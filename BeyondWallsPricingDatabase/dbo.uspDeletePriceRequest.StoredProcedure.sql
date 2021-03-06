USE [BeyondWallsPricing]
GO
/****** Object:  StoredProcedure [dbo].[uspDeletePriceRequest]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2017-01-04
-- Description:	Delete a Price Request (including the related items)
-- =============================================
CREATE PROCEDURE [dbo].[uspDeletePriceRequest]
	-- Add the parameters for the stored procedure here
	@PriceRequestId UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ProgramName VARCHAR(128) = OBJECT_NAME(@@PROCID);
	DECLARE @ErrorSaved INT;

	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Started execution'

	BEGIN TRANSACTION
		SELECT * FROM [dbo].[PriceRequest_VW] WHERE [PriceRequestId] = @PriceRequestId;

		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' DELETE FROM [dbo].[PriceRequestItem]'
		DELETE FROM [dbo].[PriceRequestItem] WHERE [PriceRequestId] = @PriceRequestId;
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to delete from PriceRequestItem', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END

		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' DELETE FROM [dbo].[PriceRequest]'
		DELETE FROM [dbo].[PriceRequest] WHERE [PriceRequestId] = @PriceRequestId;
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to delete from PriceRequest', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END

	COMMIT;
		
	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Finished execution'
END


GO
