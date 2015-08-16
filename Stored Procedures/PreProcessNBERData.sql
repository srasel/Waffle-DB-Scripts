IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreProcessNBERData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PreProcessNBERData]
GO

/****** Object:  StoredProcedure [dbo].[PreProcessNBERData]    Script Date: 8/15/2015 8:29:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessNBERData]
AS
BEGIN
		SET NOCOUNT ON;
		
		--DROP TABLE #y
		SELECT n.CountryCode, n.Region
			INTO #y
		FROM [dbo].[NBERRawData] n
		INNER JOIN DimGeo g
		ON n.CountryCode = g.id
		GROUP BY CountryCode, n.Region

		--DROP TABLE #final
		SELECT y.Region name, CAST(g.id AS VARCHAR(100)) id,
		y.CountryCode region, 'province' cat
		INTO #final
		FROM #y y LEFT JOIN DimGeo g
		ON y.Region = g.name
		AND y.CountryCode = g.region
		WHERE g.id IS NOT NULL
		AND y.Region <> ''

		UNION ALL

		SELECT y.Region name, CAST(y.CountryCode+'-'+y.Region AS VARCHAR(100)) id,
		y.CountryCode region, 'province' cat
		FROM #y y LEFT JOIN DimGeo g
		ON y.Region = g.name
		WHERE g.id IS NULL
		AND y.Region <> ''

		MERGE DimGeo T
		USING (
			SELECT f.*, g.[GeoLevelNo] lev
			FROM #final f INNER JOIN [dbo].[GeoHierarchyLevel] g
			ON f.cat = g.[GeoLevelName]
		) S
		ON (T.id = S.id AND T.cat = S.cat AND T.region = S.region)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES('geo',LOWER(S.id),S.name,LOWER(S.region),S.cat,S.lev);


		TRUNCATE TABLE dbo.DimCountry
		INSERT INTO dbo.DimCountry([Type],[Country Code],[Short Name], [Country Name])
		SELECT cat,id,name,name
		FROM DimGeo
		ORDER BY lev

		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = 8

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 8,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM [dbo].[NBERRawData]
		GROUP BY Indicator

		DROP INDEX ix_fact ON FactFinal

		DELETE FROM FactFinal
		WHERE DataSourceID = 8

		INSERT INTO factfinal 
					([datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					[value]) 
		SELECT 8, r.ID, r.Period, i.ID, IIF(ISNUMERIC(r.DataValue)=1,r.DataValue,NULL)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator 
			FROM [dbo].[NBERRawData] hr
			LEFT JOIN DimCountry dc
			ON hr.CountryCode = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			FROM [dbo].[NBERRawData] hr
			LEFT JOIN #final f
			ON hr.Region = F.name
			AND hr.CountryCode = f.region
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'province'
			AND f.cat = 'province'
			AND F.id IS NOT NULL
		)r 
		LEFT JOIN (
			SELECT * FROM DimIndicators WHERE DataSourceID = 8
		) i
			ON r.Indicator = i.[Indicator Name]

		CREATE NONCLUSTERED INDEX ix_fact 
		ON factfinal ([datasourceid], [country code], [period], [indicator code],[SubGroup] ) 
		INCLUDE([Value])

END

GO


