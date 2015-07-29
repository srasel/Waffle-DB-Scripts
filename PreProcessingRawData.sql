/****** Object:  StoredProcedure [dbo].[PreProcessRawData]    Script Date: 7/29/2015 3:44:54 PM ******/
DROP PROCEDURE [dbo].[PreProcessRawData]
GO

/****** Object:  StoredProcedure [dbo].[PreProcessRawData]    Script Date: 7/29/2015 3:44:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Preprocessrawdata] 
AS 
  BEGIN 
      -- SET NOCOUNT ON added to prevent extra result sets from 
      -- interfering with SELECT statements. 
      SET nocount ON; 

      TRUNCATE TABLE dbo.allrawdata 

      BULK INSERT dbo.allrawdata 
        FROM 'C:\Users\shahnewaz\Documents\GapMinder\allRawData.txt' 
        WITH 
          ( 
            fieldterminator = ',', 
            rowterminator = '\n' 
          ) 
      DROP TABLE subnationaldata 

      CREATE TABLE subnationaldata 
        ( 
           [indicator name] VARCHAR(max), 
           [indicator code] VARCHAR(max), 
           [country name]   VARCHAR(max), 
           [country code]   VARCHAR(max), 
           [period]         INT, 
           [value]          FLOAT 
        ) 

      TRUNCATE TABLE dbo.subnationaldata 

      BULK INSERT dbo.subnationaldata 
        FROM 'C:\Users\shahnewaz\Documents\GapMinder\allSubnationalData.txt' 
        WITH 
          ( 
            fieldterminator = ',', 
            rowterminator = '\n' 
          ) 
      ALTER TABLE dbo.subnationaldata 
        ADD [region] VARCHAR(max) 

      UPDATE subnationaldata 
      SET    [region] = Replace(Substring([country name], 
                                Charindex(';', [country name], 1) + 
                                       1, Len( 
                                [country name])), '"', ''), 
             [country name] = Replace(Substring([country name], 1, 
                                      Charindex(';', [country name], 1) - 1), 
                              '"' 
                              , '') 
      WHERE  Charindex(';', [country name], 1) > 1 

      DROP TABLE subnationalindicator 

      CREATE TABLE [dbo].[subnationalindicator] 
        ( 
           [id]        INT NULL, 
           [indicator] [VARCHAR](max) NULL 
        ) 
      ON [PRIMARY] 
      textimage_on [PRIMARY] 

      INSERT INTO subnationalindicator 
      SELECT Row_number() OVER (ORDER BY [indicator name]) 
             + 5000           ID, 
             [indicator name] indicator 
      FROM   (SELECT [indicator name] 
              FROM   subnationaldata 
              GROUP  BY [indicator name])A 

      TRUNCATE TABLE wdi_country 

      BULK INSERT wdi_country 
        FROM 
  'C:\Users\shahnewaz\Documents\GapMinder\WDI Data\Data\WDI_Country.csv' 
        WITH 
          ( 
            fieldterminator = ',', 
            rowterminator = '\n' 
          ) 
      TRUNCATE TABLE dbo.wdi_data 

      BULK INSERT dbo.wdi_data 
        FROM 'C:\Users\shahnewaz\Documents\GapMinder\allWDIRawData.txt' 
        WITH 
          ( 
            fieldterminator = ',', 
            rowterminator = '\n' 
          ) 
      TRUNCATE TABLE dbo.configtable 

      BULK INSERT dbo.configtable 
        FROM 'C:\Users\shahnewaz\Documents\GapMinder\config.txt' 
        WITH 
          ( 
            fieldterminator = '\t', 
            rowterminator = '\n' 
          ) 
      TRUNCATE TABLE dbo.indicator 

      BULK INSERT dbo.indicator 
        FROM 'C:\Users\shahnewaz\Documents\GapMinder\indicators.txt' 
        WITH 
          ( 
            fieldterminator = ',', 
            rowterminator = '\n' 
          ) 
      DELETE a 
      FROM   (SELECT *, 
                     Row_number() 
                       OVER( 
                         partition BY indicator 
                         ORDER BY indicator) rnk 
              FROM   dbo.indicator)A 
      WHERE  rnk > 1 

      IF Object_id('dbo.WDI_Indicator', 'U') IS NOT NULL 
        DROP TABLE wdi_indicator 

      SELECT a.indicator 
      INTO   wdi_indicator 
      FROM   (SELECT [indicator name] indicator 
              FROM   wdi_data 
              GROUP  BY [indicator name])A 

      --left join dbo.Indicator id 
      --on a.indicator = id.indicator 
      --where id.indicator is null 
      --drop table #A 
      SELECT ( Row_number() 
                 OVER( 
                   ORDER BY [indicator]) ) + 1000 ID, 
             [indicator] 
      INTO   #a 
      FROM   wdi_indicator 

      IF Object_id('dbo.WDI_Indicator', 'U') IS NOT NULL 
        DROP TABLE wdi_indicator 

      SELECT a.* 
      INTO   wdi_indicator 
      FROM   #a a 

      --left join dbo.Indicator i 
      --on a.[indicator] = i.indicator 
      --where i.indicator is null 
      ALTER TABLE wdi_indicator 
        ALTER COLUMN id INT NOT NULL 

      ALTER TABLE wdi_indicator 
        ADD PRIMARY KEY (id) 

      --select * from WDI_Indicator 
      UPDATE [dbo].[configtable] 
      SET    [menu level1] = 'N/A' 
      WHERE  [menu level1] IS NULL 

      UPDATE [dbo].[configtable] 
      SET    [menu level2] = 'N/A' 
      WHERE  [menu level2] IS NULL 

      UPDATE [dbo].[configtable] 
      SET    [indicator url] = 'N/A' 
      WHERE  [indicator url] IS NULL 

      UPDATE [dbo].[configtable] 
      SET    [download] = 'N/A' 
      WHERE  [download] IS NULL 

      UPDATE [dbo].[configtable] 
      SET    [id] = 'N/A' 
      WHERE  [id] IS NULL 

      UPDATE [dbo].[configtable] 
      SET    [scale] = 'N/A' 
      WHERE  [scale] IS NULL 

      DROP INDEX myindex ON factdata 

      --truncate table FactData 
      --insert into FactData 
      --SELECT [fileLocation] 
      --    ,[pathID] 
      --    ,[country] 
      --    ,[period] 
      --    ,case when ISNUMERIC([value]) = 1 then cast([value] as float) else 0.00 end 
      --  FROM [dbo].[allRawData] 
      TRUNCATE TABLE factdata 

      INSERT INTO factdata 
      SELECT [filelocation], 
             [pathid], 
             [country], 
             CASE 
               WHEN Isnumeric([period]) = 1 THEN [period] 
               ELSE NULL 
             END, 
             CASE 
               WHEN Isnumeric([value]) = 1 THEN Cast([value] AS FLOAT) 
               ELSE 0.00 
             END 
      FROM   [dbo].[allrawdata] 

      CREATE CLUSTERED INDEX myindex 
        ON factdata (pathid) 

      DROP INDEX myindexwdi ON dbo.factwdidata 

      TRUNCATE TABLE dbo.factwdidata 

      INSERT INTO dbo.factwdidata 
      SELECT wi.id, 
             wd.[country name], 
             CASE 
               WHEN Isnumeric([period]) = 1 THEN [period] 
               ELSE NULL 
             END, 
             CASE 
               WHEN Isnumeric([value]) = 1 THEN Cast([value] AS FLOAT) 
               ELSE 0.00 
             END 
      FROM   dbo.wdi_data wd 
             LEFT JOIN wdi_indicator wi 
                    ON wd.[indicator name] = wi.[indicator] 

      CREATE CLUSTERED INDEX myindexwdi 
        ON dbo.factwdidata (pathid) 

      TRUNCATE TABLE [dbo].[imfrawfile] 

      BULK INSERT [dbo].[imfrawfile] 
        FROM 'C:\Users\shahnewaz\Documents\GapMinder\allIMFData.txt' 
        WITH 
          ( 
            fieldterminator = ',', 
            rowterminator = '0x0a' 
          ) 
      INSERT INTO dimindicators 
                  (datasourceid, 
                   [indicator code], 
                   [indicator name], 
                   tempid) 
      SELECT 4, 
             indicator, 
             indicator, 
             NULL 
      FROM   imfrawfile 
      GROUP  BY indicator 

      INSERT INTO factfinal 
                  (datasourceid, 
                   [country code], 
                   period, 
                   [indicator code], 
                   value) 
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

      TRUNCATE TABLE [dbo].[incomemountain] 

      BULK INSERT [dbo].[incomemountain] 
        FROM 'C:\Users\shahnewaz\Documents\GapMinder\mountain.txt' 
        WITH 
          ( 
            fieldterminator = ';', 
            rowterminator = '0x0a' 
          ) 
      UPDATE incomemountain 
      SET    mountainshape = Replace(mountainshape, Char(13), '') 
      WHERE  RIGHT(mountainshape, 1) = Char(13) 
  END 



GO


