USE [BeyondWallsPricing]
GO
/****** Object:  UserDefinedFunction [dbo].[udfGetPriceRequestStatusForAPriceRequestId]    Script Date: 2/22/2017 1:40:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-11-29
-- Description:	Returns the status of a Price Request based on its uniqueidentifier
-- =============================================
CREATE FUNCTION [dbo].[udfGetPriceRequestStatusForAPriceRequestId]
(
	-- Add the parameters for the function here
	@PriceRequestId uniqueidentifier
)
RETURNS varchar(20)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(20)
	DECLARE @MaxNumMinutesToProcessPriceRequest INT = (SELECT (CAST([ConfigurationValue] AS INT)*-1) FROM [dbo].[Configuration] WHERE [ConfigurationKey] = 'MaxNumMinutesToProcessPriceRequest')
	DECLARE @NotificationDateTime DATETIME = DATEADD(minute,@MaxNumMinutesToProcessPriceRequest,GETDATE())

	-- Add the T-SQL statements to compute the return value here
	IF EXISTS(SELECT 'x' FROM [dbo].[PriceRequest] AS req WHERE req.[PriceRequestId] = @PriceRequestId AND [PriceRequestDateTime] > @NotificationDateTime)
		SET @Result = 'Requested'
	ELSE
		IF EXISTS(SELECT 'x' FROM [dbo].[PriceRequest] AS req WHERE req.[PriceRequestId] = @PriceRequestId AND [PriceRequestDateTime] <= @NotificationDateTime)
			SET @Result = 'TimedOut'
		ELSE
			IF EXISTS(SELECT 'x' FROM [dbo].[PriceResult] AS res WHERE res.[PriceRequestId] = @PriceRequestId)
				SET @Result = 'Available'
			ELSE
				SET @Result = 'Not found'

	-- Return the result of the function
	RETURN @Result

END

GO
GRANT EXECUTE ON [dbo].[udfGetPriceRequestStatusForAPriceRequestId] TO [CetUsr] AS [dbo]
GO
