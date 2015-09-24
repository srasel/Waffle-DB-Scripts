IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessDHSData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ProcessDHSData]
GO

/****** Object:  StoredProcedure [dbo].[ProcessDHSData]    Script Date: 9/8/2015 5:16:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessDHSData]
AS
BEGIN
	
			SET NOCOUNT ON;

			DECLARE @versionNo INT
			SELECT @versionNo = MAX(VersionNo)
			FROM UtilityDataVersions
			WHERE DataSource = 'dhs'
			GROUP BY DataSource
			--SELECT @versionNo
		
			DECLARE @dataSourceID INT
			SELECT @dataSourceID = ID
			FROM DimDataSource
			WHERE DataSource = 'dhs'
			--SELECT @dataSourceID

			--DROP #MICS
			SELECT Stratifier 
			,Country
			,CASE Stratifier
				WHEN 'gregion' THEN IndPostfix
				ELSE Country END Region
			,CASE Stratifier
				WHEN 'sex' THEN IndPostfix
				ELSE 'N/A' END Gender
			,[Year]
			,CASE Stratifier
				WHEN 'area' THEN IndPostfix
				WHEN 'meduc' THEN IndPostfix
				WHEN 'wiq' THEN IndPostfix
				ELSE 'N/A' END SubGroup
			,CASE Stratifier
				WHEN 'mage' THEN REPLACE(Stratifier_type,' '+IndPostfix,'')
				ELSE 'N/A' END AgeGroup
			,Indicator
			,DataValue
			--,Indicator2
			INTO #MICS
			FROM (
			SELECT DataSheetName,Country,[Year],Indicator,Stratifier,Stratifier_type, Indicator2
			,SUBSTRING(Stratifier_type, CHARINDEX(' ',Stratifier_type,1)+1, LEN(Stratifier_type)) IndPostfix
			,DataValue 
			FROM [Gapminder_RAW].[dhs].[MICS_RawData]
			WHERE Indicator2 IN ('r','')
			--AND Indicator = 'anc4'
			--AND Country = 'Bhutan'
			)A
			ORDER BY Stratifier

			--DROP TABLE #GEO
			SELECT Country CountryMain, Region RegionMain, REPLACE(Country,'_',' ') Country, LTRIM(SUBSTRING(Region, CHARINDEX(']',Region,1)+1, LEN(Region))) REGION
			,CAST(NULL AS VARCHAR(100)) ISO, CAST(NULL AS VARCHAR(100)) ISO_REGION
			INTO #GEO
			FROM #MICS
			WHERE Country <> Region
			GROUP BY COUNTRY,Region

			UPDATE G
			SET G.ISO = DG.id
			FROM #GEO G INNER JOIN DimGeo DG
			ON G.Country = DG.name
			WHERE DG.cat = 'Country'

			UPDATE G
			SET G.ISO_REGION = DG.id
			FROM #GEO G INNER JOIN DimGeo DG
			ON G.ISO = DG.region
			AND G.REGION = DG.name
			WHERE DG.cat = 'province'
			AND G.ISO IS NOT NULL

			UPDATE  G
			SET G.ISO_REGION = ISO+'-'+LOWER(REGION)
			FROM #GEO G
			WHERE ISO IS NOT NULL
			AND ISO_REGION IS NULL

			DELETE FROM #GEO
			WHERE ISO IS NULL

			MERGE DimGeo T
			USING (
				SELECT * FROM #GEO
			) S
			ON (T.id = S.ISO_REGION AND T.region = S.ISO AND T.cat = 'province')
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(dim,id,name,region,cat,lev) 
				VALUES('geo',LOWER(S.ISO_REGION),S.REGION,LOWER(S.region),'province',4);
		
			MERGE dbo.DimCountry T
			USING (
				SELECT * FROM #Geo
			) S
			ON (T.[Country Code] = S.ISO_REGION AND T.[type] = 'province')
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT([type],[Country Code],[Short Name],[Country Name]) 
				VALUES('province',LOWER(S.ISO_REGION),S.REGION,S.REGION);

			MERGE [dbo].[DimSubGroup] T
			USING (
				SELECT SubGroup FROM #MICS
				GROUP BY SubGroup
			) S
			ON (T.SubGroup = S.SubGroup AND T.DataSourceID = @dataSourceID)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(SubGroup,DataSourceID) 
				VALUES(S.SubGroup,@dataSourceID);

			MERGE [dbo].[DimAge] T
			USING (
				SELECT AgeGroup FROM #MICS
				GROUP BY AgeGroup
			) S
			ON (T.age = S.AgeGroup AND T.DataSourceID = @dataSourceID)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(age,DataSourceID) 
				VALUES(S.AgeGroup,@dataSourceID);

			MERGE [dbo].[DimGender] T
			USING (
				SELECT Gender FROM #MICS
				GROUP BY Gender
			) S
			ON (T.gender = S.gender AND T.DataSourceID = @dataSourceID)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(gender,DataSourceID) 
				VALUES(S.gender,@dataSourceID);

			MERGE DimIndicators T
			USING (
				SELECT @dataSourceID DataSourceID
				,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
				, indicator
				,NULL ID 
				FROM #MICS 
				GROUP BY Indicator
			) S
			ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
				VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);

			EXECUTE ChangeIndexAndConstraint 'DROP', 'dhs'

			DELETE FROM [dbo].[FactDHS]
			WHERE VersionID = @versionNo

			INSERT INTO [dbo].[FactDHS] 
					([VersionID],
					 [DataSourceID], 
					 [Country Code], 
					 [Period], 
					 [Indicator Code], 
					 [SubGroup],
					 [Age],
					 [Gender],
					 [Value]) 
			SELECT @versionNo,@dataSourceID,c.ID, LEFT(r.[Year],4), i.ID, s.ID, ag.ID, gen.ID, r.DataValue
			FROM (
				SELECT ISO id, Indicator, SubGroup, AgeGroup, Gender, [Year], TRY_CONVERT(float,DataValue) DataValue
				FROM #MICS f LEFT JOIN (SELECT ISO,CountryMain FROM #GEO GROUP BY ISO,CountryMain) g
				ON f.Country = g.CountryMain
				--AND f.Region = g.RegionMain
				WHERE Stratifier <> 'gregion'
				AND G.ISO IS NOT NULL

				UNION ALL

				SELECT ISO id, Indicator, SubGroup, AgeGroup, Gender, [Year], TRY_CONVERT(float,DataValue) DataValue
				FROM #MICS f LEFT JOIN (
					SELECT ISO_REGION ISO,CountryMain,RegionMain FROM #GEO 
					GROUP BY ISO_REGION,CountryMain,RegionMain
				) g
				ON f.Country = g.CountryMain
				AND f.Region = g.RegionMain
				WHERE Stratifier = 'gregion'
				AND G.ISO IS NOT NULL
			)
			r 
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
				ON r.Subgroup = s.SubGroup
			LEFT JOIN (
				SELECT ID, [Country Code]
				FROM DimCountry
				WHERE [Type] IN ('country', 'province')
			) c
				ON r.id = c.[Country Code]
			LEFT JOIN (
				SELECT ID, age
				FROM DimAge
				WHERE  DataSourceID = @dataSourceID
			) ag
				ON r.AgeGroup = ag.age
			LEFT JOIN (
				SELECT ID,gender
				FROM DimGender
				WHERE  DataSourceID = @dataSourceID
			) gen
				ON r.gender = gen.gender
			
			--DROP TABLE #NATIONAL
			SELECT CASE CountryName
				WHEN 'KYRGYZSTAN' THEN 'Kyrgyz Republic'
				WHEN 'CONGO (Kinshasa)' THEN 'Dem. Rep. Congo'
				WHEN 'CONGO (Brazzaville)' THEN 'Rep. Congo'
				ELSE REPLACE(CountryName,'&','AND') END
			CountryName
			,[Year]
			,[Indicator]
			,TRY_CONVERT(float,DataValue) DataValue
			INTO #NATIONAL
			FROM [Gapminder_RAW].dhs.Spatial_National_Raw_Data

			MERGE DimIndicators T
			USING (
				SELECT @dataSourceID DataSourceID
				,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
				, indicator
				,NULL ID 
				FROM #NATIONAL 
				GROUP BY Indicator
			) S
			ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
				VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);

			INSERT INTO [dbo].[FactDHS] 
					([VersionID],
					 [DataSourceID], 
					 [Country Code], 
					 [Period], 
					 [Indicator Code], 
					 [SubGroup],
					 [Age],
					 [Gender],
					 [Value]) 
			SELECT @versionNo,@dataSourceID, c.ID, r.[Year], i.ID
				,s.ID
				,a.ID
				,g.ID, r.DataValue
			FROM ( 
				SELECT * ,'N/A' SubGroup,'N/A' Age,'N/A' Gender
				FROM #NATIONAL
			
			)r 
			LEFT JOIN (
				SELECT ID,[Indicator Name] 
				FROM   DimIndicators 
				WHERE  datasourceid = @dataSourceID
			) i
				ON r.Indicator = i.[Indicator Name]
			LEFT JOIN (
				SELECT ID, [Short Name]
				FROM DimCountry
				WHERE [Type] = 'country'
			)c
				ON r.CountryName = c.[Short Name]
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

			--EXECUTE [dbo].[PostProcessFactPivot] 'dhs', @versionNo

			EXECUTE ChangeIndexAndConstraint 'CREATE', 'dhs'

END

GO

--EXECUTE [dbo].[ProcessDHSData]


