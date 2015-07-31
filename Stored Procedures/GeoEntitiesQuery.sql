USE [GapMinder]
GO

/****** Object:  StoredProcedure [dbo].[GeoEntitiesQuery]    Script Date: 7/7/2015 4:48:21 AM ******/
DROP PROCEDURE [dbo].[GeoEntitiesQuery]
GO

/****** Object:  StoredProcedure [dbo].[GeoEntitiesQuery]    Script Date: 7/7/2015 4:48:21 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[GeoEntitiesQuery]
@xml xml
as
begin
	--select [Type] Geo, [Country Code] Name, ID [Time], ID [Value] from DimCountry
	declare @XmlStr xml
	set @XmlStr = @xml
	
	create table #select  (name varchar(100))
	create table #wheregeo (name varchar(100))
	create table #wherecat (name varchar(100))
	create table #wheretime (minTime int, maxTime int)
	
	create table #from (tab varchar(100))

	declare @dyn_sql nvarchar(max)

	insert into #select
	select x.col.value('.', 'varchar(100)') AS [text()]
	FROM @XmlStr.nodes('//root//query//SELECT') x(col)

	if(@@ROWCOUNT = 0 or (select top 1 name from #select)='*')
	begin
		truncate table #select
		insert into #select
		select ('geo')
		union all 
		select ('geo.name')
		union all 
		select ('geo.cat')
	end
	
	insert into #wherecat
	select x.col.value('.', 'varchar(100)') AS [text()]
	FROM @XmlStr.nodes('//root//query//WHERE//geo.cat') x(col)

	insert into #wherecat
	select x.col.value('.', 'varchar(100)') AS [text()]
	FROM @XmlStr.nodes('//root//query//WHERE//cat') x(col)

	insert into #wheregeo
	select x.col.value('.', 'varchar(100)') AS [text()]
	FROM @XmlStr.nodes('//root//query//WHERE//geo') x(col)
	
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
	
	/*
	select * from #select
	select * from #wheregeo
	select * from #wherecat
	*/

	insert into #from
	select x.col.value('.', 'varchar(100)') AS [text()]
	FROM @XmlStr.nodes('//root//query//FROM') x(col)

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
		select max(period),max(period) from DimTime
	end

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

	declare @dColsSelection nvarchar(max)
	select @dColsSelection = STUFF((
	select (',' + ' isnull([' + s.name +'], '''') [' + s.name + ']') as [text()]
	from #select s
	for xml path ('')),1,1,'')
	
	set @dyn_sql = N'
		select ' + @dColsSelection + ' from (
		select g.id [geo], g.name [geo.name], g.cat [geo.cat], g.cat [geo.category], g.region [geo.region], cast(t.period as varchar(10)) [time]
		from DimGeo g left join #wheregeo c
		on g.id = c.name
		,#time t
		where c.name is not null
		)A
	'
	--print @dyn_sql
	execute sp_executesql @dyn_sql
	/*
execute GeoEntitiesQuery
'
<root><query><SELECT>*</SELECT>
<WHERE><geo>*</geo><geo.cat>region</geo.cat><cat /></WHERE>
<FROM>spreedsheet</FROM></query>
<lang>en</lang></root>
'
*/
end



GO


