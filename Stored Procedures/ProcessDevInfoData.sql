IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessDevInfoData]') AND type in (N'P', N'PC'))

DROP PROCEDURE [dbo].[ProcessDevInfoData]
GO

/****** Object:  StoredProcedure [dbo].[ProcessDevInfoData]    Script Date: 8/12/2015 12:46:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessDevInfoData]
AS
BEGIN
		SET NOCOUNT ON;
		--DROP TABLE #A
		SELECT Area, AreaCode
		INTO #A
		FROM dbo.AllDevInfoRawData 
		GROUP BY Area, AreaCode
		--SELECT * FROM #A

		--DROP TABLE #C
		SELECT Area, AreaCode,c.lev,c.cat INTO #C
		FROM #A g LEFT JOIN (
			SELECT * FROM DimGeo WHERE cat = 'country'
		) c
		ON LEFT(areacode,3) = c.id
		WHERE ISNUMERIC(LEFT(AreaCode, 3)) = 0
		AND C.ID IS NOT NULL
		--SELECT * FROM #C
		
		--DROP TABLE #B
		SELECT CAST(LEFT(areacode,3) AS VARCHAR(100)) iso
			, 3 l, 1 rnk, CAST('country' AS VARCHAR(100)) cat
			INTO #B
		FROM #A
		WHERE ISNUMERIC(LEFT(areacode,3)) = 0
		AND LEN(AreaCode) = 3
		group by LEFT(areacode,3)
		--SELECT * FROM #B

		INSERT INTO #B
		SELECT *,
		CASE rnk WHEN 1 THEN 'province'
				WHEN 2 THEN 'territory'
				WHEN 3 THEN 'sub territory'
				WHEN 4 THEN 'brick' end cat
		FROM (
		SELECT iso, l, row_number() OVER(PARTITION BY iso ORDER BY l) rnk 
		FROM (
			SELECT DENSE_RANK() OVER(PARTITION BY LEFT(areacode,3), LEN(areacode) ORDER BY area)
			rnk,
			LEN(areacode) l, 
			LEFT(areacode,3) iso, *
			FROM #A
			WHERE ISNUMERIC(LEFT(areacode,3)) = 0
			AND LEN(AreaCode) > 3
			)A WHERE rnk = 1
		)B
		
		--SELECT * FROM #B
		--SELECT * FROM #C
		;WITH cte (code,name,parent,rnk, cat)
		AS
		(
			SELECT CAST(areacode AS VARCHAR(100)), CAST(area AS VARCHAR(100)), CAST(b.iso AS VARCHAR(100)), b.rnk
			,b.cat
			FROM #C c inner join #B b
			ON LEN(c.areacode) = b.l
			AND LEFT(c.areacode, b.l) LIKE b.iso + '%'
			WHERE b.cat = 'province'

			UNION ALL

			SELECT CAST(areacode AS VARCHAR(100)), CAST(area AS VARCHAR(100)), CAST(ct.code AS VARCHAR(100)), ct.rnk + 1
			,b.cat
			FROM #C c inner join cte ct
			ON c.areacode LIKE ct.code + '%'
			inner join #B b
			ON LEN(c.areacode) = b.l
			AND LEFT(c.areacode, b.l) LIKE b.iso + '%'
			WHERE b.rnk = ct.rnk + 1
			AND ct.rnk < 7
		)
		
		SELECT 'geo' dim,code id, name, parent region,cat, g.GeoLevelNo lev, 
				NULL lat, NULL long
				INTO #final
		FROM cte c INNER JOIN GeoHierarchyLevel g
		ON c.cat = g.GeoLevelName

		MERGE DimGeo T
		USING (
			SELECT * FROM #final
		) S
		ON (T.id = S.id AND T.cat = S.cat)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES(S.dim,LOWER(S.id),S.name,LOWER(S.region),S.cat,S.lev);
		
		MERGE dbo.DimCountry T
		USING (
			SELECT * FROM #final
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		MERGE [dbo].[DimSubGroup] T
		USING (
			SELECT 'N/A' SubGroup
			UNION ALL
			SELECT SUBGROUP
			FROM AllDevInfoRawData
			GROUP BY Subgroup
		) S
		ON (T.SubGroup = S.SubGroup)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(SubGroup) 
			VALUES(S.SubGroup);

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'devinfo'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'devinfo'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator
			,Unit
			,NULL ID 
			FROM dbo.AllDevInfoRawData 
			GROUP BY Indicator,Unit
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],Unit,[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,Unit,S.ID);

		EXECUTE ChangeIndexAndConstraint 'DROP', 'devinfo'

		DELETE FROM [dbo].[FactDevInfo]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactDevInfo] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code], 
				 [SubGroup],
				 [Value]) 
		
		SELECT @versionNo,@dataSourceID,c.ID, TRY_CONVERT(int, r.[Year]), i.ID, s.ID, TRY_CONVERT(float,r.DataValue)
		FROM dbo.AllDevInfoRawData  r 
		LEFT JOIN (
			SELECT ID,[Indicator Name]
			FROM   DimIndicators 
			WHERE  datasourceid = @dataSourceID
		) i
			ON r.Indicator = i.[Indicator Name]
		LEFT JOIN DimSubGroup s
			ON r.Subgroup = s.SubGroup
		LEFT JOIN (
			SELECT ID, [Country Code],[Type]
			FROM DimCountry
			--WHERE [Type] = 'country'
		) c
			ON r.AreaCode = c.[Country Code]
		WHERE i.id IS NOT NULL
		AND c.id IS NOT NULL
		AND S.ID IS NOT NULL
		
		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		EXECUTE [dbo].[PostProcessFactPivot] 'devinfo', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'devinfo'

END

GO


