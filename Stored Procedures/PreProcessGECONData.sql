IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreProcessGECONData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PreProcessGECONData]
GO

/****** Object:  StoredProcedure [dbo].[PreProcessGECONData]    Script Date: 9/9/2015 12:17:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessGECONData]
AS
BEGIN
		SET NOCOUNT ON;
		SELECT TOP 2 * 
		FROM [Gapminder_RAW].[gecon].[Raw_Data]
		
		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = 14

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 14,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM [Gapminder_RAW].[gecon].[Raw_Data] 
		GROUP BY Indicator

		DELETE FROM FactFinal
		WHERE DataSourceID = 14
		
		INSERT INTO factfinal 
					([datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					[value]) 
			SELECT 14, c.ID, r.Period, i.ID, r.DataValue
			FROM ( 
					SELECT CASE Country
					WHEN 'KYRGYZSTAN' THEN 'Kyrgyz Republic'
					WHEN 'Slovakia' THEN 'Slovak Republic'
					WHEN 'CONGO' THEN 'Rep. Congo'
					WHEN 'SouthAfrica' THEN 'South Africa'
					WHEN 'Central Africa' THEN 'Central African Republic'
					WHEN 'Czech' THEN 'Czech Republic'
					WHEN 'UK' THEN 'United Kingdom'
					ELSE Country END
					Country
					,Period
					,Indicator
					,TRY_CONVERT(float,DataValue) DataValue
					FROM [Gapminder_RAW].[gecon].[Raw_Data]
					WHERE PERIOD <> ''
			)r 
			LEFT JOIN (
				SELECT * FROM DimIndicators WHERE DataSourceID = 14
			) i
				ON r.Indicator = i.[Indicator Name]
			LEFT JOIN (
				SELECT * FROM DimCountry WHERE [type] = 'country'
			)c
				ON r.Country = c.[Short Name]
			

END

GO


