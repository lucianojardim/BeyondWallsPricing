USE [msdb]
GO
CREATE USER [BeyondWallsUsr] FOR LOGIN [BeyondWallsUsr]
GO
ALTER ROLE [SQLAgentOperatorRole] ADD MEMBER [BeyondWallsUsr]
GO
ALTER ROLE [DatabaseMailUserRole] ADD MEMBER [BeyondWallsUsr]
GO

CREATE USER [CetUsr] FOR LOGIN [CetUsr]
GO
ALTER ROLE [SQLAgentOperatorRole] ADD MEMBER [CetUsr]
GO

GRANT SELECT ON [msdb].[dbo].[sysjobs] TO [CetUsr]
GO
GRANT SELECT ON [msdb].[dbo].[sysjobs] TO [BeyondWallsUsr]
GO
GRANT SELECT ON [msdb].[dbo].[sysjobactivity] TO [CetUsr]
GO
GRANT SELECT ON [msdb].[dbo].[sysjobactivity] TO [BeyondWallsUsr]
GO

EXECUTE msdb.dbo.sysmail_configure_sp 'MaxFileSize', '50000000';
GO