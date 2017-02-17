USE [master]
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [CetUsr]    Script Date: 2/17/2017 2:00:17 PM ******/
CREATE LOGIN [CetUsr] WITH PASSWORD=N'CetUsr', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

ALTER LOGIN [CetUsr] DISABLE
GO


