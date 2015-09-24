IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessOPHIData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ProcessOPHIData]
GO

/****** Object:  StoredProcedure [dbo].[ProcessOPHIData]    Script Date: 8/16/2015 1:44:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessOPHIData]
AS
BEGIN
		
		SET NOCOUNT ON;
		
		--DROP TABLE #A
		SELECT CountryCode, CountryName, SubRegionName, CAST(NULL AS VARCHAR(200)) id
			INTO #A
		FROM [Gapminder_RAW].[ophi].[Raw_Data]
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

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'ophi'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'ophi'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator
			,NULL ID 
			FROM [Gapminder_RAW].[ophi].[Raw_Data]
			GROUP BY Indicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);
		
		EXECUTE ChangeIndexAndConstraint 'DROP', 'ophi'

		DELETE FROM [dbo].[FactOPHI]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactOPHI] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code], 
				 [SubGroup],
				 [Age],
				 [Gender],
				 [Value]) 
		SELECT @versionNo,@dataSourceID, r.ID, LEFT(r.Period,4), i.ID
				,s.ID
				,a.ID
				,g.ID, TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender
			FROM [Gapminder_RAW].[ophi].[Raw_Data] hr
			LEFT JOIN DimCountry dc
			ON hr.CountryCode = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator 
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender 
			FROM [Gapminder_RAW].[ophi].[Raw_Data] hr
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

		--EXECUTE [dbo].[PostProcessFactPivot] 'ophi', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'ophi'

END

GO

-- EXECUTE [dbo].[ProcessOPHIData]
