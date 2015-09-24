IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessAdhocData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ProcessAdhocData]
GO

/****** Object:  StoredProcedure [dbo].[ProcessAdhocData]    Script Date: 8/16/2015 6:06:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessAdhocData] 
AS
BEGIN
			SET NOCOUNT ON;

			DECLARE @versionNo INT
			SELECT @versionNo = MAX(VersionNo)
			FROM UtilityDataVersions
			WHERE DataSource = 'spreedsheet'
			GROUP BY DataSource
			--SELECT @versionNo
		
			DECLARE @dataSourceID INT
			SELECT @dataSourceID = ID
			FROM DimDataSource
			WHERE DataSource = 'spreedsheet'
			--SELECT @dataSourceID

			--DROP TABLE #GINI
			SELECT @dataSourceID DataSource, 'gini' IndicatorCode
				INTO #GINI
			UNION ALL
			SELECT @dataSourceID DataSource, 'u5mr' IndicatorCode
			UNION ALL
			SELECT @dataSourceID DataSource, 'childSurv' IndicatorCode
		
			MERGE dbo.DimIndicators T
			USING (
				SELECT * FROM #GINI
			) S
			ON (T.[Indicator Code] = S.IndicatorCode AND T.DataSourceID = @dataSourceID)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT([DataSourceID],[Indicator Code],[Indicator Name]) 
				VALUES(S.DataSource,S.IndicatorCode,S.IndicatorCode);

			--DROP TABLE #INDICATORS
			SELECT ID,IndicatorCode INTO #INDICATORS
			FROM DimIndicators I INNER JOIN #GINI G
			ON I.[Indicator Code] = G.IndicatorCode
			AND I.DataSourceID = G.DataSource

			DELETE FROM FactSpreedSheet
			WHERE [Indicator Code] IN (
				SELECT ID FROM #INDICATORS
			) AND VersionID = @versionNo

			INSERT INTO FactSpreedSheet 
						(VersionID,
						[datasourceid], 
						[country code], 
						period, 
						[indicator code], 
						[SubGroup],
						[Age],
						[Gender],
						[value])

			SELECT VersionID,ds,CID,Period,IND,s.ID,a.ID,g.ID, Val
			FROM (
				SELECT  @versionNo VersionID, @dataSourceID ds, c.ID CID, TRY_CONVERT(INT, r.[time]) Period
				, i.ID IND, TRY_CONVERT(float,gini) Val --into #A
				,'N/A' SubGroup,'N/A' Age,'N/A' Gender
				FROM dbo.NewDataGiniU5mrChildSurv r LEFT JOIN DimCountry c
				ON r.geo = c.[Country Code]
				,#INDICATORS i
				WHERE c.[Country Code] IS NOT NULL
				AND c.[Type] = 'country'
				AND I.IndicatorCode = 'gini'
		
				UNION ALL

				SELECT  @versionNo,@dataSourceID ds, c.ID, TRY_CONVERT(INT, r.[time]) per, i.ID ind
				, TRY_CONVERT(float,u5mr)
				,'N/A' SubGroup,'N/A' Age,'N/A' Gender
				FROM dbo.NewDataGiniU5mrChildSurv r LEFT JOIN DimCountry c
				ON r.geo = c.[Country Code]
				,#INDICATORS i
				WHERE c.[Country Code] IS NOT NULL
				AND c.[Type] = 'country'
				AND I.IndicatorCode = 'u5mr'

				UNION ALL

				SELECT  @versionNo,@dataSourceID ds, c.ID, TRY_CONVERT(INT, r.[time]) per, i.ID ind
				, TRY_CONVERT(float,childSurv)
				,'N/A' SubGroup,'N/A' Age,'N/A' Gender
				FROM dbo.NewDataGiniU5mrChildSurv r LEFT JOIN DimCountry c
				ON r.geo = c.[Country Code]
				,#INDICATORS i
				WHERE c.[Country Code] IS NOT NULL
				AND c.[Type] = 'country'
				AND I.IndicatorCode = 'childSurv'
			)fd
			LEFT JOIN (
				SELECT ID, SubGroup
				FROM DimSubGroup
				WHERE  DataSourceID = @dataSourceID
			) s
			ON fd.SubGroup = s.SubGroup
			LEFT JOIN (
				SELECT ID, age
				FROM DimAge
				WHERE  DataSourceID = @dataSourceID
			) a
			ON fd.Age = a.age
			LEFT JOIN (
				SELECT ID,gender
				FROM DimGender
				WHERE  DataSourceID = @dataSourceID
			) g
			ON fd.Gender = g.gender

END

GO


