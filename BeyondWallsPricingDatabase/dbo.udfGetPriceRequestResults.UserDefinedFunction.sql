USE [BeyondWallsPricing]
GO
/****** Object:  UserDefinedFunction [dbo].[udfGetPriceRequestResults]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-11-15
-- Description:	Return Price Results for a given PriiceRequestId
-- =============================================
CREATE FUNCTION [dbo].[udfGetPriceRequestResults] 
(	
	-- Add the parameters for the function here
	@PriceRequestId uniqueidentifier = NULL
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT 
		COALESCE(mo.[ModelOptionsStringDesc],req.[ModelOptionsStringDesc]) AS [ModelOptionsStringDesc],
		mo.[ModelOptionsStringPrice]
	FROM 
		[dbo].[PriceRequestItem] AS req
	LEFT OUTER JOIN
		[dbo].[ModelOptionsString] AS mo
		ON [dbo].[udfGetModelOptionsStringProduct](mo.[ModelOptionsStringDesc]) = [dbo].[udfGetModelOptionsStringProduct](req.[ModelOptionsStringDesc])
	WHERE
		req.[PriceRequestId] = CASE WHEN @PriceRequestId IS NOT NULL THEN @PriceRequestId ELSE req.[PriceRequestId] END
	UNION
	SELECT 
		res.[ModelOptionsStringDesc],
		res.[ModelOptionsStringPrice]
	FROM 
		[dbo].[PriceResultItem] AS res
	WHERE
		res.[PriceRequestId] = CASE WHEN @PriceRequestId IS NOT NULL THEN @PriceRequestId ELSE res.[PriceRequestId] END
)



GO
GRANT SELECT ON [dbo].[udfGetPriceRequestResults] TO [BeyondWallsAdmin] AS [dbo]
GO
GRANT SELECT ON [dbo].[udfGetPriceRequestResults] TO [CetUsr] AS [dbo]
GO
