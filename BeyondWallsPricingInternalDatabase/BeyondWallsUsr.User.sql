USE [BeyondWallsPricingInternal]
GO
/****** Object:  User [BeyondWallsUsr]    Script Date: 2/17/2017 1:44:34 PM ******/
CREATE USER [BeyondWallsUsr] FOR LOGIN [BeyondWallsUsr] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [BeyondWallsUsr]
GO
