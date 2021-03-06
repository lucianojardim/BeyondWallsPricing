USE [BeyondWallsPricingInternal]
GO
/****** Object:  UserDefinedFunction [dbo].[udfGetNextPriceOptionDesc]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[udfGetNextPriceOptionDesc](@ModelOptionsStringPrice [numeric](18,4))
RETURNS [char](5) WITH EXECUTE AS CALLER
AS 
BEGIN
	DECLARE @Result [char](5) = NULL;

	IF (@ModelOptionsStringPrice IS NOT NULL) AND NOT EXISTS(SELECT 'x' FROM [dbo].[PriceOption] WHERE PriceOptionAmount = @ModelOptionsStringPrice)
		SELECT 
			@Result = RIGHT('00000'+CAST((CAST(COALESCE(MAX([PriceOptionDesc]),0) AS INT)+1) AS VARCHAR(5)),5) -- Get next number and pad it with zeros to the right converting to char
		FROM
			[dbo].[PriceOption]

	RETURN @Result
END






GO
