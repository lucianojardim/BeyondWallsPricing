USE [master]
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [BeyondWallsUsr]    Script Date: 2/17/2017 2:00:17 PM ******/
CREATE LOGIN [BeyondWallsUsr] WITH PASSWORD=N'BeyondWallsUsr', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

ALTER LOGIN [BeyondWallsUsr] DISABLE
GO


