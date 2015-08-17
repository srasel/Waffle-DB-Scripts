IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreProcessOPHIData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PreProcessOPHIData]
GO

/****** Object:  StoredProcedure [dbo].[PreProcessOPHIData]    Script Date: 8/16/2015 1:44:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessOPHIData]
AS
BEGIN
		
		SET NOCOUNT ON;
		
		--DROP TABLE #A
		SELECT CountryCode, CountryName, SubRegionName, CAST(NULL AS VARCHAR(200)) id
			INTO #A
		FROM OPHI_Raw_Data
		GROUP BY CountryCode, CountryName, SubRegionName
		
		UPDATE A
		SET A.id  = G.id
		FROM #A A LEFT JOIN (SELECT * FROM DimGeo WHERE cat = 'province') G
			ON A.CountryCode = G.region
			AND A.SubRegionName = g.name
		WHERE G.id IS NOT NULL

		UPDATE A
		SET A.id = LOWER(A.CountryCode)+'-'+LOWER(REPLACE(A.SubRegionName,' ','-'))
		FROM #A A
		WHERE A.id IS NULL

		MERGE DimGeo T
		USING (
			SELECT A.id,SubRegionName name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #A A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'

		) S
		ON (T.id = S.id AND T.cat = 'province')
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES('geo',S.id,S.name,S.region,S.cat,S.lev);
		
		MERGE dbo.DimCountry T
		USING (
			SELECT A.id,SubRegionName name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #A A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = 9

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 9,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM [dbo].[OPHI_Raw_Data]
		GROUP BY Indicator

		DROP INDEX ix_fact ON FactFinal

		DELETE FROM FactFinal
		WHERE DataSourceID = 9

		INSERT INTO FactFinal 
					([datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					[value]) 
		SELECT 9, r.ID, LEFT(r.Period,4), i.ID, TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator
			FROM [dbo].[OPHI_Raw_Data] hr
			LEFT JOIN DimCountry dc
			ON hr.CountryCode = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			FROM [dbo].[OPHI_Raw_Data] hr
			LEFT JOIN #A f
			ON hr.SubRegionName = F.SubRegionName
			AND hr.CountryCode = f.CountryCode
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'province'
			AND F.id IS NOT NULL
		)r 
		LEFT JOIN (
			SELECT * FROM DimIndicators WHERE DataSourceID = 9
		) i
			ON r.Indicator = i.[Indicator Name]

		CREATE NONCLUSTERED INDEX ix_fact 
		ON FactFinal ([datasourceid], [country code], [period], [indicator code],[SubGroup] ) 
		INCLUDE([Value])


END

GO


