USE [BeyondWallsPricing]
GO
/****** Object:  User [HONI\All Members-AD]    Script Date: 2/17/2017 1:24:58 PM ******/
CREATE USER [HONI\All Members-AD]
GO
ALTER ROLE [db_datareader] ADD MEMBER [HONI\All Members-AD]
GO
