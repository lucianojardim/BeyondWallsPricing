USE [BeyondWallsPricing]
GO
/****** Object:  User [HONI\All Members-AD]    Script Date: 2/22/2017 1:40:01 PM ******/
CREATE USER [HONI\All Members-AD]
GO
ALTER ROLE [db_datareader] ADD MEMBER [HONI\All Members-AD]
GO
