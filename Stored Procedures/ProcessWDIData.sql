/****** Object:  StoredProcedure [dbo].[ProcessWDIData]    Script Date: 07/31/2015 14:46:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessWDIData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ProcessWDIData]
GO

/****** Object:  StoredProcedure [dbo].[ProcessWDIData]    Script Date: 07/31/2015 14:46:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessWDIData]
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @dyn_sql NVARCHAR(max)
				,@baseFolderLocation VARCHAR(100)
				,@rawDataFileLocation VARCHAR(100)
				,@wdiCountryData VARCHAR(100)
	
		SET @baseFolderLocation = N'C:\Users\shahnewaz\Documents\GapMinder_DEV\wdi\'
		SET @rawDataFileLocation = @baseFolderLocation + 'AllWDIRawData.txt';
		SET @wdiCountryData = @baseFolderLocation + 'Data\WDI_Country.csv';
		
		TRUNCATE TABLE dbo.WDI_Country
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.WDI_Country
				FROM ''' + @wdiCountryData + ''' 
				WITH 
					(
					FIRSTROW = 2,
					FIELDTERMINATOR = '','', 
					ROWTERMINATOR = ''\n'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql
		
		TRUNCATE TABLE dbo.WDI_Data
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.WDI_Data
				FROM ''' + @rawDataFileLocation + ''' 
				WITH 
					( 
					fieldterminator = '','', 
					rowterminator = ''\n'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql
		
		TRUNCATE TABLE dbo.WDI_Indicator
		INSERT INTO dbo.WDI_Indicator(ID,indicator,indicatorCode)
		SELECT ROW_NUMBER() over(order by A.indicator) ID, A.indicator, A.[Indicator Code]
		FROM   (
				SELECT [indicator name] indicator,[Indicator Code]
				FROM   wdi_data 
				GROUP  BY [indicator name],[Indicator Code]
		)A

		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY [IndicatorCode] ORDER BY [IndicatorCode]) RNK
			FROM dbo.WDI_Indicator
		)
		DELETE FROM CTE WHERE RNK > 1

		UPDATE dbo.WDI_Indicator
		SET indicator = REPLACE(indicator,'"','')
		
		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'wdi'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'wdi'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,[IndicatorCode]
			, indicator --LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) 
			,ID 
			FROM dbo.WDI_Indicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator AND T.[Indicator Code] = S.indicatorCode)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[IndicatorCode],S.indicator,S.ID);

		EXECUTE ChangeIndexAndConstraint 'DROP', 'wdi'

		DELETE FROM [dbo].[FactWDI]
		WHERE VersionID = @versionNo
		
		INSERT INTO [dbo].[FactWDI] 
		(
			[VersionID],
			[DataSourceID], 
			[Country Code], 
			[Period], 
			[Indicator Code],
			[SubGroup],
			[Age],
			[Gender], 
			[Value]
		)
		SELECT 
			@versionNo,@dataSourceID, 
			dc.id, 
			TRY_CONVERT(int, fd.period), 
			di.id,
			s.ID,
			a.ID,
			g.ID ,
			TRY_CONVERT(float, fd.[value]) 
		FROM (SELECT *,'N/A' SubGroup,'N/A' Age,'N/A' Gender FROM dbo.WDI_Data) fd 
			LEFT JOIN (
				SELECT ID,[Indicator Code] 
				FROM   DimIndicators 
				WHERE  datasourceid = @dataSourceID
			) di 
			ON fd.[Indicator Code] = di.[Indicator Code]
			LEFT JOIN (
				SELECT ID,[Short Name]
				FROM DimCountry
				WHERE [Type] = 'country'
			) dc 
			ON fd.[country name] = dc.[short name] 
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
		
		EXECUTE [dbo].[PostProcessFactPivot] 'wdi', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'wdi'
		
END

GO


