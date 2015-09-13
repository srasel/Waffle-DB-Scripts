IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessIMFData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ProcessIMFData]
GO

/****** Object:  StoredProcedure [dbo].[ProcessIMFData]    Script Date: 8/16/2015 9:25:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessIMFData]
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @dyn_sql NVARCHAR(max)
				,@baseFolderLocation VARCHAR(100)
				,@rawDataFileLocation VARCHAR(100)
	
		SET @baseFolderLocation = N'C:\Users\shahnewaz\Documents\GapMinder_DEV\imf\'
		SET @rawDataFileLocation = @baseFolderLocation + 'AllIMFData.txt';

		TRUNCATE TABLE dbo.IMFAllRawData
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.IMFAllRawData 
				FROM ''' + @rawDataFileLocation + ''' 
				WITH 
					( 
					fieldterminator = '','', 
					rowterminator = ''0x0a'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'imf'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'imf'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator
			,NULL ID 
			FROM dbo.IMFAllRawData
			GROUP BY Indicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);

		EXECUTE ChangeIndexAndConstraint 'DROP', 'imf'

		DELETE FROM [dbo].[FactIMF]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactIMF] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code], 
				 [Value]) 
		SELECT @versionNo,@dataSourceID, 
			dc.id, 
			TRY_CONVERT(int,LEFT(r.[time], 4)), 
			di.id, 
			CASE 
				WHEN r.indicator LIKE 'population%' THEN 
					 TRY_CONVERT(float,r.[value]) * 1000000
				ELSE TRY_CONVERT(float,r.[value])
			END 
		FROM dbo.IMFAllRawData r 
		LEFT JOIN (
				SELECT ID,[Indicator Name] 
				FROM   DimIndicators 
				WHERE  datasourceid = @dataSourceID
		) di 
		ON r.indicator = di.[Indicator Name] 
		LEFT JOIN (
				SELECT ID, [Country Code]
				FROM DimCountry
				WHERE [Type] = 'country'
		) dc
		ON r.geo = dc.[country code]
		WHERE di.id IS NOT NULL 
		AND dc.ID IS NOT NULL

		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		EXECUTE [dbo].[PostProcessFactPivot] 'imf',@versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'imf'

END

GO


