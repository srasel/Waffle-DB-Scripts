IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessGECONData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ProcessGECONData]
GO

/****** Object:  StoredProcedure [dbo].[ProcessGECONData]    Script Date: 9/9/2015 12:17:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessGECONData]
AS
BEGIN
		SET NOCOUNT ON;
		
		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'gecon'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'gecon'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator
			,NULL ID 
			FROM [Gapminder_RAW].[gecon].[Raw_Data] 
			GROUP BY Indicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);
		
		EXECUTE ChangeIndexAndConstraint 'DROP', 'gecon'

		DELETE FROM [dbo].[FactGECON]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactGECON] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code], 
				 [Value]) 
		SELECT @versionNo,@dataSourceID, c.ID, r.Period, i.ID, r.DataValue
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
			SELECT ID,[Indicator Name] 
			FROM   DimIndicators 
			WHERE  datasourceid = @dataSourceID
		) i
			ON r.Indicator = i.[Indicator Name]
		LEFT JOIN (
			SELECT ID, [Short Name]
			FROM DimCountry
			WHERE [Type] = 'country'
		)c
			ON r.Country = c.[Short Name]

		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		--EXECUTE [dbo].[PostProcessFactPivot] 'gecon', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'gecon'
		
END

GO


