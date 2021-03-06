USE [BeyondWallsPricingInternal]
GO
/****** Object:  StoredProcedure [dbo].[uspCalculateBeyondWallsPrice]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-11-22
-- Description:	Calculate price and send it to the DMZ database
-- =============================================
CREATE PROCEDURE [dbo].[uspCalculateBeyondWallsPrice]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ProgramName VARCHAR(128) = OBJECT_NAME(@@PROCID);
	DECLARE @ErrorSaved INT;
		
	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Started execution'
	
	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Read Model+Options have cost already calculated for them and hadn''t been priced yet'
	SELECT 
		[ModelOptionsStringId],
		[ModelOptionsStringDesc],
		[PriceFactorId],
		[ModelOptionsStringCost],
		CEILING([ModelOptionsStringCost]/([dbo].[udfGetPriceFactorAmount](PriceFactorId)))+1 AS [ModelOptionsStringPrice], -- Price = (Cost from BMIBATCH rounded to next integer)/(Price Factor) rounded to the next integer + 1 dollar
		[ModelOptionsStringStateId]
	INTO 
		#ModelOptionsStringThatHaveCost
	FROM 
		[dbo].[ModelOptionsString]
	WHERE
		[ModelOptionsStringStateId] = [dbo].[udfGetModelOptionsStringStateId]('NeedPrice')
	IF (SELECT COUNT(*) FROM #ModelOptionsStringThatHaveCost) = 0 BEGIN
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Nothing to be processed. Finishing the execution'
		RETURN 0
	END
	-- Report Model+Options that need to have price calculated
	SELECT
		[ModelOptionsStringDesc] AS [ModelOptionsStringDesc that already have cost determined and need price to be calculated],
		[PriceFactorId],
		[ModelOptionsStringCost]
	FROM 
		#ModelOptionsStringThatHaveCost
	ORDER BY
		[ModelOptionsStringDesc];
	
	-- Decide what ModelOptionsString needs a new Price Options
	SELECT DISTINCT
		[ModelOptionsStringPrice]
	INTO 
		#ModelOptionsStringPriceWithoutPriceOption
	FROM 
		#ModelOptionsStringThatHaveCost
	WHERE 
		[ModelOptionsStringPrice] NOT IN (SELECT [PriceOptionAmount] FROM [dbo].[PriceOption] WHERE [PriceOptionAmount] IS NOT NULL)
		AND [ModelOptionsStringPrice] IS NOT NULL;
	ALTER TABLE #ModelOptionsStringPriceWithoutPriceOption ADD [SeqNum] INT  IDENTITY(1,1) NOT NULL; 
	
	BEGIN TRANSACTION
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Create new Price Options (if needed)'
		DECLARE @NumNewPriceOptionsToBeProcessed INT = (SELECT COUNT(*) FROM #ModelOptionsStringPriceWithoutPriceOption);
		DECLARE @NumNewPriceOptionsProcessed INT = 1;
 		WHILE (@NumNewPriceOptionsToBeProcessed >= @NumNewPriceOptionsProcessed) BEGIN
			INSERT INTO [dbo].[PriceOption](
			   [PriceOptionDesc],
			   [PriceOptionAmount]
			)
				SELECT
					[dbo].[udfGetNextPriceOptionDesc]([ModelOptionsStringPrice]),
					[ModelOptionsStringPrice]
				FROM 
					#ModelOptionsStringPriceWithoutPriceOption
				WHERE 
					[SeqNum] = @NumNewPriceOptionsProcessed
					AND [dbo].[udfGetNextPriceOptionDesc]([ModelOptionsStringPrice]) IS NOT NULL;
			SET @ErrorSaved = @@ERROR;
			IF @ErrorSaved <> 0 BEGIN
				RAISERROR(N'Failed to insert new Price Options', 16, 1);
				ROLLBACK;
				RETURN @ErrorSaved
			END
			
			SET @NumNewPriceOptionsProcessed = @NumNewPriceOptionsProcessed + 1;
		END
		IF @NumNewPriceOptionsToBeProcessed > 0
			SELECT * FROM [dbo].[PriceOption] WITH(NOLOCK) WHERE [PriceOptionAmount] IN (SELECT [ModelOptionsStringPrice] FROM #ModelOptionsStringPriceWithoutPriceOption);
		ELSE
			PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' No new Price Options were found. Nothing was changed'
		
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Send price data to the DMZ'
		INSERT INTO [BeyondWallsPricing].[dbo].[ModelOptionsString](
			[ModelOptionsStringDesc],
			[ModelOptionsStringPrice]
		)
			SELECT
				[dbo].[udfGetModelOptionsStringDescToPostPrice]([ModelOptionsStringDesc], [ModelOptionsStringPrice]), -- Remove .NA and adds the Price Option string
				[ModelOptionsStringPrice]
			FROM 
				#ModelOptionsStringThatHaveCost
			WHERE
				[ModelOptionsStringDesc] IN (SELECT [ModelOptionsStringDesc] FROM [BeyondWallsPricing].[dbo].[udfGetModelOptionsStringThatNeedPrice]());
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to insert price information into the DMZ database', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Update the state of Model+Options string'
		UPDATE 
			[dbo].[ModelOptionsString]
		SET 
			[ModelOptionsStringStateId] = [dbo].[udfGetModelOptionsStringStateId]('PriceWasSentToTheDMZ')
		WHERE 
			[ModelOptionsStringDesc] IN (SELECT [ModelOptionsStringDesc] FROM #ModelOptionsStringThatHaveCost);
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to update the state of Model+Options string', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
	COMMIT;

	DROP TABLE #ModelOptionsStringThatHaveCost;
	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Finished execution'
END



GO
