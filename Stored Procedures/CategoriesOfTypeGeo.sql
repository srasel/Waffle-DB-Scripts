IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CategoriesOfTypeGeo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[CategoriesOfTypeGeo]
GO

/****** Object:  StoredProcedure [dbo].[PostProcessFactPivot]    Script Date: 9/12/2015 4:58:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CategoriesOfTypeGeo]
AS
BEGIN
		SELECT cat [-t-id], UPPER(cat) [-t-name], 'geo' [-t-dim] FROM DimGeo
		GROUP BY cat,lev
		ORDER BY lev	
END
