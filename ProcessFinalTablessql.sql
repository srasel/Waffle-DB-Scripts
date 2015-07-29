/****** Object:  StoredProcedure [dbo].[ProcessFinalTables]    Script Date: 7/29/2015 4:40:55 PM ******/
DROP PROCEDURE [dbo].[ProcessFinalTables]
GO

/****** Object:  StoredProcedure [dbo].[ProcessFinalTables]    Script Date: 7/29/2015 4:40:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessFinalTables]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	TRUNCATE TABLE dbo.DimCountry

	INSERT INTO dbo.DimCountry([Type],[Country Code],[Short Name], [Country Name])
		SELECT	'geo', [Country Code],[Short Name], [Long Name] 
		FROM	dbo.WDI_Country
		GROUP BY [Country Code],[Short Name], [Long Name]

	INSERT INTO dbo.DimCountry([Type],[Country Code],[Short Name], [Country Name])
	SELECT a.*
	FROM (
		SELECT CASE WHEN sd.Region is null THEN 'geo' ELSE 'region' END [Type], 
				sd.[Country Code],
				CASE WHEN sd.Region is null THEN sd.[Country Name] ELSE sd.[Country Name]+ISNULL(sd.Region,sd.[Country Code]) END [Short Name]
				,CASE WHEN sd.Region is null THEN sd.[Country Name] ELSE sd.[Country Name]+ISNULL(sd.Region,sd.[Country Code]) END [Country Name]
		FROM  SubNationalData sd
		WHERE region IS NOT NULL
		GROUP BY sd.[Country Code],sd.[Country Name],sd.Region              
	)A LEFT JOIN DimCountry d 
	ON a.[Country Code] = d.[Country Code]
	WHERE d.[Country Code] IS NULL

	INSERT INTO dbo.DimCountry([Type],[Country Code],[Short Name], [Country Name])
	SELECT 'geo',a.country,a.country,a.country
	FROM (
		SELECT  country
		FROM FactData
		GROUP BY country
	)a LEFT JOIN DimCountry d
	ON  a.country = d.[Short Name]
	OR a.country = d.[Country Code]
	WHERE d.[Short Name] IS NULL

	
	TRUNCATE TABLE [dbo].[DimIndicators]

	INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name], TempID)
	SELECT 1,'N/A', indicator,ID 
	FROM Indicator

	UNION ALL

	SELECT 2, 'N/A', indicator, ID 
	FROM WDI_Indicator

	UNION ALL

	SELECT 3, 'N/A' [Indicator Code], id.indicator, id.ID 
	FROM dbo.SubNationalIndicator id

	UPDATE [dbo].[DimIndicators]
	SET [Indicator Code] = LEFT(LOWER(REPLACE([Indicator Name],' ', '_')),99)

	DROP INDEX ix_fact ON FactFinal

    TRUNCATE TABLE FactFinal
	INSERT INTO factfinal 
            ([datasourceid], 
             [country code], 
             period, 
             [indicator code], 
             [value]) 
	SELECT 1, 
		   dc.id, 
		   fd.period, 
		   di.id, 
		   fd.value 
	FROM   FactData fd 
		   LEFT JOIN (SELECT * 
					  FROM   DimIndicators 
					  WHERE  datasourceid = 1) di 
				  ON fd.pathid = di.tempid 
		   LEFT JOIN DimCountry dc 
				  ON fd.country = dc.[short name] 
	WHERE  di.id IS NOT NULL 
		   AND dc.id IS NOT NULL 
	UNION ALL 
	--insert into FactFinal ([Country Code],Period,[Indicator Code],[Value]) 
	SELECT 2, 
		   dc.id, 
		   fd.period, 
		   di.id, 
		   fd.value 
	FROM   factwdidata fd 
		   LEFT JOIN (SELECT * 
					  FROM   dimindicators 
					  WHERE  datasourceid = 2) di 
				  ON fd.pathid = di.tempid 
		   LEFT JOIN dimcountry dc 
				  ON fd.country = dc.[short name] 
	WHERE  di.id IS NOT NULL 
		   AND dc.id IS NOT NULL 
	--insert into FactFinal ([DataSourceID],[Country Code],Period,[Indicator Code],[Value]) 
	UNION ALL 
	SELECT 3, 
		   dc.id, 
		   fd.period, 
		   di.id, 
		   fd.value 
	FROM   subnationaldata fd 
		   LEFT JOIN (SELECT * 
					  FROM   dimindicators 
					  WHERE  datasourceid = 3) di 
				  ON fd.[indicator name] = di.[indicator name] 
		   LEFT JOIN dimcountry dc 
				  ON fd.[country code] = dc.[country code] 
	WHERE  di.id IS NOT NULL 
		   AND dc.id IS NOT NULL 

	CREATE NONCLUSTERED INDEX ix_fact 
	  ON factfinal ([datasourceid], [country code], [period], [indicator code]) 
	  include([Value]) 

END
GO


