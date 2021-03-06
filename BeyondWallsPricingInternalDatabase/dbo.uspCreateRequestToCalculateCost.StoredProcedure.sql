USE [BeyondWallsPricingInternal]
GO
/****** Object:  StoredProcedure [dbo].[uspCreateRequestToCalculateCost]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-11-17
-- Description:	Send request to calculate cost as needed
-- =============================================
CREATE PROCEDURE [dbo].[uspCreateRequestToCalculateCost]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ProgramName VARCHAR(128) = OBJECT_NAME(@@PROCID);
	DECLARE @ErrorSaved INT;

	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Started execution'
	-- Maximum number of Model+Options strings that BMIBATCH can process at once
	DECLARE @maxModelOptionsBMIBATCH INT = (SELECT CAST(ConfigurationValue AS INT) FROM [dbo].[Configuration] WHERE [ConfigurationKey]='MaxModelOptionsBMIBATCH');

	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Connect to Beyond Walls Pricing in the DMZ to find out what Model+Options need to have price calculated'
	SELECT 
		[ModelOptionsStringDesc],
		[PriceFactorId]
	INTO 
		#ModelOptionsStringThatNeedPrice
	FROM 
		[BeyondWallsPricing].[dbo].[udfGetModelOptionsStringThatNeedPrice]();
	-- Report Model+Options that need to have price calculated
	SELECT
		[ModelOptionsStringDesc] AS [ModelOptionsStringDesc of Price Requests that are still without price available],
		[PriceFactorId]
	FROM 
		#ModelOptionsStringThatNeedPrice
	ORDER BY
		[ModelOptionsStringDesc];

	IF (SELECT COUNT(*) FROM #ModelOptionsStringThatNeedPrice WHERE [ModelOptionsStringDesc] NOT IN (SELECT [ModelOptionsStringDesc] FROM [dbo].[ModelOptionsString])) = 0 BEGIN
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Nothing to be processed. Finishing the execution'
		RETURN 0
	END
	
	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Save new Model+Options that need to have cost calculated'
	INSERT INTO [dbo].[ModelOptionsString](
		[ModelOptionsStringId],
		[ModelOptionsStringDesc],
		[PriceFactorId],
		[ModelOptionsStringStateId]
	)
		SELECT
			NEWID(),
			[ModelOptionsStringDesc],
			[PriceFactorId],
			[dbo].[udfGetModelOptionsStringStateId]('NeedCost')
		FROM
			#ModelOptionsStringThatNeedPrice
		WHERE
			[ModelOptionsStringDesc] NOT IN (SELECT [ModelOptionsStringDesc] FROM [dbo].[ModelOptionsString])
	SET @ErrorSaved = @@ERROR;
	IF @ErrorSaved <> 0 BEGIN
		RAISERROR(N'Failed to insert Model.Options that need cost into [ModelOptionsString]', 16, 1);
		RETURN @ErrorSaved
	END
	DROP TABLE #ModelOptionsStringThatNeedPrice;

	-- Find what Model+Options need to have cost calculated
	SELECT 
		[ModelOptionsStringDesc] 
	INTO 
		#ModelOptionsStringThatNeedCost
	FROM 
		[dbo].[ModelOptionsString]
	WHERE 
		[ModelOptionsStringStateId] = [dbo].[udfGetModelOptionsStringStateId]('NeedCost');

	DECLARE @numRows INT = (SELECT COUNT(*) FROM #ModelOptionsStringThatNeedCost);
	IF (@numRows > 0) BEGIN
		-- Add trailing spaces, required by BMIBATCH
		ALTER TABLE #ModelOptionsStringThatNeedCost ALTER COLUMN [ModelOptionsStringDesc] CHAR(100); -- CHAR(100) is required to add spaces at the end of the string
		-- Add sequential number to read data
		ALTER TABLE #ModelOptionsStringThatNeedCost ADD [SeqNum] INT  IDENTITY(1,1) NOT NULL;

		DECLARE @i INT = 1; -- loop to read all rows
		DECLARE @lastEvtDsRequestArchiveId uniqueidentifier; -- pointer to last EVT_DS information generated
		DECLARE @INF_EVENT_EVT VARCHAR(1000) = ''; -- same size of the BMIBATCH buffer (PRODDB.EVT_DS)
		DECLARE @j INT = 1; -- loop to send @maxModelOptionsBMIBATCH rows at once to BMIBATCH
		WHILE (@i <= @numRows) BEGIN
		
			SET @j = 1; -- loop to send @maxModelOptionsBMIBATCH rows at once to BMIBATCH
			SET @INF_EVENT_EVT = ''; -- reset buffer
			WHILE (@j <= @maxModelOptionsBMIBATCH) AND (@i <= @numRows) BEGIN
				SET @INF_EVENT_EVT = @INF_EVENT_EVT + (SELECT [ModelOptionsStringDesc] FROM #ModelOptionsStringThatNeedCost WHERE [SeqNum] = @i); -- prepare string to be sent to BMIBATCH
				SET @j = @j + 1;
				SET @i = @i + 1;
			END
			
			PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Send information to be processed by BMIBATCH'
			SELECT @INF_EVENT_EVT AS [Set of Model+Options that is going to be sent to BMIBATCH]
			-- insert Model+Options that need price into the table used by BMIBATCH
			/*
			CD_COMPANY_EVT     NUMBER(4)       = 200  
			CD_EVT_RSN_EVT     CHAR(6)         = “M531”
			CD_EVT_TRAN_EVT    CHAR(8)         = “M531”
			TM_EVT_CRTD_EVT    CHAR(6)         = current time (you can leave blank)
			DT_EVT_CRTD_EVT    NUMBER(5)       = today’s date (you can leave blank)
			CD_INFO_REQ_EVT    NUMBER(3)       = leave blank
			NUM_SEQ_EVT        NUMBER(12)      = leave blank
			SDN_EVT_CRTD_EVT   NUMBER(5)       = today’s SDN date (you can leave blank)
			KEY_ALPHA_EVT      CHAR(35)        = leave blank
			CD_USER_CRTD_EVT   CHAR(13)        = your program name, or something descriptive
			INF_EVENT_EVT      VARCHAR2(1000)  = model.option string(s)
			EVT_DS_DUP         NUMBER(10)      = leave blank
			DT_DB_UPDT_EVT_DS  DATE            = system generated timestamp, no need to worry about this
			*/
			INSERT INTO [BWPDB]..[PRODDB].[EVT_DS] (
				[CD_COMPANY_EVT],
				[CD_EVT_RSN_EVT],
				[CD_EVT_TRAN_EVT],
				[TM_EVT_CRTD_EVT],
				[DT_EVT_CRTD_EVT],
				[CD_INFO_REQ_EVT],
				[NUM_SEQ_EVT],
				[SDN_EVT_CRTD_EVT],
				[KEY_ALPHA_EVT],
				[CD_USER_CRTD_EVT],
				[INF_EVENT_EVT],
				--[EVT_DS_DUP],
				[DT_DB_UPDT_EVT_DS]
			)
			VALUES(
				200,
				'M531',
				'M531',
				'',
				0,
				0,
				@i,
				0,
				'',
				'BEYOND WALLS',
				@INF_EVENT_EVT,
				--@i,
				CAST(GETDATE() AS SMALLDATETIME)
			);
			SET @ErrorSaved = @@ERROR;
			-- Attempt to display the request sent to BMIBATCH
			DECLARE @maxEVT_DS_DUP INT = (SELECT MAX([EVT_DS_DUP]) FROM [BWPDB]..[PRODDB].[EVT_DS])
			SELECT TOP 1 * FROM [BWPDB]..[PRODDB].[EVT_DS] WHERE [CD_EVT_TRAN_EVT] = 'M531' AND [EVT_DS_DUP] > @maxEVT_DS_DUP - 10000 ORDER BY [DT_DB_UPDT_EVT_DS] DESC
			IF @ErrorSaved <> 0 BEGIN
				RAISERROR(N'Failed to insert BMIBATCH request into PRODDB.EVT_DS', 16, 1);
				RETURN @ErrorSaved
			END

			-- Insert into the SQL Server database to keep track of the requests
			SET @lastEvtDsRequestArchiveId = NEWID();
			INSERT INTO [dbo].[EvtDsRequestArchive](
				[EvtDsRequestArchiveId],
				[EvtDsRequestArchiveDateTime],
				[CD_COMPANY_EVT],
				[CD_EVT_RSN_EVT],
				[CD_EVT_TRAN_EVT],
				[TM_EVT_CRTD_EVT],
				[DT_EVT_CRTD_EVT],
				[CD_INFO_REQ_EVT],
				[NUM_SEQ_EVT],
				[SDN_EVT_CRTD_EVT],
				[KEY_ALPHA_EVT],
				[CD_USER_CRTD_EVT],
				[INF_EVENT_EVT],
				[EVT_DS_DUP],
				[DT_DB_UPDT_EVT_DS]
			)
			VALUES(
				@lastEvtDsRequestArchiveId,
				GETDATE(),
				200,
				'M531',
				'M531',
				'',
				0,
				0,
				@i,
				0,
				'',
				'BEYOND WALLS',
				@INF_EVENT_EVT,
				-1,
				CAST(GETDATE() AS SMALLDATETIME)
			);
			
			SELECT
				[EvtDsRequestArchiveId]
				[EvtDsRequestArchiveDateTime],
				[CD_COMPANY_EVT],
				[CD_EVT_RSN_EVT],
				[CD_EVT_TRAN_EVT],
				[TM_EVT_CRTD_EVT],
				[DT_EVT_CRTD_EVT],
				[CD_INFO_REQ_EVT],
				[NUM_SEQ_EVT],
				[SDN_EVT_CRTD_EVT],
				[KEY_ALPHA_EVT],
				[CD_USER_CRTD_EVT],
				[INF_EVENT_EVT],
				[EVT_DS_DUP],
				[DT_DB_UPDT_EVT_DS]
			FROM
				[dbo].[EvtDsRequestArchive]
			WHERE
				[EvtDsRequestArchiveId] = @lastEvtDsRequestArchiveId;
		END -- (@i <= @numRows)
		
		-- Change the status of Model+Options that were sent to be processed by BMIBATCH
		UPDATE 
			[dbo].[ModelOptionsString] 
		SET 
			[ModelOptionsStringStateId] = [dbo].[udfGetModelOptionsStringStateId]('Waiting for cost from BMIBATCH')
		WHERE
			[ModelOptionsStringDesc] IN (SELECT [ModelOptionsStringDesc] FROM #ModelOptionsStringThatNeedCost);
		SET @ErrorSaved = @@ERROR;
		IF @ErrorSaved <> 0 BEGIN
			RAISERROR(N'Failed to update [dbo].[ModelOptionsString] with the new state assumed when data is sent to BMIBATCH', 16, 1);
			RETURN @ErrorSaved
		END
	END
	DROP TABLE #ModelOptionsStringThatNeedCost;
	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Finished execution'
END

GO
