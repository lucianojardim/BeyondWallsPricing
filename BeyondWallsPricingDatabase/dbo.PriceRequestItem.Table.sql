USE [BeyondWallsPricing]
GO
/****** Object:  Table [dbo].[PriceRequestItem]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PriceRequestItem](
	[PriceRequestItemId] [uniqueidentifier] NOT NULL,
	[ModelOptionsStringDesc] [varchar](100) NOT NULL,
	[PriceFactorId] [int] NOT NULL,
	[PriceRequestId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_PriceRequestItem] PRIMARY KEY CLUSTERED 
(
	[PriceRequestItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_PriceRequestItem_ModelOptionsStringDesc]    Script Date: 2/22/2017 1:40:01 PM ******/
CREATE NONCLUSTERED INDEX [IX_PriceRequestItem_ModelOptionsStringDesc] ON [dbo].[PriceRequestItem]
(
	[ModelOptionsStringDesc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PriceRequestItem_PriceRequestId]    Script Date: 2/22/2017 1:40:01 PM ******/
CREATE NONCLUSTERED INDEX [IX_PriceRequestItem_PriceRequestId] ON [dbo].[PriceRequestItem]
(
	[PriceRequestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PriceRequestItem]  WITH CHECK ADD  CONSTRAINT [FK_PriceRequestItem_PriceFactor] FOREIGN KEY([PriceFactorId])
REFERENCES [dbo].[PriceFactor] ([PriceFactorId])
GO
ALTER TABLE [dbo].[PriceRequestItem] CHECK CONSTRAINT [FK_PriceRequestItem_PriceFactor]
GO
ALTER TABLE [dbo].[PriceRequestItem]  WITH CHECK ADD  CONSTRAINT [FK_PriceRequestItem_PriceRequest] FOREIGN KEY([PriceRequestId])
REFERENCES [dbo].[PriceRequest] ([PriceRequestId])
GO
ALTER TABLE [dbo].[PriceRequestItem] CHECK CONSTRAINT [FK_PriceRequestItem_PriceRequest]
GO
