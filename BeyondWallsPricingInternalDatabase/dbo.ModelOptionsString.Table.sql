USE [BeyondWallsPricingInternal]
GO
/****** Object:  Table [dbo].[ModelOptionsString]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ModelOptionsString](
	[ModelOptionsStringId] [uniqueidentifier] NOT NULL,
	[ModelOptionsStringDesc] [varchar](100) NOT NULL,
	[PriceFactorId] [int] NOT NULL,
	[ModelOptionsStringCost] [numeric](18, 4) NULL,
	[ModelOptionsStringDateTime] [datetime] NOT NULL,
	[ModelOptionsStringStateId] [int] NOT NULL,
 CONSTRAINT [PK_ModelOptionsString] PRIMARY KEY CLUSTERED 
(
	[ModelOptionsStringId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ModelOptonsString_ModelOptonsStringDesc]    Script Date: 2/22/2017 1:41:03 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ModelOptonsString_ModelOptonsStringDesc] ON [dbo].[ModelOptionsString]
(
	[ModelOptionsStringDesc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModelOptionsString] ADD  CONSTRAINT [DF_ModelOptionsString_ModelOptionsStringId]  DEFAULT (newid()) FOR [ModelOptionsStringId]
GO
ALTER TABLE [dbo].[ModelOptionsString] ADD  CONSTRAINT [DF_ModelOptionsString_IsSolid]  DEFAULT ((0)) FOR [PriceFactorId]
GO
ALTER TABLE [dbo].[ModelOptionsString] ADD  CONSTRAINT [DF_ModelOptionsString_ModelOptionsStringDateTime]  DEFAULT (getdate()) FOR [ModelOptionsStringDateTime]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 (nonsolid) is the default because currently it means a higher margin then 1 (solid)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ModelOptionsString', @level2type=N'COLUMN',@level2name=N'PriceFactorId'
GO
