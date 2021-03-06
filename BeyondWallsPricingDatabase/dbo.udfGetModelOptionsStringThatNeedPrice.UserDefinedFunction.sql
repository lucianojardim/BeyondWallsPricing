USE [BeyondWallsPricing]
GO
/****** Object:  UserDefinedFunction [dbo].[udfGetModelOptionsStringThatNeedPrice]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-11-15
-- Description:	Return Model+Options from Price Requests that are not on the database
-- =============================================
CREATE FUNCTION [dbo].[udfGetModelOptionsStringThatNeedPrice] 
(	
	-- Add the parameters for the function here
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT DISTINCT
		[ModelOptionsStringDesc],
		[PriceFactorId]
	FROM
		[dbo].[PriceRequestItem]
	WHERE
		[dbo].[udfGetModelOptionsStringProduct]([ModelOptionsStringDesc]) NOT IN (SELECT [dbo].[udfGetModelOptionsStringProduct]([ModelOptionsStringDesc]) FROM [dbo].[ModelOptionsString])
		--SUBSTRING([ModelOptionsStringDesc],1,LEN([ModelOptionsStringDesc])-3) NOT IN (SELECT SUBSTRING([ModelOptionsStringDesc],1,LEN([ModelOptionsStringDesc])-11) FROM [dbo].[ModelOptionsString])
)

GO
