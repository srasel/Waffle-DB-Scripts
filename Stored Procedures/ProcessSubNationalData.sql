IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessSubNationalData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ProcessSubNationalData]
GO

/****** Object:  StoredProcedure [dbo].[ProcessSubNationalData]    Script Date: 08/01/2015 23:56:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ProcessSubNationalData]
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @dyn_sql NVARCHAR(max)
				,@baseFolderLocation VARCHAR(100)
				,@rawDataFileLocation VARCHAR(100)
				,@maxRowCount int
	
		SET @baseFolderLocation = N'C:\Users\shahnewaz\Documents\GapMinder_DEV\subnational\'
		SET @rawDataFileLocation = @baseFolderLocation + 'AllSubNationalRawData.txt';
		
		DROP TABLE dbo.SubNationalData

		CREATE TABLE dbo.SubNationalData
		( 
			[indicator name] VARCHAR(max), 
			[indicator code] VARCHAR(max), 
			[country name]   VARCHAR(max), 
			[country code]   VARCHAR(max), 
			[period]         INT, 
			[value]          FLOAT 
		)
		
		TRUNCATE TABLE dbo.SubNationalData
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.SubNationalData
				FROM ''' + @rawDataFileLocation + ''' 
				WITH 
					(
					FIELDTERMINATOR = '','', 
					ROWTERMINATOR = ''\n'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql
		
		ALTER TABLE dbo.SubNationalData
        ADD [region] VARCHAR(max) 

		UPDATE dbo.SubNationalData 
		SET [region] = Replace(Substring([country name], 
								Charindex(';', [country name], 1) + 
									   1, Len( 
								[country name])), '"', ''), 
			[country name] = Replace(Substring([country name], 1, 
									  Charindex(';', [country name], 1) - 1), 
							  '"' 
							  , '') 
		WHERE  Charindex(';', [country name], 1) > 1

		SELECT CASE WHEN sd.Region IS NULL THEN 'geo' ELSE 'region' END [Type], 
		sd.[Country Code] factID,
		CAST (NULL AS VARCHAR(200)) CountryID
		,LEFT([Country Code],3) CountryCode
		,LTRIM(Region) Region
		into #a
		FROM  SubNationalData sd
		--WHERE region IS NOT NULL
		GROUP BY sd.[Country Code],sd.[Country Name],sd.Region

		UPDATE a
		SET a.CountryID = g.id
		--select * 
		FROM #a a LEFT JOIN (SELECT name,region,id FROM DimGeo WHERE cat ='province') g
		ON ISNULL(a.Region,'') = g.name
		AND a.CountryCode = g.region
		WHERE g.id IS NOT NULL

		UPDATE a
		SET a.CountryID = lower(a.CountryCode+'-'+a.Region)
		--select * 
		FROM #a a LEFT JOIN (SELECT name,region,id FROM DimGeo WHERE cat ='province') g
		ON  ISNULL(a.Region,'') = g.name
		AND a.CountryCode = g.region
		WHERE g.id IS NULL

		MERGE DimGeo T
		USING (
			SELECT * FROM #A WHERE [type]='region'
		) S
		ON (T.id = S.CountryID AND T.cat = 'province')
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES('geo',LOWER(S.CountryID),s.Region,LOWER(S.CountryCode),'province',4);
		
		MERGE dbo.DimCountry T
		USING (
			SELECT * FROM #A WHERE [type]='region'
		) S
		ON (T.[Country Code] = S.CountryID)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES('province',LOWER(S.CountryID),S.Region,S.Region);

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'subnational'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'subnational'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator name],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, [indicator name] indicator
			,NULL ID 
			FROM dbo.SubNationalData 
			GROUP  BY [indicator name]
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);

		EXECUTE ChangeIndexAndConstraint 'DROP', 'subnational'

		DELETE FROM [dbo].[FactSubNational]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactSubNational] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code],
				 [SubGroup],
				 [Age],
				 [Gender],
				 [Value]) 
		SELECT	@versionNo
				,@dataSourceID
				,dc.id 
				,TRY_CONVERT(int, fd.period) 
				,di.id
				,s.ID
				,a.ID
				,g.ID
				,TRY_CONVERT(float, fd.[value]) 
		FROM (
				SELECT *,'N/A' SubGroup,'N/A' Age,'N/A' Gender
				FROM [dbo].[SubNationalData]
		) fd 
			LEFT JOIN (
				SELECT ID,[Indicator Name] 
				FROM   DimIndicators 
				WHERE  DataSourceID = @dataSourceID
			) di 
			ON fd.[indicator name] = di.[Indicator Name]
			LEFT JOIN (
				SELECT ID, A.factID
				FROM DimCountry c INNER JOIN #a A
				ON C.[Country Code] = A.CountryID
				WHERE c.[Type] = 'province'
			) dc 
			ON fd.[country code] = dc.factID
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
			WHERE  di.id IS NOT NULL 
			AND dc.id IS NOT NULL
		
		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		--EXECUTE [dbo].[PostProcessFactPivot] 'subnational', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'subnational'
		
END
GO