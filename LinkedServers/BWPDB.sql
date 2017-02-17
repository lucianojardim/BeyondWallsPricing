USE [master]
GO

--Assumes that the Oracle client is already isntalled ande the OraOLEDB is available
exec master.dbo.sp_MSset_oledb_prop 'ORAOLEDB.Oracle', N'AllowInProcess', 1 
GO

/****** Object:  LinkedServer [BWPDB]    Script Date: 2/17/2017 1:45:45 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'BWPDB', @srvproduct=N'Oracle', @provider=N'OraOLEDB.Oracle', @datasrc=N'QADB'

GO

EXEC master.dbo.sp_serveroption @server=N'BWPDB', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'BWPDB', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'BWPDB', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'BWPDB', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'BWPDB', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'BWPDB', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'BWPDB', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'BWPDB', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'BWPDB', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'BWPDB', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'BWPDB', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'BWPDB', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'BWPDB', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO


