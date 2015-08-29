IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreProcessMortalityData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PreProcessMortalityData]
GO

/****** Object:  StoredProcedure [dbo].[PreProcessMortalityData]    Script Date: 8/25/2015 5:45:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessMortalityData] 
AS
BEGIN
		
		SET NOCOUNT ON;

		TRUNCATE TABLE dbo.DimAge
		INSERT INTO dbo.DimAge(age)
		SELECT 'N/A' age
		UNION ALL
		SELECT Age FROM [dbo].[MortalityOrgData]
		GROUP BY Age

		TRUNCATE TABLE [dbo].[DimGender]
		INSERT INTO [dbo].[DimGender]
		SELECT 'N/A' gender
		UNION ALL 
		SELECT 'male'
		UNION ALL
		SELECT 'female'
		UNION ALL
		SELECT 'both'
		UNION ALL
		SELECT 'others'

		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = 12

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 12,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM [dbo].[MortalityOrgData]
		GROUP BY Indicator

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
		ON (T.SubGroup = S.subgroup)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(SubGroup) 
			VALUES(S.subgroup);

		UPDATE A
		SET A.subGroupID = S.ID
		FROM #A A INNER JOIN DimSubGroup S
		ON A.subgroup = S.SubGroup

		--SELECT * FROM #A
	
		DELETE FROM FactFinal
		WHERE DataSourceID = 12

		INSERT INTO FactFinal 
					([datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					SubGroup,
					Age,
					Gender,
					[value]) 
		SELECT 12,c.ID, LEFT(r.Year,4), i.ID, s.ID, ag.ID, gen.ID, r.DataValue
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
			SELECT * FROM DimIndicators WHERE DataSourceID = 12
		) i
			ON r.Indicator = i.[Indicator Name]
		LEFT JOIN (SELECT subgroup,subGroupID ID FROM #A GROUP BY subgroup,subGroupID) s
			ON r.Subgroup = s.SubGroup
		LEFT JOIN DimCountry c
			ON r.id = c.[Country Code]
		LEFT JOIN DimAge ag
			ON r.Age = ag.age
		LEFT JOIN DimGender gen
			ON r.gender = gen.gender
		--WHERE i.id IS NOT NULL
		--AND c.id IS NOT NULL
		--AND S.ID IS NOT NULL
		--AND gen.ID IS NOT NULL

END

GO


