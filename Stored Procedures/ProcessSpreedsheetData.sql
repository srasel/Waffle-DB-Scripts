IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessSpreedSheetData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ProcessSpreedSheetData]
GO

/****** Object:  StoredProcedure [dbo].[ProcessSpreedSheetData]    Script Date: 7/29/2015 3:50:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessSpreedSheetData]
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @dyn_sql NVARCHAR(max)
				,@baseFolderLocation VARCHAR(100)
				,@rawDataFileLocation VARCHAR(100)
				,@configFileLocation VARCHAR(100)
				,@indicatorFileLocation VARCHAR(100)
	
		SET @baseFolderLocation = N'C:\Users\shahnewaz\Documents\GapMinder_DEV\spreedsheet\'
		SET @rawDataFileLocation = @baseFolderLocation + 'AllRawData.txt';
		SET @configFileLocation = @baseFolderLocation + 'Config.txt';
		SET @indicatorFileLocation = @baseFolderLocation + 'Indicators.txt';

		TRUNCATE TABLE dbo.configTable 
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.configTable 
				FROM ''' + @configFileLocation + ''' 
				WITH 
					( 
					fieldterminator = ''\t'', 
					rowterminator = ''\n'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql

		--select * from WDI_Indicator 
		UPDATE [dbo].[configTable] 
		SET    [menu level1] = ISNULL([menu level1],'N/A')
			,[menu level2] = ISNULL([menu level2],'N/A')
			,[indicator url] = ISNULL([indicator url],'N/A')
			,[download] = ISNULL([download],'N/A')
			,[id] = ISNULL([id],'N/A')
			,[scale] =ISNULL([scale],'N/A')

		TRUNCATE TABLE dbo.SpreedSheetIndicator 
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.SpreedSheetIndicator 
				FROM ''' + @indicatorFileLocation + ''' 
				WITH 
					( 
					fieldterminator = '','', 
					rowterminator = ''\n'' 
					)
			'
		EXECUTE sp_executesql @dyn_sql 

		DELETE a 
		FROM   (SELECT *, 
						Row_number() 
						OVER( 
							partition BY indicator 
							ORDER BY indicator) rnk 
				FROM   dbo.SpreedSheetIndicator)A 
		WHERE  rnk > 1

		TRUNCATE TABLE dbo.SpreedSheetAllRawData;
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.SpreedSheetAllRawData 
				FROM  '''  + @rawDataFileLocation + '''
				WITH 
					( 
					fieldterminator = '','', 
					rowterminator = ''\n'' 
					)
			'
		EXECUTE sp_executesql @dyn_sql

		UPDATE dbo.SpreedSheetIndicator
		SET indicator = REPLACE(indicator,'"','')

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

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator
			,ID 
			FROM dbo.SpreedSheetIndicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);
		
		EXECUTE ChangeIndexAndConstraint 'DROP', 'spreedsheet'

		DELETE FROM [dbo].[FactSpreedSheet]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactSpreedSheet] 
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
				FROM [dbo].[SpreedSheetAllRawData]
		) fd 
			LEFT JOIN (
				SELECT ID,TempID 
				FROM   DimIndicators 
				WHERE  DataSourceID = @dataSourceID
			) di 
			ON fd.pathid = di.tempid 
			LEFT JOIN (
				SELECT ID, [Short Name]
				FROM DimCountry
				WHERE [Type] = 'country'
			) dc 
			ON fd.country = dc.[short name] 
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
		
		EXECUTE ProcessAdhocData

		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		EXECUTE [dbo].[PostProcessFactPivot] 'spreedsheet', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'spreedsheet'


		/*
			DROP TABLE [dbo].[DimIndicatorsMetaData]
			CREATE TABLE [dbo].[DimIndicatorsMetaData](
				[ID] [varchar](50) NULL,
				[Name] [varchar](200) NULL,
				[Val] [varchar](500) NULL
			) ON [PRIMARY]

			DECLARE @dyn_sql NVARCHAR(max)
			SET @dyn_sql = 
				N'
					BULK INSERT [dbo].[DimIndicatorsMetaData]
					FROM ''C:\Users\shahnewaz\Documents\GapMinder_DEV\spreedsheet\Settings.txt'' 
					WITH 
						( 
						fieldterminator = '','', 
						rowterminator = ''\n'' 
						) 
				'
			EXECUTE sp_executesql @dyn_sql

			UPDATE DimIndicatorsMetaData
			SET NAME = 'Scale type'
			WHERE NAME = 'Scale type (log or lin)'

			UPDATE MD
			SET Name = CASE  WHEN VAL = 'LOG' THEN 'Scale type'
								WHEN VAL LIKE 'http://' THEN 'Source link'
								WHEN VAL = '' THEN ''
							ELSE NAME END
			FROM [dbo].[DimIndicatorsMetaData] MD
			WHERE MD.ID IN (
				select ID from [dbo].[DimIndicatorsMetaData]
				where name not in ('source name','source link','scale type')
				GROUP BY ID
				HAVING COUNT(*)=3
			)

			UPDATE MD
			SET Name = CASE WHEN VAL LIKE 'http://' THEN 'Source link'
							ELSE 'Source name' END
			FROM [dbo].[DimIndicatorsMetaData] MD
			WHERE MD.ID IN (
				select ID from [dbo].[DimIndicatorsMetaData]
				where name not in ('source name','source link','scale type')
				GROUP BY ID
				HAVING COUNT(*)= 2
			)

			SELECT * INTO #A
			FROM [dbo].[DimIndicatorsMetaData]

			DROP TABLE [dbo].[DimIndicatorsMetaData]
			select *
			INTO [dbo].[DimIndicatorsMetaData]
			from (
				select * from #A

			)A
			pivot(
				max(val)
				for [name] in ([Source name],[Source link],[Scale Type])
			) as pvt




		*/

END

GO

