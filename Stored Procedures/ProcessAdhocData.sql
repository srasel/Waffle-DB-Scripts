IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessAdhocData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ProcessAdhocData]
GO

/****** Object:  StoredProcedure [dbo].[ProcessAdhocData]    Script Date: 8/16/2015 6:06:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessAdhocData] 
AS
BEGIN
		SET NOCOUNT ON;

		--DROP TABLE #GINI
		SELECT 1 DataSource, 'gini' IndicatorCode
			INTO #GINI
		UNION ALL
		SELECT 1 DataSource, 'u5mr' IndicatorCode
		UNION ALL
		SELECT 1 DataSource, 'childSurv' IndicatorCode
		
		MERGE dbo.DimIndicators T
		USING (
			SELECT * FROM #GINI
		) S
		ON (T.[Indicator Code] = S.IndicatorCode)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name]) 
			VALUES(S.DataSource,S.IndicatorCode,S.IndicatorCode);

		--DROP TABLE #INDICATORS
		SELECT ID,IndicatorCode INTO #INDICATORS
		FROM DimIndicators I INNER JOIN #GINI G
		ON I.[Indicator Code] = G.IndicatorCode
		AND I.DataSourceID = G.DataSource

		DELETE FROM FactSpreedSheet
		WHERE [Indicator Code] IN (
			SELECT ID FROM #INDICATORS
		)

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'spreedsheet'
		GROUP BY DataSource

		INSERT INTO FactSpreedSheet 
					(VersionID,
					[datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					[value])

		SELECT  @versionNo, 1 ds, c.ID, TRY_CONVERT(INT, r.[time]) per, i.ID ind, TRY_CONVERT(float,gini) --into #A
		FROM dbo.NewDataGiniU5mrChildSurv r LEFT JOIN DimCountry c
		ON r.geo = c.[Country Code]
		,#INDICATORS i
		WHERE c.[Country Code] IS NOT NULL
		AND c.[Type] = 'country'
		AND I.IndicatorCode = 'gini'
		
		UNION ALL

		SELECT  @versionNo,1 ds, c.ID, TRY_CONVERT(INT, r.[time]) per, i.ID ind, TRY_CONVERT(float,u5mr)
		FROM dbo.NewDataGiniU5mrChildSurv r LEFT JOIN DimCountry c
		ON r.geo = c.[Country Code]
		,#INDICATORS i
		WHERE c.[Country Code] IS NOT NULL
		AND c.[Type] = 'country'
		AND I.IndicatorCode = 'u5mr'

		UNION ALL

		SELECT  @versionNo,1 ds, c.ID, TRY_CONVERT(INT, r.[time]) per, i.ID ind, TRY_CONVERT(float,childSurv)
		FROM dbo.NewDataGiniU5mrChildSurv r LEFT JOIN DimCountry c
		ON r.geo = c.[Country Code]
		,#INDICATORS i
		WHERE c.[Country Code] IS NOT NULL
		AND c.[Type] = 'country'
		AND I.IndicatorCode = 'childSurv'

END

GO


