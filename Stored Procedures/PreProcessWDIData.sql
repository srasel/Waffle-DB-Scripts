/****** Object:  StoredProcedure [dbo].[PreProcessWDIData]    Script Date: 07/31/2015 14:46:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreProcessWDIData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PreProcessWDIData]
GO

/****** Object:  StoredProcedure [dbo].[PreProcessWDIData]    Script Date: 07/31/2015 14:46:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessWDIData]
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
		INSERT INTO dbo.WDI_Indicator
		SELECT ROW_NUMBER() over(order by A.indicator) ID, A.indicator 
		FROM   (
				SELECT [indicator name] indicator 
				FROM   wdi_data 
				GROUP  BY [indicator name]
		)A
		
		DROP INDEX myindexwdi ON dbo.WDI_FactData
		
		TRUNCATE TABLE dbo.WDI_FactData

		INSERT INTO dbo.WDI_FactData
		SELECT	wi.id 
				,wd.[country name]
				,TRY_CONVERT(int, [period])
				,TRY_CONVERT(float, [value])
		FROM	dbo.WDI_Data wd LEFT JOIN dbo.WDI_Indicator wi 
				ON wd.[indicator name] = wi.[indicator] 

		CREATE CLUSTERED INDEX myindexwdi 
		ON dbo.WDI_FactData (pathid)
		
END

GO


