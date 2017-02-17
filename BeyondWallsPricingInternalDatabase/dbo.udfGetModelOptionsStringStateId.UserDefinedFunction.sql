USE [BeyondWallsPricingInternal]
GO
/****** Object:  UserDefinedFunction [dbo].[udfGetModelOptionsStringStateId]    Script Date: 2/17/2017 1:44:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udfGetModelOptionsStringStateId](@ModelOptionsStringStateDesc [varchar](128))
RETURNS [int] WITH EXECUTE AS CALLER
AS 
BEGIN
	DECLARE @Result int;

	SELECT 
		@Result = [ModelOptionsStringStateId]
	FROM
		dbo.[ModelOptionsStringState] WITH(NOLOCK)
	WHERE
		[ModelOptionsStringStateDesc] = @ModelOptionsStringStateDesc;

	RETURN @Result
END





GO
