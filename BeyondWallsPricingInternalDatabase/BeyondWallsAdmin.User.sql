USE [BeyondWallsPricingInternal]
GO
/****** Object:  User [BeyondWallsAdmin]    Script Date: 2/22/2017 1:41:03 PM ******/
CREATE USER [BeyondWallsAdmin] FOR LOGIN [BeyondWallsAdmin] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [BeyondWallsAdmin]
GO
