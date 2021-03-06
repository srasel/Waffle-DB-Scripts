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

		--DROP TABLE #IMR
		SELECT CountryCode, Region, RegionCode
			, CAST(RegionCode as VARCHAR(200)) id
			INTO #IMR
		FROM [dbo].[SEDAC_IMR]
		GROUP BY CountryCode, Region, RegionCode
		--select * from #IMR
		
		UPDATE G
		SET G.id =	LOWER(A.id)
		--SELECT *, ROW_NUMBER() OVER PARTITION BY A.
		FROM DimGeo G INNER JOIN #IMR A
		ON A.CountryCode = G.region
		AND A.Region = G.name

		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) RNK
			FROM DimGeo
		)
		DELETE FROM CTE WHERE RNK > 1

		MERGE DimGeo T
		USING (
			SELECT A.id,A.Region name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #IMR A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'
			AND LEN(A.ID)>3

		) S
		ON (T.id = S.id AND T.cat = 'province' AND T.region = S.region)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES('geo',S.id,S.name,S.region,S.cat,S.lev);

		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) RNK
			FROM DimGeo
		)
		DELETE FROM CTE WHERE RNK > 1
		
		MERGE dbo.DimCountry T
		USING (
			SELECT A.id,A.Region name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #IMR A, [dbo].[GeoHierarchyLevel] G
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
			UNION
		SELECT 11,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM [dbo].[SEDAC_National_Poverty_RawData]
		WHERE Indicator<>''
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
			LEFT JOIN #IMR f
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

		--SELECT TOP 2 * FROM [dbo].[SEDAC_National_Poverty_RawData]
		--DROP TABLE #POV
		SELECT CountryCode,CountryName,Region, 'province' cat
		,CAST(NULL AS VARCHAR(100)) id
		INTO #POV
		FROM (
			SELECT CountryCode,CountryName,Region, AdmLevel, DENSE_RANK() OVER(PARTITION BY CountryCode,CountryName ORDER BY AdmLevel) rnk 
			FROM [dbo].[SEDAC_National_Poverty_RawData]
			WHERE ISNUMERIC(Region) = 0
			GROUP BY CountryCode,CountryName, Region, AdmLevel

		)A WHERE rnk = 1
		ORDER BY CountryName

		UPDATE B
		SET B.ID = IIF(G.id IS NULL, LOWER(B.CountryCode+'-'+REPLACE(B.Region,' ','-')) ,G.id)
		FROM #POV B LEFT JOIN (SELECT * FROM DimGeo WHERE cat = 'province') G
		ON B.Region = G.name
		AND B.CountryCode = G.region

		MERGE DimGeo T
		USING (
			SELECT A.id,A.Region name,LOWER(CountryCode) region, 'province' cat,G.[GeoLevelNo] lev
			FROM #POV A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'

		) S
		ON (T.id = S.id AND T.cat = 'province' AND T.region = S.region)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES('geo',S.id,S.name,S.region,S.cat,S.lev);

		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) RNK
			FROM DimGeo
		)
		DELETE FROM CTE WHERE RNK > 1
		
		MERGE dbo.DimCountry T
		USING (
			SELECT A.id,A.Region name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #POV A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY [Country Code] ORDER BY [Country Code]) RNK
			FROM DimCountry
		)
		DELETE FROM CTE WHERE RNK > 1

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
			FROM [dbo].[SEDAC_National_Poverty_RawData] hr
			LEFT JOIN DimCountry dc
			ON hr.CountryCode = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			FROM [dbo].[SEDAC_National_Poverty_RawData] hr
			LEFT JOIN #POV f
			ON hr.Region = F.Region
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


END

GO

--EXECUTE [dbo].[PreProcessSEDACData]


