IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessNBERData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ProcessNBERData]
GO

/****** Object:  StoredProcedure [dbo].[ProcessNBERData]    Script Date: 8/15/2015 8:29:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessNBERData]
AS
BEGIN
		SET NOCOUNT ON;
		
		--DROP TABLE #y
		SELECT n.CountryCode, n.Region
			INTO #y
		FROM [GapMinder_RAW].[nber].[RawData] n
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


		MERGE dbo.DimCountry T
		USING (
			SELECT f.*, g.[GeoLevelNo] lev
			FROM #final f INNER JOIN [dbo].[GeoHierarchyLevel] g
			ON f.cat = g.[GeoLevelName]
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'nber'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'nber'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator
			,NULL ID 
			FROM [GapMinder_RAW].[nber].[RawData]
			GROUP BY Indicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);
		
		EXECUTE ChangeIndexAndConstraint 'DROP', 'nber'

		DELETE FROM [dbo].[FactNBER]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactNBER] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code],
				 [SubGroup],
				 [Age],
				 [Gender],
				 [Value]) 
		SELECT @versionNo,@dataSourceID, r.ID, r.Period, i.ID
				,s.ID
				,a.ID
				,g.ID, TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender
			FROM [GapMinder_RAW].[nber].[RawData] hr
			LEFT JOIN DimCountry dc
			ON hr.CountryCode = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender  
			FROM [GapMinder_RAW].[nber].[RawData] hr
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
			SELECT ID,[Indicator Name] 
			FROM   DimIndicators 
			WHERE  datasourceid = @dataSourceID
		) i
			ON r.Indicator = i.[Indicator Name]
		LEFT JOIN (
			SELECT ID, SubGroup
			FROM DimSubGroup
			WHERE  DataSourceID = @dataSourceID
		) s
			ON r.SubGroup = s.SubGroup
		LEFT JOIN (
			SELECT ID, age
			FROM DimAge
			WHERE  DataSourceID = @dataSourceID
		) a
			ON r.Age = a.age
		LEFT JOIN (
			SELECT ID,gender
			FROM DimGender
			WHERE  DataSourceID = @dataSourceID
		) g
			ON r.Gender = g.gender

		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		--EXECUTE [dbo].[PostProcessFactPivot] 'nber', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'nber'


END

GO

-- EXECUTE [dbo].[ProcessNBERData]
