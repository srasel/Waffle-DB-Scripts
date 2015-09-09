IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreProcessDHSData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PreProcessDHSData]
GO

/****** Object:  StoredProcedure [dbo].[PreProcessDHSData]    Script Date: 9/8/2015 5:16:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessDHSData]
AS
BEGIN
		
		SET NOCOUNT ON;
		--DROP #MICS
		SELECT Stratifier 
		,Country
		,CASE Stratifier
			WHEN 'all' THEN Country
			WHEN 'area' THEN Country
			WHEN 'gregion' THEN IndPostfix
			WHEN 'meduc' THEN Country
			WHEN 'wiq' THEN Country
			WHEN 'sex' THEN Country
			ELSE Country END Region
		,CASE Stratifier
			WHEN 'sex' THEN IndPostfix
			ELSE 'Other' END Gender
		,[Year]
		,CASE Stratifier
			WHEN 'all' THEN Indicator
			WHEN 'area' THEN Indicator+'-'+IndPostfix
			WHEN 'gregion' THEN Indicator
			WHEN 'meduc' THEN Indicator+'-'+IndPostfix
			WHEN 'wiq' THEN Stratifier+'-'+IndPostfix
			WHEN 'sex' THEN Indicator
			ELSE Indicator END Indicator
		,DataValue
		--,Indicator2
		INTO #MICS
		FROM (
		SELECT DataSheetName,Country,[Year],Indicator,Stratifier,Stratifier_type, Indicator2
		,SUBSTRING(Stratifier_type, CHARINDEX(' ',Stratifier_type,1)+1, LEN(Stratifier_type)) IndPostfix
		,DataValue 
		FROM [Gapminder_RAW].[dhs].[MICS_RawData]
		WHERE Indicator2 IN ('r','')
		--AND Indicator = 'anc4'
		--AND Country = 'Bhutan'
		)A
		ORDER BY Stratifier

		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = 13

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 13,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM #MICS 
		GROUP BY Indicator

		SELECT * FROM #MICS
		WHERE Indicator = 'anc4'
		AND Country=Region

END

GO

EXECUTE [dbo].[PreProcessDHSData]


