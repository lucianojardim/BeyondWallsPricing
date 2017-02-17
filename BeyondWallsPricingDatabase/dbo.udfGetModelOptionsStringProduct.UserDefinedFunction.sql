USE [BeyondWallsPricing]
GO
/****** Object:  UserDefinedFunction [dbo].[udfGetModelOptionsStringProduct]    Script Date: 2/17/2017 1:24:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[udfGetModelOptionsStringProduct](@ModelOptionsStringDesc [varchar](100))
RETURNS [varchar](100) WITH EXECUTE AS CALLER
AS 
BEGIN
	DECLARE @Result [varchar](128);
	DECLARE @positionLastChar INT = LEN(@ModelOptionsStringDesc)-CHARINDEX('.',REVERSE(@ModelOptionsStringDesc));
	
	SELECT @Result = SUBSTRING(@ModelOptionsStringDesc,1,@positionLastChar);

	RETURN @Result;
END





GO
