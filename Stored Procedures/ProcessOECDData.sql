IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessOECDData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ProcessOECDData]
GO

/****** Object:  StoredProcedure [dbo].[ProcessOECDData]    Script Date: 9/8/2015 5:16:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessOECDData]
AS
BEGIN
			SET NOCOUNT ON;
			--DROP TABLE #OECD
			SELECT CountryCode
				,CASE Sex WHEN '' THEN 'N/A'
						WHEN 'Males' THEN 'Male'
						WHEN 'Females' THEN 'Female'
					ELSE Sex END Gender
				,CASE Age WHEN '' THEN 'N/A'
					ELSE Age END Age
				,'N/A' SubGroup
				,Indicator
				,Unit + ' ( ' + PowerCode + ')' [Unit]
				,Period
				,TRY_CONVERT(float,DataValue) DataValue
			INTO #OECD
			FROM [Gapminder_RAW].[oecd].[RawData]

			DECLARE @versionNo INT
			SELECT @versionNo = MAX(VersionNo)
			FROM UtilityDataVersions
			WHERE DataSource = 'oecd'
			GROUP BY DataSource
			--SELECT @versionNo
		
			DECLARE @dataSourceID INT
			SELECT @dataSourceID = ID
			FROM DimDataSource
			WHERE DataSource = 'oecd'
			--SELECT @dataSourceID
			
			MERGE [dbo].[DimAge] T
			USING (
				SELECT Age FROM #OECD
				GROUP BY Age
			) S
			ON (T.age = S.Age AND T.DataSourceID = @datasourceID)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(DatasourceID, age) 
				VALUES(@dataSourceID,S.Age);

			MERGE [dbo].[DimGender] T
			USING (
				SELECT gender FROM #OECD
				GROUP BY gender
			) S
			ON (T.gender = S.gender AND T.DataSourceID = @datasourceID)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(DatasourceID, gender) 
				VALUES(@dataSourceID,S.gender);

			MERGE [dbo].[DimSubGroup] T
			USING (
				SELECT SubGroup FROM #OECD
				GROUP BY SubGroup
			) S
			ON (T.SubGroup = S.SubGroup AND T.DataSourceID = @datasourceID)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(DatasourceID, SubGroup) 
				VALUES(@dataSourceID,S.SubGroup);

			MERGE DimIndicators T
			USING (
				SELECT @dataSourceID DataSourceID
				,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
				, indicator
				,NULL ID
				,Unit
				FROM #OECD 
				GROUP BY Indicator,unit
			) S
			ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID],Unit) 
				VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID,Unit);

			EXECUTE ChangeIndexAndConstraint 'DROP', 'oecd'

			DELETE FROM [dbo].[FactOECD]
			WHERE VersionID = @versionNo

			INSERT INTO [dbo].[FactOECD] 
					([VersionID],
					 [DataSourceID], 
					 [Country Code], 
					 [Period], 
					 [Indicator Code], 
					 [SubGroup],
					 [Age],
					 [Gender],
					 [Value]) 
			SELECT @versionNo,@dataSourceID,c.ID, LEFT(r.Period,4), i.ID,sub.ID, ag.ID, gen.ID, r.DataValue
			FROM (
				
				SELECT * FROM #OECD
			)r 
			LEFT JOIN (
				SELECT ID,[Indicator Name] 
				FROM   DimIndicators 
				WHERE  datasourceid = @dataSourceID
			) i
				ON r.Indicator = i.[Indicator Name]
			LEFT JOIN (
				SELECT ID,[Country Code]
				FROM DimCountry
				WHERE [Type] = 'country'
			) c
				ON r.CountryCode = c.[Country Code]
			LEFT JOIN (
				SELECT ID,age
				FROM   DimAge 
				WHERE  datasourceid = @dataSourceID
			) ag
				ON r.Age = ag.age
			LEFT JOIN (
				SELECT ID,gender
				FROM   DimGender 
				WHERE  datasourceid = @dataSourceID
			) gen
				ON r.gender = gen.gender
			LEFT JOIN (
				SELECT ID,SubGroup
				FROM   DimSubGroup 
				WHERE  datasourceid = @dataSourceID
			) sub
				ON r.SubGroup = sub.SubGroup
			
			UPDATE i
			SET i.[Indicator Code] = r.IndicatorNameAfter
			FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
			ON i.DataSourceID = r.DataSourceID
			AND i.[Indicator Name] = r.IndicatorNameBefore

			--EXECUTE [dbo].[PostProcessFactPivot] 'dhs', @versionNo

			EXECUTE ChangeIndexAndConstraint 'CREATE', 'oecd'

END

GO

--EXECUTE [dbo].[ProcessOECDData]


