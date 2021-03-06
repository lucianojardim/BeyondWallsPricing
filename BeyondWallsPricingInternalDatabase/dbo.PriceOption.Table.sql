USE [BeyondWallsPricingInternal]
GO
/****** Object:  Table [dbo].[PriceOption]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PriceOption](
	[PriceOptionId] [uniqueidentifier] NOT NULL,
	[PriceOptionDesc] [char](5) NOT NULL,
	[PriceOptionAmount] [numeric](18, 4) NULL,
 CONSTRAINT [PK_PriceOption] PRIMARY KEY CLUSTERED 
(
	[PriceOptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [IX_PriceOption_PriceOptionAmount]    Script Date: 2/22/2017 1:41:03 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_PriceOption_PriceOptionAmount] ON [dbo].[PriceOption]
(
	[PriceOptionAmount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_PriceOption_PriceOptionDesc]    Script Date: 2/22/2017 1:41:03 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_PriceOption_PriceOptionDesc] ON [dbo].[PriceOption]
(
	[PriceOptionDesc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PriceOption] ADD  CONSTRAINT [DF_PriceOption_PriceOptionId]  DEFAULT (newid()) FOR [PriceOptionId]
GO
