USE [BeyondWallsPricingInternal]
GO
/****** Object:  StoredProcedure [dbo].[uspPurgeDataFromBeyondWallsPricingInternal]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-12-02
-- Description:	Delete cost related data that are no longer necessary
-- =============================================
CREATE PROCEDURE [dbo].[uspPurgeDataFromBeyondWallsPricingInternal]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ProgramName VARCHAR(128) = OBJECT_NAME(@@PROCID);
	DECLARE @ErrorSaved INT;
	DECLARE @NumDaysSinceDataWasCreated INT = CAST((SELECT [ConfigurationValue] FROM [dbo].[Configuration] WHERE [ConfigurationKey] = 'NumDaysSinceDataWasCreated') AS INT); 

	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Started execution'
	
	IF @NumDaysSinceDataWasCreated < 0 BEGIN
		SET @NumDaysSinceDataWasCreated = 31;
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' @NumDaysSinceDataWasCreated was negative and was reset to 31'
	END;
	SET @NumDaysSinceDataWasCreated = @NumDaysSinceDataWasCreated * -1;
	DECLARE @TargetDateTime DATETIME = DATEADD(dd,@NumDaysSinceDataWasCreated,GETDATE())
	
	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' This program is going to delete data created before '+CAST(@TargetDateTime AS VARCHAR(50))
 
	BEGIN TRANSACTION
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' DELETE FROM [dbo].[CostFromBmiBatchArchive]'
		SELECT * FROM [dbo].[CostFromBmiBatchArchive] WHERE [CostFromBmiBatchArchiveDateTime] < @TargetDateTime;
		DELETE FROM [dbo].[CostFromBmiBatchArchive] WHERE [CostFromBmiBatchArchiveDateTime] < @TargetDateTime;
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to delete from CostFromBmiBatchArchive', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
		
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' DELETE FROM [dbo].[EvtDsRequestArchive]'
		SELECT * FROM [dbo].[EvtDsRequestArchive] WHERE [EvtDsRequestArchiveDateTime] < @TargetDateTime;
		DELETE FROM [dbo].[EvtDsRequestArchive] WHERE [EvtDsRequestArchiveDateTime] < @TargetDateTime;
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to delete from EvtDsRequestArchive', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
		
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' DELETE FROM [dbo].[ModelOptionsString]'
		SELECT * FROM [dbo].[ModelOptionsString] WHERE [ModelOptionsStringDateTime] < @TargetDateTime AND [ModelOptionsStringStateId] = [dbo].[udfGetModelOptionsStringStateId]('PriceWasSentToTheDMZ');
		DELETE FROM [dbo].[ModelOptionsString] WHERE [ModelOptionsStringDateTime] < @TargetDateTime AND [ModelOptionsStringStateId] = [dbo].[udfGetModelOptionsStringStateId]('PriceWasSentToTheDMZ');
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to delete from ModelOptionsString', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
	COMMIT;

    PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Finished execution'
END


GO
