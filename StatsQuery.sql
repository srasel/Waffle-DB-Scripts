USE [GapMinder]
GO

/****** Object:  StoredProcedure [dbo].[StatsQuery]    Script Date: 7/7/2015 4:47:31 AM ******/
DROP PROCEDURE [dbo].[StatsQuery]
GO

/****** Object:  StoredProcedure [dbo].[StatsQuery]    Script Date: 7/7/2015 4:47:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[StatsQuery]
@xml xml
as
begin
	--select [Type] Geo, [Country Code] Name, ID [Time], ID [Value] from DimCountry
	declare @XmlStr xml
	set @XmlStr = @xml
	
	create table #select  (name varchar(100))
	create table #wheregeo (name varchar(100))
	create table #wheretime (minTime int, maxTime int)
	create table #whereind (name varchar(100))
	create table #wherecat (name varchar(100))
	
	create table #from (tab varchar(100))

	declare @dyn_sql nvarchar(max)

	insert into #select
	select x.col.value('.', 'varchar(100)') AS [text()]
	FROM @XmlStr.nodes('//root//query//SELECT') x(col)

	--select * from #select 

	select s.* into #A 
	from #select s left join vDimDetails d
	on s.name = d.[-t-id]
	where d.[-t-id] is null

	--select * from #A

	if(@@ROWCOUNT = 0 or (select count(*) from #A)=0)
	begin
		--insert into #select
		--select 'ind' [Indicator Code] 
		execute GeoEntitiesQuery @xml
		return
		--from DimIndicators
		--where [Indicator Code] like 'pop'
		--or [Indicator Code] like 'gdp'
		--or [Indicator Code] like 'lex'
	end

	;WITH cte AS (
		SELECT *, 
			row_number() OVER(PARTITION BY name ORDER BY name) AS [rn]
		FROM #select
	)
	DELETE cte WHERE [rn] > 1

	insert into #wherecat
	select x.col.value('.', 'varchar(100)') AS [text()]
	FROM @XmlStr.nodes('//root//query//WHERE//geo.cat') x(col)
	
	insert into #wheregeo
	select x.col.value('.', 'varchar(100)') AS [text()]
	FROM @XmlStr.nodes('//root//query//WHERE//geo') x(col)

	--select * from #wheregeo

	if(@@ROWCOUNT = 0 or (select top 1 name from #wheregeo)='*')
	begin
		truncate table #wheregeo
		if((select count(*) from #wherecat)>0)
		begin
			insert into #wheregeo
			select id [Country Code] from DimGeo g inner join #wherecat wc on g.cat = wc.name
		end
		else
		begin
			insert into #wheregeo
			select id [Country Code] from DimGeo --where cat = (select top 1 * from #wherecat)
		end
	end
	else
	begin
		if((select count(*) from #wherecat)>0)
		begin
			
			;with cte (id, cat, rnk)as
			(
				select cast(id as nvarchar(255)) id 
				,cast(cat as nvarchar(255))cat 
				,geo.rnk rnk
				from (select *,case when cat ='planet' then 1 
					when cat = 'region' then 2
					when cat = 'country' then 3 end rnk from DimGeo) geo 
				inner join #wheregeo wg on geo.id = wg.name

				union all

				select g.id
				,g.cat
				,c.rnk+1
				from (select *,case when cat ='planet' then 1 
					when cat = 'region' then 2
					when cat = 'country' then 3 end rnk from DimGeo) g 
				inner join cte c on g.region = c.id
			)
			select c.id into #wheregeotemp from cte c inner join #wherecat wc on c.cat = wc.name

			truncate table #wheregeo
			insert into #wheregeo
			select * from #wheregeotemp

		end
	end
	
	insert into #wheretime
	select iif(isnull(PARSENAME([val],2),PARSENAME([val],1))='*',-1,isnull(PARSENAME([val],2),PARSENAME([val],1)))
	, iif(PARSENAME([val],1)='*',-1,PARSENAME([val],1))
	from (
	select replace([text()],'-','.') val from (
		select x.col.value('.', 'varchar(100)') AS [text()]
		FROM @XmlStr.nodes('//root//query//WHERE//time') x(col)
		)A
	)B

	if(@@ROWCOUNT = 0 or (select top 1 minTime from #wheretime)='-1')
	begin
		truncate table #wheretime
		insert into #wheretime
		select min(period),max(period) from DimTime
	end

	--select * from #wheretime

	declare @start int
	declare @end int
	declare @counter int

	create table #time (period int)

	select @start = minTime, @end = maxTime from #wheretime
	set @counter = @start

	while @counter <= @end 
	begin
		insert into #time
		select @counter
		set @counter = @counter + 1;
	end
	--;with cte(period) as
	--(
	--	select minTime from #wheretime
	--	union all
	--	select c.period + 1
	--	from cte c
	--	where c.period < (select maxTime from #wheretime)
	--)
	--select * into #time
	--from cte;

	--select * from #time order by period
	
	insert into #whereind
	select s.name
	from #select s left join vDimDetails d
	on s.name = d.[-t-id]
	where d.[-t-id] is null

	declare @measure varchar(20)
	select @measure = name from #select where name like 'age%'

	declare @kount int
	select @kount = count(*) from #select where name like 'age%'or name like 'pop%'

	if(@kount > 1)
	begin
		truncate table #whereind
		insert into #whereind
		select [Indicator Code] from DimIndicators
		where [Indicator Code] like case when len(@measure) > 3 then @measure + '%' else 'age_group%' end
	end

	--select * from #whereind

	
	insert into #from
	select x.col.value('.', 'varchar(100)') AS [text()]
	FROM @XmlStr.nodes('//root//query//FROM') x(col)

	update #from
	set tab = 'spreedsheet'
	where tab = 'humnum'
	
	declare @colInFinalSelect nvarchar(max)
	select @colInFinalSelect = STUFF((
	select (',' + '([' + s.name + ']) ['  + s.name +']'  ) as [text()]
	from #select s left join vDimDetails dd
	on dd.[-t-id] = s.name
	where dd.cName is not null
	for xml path ('')),1,1,'')
	--select @dCols

	--select * from #select
	if((select count(*) from #select where name like 'age_group%')>=1)
	begin
		select @colInFinalSelect = coalesce(@colInFinalSelect+', '''+  replace(s.name,'age_group_','Age Group ') +''' [' + s.name + ']',@colInFinalSelect)
		from #select s where s.name like 'age_group%' 
	end

	--select @colInFinalSelect

	declare @colInQuerySelection nvarchar(max)
	select @colInQuerySelection = STUFF((
	select (',' + dd.cName + '[' + s.name + ']' ) as [text()]
	from #select s left join vDimDetails dd
	on dd.[-t-id] = s.name
	for xml path ('')),1,1,'')
	
	declare @colInGroupBy nvarchar(max)
	select @colInGroupBy = STUFF((
	select (',' + dd.cName ) as [text()]
	from #select s left join vDimDetails dd
	on dd.[-t-id] = s.name
	for xml path ('')),1,1,'')


	declare @indCol nvarchar(max)
	select @indCol = STUFF((
	select (',' +  ' [' + s.name +']') as [text()]
	from #whereind s
	for xml path ('')),1,1,'')

	declare @indColInSelect nvarchar(max)
	select @indColInSelect = STUFF((
	select (',' + '([' + s.name + ']) [' + s.name + ']') as [text()]
	from #whereind s
	for xml path ('')),1,1,'')
	
	declare @interimSelect varchar(100)
	set @interimSelect = '[Indicator Code]'

	if(@kount > 1)
	begin
		set @indCol = '[pop]'
		set @indColInSelect = '[pop]'
		set @interimSelect = '''pop'''
	end
	

	--if(@@ROWCOUNT = 0 or (select top 1 name from #wherecat)='')
	--begin
	--	truncate table #wherecat
	--	insert into #wherecat
	--	select 'country'
	--end

	--select * from #wherecat
	--select * from #wheregeo

	--select * from #wheregeo
	;with cte (id, name, par, parId, cat, rnk)as
	(
		select cast(id as nvarchar(255)) id, 
		cast(geo.name as nvarchar(255)) name,
		geo.id par,
		geo.cat parId, 
		cast(cat as nvarchar(255))cat, geo.rnk rnk
		from (select *,case when cat ='planet' then 1 
			when cat = 'region' then 2
			when cat = 'country' then 3 end rnk from DimGeo) geo 
		inner join #wheregeo wg on geo.id = wg.name

		union all

		select g.id, 
		g.name,
		c.par  par,
		c.parId parId, 
		g.cat, c.rnk+1
		from (select *,case when cat ='planet' then 1 
			when cat = 'region' then 2
			when cat = 'country' then 3 end rnk from DimGeo) g inner join cte c
		on g.region = c.id
	)
	select dc.ID, c.par [Country Code], c.parId [Short Name]
	into #geoFinal 
	from dimCountry dc 
	left join (select * from cte where rnk = (select max(rnk) from cte)) c 
	on dc.[Short Name] = c.name where c.name is not null 
	
	--select * from #time

	DECLARE @parmDefinition nvarchar(500);
	set @parmDefinition = N'@start int, @end int'

	IF OBJECT_ID('SumTable', 'U') IS NOT NULL
		DROP TABLE dbo.SumTable 

	--CREATE TABLE [dbo].[SumTable](
	--	[geo] [nvarchar](255) NULL,
	--	[time] [varchar](10) NULL,
	--	[val] [float] NULL,
	--	[Indicator Code] [varchar](255) NULL
	--) ON [PRIMARY]

	set @dyn_sql = N'
			select ' + @colInQuerySelection + ', sum(f.Value) val,  di.[Indicator Code]
			into SumTable
			from dbo.FactFinal f 
			left join (select * from #geoFinal) dc
			on f.[Country Code] = dc.ID
			left join ( select i.[ID],i.[dataSourceID], [Indicator Code], i.[Indicator Name] from DimIndicators i left join #whereind w on i.[Indicator Code] = w.name where w.name is not null) di
			on f.[Indicator Code] = di.ID
			, #time t --#wheretime t 
			--on t.period = f.Period
			where dc.ID is not null
			and f.DataSourceID = (select top 1 ID from DimDataSource inner join #from on DataSource = tab)
			and di.ID is not null
			and f.Period = t.period--(Period >=t.minTime and Period <= t.maxTime)
			--and f.Period between @start and @end
			group by ' + @colInGroupBy + ', di.[Indicator Code]
		'
	--print @dyn_sql
	execute sp_executesql @dyn_sql, @parmDefinition, @start = @start, @end = @end

	--select * from SumTable

	if(CHARINDEX('time',@colInQuerySelection,1)>0)
	begin
		
		declare @cols nvarchar(max)
		select @cols =  stuff((select ',['+ COLUMN_NAME + ']'  from INFORMATION_SCHEMA.COLUMNS
		where TABLE_NAME = 'SumTable'
		and COLUMN_NAME not in ('time','val')
		for xml path('')),1,1,'')

		set @dyn_sql = N'
			insert into SumTable(' +  @cols + ', time, val)
			select ' + @cols + ',period, NULL val
			from SumTable, #time
			group by ' + @cols + ', period
		'
		execute sp_executesql @dyn_sql
		--select * from SumTable

		IF OBJECT_ID('WithAllData', 'U') IS NOT NULL
			DROP TABLE dbo.WithAllData 

		set @dyn_sql = N'
			select ' + @cols + ',time,sum(val) val
			into WithAllData
			from SumTable--, #time
			group by ' + @cols + ', time
		'
		execute sp_executesql @dyn_sql
		--select * from WithAllData

		set @dyn_sql = N'
			select ' + @colInFinalSelect + ','  + @indColInSelect + ' 
			from (
				select ' + @colInFinalSelect + ', val, ' + @interimSelect + ' [Indicator Code]
				from (
						SELECT ' + @cols + ',[time]
						,val=CASE
							WHEN val IS NOT NULL THEN val
							ELSE s + (1. * m / x) * (LEAD(val, n, s) OVER (partition by ' + @cols + ' ORDER BY [time]) -s)
							END
						FROM
						(
							SELECT ' + @cols + ',[time], val, s=MAX(val) OVER (PARTITION BY ' + @cols +',c)
								,n=ROW_NUMBER() OVER (PARTITION BY ' + @cols +',c ORDER BY [time] DESC)
								,m=ROW_NUMBER() OVER (PARTITION BY ' + @cols +',c ORDER BY [time]) - 1
								,x=1 + COUNT(CASE WHEN val IS NULL THEN 1 END) OVER (PARTITION BY ' + @cols +',c)
							FROM
							(
								SELECT ' + @cols + ',[time], val
									,c=COUNT(val) OVER (partition by ' + @cols + ' ORDER BY time)
								FROM WithAllData
							) a
						) a
				) b --where val > 0
			)A 
			pivot
			(
				sum(val)
				for [Indicator Code] in (' + @indCol + ')
			) as pvt
		'
		execute sp_executesql @dyn_sql
	end

	else
	begin
		set @dyn_sql = N'
			select ' + @colInFinalSelect + ','  + @indColInSelect + ' 
			from (
				select ' + @colInFinalSelect + ', val, ' + @interimSelect + ' [Indicator Code]
				from (
						select * from SumTable
				) b --where val > 0
			)A 
			pivot
			(
				sum(val)
				for [Indicator Code] in (' + @indCol + ')
			) as pvt
		'
		execute sp_executesql @dyn_sql
	end

end


GO

execute StatsQuery 
'
<root><query><SELECT>geo</SELECT><SELECT>time</SELECT><SELECT>lex</SELECT><WHERE><geo>world</geo>
<geo.cat>region</geo.cat><time>2050-2100</time><quantity /></WHERE>
<FROM>spreedsheet</FROM></query><lang>en</lang></root>
'

