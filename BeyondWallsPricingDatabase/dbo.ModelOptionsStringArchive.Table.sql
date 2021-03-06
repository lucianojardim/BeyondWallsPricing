USE [BeyondWallsPricing]
GO
/****** Object:  Table [dbo].[ModelOptionsStringArchive]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ModelOptionsStringArchive](
	[ModelOptionsStringArchiveId] [uniqueidentifier] NOT NULL,
	[ModelOptionsStringArchiveDateTime] [datetime] NOT NULL,
	[ModelOptionsStringSqlStatement] [varchar](10) NOT NULL,
	[ModelOptionsStringId] [uniqueidentifier] NOT NULL,
	[ModelOptionsStringDesc] [varchar](100) NOT NULL,
	[ModelOptionsStringPrice] [numeric](18, 4) NULL,
	[ModelOptionsStringDateTime] [datetime] NOT NULL,
	[IsInEcatalog] [bit] NOT NULL,
 CONSTRAINT [PK_ModelOptionsStringArchive] PRIMARY KEY CLUSTERED 
(
	[ModelOptionsStringArchiveId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[ModelOptionsStringArchive] ADD  CONSTRAINT [DF_ModelOptionsString_ModelOptionsStringArchiveId]  DEFAULT (newid()) FOR [ModelOptionsStringArchiveId]
GO
ALTER TABLE [dbo].[ModelOptionsStringArchive] ADD  CONSTRAINT [DF_ModelOptionsString_ModelOptionsStringArchiveDateTime]  DEFAULT (getdate()) FOR [ModelOptionsStringArchiveDateTime]
GO
ALTER TABLE [dbo].[ModelOptionsStringArchive] ADD  CONSTRAINT [DF_ModelOptionsStringArchive_IsInEcatalog]  DEFAULT ((0)) FOR [IsInEcatalog]
GO
