USE [BeyondWallsPricing]
GO
/****** Object:  View [dbo].[ModelOptionsString_VW]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ModelOptionsString_VW] AS
SELECT 
	[ModelOptionsStringId]
	,[ModelOptionsStringDesc]
	,[ModelOptionsStringPrice]
	,[ModelOptionsStringDateTime]
	,[IsInEcatalog]
FROM 
	[dbo].[ModelOptionsString]


GO
GRANT SELECT ON [dbo].[ModelOptionsString_VW] TO [BeyondWallsAdmin] AS [dbo]
GO
