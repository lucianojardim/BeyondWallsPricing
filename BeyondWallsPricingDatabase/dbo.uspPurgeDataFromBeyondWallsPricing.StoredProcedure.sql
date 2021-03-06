USE [BeyondWallsPricing]
GO
/****** Object:  StoredProcedure [dbo].[uspPurgeDataFromBeyondWallsPricing]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-11-29
-- Description:	Delete price results and archived price requests that are no longer necessary
-- =============================================
CREATE PROCEDURE [dbo].[uspPurgeDataFromBeyondWallsPricing]
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
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' DELETE FROM [dbo].[PriceResultItem] and [dbo].[PriceResult]'
		SELECT * FROM [dbo].[PriceResult_VW] WHERE [PriceResultDateTime] < @TargetDateTime;
		DELETE FROM [dbo].[PriceResultItem] WHERE PriceRequestId IN (SELECT PriceRequestId FROM [dbo].[PriceResult] WHERE [PriceResultDateTime] < @TargetDateTime);
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to delete from PriceResultItem', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
		DELETE FROM [dbo].[PriceResult] WHERE [PriceResultDateTime] < @TargetDateTime;
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to delete from PriceResult', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
		
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' DELETE FROM [dbo].[PriceRequestArchive]'
		SELECT * FROM [dbo].[PriceRequestArchive] WHERE [PriceRequestDateTime] < @TargetDateTime;
		DELETE FROM [dbo].[PriceRequestArchive] WHERE [PriceRequestDateTime] < @TargetDateTime;
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to delete from PriceRequestArchive', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
	COMMIT;

    PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Finished execution'
END


GO
