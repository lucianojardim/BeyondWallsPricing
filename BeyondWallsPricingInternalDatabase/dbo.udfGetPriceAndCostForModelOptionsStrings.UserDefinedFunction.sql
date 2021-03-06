USE [BeyondWallsPricingInternal]
GO
/****** Object:  UserDefinedFunction [dbo].[udfGetPriceAndCostForModelOptionsStrings]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[udfGetPriceAndCostForModelOptionsStrings]
(
	-- Add the parameters for the function here
	@ModelOptionsStringDesc [varchar](100) = NULL
)
RETURNS TABLE 
AS RETURN
(
	SELECT
		[price].[ModelOptionsStringDesc], 
		[cost].[ModelOptionsStringCost],
		CAST([price].[ModelOptionsStringPrice] AS INT) AS [ModelOptionsStringPrice]
	FROM
		[dbo].[ModelOptionsString_VW] AS [cost]
	FULL OUTER JOIN
		[BeyondWallsPricing].[dbo].[ModelOptionsString_VW] AS [price]
		ON 
			([BeyondWallsPricing].[dbo].[udfGetModelOptionsStringProduct]([price].[ModelOptionsStringDesc])) = ([dbo].[udfGetModelOptionsStringProduct]([cost].[ModelOptionsStringDesc]))
	WHERE 
		[cost].[ModelOptionsStringDesc] LIKE (CASE WHEN @ModelOptionsStringDesc IS NULL THEN [cost].[ModelOptionsStringDesc] ELSE [dbo].[udfGetModelOptionsStringProduct](@ModelOptionsStringDesc)+ '._____' END)
)


GO
GRANT SELECT ON [dbo].[udfGetPriceAndCostForModelOptionsStrings] TO [BeyondWallsAdmin] AS [dbo]
GO
