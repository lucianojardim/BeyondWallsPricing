USE [BeyondWallsPricingInternal]
GO
/****** Object:  UserDefinedFunction [dbo].[udfGetModelOptionsStringDescToPostPrice]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[udfGetModelOptionsStringDescToPostPrice](
	@ModelOptionsStringDesc [varchar](100), 
	@ModelOptionsStringPrice [numeric](18,4)
)
RETURNS [varchar](100) WITH EXECUTE AS CALLER
AS 
BEGIN
	DECLARE @Result [varchar](100);

	IF (@ModelOptionsStringPrice IS NOT NULL)
		SELECT 
			@Result = [dbo].[udfGetModelOptionsStringProduct](@ModelOptionsStringDesc)+'.'+[PriceOptionDesc]   -- Remove .NA and add price option
		FROM
			[dbo].[PriceOption]
		WHERE 
			[PriceOptionAmount] = @ModelOptionsStringPrice;
	ELSE
		SELECT 
			@Result = [dbo].[udfGetModelOptionsStringProduct](@ModelOptionsStringDesc)+'.'+[PriceOptionDesc]   -- Remove .NA and add price option
		FROM
			[dbo].[PriceOption]
		WHERE 
			[PriceOptionAmount] IS NULL;

	RETURN @Result;
END






GO
