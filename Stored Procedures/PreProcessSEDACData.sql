IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreProcessSEDACData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PreProcessSEDACData]
GO

/****** Object:  StoredProcedure [dbo].[PreProcessSEDACData]    Script Date: 8/18/2015 6:46:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessSEDACData]
AS
BEGIN
		SET NOCOUNT ON;

		--DROP TABLE #A
		SELECT CountryCode, Region, RegionCode
			, CAST(RegionCode as VARCHAR(200)) id
			INTO #A
		FROM [dbo].[SEDAC_IMR]
		GROUP BY CountryCode, Region, RegionCode

		UPDATE G
		SET G.id = A.id
		--SELECT * 
		FROM DimGeo G LEFT JOIN #A A
		ON A.CountryCode = G.region
		AND A.Region = G.name
		WHERE A.id IS NOT NULL

		MERGE DimGeo T
		USING (
			SELECT A.id,A.Region name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #A A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'

		) S
		ON (T.id = S.id AND T.cat = 'province')
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES('geo',S.id,S.name,S.region,S.cat,S.lev);
		
		MERGE dbo.DimCountry T
		USING (
			SELECT A.id,A.Region name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #A A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = 11

		
		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 11,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM [dbo].[SEDAC_IMR]
		GROUP BY Indicator

		--DROP INDEX ix_fact ON FactFinal

		DELETE FROM FactFinal
		WHERE DataSourceID = 11

		INSERT INTO FactFinal 
					([datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					[value]) 
		SELECT 11, r.ID, LEFT(r.Period,4), i.ID, TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator
			FROM [dbo].[SEDAC_IMR] hr
			LEFT JOIN DimCountry dc
			ON hr.CountryCode = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			FROM [dbo].[SEDAC_IMR] hr
			LEFT JOIN #A f
			ON hr.RegionCode = F.RegionCode
			AND hr.CountryCode = f.CountryCode
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'province'
			AND F.id IS NOT NULL
		)r 
		LEFT JOIN (
			SELECT * FROM DimIndicators WHERE DataSourceID = 11
		) i
			ON r.Indicator = i.[Indicator Name]

		SELECT TOP 2 * FROM [dbo].[SEDAC_National_Poverty_RawData]

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 11,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM [dbo].[SEDAC_IMR]
		GROUP BY Indicator

		/* need to modify the following code block */
		SELECT CountryName,AdmLevel FROM [dbo].[SEDAC_National_Poverty_RawData]
		GROUP BY CountryName ,AdmLevel
		ORDER BY CountryName ,AdmLevel

		SELECT * FROM [dbo].[SEDAC_National_Poverty_RawData]
		WHERE CountryName = 'Bolivia'
		ORDER BY AdmLevel

		SELECT * FROM [dbo].[SEDAC_National_Poverty_RawData]
		WHERE AdmUnitId = 5240000
		--SELECT *
		--FROM (
		
		--)A LEFT JOIN DimGeo G
		--ON A.CountryCode = G.region
		--AND A.Region = G.name
		--WHERE G.id IS NULL

		--SELECT TOP 2 * FROM [dbo].[SEDAC_National_Poverty_RawData]

END

GO

EXECUTE [dbo].[PreProcessSEDACData]


