IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreProcessDevInfoData]') AND type in (N'P', N'PC'))

DROP PROCEDURE [dbo].[PreProcessDevInfoData]
GO

/****** Object:  StoredProcedure [dbo].[PreProcessDevInfoData]    Script Date: 8/12/2015 12:46:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessDevInfoData]
AS
BEGIN
		SET NOCOUNT ON;
		
		SELECT Area, AreaCode
		INTO #A
		FROM [GapMinder_Dev_Maeenul].dbo.AllDevInfoRawData 
		GROUP BY Area, AreaCode

		DROP TABLE ZGeo
		SELECT * INTO ZGeo
		FROM #A

		--DROP TABLE #C
		SELECT Area, AreaCode INTO #C
		FROM ZGeo g inner join DimCountry c
		on left(areacode,3) = c.[Country Code]
		WHERE ISNUMERIC(left(AreaCode, 3)) = 0

		--DROP TABLE #B
		SELECT *,
		CASE rnk WHEN 1 THEN 'province'
				WHEN 2 THEN 'territory'
				WHEN 3 THEN 'sub territory'
				WHEN 4 THEN 'brick' end cat
		INTO #B
		FROM (
		SELECT iso, l, row_number() OVER(PARTITION BY iso ORDER BY l) rnk 
		FROM (
		SELECT DENSE_RANK() OVER(PARTITION BY left(areacode,3), len(areacode) ORDER BY area)
		rnk,
		len(areacode) l, 
		left(areacode,3) iso, *
		FROM ZGeo
		WHERE isnumeric(left(areacode,3)) = 0
		)A WHERE rnk = 1
		)B
		--ORDER BY AreaCode, l

		--SELECT * FROM DimGeo

		;WITH cte (code,name,parent,rnk, cat)
		as
		(
			SELECT cast(areacode as varchar(100)), cast(area as varchar(100)), cast(b.iso as varchar(100)), b.rnk
			,b.cat
			FROM #C c inner join #B b
			on len(c.areacode) = b.l
			and left(c.areacode, b.l) like b.iso + '%'
			WHERE b.rnk = 1

			union all

			SELECT cast(areacode as varchar(100)), cast(area as varchar(100)), cast(ct.code as varchar(100)), ct.rnk + 1
			,b.cat
			FROM #C c inner join cte ct
			on c.areacode like ct.code + '%'
			inner join #B b
			on len(c.areacode) = b.l
			and left(c.areacode, b.l) like b.iso + '%'
			WHERE b.rnk = ct.rnk + 1
			and ct.rnk < 6
		)

		--SELECT area, AreaCode
		--FROM #A
		--except

		INSERT INTO DimGeo
		SELECT 'geo', code, name, parent,cat, NULL, NULL
		FROM cte
		WHERE len(code) > 3

		;WITH cte (code,name,parent,rnk, cat)
		as
		(
			SELECT cast(areacode as varchar(100)), cast(area as varchar(100)), cast(b.iso as varchar(100)), b.rnk
			,b.cat
			FROM #C c inner join #B b
			on len(c.areacode) = b.l
			and left(c.areacode, b.l) like b.iso + '%'
			WHERE b.rnk = 1

			union all

			SELECT cast(areacode as varchar(100)), cast(area as varchar(100)), cast(ct.code as varchar(100)), ct.rnk + 1
			,b.cat
			FROM #C c inner join cte ct
			on c.areacode like ct.code + '%'
			inner join #B b
			on len(c.areacode) = b.l
			and left(c.areacode, b.l) like b.iso + '%'
			WHERE b.rnk = ct.rnk + 1
			and ct.rnk < 6
		)

		INSERT INTO dbo.DimCountry([Type],[Country Code],[Short Name], [Country Name])
		SELECT cat, code, name, name
		FROM cte
		WHERE len(code) > 3

END

GO


