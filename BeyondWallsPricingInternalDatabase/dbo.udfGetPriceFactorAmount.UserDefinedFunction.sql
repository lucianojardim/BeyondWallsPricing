USE [BeyondWallsPricingInternal]
GO
/****** Object:  UserDefinedFunction [dbo].[udfGetPriceFactorAmount]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udfGetPriceFactorAmount](@PriceFactorId [int])
RETURNS [numeric](5,4) WITH EXECUTE AS CALLER
AS 
BEGIN
	DECLARE @Result [numeric](5,4);

	SELECT 
		@Result = [PriceFactorAmount]
	FROM
		[dbo].[PriceFactor] WITH(NOLOCK)
	WHERE
		[PriceFactorId] = @PriceFactorId;

	RETURN @Result
END





GO
