IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessMortalityData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ProcessMortalityData]
GO

/****** Object:  StoredProcedure [dbo].[ProcessMortalityData]    Script Date: 8/25/2015 5:45:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessMortalityData] 
AS
BEGIN
		
		SET NOCOUNT ON;

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'hmd'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'hmd'
		--SELECT @dataSourceID

		MERGE [dbo].[DimAge] T
		USING (
			SELECT 'N/A' age 
			UNION ALL
			SELECT Age FROM [dbo].[MortalityOrgData]
			GROUP BY Age
		) S
		ON (T.age = S.age AND T.DataSourceID = @dataSourceID)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(age, DataSourceID) 
			VALUES(S.age, @dataSourceID);

		MERGE [dbo].[DimGender] T
		USING (
			SELECT 'N/A' gender UNION ALL SELECT 'male' UNION ALL
			SELECT 'female' UNION ALL SELECT 'both' UNION ALL
			SELECT 'others'
		) S
		ON (T.gender = S.gender AND T.DataSourceID = @dataSourceID)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(gender, DataSourceID) 
			VALUES(S.gender,@dataSourceID);

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255))[Indicator Code]
			,indicator
			,NULL ID
			FROM [dbo].[MortalityOrgData]
			GROUP BY Indicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);

		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		--DROP TABLE #A
		SELECT LEFT(CountryCode,3) countrycode
		,IIF(SUBSTRING(CountryCode,4, LEN(CountryCode))='','N/A'
			,SUBSTRING(CountryCode,4, LEN(CountryCode))
		)subgroup
		,CAST(NULL AS INT) subGroupID
		INTO #A
		FROM (
			SELECT CountryCode
			FROM [dbo].[MortalityOrgData]
			GROUP BY CountryCode
		)A
		
		--TRUNCATE TABLE [dbo].[DimSubGroup]
		MERGE [dbo].[DimSubGroup] T
		USING (
			SELECT subgroup FROM #A
			GROUP BY subgroup
		) S
		ON (T.SubGroup = S.subgroup AND T.DataSourceID = @dataSourceID)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(SubGroup, DataSourceID) 
			VALUES(S.subgroup, @dataSourceID);

		UPDATE A
		SET A.subGroupID = S.ID
		FROM #A A INNER JOIN DimSubGroup S
		ON A.subgroup = S.SubGroup
		WHERE S.DataSourceID = @dataSourceID

		EXECUTE ChangeIndexAndConstraint 'DROP', 'hmd'

		DELETE FROM dbo.FactHMD
		WHERE VersionID = @versionNo

		INSERT INTO FactHMD 
					([VersionID],
					[datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					SubGroup,
					Age,
					Gender,
					[value]) 
		SELECT @versionNo, @dataSourceID,c.ID, LEFT(r.Year,4), i.ID, s.ID, ag.ID, gen.ID, r.DataValue
		FROM (
			SELECT Indicator, LEFT(CountryCode,3)id
			,IIF(SUBSTRING(CountryCode,4, LEN(CountryCode))='','N/A'
				,SUBSTRING(CountryCode,4, LEN(CountryCode))
			)subgroup,[Year],Age,'male' gender, TRY_CONVERT(float,Male) DataValue
			FROM [dbo].[MortalityOrgData] 

			UNION ALL

			SELECT Indicator, LEFT(CountryCode,3)id
			,IIF(SUBSTRING(CountryCode,4, LEN(CountryCode))='','N/A'
				,SUBSTRING(CountryCode,4, LEN(CountryCode))
			)subgroup,[Year],Age,'female' gender, TRY_CONVERT(float,Female) DataValue
			FROM [dbo].[MortalityOrgData]
			
			UNION ALL

			SELECT Indicator, LEFT(CountryCode,3)id
			,IIF(SUBSTRING(CountryCode,4, LEN(CountryCode))='','N/A'
				,SUBSTRING(CountryCode,4, LEN(CountryCode))
			)subgroup,[Year],Age,'both' gender, TRY_CONVERT(float,Total) DataValue
			FROM [dbo].[MortalityOrgData] 
		)
		r 
		LEFT JOIN (
			SELECT * FROM DimIndicators WHERE DataSourceID = @dataSourceID
		) i
			ON r.Indicator = i.[Indicator Name]
		LEFT JOIN (SELECT subgroup,subGroupID ID FROM #A GROUP BY subgroup,subGroupID) s
			ON r.Subgroup = s.SubGroup
		LEFT JOIN (
			SELECT ID, [Country Code]
			FROM DimCountry
			WHERE [Type] = 'country'
		) c
			ON r.id = c.[Country Code]
		LEFT JOIN ( 
			SELECT ID, age
			FROM DimAge
			WHERE  DataSourceID = @dataSourceID
		)ag
			ON r.Age = ag.age
		LEFT JOIN (
			SELECT ID,gender
			FROM DimGender
			WHERE  DataSourceID = @dataSourceID
		) gen
			ON r.gender = gen.gender
		--WHERE i.id IS NOT NULL
		--AND c.id IS NOT NULL
		--AND S.ID IS NOT NULL
		--AND gen.ID IS NOT NULL

		EXECUTE [dbo].[PostProcessFactPivot] 'hmd', @versionNo
		EXECUTE ChangeIndexAndConstraint 'CREATE', 'hmd'

END

GO

-- EXECUTE [dbo].[ProcessMortalityData] 
