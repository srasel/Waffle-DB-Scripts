/****** Object:  StoredProcedure [dbo].[StatsQuery]    Script Date: 7/7/2015 4:47:31 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[StatsQuery]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[StatsQuery]
GO

/****** Object:  StoredProcedure [dbo].[StatsQuery]    Script Date: 7/7/2015 4:47:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[StatsQuery]
@XML XML
AS
BEGIN
		SET NOCOUNT ON;
		
		DECLARE @XmlStr XML
				,@dyn_sql NVARCHAR(MAX)
				,@dropT NVARCHAR(MAX)
				,@newId NVARCHAR(MAX)
				,@factTable NVARCHAR(MAX)
				,@start INT
				,@END INT
				,@counter INT
				,@measure VARCHAR(20)
				,@reportData INT

		DECLARE @availableDataLevel TABLE (ds NVARCHAR(MAX), cat NVARCHAR(100),lev INT)
		
		CREATE TABLE #SELECT  (name VARCHAR(100))
		CREATE TABLE #wheregeo (name VARCHAR(100))
		CREATE TABLE #wheretime (minTime INT, maxTime INT)
		CREATE TABLE #whereind (name VARCHAR(100))
		CREATE TABLE #wherecat (name VARCHAR(100))
		CREATE TABLE #FROM (tab VARCHAR(100))
		CREATE TABLE #time (period INT)
		
		/*
			history of data level available for each source
		*/
		INSERT INTO @availableDataLevel
		SELECT 'SpreedSheet','country', 3
		UNION ALL
		SELECT 'SubNational','country',3
		UNION ALL
		SELECT 'SubNational','territory', 4
		UNION ALL
		SELECT 'WDI','country',3
		UNION ALL
		SELECT 'IMF','country',3
		UNION ALL
		SELECT 'ChartBook','country',3
		UNION ALL
		SELECT 'humnum','country',3
		
		SET @XmlStr = @XML
		SET @newId = NEWID()

		SET @factTable = 'FactFinal'

		BEGIN TRY
		
			INSERT INTO LogRequest([QueryUniqueID],[InputXML])
			SELECT @newId, @XML

			-- extract the values under SELECT
			INSERT INTO #SELECT
			SELECT x.col.value('.', 'VARCHAR(100)') AS [text()]
			FROM @XmlStr.nodes('//root//query//SELECT') x(col)

			/*
				transform reporting column to actual db column i.e. 
				geo -> [Country Code]
				geo.name -> [Short Name]
			*/
			SELECT s.* INTO #A 
			FROM #SELECT s LEFT JOIN vDimDetails d
			ON s.name = d.[-t-id]
			WHERE d.[-t-id] IS NULL

			/*
				if SELECT does not contain any measure column
				so, asking for Geo Dimension ???
			*/
			IF(@@ROWCOUNT = 0 or (SELECT COUNT(*) FROM #A)=0)
			BEGIN
				
				EXECUTE GeoEntitiesQuery @XML
			
				UPDATE LogRequest
				SET [Status] = 1
				,EndTime = getdate()
				WHERE QueryUniqueID = @newId

				RETURN
			END

			/*
				Shape file reporting.
				by pass from main system ???
			*/
			IF((SELECT COUNT(*) FROM #SELECT WHERE name LIKE 'incomeMount_shape_stack_%') > 0)
			BEGIN
				EXECUTE IncomeMountainQuery @XML

				UPDATE LogRequest
				SET [Status] = 1
				,EndTime = getdate()
				WHERE QueryUniqueID = @newId

				RETURN
			END

			-- remove duplicate from SELECT list.
			;WITH cte AS (
				SELECT *, 
					row_number() OVER(PARTITION BY name ORDER BY name) AS [rn]
				FROM #SELECT
			)
			DELETE cte WHERE [rn] > 1

			-- extract geo.cat & geo from WHERE clause
			INSERT INTO #wherecat
			SELECT x.col.value('.', 'VARCHAR(100)') AS [text()]
			FROM @XmlStr.nodes('//root//query//WHERE//geo.cat') x(col)
	
			INSERT INTO #wheregeo
			SELECT x.col.value('.', 'VARCHAR(100)') AS [text()]
			FROM @XmlStr.nodes('//root//query//WHERE//geo') x(col)

			/*
				If no geo selected or geo='*' in WHERE clause
			*/
			IF(@@ROWCOUNT = 0 or (SELECT top 1 name FROM #wheregeo)='*')
				BEGIN
					
					TRUNCATE TABLE #wheregeo

					-- category define? select that level from DimGeo
					-- otherwise take all
					IF((SELECT COUNT(*) FROM #wherecat)>0)
						BEGIN
							INSERT INTO #wheregeo
							SELECT id [Country Code] FROM DimGeo g INNER JOIN #wherecat wc ON g.cat = wc.name
						END
					ELSE
						BEGIN
							INSERT INTO #wheregeo
							SELECT id [Country Code] FROM DimGeo --WHERE cat = (SELECT top 1 * FROM #wherecat)
						END

				END

			/*
				some values are there in geo={swe,nor} ..
			*/
			ELSE
				BEGIN
					/*
						geo.cat define? 
						if geo={eur, asi} and geo.cat='county'
						we have to select the countries under eur, asi ..
					*/
					IF((SELECT COUNT(*) FROM #wherecat)>0 AND (SELECT top 1 name FROM #wherecat)!='')
						BEGIN
							--SELECT * FROM #wherecat
							;WITH cte (id, cat, rnk)AS
							(
								SELECT CAST(id AS NVARCHAR(255)) id 
								,CAST(cat AS NVARCHAR(255))cat 
								,geo.rnk rnk
								FROM (SELECT *,CASE WHEN cat ='planet' THEN 1 
									WHEN cat = 'region' THEN 2
									WHEN cat = 'country' THEN 3  
									WHEN cat = 'territory' THEN 4 END rnk FROM DimGeo) geo 
								INNER JOIN #wheregeo wg ON geo.id = wg.name

								UNION ALL

								SELECT g.id
								,g.cat
								,c.rnk+1
								FROM (SELECT *,CASE WHEN cat ='planet' THEN 1 
									WHEN cat = 'region' THEN 2
									WHEN cat = 'country' THEN 3  
									WHEN cat = 'territory' THEN 4 END rnk FROM DimGeo) g 
								INNER JOIN cte c ON g.region = c.id
							)
							SELECT c.id INTO #wheregeotemp 
							FROM cte c INNER JOIN #wherecat wc 
							ON c.cat = wc.name
					
							TRUNCATE TABLE #wheregeo
							INSERT INTO #wheregeo
							SELECT * FROM #wheregeotemp

						END

				END
	
			-- extract time under WHERE clause
			INSERT INTO #wheretime
			SELECT iif(isnull(PARSENAME([val],2),PARSENAME([val],1))='*',-1,isnull(PARSENAME([val],2),PARSENAME([val],1)))
			, iif(PARSENAME([val],1)='*',-1,PARSENAME([val],1))
			FROM (
			SELECT replace([text()],'-','.') val FROM (
				SELECT x.col.value('.', 'VARCHAR(100)') AS [text()]
				FROM @XmlStr.nodes('//root//query//WHERE//time') x(col)
				)A
			)B

			-- only one time defined? 
			-- time=2000 then make it a range time=[2000-2000]
			IF(@@ROWCOUNT = 0 or (SELECT top 1 minTime FROM #wheretime)='-1')
			BEGIN
				TRUNCATE TABLE #wheretime
				INSERT INTO #wheretime
				SELECT min(period),MAX(period) FROM DimTime
			END

			-- for interpolation, we need to report all time
			-- between two period range
			SELECT @start = minTime, @END = maxTime FROM #wheretime
			SET @counter = @start
			while @counter <= @END 
			BEGIN
				INSERT INTO #time
				SELECT @counter
				SET @counter = @counter + 1;
			END
			
			-- extract the indicator list from SELECT clause
			INSERT INTO #whereind
			SELECT s.name
			FROM #SELECT s LEFT JOIN vDimDetails d
			ON s.name = d.[-t-id]
			WHERE d.[-t-id] IS NULL

			/*
				another hard-coded logic to handle
				the age group functionality.
			*/
			SELECT @measure = name FROM #SELECT WHERE name LIKE 'age%'
			DECLARE @kount INT
			SELECT @kount = COUNT(*) FROM #SELECT WHERE name LIKE 'age%'or name LIKE 'pop%'

			IF(@kount > 1)
			BEGIN
				TRUNCATE TABLE #whereind
				INSERT INTO #whereind
				SELECT [Indicator Code] FROM DimIndicators
				WHERE [Indicator Code] LIKE CASE WHEN len(@measure) > 3 THEN @measure + '%' ELSE 'age_group%' END
			END

			-- extract FROM
			INSERT INTO #FROM
			SELECT x.col.value('.', 'VARCHAR(100)') AS [text()]
			FROM @XmlStr.nodes('//root//query//FROM') x(col)

			UPDATE #FROM
			SET tab = 'spreedsheet'
			WHERE tab = 'humnum'
	
			/*
				change the following logic
			*/
			SELECT @reportData = lev
			FROM @availableDataLevel d 
			INNER JOIN #FROM f ON d.ds = f.tab
			LEFT JOIN #wherecat c ON d.cat = c.name
			WHERE c.name IS NOT NULL

			IF(@reportData IS NULL)
			BEGIN
				SELECT @reportData = MIN(lev)
				FROM @availableDataLevel d 
				INNER JOIN #FROM f ON d.ds = f.tab
				GROUP BY d.ds
			END

			/*
				create a cols list like
				[Country Code] [geo], [Short Name] [geo.name]
			*/
			DECLARE @colInFinalSelect NVARCHAR(MAX)
			SELECT @colInFinalSelect = STUFF((
			SELECT (',' + '([' + s.name + ']) ['  + s.name +']'  ) AS [text()]
			FROM #SELECT s LEFT JOIN vDimDetails dd
			ON dd.[-t-id] = s.name
			WHERE dd.cName IS NOT NULL
			FOR XML PATH ('')),1,1,'')

			-- handle age_group logic again?
			IF((SELECT COUNT(*) FROM #SELECT WHERE name LIKE 'age_group%')>=1)
			BEGIN
				SELECT @colInFinalSelect = coalesce(@colInFinalSelect+', '''+  replace(s.name,'age_group_','Age Group ') +''' [' + s.name + ']',@colInFinalSelect)
				FROM #SELECT s WHERE s.name LIKE 'age_group%' 
			END

			DECLARE @colInQuerySelection NVARCHAR(MAX)
			SELECT @colInQuerySelection = STUFF((
			SELECT (',' + dd.cName + '[' + s.name + ']' ) AS [text()]
			FROM #SELECT s LEFT JOIN vDimDetails dd
			ON dd.[-t-id] = s.name
			FOR XML PATH ('')),1,1,'')
	
			DECLARE @colInGroupBy NVARCHAR(MAX)
			SELECT @colInGroupBy = STUFF((
			SELECT (',' + dd.cName ) AS [text()]
			FROM #SELECT s LEFT JOIN vDimDetails dd
			ON dd.[-t-id] = s.name
			FOR XML PATH ('')),1,1,'')


			DECLARE @indCol NVARCHAR(MAX)
			SELECT @indCol = STUFF((
			SELECT (',' +  ' [' + s.name +']') AS [text()]
			FROM #whereind s
			FOR XML PATH ('')),1,1,'')

			DECLARE @indColInSelect NVARCHAR(MAX)
			SELECT @indColInSelect = STUFF((
			SELECT (',' + ' CASE WHEN ''' + s.name + ''' = ''pop'' THEN round([' + s.name + '],0) ELSE dbo.fix([' + s.name + '],4) END  [' + s.name + ']') AS [text()]
			FROM #whereind s
			FOR XML PATH ('')),1,1,'')

			--SELECT @indColInSelect
	
			DECLARE @interimSelect VARCHAR(100)
			SET @interimSelect = '[Indicator Code]'

			IF(@kount > 1)
			BEGIN
				SET @indCol = '[pop]'
				SET @indColInSelect = '[pop]'
				SET @interimSelect = '''pop'''
			END
	
			;WITH cte (id, name, par, parId, cat, region, rnk)AS
			(
				SELECT CAST(id AS NVARCHAR(255)) id, 
				CAST(geo.name AS NVARCHAR(255)) name,
				geo.id par,
				geo.name parId, 
				CAST(cat AS NVARCHAR(255))cat,
				geo.region,
				geo.rnk rnk
				FROM (SELECT *,CASE WHEN cat ='planet' THEN 1 
					WHEN cat = 'region' THEN 2
					WHEN cat = 'country' THEN 3 
					WHEN cat = 'territory' THEN 4 END rnk FROM DimGeo) geo 
				INNER JOIN #wheregeo wg ON geo.id = wg.name

				UNION ALL

				SELECT g.id, 
				g.name,
				c.par  par,
				c.parId parId, 
				c.cat, 
				c.region,
				c.rnk+1
				FROM (SELECT *,CASE WHEN cat ='planet' THEN 1 
					WHEN cat = 'region' THEN 2
					WHEN cat = 'country' THEN 3 
					WHEN cat = 'territory' THEN 4 END rnk FROM DimGeo) g INNER JOIN cte c
				ON g.region = c.id
			)
			SELECT dc.ID, c.par [Country Code], c.parId [Short Name], c.region, c.cat [category]
			INTO #geoFinal 
			FROM dimCountry dc 
			LEFT JOIN (SELECT * FROM cte 
						WHERE rnk = @reportData--(SELECT lev FROM @availableDataLevel a INNER JOIN #FROM f ON a.ds = f.tab)
			) c 
			ON dc.[Short Name] = c.name
			WHERE c.name IS NOT NULL

			DECLARE @parmDefinition NVARCHAR(500);
			SET @parmDefinition = N'@start INT, @END INT'

			IF OBJECT_ID('SumTable', 'U') IS NOT NULL
				DROP TABLE dbo.SumTable

			-- for lex, gini: we need to do weighted avg.
			IF((SELECT COUNT(*) FROM #SELECT WHERE name in ('lex','gini'))>0
				AND 
				(SELECT name FROM #wherecat) <> 'country'
				)
			BEGIN
				SET @dyn_sql = N'
						SELECT [DataSourceID],[Country Code], [Period], [Indicator Code],
								[Value]/iif(isnull([SumValue],1)=0, 1, isnull([SumValue],1)) [Value]
						INTO [FactFinal' + @newId + ']
						FROM (
							SELECT par, A.[DataSourceID],A.[Country Code], A.[Period], A.[Indicator Code],
									(isnull(A.value,0) * isnull(B.value,0)) [Value]
									, sum(
										iif(A.value IS NULL, 0, 1) * B.value
									) over(partition by par, A.[Period], A.[Indicator Code]) [SumValue]
							--INTO [FactFinal' + @newId + ']
							FROM (
								SELECT f.*,dc.[Country Code] par,dc.[Short Name] partID  FROM dbo.[' + @factTable + '] f 
								LEFT JOIN (SELECT * FROM #geoFinal) dc
								ON f.[Country Code] = dc.ID
								LEFT JOIN ( SELECT i.[ID],i.[dataSourceID], [Indicator Code], i.[Indicator Name] FROM DimIndicators i LEFT JOIN #whereind w ON i.[Indicator Code] = w.name WHERE w.name IS NOT NULL) di
								ON f.[Indicator Code] = di.ID
								, #time t 
								WHERE dc.ID IS NOT NULL
								AND f.DataSourceID = (SELECT top 1 ID FROM DimDataSource INNER JOIN #FROM ON DataSource = tab)
								AND di.ID IS NOT NULL
								AND f.Period = t.period
							)A LEFT JOIN
							(
								SELECT f.* FROM dbo.[' + @factTable + '] f 
								LEFT JOIN (SELECT * FROM #geoFinal) dc
								ON f.[Country Code] = dc.ID
								LEFT JOIN ( SELECT i.[ID],i.[dataSourceID], [Indicator Code], i.[Indicator Name] FROM DimIndicators i WHERE [Indicator Code] = ''pop'') di
								ON f.[Indicator Code] = di.ID
								, #time t 
								WHERE dc.ID IS NOT NULL
								AND f.DataSourceID = (SELECT top 1 ID FROM DimDataSource INNER JOIN #FROM ON DataSource = tab)
								AND f.DataSourceID = di.DataSourceID
								AND di.ID IS NOT NULL
								AND f.Period = t.period
							) B 
							ON A.[DataSourceID] = B.[DataSourceID]
							AND A.[Country Code] = B.[Country Code]
							AND A.[Period] = B.[Period]
						)C
					'
				EXECUTE SP_EXECUTESQL @dyn_sql, @parmDefinition, @start = @start, @END = @END
				--exec('SELECT * FROM [FactFinal' + @newId + ']')
				SET @factTable = 'FactFinal' + @newId
			END

			SET @dyn_sql = N'
					SELECT ' + @colInQuerySelection + ', sum(f.Value) val,  di.[Indicator Code]
					INTO [SumTable' + @newId + ']
					FROM dbo.[' + @factTable + '] f 
					LEFT JOIN (SELECT * FROM #geoFinal) dc
					ON f.[Country Code] = dc.ID
					LEFT JOIN ( SELECT i.[ID],i.[dataSourceID], [Indicator Code], i.[Indicator Name] FROM DimIndicators i LEFT JOIN #whereind w ON i.[Indicator Code] = w.name WHERE w.name IS NOT NULL) di
					ON f.[Indicator Code] = di.ID
					, #time t --#wheretime t 
					--ON t.period = f.Period
					WHERE dc.ID IS NOT NULL
					AND f.DataSourceID = (SELECT top 1 ID FROM DimDataSource INNER JOIN #FROM ON DataSource = tab)
					AND di.ID IS NOT NULL
					AND f.Period = t.period--(Period >=t.minTime AND Period <= t.maxTime)
					--AND f.Period between @start AND @END
					group by ' + @colInGroupBy + ', di.[Indicator Code]
				'
			--print @dyn_sql
			EXECUTE SP_EXECUTESQL @dyn_sql, @parmDefinition, @start = @start, @END = @END

			--exec('SELECT * FROM [SumTable' + @newId + ']')
		
			
			IF(CHARINDEX('time',@colInQuerySelection,1)>0)
			BEGIN
				DECLARE @cols NVARCHAR(MAX)
				SELECT @cols =  stuff((SELECT ',['+ COLUMN_NAME + ']'  FROM INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_NAME = 'SumTable' + @newId
				AND COLUMN_NAME NOT in ('time','val')
				FOR XML PATH('')),1,1,'')
			
				SET @dyn_sql = N'
					INSERT INTO [SumTable' + @newId + '](' +  @cols + ', time, val)
					SELECT ' + @cols + ',period, NULL val
					FROM [SumTable' + @newId + '], #time
					group by ' + @cols + ', period
				'
				EXECUTE SP_EXECUTESQL @dyn_sql
				--SELECT * FROM SumTable

				IF OBJECT_ID('WithAllData', 'U') IS NOT NULL
					DROP TABLE dbo.WithAllData 

				SET @dyn_sql = N'
					SELECT ' + @cols + ',time,sum(val) val
					INTO [WithAllData' + @newId + '] 
					FROM [SumTable' + @newId + '] 
					group by ' + @cols + ', time
				'
				EXECUTE SP_EXECUTESQL @dyn_sql
				--SELECT * FROM WithAllData
			
			
				SET @dyn_sql = N'
					SELECT ' + @colInFinalSelect + ','  + @indColInSelect + ' 
					FROM (
						SELECT ' + @colInFinalSelect + ', val, ' + @interimSelect + ' [Indicator Code]
						FROM (
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
										FROM [WithAllData' + @newId + '] 
									) a
								) a
						) b --WHERE val > 0
					)A 
					pivot
					(
						sum(val)
						FOR [Indicator Code] in (' + @indCol + ')
					) AS pvt
				'
				--print @dyn_sql
				EXECUTE SP_EXECUTESQL @dyn_sql

			END

			ELSE
			BEGIN
				SET @dyn_sql = N'
					SELECT ' + @colInFinalSelect + ','  + @indColInSelect + ' 
					FROM (
						SELECT ' + @colInFinalSelect + ', val, ' + @interimSelect + ' [Indicator Code]
						FROM (
								SELECT * FROM [SumTable' + @newId + ']
						) b --WHERE val > 0
					)A 
					pivot
					(
						sum(val)
						FOR [Indicator Code] in (' + @indCol + ')
					) AS pvt
				'
				EXECUTE SP_EXECUTESQL @dyn_sql
			
			
			END

			SET @dropT = 'drop TABLE [' + ('SumTable' + @newId) + ']'
			IF OBJECT_ID('SumTable' + @newId + '', 'U') IS NOT NULL
				exec(@dropT)
			SET @dropT = 'drop TABLE [' + ('WithAllData' + @newId) + ']'
			IF OBJECT_ID('WithAllData' + @newId + '', 'U') IS NOT NULL
				exec(@dropT)
			SET @dropT = 'drop TABLE [' + ('FactFinal' + @newId) + ']'
			IF OBJECT_ID('FactFinal' + @newId + '', 'U') IS NOT NULL
				exec(@dropT)

			UPDATE LogRequest
			SET [Status] = 1
			,EndTime = getdate()
			WHERE QueryUniqueID = @newId
		END TRY
		BEGIN CATCH
			SELECT NULL geo, ERROR_MESSAGE() [geo.name], NULL [time]
		END CATCH

END


GO

EXECUTE StatsQuery 
'
<root>
  <query>
    <SELECT>geo</SELECT>
    <SELECT>geo.region</SELECT>
    <SELECT>time</SELECT>
    <SELECT>poverty_headcount_ratio_at_national_poverty_line_(%_of_population)</SELECT>
    <SELECT>co2_per_capita</SELECT>
    <WHERE>
      <geo>*</geo>
      <geo.cat>territory</geo.cat>
      <time>1990-2015</time>
      <quantity />
    </WHERE>
    <FROM>subnational</FROM>
  </query>
  <lang>en</lang>
</root>
'


