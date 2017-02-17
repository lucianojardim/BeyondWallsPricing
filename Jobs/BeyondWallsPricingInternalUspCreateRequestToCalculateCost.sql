USE [msdb]
GO

/****** Object:  Job [BeyondWallsPricingInternalUspCreateRequestToCalculateCost]    Script Date: 2/17/2017 1:54:59 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [BeyondWallsPricingInternal]    Script Date: 2/17/2017 1:54:59 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'BeyondWallsPricingInternal' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'BeyondWallsPricingInternal'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BeyondWallsPricingInternalUspCreateRequestToCalculateCost', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Calculate cost and sends price to the BeyondWallsPricing database', 
		@category_name=N'BeyondWallsPricingInternal', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'ITEBIZONCALL', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step01]    Script Date: 2/17/2017 1:54:59 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step01', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Finds what needs to have cost calculated, and sends requests to BMIBATCH
EXEC [dbo].[uspCreateRequestToCalculateCost];

-- Update table ModelOptionsSring with cost from BMIBATCH
EXEC [dbo].[uspProcessCostReturnedFromBmiBatch];

-- Calculate and send price to the BeyondWallsPricing DMZ database
EXEC [dbo].[uspCalculateBeyondWallsPrice];', 
		@database_name=N'BeyondWallsPricingInternal', 
		@output_file_name=N'$(ESCAPE_NONE(SQLLOGDIR))\BeyondWallsPricingInternalUspCreateRequestToCalculateCost.$(ESCAPE_NONE(STEPID)).$(ESCAPE_NONE(STRTDT)).$(ESCAPE_NONE(STRTTM)).log', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'BeyondWallsPricingInternalUspCreateRequestToCalculateCost', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20161203, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'5b44e301-6fe9-457a-b5a5-e4e4f60f6360'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


