USE [BeyondWallsPricing]
GO
/****** Object:  User [BeyondWallsUsr]    Script Date: 2/22/2017 1:40:01 PM ******/
CREATE USER [BeyondWallsUsr] FOR LOGIN [BeyondWallsUsr] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [BeyondWallsUsr]
GO
