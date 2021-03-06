USE [BeyondWallsPricing]
GO
/****** Object:  StoredProcedure [dbo].[uspCreatePriceRequest]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-11-14
-- Description:	Request to calculate prices
-- =============================================
CREATE PROCEDURE [dbo].[uspCreatePriceRequest]
	-- Add the parameters for the stored procedure here
	@PriceRequestUserId VARCHAR(128),
	@PriceRequestItemTable PriceRequestItemTableType READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ProgramName VARCHAR(128) = OBJECT_NAME(@@PROCID);
	DECLARE @usrMsg VARCHAR(1024) = 'Execution Started';
	DECLARE @PriceRequestDateTime DATETIME;
	DECLARE @PriceRequestUniqueIdentifier UNIQUEIDENTIFIER;

	-- Validate input parameters
	IF (@PriceRequestUserId IS NULL)
		SET @usrMsg = 'PriceRequestUserId cannot be NULL'
	ELSE BEGIN
		IF (SELECT COUNT(*) FROM @PriceRequestItemTable) = 0
			SET @usrMsg = 'PriceRequestItemTable cannot be empty'
		ELSE IF EXISTS(SELECT 'x' FROM @PriceRequestItemTable WHERE [PriceFactorId] NOT IN (SELECT [PriceFactorId] FROM [dbo].[PriceFactor] WITH(NOLOCK)))
				SET @usrMsg = 'Price requests cannot contain invalid Price Factors'
			ELSE BEGIN
				SET @PriceRequestDateTime = GETDATE();
				SET @PriceRequestUniqueIdentifier = NEWID();
				BEGIN TRANSACTION;
				INSERT INTO dbo.PriceRequest (
					[PriceRequestId],
					[PriceRequestUserId],
					[PriceRequestDateTime]
				)
				VALUES(
					@PriceRequestUniqueIdentifier,
					@PriceRequestUserid,
					@PriceRequestDateTime
				);
				IF @@ERROR = 0 BEGIN
					INSERT INTO dbo.PriceRequestItem (
						[PriceRequestItemId],
						[ModelOptionsStringDesc],
						[PriceFactorId],
						[PriceRequestId]
					)
					SELECT
						NEWID(),
						LTRIM(RTRIM([ModelOptionsStringDesc])),
						[PriceFactorId],
						@PriceRequestUniqueIdentifier
					FROM
						@PriceRequestItemTable;
					SET @usrMsg = 'Execution Completed Successfully'
					COMMIT;
					
					-- Attempts to move the Price Request to Price Result if all prices are availble in the database
					IF NOT EXISTS(	SELECT 'x' 
								FROM 
									msdb.dbo.sysjobactivity AS sja 
								INNER JOIN 
									msdb.dbo.sysjobs AS sj 
										ON sja.job_id = sj.job_id 
								WHERE 
									sja.start_execution_date IS NOT NULL
									AND sja.stop_execution_date IS NULL
									AND sj.name = 'BeyondWallsPricingUspProcessPriceRequest')
						EXEC msdb.dbo.sp_start_job  
								@job_name = N'BeyondWallsPricingUspProcessPriceRequest' 

					-- Creates Cost Requests if needed
					IF NOT EXISTS(	SELECT 'x' 
								FROM 
									msdb.dbo.sysjobactivity AS sja 
								INNER JOIN 
									msdb.dbo.sysjobs AS sj 
										ON sja.job_id = sj.job_id 
								WHERE 
									sja.start_execution_date IS NOT NULL
									AND sja.stop_execution_date IS NULL
									AND sj.name = 'BeyondWallsPricingInternalUspCreateRequestToCalculateCost')
						EXEC msdb.dbo.sp_start_job  
							@job_name = N'BeyondWallsPricingInternalUspCreateRequestToCalculateCost' 
				END -- @@ERROR = 0 for INSERT INTO dbo.PriceRequest
				ELSE BEGIN
					SET @usrMsg = 'Failed to insert Price Request'
					ROLLBACK;	
				END -- ELSE @@ERROR = 0 for INSERT INTO dbo.PriceRequest
			END -- ELSE (SELECT COUNT(*) FROM @PriceRequestItemTable) = 0
	END -- ELSE @PriceRequestUserId IS NULL

    SELECT 
		@PriceRequestUniqueIdentifier AS [PriceRequestUniqueIdentifier],
		@usrMsg as [UsrMsg],
		@ProgramName as [ProgramName]
END


GO
GRANT EXECUTE ON [dbo].[uspCreatePriceRequest] TO [CetUsr] AS [dbo]
GO
