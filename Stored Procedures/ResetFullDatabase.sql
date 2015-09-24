USE GapMinder_DEV
	/*
	TRUNCATE TABLE [dbo].[DimCountry]
	TRUNCATE TABLE [dbo].[DimIndicators]
	TRUNCATE TABLE [dbo].[DimAge]
	TRUNCATE TABLE [dbo].[DimGender]
	TRUNCATE TABLE [dbo].[DimSubGroup]
	
	TRUNCATE TABLE [dbo].[FactDevInfo]
	TRUNCATE TABLE [dbo].[FactDevInfo_Pivoted]
	TRUNCATE TABLE [dbo].[FactDHS]
	TRUNCATE TABLE [dbo].[FactGECON]
	TRUNCATE TABLE [dbo].[FactHarvestChoice]
	TRUNCATE TABLE [dbo].[FactHarvestChoice_Pivoted]
	TRUNCATE TABLE [dbo].[FactHMD]
	TRUNCATE TABLE [dbo].[FactHMD_Pivoted]
	TRUNCATE TABLE [dbo].[FactIMF]
	TRUNCATE TABLE [dbo].[FactIMF_Pivoted]
	TRUNCATE TABLE [dbo].[FactNBER]
	TRUNCATE TABLE [dbo].[FactOPHI]
	TRUNCATE TABLE [dbo].[FactSEDAC]
	TRUNCATE TABLE [dbo].[FactSpreedSheet]
	TRUNCATE TABLE [dbo].[FactSpreedSheet_Pivoted]
	TRUNCATE TABLE [dbo].[FactWDI]
	TRUNCATE TABLE [dbo].[FactWDI_Pivoted]
	TRUNCATE TABLE [dbo].[FactOECD]
	

	DELETE FROM [dbo].[DimGeo] WHERE cat NOT IN ('planet','region','country')
	--SELECT * FROM DimGeo
	*/

	INSERT INTO DimCountry ([Type],[Country Code],[Short Name],[Country Name] )
	SELECT cat,id,name,name FROM DimGeo ORDER BY lev

	INSERT INTO DimAge(DataSourceID,age)
	SELECT ID,'N/A' FROM DimDataSource

	INSERT INTO DimGender([DataSourceID],gender)
	SELECT ID,'N/A' FROM DimDataSource

	INSERT INTO [dbo].[DimSubGroup]([DataSourceID],[SubGroup])
	SELECT ID,'N/A' FROM DimDataSource

	;WITH CTE
	AS
	(
	SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) RNK
	FROM DimGeo
	)
	SELECT * FROM CTE WHERE RNK > 1
	--DELETE FROM CTE WHERE RNK > 1

	;WITH CTE
	AS
	(
	SELECT *, ROW_NUMBER() OVER (PARTITION BY [Country Code] ORDER BY [Country Code]) RNK
	FROM DimCountry
	)
	SELECT * FROM CTE WHERE RNK > 1
	--DELETE FROM CTE WHERE RNK > 1

	/*
	EXECUTE ChangeIndexAndConstraint 'DROP', 'spreedsheet'
	EXECUTE ChangeIndexAndConstraint 'DROP', 'wdi'
	EXECUTE ChangeIndexAndConstraint 'DROP', 'sedac'
	EXECUTE ChangeIndexAndConstraint 'DROP', 'ophi'
	EXECUTE ChangeIndexAndConstraint 'DROP', 'nber'
	EXECUTE ChangeIndexAndConstraint 'DROP', 'hmd'
	EXECUTE ChangeIndexAndConstraint 'DROP', 'imf'
	EXECUTE ChangeIndexAndConstraint 'DROP', 'harvestchoice'
	EXECUTE ChangeIndexAndConstraint 'DROP', 'gecon'
	EXECUTE ChangeIndexAndConstraint 'DROP', 'dhs'
	EXECUTE ChangeIndexAndConstraint 'DROP', 'devinfo'
	EXECUTE ChangeIndexAndConstraint 'DROP', 'sedac'
	EXECUTE ChangeIndexAndConstraint 'DROP', 'oecd'
	*/

