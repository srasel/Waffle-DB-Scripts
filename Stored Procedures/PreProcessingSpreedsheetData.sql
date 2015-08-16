IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreProcessSpreedSheetData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PreProcessSpreedSheetData]
GO

/****** Object:  StoredProcedure [dbo].[PreProcessSpreedSheetData]    Script Date: 7/29/2015 3:50:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessSpreedSheetData]
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

		DROP INDEX myindex ON dbo.SpreedSheetFactData 
		
		TRUNCATE TABLE dbo.SpreedSheetFactData 
		INSERT INTO dbo.SpreedSheetFactData 
		SELECT [filelocation], 
				[pathid], 
				[country],
				TRY_CONVERT(int, [period]),
				TRY_CONVERT(float, [value])
		FROM   [dbo].[SpreedSheetAllRawData] 

		CREATE CLUSTERED INDEX myindex ON dbo.SpreedSheetFactData (pathid) 
END

GO

