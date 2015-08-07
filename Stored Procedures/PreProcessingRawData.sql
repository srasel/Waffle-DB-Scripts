/****** Object:  StoredProcedure [dbo].[PreProcessRawData]    Script Date: 7/29/2015 3:44:54 PM ******/
DROP PROCEDURE [dbo].[PreProcessRawData]
GO

/****** Object:  StoredProcedure [dbo].[PreProcessRawData]    Script Date: 7/29/2015 3:44:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Preprocessrawdata] 
AS 
  BEGIN 
      
	  SET NOCOUNT ON; 

	  EXECUTE [dbo].[PreProcessSpreedSheetData]
	  EXECUTE [dbo].[PreProcessWDIData]
	  EXECUTE [dbo].[PreProcessSubNationalData]
	  EXECUTE [dbo].[PreProcessShapeFile]
	  EXECUTE [dbo].[ProcessFinalTables]

  END 
GO


