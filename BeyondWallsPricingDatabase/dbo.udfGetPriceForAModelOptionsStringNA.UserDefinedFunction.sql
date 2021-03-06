USE [BeyondWallsPricing]
GO
/****** Object:  UserDefinedFunction [dbo].[udfGetPriceForAModelOptionsStringNA]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udfGetPriceForAModelOptionsStringNA]
(
	-- Add the parameters for the function here
	@ModelOptionsStringDesc [varchar](100)
)
RETURNS TABLE 
AS RETURN
(
	SELECT TOP 1
		ModelOptionsStringDesc, ModelOptionsStringPrice
	FROM
		[dbo].[ModelOptionsString]
	WHERE 
		ModelOptionsStringDesc LIKE (([dbo].[udfGetModelOptionsStringProduct](@ModelOptionsStringDesc))+ '._____')
)


GO
GRANT SELECT ON [dbo].[udfGetPriceForAModelOptionsStringNA] TO [CetUsr] AS [dbo]
GO
