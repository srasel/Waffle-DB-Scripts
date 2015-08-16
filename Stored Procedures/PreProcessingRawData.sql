IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreProcessRawData]') AND type in (N'P', N'PC'))
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
	  EXECUTE [dbo].[PreProcessIMFData]
	  --EXECUTE [dbo].[PreProcessSubNationalData]
	  --EXECUTE [dbo].[PreProcessShapeFile]
	  EXECUTE [dbo].[ProcessFinalTables]
	  EXECUTE [dbo].[PreProcessDevInfoData]
	  EXECUTE [dbo].[PreProcessHarvestData]
	  EXECUTE [dbo].[PreProcessNBERData]

  END 
GO


