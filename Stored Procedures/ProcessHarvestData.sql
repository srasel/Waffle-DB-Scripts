IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessHarvetChoice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ProcessHarvetChoice]
GO

/****** Object:  StoredProcedure [dbo].[ProcessHarvetChoice]    Script Date: 8/15/2015 6:04:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessHarvetChoice]
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
			FROM [GapMinder_RAW].[harvestchoice].[RawData]
			GROUP BY ADM0_NAME,ADM1_NAME_ALT,ISO3

			UNION ALL

			SELECT ADM2_NAME_ALT,ADM1_NAME_ALT, NULL, NULL, 'territory' 
			FROM [GapMinder_RAW].[harvestchoice].[RawData]
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

		
		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'harvestchoice'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'harvestchoice'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator
			,NULL ID 
			FROM [GapMinder_RAW].[harvestchoice].[RawData]
			GROUP BY Indicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);
		
		EXECUTE ChangeIndexAndConstraint 'DROP', 'harvestchoice'

		DELETE FROM [dbo].[FactHarvestChoice]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactHarvestChoice] 
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
		,g.ID
		,TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator 
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender
			FROM [GapMinder_RAW].[harvestchoice].[RawData] hr
			LEFT JOIN DimCountry dc
			ON hr.ISO3 = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender
			FROM [GapMinder_RAW].[harvestchoice].[RawData] hr
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
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender 
			FROM [GapMinder_RAW].[harvestchoice].[RawData] hr
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

		EXECUTE [dbo].[PostProcessFactPivot] 'harvestchoice', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'harvestchoice'

END

GO


--EXECUTE [dbo].[ProcessHarvetChoice]