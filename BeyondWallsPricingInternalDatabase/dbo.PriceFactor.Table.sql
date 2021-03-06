USE [BeyondWallsPricingInternal]
GO
/****** Object:  Table [dbo].[PriceFactor]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceFactor](
	[PriceFactorId] [int] NOT NULL,
	[PriceFactorAmount] [numeric](5, 4) NOT NULL,
 CONSTRAINT [PK_PriceFactor] PRIMARY KEY CLUSTERED 
(
	[PriceFactorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
