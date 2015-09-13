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
CREATE PROCEDURE [dbo].[PreProcessRawData] 
AS 
  BEGIN 
      
		SET NOCOUNT ON;
		/*
		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) RNK
			FROM DimGeo
		)
		DELETE FROM CTE WHERE RNK > 1
		*/
		EXECUTE [dbo].[IndexAndConstraint] 'DROP'

		EXECUTE [dbo].[PreProcessSpreedSheetData]
		EXECUTE [dbo].[PreProcessWDIData]
		EXECUTE [dbo].[PreProcessIMFData]
		--EXECUTE [dbo].[PreProcessSubNationalData]
		--EXECUTE [dbo].[PreProcessShapeFile]
		EXECUTE [dbo].[ProcessFinalTables]
		EXECUTE [dbo].[PreProcessDevInfoData]
		EXECUTE [dbo].[PreProcessHarvestData]
		EXECUTE [dbo].[PreProcessNBERData]
		EXECUTE [dbo].[PreProcessOPHIData]
		EXECUTE [dbo].[PreProcessSEDACData]
		EXECUTE [dbo].[ProcessAdhocData]
		--EXECUTE [dbo].[PreProcessMortalityData] 
		--EXECUTE [dbo].[PreProcessDHSData]

		EXECUTE [dbo].[IndexAndConstraint] 'CREATE'

		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		/*
			
			update i 
			set i.[Indicator Name] = case [Indicator Name]
				when 'cMx_1x1' then 'Death rates (cohort 1x1)'
				when 'cExposures_1x1' then 'Exposure to risk (cohort 1x1)'
				when 'Deaths_1x1' then  'Deaths (1x1)'
				when 'Mx_1x1' then 'Death rates (period 1x1)' 
				else [Indicator Name]
				end
					 
			from dimindicators i
			where datasourceid  = 12

		*/

		UPDATE A
		SET A.Lev = H.GeoLevelNo
		FROM UtilityAvailableDataLevel A INNER JOIN GeoHierarchyLevel H
		ON A.Category = H.GeoLevelName


  END 
GO


