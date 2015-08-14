/****** Object:  StoredProcedure [dbo].[ProcessFinalTables]    Script Date: 7/29/2015 4:40:55 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessFinalTables]') AND type in (N'P', N'PC'))
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

		UNION ALL
		
		SELECT 4, 
				indicator, 
				indicator, 
				NULL 
		FROM   imfrawfile 
		GROUP  BY indicator

		UNION ALL

		SELECT 6, 
				Indicator,
				Indicator,
				NULL
		FROM AllDevInfoRawData
		GROUP BY Indicator

		UPDATE [dbo].[DimIndicators]
		SET [Indicator Code] = LEFT(LOWER(REPLACE([Indicator Name],' ', '_')),99)

		INSERT INTO DimSubGroup (SubGroup)
		SELECT SUBGROUP
		FROM AllDevInfoRawData
		GROUP BY Subgroup

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

		UNION ALL

		SELECT 4, 
             dc.id, 
             LEFT(r.[time], 4), 
             di.id, 
             CASE 
               WHEN r.indicator = 'pop' THEN r.[value] * 1000000 
               ELSE r.[value] 
             END 
		  FROM   imfrawfile r 
				 LEFT JOIN (SELECT * 
							FROM   dimindicators 
							WHERE  datasourceid = 4) di 
						ON r.indicator = di.[indicator code] 
				 LEFT JOIN dimcountry dc 
						ON r.geo = dc.[country code] 

		
			INSERT INTO factfinal 
					([datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					SubGroup,
					[value]) 
			SELECT 6,c.ID, r.Year, i.ID, s.ID, r.DataValue
			FROM AllDevInfoRawData r 
			LEFT JOIN (
				SELECT * FROM DimIndicators WHERE DataSourceID = 6
			) i
				on r.Indicator = i.[Indicator Name]
			LEFT JOIN DimSubGroup s
				on r.Subgroup = s.SubGroup
			LEFT JOIN DimCountry c
				on r.AreaCode = c.[Country Code]
			where i.id is not null
			and c.id is not null


		CREATE NONCLUSTERED INDEX ix_fact 
		ON factfinal ([datasourceid], [country code], [period], [indicator code],[SubGroup] ) 
		INCLUDE([Value])
		
		
		/*
			Fixed pre-processing
		*/
		update DimGeo
		set cat = replace(replace(cat,'["',''),'"]','')

		update DimGeo
		set region = 'world'
		where region is null
		and cat in ('region')

		update dc
		set dc.[Country Code] = dg.id
		from DimCountry dc inner join DimGeo dg
		on dc.[Short Name] = dg.name
		
END
GO


