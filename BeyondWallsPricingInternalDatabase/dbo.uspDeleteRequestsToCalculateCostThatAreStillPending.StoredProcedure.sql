USE [BeyondWallsPricingInternal]
GO
/****** Object:  StoredProcedure [dbo].[uspDeleteRequestsToCalculateCostThatAreStillPending]    Script Date: 2/22/2017 1:41:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Luciano Jardim
-- Create date: 2016-11-17
-- Description:	Delete all requests to calculate cost that are still pending
-- =============================================
CREATE PROCEDURE [dbo].[uspDeleteRequestsToCalculateCostThatAreStillPending]
	-- Add the parameters for the stored procedure here
	@ModelOptionsStringDesc [VARCHAR](100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ProgramName VARCHAR(128) = OBJECT_NAME(@@PROCID);
	DECLARE @ErrorSaved INT;

	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Started execution'

	SELECT 
		* 
	FROM 
		[dbo].[ModelOptionsString_VW] 
	WHERE 
		[ModelOptionsStringStateDesc] IN ('NeedCost','Waiting for cost from BMIBATCH')
		AND [ModelOptionsStringDesc] = (CASE WHEN @ModelOptionsStringDesc IS NOT NULL THEN @ModelOptionsStringDesc ELSE [ModelOptionsStringDesc] END);
	
	DELETE FROM [dbo].[ModelOptionsString] 
	WHERE 
		([ModelOptionsStringStateId] = [dbo].[udfGetModelOptionsStringStateId]('NeedCost')
		OR [ModelOptionsStringStateId] = [dbo].[udfGetModelOptionsStringStateId]('Waiting for cost from BMIBATCH'))
		AND [ModelOptionsStringDesc] = (CASE WHEN @ModelOptionsStringDesc IS NOT NULL THEN @ModelOptionsStringDesc ELSE [ModelOptionsStringDesc] END)
		;

	PRINT CONVERT(VARCHAR(30),GETDATE(),120)+' '+@ProgramName+' Finished execution'
END


GO
