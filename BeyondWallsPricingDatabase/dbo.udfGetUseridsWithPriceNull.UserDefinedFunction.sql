USE [BeyondWallsPricing]
GO
/****** Object:  UserDefinedFunction [dbo].[udfGetUseridsWithPriceNull]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2017-02-17
-- Description:	Return Userids that received Model+Options with Price that is NULL
-- =============================================
CREATE FUNCTION [dbo].[udfGetUseridsWithPriceNull] 
(	
	-- Add the parameters for the function here
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
SELECT 
	[PriceResultDateTime]
	,[PriceRequestUserId]
	,[ModelOptionsStringDesc]
FROM 
	[dbo].[PriceResult_VW]
WHERE 
	[ModelOptionsStringPrice] IS NULL
)

GO
GRANT SELECT ON [dbo].[udfGetUseridsWithPriceNull] TO [BeyondWallsAdmin] AS [dbo]
GO
