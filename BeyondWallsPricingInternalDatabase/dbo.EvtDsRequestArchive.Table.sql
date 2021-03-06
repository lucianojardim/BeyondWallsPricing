USE [BeyondWallsPricingInternal]
GO
/****** Object:  Table [dbo].[EvtDsRequestArchive]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EvtDsRequestArchive](
	[EvtDsRequestArchiveId] [uniqueidentifier] NOT NULL,
	[EvtDsRequestArchiveDateTime] [datetime] NOT NULL,
	[CD_COMPANY_EVT] [numeric](4, 0) NOT NULL,
	[CD_EVT_RSN_EVT] [char](6) NOT NULL,
	[CD_EVT_TRAN_EVT] [char](8) NOT NULL,
	[TM_EVT_CRTD_EVT] [char](6) NOT NULL,
	[DT_EVT_CRTD_EVT] [numeric](5, 0) NOT NULL,
	[CD_INFO_REQ_EVT] [numeric](3, 0) NOT NULL,
	[NUM_SEQ_EVT] [numeric](12, 0) NOT NULL,
	[SDN_EVT_CRTD_EVT] [numeric](5, 0) NOT NULL,
	[KEY_ALPHA_EVT] [char](35) NOT NULL,
	[CD_USER_CRTD_EVT] [char](13) NOT NULL,
	[INF_EVENT_EVT] [varchar](1000) NOT NULL,
	[EVT_DS_DUP] [numeric](10, 0) NOT NULL,
	[DT_DB_UPDT_EVT_DS] [smalldatetime] NOT NULL,
 CONSTRAINT [PK_EvtDsRequestArchive] PRIMARY KEY CLUSTERED 
(
	[EvtDsRequestArchiveId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[EvtDsRequestArchive] ADD  CONSTRAINT [DF_EvtDsRequestArchive_EVT_DS_ID]  DEFAULT (newid()) FOR [EvtDsRequestArchiveId]
GO
ALTER TABLE [dbo].[EvtDsRequestArchive] ADD  CONSTRAINT [DF_EvtDsRequestArchive_EvtDsArchieveDateTime]  DEFAULT (getdate()) FOR [EvtDsRequestArchiveDateTime]
GO
ALTER TABLE [dbo].[EvtDsRequestArchive] ADD  CONSTRAINT [DF_EvtDsRequestArchive_CD_COMPANY_EVT]  DEFAULT ((200)) FOR [CD_COMPANY_EVT]
GO
ALTER TABLE [dbo].[EvtDsRequestArchive] ADD  CONSTRAINT [DF_EvtDsRequestArchive_CD_EVT_RSN_EVT]  DEFAULT ('M531') FOR [CD_EVT_RSN_EVT]
GO
ALTER TABLE [dbo].[EvtDsRequestArchive] ADD  CONSTRAINT [DF_EvtDsRequestArchive_CD_EVT_TRAN_EVT]  DEFAULT ('M531') FOR [CD_EVT_TRAN_EVT]
GO
ALTER TABLE [dbo].[EvtDsRequestArchive] ADD  CONSTRAINT [DF_EvtDsRequestArchive_TM_EVT_CRTD_EVT]  DEFAULT (space((6))) FOR [TM_EVT_CRTD_EVT]
GO
ALTER TABLE [dbo].[EvtDsRequestArchive] ADD  CONSTRAINT [DF_EvtDsRequestArchive_DT_EVT_CRTD_EVT]  DEFAULT ((0)) FOR [DT_EVT_CRTD_EVT]
GO
ALTER TABLE [dbo].[EvtDsRequestArchive] ADD  CONSTRAINT [DF_EvtDsRequestArchive_CD_INFO_REQ_EVT]  DEFAULT ((0)) FOR [CD_INFO_REQ_EVT]
GO
ALTER TABLE [dbo].[EvtDsRequestArchive] ADD  CONSTRAINT [DF_EvtDsRequestArchive_NUM_SEQ_EVT]  DEFAULT ((0)) FOR [NUM_SEQ_EVT]
GO
ALTER TABLE [dbo].[EvtDsRequestArchive] ADD  CONSTRAINT [DF_EvtDsRequestArchive_SDN_EVT_CRTD_EVT]  DEFAULT ((0)) FOR [SDN_EVT_CRTD_EVT]
GO
ALTER TABLE [dbo].[EvtDsRequestArchive] ADD  CONSTRAINT [DF_EvtDsRequestArchive_KEY_ALPHA_EVT]  DEFAULT (space((35))) FOR [KEY_ALPHA_EVT]
GO
ALTER TABLE [dbo].[EvtDsRequestArchive] ADD  CONSTRAINT [DF_EvtDsRequestArchive_CD_USER_CRTD_EVT]  DEFAULT ('BeyondWalls') FOR [CD_USER_CRTD_EVT]
GO
ALTER TABLE [dbo].[EvtDsRequestArchive] ADD  CONSTRAINT [DF_EvtDsRequestArchive_INF_EVENT_EVT]  DEFAULT ('') FOR [INF_EVENT_EVT]
GO
ALTER TABLE [dbo].[EvtDsRequestArchive] ADD  CONSTRAINT [DF_EvtDsRequestArchive_EVT_DS_DUP]  DEFAULT ((0)) FOR [EVT_DS_DUP]
GO
ALTER TABLE [dbo].[EvtDsRequestArchive] ADD  CONSTRAINT [DF_EvtDsRequestArchive_DT_DB_UPDT_EVT_DS]  DEFAULT (getdate()) FOR [DT_DB_UPDT_EVT_DS]
GO
