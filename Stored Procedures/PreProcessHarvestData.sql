IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreProcessHarvestData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PreProcessHarvestData]
GO

/****** Object:  StoredProcedure [dbo].[PreProcessHarvestData]    Script Date: 8/15/2015 6:04:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessHarvestData]
AS
BEGIN
		SET NOCOUNT ON;

		--DROP TABLE #X
		SELECT * INTO #X
		FROM (
			SELECT ADM1_NAME_ALT name 
				,ADM0_NAME parentName
				,CAST(NULL AS VARCHAR(100)) id
				,CAST(ISO3 AS VARCHAR(100)) parent
				,'province' cat 
			FROM [dbo].[HarvestChoiceRawData]
			GROUP BY ADM0_NAME,ADM1_NAME_ALT,ISO3

			UNION ALL

			SELECT ADM2_NAME_ALT,ADM1_NAME_ALT, NULL, NULL, 'territory' 
			FROM [dbo].[HarvestChoiceRawData]
			GROUP BY ADM2_NAME_ALT,ADM1_NAME_ALT
		)A

		UPDATE x
		SET x.id = g.id
		FROM #X x INNER JOIN DimGeo g
		ON x.name = g.name
		AND x.parent = g.region
		WHERE x.cat = 'province'

		UPDATE x
		SET x.id = p.code
		FROM #X x INNER JOIN UtilityProvince p
		ON X.name = P.subdivision_name
		WHERE x.cat = 'province'
		AND id IS NULL

		UPDATE X
		SET X.ID = parent+'-'+REPLACE(x.name,' ','-')
		FROM #X x
		WHERE x.cat = 'province'
		AND id IS NULL

		UPDATE X
		SET  x.parent = y.id
		FROM #X x INNER JOIN #X y
		ON x.parentName = y.name
		WHERE x.cat = 'TERRITORY'
		AND Y.cat = 'PROVINCE'

		UPDATE X
		SET X.id = G.id
		FROM #X x INNER JOIN DimGeo g
		ON x.name = g.name
		WHERE x.cat = 'territory'
		AND G.cat = 'TERRITORY'
		AND X.id IS NULL

		UPDATE X
		SET X.ID = parent+'-'+REPLACE(x.name,' ','-')
		FROM #X x
		WHERE x.cat = 'territory'
		AND id IS NULL

		SELECT 'geo' dim,LOWER(x.id) id,name,LOWER(parent) region 
			,g.GeoLevelName cat, g.GeoLevelNo lev
			INTO #final
		FROM #X X INNER JOIN GeoHierarchyLevel g
		ON x.cat = g.GeoLevelName

		MERGE DimGeo T
		USING (
			SELECT * FROM #final
		) S
		ON (T.id = S.id AND T.cat = S.cat AND S.region = T.region)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES(S.dim,S.id,S.name,S.region,S.cat,S.lev);
		
		MERGE dbo.DimCountry T
		USING (
			SELECT * FROM #final
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = 7

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 7,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM [dbo].[HarvestChoiceRawData]
		GROUP BY Indicator
		
		--DROP INDEX ix_fact ON FactFinal

		DELETE FROM FactFinal
		WHERE DataSourceID = 7

		INSERT INTO factfinal 
					([datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					[value]) 
		SELECT 7, r.ID, r.Period, i.ID, TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator 
			FROM [dbo].[HarvestChoiceRawData] hr
			LEFT JOIN DimCountry dc
			ON hr.ISO3 = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			FROM [dbo].[HarvestChoiceRawData] hr
			LEFT JOIN #final f
			ON hr.ADM1_NAME_ALT = F.name
			AND hr.ISO3 = f.region
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'province'
			AND f.cat = 'province'
			AND F.id IS NOT NULL

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			FROM [dbo].[HarvestChoiceRawData] hr
			LEFT JOIN #final f
			ON hr.ADM2_NAME_ALT = F.name
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'territory'
			AND f.cat = 'territory'
			AND F.id IS NOT NULL
			
		)r 
		LEFT JOIN (
			SELECT * FROM DimIndicators WHERE DataSourceID = 7
		) i
			ON r.Indicator = i.[Indicator Name]

		--CREATE NONCLUSTERED INDEX ix_fact 
		--ON factfinal ([datasourceid], [country code], [period], [indicator code],[SubGroup] ) 
		--INCLUDE([Value])

END

GO


