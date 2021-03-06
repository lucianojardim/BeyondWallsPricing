USE [BeyondWallsPricing]
GO
/****** Object:  Table [dbo].[PriceRequestArchive]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PriceRequestArchive](
	[PriceRequestArchiveId] [uniqueidentifier] NOT NULL,
	[PriceRequestId] [uniqueidentifier] NOT NULL,
	[PriceRequestUserId] [varchar](128) NOT NULL,
	[PriceRequestDateTime] [datetime] NOT NULL,
	[PriceRequestItemId] [uniqueidentifier] NOT NULL,
	[ModelOptionsStringDesc] [varchar](100) NOT NULL,
	[PriceFactorId] [int] NOT NULL,
 CONSTRAINT [PK_PriceRequestArchive] PRIMARY KEY CLUSTERED 
(
	[PriceRequestArchiveId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[PriceRequestArchive] ADD  CONSTRAINT [DF_PriceRequestArchive_PriceRequestArchiveId]  DEFAULT (newid()) FOR [PriceRequestArchiveId]
GO
ALTER TABLE [dbo].[PriceRequestArchive] ADD  CONSTRAINT [DF_PriceRequestArchive_PriceFactorId]  DEFAULT ((0)) FOR [PriceFactorId]
GO
