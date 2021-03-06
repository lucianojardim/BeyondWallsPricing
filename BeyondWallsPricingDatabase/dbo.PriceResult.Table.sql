USE [BeyondWallsPricing]
GO
/****** Object:  Table [dbo].[PriceResult]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PriceResult](
	[PriceRequestId] [uniqueidentifier] NOT NULL,
	[PriceRequestUserId] [varchar](128) NOT NULL,
	[PriceResultDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_PriceResult] PRIMARY KEY CLUSTERED 
(
	[PriceRequestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_PriceResult_PriceRequestUserId]    Script Date: 2/22/2017 1:40:01 PM ******/
CREATE NONCLUSTERED INDEX [IX_PriceResult_PriceRequestUserId] ON [dbo].[PriceResult]
(
	[PriceRequestUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PriceResult] ADD  CONSTRAINT [DF_PriceRsult_PriceResultDateTime]  DEFAULT (getdate()) FOR [PriceResultDateTime]
GO
