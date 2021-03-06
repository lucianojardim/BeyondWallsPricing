USE [BeyondWallsPricing]
GO
/****** Object:  StoredProcedure [dbo].[uspRecalculatePriceForModelOptionsString]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-12-21
-- Description:	Recalculate prices for ModelOptionsString
-- =============================================
CREATE PROCEDURE [dbo].[uspRecalculatePriceForModelOptionsString]
	-- Add the parameters for the stored procedure here
	@ModelOptionsStringDesc VARCHAR(100),
	@PriceFactorId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ProgramName VARCHAR(128) = OBJECT_NAME(@@PROCID);
	DECLARE @ErrorSaved INT;

	DECLARE @ModelOptionsStringProduct VARCHAR(100) = [dbo].[udfGetModelOptionsStringProduct](@ModelOptionsStringDesc);
	DECLARE @ModelOptionsStringProductLIKE VARCHAR(100) = @ModelOptionsStringProduct+'______';
	DECLARE @ModelOptionsStringProductNA VARCHAR(100) = @ModelOptionsStringProduct+'.NA';
	DECLARE @PriceRequestItemTable AS PriceRequestItemTableType;

	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Started execution'
	
	IF (@PriceFactorId IS NULL) OR NOT EXISTS(SELECT 'x' FROM [dbo].[PriceFactor] WHERE [PriceFactorId] = @PriceFactorId) BEGIN
			RAISERROR(N'@PriceFactorId is invalid. It cannot be NULL and must match existing range', 16, 1);
			RETURN 16
	END
			
	-- Move PriceRequest with all items priced to PriceResult 
	BEGIN TRANSACTION
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Delete previously calculated price'
		SELECT * FROM [dbo].[modelOptionsString] WHERE [ModelOptionsStringDesc] LIKE @ModelOptionsStringProductLIKE;
		DELETE FROM [dbo].[modelOptionsString] WHERE [ModelOptionsStringDesc] LIKE @ModelOptionsStringProductLIKE;
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to delete previously calculated price', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END

		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Delete previously calculated cost'
		SELECT * FROM [BeyondWallsPricingInternal].[dbo].[modelOptionsString] WHERE [ModelOptionsStringDesc] = @ModelOptionsStringProductNA;
		DELETE FROM [BeyondWallsPricingInternal].[dbo].[modelOptionsString] WHERE [ModelOptionsStringDesc] = @ModelOptionsStringProductNA;
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to delete previously calculated cost', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
 
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Create new price request for '+@ModelOptionsStringDesc
		INSERT INTO @PriceRequestItemTable ([ModelOptionsStringDesc], [PriceFactorId]) VALUES 
			(@ModelOptionsStringProductNA,@PriceFactorId);
		EXEC @ErrorSaved = [dbo].[uspCreatePriceRequest]
			@PriceRequestUserId = 'BeyondWallsUsr',
			@PriceRequestItemTable = @PriceRequestItemTable;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to create new price request', 16, 1);
			ROLLBACK;
			RETURN @ErrorSaved
		END
	COMMIT;

	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Finished execution'
END


GO
