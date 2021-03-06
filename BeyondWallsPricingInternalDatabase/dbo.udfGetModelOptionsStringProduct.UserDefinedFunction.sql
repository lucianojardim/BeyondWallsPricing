USE [BeyondWallsPricingInternal]
GO
/****** Object:  UserDefinedFunction [dbo].[udfGetModelOptionsStringProduct]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[udfGetModelOptionsStringProduct](@ModelOptionsStringStateDesc [varchar](128))
RETURNS [varchar](128) WITH EXECUTE AS CALLER
AS 
BEGIN
	DECLARE @Result [varchar](128);
	DECLARE @positionLastChar INT = LEN(@ModelOptionsStringStateDesc)-CHARINDEX('.',REVERSE(@ModelOptionsStringStateDesc));
	
	SELECT @Result = SUBSTRING(@ModelOptionsStringStateDesc,1,@positionLastChar);

	RETURN @Result;
END





GO
