USE [BeyondWallsPricing]
GO
/****** Object:  Table [dbo].[PriceResultItem]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PriceResultItem](
	[PriceRequestItemId] [uniqueidentifier] NOT NULL,
	[ModelOptionsStringDesc] [varchar](100) NOT NULL,
	[PriceRequestId] [uniqueidentifier] NOT NULL,
	[ModelOptionsStringPrice] [numeric](18, 4) NULL,
 CONSTRAINT [PK_PriceResultItem] PRIMARY KEY CLUSTERED 
(
	[PriceRequestItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_PriceResultItem_ModelOptionsStringDesc]    Script Date: 2/22/2017 1:40:01 PM ******/
CREATE NONCLUSTERED INDEX [IX_PriceResultItem_ModelOptionsStringDesc] ON [dbo].[PriceResultItem]
(
	[ModelOptionsStringDesc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PriceResultsItem_PriceRequestId]    Script Date: 2/22/2017 1:40:01 PM ******/
CREATE NONCLUSTERED INDEX [IX_PriceResultsItem_PriceRequestId] ON [dbo].[PriceResultItem]
(
	[PriceRequestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PriceResultItem]  WITH CHECK ADD  CONSTRAINT [FK_PriceResultItem_PriceResult] FOREIGN KEY([PriceRequestId])
REFERENCES [dbo].[PriceResult] ([PriceRequestId])
GO
ALTER TABLE [dbo].[PriceResultItem] CHECK CONSTRAINT [FK_PriceResultItem_PriceResult]
GO
