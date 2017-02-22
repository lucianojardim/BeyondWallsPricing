USE [BeyondWallsPricing]
GO
/****** Object:  UserDefinedTableType [dbo].[PriceRequestItemTableType]    Script Date: 2/22/2017 1:40:01 PM ******/
CREATE TYPE [dbo].[PriceRequestItemTableType] AS TABLE(
	[ModelOptionsStringDesc] [varchar](100) NOT NULL,
	[PriceFactorId] [int] NOT NULL
)
GO
GRANT EXECUTE ON TYPE::[dbo].[PriceRequestItemTableType] TO [CetUsr] AS [dbo]
GO
