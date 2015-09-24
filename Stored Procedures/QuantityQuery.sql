IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[QuantityQuery]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[QuantityQuery]
GO

/****** Object:  StoredProcedure [dbo].[QuantityQuery]    Script Date: 9/14/2015 4:41:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[QuantityQuery]
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
		FROM @XmlStr.nodes('//root//query//WHERE//quantity') x(col)
	
		if(@@ROWCOUNT = 0 or (select top 1 name from #where)='*')
		begin
			truncate table #where
			insert into #where
			select ID from DimIndicators
		end
	
		insert into #from
		select x.col.value('.', 'varchar(100)') AS [text()]
		FROM @XmlStr.nodes('//root//query//FROM') x(col)

		update #from
		set tab = 'spreedsheet'
		where tab = 'humnum'

		IF(SELECT tab from #from) = 'spreedsheet'
		BEGIN
			
			select di.[Indicator Code] [-t-ind], di.[Indicator Name] [-t-name], null [-t-type]
				,ISNULL(ct.[Source name],'') [-t-source], ISNULL(ct.[Source link],'') [-t-url],ISNULL(ct.[Scale Type],'') [-t-scale]
			from DimIndicators di left join [dbo].[DimIndicatorsMetaData] ct
			on di.TempID = ct.ID
			left join #where w
			on di.ID = w.name
			where w.name is not null
			and di.DataSourceID = ( select top 1 ID from DimDataSource inner join #from on DataSource = tab)
			and di.[Indicator Code] <> 'N/A'
			order by len(di.[Indicator Code])

		END

		ELSE
		BEGIN
	
			select di.[Indicator Code] [-t-ind], di.[Indicator Name] [-t-name]
			from DimIndicators di left join dbo.configTable ct
			on di.TempID = ct.fileID
			left join #where w
			on di.ID = w.name
			where w.name is not null
			and di.DataSourceID = ( select top 1 ID from DimDataSource inner join #from on DataSource = tab)
			and di.[Indicator Code] <> 'N/A'
			order by len(di.[Indicator Code])

		END
	
		--select * from #select
		/*select * from #wheregeo
		select * from #wheretime
		select * from #whereind
	

		set @dyn_sql = N''
		print @dyn_sql
		execute sp_executesql @dyn_sql*/
	
end




GO


