USE [BeyondWallsPricing]
GO
/****** Object:  UserDefinedTableType [dbo].[PriceRequestItemTableType]    Script Date: 2/17/2017 1:24:59 PM ******/
CREATE TYPE [dbo].[PriceRequestItemTableType] AS TABLE(
	[ModelOptionsStringDesc] [varchar](100) NOT NULL,
	[PriceFactorId] [int] NOT NULL
)
GO
GRANT EXECUTE ON TYPE::[dbo].[PriceRequestItemTableType] TO [CetUsr] AS [dbo]
GO
