IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreProcessShapeFile]') AND type in (N'P', N'PC'))
/****** Object:  StoredProcedure [dbo].[PreProcessShapeFile]    Script Date: 8/5/2015 1:24:39 PM ******/
DROP PROCEDURE [dbo].[PreProcessShapeFile]
GO

/****** Object:  StoredProcedure [dbo].[PreProcessShapeFile]    Script Date: 8/5/2015 1:24:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessShapeFile]
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @dyn_sql NVARCHAR(max)
				,@shapeFileLocation VARCHAR(100)
	
		SET @shapeFileLocation = N'C:\Users\shahnewaz\Documents\wwwroot\webapitest\App_Data\mountain.txt'
		
		IF OBJECT_ID('dbo.IncomeMountainInput', 'U') IS NOT NULL
			DROP TABLE [dbo].[IncomeMountainInput]

		CREATE TABLE [dbo].[IncomeMountainInput](
			[Indicator] [varchar](200) NULL,
			[Period] [int] NULL,
			[MountainShape] [varchar](max) NULL
		) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

		TRUNCATE TABLE [dbo].[IncomeMountainInput]
		SET @dyn_sql = 
			N'
				BULK INSERT [dbo].[IncomeMountainInput]
				FROM ''' + @shapeFileLocation + ''' 
				WITH 
					(
					FIELDTERMINATOR = '';'', 
					ROWTERMINATOR = ''\n'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql

		MERGE [dbo].[IncomeMountain] AS T
		USING [dbo].[IncomeMountainInput] AS S
		ON (T.Indicator = S.Indicator AND T.Period = S.Period) 

		WHEN NOT MATCHED BY TARGET
			THEN INSERT(Indicator, Period, MountainShape) VALUES(S.Indicator, S.Period, S.MountainShape)
		WHEN MATCHED 
			THEN UPDATE SET T.MountainShape = S.MountainShape;

		IF OBJECT_ID('dbo.IncomeMountainInput', 'U') IS NOT NULL
			DROP TABLE [dbo].[IncomeMountainInput]
END

GO


