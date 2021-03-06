USE [BeyondWallsPricing]
GO
/****** Object:  Table [dbo].[ModelOptionsString]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ModelOptionsString](
	[ModelOptionsStringId] [uniqueidentifier] NOT NULL,
	[ModelOptionsStringDesc] [varchar](100) NOT NULL,
	[ModelOptionsStringPrice] [numeric](18, 4) NULL,
	[ModelOptionsStringDateTime] [datetime] NOT NULL,
	[IsInEcatalog] [bit] NOT NULL,
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
/****** Object:  Index [IX_ModelOptionsString_ModelOptionsStringDesc]    Script Date: 2/22/2017 1:40:01 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ModelOptionsString_ModelOptionsStringDesc] ON [dbo].[ModelOptionsString]
(
	[ModelOptionsStringDesc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModelOptionsString] ADD  CONSTRAINT [DF_ModelOptionsString_ModelOptionsStringId]  DEFAULT (newid()) FOR [ModelOptionsStringId]
GO
ALTER TABLE [dbo].[ModelOptionsString] ADD  CONSTRAINT [DF_ModelOptionsString_ModelOptionsStringDateTime]  DEFAULT (getdate()) FOR [ModelOptionsStringDateTime]
GO
ALTER TABLE [dbo].[ModelOptionsString] ADD  CONSTRAINT [DF_ModelOptionsString_IsInEcatalog]  DEFAULT ((0)) FOR [IsInEcatalog]
GO
/****** Object:  Trigger [dbo].[ModelOptionsString_DeleteTrigger]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-12-07
-- Description:	Record price information that was deleted
-- =============================================
CREATE TRIGGER [dbo].[ModelOptionsString_DeleteTrigger] 
   ON  [dbo].[ModelOptionsString] 
   FOR DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	INSERT INTO [dbo].[ModelOptionsStringArchive](
		[ModelOptionsStringSqlStatement],
		[ModelOptionsStringId],
		[ModelOptionsStringDesc],
		[ModelOptionsStringPrice],
		[ModelOptionsStringDateTime],
		[IsInEcatalog]
	)
	  SELECT 
		'DELETE' AS [ModelOptionsStringSqlStatement],
		[ModelOptionsStringId],
		[ModelOptionsStringDesc],
		[ModelOptionsStringPrice],
		[ModelOptionsStringDateTime],
		[IsInEcatalog]
	  FROM  
		deleted

END

GO
ALTER TABLE [dbo].[ModelOptionsString] ENABLE TRIGGER [ModelOptionsString_DeleteTrigger]
GO
/****** Object:  Trigger [dbo].[ModelOptionsString_InsertTrigger]    Script Date: 2/22/2017 1:40:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-12-07
-- Description:	Record new price information
-- =============================================
CREATE TRIGGER [dbo].[ModelOptionsString_InsertTrigger] 
   ON  [dbo].[ModelOptionsString] 
   FOR INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	INSERT INTO [dbo].[ModelOptionsStringArchive](
		[ModelOptionsStringSqlStatement],
		[ModelOptionsStringId],
		[ModelOptionsStringDesc],
		[ModelOptionsStringPrice],
		[ModelOptionsStringDateTime],
		[IsInEcatalog]
	)
	  SELECT 
		'INSERT' AS [ModelOptionsStringSqlStatement],
		[ModelOptionsStringId],
		[ModelOptionsStringDesc],
		[ModelOptionsStringPrice],
		[ModelOptionsStringDateTime],
		[IsInEcatalog]
	  FROM  
		inserted

END

GO
ALTER TABLE [dbo].[ModelOptionsString] ENABLE TRIGGER [ModelOptionsString_InsertTrigger]
GO
/****** Object:  Trigger [dbo].[ModelOptionsString_UpdateTrigger]    Script Date: 2/22/2017 1:40:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-12-07
-- Description:	Record price information that was updated
-- =============================================
CREATE TRIGGER [dbo].[ModelOptionsString_UpdateTrigger] 
   ON  [dbo].[ModelOptionsString] 
   FOR UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	INSERT INTO [dbo].[ModelOptionsStringArchive](
		[ModelOptionsStringSqlStatement],
		[ModelOptionsStringId],
		[ModelOptionsStringDesc],
		[ModelOptionsStringPrice],
		[ModelOptionsStringDateTime],
		[IsInEcatalog]
	)
	  SELECT 
		'UPDATE_OLD' AS [ModelOptionsStringSqlStatement],
		[ModelOptionsStringId],
		[ModelOptionsStringDesc],
		[ModelOptionsStringPrice],
		[ModelOptionsStringDateTime],
		[IsInEcatalog]
	  FROM  
		deleted;
	INSERT INTO [dbo].[ModelOptionsStringArchive](
		[ModelOptionsStringSqlStatement],
		[ModelOptionsStringId],
		[ModelOptionsStringDesc],
		[ModelOptionsStringPrice],
		[ModelOptionsStringDateTime],
		[IsInEcatalog]
	)
	  SELECT 
		'UPDATE_NEW' AS [ModelOptionsStringSqlStatement],
		[ModelOptionsStringId],
		[ModelOptionsStringDesc],
		[ModelOptionsStringPrice],
		[ModelOptionsStringDateTime],
		[IsInEcatalog]
	  FROM  
		inserted;
END

GO
ALTER TABLE [dbo].[ModelOptionsString] ENABLE TRIGGER [ModelOptionsString_UpdateTrigger]
GO
