USE [BeyondWallsPricingInternal]
GO
/****** Object:  Table [dbo].[CostFromBmiBatch]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CostFromBmiBatch](
	[CostFromBmiBatchId] [uniqueidentifier] NOT NULL,
	[Model] [varchar](20) NULL,
	[Model.Options] [varchar](60) NOT NULL,
	[Unit Total] [numeric](18, 4) NULL,
	[Errors?] [char](1) NOT NULL,
	[BmiBatchFullFileName] [varchar](1024) NOT NULL,
	[BmiBatchFileLastWriteTime] [datetime] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_CostFromBmiBatch] PRIMARY KEY CLUSTERED 
(
	[CostFromBmiBatchId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[CostFromBmiBatch] ADD  CONSTRAINT [DF_CostFromBmiBatch_CostFromBmiBatchId]  DEFAULT (newid()) FOR [CostFromBmiBatchId]
GO
ALTER TABLE [dbo].[CostFromBmiBatch] ADD  CONSTRAINT [DF_CostFromBmiBatch_LoadDateTime]  DEFAULT (getdate()) FOR [LoadDateTime]
GO
