IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessUNData]') AND type in (N'P', N'PC'))

DROP PROCEDURE [dbo].[ProcessUNData]
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
CREATE PROCEDURE ProcessUNData
AS
BEGIN
		SET NOCOUNT ON;

		--DELETE FROM [Gapminder_RAW].dbo.Unicef_Total_Population
		--WHERE Geo = '"China'

		--DELETE FROM [Gapminder_RAW].dbo.Unicef_Total_Population
		--WHERE LEN(gender) > LEN('female')

		--DROP TABLE #GEO
		
		SELECT CASE GEO 
				WHEN 'Côte d''Ivoire' THEN 'Cote d''Ivoire'
				WHEN 'United States of America' THEN 'United States'
				WHEN 'Democratic Republic of the Congo' THEN 'Dem. Rep. Congo'
				WHEN 'Congo' THEN 'Rep. Congo'
				WHEN 'Viet Nam' THEN 'Vietnam'
				WHEN 'Iran (Islamic Republic of)' THEN 'Iran'
				WHEN 'Kyrgyzstan' THEN 'Kyrgyz Republic'
				WHEN 'Lao People''s Democratic Republic' THEN 'Lao'
				WHEN 'Slovakia' THEN 'Slovak Republic'
				WHEN 'Syrian Arab Republic' THEN 'Syria'
				ELSE GEO END GEO
		INTO #GEO
		FROM (
			SELECT Geo
			FROM [Gapminder_RAW].dbo.Unicef_Total_Population
			GROUP BY Geo
		)A
		INTERSECT
		SELECT NAME
		FROM DimGeo WHERE cat IN ('planet','region','country')

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'un'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'un'
		--SELECT @dataSourceID
		
		/*
		SELECT * FROM #GEO G LEFT JOIN DimCountry C
		ON G.GEO = C.[Short Name]
		WHERE C.[Country Code] IS NOT NULL
		AND C.[Type] IN ('planet','region','country')

		SELECT TOP 100 * FROM [Gapminder_RAW].dbo.Unicef_Total_Population
		*/

		MERGE [dbo].[DimSubGroup] T
		USING (
			SELECT 'N/A' SubGroup
			UNION ALL
			SELECT VARIANT
			FROM [Gapminder_RAW].dbo.Unicef_Total_Population
			GROUP BY VARIANT
		) S
		ON (T.SubGroup = S.SubGroup AND T.DataSourceID = @dataSourceID)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(SubGroup,DataSourceID) 
			VALUES(S.SubGroup,@dataSourceID);

		MERGE [dbo].[DimGender] T
		USING (
			SELECT gender 
			FROM [Gapminder_RAW].dbo.Unicef_Total_Population
			GROUP BY gender
		) S
		ON (T.gender = S.gender AND T.DataSourceID = @datasourceID)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(DatasourceID, gender) 
			VALUES(@dataSourceID,S.gender);

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,'pop' [Indicator Code]
			,'Total Population (thousands)' [indicator]
			,'thousands' Unit
			,NULL ID 
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],Unit,[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,Unit,S.ID);

		MERGE [dbo].[DimAge] T
		USING (
			SELECT 'N/A' Age
		) S
		ON (T.age = S.Age AND T.DataSourceID = @datasourceID)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(DatasourceID, age) 
			VALUES(@dataSourceID,S.Age);

		EXECUTE ChangeIndexAndConstraint 'DROP', 'un'

		DELETE FROM [dbo].[FactUN]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactUN] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code], 
				 [SubGroup],
				 [Age],
				 [Gender],
				 [Value]) 
		
		SELECT @versionNo,@dataSourceID,c.ID, TRY_CONVERT(int, r.Attribute), i.ID, s.ID,a.id,g.id, TRY_CONVERT(float,r.Value)
		FROM (SELECT *,'N/A' Age, 'pop' indicator FROM [Gapminder_RAW].dbo.Unicef_Total_Population)  r 
		LEFT JOIN (
			SELECT ID,[Indicator Code]
			FROM   DimIndicators 
			WHERE  datasourceid = @dataSourceID
		) i
			ON r.indicator = i.[Indicator Code]
		LEFT JOIN (
			SELECT ID, SubGroup
			FROM DimSubGroup
			WHERE  DataSourceID = @dataSourceID
		) s
			ON r.Variant = s.SubGroup
		LEFT JOIN (
			SELECT ID,GEO FROM #GEO G LEFT JOIN DimCountry C
			ON G.GEO = C.[Short Name]
			WHERE C.[Country Code] IS NOT NULL
			AND C.[Type] IN ('planet','region','country')
		) c
			ON r.Geo = c.GEO
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
		WHERE i.id IS NOT NULL
		AND c.id IS NOT NULL
		AND S.ID IS NOT NULL
		
		--UPDATE i
		--SET i.[Indicator Code] = r.IndicatorNameAfter
		--FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		--ON i.DataSourceID = r.DataSourceID
		--AND i.[Indicator Name] = r.IndicatorNameBefore

		EXECUTE [dbo].[PostProcessFactPivot] 'un',@versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'un'


END
GO
