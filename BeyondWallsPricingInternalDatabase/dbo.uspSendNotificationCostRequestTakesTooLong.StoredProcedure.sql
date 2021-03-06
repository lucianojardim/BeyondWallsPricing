USE [BeyondWallsPricingInternal]
GO
/****** Object:  StoredProcedure [dbo].[uspSendNotificationCostRequestTakesTooLong]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-11-30
-- Description:	Send notification when Cost Request takes longer than desired
-- =============================================
CREATE PROCEDURE [dbo].[uspSendNotificationCostRequestTakesTooLong]
	-- Add the parameters for the stored procedure here
	@recipients VARCHAR(MAX) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ProgramName VARCHAR(128) = OBJECT_NAME(@@PROCID);
	DECLARE @MaxNumMinutesToProcessCostRequest INT = CAST((SELECT [ConfigurationValue] FROM [dbo].[Configuration] WHERE [ConfigurationKey] = 'MaxNumMinutesToProcessCostRequest') AS INT); 

	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Started execution'
	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' @recipients='+@recipients

	IF @recipients IS NULL BEGIN
		SET @recipients = (SELECT [ConfigurationValue] FROM [dbo].[Configuration] WHERE [ConfigurationKey] = 'RecipientsOfDelayNotifications');
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' @recepients was NULL and was reset to '+@recipients
	END;
	
	IF @MaxNumMinutesToProcessCostRequest < 0 BEGIN
		SET @MaxNumMinutesToProcessCostRequest = @MaxNumMinutesToProcessCostRequest * -1;
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' @MaxNumMinutesToProcessCostRequest was negative and was reset to '+@MaxNumMinutesToProcessCostRequest
	END;
	
	SET @MaxNumMinutesToProcessCostRequest = @MaxNumMinutesToProcessCostRequest * -1;
	DECLARE @NotificationDateTime DATETIME = DATEADD(minute,@MaxNumMinutesToProcessCostRequest,GETDATE())
	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' This program sends notification if it finds Cost Requests that are older than '+CAST(@NotificationDateTime AS VARCHAR(50))
	
	IF (SELECT COUNT(*) FROM [dbo].[ModelOptionsString_VW] WHERE [ModelOptionsStringDateTime] <= @NotificationDateTime AND [ModelOptionsStringStateDesc] <> 'PriceWasSentToTheDMZ') = 0 
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' All Cost requests are being processed within the time allotted. Nothing to report'
	ELSE BEGIN
		PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' List of Cost Requests that took longer than expected to be processed'
		SELECT 
			[ModelOptionsStringId],
			[ModelOptionsStringDesc],
			[PriceFactorId],
			[ModelOptionsStringCost],
			[ModelOptionsStringDateTime],
			[ModelOptionsStringStateDesc] 
		FROM 
			[dbo].[ModelOptionsString_VW] 
		WHERE 
			[ModelOptionsStringDateTime] <= @NotificationDateTime 
			AND [ModelOptionsStringStateDesc] <> 'PriceWasSentToTheDMZ'
		ORDER BY 
			[ModelOptionsStringDesc]

		DECLARE @profile_name sysname = 'sqlsrv';
		DECLARE @from_address varchar(MAX) = 'BeyonWallsPricing@hnicorp.com';
		DECLARE @reply_to varchar(MAX) = 'donotreply@hnicorp.com';
		DECLARE @subject NVARCHAR(255) = 'Notification from the Beyond Walls Pricing application. List of Cost Requests that are talking longer than expected to be processed';
		DECLARE @body nvarchar(max) = CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' List of Cost Requests that are talking longer than expected to be processed is attached to this email.';
		DECLARE @body_format varchar(20) = 'TEXT';
		DECLARE @query nvarchar(max) = 'SELECT [ModelOptionsStringId],[ModelOptionsStringDesc],[PriceFactorId],[ModelOptionsStringCost],[ModelOptionsStringDateTime],[ModelOptionsStringStateDesc] FROM [dbo].[ModelOptionsString_VW] WHERE [ModelOptionsStringDateTime] <= '''+CONVERT(VARCHAR(30),@NotificationDateTime,120)+''' AND [ModelOptionsStringStateDesc] <> ''PriceWasSentToTheDMZ'' ORDER BY [ModelOptionsStringDesc]';
		DECLARE @execute_query_database sysname = 'BeyondWallsPricingInternal';
		DECLARE @attach_query_result_as_file bit = 1;
		DECLARE @query_attachment_filename nvarchar(255) = 'List of Cost Requests that are talking longer than expected to be processed.txt';
		DECLARE @query_result_width INT = 330;
		EXEC msdb.dbo.sp_send_dbmail 
			@profile_name = @profile_name,
			@recipients = @recipients, 
			--[ , [ @copy_recipients = ] 'copy_recipient [ ; ...n ]' ]  
			--[ , [ @blind_copy_recipients = ] 'blind_copy_recipient [ ; ...n ]' ]  
			@from_address = @from_address,
			@reply_to = @reply_to,   
			@subject = @subject,   
			@body = @body,   
			@body_format = @body_format,  
			--[ , [ @importance = ] 'importance' ]  
			--[ , [ @sensitivity = ] 'sensitivity' ]  
			--[ , [ @file_attachments = ] 'attachment [ ; ...n ]' ]  
			@query = @query,
			@execute_query_database = @execute_query_database,  
			@attach_query_result_as_file = @attach_query_result_as_file,  
			@query_attachment_filename = @query_attachment_filename,
			--[ , [ @query_result_header = ] query_result_header ]  
			@query_result_width = @query_result_width
			--[ , [ @query_result_separator = ] 'query_result_separator' ]  
			--[ , [ @exclude_query_output = ] exclude_query_output ]  
			--[ , [ @append_query_error = ] append_query_error ]  
			--[ , [ @query_no_truncate = ] query_no_truncate ]   
			--[ , [ @query_result_no_padding = ] @query_result_no_padding ]   
			--[ , [ @mailitem_id = ] mailitem_id ] [ OUTPUT ] 
	END 
	
    PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Finished execution'
END



GO
