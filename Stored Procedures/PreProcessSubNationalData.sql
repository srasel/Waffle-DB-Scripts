IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreProcessSubNationalData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PreProcessSubNationalData]
GO

/****** Object:  StoredProcedure [dbo].[PreProcessSubNationalData]    Script Date: 08/01/2015 23:56:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PreProcessSubNationalData]
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

		DROP TABLE [dbo].[SubNationalIndicator] 

		CREATE TABLE [dbo].[SubNationalIndicator]
		( 
			[id]        INT NULL, 
			[indicator] [VARCHAR](max) NULL 
		) 
		ON [PRIMARY] 
		textimage_on [PRIMARY] 

		SET @maxRowCount = (SELECT MAX(ID) FROM DimIndicators)

		INSERT INTO [dbo].[SubNationalIndicator] 
		SELECT Row_number() OVER (ORDER BY [indicator name]) 
				+ @maxRowCount           ID, 
				[indicator name] indicator 
		FROM   (SELECT [indicator name] 
				FROM   dbo.SubNationalData 
				GROUP  BY [indicator name])A 

END
GO