USE [BeyondWallsPricing]
GO
/****** Object:  UserDefinedFunction [dbo].[udfGetPriceRequestStatus]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-11-15
-- Description:	Return Status of Price Requests made by a user
-- =============================================
CREATE FUNCTION [dbo].[udfGetPriceRequestStatus] 
(	
	-- Add the parameters for the function here
	@PriceRequestUserId varchar(128) = NULL
)
RETURNS TABLE 
AS
RETURN 
(	
	-- Add the SELECT statement with parameter references here
	SELECT 
		req.[PriceRequestId] AS [PriceRequestId],
		req.[PriceRequestDateTime] AS [PriceRequestDateTime],
		'Requested' AS [PriceRequestStatus]
	FROM 
		[dbo].[PriceRequest] AS req
	WHERE
		req.[PriceRequestUserId] = CASE WHEN @PriceRequestUserId IS NOT NULL THEN @PriceRequestUserId ELSE req.[PriceRequestUserId] END 
		AND [PriceRequestDateTime] > (SELECT TOP 1 DATEADD(minute,(CAST([ConfigurationValue] AS INT)*-1),GETDATE()) FROM [dbo].[Configuration] WHERE [ConfigurationKey] = 'MaxNumMinutesToProcessPriceRequest')
	UNION
	SELECT 
		req.[PriceRequestId] AS [PriceRequestId],
		req.[PriceRequestDateTime] AS [PriceRequestDateTime],
		'TimedOut' AS [PriceRequestStatus]
	FROM 
		[dbo].[PriceRequest] AS req
	WHERE
		req.[PriceRequestUserId] = CASE WHEN @PriceRequestUserId IS NOT NULL THEN @PriceRequestUserId ELSE req.[PriceRequestUserId] END 
		AND [PriceRequestDateTime] <= (SELECT TOP 1 DATEADD(minute,(CAST([ConfigurationValue] AS INT)*-1),GETDATE()) FROM [dbo].[Configuration] WHERE [ConfigurationKey] = 'MaxNumMinutesToProcessPriceRequest')
	UNION
	SELECT 
		res.[PriceRequestId] AS [PriceRequestId],
		res.[PriceResultDateTime] AS [PriceRequestDateTime],
		'Available' AS [PriceRequestStatus]
	FROM 
		[dbo].[PriceResult] AS res
	WHERE
		res.[PriceRequestUserId] = CASE WHEN @PriceRequestUserId IS NOT NULL THEN @PriceRequestUserId ELSE res.[PriceRequestUserId] END
)




GO
GRANT SELECT ON [dbo].[udfGetPriceRequestStatus] TO [CetUsr] AS [dbo]
GO
