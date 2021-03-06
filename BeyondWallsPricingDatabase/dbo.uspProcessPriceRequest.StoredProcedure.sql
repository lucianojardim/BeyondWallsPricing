USE [BeyondWallsPricing]
GO
/****** Object:  StoredProcedure [dbo].[uspProcessPriceRequest]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-11-17
-- Description:	Process requests made to calculate prices
-- =============================================
CREATE PROCEDURE [dbo].[uspProcessPriceRequest]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ProgramName VARCHAR(128) = OBJECT_NAME(@@PROCID);
	DECLARE @ErrorSaved INT;

	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Started execution'
	
	-- For each PriceRequestId in PriceRequest check if all ModelOptionsStringDesc in PriceRequestItem have prices in ModelOptionsString
	SELECT 
		pr.[PriceRequestId] -- PriceRequestId with only items that were priced already
	INTO
		#PriceRequestIdReadyToBeMoved
	FROM 
		[dbo].[PriceRequest] AS pr
	WHERE
		pr.[PriceRequestId] NOT IN (SELECT 
										pri.[PriceRequestId] -- PriceRequestId with items not priced yet
									FROM 
										[dbo].[PriceRequestItem] AS pri
									WHERE
										[dbo].[udfGetModelOptionsStringProduct](pri.[ModelOptionsStringDesc]) IN -- ModelOptionsStringDesc not priced yet
											(SELECT 
												[dbo].[udfGetModelOptionsStringProduct](pri2.[ModelOptionsStringDesc]) -- remove .NA
											FROM 
												[dbo].[PriceRequestItem] AS pri2
											EXCEPT
											SELECT 
												[dbo].[udfGetModelOptionsStringProduct](mo.[ModelOptionsStringDesc]) -- remove .price option (CHAR(5))
											FROM 
												[dbo].[ModelOptionsString] AS mo
											));
	IF (SELECT COUNT(*) FROM #PriceRequestIdReadyToBeMoved) = 0 BEGIN
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Nothing to be processed. Finishing the execution'
		RETURN 0
	END						
	-- Report what is going to be deleted
	SELECT 
		[PriceRequestId] AS [PriceRequestId to be moved to PriceResults],
		[PriceRequestUserId],
		[PriceRequestDateTime],
		[PriceRequestItemId],
		[ModelOptionsStringDesc]
	FROM 
		[dbo].[PriceRequest_VW]
	WHERE
		[PriceRequestId] IN (SELECT [PriceRequestId] FROM #PriceRequestIdReadyToBeMoved)
	ORDER BY
		[PriceRequestId],
		[PriceRequestItemId];
		
	-- Move PriceRequest with all items priced to PriceResult 
	BEGIN TRANSACTION
		-- Insert into Price Results
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Insert into Price Results when prices were already available'
		INSERT INTO [dbo].[PriceResult]
			SELECT
				[PriceRequestId],
				[PriceRequestUserId],
				GETDATE()
			FROM 
				[dbo].[PriceRequest]
			WHERE
				[PriceRequestId] IN (SELECT [PriceRequestId] FROM #PriceRequestIdReadyToBeMoved);
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to insert price results', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
		
		INSERT INTO [dbo].[PriceResultItem]
			SELECT
				pri.[PriceRequestItemId],
				mo.[ModelOptionsStringDesc],
				pri.[PriceRequestId],
				mo.[ModelOptionsStringPrice]
			FROM 
				[dbo].[PriceRequestItem] AS pri
			INNER JOIN
				[dbo].[ModelOptionsString] AS mo
					ON [dbo].[udfGetModelOptionsStringProduct](mo.[ModelOptionsStringDesc]) = [dbo].[udfGetModelOptionsStringProduct](pri.[ModelOptionsStringDesc])
			WHERE
				[PriceRequestId] IN (SELECT [PriceRequestId] FROM #PriceRequestIdReadyToBeMoved);
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to insert price results items', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
		
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Archive price requests before they are deleted'
		INSERT INTO [dbo].[PriceRequestArchive](
			[PriceRequestArchiveId],
			[PriceRequestId],
			[PriceRequestUserId],
			[PriceRequestDateTime],
			[PriceRequestItemId],
			[ModelOptionsStringDesc],
			[PriceFactorId]
        )
			SELECT
				NEWID(),
				[PriceRequestId],
				[PriceRequestUserId],
				[PriceRequestDateTime],
				[PriceRequestItemId],
				[ModelOptionsStringDesc],
				[PriceFactorId]
			FROM 
				[dbo].[PriceRequest_VW]
			WHERE
				[PriceRequestId] IN (SELECT [PriceRequestId] FROM #PriceRequestIdReadyToBeMoved);
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to archive price requests', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
		
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Delete from Price Request after results are created'
		DELETE FROM
			[dbo].[PriceRequestItem]
		WHERE
			[PriceRequestId] IN (SELECT [PriceRequestId] FROM #PriceRequestIdReadyToBeMoved);
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to delete price request items', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
		
		DELETE FROM 	
			[dbo].[PriceRequest]
		WHERE
			[PriceRequestId] IN (SELECT [PriceRequestId] FROM #PriceRequestIdReadyToBeMoved);
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to delete price requests', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
	COMMIT;

	-- Report what is going to be inserted
	SELECT 
		[PriceRequestId] AS [PriceRequestId that were moved to PriceResults],
		[PriceRequestUserId],
		[PriceResultDateTime],
		[PriceRequestItemId],
		[ModelOptionsStringDesc],
		[ModelOptionsStringPrice]
	FROM 
		[dbo].[PriceResult_VW]
	WHERE
		[PriceRequestId] IN (SELECT [PriceRequestId] FROM #PriceRequestIdReadyToBeMoved)
	ORDER BY
		[PriceRequestId],
		[PriceRequestItemId];
		
	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Finished execution'
END

GO
