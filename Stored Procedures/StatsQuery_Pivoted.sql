IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[StatsQuery_Pivoted]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[StatsQuery_Pivoted]
GO

/****** Object:  StoredProcedure [dbo].[StatsQuery_Pivoted]    Script Date: 8/29/2015 6:08:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[StatsQuery_Pivoted]
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
				,@reportData INT = 3
				,@dataSourceID VARCHAR(10) = '1'

		CREATE TABLE #SELECT  (name VARCHAR(100))
		CREATE TABLE #wheregeo (name VARCHAR(100))
		CREATE TABLE #wheretime (minTime INT, maxTime INT)
		CREATE TABLE #whereind (name VARCHAR(100))
		CREATE TABLE #wherecat (name VARCHAR(100))
		
		CREATE TABLE #whereage (id INT, age VARCHAR(100))
		CREATE TABLE #wheregender (id INT, gender VARCHAR(100))
		CREATE TABLE #wheresubgroup (id INT, grp VARCHAR(300))

		CREATE TABLE #FROM (tab VARCHAR(100))
		CREATE TABLE #time (period INT)
		/*
			history of data level available for each source
		*/
		SET @XmlStr = @XML
		SET @newId = NEWID()

		SET @factTable = 'FactFinalHMD_Pivoted'

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

			-- extract FROM
			INSERT INTO #FROM
			SELECT x.col.value('.', 'VARCHAR(100)') AS [text()]
			FROM @XmlStr.nodes('//root//query//FROM') x(col)

			SELECT @dataSourceID = S.ID 
			FROM DimDataSource S INNER JOIN #FROM F
			ON S.DataSource = F.tab

			UPDATE #FROM
			SET tab = 'spreedsheet'
			WHERE tab = 'humnum'

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

			

			--- extract others --
			INSERT INTO #whereage(AGE)
			SELECT x.col.value('.', 'VARCHAR(100)') AS [text()]
			FROM @XmlStr.nodes('//root//query//WHERE//age') x(col)
			
			DECLARE @age VARCHAR(10) = 'N/A'
			IF(@@ROWCOUNT=0 OR (SELECT TOP 1 age FROM #whereage)='' OR (SELECT TOP 1 age FROM #whereage)='*')
			BEGIN
				
				IF(@dataSourceID = 12)
				BEGIN
					SET @age = '0-50'
				END
				TRUNCATE TABLE #whereage
				INSERT INTO #whereage (age)
				SELECT @age
			END

			
			IF (@dataSourceID = 12 AND (SELECT TOP 1 age FROM #whereage) <> 'N/A')
			BEGIN
				DECLARE @ageGroup Table (startAge INT,endAge INT)
				
				INSERT INTO @ageGroup
				SELECT iif(isnull(PARSENAME([val],2),PARSENAME([val],1))='*',-1,isnull(PARSENAME([val],2),PARSENAME([val],1)))
				, iif(PARSENAME([val],1)='*',-1,PARSENAME([val],1))
				FROM (
				SELECT replace([text()],'-','.') val FROM (
					SELECT age [text()] FROM #whereage
					)A
				)B

				DECLARE @startAge INT
						,@endAge INT
						,@kount INT
				-- between two period range
				SELECT @startAge = startAge, @endAge = endAge FROM @ageGroup
				TRUNCATE TABLE #whereage
				SET @kount = @startAge
				while @kount <= @endAge 
				BEGIN
					INSERT INTO #whereage(AGE)
					SELECT @kount
					SET @kount = @kount + 1;
				END

			END

			UPDATE A
			SET A.id = DA.ID
			FROM #whereage A INNER JOIN DimAge DA
			ON A.age = DA.age

			INSERT INTO #wheregender(GENDER)
			SELECT x.col.value('.', 'VARCHAR(100)') AS [text()]
			FROM @XmlStr.nodes('//root//query//WHERE//gender') x(col)

			IF(@@ROWCOUNT=0 OR (SELECT TOP 1 gender FROM #wheregender)=''OR (SELECT TOP 1 gender FROM #wheregender)='*')
			BEGIN
				TRUNCATE TABLE #wheregender
				DECLARE @gen VARCHAR(10) = 'N/A'
				IF(@dataSourceID = 12)
				BEGIN
					SET @gen = 'both'
				END
				INSERT INTO #wheregender (id,gender)
				SELECT * FROM DimGender WHERE gender = @gen
			END

			UPDATE G
			SET G.id = DG.ID
			FROM #wheregender G INNER JOIN DimGender DG
			ON G.gender = DG.gender


			INSERT INTO #wheresubgroup(grp)
			SELECT x.col.value('.', 'VARCHAR(100)') AS [text()]
			FROM @XmlStr.nodes('//root//query//WHERE//group') x(col)

			IF(@@ROWCOUNT=0 OR (SELECT TOP 1 grp FROM #wheresubgroup)='' OR (SELECT TOP 1 grp FROM #wheresubgroup)='*')
			BEGIN
				TRUNCATE TABLE #wheresubgroup
				DECLARE @grp VARCHAR(10) = 'N/A'
				--IF(@dataSourceID = 12)
				--BEGIN
				--	SET @gen = 'both'
				--END
				INSERT INTO #wheresubgroup (id,grp)
				SELECT * FROM DimSubGroup WHERE SubGroup = @grp
			END

			UPDATE S
			SET S.id = DS.ID
			FROM #wheresubgroup S INNER JOIN DimSubGroup DS
			ON S.grp = DS.SubGroup

			----------------------
	
			/*
				change the following logic
			*/
			SET @reportData = (SELECT lev
			FROM UtilityAvailableDataLevel d 
			INNER JOIN #FROM f ON d.DataSource = f.tab
			LEFT JOIN #wherecat c ON d.Category = c.name
			WHERE c.name IS NOT NULL
			AND D.[IsAvailable] = 1)
			
			IF(@reportData IS NULL)
			BEGIN
				SET @reportData =(SELECT MIN(lev)
				FROM UtilityAvailableDataLevel d 
				INNER JOIN #FROM f ON d.DataSource = f.tab
				WHERE D.[IsAvailable] = 1
				GROUP BY d.DataSource)
			END;
			ELSE
			BEGIN
				SET @reportData = @reportData
			END
			--select @reportData
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
							
							;WITH cte (id, cat, rnk)AS
							(
								SELECT CAST(id AS NVARCHAR(255)) id 
								,CAST(cat AS NVARCHAR(255))cat 
								,geo.lev rnk
								FROM DimGeo geo 
								INNER JOIN #wheregeo wg ON geo.id = wg.name

								UNION ALL

								SELECT g.id
								,g.cat
								,c.rnk+1
								FROM DimGeo g 
								INNER JOIN cte c ON g.region = c.id
								AND c.rnk <= @reportData
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
			--SELECT @measure = name FROM #SELECT WHERE name LIKE 'age_%'
			--DECLARE @kount INT
			--SELECT @kount = COUNT(*) FROM #SELECT WHERE name LIKE 'age%'or name LIKE 'pop%'

			--IF(@kount > 1)
			--BEGIN
			--	TRUNCATE TABLE #whereind
			--	INSERT INTO #whereind
			--	SELECT [Indicator Code] FROM DimIndicators
			--	WHERE [Indicator Code] LIKE CASE WHEN len(@measure) > 3 THEN @measure + '%' ELSE 'age_group%' END
			--END

			

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
			--IF((SELECT COUNT(*) FROM #SELECT WHERE name LIKE 'age_group%')>=1)
			--BEGIN
			--	SELECT @colInFinalSelect = coalesce(@colInFinalSelect+', '''+  replace(s.name,'age_group_','Age Group ') +''' [' + s.name + ']',@colInFinalSelect)
			--	FROM #SELECT s WHERE s.name LIKE 'age_group%' 
			--END

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

			DECLARE @indColInSelectPivoted NVARCHAR(MAX)
			SELECT @indColInSelectPivoted = STUFF((
			SELECT (',' + ' CASE WHEN ''' + s.name + ''' = ''pop'' THEN round(sum(f.[' + s.name + ']),0) ELSE dbo.fix(sum(f.[' + s.name + ']),4) END  [' + s.name + ']') AS [text()]
			FROM #whereind s
			FOR XML PATH ('')),1,1,'')

			--SELECT @indColInSelectPivoted
	
			DECLARE @interimSelect VARCHAR(100)
			SET @interimSelect = '[Indicator Code]'

			--IF(@kount > 1)
			--BEGIN
			--	SET @indCol = '[pop]'
			--	SET @indColInSelect = '[pop]'
			--	SET @interimSelect = '''pop'''
			--END
			
			;WITH cte (id, name, par, parId, cat, region, rnk)AS
			(
				SELECT CAST(id AS NVARCHAR(255)) id, 
				CAST(geo.name AS NVARCHAR(255)) name,
				geo.id par,
				geo.name parId, 
				CAST(cat AS NVARCHAR(255))cat,
				geo.region,
				geo.lev rnk
				FROM  DimGeo geo 
				INNER JOIN #wheregeo wg ON geo.id = wg.name

				UNION ALL

				SELECT g.id, 
				g.name,
				c.par  par,
				c.parId parId, 
				c.cat, 
				c.region,
				c.rnk+1
				FROM DimGeo g INNER JOIN cte c
				ON g.region = c.id
				AND C.rnk + 1 <= @reportData
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
			IF(
				(
					SELECT COUNT(*) 
					FROM #SELECT WHERE 
					name IN (SELECT Indicator FROM UtilityIndicatorCalculation WHERE CalType = 'weighted')
				)>0
				AND

				(
					SELECT COUNT(*) 
					FROM #wherecat 
					WHERE name IN ('planet','region')
				)> 0 
			)
			BEGIN
				SET @dyn_sql = N'
						SELECT [DataSourceID],[Country Code], [Period], [Indicator Code],
								[Value]/iif(isnull([SumValue],1)=0, 1, isnull([SumValue],1)) [Value]
								,age
								,gender
								, subgroup
						INTO [FactFinal' + @newId + ']
						FROM (
							SELECT par, A.[DataSourceID],A.[Country Code], A.[Period], A.[Indicator Code],
									(isnull(A.value,0) * isnull(B.value,0)) [Value]
									, sum(
										iif(A.value IS NULL, 0, 1) * B.value
									) over(partition by par, A.[Period], A.[Indicator Code]) [SumValue]
									,A.[Age] age
									,A.[Gender] gender
									,A.[SubGroup] subgroup
							--INTO [FactFinal' + @newId + ']
							FROM (
								SELECT f.*,dc.[Country Code] par,dc.[Short Name] partID  FROM (SELECT [DataSourceID],[country code], [period], [indicator code],[SubGroup],[Age],[Gender],[Value] FROM dbo.[' + @factTable + '] WHERE [DataSourceID] = ' + @dataSourceID + ' ) f 
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
								SELECT f.* FROM (SELECT [DataSourceID],[country code], [period], [indicator code],[SubGroup],[Age],[Gender],[Value]  FROM dbo.[' + @factTable + '] WHERE [DataSourceID] = ' + @dataSourceID + ' ) f 
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
				--PRINT @dyn_sql
				EXECUTE SP_EXECUTESQL @dyn_sql, @parmDefinition, @start = @start, @END = @END
				--exec('SELECT * FROM [FactFinal' + @newId + ']')
				SET @factTable = 'FactFinal' + @newId
			END

			DECLARE @otherJoin VARCHAR(MAX)
			SET @otherJoin = ''

			--IF(SELECT COUNT(*) FROM #SELECT WHERE name = )
			--BEGIN
			--END

			SET @dyn_sql = N'
					SELECT ' + @colInQuerySelection + ', ' + @indColInSelectPivoted + '
					INTO [SumTable' + @newId + ']
					FROM (SELECT *  FROM dbo.[' + @factTable + '] WHERE [DataSourceID] = ' + @dataSourceID + ' ) f 
					LEFT JOIN (SELECT * FROM #geoFinal) dc
					ON f.[Country Code] = dc.ID
					LEFT JOIN #whereage ag
					ON f.age = ag.ID
					LEFT JOIN #wheregender gen
					ON f.gender = gen.ID
					LEFT JOIN #wheresubgroup sg
					ON f.subgroup = sg.ID
					, #time t --#wheretime t 
					--ON t.period = f.Period
					WHERE dc.ID IS NOT NULL
					AND f.DataSourceID = (SELECT top 1 ID FROM DimDataSource INNER JOIN #FROM ON DataSource = tab)
					AND f.Period = t.period--(Period >=t.minTime AND Period <= t.maxTime)
					--AND f.Period between @start AND @END
					AND ag.ID IS NOT NULL
					AND gen.ID IS NOT NULL
					AND sg.ID IS NOT NULL
					group by ' + @colInGroupBy + '
				'
			--PRINT @dyn_sql

			---return
			EXECUTE SP_EXECUTESQL @dyn_sql, @parmDefinition, @start = @start, @END = @END

			--select @colInFinalSelect
			--return

			--exec('SELECT * FROM [SumTable' + @newId + ']')
			
			IF(CHARINDEX('time',@colInQuerySelection,1)>0)
			BEGIN
				DECLARE @cols NVARCHAR(MAX)
				SELECT @cols =  stuff((SELECT ',['+ COLUMN_NAME + ']'  FROM INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_NAME = 'SumTable' + @newId
				AND COLUMN_NAME NOT in ('time','val')
				FOR XML PATH('')),1,1,'')

				DECLARE @colsM NVARCHAR(MAX)
				SELECT @colsM =  stuff((SELECT ',['+ COLUMN_NAME + ']'  
				FROM INFORMATION_SCHEMA.COLUMNS C 
					LEFT JOIN #whereind I
				ON C.COLUMN_NAME = I.name
				WHERE C.TABLE_NAME = 'SumTable' + @newId
				AND C.COLUMN_NAME NOT in ('time')
				AND I.name IS NULL
				FOR XML PATH('')),1,1,'')

				DECLARE @colsI NVARCHAR(MAX)
				SELECT @colsI =  stuff((SELECT ',['+ I.name + ']'  
				FROM #whereind I
				FOR XML PATH('')),1,1,'')

				DECLARE @colsINULL NVARCHAR(MAX)
				SELECT @colsINULL =  stuff((SELECT ',NULL ['+ I.name + ']'  
				FROM #whereind I
				FOR XML PATH('')),1,1,'')

				DECLARE @colsISUM NVARCHAR(MAX)
				SELECT @colsISUM =  stuff((SELECT ',SUM(['+ I.name + ']) ['+ I.name + ']'  
				FROM #whereind I
				FOR XML PATH('')),1,1,'')

				SET @dyn_sql = N'
					INSERT INTO [SumTable' + @newId + ']
					(' + @colsM + ',time,' + @colsI +' )
					SELECT ' + @colsM + ',period time, ' + @colsINULL + ' 
					FROM [SumTable' + @newId + '], #time
					group by ' + @colsM + ', period
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				IF OBJECT_ID('WithAllData', 'U') IS NOT NULL
					DROP TABLE dbo.WithAllData 

				SET @dyn_sql = N'
					SELECT ' + @colsM + ',time, ' + @colsISUM + ' 
					INTO [WithAllData' + @newId + '] 
					FROM [SumTable' + @newId + '] 
					group by ' + @colsM + ', time
				'
				--PRINT @DYN_SQL
				EXECUTE SP_EXECUTESQL @dyn_sql
				--SELECT * FROM WithAllData
				--exec('SELECT * FROM [WithAllData' + @newId + ']')
				
				DECLARE @countC NVARCHAR(MAX)
				SELECT @countC =  stuff((
				SELECT ',COUNT(['+I.name + ']) OVER (partition by ' + @colsM + ' ORDER BY time) ['+ I.name +'C]'  
				FROM #whereind I
				FOR XML PATH('')),1,1,'')

				DECLARE @X NVARCHAR(MAX)
				SELECT @X =  stuff((
				SELECT ',1+COUNT(CASE WHEN ['+ I.name +'] IS NULL THEN 1 END) OVER (PARTITION BY ' + @colsM +',['+ I.name + 'C]) ['+ I.name + 'X]'  
				FROM #whereind I
				FOR XML PATH('')),1,1,'')

				DECLARE @M NVARCHAR(MAX)
				SELECT @M =  stuff((
				SELECT ',(ROW_NUMBER() OVER (PARTITION BY ' + @colsM +',['+ I.name +'C] ORDER BY [time]) - 1)['+ I.name +'M]'  
				FROM #whereind I
				FOR XML PATH('')),1,1,'')

				DECLARE @N NVARCHAR(MAX)
				SELECT @N =  stuff((
				SELECT ',(ROW_NUMBER() OVER (PARTITION BY ' + @colsM +',['+ I.name +'C] ORDER BY [time] DESC))['+ I.name +'N]'  
				FROM #whereind I
				FOR XML PATH('')),1,1,'')

				DECLARE @S NVARCHAR(MAX)
				SELECT @S =  stuff((
				SELECT ',MAX(['+ I.name +']) OVER (PARTITION BY ' + @colsM +',['+ I.name + 'C])['+I.name +'S]'  
				FROM #whereind I
				FOR XML PATH('')),1,1,'')

				DECLARE @val NVARCHAR(MAX)
				SELECT @val =  stuff((
				SELECT ',CASE WHEN ['+ I.name +'] IS NOT NULL THEN ['+ I.name +'] ELSE ['+ I.name +'S] + (1. * ['+ I.name+'M] / ['+ I.name +'X]) * (LEAD(['+I.name+'], ['+ I.name +'N], ['+ I.name +'S]) OVER (partition by ' + @colsM + ' ORDER BY [time]) - ['+ I.name +'S]) END [' + I.name + ']'  
				FROM #whereind I
				FOR XML PATH('')),1,1,'')
			
				SET @dyn_sql = N'
					SELECT ' + @colsM + ',[time]
					,' + @val + '
					FROM
					(
						SELECT ' + @colsM + ',' + @colsI + ',[time], ' + @S + '
							,'+ @N +'
							,'+ @M +'
							,'+ @X +'
						FROM
						(
							SELECT ' + @colsM + ',' + @colsI + ',[time]
								,' + @countC + ' 
							FROM [WithAllData' + @newId + '] 
						) a
					) a
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
				--print @dyn_sql
				--EXECUTE SP_EXECUTESQL @dyn_sql
			
			
			END

			--select @colInFinalSelect
			--select @indColInSelect
			--select @interimSelect
			--select @indCol

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


