IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PostProcessFactPivot]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PostProcessFactPivot]
GO

/****** Object:  StoredProcedure [dbo].[PostProcessFactPivot]    Script Date: 9/12/2015 4:58:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[PostProcessFactPivot]
	@dataSource VARCHAR(100) = 'SpreedSheet',
	@versionNo VARCHAR(10) = '1'
AS
BEGIN

	DECLARE @dataSourceID VARCHAR(10)
			,@factTableName VARCHAR(100)
			,@factTablePivotedName VARCHAR(100)
			,@dropT VARCHAR(100)

		SELECT @dataSourceID = ID
			   ,@factTableName = FactTableName
			   ,@factTablePivotedName = FactTablePivotedName
		FROM DimDataSource
		WHERE DataSource = @dataSource

		DECLARE @indicators NVARCHAR(MAX)
				,@dyn_sql NVARCHAR(MAX)

		SELECT @indicators = STUFF((
		SELECT (',[' + I.IndicatorCode + ']' ) AS [text()]
		FROM UtilityCommonlyUsedIndicators I
		WHERE DataSourceID = @dataSourceID
		FOR XML PATH ('')),1,1,'')

		SET @dyn_sql = N'
			DELETE FROM ' + @factTablePivotedName + ' WHERE VersionID = ' + @versionNo + '
		'
		EXECUTE SP_EXECUTESQL @dyn_sql
		
		--SET @dropT = 'drop TABLE [' + @factTablePivotedName + ']'
		--IF OBJECT_ID('' + @factTablePivotedName + '', 'U') IS NOT NULL
		--		EXEC(@dropT)

		SET @dyn_sql = N'
			INSERT INTO ' + @factTablePivotedName + ' 
			([VersionID],DataSourceID, [Country Code], Period,SubGroup,Age,Gender,'+ @indicators + ')
			select [VersionID],DataSourceID, [Country Code], Period,SubGroup,Age,Gender,'+ @indicators + '
			from (
				select F.[VersionID],f.DataSourceID, f.[Country Code], f.Period,f.SubGroup,
				f.Age,f.Gender,i.[Indicator Code],f.Value
				from ' + @factTableName + ' f
				left join (
						select di.ID,di.[Indicator Code] 
						from DimIndicators di 
						LEFT JOIN UtilityCommonlyUsedIndicators ci
						ON di.[Indicator Code] = ci.IndicatorCode
						WHERE di.DataSourceID = ' + @dataSourceID + '
						AND ci.DataSourceID = ' + @dataSourceID + '
						AND ci.ID IS NOT NULL
				) i
				ON f.[Indicator Code] = i.ID
			)A
			pivot(
				sum(value)
				for [Indicator Code] in ('+ @indicators + ')
			) as pvt
		'
		EXECUTE SP_EXECUTESQL @dyn_sql

END

GO


