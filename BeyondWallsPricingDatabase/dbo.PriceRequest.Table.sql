USE [BeyondWallsPricing]
GO
/****** Object:  Table [dbo].[PriceRequest]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PriceRequest](
	[PriceRequestId] [uniqueidentifier] NOT NULL,
	[PriceRequestUserId] [varchar](128) NOT NULL,
	[PriceRequestDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_PriceRequest] PRIMARY KEY CLUSTERED 
(
	[PriceRequestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_PriceRequest_PriceRequestUserId]    Script Date: 2/22/2017 1:40:01 PM ******/
CREATE NONCLUSTERED INDEX [IX_PriceRequest_PriceRequestUserId] ON [dbo].[PriceRequest]
(
	[PriceRequestUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PriceRequest] ADD  CONSTRAINT [DF_PriceRequest_PriceRequestId]  DEFAULT (newid()) FOR [PriceRequestId]
GO
ALTER TABLE [dbo].[PriceRequest] ADD  CONSTRAINT [DF_PriceRequest_PriceRequestDateTime]  DEFAULT (getdate()) FOR [PriceRequestDateTime]
GO
