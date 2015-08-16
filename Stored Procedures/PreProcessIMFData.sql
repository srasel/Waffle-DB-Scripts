IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreProcessIMFData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PreProcessIMFData]
GO

/****** Object:  StoredProcedure [dbo].[PreProcessIMFData]    Script Date: 8/16/2015 9:25:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessIMFData]
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

		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = 4

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 4,indicator, indicator 
		FROM dbo.IMFAllRawData
		GROUP BY Indicator

		--DROP INDEX ix_fact ON FactFinal

		--DELETE FROM FactFinal
		--WHERE DataSourceID = 4

		

		--CREATE NONCLUSTERED INDEX ix_fact 
		--ON dbo.FactFinal ([datasourceid], [country code], [period], [indicator code],[SubGroup] ) 
		--INCLUDE([Value])

END

GO


