USE [BeyondWallsPricingInternal]
GO
/****** Object:  StoredProcedure [dbo].[uspProcessCostReturnedFromBmiBatch]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-11-22
-- Description:	Process cost information returned by BMIBATCH (GFR)
-- =============================================
CREATE PROCEDURE [dbo].[uspProcessCostReturnedFromBmiBatch]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ProgramName VARCHAR(128) = OBJECT_NAME(@@PROCID);
	DECLARE @ErrorSaved INT;
	
	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Started execution'

	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Read cost returned by BmiBatch'
	SELECT 
		[CostFromBmiBatchId],
		[Model],
		[Model.Options],
		[Unit Total],
		[Errors?],
		[BmiBatchFullFileName],
		[BmiBatchFileLastWriteTime],
		[LoadDateTime]
	INTO 
		#CostFromBmiBatch
	FROM 
		[dbo].[CostFromBmiBatch];
	IF (SELECT COUNT(*) FROM #CostFromBmiBatch) = 0 BEGIN
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Nothing to be processed. Finishing the execution'
		RETURN 0
	END
	-- Report Model+Options found in the BmiBatch files
	SELECT
		[Model.Options] AS [ModelOptionsStringDesc with cost information returned by BMIBATCH],
		[Unit Total] AS [ModelOptionsStringCost]
	FROM 
		#CostFromBmiBatch
	ORDER BY
		[Model.Options];

	BEGIN TRANSACTION
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Update table [ModelOptionsString] with data from BMIBATCH'
		UPDATE mo
		SET
			mo.[ModelOptionsStringCost] = CEILING(bmibatch.[Unit Total]), -- Round the cost to the next integer, requested by Beyond Walls Team
			mo.[ModelOptionsStringStateId] = [dbo].[udfGetModelOptionsStringStateId]('NeedPrice')
		FROM
			[dbo].[ModelOptionsString] AS mo
		JOIN
			#CostFromBmiBatch AS bmibatch
			ON
				mo.[ModelOptionsStringDesc]  = bmibatch.[Model.Options];
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to Update table [ModelOptionsString] with data from BMIBATCH', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
	
		INSERT INTO [dbo].[ModelOptionsString](
			--[ModelOptionsStringId],
			[ModelOptionsStringDesc],
			[PriceFactorId], -- This information is not provided from BMIBATCH, a default value will be assigned to it
			[ModelOptionsStringCost],
			[ModelOptionsStringStateId]
		)
			SELECT DISTINCT -- eliminates duplicated data sent from BMIBATCH
				--(NEWID()),
				[Model.Options],
				0, -- Defaults to the index of the highest margin price factor
				[Unit Total],
				[dbo].[udfGetModelOptionsStringStateId]('NeedPrice')
			FROM
				#CostFromBmiBatch
			WHERE
				[Model.Options] NOT IN (SELECT [ModelOptionsStringDesc] FROM [dbo].[ModelOptionsString]);
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to Insert data from BMIBATCH into table [ModelOptionsString]', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
		
		INSERT INTO [dbo].[CostFromBmiBatchArchive](
			[CostFromBmiBatchArchiveId]
			,[CostFromBmiBatchArchiveDateTime]
			,[CostFromBmiBatchId]
			,[Model]
			,[Model.Options]
			,[Unit Total]
		    ,[Errors?]
			,[BmiBatchFullFileName]
			,[BmiBatchFileLastWriteTime]
			,[LoadDateTime]
		)
			SELECT
				(NEWID()),
				(GETDATE()),
				[CostFromBmiBatchId],
				[Model],
				[Model.Options],
				[Unit Total],
				[Errors?],
				[BmiBatchFullFileName],
				[BmiBatchFileLastWriteTime],
				[LoadDateTime]
			FROM
				#CostFromBmiBatch;
		DELETE FROM
			[dbo].[CostFromBmiBatch]
		WHERE
			[CostFromBmiBatchId] IN (SELECT [CostFromBmiBatchId] FROM #CostFromBmiBatch);
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to archieve BMIBATCH data', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
	COMMIT;
	
	DROP TABLE #CostFromBmiBatch;
	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Finished execution'
END


GO
