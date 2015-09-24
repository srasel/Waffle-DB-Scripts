IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetDimensionDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetDimensionDetails]
GO

/****** Object:  StoredProcedure [dbo].[GetDimensionDetails]    Script Date: 9/14/2015 4:43:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[GetDimensionDetails]
@xml xml
as
begin
		--select [Type] Geo, [Country Code] Name, ID [Time], ID [Value] from DimCountry
		declare @XmlStr xml
		set @XmlStr = @xml
	
		create table #select  (name varchar(100))
		create table #where (name varchar(100))
	
		create table #from (tab varchar(100))

		declare @dyn_sql nvarchar(max)

		insert into #select
		select x.col.value('.', 'varchar(100)') AS [text()]
		FROM @XmlStr.nodes('//root//query//SELECT') x(col)
	
		insert into #where
		select x.col.value('.', 'varchar(100)') AS [text()]
		FROM @XmlStr.nodes('//root//query//WHERE//dimension') x(col)
	
		if(@@ROWCOUNT = 0 or (select top 1 name from #where)='*')
		begin
			truncate table #where
			insert into #where
			select 'dimgeo'
		end
	
		insert into #from
		select x.col.value('.', 'varchar(100)') AS [text()]
		FROM @XmlStr.nodes('//root//query//FROM') x(col)

		update #from
		set tab = 'spreedsheet'
		where tab = 'humnum'

		CREATE TABLE #DIMCOL (name VARCHAR(50), dim VARCHAR(20), seq int)
		INSERT INTO #DIMCOL
		SELECT '[Indicator Code] [-t-ind]', 'DimIndicators',1
		UNION ALL
		SELECT '[Indicator Name] [-t-name]', 'DimIndicators',2
		UNION ALL
		SELECT '[Unit] [-t-unit]', 'DimIndicators',3
		UNION ALL
		SELECT '[ID] [id]', 'DimAge',1
		UNION ALL
		SELECT '[age] [value]', 'DimAge',2
		UNION ALL
		SELECT '[ID] [id]', 'DimGender',1
		UNION ALL
		SELECT '[gender] [value]', 'DimGender',2
		UNION ALL
		SELECT '[ID] [id]', 'DimSubGroup',1
		UNION ALL
		SELECT '[subgroup] [value]', 'DimSubGroup',2

		DECLARE @cols NVARCHAR(MAX)
		SELECT @cols = STUFF((
		SELECT (',' + '' + s.name + '') AS [text()]
		FROM #DIMCOL s INNER JOIN #WHERE W
		ON s.dim = w.name
		ORDER BY S.seq
		FOR XML PATH ('')),1,1,'')

		DECLARE @dimName varchar(30)
		SELECT @dimName = name FROM #where
		
		--SELECT @xml [name]

		SET @dyn_sql = N'
			SELECT ' + @cols + ' 
			FROM ' +  @dimName + '
			WHERE DataSourceID = (SELECT top 1 ID FROM DimDataSource 
			INNER JOIN #FROM ON DataSource = tab)
		'

		IF @dimName = 'DimGeo' 
		BEGIN
			SET @dyn_sql = N'
				SELECT id, name, region parent, cat
				FROM DimGeo
				where lev < 4
				order by lev

			'
		END

		IF(@dimName='DimIndicators' AND (SELECT tab from #from)='spreedsheet')
		BEGIN
			SET @dyn_sql = N'
				select di.[Indicator Code] [-t-ind], di.[Indicator Name] [-t-name], null [-t-type]
				,ISNULL(ct.[Source name],'''') [-t-source], ISNULL(ct.[Source link],'''') [-t-url],ISNULL(ct.[Scale Type],'''') [-t-scale]
				from DimIndicators di left join [dbo].[DimIndicatorsMetaData] ct
				on di.TempID = ct.ID
				where di.DataSourceID = 1
				and di.[Indicator Code] <> ''N/A''
				order by len(di.[Indicator Code])

			'
			print @dyn_sql
		END

		EXECUTE sp_executesql @dyn_sql

	
end

GO

EXECUTE GetDimensionDetails
'
<root><query><SELECT>*</SELECT><WHERE><dimension>dimindicators</dimension></WHERE>
<FROM>spreedsheet</FROM></query><lang>en</lang></root>
'


