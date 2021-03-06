USE [BeyondWallsPricingInternal]
GO
/****** Object:  Table [dbo].[ModelOptionsStringState]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ModelOptionsStringState](
	[ModelOptionsStringStateId] [int] IDENTITY(1,1) NOT NULL,
	[ModelOptionsStringStateDesc] [varchar](128) NOT NULL,
 CONSTRAINT [PK_ModelOptionsStringState] PRIMARY KEY CLUSTERED 
(
	[ModelOptionsStringStateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
