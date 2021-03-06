SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fix](@num float, @digits int) returns float as
begin
	declare @intPart INT
	set @intPart = cast(@num as int)
	set @num = @num - @intPart
	select @digits = iif(@num *10 > 1, 2, @digits)
    declare @res float
    select @res = @intPart +  case when @num = 0 then 0 else round(@num,@digits-1-floor(log10(abs(@num)))) end
    return (@res)
end




GO
/****** Object:  UserDefinedFunction [dbo].[getSplitPart]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[getSplitPart] ( 
	@stringToSplit nVARCHAR(MAX),
	@delimiter nvarchar(max),
	@index int
	)
RETURNS nvarchar(max)
AS
BEGIN

 DECLARE @name NVARCHAR(255)
 DECLARE @pos INT
 declare @curIndex int
 set @curIndex = 0
 set @name = @stringToSplit

 WHILE CHARINDEX(@delimiter, @stringToSplit) > 0
 BEGIN

	SELECT @pos  = CHARINDEX(@delimiter, @stringToSplit)  
	SELECT @name = SUBSTRING(@stringToSplit, 1, @pos-1)

	if(@index=@curIndex)
		return @name

	set @curIndex = @curIndex + 1
	SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
 END

 RETURN @name
END
GO
/****** Object:  UserDefinedFunction [dbo].[splitstring]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[splitstring] ( 
	@stringToSplit NVARCHAR(MAX),
	@delimiter nvarchar(max))
RETURNS
 @returnList TABLE ([Name] [nvarchar] (500))
AS
BEGIN

 DECLARE @name NVARCHAR(255)
 DECLARE @pos INT

 WHILE CHARINDEX(@delimiter, @stringToSplit) > 0
 BEGIN
  SELECT @pos  = CHARINDEX(@delimiter, @stringToSplit)  
  SELECT @name = SUBSTRING(@stringToSplit, 1, @pos-1)

  INSERT INTO @returnList 
  SELECT @name

  SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
 END

 INSERT INTO @returnList
 SELECT @stringToSplit

 RETURN
END
GO
/****** Object:  Table [dbo].[AllChartBookData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AllChartBookData](
	[Column 0] [varchar](500) NULL,
	[Column 1] [varchar](500) NULL,
	[Column 2] [varchar](500) NULL,
	[Column 3] [varchar](500) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AllDevInfoRawData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AllDevInfoRawData](
	[Indicator] [varchar](500) NULL,
	[Unit] [varchar](500) NULL,
	[Subgroup] [varchar](500) NULL,
	[Area] [varchar](500) NULL,
	[AreaCode] [varchar](500) NULL,
	[Year] [varchar](500) NULL,
	[DataValue] [varchar](500) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ConfigTable]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConfigTable](
	[fileID] [varchar](10) NULL,
	[Name] [varchar](max) NULL,
	[Tooltip] [varchar](max) NULL,
	[Menu level1] [varchar](max) NULL,
	[Menu level2] [varchar](max) NULL,
	[Indicator url] [varchar](max) NULL,
	[Download] [varchar](max) NULL,
	[ID] [varchar](max) NULL,
	[Scale] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DimAge]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DimAge](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourceID] [int] NULL,
	[age] [varchar](100) NULL,
 CONSTRAINT [PK_DimAge] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DimCountry]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DimCountry](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Type] [varchar](max) NULL,
	[Country Code] [varchar](100) NULL,
	[Short Name] [varchar](100) NULL,
	[Country Name] [varchar](max) NULL,
 CONSTRAINT [PK_DimCountry] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DimDataSource]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DimDataSource](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSource] [varchar](200) NULL,
	[Available] [bit] NULL CONSTRAINT [DF_DimDataSource_Available]  DEFAULT ((1)),
	[FactTableName] [varchar](100) NULL,
	[FactTablePivotedName] [varchar](100) NULL,
 CONSTRAINT [PK_DimDataSource] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DimGender]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DimGender](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourceID] [int] NULL,
	[gender] [varchar](100) NULL,
 CONSTRAINT [PK_DimGender] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DimGeo]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimGeo](
	[dim] [nvarchar](255) NULL,
	[id] [nvarchar](255) NULL,
	[name] [nvarchar](255) NULL,
	[region] [nvarchar](255) NULL,
	[cat] [nvarchar](255) NULL,
	[lev] [int] NULL,
	[lat] [float] NULL,
	[long] [float] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DimGeo_BAK]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimGeo_BAK](
	[dim] [nvarchar](255) NULL,
	[id] [nvarchar](255) NULL,
	[name] [nvarchar](255) NULL,
	[region] [nvarchar](255) NULL,
	[cat] [nvarchar](255) NULL,
	[lev] [int] NULL,
	[lat] [float] NULL,
	[long] [float] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DimIndicators]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DimIndicators](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourceID] [int] NOT NULL,
	[Indicator Code] [varchar](255) NULL,
	[Indicator Name] [varchar](max) NULL,
	[Unit] [varchar](50) NULL CONSTRAINT [DF_DimIndicators_Unit]  DEFAULT ('N/A'),
	[TempID] [int] NULL,
 CONSTRAINT [PK_DimIndicators] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DimIndicatorsMetaData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DimIndicatorsMetaData](
	[ID] [varchar](50) NULL,
	[Source name] [varchar](500) NULL,
	[Source link] [varchar](500) NULL,
	[Scale Type] [varchar](500) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DimSubGroup]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DimSubGroup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourceID] [int] NULL,
	[SubGroup] [varchar](500) NULL,
 CONSTRAINT [PK_DimSubGroup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DimTime]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimTime](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Period] [int] NOT NULL,
 CONSTRAINT [PK_DimTime] PRIMARY KEY CLUSTERED 
(
	[Period] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactDevInfo]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactDevInfo](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL DEFAULT ((1)),
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[Indicator Code] [int] NULL,
	[SubGroup] [int] NULL DEFAULT ((1)),
	[Age] [int] NULL DEFAULT ((1)),
	[Gender] [int] NULL DEFAULT ((1)),
	[Value] [float] NULL,
 CONSTRAINT [PK_FactDevInfo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactDevInfo_Pivoted]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactDevInfo_Pivoted](
	[VersionID] [int] NOT NULL,
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[SubGroup] [int] NULL,
	[Age] [int] NULL,
	[Gender] [int] NULL,
	[pop(p)] [float] NULL,
	[pop(%)] [float] NULL,
	[pop(n)] [float] NULL,
	[pop(m)] [float] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactDHS]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactDHS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL DEFAULT ((1)),
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[Indicator Code] [int] NULL,
	[SubGroup] [int] NULL DEFAULT ((1)),
	[Age] [int] NULL DEFAULT ((1)),
	[Gender] [int] NULL DEFAULT ((1)),
	[Value] [float] NULL,
 CONSTRAINT [PK_FactDHS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactFinal]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactFinal](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL DEFAULT ((1)),
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[Indicator Code] [int] NULL,
	[SubGroup] [int] NULL DEFAULT ((1)),
	[Age] [int] NULL DEFAULT ((1)),
	[Gender] [int] NULL DEFAULT ((1)),
	[Value] [float] NULL,
 CONSTRAINT [PK_FactFinal] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactGECON]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactGECON](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL DEFAULT ((1)),
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[Indicator Code] [int] NULL,
	[SubGroup] [int] NULL DEFAULT ((1)),
	[Age] [int] NULL DEFAULT ((1)),
	[Gender] [int] NULL DEFAULT ((1)),
	[Value] [float] NULL,
 CONSTRAINT [PK_FactGECON] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactHarvestChoice]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactHarvestChoice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL DEFAULT ((1)),
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[Indicator Code] [int] NULL,
	[SubGroup] [int] NULL DEFAULT ((1)),
	[Age] [int] NULL DEFAULT ((1)),
	[Gender] [int] NULL DEFAULT ((1)),
	[Value] [float] NULL,
 CONSTRAINT [PK_FactHarvetChoice] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactHarvestChoice_Pivoted]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactHarvestChoice_Pivoted](
	[VersionID] [int] NOT NULL,
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[SubGroup] [int] NULL,
	[Age] [int] NULL,
	[Gender] [int] NULL,
	[tpov_pt125] [float] NULL,
	[tpov_pt200] [float] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactHMD]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactHMD](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL DEFAULT ((1)),
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[Indicator Code] [int] NULL,
	[SubGroup] [int] NULL DEFAULT ((1)),
	[Age] [int] NULL DEFAULT ((1)),
	[Gender] [int] NULL DEFAULT ((1)),
	[Value] [float] NULL,
 CONSTRAINT [PK_FactHMD] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactHMD_Pivoted]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactHMD_Pivoted](
	[VersionID] [int] NOT NULL,
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[SubGroup] [int] NULL,
	[Age] [int] NULL,
	[Gender] [int] NULL,
	[pop] [float] NULL,
	[death_rates_cohort] [float] NULL,
	[cexposures] [float] NULL,
	[deaths] [float] NULL,
	[death_rates_period] [float] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactIMF]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactIMF](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL DEFAULT ((1)),
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[Indicator Code] [int] NULL,
	[SubGroup] [int] NULL DEFAULT ((1)),
	[Age] [int] NULL DEFAULT ((1)),
	[Gender] [int] NULL DEFAULT ((1)),
	[Value] [float] NULL,
 CONSTRAINT [PK_FactIMF] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactIMF_Pivoted]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactIMF_Pivoted](
	[VersionID] [int] NOT NULL,
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[SubGroup] [int] NULL,
	[Age] [int] NULL,
	[Gender] [int] NULL,
	[pop] [float] NULL,
	[gdp_per_cap] [float] NULL,
	[total_investment_percent_of_gdp] [float] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactNBER]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactNBER](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL DEFAULT ((1)),
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[Indicator Code] [int] NULL,
	[SubGroup] [int] NULL DEFAULT ((1)),
	[Age] [int] NULL DEFAULT ((1)),
	[Gender] [int] NULL DEFAULT ((1)),
	[Value] [float] NULL,
 CONSTRAINT [PK_FactNBER] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactOECD]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactOECD](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL DEFAULT ((1)),
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[Indicator Code] [int] NULL,
	[SubGroup] [int] NULL DEFAULT ((1)),
	[Age] [int] NULL DEFAULT ((1)),
	[Gender] [int] NULL DEFAULT ((1)),
	[Value] [float] NULL,
 CONSTRAINT [PK_FactOECD] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactOPHI]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactOPHI](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL DEFAULT ((1)),
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[Indicator Code] [int] NULL,
	[SubGroup] [int] NULL DEFAULT ((1)),
	[Age] [int] NULL DEFAULT ((1)),
	[Gender] [int] NULL DEFAULT ((1)),
	[Value] [float] NULL,
 CONSTRAINT [PK_FactOPHI] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactSEDAC]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactSEDAC](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL DEFAULT ((1)),
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[Indicator Code] [int] NULL,
	[SubGroup] [int] NULL DEFAULT ((1)),
	[Age] [int] NULL DEFAULT ((1)),
	[Gender] [int] NULL DEFAULT ((1)),
	[Value] [float] NULL,
 CONSTRAINT [PK_FactSEDAC] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactSpreedSheet]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactSpreedSheet](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL DEFAULT ((1)),
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[Indicator Code] [int] NULL,
	[SubGroup] [int] NULL DEFAULT ((1)),
	[Age] [int] NULL DEFAULT ((1)),
	[Gender] [int] NULL DEFAULT ((1)),
	[Value] [float] NULL,
 CONSTRAINT [PK_FactSpreedSheet] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactSpreedSheet_Pivoted]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactSpreedSheet_Pivoted](
	[VersionID] [int] NOT NULL,
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[SubGroup] [int] NULL,
	[Age] [int] NULL,
	[Gender] [int] NULL,
	[gdp_per_cap] [float] NULL,
	[lex] [float] NULL,
	[pop] [float] NULL,
	[gini] [float] NULL,
	[u5mr] [float] NULL,
	[childSurv] [float] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactSubNational]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactSubNational](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL DEFAULT ((1)),
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[Indicator Code] [int] NULL,
	[SubGroup] [int] NULL DEFAULT ((1)),
	[Age] [int] NULL DEFAULT ((1)),
	[Gender] [int] NULL DEFAULT ((1)),
	[Value] [float] NULL,
 CONSTRAINT [PK_FactSubNational] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactWDI]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactWDI](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VersionID] [int] NOT NULL DEFAULT ((1)),
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[Indicator Code] [int] NULL,
	[SubGroup] [int] NULL DEFAULT ((1)),
	[Age] [int] NULL DEFAULT ((1)),
	[Gender] [int] NULL DEFAULT ((1)),
	[Value] [float] NULL,
 CONSTRAINT [PK_FactWDI] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FactWDI_Pivoted]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactWDI_Pivoted](
	[VersionID] [int] NOT NULL,
	[DataSourceID] [int] NOT NULL,
	[Country Code] [int] NULL,
	[Period] [int] NULL,
	[SubGroup] [int] NULL,
	[Age] [int] NULL,
	[Gender] [int] NULL,
	[pop] [float] NULL,
	[gdp_per_cap] [float] NULL,
	[co2_emissions] [float] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GeoHierarchyLevel]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GeoHierarchyLevel](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[GeoLevelName] [varchar](100) NULL,
	[GeoLevelNo] [int] NULL,
 CONSTRAINT [PK_GeoHierarchyLevel] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HarvestChoiceRawData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HarvestChoiceRawData](
	[DataSourceName] [varchar](500) NULL,
	[DataSourceFileName] [varchar](500) NULL,
	[CELL5M] [varchar](500) NULL,
	[ISO3] [varchar](500) NULL,
	[ADM0_NAME] [varchar](500) NULL,
	[ADM1_NAME_ALT] [varchar](500) NULL,
	[ADM2_NAME_ALT] [varchar](500) NULL,
	[X] [varchar](500) NULL,
	[Y] [varchar](500) NULL,
	[Period] [varchar](500) NULL,
	[Indicator] [varchar](500) NULL,
	[DataValue] [varchar](500) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IMFAllRawData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IMFAllRawData](
	[Time] [nvarchar](50) NULL,
	[Value] [float] NULL,
	[Geo] [nvarchar](50) NULL,
	[Indicator] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[IncomeMountain]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IncomeMountain](
	[Indicator] [varchar](200) NULL,
	[Period] [int] NULL,
	[MountainShape] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LogRequest]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LogRequest](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[QueryUniqueID] [varchar](max) NULL,
	[InputXML] [xml] NULL,
	[Status] [bit] NULL CONSTRAINT [DF_LogRequest_Status]  DEFAULT ((0)),
	[StartTime] [datetime] NULL CONSTRAINT [DF_LogRequest_StartTime]  DEFAULT (getdate()),
	[EndTime] [datetime] NULL,
 CONSTRAINT [PK_LogRequest] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MortalityOrgData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MortalityOrgData](
	[Indicator] [varchar](50) NULL,
	[CountryCode] [varchar](50) NULL,
	[Year] [varchar](50) NULL,
	[Age] [varchar](50) NULL,
	[Male] [varchar](50) NULL,
	[Female] [varchar](50) NULL,
	[Total] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NBERRawData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NBERRawData](
	[DataSourceName] [varchar](50) NULL,
	[DataSheetName] [varchar](50) NULL,
	[RowNumber] [varchar](50) NULL,
	[CountryCode] [varchar](50) NULL,
	[CountryCodeNum] [varchar](50) NULL,
	[Region] [varchar](500) NULL,
	[Period] [varchar](50) NULL,
	[Indicator] [varchar](50) NULL,
	[DataValue] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NewDataGiniU5mrChildSurv]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NewDataGiniU5mrChildSurv](
	[geo] [varchar](100) NULL,
	[geo name] [varchar](100) NULL,
	[time] [varchar](50) NULL,
	[pop] [varchar](50) NULL,
	[u5mr] [varchar](50) NULL,
	[childSurv] [varchar](50) NULL,
	[gdp_per_cap] [varchar](50) NULL,
	[size] [varchar](50) NULL,
	[geo region] [varchar](50) NULL,
	[gini] [varchar](50) NULL,
	[geo cat] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NSI_tab2]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NSI_tab2](
	[DataSourceName] [varchar](500) NULL,
	[DataSheetName] [varchar](500) NULL,
	[Region] [varchar](500) NULL,
	[GeoLevel] [varchar](500) NULL,
	[Period] [varchar](500) NULL,
	[Indicator] [varchar](500) NULL,
	[DataValue] [varchar](500) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OECDRawData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OECDRawData](
	[DataSourceName] [varchar](500) NULL,
	[DataSheetName] [varchar](500) NULL,
	[CountryCode] [varchar](500) NULL,
	[CountryName] [varchar](500) NULL,
	[Sex] [varchar](500) NULL,
	[Age] [varchar](500) NULL,
	[Indicator] [varchar](500) NULL,
	[Unit] [varchar](500) NULL,
	[PowerCode] [varchar](500) NULL,
	[Period] [varchar](500) NULL,
	[DataValue] [varchar](500) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OPHI_Raw_Data]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OPHI_Raw_Data](
	[DataSourceName] [varchar](50) NULL,
	[DataSheetName] [varchar](500) NULL,
	[CountryCode] [varchar](500) NULL,
	[CountryName] [varchar](500) NULL,
	[SubRegionName] [varchar](500) NULL,
	[WorldRegion] [varchar](500) NULL,
	[MPIDataSource] [varchar](500) NULL,
	[Period] [varchar](500) NULL,
	[Indicator] [varchar](500) NULL,
	[DataValue] [varchar](500) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SEDAC_IMR]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SEDAC_IMR](
	[RegionCode] [varchar](500) NULL,
	[NumId] [varchar](50) NULL,
	[CountryCode] [varchar](50) NULL,
	[Region] [varchar](50) NULL,
	[Period] [varchar](50) NULL,
	[Indicator] [varchar](50) NULL,
	[DataValue] [varchar](50) NULL,
	[DataSourceName] [varchar](50) NULL,
	[DataSheetName] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SEDAC_National_Poverty_RawData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SEDAC_National_Poverty_RawData](
	[DataSourceName] [varchar](500) NULL,
	[DataSheetName] [varchar](500) NULL,
	[AdmUnitId] [varchar](500) NULL,
	[CountryCode] [varchar](500) NULL,
	[CountryName] [varchar](500) NULL,
	[AdmParent] [varchar](500) NULL,
	[Region] [varchar](500) NULL,
	[AdmLevel] [varchar](500) NULL,
	[Period] [varchar](500) NULL,
	[Indicator] [varchar](500) NULL,
	[DataValue] [varchar](500) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SpreedSheetAllRawData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SpreedSheetAllRawData](
	[fileLocation] [varchar](max) NULL,
	[pathID] [varchar](max) NULL,
	[country] [varchar](max) NULL,
	[period] [varchar](max) NULL,
	[value] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SpreedSheetFactData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SpreedSheetFactData](
	[fileLocation] [varchar](max) NULL,
	[pathID] [int] NULL,
	[country] [varchar](max) NULL,
	[period] [int] NULL,
	[value] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SpreedSheetIndicator]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SpreedSheetIndicator](
	[ID] [int] NOT NULL,
	[indicator] [varchar](max) NULL,
	[uKey] [varchar](max) NULL,
 CONSTRAINT [PK_indicators] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SubNationalData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SubNationalData](
	[indicator name] [varchar](max) NULL,
	[indicator code] [varchar](max) NULL,
	[country name] [varchar](max) NULL,
	[country code] [varchar](max) NULL,
	[period] [int] NULL,
	[value] [float] NULL,
	[region] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UtilityAvailableDataLevel]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UtilityAvailableDataLevel](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSource] [varchar](50) NULL,
	[Category] [varchar](50) NULL,
	[Lev] [int] NULL,
	[IsAvailable] [bit] NULL CONSTRAINT [DF_UtilityAvailableDataLevel_IsAvailable]  DEFAULT ((1)),
 CONSTRAINT [PK_UtilityAvailableDataLevel] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UtilityCommonlyUsedIndicators]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UtilityCommonlyUsedIndicators](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourceID] [int] NULL,
	[IndicatorCode] [varchar](200) NULL,
 CONSTRAINT [PK_UtilityCommonlyUsedIndicators] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UtilityDataVersions]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UtilityDataVersions](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSource] [varchar](100) NULL,
	[VersionNo] [int] NULL CONSTRAINT [DF_UtilityDataVersions_VersionNo]  DEFAULT ((1)),
	[UpdateTime] [datetime2](7) NULL CONSTRAINT [DF_UtilityDataVersions_UpdateTime]  DEFAULT (getdate()),
 CONSTRAINT [PK_UtilityDataVersions] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UtilityIndicatorCalculation]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UtilityIndicatorCalculation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Indicator] [varchar](max) NULL,
	[CalType] [varchar](100) NULL,
 CONSTRAINT [PK_UtilityIndicatorCalculation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UtilityProvince]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UtilityProvince](
	[country_code] [varchar](50) NULL,
	[subdivision_name] [varchar](50) NULL,
	[code] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UtilityRedirectingGiniData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UtilityRedirectingGiniData](
	[geo] [varchar](50) NULL,
	[geo name] [varchar](50) NULL,
	[geo cat] [varchar](50) NULL,
	[geo region] [varchar](50) NULL,
	[time] [varchar](50) NULL,
	[gini] [varchar](50) NULL,
	[pop] [varchar](50) NULL,
	[gdp_per_cap] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UtilityRenameIndicator]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UtilityRenameIndicator](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSourceID] [int] NULL,
	[IndicatorID] [int] NULL,
	[IndicatorNameBefore] [varchar](max) NULL,
	[IndicatorNameAfter] [varchar](max) NULL,
 CONSTRAINT [PK_UtilityRenameIndicator] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[vDimDetails]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[vDimDetails](
	[cName] [nvarchar](259) NULL,
	[-t-id] [varchar](20) NULL,
	[-t-dim] [varchar](20) NULL,
	[-t-name] [sysname] NOT NULL,
	[showHide] [bit] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[vDimensions]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[vDimensions](
	[-t-id] [varchar](20) NOT NULL,
	[-t-dim] [varchar](20) NOT NULL,
	[-t-kind] [varchar](20) NOT NULL,
	[-t-name] [varchar](50) NOT NULL,
	[-t-scale] [varchar](50) NOT NULL,
	[-t-types] [varchar](20) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WDI_Country]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WDI_Country](
	[Country Code] [varchar](4000) NULL,
	[Short Name] [varchar](4000) NULL,
	[Table Name] [varchar](4000) NULL,
	[Long Name] [varchar](4000) NULL,
	[2-alpha code] [varchar](4000) NULL,
	[Currency Unit] [varchar](4000) NULL,
	[Special Notes] [varchar](4000) NULL,
	[Region] [varchar](4000) NULL,
	[Income Group] [varchar](4000) NULL,
	[International memberships] [varchar](4000) NULL,
	[WB-2 code] [varchar](4000) NULL,
	[National accounts base year] [varchar](4000) NULL,
	[National accounts reference year] [varchar](4000) NULL,
	[SNA price valuation] [varchar](4000) NULL,
	[Lending category] [varchar](4000) NULL,
	[Other groups] [varchar](4000) NULL,
	[System of National Accounts] [varchar](4000) NULL,
	[Alternative conversion factor] [varchar](4000) NULL,
	[PPP survey year] [varchar](4000) NULL,
	[Balance of Payments Manual in use] [varchar](4000) NULL,
	[External debt Reporting status] [varchar](4000) NULL,
	[System of trade] [varchar](4000) NULL,
	[Government Accounting concept] [varchar](4000) NULL,
	[IMF data dissemination standard] [varchar](4000) NULL,
	[Latest population census] [varchar](4000) NULL,
	[Latest household survey] [varchar](4000) NULL,
	[Source of most recent Income and expenditure data] [varchar](4000) NULL,
	[Vital registration complete] [varchar](4000) NULL,
	[Latest agricultural census] [varchar](4000) NULL,
	[Latest industrial data] [varchar](4000) NULL,
	[Latest trade data] [varchar](4000) NULL,
	[Latest water withdrawal data] [varchar](4000) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WDI_Data]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WDI_Data](
	[Country Name] [varchar](max) NULL,
	[Country Code] [varchar](max) NULL,
	[Indicator Name] [varchar](max) NULL,
	[Indicator Code] [varchar](max) NULL,
	[period] [varchar](max) NULL,
	[value] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WDI_FactData1]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WDI_FactData1](
	[pathID] [int] NULL,
	[country] [varchar](max) NULL,
	[period] [int] NULL,
	[value] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WDI_Indicator]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WDI_Indicator](
	[ID] [int] NOT NULL,
	[indicator] [varchar](max) NULL,
	[indicatorCode] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WPP]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WPP](
	[LocID] [varchar](50) NULL,
	[Location] [varchar](500) NULL,
	[VarID] [varchar](50) NULL,
	[Variant] [varchar](500) NULL,
	[Time] [int] NULL,
	[SexID] [varchar](50) NULL,
	[Sex] [varchar](50) NULL,
	[AgeGrp] [varchar](50) NULL,
	[AgeGrpStart] [varchar](50) NULL,
	[AgeGrpSpan] [varchar](50) NULL,
	[Value] [real] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[z_dimgeo_sedac]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[z_dimgeo_sedac](
	[dim] [nvarchar](255) NULL,
	[id] [nvarchar](255) NULL,
	[name] [nvarchar](255) NULL,
	[region] [nvarchar](255) NULL,
	[cat] [nvarchar](255) NULL,
	[lev] [int] NULL,
	[lat] [float] NULL,
	[long] [float] NULL
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[vDimCountry]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vDimCountry] as
select * from DimCountry where [type] in ('planet','region','country')
and ID <> 66

GO
/****** Object:  View [dbo].[vDimGeo]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vDimGeo] as
select dim,id,name,
case when lev = 2 then 'world' else region end region
,cat,lev,lat,long from DimGeo where lev < 4

GO
/****** Object:  View [dbo].[vFact]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vFact] as
select * from FactSpreedSheet
where period between 2000 and 2015
and [Country Code] < 270

GO
ALTER TABLE [dbo].[FactDevInfo]  WITH CHECK ADD  CONSTRAINT [FK_FactDevInfo_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactDevInfo] CHECK CONSTRAINT [FK_FactDevInfo_DimAge]
GO
ALTER TABLE [dbo].[FactDevInfo]  WITH CHECK ADD  CONSTRAINT [FK_FactDevInfo_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactDevInfo] CHECK CONSTRAINT [FK_FactDevInfo_DimCountry]
GO
ALTER TABLE [dbo].[FactDevInfo]  WITH CHECK ADD  CONSTRAINT [FK_FactDevInfo_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactDevInfo] CHECK CONSTRAINT [FK_FactDevInfo_DimDataSource]
GO
ALTER TABLE [dbo].[FactDevInfo]  WITH CHECK ADD  CONSTRAINT [FK_FactDevInfo_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactDevInfo] CHECK CONSTRAINT [FK_FactDevInfo_DimGender]
GO
ALTER TABLE [dbo].[FactDevInfo]  WITH CHECK ADD  CONSTRAINT [FK_FactDevInfo_DimIndicators] FOREIGN KEY([Indicator Code])
REFERENCES [dbo].[DimIndicators] ([ID])
GO
ALTER TABLE [dbo].[FactDevInfo] CHECK CONSTRAINT [FK_FactDevInfo_DimIndicators]
GO
ALTER TABLE [dbo].[FactDevInfo]  WITH CHECK ADD  CONSTRAINT [FK_FactDevInfo_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactDevInfo] CHECK CONSTRAINT [FK_FactDevInfo_DimSubGroup]
GO
ALTER TABLE [dbo].[FactDevInfo_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactDevInfo_Pivoted_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactDevInfo_Pivoted] CHECK CONSTRAINT [FK_FactDevInfo_Pivoted_DimAge]
GO
ALTER TABLE [dbo].[FactDevInfo_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactDevInfo_Pivoted_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactDevInfo_Pivoted] CHECK CONSTRAINT [FK_FactDevInfo_Pivoted_DimCountry]
GO
ALTER TABLE [dbo].[FactDevInfo_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactDevInfo_Pivoted_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactDevInfo_Pivoted] CHECK CONSTRAINT [FK_FactDevInfo_Pivoted_DimDataSource]
GO
ALTER TABLE [dbo].[FactDevInfo_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactDevInfo_Pivoted_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactDevInfo_Pivoted] CHECK CONSTRAINT [FK_FactDevInfo_Pivoted_DimGender]
GO
ALTER TABLE [dbo].[FactDevInfo_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactDevInfo_Pivoted_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactDevInfo_Pivoted] CHECK CONSTRAINT [FK_FactDevInfo_Pivoted_DimSubGroup]
GO
ALTER TABLE [dbo].[FactDHS]  WITH CHECK ADD  CONSTRAINT [FK_FactDHS_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactDHS] CHECK CONSTRAINT [FK_FactDHS_DimAge]
GO
ALTER TABLE [dbo].[FactDHS]  WITH CHECK ADD  CONSTRAINT [FK_FactDHS_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactDHS] CHECK CONSTRAINT [FK_FactDHS_DimCountry]
GO
ALTER TABLE [dbo].[FactDHS]  WITH CHECK ADD  CONSTRAINT [FK_FactDHS_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactDHS] CHECK CONSTRAINT [FK_FactDHS_DimDataSource]
GO
ALTER TABLE [dbo].[FactDHS]  WITH CHECK ADD  CONSTRAINT [FK_FactDHS_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactDHS] CHECK CONSTRAINT [FK_FactDHS_DimGender]
GO
ALTER TABLE [dbo].[FactDHS]  WITH CHECK ADD  CONSTRAINT [FK_FactDHS_DimIndicators] FOREIGN KEY([Indicator Code])
REFERENCES [dbo].[DimIndicators] ([ID])
GO
ALTER TABLE [dbo].[FactDHS] CHECK CONSTRAINT [FK_FactDHS_DimIndicators]
GO
ALTER TABLE [dbo].[FactDHS]  WITH CHECK ADD  CONSTRAINT [FK_FactDHS_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactDHS] CHECK CONSTRAINT [FK_FactDHS_DimSubGroup]
GO
ALTER TABLE [dbo].[FactFinal]  WITH CHECK ADD  CONSTRAINT [FK_FactFinal_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactFinal] CHECK CONSTRAINT [FK_FactFinal_DimAge]
GO
ALTER TABLE [dbo].[FactFinal]  WITH CHECK ADD  CONSTRAINT [FK_FactFinal_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactFinal] CHECK CONSTRAINT [FK_FactFinal_DimCountry]
GO
ALTER TABLE [dbo].[FactFinal]  WITH CHECK ADD  CONSTRAINT [FK_FactFinal_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactFinal] CHECK CONSTRAINT [FK_FactFinal_DimDataSource]
GO
ALTER TABLE [dbo].[FactFinal]  WITH CHECK ADD  CONSTRAINT [FK_FactFinal_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactFinal] CHECK CONSTRAINT [FK_FactFinal_DimGender]
GO
ALTER TABLE [dbo].[FactFinal]  WITH CHECK ADD  CONSTRAINT [FK_FactFinal_DimIndicators] FOREIGN KEY([Indicator Code])
REFERENCES [dbo].[DimIndicators] ([ID])
GO
ALTER TABLE [dbo].[FactFinal] CHECK CONSTRAINT [FK_FactFinal_DimIndicators]
GO
ALTER TABLE [dbo].[FactFinal]  WITH CHECK ADD  CONSTRAINT [FK_FactFinal_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactFinal] CHECK CONSTRAINT [FK_FactFinal_DimSubGroup]
GO
ALTER TABLE [dbo].[FactGECON]  WITH CHECK ADD  CONSTRAINT [FK_FactGECON_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactGECON] CHECK CONSTRAINT [FK_FactGECON_DimAge]
GO
ALTER TABLE [dbo].[FactGECON]  WITH CHECK ADD  CONSTRAINT [FK_FactGECON_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactGECON] CHECK CONSTRAINT [FK_FactGECON_DimCountry]
GO
ALTER TABLE [dbo].[FactGECON]  WITH CHECK ADD  CONSTRAINT [FK_FactGECON_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactGECON] CHECK CONSTRAINT [FK_FactGECON_DimDataSource]
GO
ALTER TABLE [dbo].[FactGECON]  WITH CHECK ADD  CONSTRAINT [FK_FactGECON_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactGECON] CHECK CONSTRAINT [FK_FactGECON_DimGender]
GO
ALTER TABLE [dbo].[FactGECON]  WITH CHECK ADD  CONSTRAINT [FK_FactGECON_DimIndicators] FOREIGN KEY([Indicator Code])
REFERENCES [dbo].[DimIndicators] ([ID])
GO
ALTER TABLE [dbo].[FactGECON] CHECK CONSTRAINT [FK_FactGECON_DimIndicators]
GO
ALTER TABLE [dbo].[FactGECON]  WITH CHECK ADD  CONSTRAINT [FK_FactGECON_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactGECON] CHECK CONSTRAINT [FK_FactGECON_DimSubGroup]
GO
ALTER TABLE [dbo].[FactHarvestChoice]  WITH CHECK ADD  CONSTRAINT [FK_FactHarvestChoice_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactHarvestChoice] CHECK CONSTRAINT [FK_FactHarvestChoice_DimAge]
GO
ALTER TABLE [dbo].[FactHarvestChoice]  WITH CHECK ADD  CONSTRAINT [FK_FactHarvestChoice_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactHarvestChoice] CHECK CONSTRAINT [FK_FactHarvestChoice_DimCountry]
GO
ALTER TABLE [dbo].[FactHarvestChoice]  WITH CHECK ADD  CONSTRAINT [FK_FactHarvestChoice_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactHarvestChoice] CHECK CONSTRAINT [FK_FactHarvestChoice_DimDataSource]
GO
ALTER TABLE [dbo].[FactHarvestChoice]  WITH CHECK ADD  CONSTRAINT [FK_FactHarvestChoice_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactHarvestChoice] CHECK CONSTRAINT [FK_FactHarvestChoice_DimGender]
GO
ALTER TABLE [dbo].[FactHarvestChoice]  WITH CHECK ADD  CONSTRAINT [FK_FactHarvestChoice_DimIndicators] FOREIGN KEY([Indicator Code])
REFERENCES [dbo].[DimIndicators] ([ID])
GO
ALTER TABLE [dbo].[FactHarvestChoice] CHECK CONSTRAINT [FK_FactHarvestChoice_DimIndicators]
GO
ALTER TABLE [dbo].[FactHarvestChoice]  WITH CHECK ADD  CONSTRAINT [FK_FactHarvestChoice_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactHarvestChoice] CHECK CONSTRAINT [FK_FactHarvestChoice_DimSubGroup]
GO
ALTER TABLE [dbo].[FactHarvestChoice_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactHarvestChoice_Pivoted_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactHarvestChoice_Pivoted] CHECK CONSTRAINT [FK_FactHarvestChoice_Pivoted_DimAge]
GO
ALTER TABLE [dbo].[FactHarvestChoice_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactHarvestChoice_Pivoted_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactHarvestChoice_Pivoted] CHECK CONSTRAINT [FK_FactHarvestChoice_Pivoted_DimCountry]
GO
ALTER TABLE [dbo].[FactHarvestChoice_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactHarvestChoice_Pivoted_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactHarvestChoice_Pivoted] CHECK CONSTRAINT [FK_FactHarvestChoice_Pivoted_DimDataSource]
GO
ALTER TABLE [dbo].[FactHarvestChoice_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactHarvestChoice_Pivoted_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactHarvestChoice_Pivoted] CHECK CONSTRAINT [FK_FactHarvestChoice_Pivoted_DimGender]
GO
ALTER TABLE [dbo].[FactHarvestChoice_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactHarvestChoice_Pivoted_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactHarvestChoice_Pivoted] CHECK CONSTRAINT [FK_FactHarvestChoice_Pivoted_DimSubGroup]
GO
ALTER TABLE [dbo].[FactHMD]  WITH CHECK ADD  CONSTRAINT [FK_FactHMD_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactHMD] CHECK CONSTRAINT [FK_FactHMD_DimAge]
GO
ALTER TABLE [dbo].[FactHMD]  WITH CHECK ADD  CONSTRAINT [FK_FactHMD_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactHMD] CHECK CONSTRAINT [FK_FactHMD_DimCountry]
GO
ALTER TABLE [dbo].[FactHMD]  WITH CHECK ADD  CONSTRAINT [FK_FactHMD_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactHMD] CHECK CONSTRAINT [FK_FactHMD_DimDataSource]
GO
ALTER TABLE [dbo].[FactHMD]  WITH CHECK ADD  CONSTRAINT [FK_FactHMD_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactHMD] CHECK CONSTRAINT [FK_FactHMD_DimGender]
GO
ALTER TABLE [dbo].[FactHMD]  WITH CHECK ADD  CONSTRAINT [FK_FactHMD_DimIndicators] FOREIGN KEY([Indicator Code])
REFERENCES [dbo].[DimIndicators] ([ID])
GO
ALTER TABLE [dbo].[FactHMD] CHECK CONSTRAINT [FK_FactHMD_DimIndicators]
GO
ALTER TABLE [dbo].[FactHMD]  WITH CHECK ADD  CONSTRAINT [FK_FactHMD_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactHMD] CHECK CONSTRAINT [FK_FactHMD_DimSubGroup]
GO
ALTER TABLE [dbo].[FactHMD_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactHMD_Pivoted_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactHMD_Pivoted] CHECK CONSTRAINT [FK_FactHMD_Pivoted_DimAge]
GO
ALTER TABLE [dbo].[FactHMD_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactHMD_Pivoted_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactHMD_Pivoted] CHECK CONSTRAINT [FK_FactHMD_Pivoted_DimCountry]
GO
ALTER TABLE [dbo].[FactHMD_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactHMD_Pivoted_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactHMD_Pivoted] CHECK CONSTRAINT [FK_FactHMD_Pivoted_DimDataSource]
GO
ALTER TABLE [dbo].[FactHMD_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactHMD_Pivoted_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactHMD_Pivoted] CHECK CONSTRAINT [FK_FactHMD_Pivoted_DimGender]
GO
ALTER TABLE [dbo].[FactHMD_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactHMD_Pivoted_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactHMD_Pivoted] CHECK CONSTRAINT [FK_FactHMD_Pivoted_DimSubGroup]
GO
ALTER TABLE [dbo].[FactIMF]  WITH CHECK ADD  CONSTRAINT [FK_FactIMF_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactIMF] CHECK CONSTRAINT [FK_FactIMF_DimAge]
GO
ALTER TABLE [dbo].[FactIMF]  WITH CHECK ADD  CONSTRAINT [FK_FactIMF_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactIMF] CHECK CONSTRAINT [FK_FactIMF_DimCountry]
GO
ALTER TABLE [dbo].[FactIMF]  WITH CHECK ADD  CONSTRAINT [FK_FactIMF_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactIMF] CHECK CONSTRAINT [FK_FactIMF_DimDataSource]
GO
ALTER TABLE [dbo].[FactIMF]  WITH CHECK ADD  CONSTRAINT [FK_FactIMF_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactIMF] CHECK CONSTRAINT [FK_FactIMF_DimGender]
GO
ALTER TABLE [dbo].[FactIMF]  WITH CHECK ADD  CONSTRAINT [FK_FactIMF_DimIndicators] FOREIGN KEY([Indicator Code])
REFERENCES [dbo].[DimIndicators] ([ID])
GO
ALTER TABLE [dbo].[FactIMF] CHECK CONSTRAINT [FK_FactIMF_DimIndicators]
GO
ALTER TABLE [dbo].[FactIMF]  WITH CHECK ADD  CONSTRAINT [FK_FactIMF_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactIMF] CHECK CONSTRAINT [FK_FactIMF_DimSubGroup]
GO
ALTER TABLE [dbo].[FactIMF_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactIMF_Pivoted_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactIMF_Pivoted] CHECK CONSTRAINT [FK_FactIMF_Pivoted_DimAge]
GO
ALTER TABLE [dbo].[FactIMF_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactIMF_Pivoted_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactIMF_Pivoted] CHECK CONSTRAINT [FK_FactIMF_Pivoted_DimCountry]
GO
ALTER TABLE [dbo].[FactIMF_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactIMF_Pivoted_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactIMF_Pivoted] CHECK CONSTRAINT [FK_FactIMF_Pivoted_DimDataSource]
GO
ALTER TABLE [dbo].[FactIMF_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactIMF_Pivoted_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactIMF_Pivoted] CHECK CONSTRAINT [FK_FactIMF_Pivoted_DimGender]
GO
ALTER TABLE [dbo].[FactIMF_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactIMF_Pivoted_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactIMF_Pivoted] CHECK CONSTRAINT [FK_FactIMF_Pivoted_DimSubGroup]
GO
ALTER TABLE [dbo].[FactNBER]  WITH CHECK ADD  CONSTRAINT [FK_FactNBER_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactNBER] CHECK CONSTRAINT [FK_FactNBER_DimAge]
GO
ALTER TABLE [dbo].[FactNBER]  WITH CHECK ADD  CONSTRAINT [FK_FactNBER_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactNBER] CHECK CONSTRAINT [FK_FactNBER_DimCountry]
GO
ALTER TABLE [dbo].[FactNBER]  WITH CHECK ADD  CONSTRAINT [FK_FactNBER_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactNBER] CHECK CONSTRAINT [FK_FactNBER_DimDataSource]
GO
ALTER TABLE [dbo].[FactNBER]  WITH CHECK ADD  CONSTRAINT [FK_FactNBER_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactNBER] CHECK CONSTRAINT [FK_FactNBER_DimGender]
GO
ALTER TABLE [dbo].[FactNBER]  WITH CHECK ADD  CONSTRAINT [FK_FactNBER_DimIndicators] FOREIGN KEY([Indicator Code])
REFERENCES [dbo].[DimIndicators] ([ID])
GO
ALTER TABLE [dbo].[FactNBER] CHECK CONSTRAINT [FK_FactNBER_DimIndicators]
GO
ALTER TABLE [dbo].[FactNBER]  WITH CHECK ADD  CONSTRAINT [FK_FactNBER_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactNBER] CHECK CONSTRAINT [FK_FactNBER_DimSubGroup]
GO
ALTER TABLE [dbo].[FactOECD]  WITH CHECK ADD  CONSTRAINT [FK_FactOECD_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactOECD] CHECK CONSTRAINT [FK_FactOECD_DimAge]
GO
ALTER TABLE [dbo].[FactOECD]  WITH CHECK ADD  CONSTRAINT [FK_FactOECD_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactOECD] CHECK CONSTRAINT [FK_FactOECD_DimCountry]
GO
ALTER TABLE [dbo].[FactOECD]  WITH CHECK ADD  CONSTRAINT [FK_FactOECD_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactOECD] CHECK CONSTRAINT [FK_FactOECD_DimDataSource]
GO
ALTER TABLE [dbo].[FactOECD]  WITH CHECK ADD  CONSTRAINT [FK_FactOECD_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactOECD] CHECK CONSTRAINT [FK_FactOECD_DimGender]
GO
ALTER TABLE [dbo].[FactOECD]  WITH CHECK ADD  CONSTRAINT [FK_FactOECD_DimIndicators] FOREIGN KEY([Indicator Code])
REFERENCES [dbo].[DimIndicators] ([ID])
GO
ALTER TABLE [dbo].[FactOECD] CHECK CONSTRAINT [FK_FactOECD_DimIndicators]
GO
ALTER TABLE [dbo].[FactOECD]  WITH CHECK ADD  CONSTRAINT [FK_FactOECD_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactOECD] CHECK CONSTRAINT [FK_FactOECD_DimSubGroup]
GO
ALTER TABLE [dbo].[FactOPHI]  WITH CHECK ADD  CONSTRAINT [FK_FactOPHI_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactOPHI] CHECK CONSTRAINT [FK_FactOPHI_DimAge]
GO
ALTER TABLE [dbo].[FactOPHI]  WITH CHECK ADD  CONSTRAINT [FK_FactOPHI_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactOPHI] CHECK CONSTRAINT [FK_FactOPHI_DimCountry]
GO
ALTER TABLE [dbo].[FactOPHI]  WITH CHECK ADD  CONSTRAINT [FK_FactOPHI_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactOPHI] CHECK CONSTRAINT [FK_FactOPHI_DimDataSource]
GO
ALTER TABLE [dbo].[FactOPHI]  WITH CHECK ADD  CONSTRAINT [FK_FactOPHI_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactOPHI] CHECK CONSTRAINT [FK_FactOPHI_DimGender]
GO
ALTER TABLE [dbo].[FactOPHI]  WITH CHECK ADD  CONSTRAINT [FK_FactOPHI_DimIndicators] FOREIGN KEY([Indicator Code])
REFERENCES [dbo].[DimIndicators] ([ID])
GO
ALTER TABLE [dbo].[FactOPHI] CHECK CONSTRAINT [FK_FactOPHI_DimIndicators]
GO
ALTER TABLE [dbo].[FactOPHI]  WITH CHECK ADD  CONSTRAINT [FK_FactOPHI_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactOPHI] CHECK CONSTRAINT [FK_FactOPHI_DimSubGroup]
GO
ALTER TABLE [dbo].[FactSEDAC]  WITH CHECK ADD  CONSTRAINT [FK_FactSEDAC_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactSEDAC] CHECK CONSTRAINT [FK_FactSEDAC_DimAge]
GO
ALTER TABLE [dbo].[FactSEDAC]  WITH CHECK ADD  CONSTRAINT [FK_FactSEDAC_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactSEDAC] CHECK CONSTRAINT [FK_FactSEDAC_DimCountry]
GO
ALTER TABLE [dbo].[FactSEDAC]  WITH CHECK ADD  CONSTRAINT [FK_FactSEDAC_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactSEDAC] CHECK CONSTRAINT [FK_FactSEDAC_DimDataSource]
GO
ALTER TABLE [dbo].[FactSEDAC]  WITH CHECK ADD  CONSTRAINT [FK_FactSEDAC_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactSEDAC] CHECK CONSTRAINT [FK_FactSEDAC_DimGender]
GO
ALTER TABLE [dbo].[FactSEDAC]  WITH CHECK ADD  CONSTRAINT [FK_FactSEDAC_DimIndicators] FOREIGN KEY([Indicator Code])
REFERENCES [dbo].[DimIndicators] ([ID])
GO
ALTER TABLE [dbo].[FactSEDAC] CHECK CONSTRAINT [FK_FactSEDAC_DimIndicators]
GO
ALTER TABLE [dbo].[FactSEDAC]  WITH CHECK ADD  CONSTRAINT [FK_FactSEDAC_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactSEDAC] CHECK CONSTRAINT [FK_FactSEDAC_DimSubGroup]
GO
ALTER TABLE [dbo].[FactSpreedSheet]  WITH CHECK ADD  CONSTRAINT [FK_FactSpreedSheet_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactSpreedSheet] CHECK CONSTRAINT [FK_FactSpreedSheet_DimAge]
GO
ALTER TABLE [dbo].[FactSpreedSheet]  WITH CHECK ADD  CONSTRAINT [FK_FactSpreedSheet_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactSpreedSheet] CHECK CONSTRAINT [FK_FactSpreedSheet_DimCountry]
GO
ALTER TABLE [dbo].[FactSpreedSheet]  WITH CHECK ADD  CONSTRAINT [FK_FactSpreedSheet_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactSpreedSheet] CHECK CONSTRAINT [FK_FactSpreedSheet_DimDataSource]
GO
ALTER TABLE [dbo].[FactSpreedSheet]  WITH CHECK ADD  CONSTRAINT [FK_FactSpreedSheet_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactSpreedSheet] CHECK CONSTRAINT [FK_FactSpreedSheet_DimGender]
GO
ALTER TABLE [dbo].[FactSpreedSheet]  WITH CHECK ADD  CONSTRAINT [FK_FactSpreedSheet_DimIndicators] FOREIGN KEY([Indicator Code])
REFERENCES [dbo].[DimIndicators] ([ID])
GO
ALTER TABLE [dbo].[FactSpreedSheet] CHECK CONSTRAINT [FK_FactSpreedSheet_DimIndicators]
GO
ALTER TABLE [dbo].[FactSpreedSheet]  WITH CHECK ADD  CONSTRAINT [FK_FactSpreedSheet_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactSpreedSheet] CHECK CONSTRAINT [FK_FactSpreedSheet_DimSubGroup]
GO
ALTER TABLE [dbo].[FactSpreedSheet_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactSpreedSheet_Pivoted_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactSpreedSheet_Pivoted] CHECK CONSTRAINT [FK_FactSpreedSheet_Pivoted_DimAge]
GO
ALTER TABLE [dbo].[FactSpreedSheet_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactSpreedSheet_Pivoted_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactSpreedSheet_Pivoted] CHECK CONSTRAINT [FK_FactSpreedSheet_Pivoted_DimCountry]
GO
ALTER TABLE [dbo].[FactSpreedSheet_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactSpreedSheet_Pivoted_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactSpreedSheet_Pivoted] CHECK CONSTRAINT [FK_FactSpreedSheet_Pivoted_DimDataSource]
GO
ALTER TABLE [dbo].[FactSpreedSheet_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactSpreedSheet_Pivoted_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactSpreedSheet_Pivoted] CHECK CONSTRAINT [FK_FactSpreedSheet_Pivoted_DimGender]
GO
ALTER TABLE [dbo].[FactSpreedSheet_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactSpreedSheet_Pivoted_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactSpreedSheet_Pivoted] CHECK CONSTRAINT [FK_FactSpreedSheet_Pivoted_DimSubGroup]
GO
ALTER TABLE [dbo].[FactSubNational]  WITH CHECK ADD  CONSTRAINT [FK_FactSubNational_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactSubNational] CHECK CONSTRAINT [FK_FactSubNational_DimAge]
GO
ALTER TABLE [dbo].[FactSubNational]  WITH CHECK ADD  CONSTRAINT [FK_FactSubNational_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactSubNational] CHECK CONSTRAINT [FK_FactSubNational_DimCountry]
GO
ALTER TABLE [dbo].[FactSubNational]  WITH CHECK ADD  CONSTRAINT [FK_FactSubNational_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactSubNational] CHECK CONSTRAINT [FK_FactSubNational_DimDataSource]
GO
ALTER TABLE [dbo].[FactSubNational]  WITH CHECK ADD  CONSTRAINT [FK_FactSubNational_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactSubNational] CHECK CONSTRAINT [FK_FactSubNational_DimGender]
GO
ALTER TABLE [dbo].[FactSubNational]  WITH CHECK ADD  CONSTRAINT [FK_FactSubNational_DimIndicators] FOREIGN KEY([Indicator Code])
REFERENCES [dbo].[DimIndicators] ([ID])
GO
ALTER TABLE [dbo].[FactSubNational] CHECK CONSTRAINT [FK_FactSubNational_DimIndicators]
GO
ALTER TABLE [dbo].[FactSubNational]  WITH CHECK ADD  CONSTRAINT [FK_FactSubNational_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactSubNational] CHECK CONSTRAINT [FK_FactSubNational_DimSubGroup]
GO
ALTER TABLE [dbo].[FactWDI]  WITH CHECK ADD  CONSTRAINT [FK_FactWDI_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactWDI] CHECK CONSTRAINT [FK_FactWDI_DimAge]
GO
ALTER TABLE [dbo].[FactWDI]  WITH CHECK ADD  CONSTRAINT [FK_FactWDI_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactWDI] CHECK CONSTRAINT [FK_FactWDI_DimCountry]
GO
ALTER TABLE [dbo].[FactWDI]  WITH CHECK ADD  CONSTRAINT [FK_FactWDI_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactWDI] CHECK CONSTRAINT [FK_FactWDI_DimDataSource]
GO
ALTER TABLE [dbo].[FactWDI]  WITH CHECK ADD  CONSTRAINT [FK_FactWDI_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactWDI] CHECK CONSTRAINT [FK_FactWDI_DimGender]
GO
ALTER TABLE [dbo].[FactWDI]  WITH CHECK ADD  CONSTRAINT [FK_FactWDI_DimIndicators] FOREIGN KEY([Indicator Code])
REFERENCES [dbo].[DimIndicators] ([ID])
GO
ALTER TABLE [dbo].[FactWDI] CHECK CONSTRAINT [FK_FactWDI_DimIndicators]
GO
ALTER TABLE [dbo].[FactWDI]  WITH CHECK ADD  CONSTRAINT [FK_FactWDI_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactWDI] CHECK CONSTRAINT [FK_FactWDI_DimSubGroup]
GO
ALTER TABLE [dbo].[FactWDI_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactWDI_Pivoted_DimAge] FOREIGN KEY([Age])
REFERENCES [dbo].[DimAge] ([ID])
GO
ALTER TABLE [dbo].[FactWDI_Pivoted] CHECK CONSTRAINT [FK_FactWDI_Pivoted_DimAge]
GO
ALTER TABLE [dbo].[FactWDI_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactWDI_Pivoted_DimCountry] FOREIGN KEY([Country Code])
REFERENCES [dbo].[DimCountry] ([ID])
GO
ALTER TABLE [dbo].[FactWDI_Pivoted] CHECK CONSTRAINT [FK_FactWDI_Pivoted_DimCountry]
GO
ALTER TABLE [dbo].[FactWDI_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactWDI_Pivoted_DimDataSource] FOREIGN KEY([DataSourceID])
REFERENCES [dbo].[DimDataSource] ([ID])
GO
ALTER TABLE [dbo].[FactWDI_Pivoted] CHECK CONSTRAINT [FK_FactWDI_Pivoted_DimDataSource]
GO
ALTER TABLE [dbo].[FactWDI_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactWDI_Pivoted_DimGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[DimGender] ([ID])
GO
ALTER TABLE [dbo].[FactWDI_Pivoted] CHECK CONSTRAINT [FK_FactWDI_Pivoted_DimGender]
GO
ALTER TABLE [dbo].[FactWDI_Pivoted]  WITH CHECK ADD  CONSTRAINT [FK_FactWDI_Pivoted_DimSubGroup] FOREIGN KEY([SubGroup])
REFERENCES [dbo].[DimSubGroup] ([ID])
GO
ALTER TABLE [dbo].[FactWDI_Pivoted] CHECK CONSTRAINT [FK_FactWDI_Pivoted_DimSubGroup]
GO
/****** Object:  StoredProcedure [dbo].[CategoriesOfTypeGeo]    Script Date: 9/24/2015 9:02:48 AM ******/
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

GO
/****** Object:  StoredProcedure [dbo].[ChangeIndexAndConstraint]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ChangeIndexAndConstraint]
	@type VARCHAR(100),
	@dataSource VARCHAR(100)
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @factTableName VARCHAR(100)
				,@factTablePivotedName VARCHAR(100)

		SELECT @factTableName = FactTableName
			   ,@factTablePivotedName = FactTablePivotedName
		FROM DimDataSource
		WHERE DataSource = @dataSource;
		
		DECLARE @tableName VARCHAR(100)
		DECLARE	@dyn_sql NVARCHAR(MAX)

		IF(@type = 'CREATE')
			BEGIN
				
				------ Fact Table Normal -----
				SET @tableName = @factTableName

				IF @tableName IS NULL RETURN;

				SET @dyn_sql=N'
				CREATE NONCLUSTERED INDEX NON_'+@tableName+'_VersionID
				ON dbo.' + @tableName + ' ([VersionID])
				INCLUDE( [country code], [period], [indicator code],[SubGroup],[Age],[Gender],[Value])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				CREATE NONCLUSTERED INDEX NON_'+@tableName+'_DataSourceID
				ON dbo.' + @tableName + ' ([DataSourceID])
				INCLUDE( [country code], [period], [indicator code],[SubGroup],[Age],[Gender],[Value])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				CREATE NONCLUSTERED INDEX NON_'+@tableName+'_Period
				ON dbo.'+@tableName+' ([Period])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				CREATE NONCLUSTERED INDEX ix_fact_'+@tableName+'  
				ON '+@tableName+' ([datasourceid], [country code], [period], [indicator code],[SubGroup],[Age],[Gender] ) 
				INCLUDE([Value])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				ALTER TABLE [dbo].['+@tableName+']  WITH CHECK ADD  CONSTRAINT [FK_'+@tableName+'_DimCountry] FOREIGN KEY([Country Code])
				REFERENCES [dbo].[DimCountry] ([ID])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				ALTER TABLE [dbo].['+@tableName+']  WITH CHECK ADD  CONSTRAINT [FK_'+@tableName+'_DimDataSource] FOREIGN KEY([DataSourceID])
				REFERENCES [dbo].[DimDataSource] ([ID])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				ALTER TABLE [dbo].['+@tableName+']  WITH CHECK ADD  CONSTRAINT [FK_'+@tableName+'_DimIndicators] FOREIGN KEY([Indicator Code])
				REFERENCES [dbo].[DimIndicators] ([ID])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				ALTER TABLE [dbo].['+@tableName+']  WITH CHECK ADD  CONSTRAINT [FK_'+@tableName+'_DimAge] FOREIGN KEY([Age])
				REFERENCES [dbo].[DimAge] ([ID])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				ALTER TABLE [dbo].['+@tableName+']  WITH CHECK ADD  CONSTRAINT [FK_'+@tableName+'_DimGender] FOREIGN KEY([Gender])
				REFERENCES [dbo].[DimGender] ([ID])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				ALTER TABLE [dbo].['+@tableName+']  WITH CHECK ADD  CONSTRAINT [FK_'+@tableName+'_DimSubGroup] FOREIGN KEY([SubGroup])
				REFERENCES [dbo].[DimSubGroup] ([ID])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				------ Fact Table Pivoted -----
				SET @tableName = @factTablePivotedName

				IF @tableName IS NULL RETURN;

				SET @dyn_sql=N'
				CREATE NONCLUSTERED INDEX NON_'+@tableName+'_VersionID
				ON dbo.' + @tableName + ' ([VersionID])
				INCLUDE( [country code], [period], [SubGroup],[Age],[Gender])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				CREATE NONCLUSTERED INDEX NON_'+@tableName+'_Period
				ON dbo.'+@tableName+' ([Period])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql
				
				SET @dyn_sql=N'
				ALTER TABLE [dbo].['+@tableName+']  WITH CHECK ADD  CONSTRAINT [FK_'+@tableName+'_DimCountry] FOREIGN KEY([Country Code])
				REFERENCES [dbo].[DimCountry] ([ID])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				ALTER TABLE [dbo].['+@tableName+']  WITH CHECK ADD  CONSTRAINT [FK_'+@tableName+'_DimDataSource] FOREIGN KEY([DataSourceID])
				REFERENCES [dbo].[DimDataSource] ([ID])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				ALTER TABLE [dbo].['+@tableName+']  WITH CHECK ADD  CONSTRAINT [FK_'+@tableName+'_DimAge] FOREIGN KEY([Age])
				REFERENCES [dbo].[DimAge] ([ID])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				ALTER TABLE [dbo].['+@tableName+']  WITH CHECK ADD  CONSTRAINT [FK_'+@tableName+'_DimGender] FOREIGN KEY([Gender])
				REFERENCES [dbo].[DimGender] ([ID])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				ALTER TABLE [dbo].['+@tableName+']  WITH CHECK ADD  CONSTRAINT [FK_'+@tableName+'_DimSubGroup] FOREIGN KEY([SubGroup])
				REFERENCES [dbo].[DimSubGroup] ([ID])
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

			END

		ELSE
			BEGIN
				-- Fact Table Normal ---
				SET @tableName = @factTableName

				IF @tableName IS NULL RETURN;

				SET @dyn_sql=N'
				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id(''dbo.'+@tableName+''') 
					AND NAME =''NON_'+@tableName+'_VersionID'')
					DROP INDEX NON_'+@tableName+'_VersionID ON dbo.'+@tableName+'
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id(''dbo.'+@tableName+''') 
					AND NAME =''NON_'+@tableName+'_DataSourceID'')
					DROP INDEX NON_'+@tableName+'_DataSourceID ON dbo.'+@tableName+'
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id(''dbo.'+@tableName+''') 
					AND NAME =''NON_'+@tableName+'_Period'')
					DROP INDEX NON_'+@tableName+'_Period ON dbo.'+@tableName+'
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id(''dbo.'+@tableName+''') 
					AND NAME =''ix_fact_'+@tableName+''')
					DROP INDEX ix_fact_'+@tableName+' ON dbo.'+@tableName+'
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = ''FK_'+@tableName+'_DimCountry'')
					ALTER TABLE [dbo].['+@tableName+'] DROP CONSTRAINT [FK_'+@tableName+'_DimCountry]
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = ''FK_'+@tableName+'_DimDataSource'')
					ALTER TABLE [dbo].['+@tableName+'] DROP CONSTRAINT [FK_'+@tableName+'_DimDataSource]
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = ''FK_'+@tableName+'_DimIndicators'')
					ALTER TABLE [dbo].['+@tableName+'] DROP CONSTRAINT [FK_'+@tableName+'_DimIndicators]
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = ''FK_'+@tableName+'_DimAge'')
					ALTER TABLE [dbo].['+@tableName+'] DROP CONSTRAINT [FK_'+@tableName+'_DimAge]
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = ''FK_'+@tableName+'_DimGender'')
					ALTER TABLE [dbo].['+@tableName+'] DROP CONSTRAINT [FK_'+@tableName+'_DimGender]
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = ''FK_'+@tableName+'_DimSubGroup'')
					ALTER TABLE [dbo].['+@tableName+'] DROP CONSTRAINT [FK_'+@tableName+'_DimSubGroup]
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				-- Fact Table Pivoted ---
				SET @tableName = @factTablePivotedName

				IF @tableName IS NULL RETURN;

				SET @dyn_sql=N'
				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id(''dbo.'+@tableName+''') 
					AND NAME =''NON_'+@tableName+'_VersionID'')
					DROP INDEX NON_'+@tableName+'_VersionID ON dbo.'+@tableName+'
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id(''dbo.'+@tableName+''') 
					AND NAME =''NON_'+@tableName+'_Period'')
					DROP INDEX NON_'+@tableName+'_Period ON dbo.'+@tableName+'
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = ''FK_'+@tableName+'_DimCountry'')
					ALTER TABLE [dbo].['+@tableName+'] DROP CONSTRAINT [FK_'+@tableName+'_DimCountry]
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = ''FK_'+@tableName+'_DimDataSource'')
					ALTER TABLE [dbo].['+@tableName+'] DROP CONSTRAINT [FK_'+@tableName+'_DimDataSource]
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = ''FK_'+@tableName+'_DimAge'')
					ALTER TABLE [dbo].['+@tableName+'] DROP CONSTRAINT [FK_'+@tableName+'_DimAge]
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = ''FK_'+@tableName+'_DimGender'')
					ALTER TABLE [dbo].['+@tableName+'] DROP CONSTRAINT [FK_'+@tableName+'_DimGender]
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

				SET @dyn_sql=N'
				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = ''FK_'+@tableName+'_DimSubGroup'')
					ALTER TABLE [dbo].['+@tableName+'] DROP CONSTRAINT [FK_'+@tableName+'_DimSubGroup]
				'
				EXECUTE SP_EXECUTESQL @dyn_sql

			END

END


GO
/****** Object:  StoredProcedure [dbo].[CleanTables]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[CleanTables] as

declare @cmd varchar(4000)
declare cmds cursor for 
select 'drop table [' + Table_Name + ']'
from INFORMATION_SCHEMA.TABLES
where Table_Name like 'SumTable%'

open cmds
while 1=1
begin
    fetch cmds into @cmd
    if @@fetch_status != 0 break
    exec(@cmd)
end
close cmds;
deallocate cmds

--declare @cmd varchar(4000)
declare cmds cursor for 
select 'drop table [' + Table_Name + ']'
from INFORMATION_SCHEMA.TABLES
where Table_Name like 'WithAllData%'

open cmds
while 1=1
begin
    fetch cmds into @cmd
    if @@fetch_status != 0 break
    exec(@cmd)
end
close cmds;
deallocate cmds



GO
/****** Object:  StoredProcedure [dbo].[GeoEntitiesQuery]    Script Date: 9/24/2015 9:02:48 AM ******/
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
			if((select count(*) from #wherecat)>0 AND (SELECT top 1 name FROM #wherecat)!='')
			begin
			
				;with cte (id, cat, rnk)as
				(
					select cast(id as nvarchar(255)) id 
					,cast(cat as nvarchar(255))cat 
					,geo.lev rnk
					from DimGeo geo 
					inner join #wheregeo wg on geo.id = wg.name

					union all

					select g.id
					,g.cat
					,c.rnk+1
					from DimGeo g 
					inner join cte c on g.region = c.id
					where g.lev = c.rnk+1
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
/****** Object:  StoredProcedure [dbo].[getAllData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[getAllData]
@type int,
@id int,
@startDate int = NULL,
@endDate int = NULL
as
	set @startDate = ISNULL(@startDate,1000)
	set @endDate = ISNULL(@endDate, 2100)
	if (@type = 1)
	begin
		select fd.country [Geo], fd.period [Time], fd.value [Value],'' Region
		from dbo.SpreedSheetFactData  fd --left join dbo.Indicator id
		--on fd.pathID = id.ID
		where fd.pathID = @id
		and fd.period between @startDate and @endDate
	end
	else
	begin
		if (@type = 2)
		begin
			select fd.country [Geo], fd.period [Time], fd.value [Value], '' Region
			from dbo.WDI_FactData fd --left join dbo.Indicator id
			--on fd.pathID = id.ID
			where fd.pathID = @id
			and fd.period between @startDate and @endDate
		end
		else
		begin
			select sd.[Country Name] [Geo],sd.period [Time],sd.value [Value], sd.Region 
			from SubNationalData sd left join dbo.SubNationalIndicator si
			on sd.[Indicator Name] = si.[indicator]
			where si.ID = @id
			and Region is not null
			and sd.period between @startDate and @endDate
		end
	end
	




GO
/****** Object:  StoredProcedure [dbo].[GetDimensionDetails]    Script Date: 9/24/2015 9:02:48 AM ******/
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
/****** Object:  StoredProcedure [dbo].[IncomeMountainQuery]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[IncomeMountainQuery]
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
	declare @dropT nvarchar(max)
	declare @newId nvarchar(max)
	set @newId = newid()

	declare @factTable nvarchar(max)
	set @factTable = 'FactFinal'

	begin try
		insert into #select
		select x.col.value('.', 'varchar(100)') AS [text()]
		FROM @XmlStr.nodes('//root//query//SELECT') x(col)

		--select * from #select 

		select s.* into #A 
		from #select s left join vDimDetails d
		on s.name = d.[-t-id]
		where d.[-t-id] is null

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
		
		insert into #whereind
		select s.name
		from #select s left join vDimDetails d
		on s.name = d.[-t-id]
		where d.[-t-id] is null

		
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

		
		declare @colInQuerySelection nvarchar(max)
		select @colInQuerySelection = STUFF((
		select (',' + dd.cName + '[' + s.name + ']' ) as [text()]
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
		select (',' + '[' + s.name + ']') as [text()]
		from #whereind s
		for xml path ('')),1,1,'')

		DECLARE @parmDefinition nvarchar(500);
		set @parmDefinition = N'@start int, @end int'

		
		set @dyn_sql = N'
			select ' + @colInFinalSelect + ','  + @indColInSelect + ' 
			from (
				select ''world'' [geo], ''World'' [geo.name], ''world'' [geo.cat], null [geo.region], i.Period [time]
				, indicator [Indicator Code], MountainShape from IncomeMountain i
				, #time t
				where i.Period = t.Period
			)A 
			pivot
			(
				max(MountainShape)
				for [Indicator Code] in (' + @indCol + ')
			) as pvt
		'
		--print @dyn_sql
		execute sp_executesql @dyn_sql

		
	end try
	begin catch
		select null geo, ERROR_MESSAGE() [geo.name], null [time]
	end catch

end




GO
/****** Object:  StoredProcedure [dbo].[IndexAndConstraint]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[IndexAndConstraint]
	@type VARCHAR(100)
AS
BEGIN
		SET NOCOUNT ON;
		IF(@type = 'CREATE')
			BEGIN
				/*
				CREATE NONCLUSTERED INDEX NON_DimGeo_ID
				ON dbo.DimGeo (id)
				INCLUDE (name,region)

				CREATE NONCLUSTERED INDEX NON_DimCountry_CountryCode
				ON dbo.DimCountry ([Country Code])
				INCLUDE (ID,[Short Name])

				CREATE NONCLUSTERED INDEX NON_DimIndicators_IndicatorCode
				ON dbo.DimIndicators ([Indicator Code])
				INCLUDE ([ID])

				CREATE NONCLUSTERED INDEX NON_DimSubGroup_SubGroup
				ON dbo.DimSubGroup ([SubGroup])
				INCLUDE ([ID])

				CREATE NONCLUSTERED INDEX NON_DimAge_Age
				ON dbo.DimAge ([age])
				INCLUDE ([ID])

				CREATE NONCLUSTERED INDEX NON_DimGender_Gender
				ON dbo.DimGender ([gender])
				INCLUDE ([ID])*/

				CREATE NONCLUSTERED INDEX NON_DimGeo_Region
				ON dbo.DimGeo ([Region])

				CREATE NONCLUSTERED INDEX NON_FactFinal_DataSourceID
				ON dbo.FactFinal ([DataSourceID])
				INCLUDE( [country code], [period], [indicator code],[SubGroup],[Age],[Gender],[Value])

				CREATE NONCLUSTERED INDEX NON_FactFinal_Period
				ON dbo.FactFinal ([Period])

				CREATE NONCLUSTERED INDEX ix_fact 
				ON factfinal ([datasourceid], [country code], [period], [indicator code],[SubGroup],[Age],[Gender] ) 
				INCLUDE([Value])

				ALTER TABLE [dbo].[FactFinal]  WITH CHECK ADD  CONSTRAINT [FK_FactFinal_DimCountry] FOREIGN KEY([Country Code])
				REFERENCES [dbo].[DimCountry] ([ID])
				--ALTER TABLE [dbo].[FactFinal] CHECK CONSTRAINT [FK_FactFinal_DimCountry]
				ALTER TABLE [dbo].[FactFinal]  WITH CHECK ADD  CONSTRAINT [FK_FactFinal_DimDataSource] FOREIGN KEY([DataSourceID])
				REFERENCES [dbo].[DimDataSource] ([ID])
				--ALTER TABLE [dbo].[FactFinal] CHECK CONSTRAINT [FK_FactFinal_DimDataSource]
				ALTER TABLE [dbo].[FactFinal]  WITH CHECK ADD  CONSTRAINT [FK_FactFinal_DimIndicators] FOREIGN KEY([Indicator Code])
				REFERENCES [dbo].[DimIndicators] ([ID])
				--ALTER TABLE [dbo].[FactFinal] CHECK CONSTRAINT [FK_FactFinal_DimIndicators]
				ALTER TABLE [dbo].[FactFinal]  WITH CHECK ADD  CONSTRAINT [FK_FactFinal_DimAge] FOREIGN KEY([Age])
				REFERENCES [dbo].[DimAge] ([ID])
				--ALTER TABLE [dbo].[FactFinal] CHECK CONSTRAINT [FK_FactFinal_DimAge]
				ALTER TABLE [dbo].[FactFinal]  WITH CHECK ADD  CONSTRAINT [FK_FactFinal_DimGender] FOREIGN KEY([Gender])
				REFERENCES [dbo].[DimGender] ([ID])
				--ALTER TABLE [dbo].[FactFinal] CHECK CONSTRAINT [FK_FactFinal_DimGender]
			END

		ELSE
			BEGIN
				/*
				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.DimGeo') 
					AND NAME ='NON_DimGeo_ID')
					DROP INDEX NON_DimGeo_ID ON dbo.DimGeo

				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.DimCountry') 
					AND NAME ='NON_DimCountry_CountryCode')
					DROP INDEX NON_DimCountry_CountryCode ON dbo.DimCountry

				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.DimIndicators') 
					AND NAME ='NON_DimIndicators_IndicatorCode')
					DROP INDEX NON_DimIndicators_IndicatorCode ON dbo.DimIndicators

				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.DimSubGroup') 
					AND NAME ='NON_DimSubGroup_SubGroup')
					DROP INDEX NON_DimSubGroup_SubGroup ON dbo.DimSubGroup

				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.DimAge') 
					AND NAME ='NON_DimAge_Age')
					DROP INDEX NON_DimAge_Age ON dbo.DimAge

				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.DimGender') 
					AND NAME ='NON_DimGender_Gender')
					DROP INDEX NON_DimGender_Gender ON dbo.DimGender*/

				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.DimGeo') 
					AND NAME ='NON_DimGeo_Region')
					DROP INDEX NON_DimGeo_Region ON dbo.DimGeo

				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.FactFinal') 
					AND NAME ='NON_FactFinal_DataSourceID')
					DROP INDEX NON_FactFinal_DataSourceID ON dbo.FactFinal

				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.FactFinal') 
					AND NAME ='NON_FactFinal_Period')
					DROP INDEX NON_FactFinal_Period ON dbo.FactFinal

				IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.FactFinal') 
					AND NAME ='ix_fact')
					DROP INDEX ix_fact ON dbo.FactFinal

				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FactFinal_DimCountry')
					ALTER TABLE [dbo].[FactFinal] DROP CONSTRAINT [FK_FactFinal_DimCountry]

				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FactFinal_DimDataSource')
					ALTER TABLE [dbo].[FactFinal] DROP CONSTRAINT [FK_FactFinal_DimDataSource]

				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FactFinal_DimIndicators')
					ALTER TABLE [dbo].[FactFinal] DROP CONSTRAINT [FK_FactFinal_DimIndicators]

				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FactFinal_DimAge')
					ALTER TABLE [dbo].[FactFinal] DROP CONSTRAINT [FK_FactFinal_DimAge]
				
				IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FactFinal_DimGender')
					ALTER TABLE [dbo].[FactFinal] DROP CONSTRAINT [FK_FactFinal_DimGender]

			END

END


GO
/****** Object:  StoredProcedure [dbo].[PostProcessFactPivot]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[PostProcessFactPivot]
	@dataSource VARCHAR(100) = 'SpreedSheet',
	@versionNo VARCHAR(10) = '1'
AS
BEGIN

	DECLARE @dataSourceID VARCHAR(10)
			,@factTableName VARCHAR(100)
			,@factTablePivotedName VARCHAR(100)
			,@dropT VARCHAR(100)

		SELECT @dataSourceID = ID
			   ,@factTableName = FactTableName
			   ,@factTablePivotedName = FactTablePivotedName
		FROM DimDataSource
		WHERE DataSource = @dataSource

		DECLARE @indicators NVARCHAR(MAX)
				,@dyn_sql NVARCHAR(MAX)

		SELECT @indicators = STUFF((
		SELECT (',[' + I.IndicatorCode + ']' ) AS [text()]
		FROM UtilityCommonlyUsedIndicators I
		WHERE DataSourceID = @dataSourceID
		FOR XML PATH ('')),1,1,'')

		SET @dyn_sql = N'
			DELETE FROM ' + @factTablePivotedName + ' WHERE VersionID = ' + @versionNo + '
		'
		EXECUTE SP_EXECUTESQL @dyn_sql
		
		--SET @dropT = 'drop TABLE [' + @factTablePivotedName + ']'
		--IF OBJECT_ID('' + @factTablePivotedName + '', 'U') IS NOT NULL
		--		EXEC(@dropT)

		SET @dyn_sql = N'
			INSERT INTO ' + @factTablePivotedName + ' 
			([VersionID],DataSourceID, [Country Code], Period,SubGroup,Age,Gender,'+ @indicators + ')
			select [VersionID],DataSourceID, [Country Code], Period,SubGroup,Age,Gender,'+ @indicators + '
			from (
				select F.[VersionID],f.DataSourceID, f.[Country Code], f.Period,f.SubGroup,
				f.Age,f.Gender,i.[Indicator Code],f.Value
				from ' + @factTableName + ' f
				left join (
						select di.ID,di.[Indicator Code] 
						from DimIndicators di 
						LEFT JOIN UtilityCommonlyUsedIndicators ci
						ON di.[Indicator Code] = ci.IndicatorCode
						WHERE di.DataSourceID = ' + @dataSourceID + '
						AND ci.DataSourceID = ' + @dataSourceID + '
						AND ci.ID IS NOT NULL
				) i
				ON f.[Indicator Code] = i.ID
			)A
			pivot(
				sum(value)
				for [Indicator Code] in ('+ @indicators + ')
			) as pvt
		'
		EXECUTE SP_EXECUTESQL @dyn_sql

END


GO
/****** Object:  StoredProcedure [dbo].[PreProcessDevInfoData]    Script Date: 9/24/2015 9:02:48 AM ******/
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
		--DROP TABLE #A
		SELECT Area, AreaCode
		INTO #A
		FROM dbo.AllDevInfoRawData 
		GROUP BY Area, AreaCode

		--DROP TABLE #C
		SELECT Area, AreaCode,c.lev,c.cat INTO #C
		FROM #A g LEFT JOIN (
			SELECT * FROM DimGeo WHERE cat = 'country'
		) c
		ON LEFT(areacode,3) = c.id
		WHERE ISNUMERIC(LEFT(AreaCode, 3)) = 0
		AND C.ID IS NOT NULL
		
		--DROP TABLE #B
		SELECT CAST(LEFT(areacode,3) AS VARCHAR(100)) iso
			, 3 l, 1 rnk, CAST('country' AS VARCHAR(100)) cat
			INTO #B
		FROM #A
		WHERE ISNUMERIC(LEFT(areacode,3)) = 0
		AND LEN(AreaCode) = 3
		group by LEFT(areacode,3)

		INSERT INTO #B
		SELECT *,
		CASE rnk WHEN 1 THEN 'province'
				WHEN 2 THEN 'territory'
				WHEN 3 THEN 'sub territory'
				WHEN 4 THEN 'brick' end cat
		FROM (
		SELECT iso, l, row_number() OVER(PARTITION BY iso ORDER BY l) rnk 
		FROM (
			SELECT DENSE_RANK() OVER(PARTITION BY LEFT(areacode,3), LEN(areacode) ORDER BY area)
			rnk,
			LEN(areacode) l, 
			LEFT(areacode,3) iso, *
			FROM #A
			WHERE ISNUMERIC(LEFT(areacode,3)) = 0
			AND LEN(AreaCode) > 3
			)A WHERE rnk = 1
		)B
		
		--SELECT * FROM #B
		--SELECT * FROM #C
		;WITH cte (code,name,parent,rnk, cat)
		AS
		(
			SELECT CAST(areacode AS VARCHAR(100)), CAST(area AS VARCHAR(100)), CAST(b.iso AS VARCHAR(100)), b.rnk
			,b.cat
			FROM #C c inner join #B b
			ON LEN(c.areacode) = b.l
			AND LEFT(c.areacode, b.l) LIKE b.iso + '%'
			WHERE b.cat = 'province'

			UNION ALL

			SELECT CAST(areacode AS VARCHAR(100)), CAST(area AS VARCHAR(100)), CAST(ct.code AS VARCHAR(100)), ct.rnk + 1
			,b.cat
			FROM #C c inner join cte ct
			ON c.areacode LIKE ct.code + '%'
			inner join #B b
			ON LEN(c.areacode) = b.l
			AND LEFT(c.areacode, b.l) LIKE b.iso + '%'
			WHERE b.rnk = ct.rnk + 1
			AND ct.rnk < 7
		)
		
		SELECT 'geo' dim,code id, name, parent region,cat, g.GeoLevelNo lev, 
				NULL lat, NULL long
				INTO #final
		FROM cte c INNER JOIN GeoHierarchyLevel g
		ON c.cat = g.GeoLevelName

		MERGE DimGeo T
		USING (
			SELECT * FROM #final
		) S
		ON (T.id = S.id AND T.cat = S.cat)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES(S.dim,LOWER(S.id),S.name,LOWER(S.region),S.cat,S.lev);
		
		MERGE dbo.DimCountry T
		USING (
			SELECT * FROM #final
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		TRUNCATE TABLE DBO.DimSubGroup
		INSERT INTO DimSubGroup (SubGroup)
		SELECT 'N/A'
		UNION ALL
		SELECT SUBGROUP
		FROM AllDevInfoRawData
		GROUP BY Subgroup

		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = 6

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 6,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM dbo.AllDevInfoRawData 
		GROUP BY Indicator

		--DROP INDEX ix_fact ON FactFinal

		DELETE FROM FactFinal
		WHERE DataSourceID = 6

		INSERT INTO FactFinal 
					([datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					SubGroup,
					[value]) 
		SELECT 6,c.ID, r.Year, i.ID, s.ID, TRY_CONVERT(float,r.DataValue)
		FROM dbo.AllDevInfoRawData  r 
		LEFT JOIN (
			SELECT * FROM DimIndicators WHERE DataSourceID = 6
		) i
			ON r.Indicator = i.[Indicator Name]
		LEFT JOIN DimSubGroup s
			ON r.Subgroup = s.SubGroup
		LEFT JOIN DimCountry c
			ON r.AreaCode = c.[Country Code]
		WHERE i.id IS NOT NULL
		AND c.id IS NOT NULL
		AND S.ID IS NOT NULL

		--CREATE NONCLUSTERED INDEX ix_fact 
		--ON factfinal ([datasourceid], [country code], [period], [indicator code],[SubGroup] ) 
		--INCLUDE([Value])

END


GO
/****** Object:  StoredProcedure [dbo].[PreProcessDHSData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessDHSData]
AS
BEGIN
	
			SET NOCOUNT ON;
			--DROP #MICS
			SELECT Stratifier 
			,Country
			,CASE Stratifier
				WHEN 'gregion' THEN IndPostfix
				ELSE Country END Region
			,CASE Stratifier
				WHEN 'sex' THEN IndPostfix
				ELSE 'N/A' END Gender
			,[Year]
			,CASE Stratifier
				WHEN 'area' THEN IndPostfix
				WHEN 'meduc' THEN IndPostfix
				WHEN 'wiq' THEN IndPostfix
				ELSE 'N/A' END SubGroup
			,CASE Stratifier
				WHEN 'mage' THEN REPLACE(Stratifier_type,' '+IndPostfix,'')
				ELSE 'N/A' END AgeGroup
			,Indicator
			,DataValue
			--,Indicator2
			INTO #MICS
			FROM (
			SELECT DataSheetName,Country,[Year],Indicator,Stratifier,Stratifier_type, Indicator2
			,SUBSTRING(Stratifier_type, CHARINDEX(' ',Stratifier_type,1)+1, LEN(Stratifier_type)) IndPostfix
			,DataValue 
			FROM [Gapminder_RAW].[dhs].[MICS_RawData]
			WHERE Indicator2 IN ('r','')
			--AND Indicator = 'anc4'
			--AND Country = 'Bhutan'
			)A
			ORDER BY Stratifier

			--DROP TABLE #GEO
			SELECT Country CountryMain, Region RegionMain, REPLACE(Country,'_',' ') Country, LTRIM(SUBSTRING(Region, CHARINDEX(']',Region,1)+1, LEN(Region))) REGION
			,CAST(NULL AS VARCHAR(100)) ISO, CAST(NULL AS VARCHAR(100)) ISO_REGION
			INTO #GEO
			FROM #MICS
			WHERE Country <> Region
			GROUP BY COUNTRY,Region

			UPDATE G
			SET G.ISO = DG.id
			FROM #GEO G INNER JOIN DimGeo DG
			ON G.Country = DG.name
			WHERE DG.cat = 'Country'

			UPDATE G
			SET G.ISO_REGION = DG.id
			FROM #GEO G INNER JOIN DimGeo DG
			ON G.ISO = DG.region
			AND G.REGION = DG.name
			WHERE DG.cat = 'province'
			AND G.ISO IS NOT NULL

			UPDATE  G
			SET G.ISO_REGION = ISO+'-'+LOWER(REGION)
			FROM #GEO G
			WHERE ISO IS NOT NULL
			AND ISO_REGION IS NULL

			DELETE FROM #GEO
			WHERE ISO IS NULL

			MERGE DimGeo T
			USING (
				SELECT * FROM #GEO
			) S
			ON (T.id = S.ISO_REGION AND T.region = S.ISO AND T.cat = 'province')
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(dim,id,name,region,cat,lev) 
				VALUES('geo',LOWER(S.ISO_REGION),S.REGION,LOWER(S.region),'province',4);
		
			MERGE dbo.DimCountry T
			USING (
				SELECT * FROM #Geo
			) S
			ON (T.[Country Code] = S.ISO_REGION)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT([type],[Country Code],[Short Name],[Country Name]) 
				VALUES('province',LOWER(S.ISO_REGION),S.REGION,S.REGION);

			MERGE [dbo].[DimSubGroup] T
			USING (
				SELECT SubGroup FROM #MICS
				GROUP BY SubGroup
			) S
			ON (T.SubGroup = S.SubGroup)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(SubGroup) 
				VALUES(S.SubGroup);

			MERGE [dbo].[DimAge] T
			USING (
				SELECT AgeGroup FROM #MICS
				GROUP BY AgeGroup
			) S
			ON (T.age = S.AgeGroup)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(age) 
				VALUES(S.AgeGroup);

			DELETE FROM [dbo].[DimIndicators]
			WHERE DataSourceID = 13

			INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
			SELECT 13,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
			FROM #MICS 
			GROUP BY Indicator

			DELETE FROM FactFinal
			WHERE DataSourceID = 13

			INSERT INTO FactFinal 
						([datasourceid], 
						[country code], 
						period, 
						[indicator code], 
						SubGroup,
						Age,
						Gender,
						[value]) 
			SELECT 13,c.ID, LEFT(r.[Year],4), i.ID, s.ID, ag.ID, gen.ID, r.DataValue
			FROM (
				SELECT ISO id, Indicator, SubGroup, AgeGroup, Gender, [Year], TRY_CONVERT(float,DataValue) DataValue
				FROM #MICS f LEFT JOIN (SELECT ISO,CountryMain FROM #GEO GROUP BY ISO,CountryMain) g
				ON f.Country = g.CountryMain
				--AND f.Region = g.RegionMain
				WHERE Stratifier <> 'gregion'
				AND G.ISO IS NOT NULL

				UNION ALL

				SELECT ISO id, Indicator, SubGroup, AgeGroup, Gender, [Year], TRY_CONVERT(float,DataValue) DataValue
				FROM #MICS f LEFT JOIN (
					SELECT ISO_REGION ISO,CountryMain,RegionMain FROM #GEO 
					GROUP BY ISO_REGION,CountryMain,RegionMain
				) g
				ON f.Country = g.CountryMain
				AND f.Region = g.RegionMain
				WHERE Stratifier = 'gregion'
				AND G.ISO IS NOT NULL
			)
			r 
			LEFT JOIN (
				SELECT * FROM DimIndicators WHERE DataSourceID = 13
			) i
				ON r.Indicator = i.[Indicator Name]
			LEFT JOIN DimSubGroup s
				ON r.Subgroup = s.SubGroup
			LEFT JOIN DimCountry c
				ON r.id = c.[Country Code]
			LEFT JOIN DimAge ag
				ON r.AgeGroup = ag.age
			LEFT JOIN DimGender gen
				ON r.gender = gen.gender
			--WHERE i.id IS NOT NULL
			--AND c.id IS NOT NULL
			--AND S.ID IS NOT NULL
			--AND gen.ID IS NOT NULL
			
			--DROP TABLE #NATIONAL
			SELECT CASE CountryName
				WHEN 'KYRGYZSTAN' THEN 'Kyrgyz Republic'
				WHEN 'CONGO (Kinshasa)' THEN 'Dem. Rep. Congo'
				WHEN 'CONGO (Brazzaville)' THEN 'Rep. Congo'
				ELSE REPLACE(CountryName,'&','AND') END
			CountryName
			,[Year]
			,[Indicator]
			,TRY_CONVERT(float,DataValue) DataValue
			INTO #NATIONAL
			FROM [Gapminder_RAW].dhs.Spatial_National_Raw_Data

			INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
			SELECT 13,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
			FROM #NATIONAL 
			GROUP BY Indicator

			INSERT INTO factfinal 
					([datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					[value]) 
			SELECT 13, c.ID, r.[Year], i.ID, r.DataValue
			FROM ( 
				SELECT * 
				FROM #NATIONAL
			
			)r 
			LEFT JOIN (
				SELECT * FROM DimIndicators WHERE DataSourceID = 13
			) i
				ON r.Indicator = i.[Indicator Name]
			LEFT JOIN (
				SELECT * FROM DimCountry WHERE [type] = 'country'
			)c
				ON r.CountryName = c.[Short Name]


END


GO
/****** Object:  StoredProcedure [dbo].[PreProcessGECONData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessGECONData]
AS
BEGIN
		SET NOCOUNT ON;
		SELECT TOP 2 * 
		FROM [Gapminder_RAW].[gecon].[Raw_Data]
		
		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = 14

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 14,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM [Gapminder_RAW].[gecon].[Raw_Data] 
		GROUP BY Indicator

		DELETE FROM FactFinal
		WHERE DataSourceID = 14
		
		INSERT INTO factfinal 
					([datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					[value]) 
			SELECT 14, c.ID, r.Period, i.ID, r.DataValue
			FROM ( 
					SELECT CASE Country
					WHEN 'KYRGYZSTAN' THEN 'Kyrgyz Republic'
					WHEN 'Slovakia' THEN 'Slovak Republic'
					WHEN 'CONGO' THEN 'Rep. Congo'
					WHEN 'SouthAfrica' THEN 'South Africa'
					WHEN 'Central Africa' THEN 'Central African Republic'
					WHEN 'Czech' THEN 'Czech Republic'
					WHEN 'UK' THEN 'United Kingdom'
					ELSE Country END
					Country
					,Period
					,Indicator
					,TRY_CONVERT(float,DataValue) DataValue
					FROM [Gapminder_RAW].[gecon].[Raw_Data]
					WHERE PERIOD <> ''
			)r 
			LEFT JOIN (
				SELECT * FROM DimIndicators WHERE DataSourceID = 14
			) i
				ON r.Indicator = i.[Indicator Name]
			LEFT JOIN (
				SELECT * FROM DimCountry WHERE [type] = 'country'
			)c
				ON r.Country = c.[Short Name]
			

END


GO
/****** Object:  StoredProcedure [dbo].[PreProcessHarvestData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessHarvestData]
AS
BEGIN
		SET NOCOUNT ON;

		--DROP TABLE #X
		SELECT * INTO #X
		FROM (
			SELECT ADM1_NAME_ALT name 
				,ADM0_NAME parentName
				,CAST(NULL AS VARCHAR(100)) id
				,CAST(ISO3 AS VARCHAR(100)) parent
				,'province' cat 
			FROM [dbo].[HarvestChoiceRawData]
			GROUP BY ADM0_NAME,ADM1_NAME_ALT,ISO3

			UNION ALL

			SELECT ADM2_NAME_ALT,ADM1_NAME_ALT, NULL, NULL, 'territory' 
			FROM [dbo].[HarvestChoiceRawData]
			GROUP BY ADM2_NAME_ALT,ADM1_NAME_ALT
		)A

		UPDATE x
		SET x.id = g.id
		FROM #X x INNER JOIN DimGeo g
		ON x.name = g.name
		AND x.parent = g.region
		WHERE x.cat = 'province'

		UPDATE x
		SET x.id = p.code
		FROM #X x INNER JOIN UtilityProvince p
		ON X.name = P.subdivision_name
		WHERE x.cat = 'province'
		AND id IS NULL

		UPDATE X
		SET X.ID = parent+'-'+REPLACE(x.name,' ','-')
		FROM #X x
		WHERE x.cat = 'province'
		AND id IS NULL

		UPDATE X
		SET  x.parent = y.id
		FROM #X x INNER JOIN #X y
		ON x.parentName = y.name
		WHERE x.cat = 'TERRITORY'
		AND Y.cat = 'PROVINCE'

		UPDATE X
		SET X.id = G.id
		FROM #X x INNER JOIN DimGeo g
		ON x.name = g.name
		WHERE x.cat = 'territory'
		AND G.cat = 'TERRITORY'
		AND X.id IS NULL

		UPDATE X
		SET X.ID = parent+'-'+REPLACE(x.name,' ','-')
		FROM #X x
		WHERE x.cat = 'territory'
		AND id IS NULL

		SELECT 'geo' dim,LOWER(x.id) id,name,LOWER(parent) region 
			,g.GeoLevelName cat, g.GeoLevelNo lev
			INTO #final
		FROM #X X INNER JOIN GeoHierarchyLevel g
		ON x.cat = g.GeoLevelName

		MERGE DimGeo T
		USING (
			SELECT * FROM #final
		) S
		ON (T.id = S.id AND T.cat = S.cat AND S.region = T.region)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES(S.dim,S.id,S.name,S.region,S.cat,S.lev);
		
		MERGE dbo.DimCountry T
		USING (
			SELECT * FROM #final
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = 7

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 7,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM [dbo].[HarvestChoiceRawData]
		GROUP BY Indicator
		
		--DROP INDEX ix_fact ON FactFinal

		DELETE FROM FactFinal
		WHERE DataSourceID = 7

		INSERT INTO factfinal 
					([datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					[value]) 
		SELECT 7, r.ID, r.Period, i.ID, TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator 
			FROM [dbo].[HarvestChoiceRawData] hr
			LEFT JOIN DimCountry dc
			ON hr.ISO3 = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			FROM [dbo].[HarvestChoiceRawData] hr
			LEFT JOIN #final f
			ON hr.ADM1_NAME_ALT = F.name
			AND hr.ISO3 = f.region
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'province'
			AND f.cat = 'province'
			AND F.id IS NOT NULL

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			FROM [dbo].[HarvestChoiceRawData] hr
			LEFT JOIN #final f
			ON hr.ADM2_NAME_ALT = F.name
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'territory'
			AND f.cat = 'territory'
			AND F.id IS NOT NULL
			
		)r 
		LEFT JOIN (
			SELECT * FROM DimIndicators WHERE DataSourceID = 7
		) i
			ON r.Indicator = i.[Indicator Name]

		--CREATE NONCLUSTERED INDEX ix_fact 
		--ON factfinal ([datasourceid], [country code], [period], [indicator code],[SubGroup] ) 
		--INCLUDE([Value])

END


GO
/****** Object:  StoredProcedure [dbo].[PreProcessIMFData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessIMFData]
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @dyn_sql NVARCHAR(max)
				,@baseFolderLocation VARCHAR(100)
				,@rawDataFileLocation VARCHAR(100)
	
		SET @baseFolderLocation = N'C:\Users\shahnewaz\Documents\GapMinder_DEV\imf\'
		SET @rawDataFileLocation = @baseFolderLocation + 'AllIMFData.txt';

		TRUNCATE TABLE dbo.IMFAllRawData
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.IMFAllRawData 
				FROM ''' + @rawDataFileLocation + ''' 
				WITH 
					( 
					fieldterminator = '','', 
					rowterminator = ''0x0a'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql

		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = 4

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 4,indicator, indicator 
		FROM dbo.IMFAllRawData
		GROUP BY Indicator

		--DROP INDEX ix_fact ON FactFinal

		--DELETE FROM FactFinal
		--WHERE DataSourceID = 4

		--CREATE NONCLUSTERED INDEX ix_fact 
		--ON dbo.FactFinal ([datasourceid], [country code], [period], [indicator code],[SubGroup] ) 
		--INCLUDE([Value])

END


GO
/****** Object:  StoredProcedure [dbo].[PreProcessMortalityData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessMortalityData] 
AS
BEGIN
		
		SET NOCOUNT ON;

		MERGE [dbo].[DimAge] T
		USING (
			SELECT 'N/A' age 
			UNION ALL
			SELECT Age FROM [dbo].[MortalityOrgData]
			GROUP BY Age
		) S
		ON (T.age = S.age)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(age) 
			VALUES(S.age);

		MERGE [dbo].[DimGender] T
		USING (
			SELECT 'N/A' gender UNION ALL SELECT 'male' UNION ALL
			SELECT 'female' UNION ALL SELECT 'both' UNION ALL
			SELECT 'others'
		) S
		ON (T.gender = S.gender)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(gender) 
			VALUES(S.gender);

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'hmd'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'hmd'
		--SELECT @dataSourceID

		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = @dataSourceID

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT @dataSourceID
		,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255))
		,indicator 
		FROM [dbo].[MortalityOrgData]
		GROUP BY Indicator

		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		--DROP TABLE #A
		SELECT LEFT(CountryCode,3) countrycode
		,IIF(SUBSTRING(CountryCode,4, LEN(CountryCode))='','N/A'
			,SUBSTRING(CountryCode,4, LEN(CountryCode))
		)subgroup
		,CAST(NULL AS INT) subGroupID
		INTO #A
		FROM (
			SELECT CountryCode
			FROM [dbo].[MortalityOrgData]
			GROUP BY CountryCode
		)A
		
		--TRUNCATE TABLE [dbo].[DimSubGroup]
		MERGE [dbo].[DimSubGroup] T
		USING (
			SELECT subgroup FROM #A
			GROUP BY subgroup
		) S
		ON (T.SubGroup = S.subgroup)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(SubGroup) 
			VALUES(S.subgroup);

		UPDATE A
		SET A.subGroupID = S.ID
		FROM #A A INNER JOIN DimSubGroup S
		ON A.subgroup = S.SubGroup

		EXECUTE ChangeIndexAndConstraint 'DROP', 'hmd'

		DELETE FROM dbo.FactHMD
		WHERE VersionID = @versionNo

		INSERT INTO FactHMD 
					([VersionID],
					[datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					SubGroup,
					Age,
					Gender,
					[value]) 
		SELECT @versionNo, @dataSourceID,c.ID, LEFT(r.Year,4), i.ID, s.ID, ag.ID, gen.ID, r.DataValue
		FROM (
			SELECT Indicator, LEFT(CountryCode,3)id
			,IIF(SUBSTRING(CountryCode,4, LEN(CountryCode))='','N/A'
				,SUBSTRING(CountryCode,4, LEN(CountryCode))
			)subgroup,[Year],Age,'male' gender, TRY_CONVERT(float,Male) DataValue
			FROM [dbo].[MortalityOrgData] 

			UNION ALL

			SELECT Indicator, LEFT(CountryCode,3)id
			,IIF(SUBSTRING(CountryCode,4, LEN(CountryCode))='','N/A'
				,SUBSTRING(CountryCode,4, LEN(CountryCode))
			)subgroup,[Year],Age,'female' gender, TRY_CONVERT(float,Female) DataValue
			FROM [dbo].[MortalityOrgData]
			
			UNION ALL

			SELECT Indicator, LEFT(CountryCode,3)id
			,IIF(SUBSTRING(CountryCode,4, LEN(CountryCode))='','N/A'
				,SUBSTRING(CountryCode,4, LEN(CountryCode))
			)subgroup,[Year],Age,'both' gender, TRY_CONVERT(float,Total) DataValue
			FROM [dbo].[MortalityOrgData] 
		)
		r 
		LEFT JOIN (
			SELECT * FROM DimIndicators WHERE DataSourceID = @dataSourceID
		) i
			ON r.Indicator = i.[Indicator Name]
		LEFT JOIN (SELECT subgroup,subGroupID ID FROM #A GROUP BY subgroup,subGroupID) s
			ON r.Subgroup = s.SubGroup
		LEFT JOIN DimCountry c
			ON r.id = c.[Country Code]
		LEFT JOIN DimAge ag
			ON r.Age = ag.age
		LEFT JOIN DimGender gen
			ON r.gender = gen.gender
		--WHERE i.id IS NOT NULL
		--AND c.id IS NOT NULL
		--AND S.ID IS NOT NULL
		--AND gen.ID IS NOT NULL

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'hmd'

END


GO
/****** Object:  StoredProcedure [dbo].[PreProcessNBERData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessNBERData]
AS
BEGIN
		SET NOCOUNT ON;
		
		--DROP TABLE #y
		SELECT n.CountryCode, n.Region
			INTO #y
		FROM [dbo].[NBERRawData] n
		INNER JOIN DimGeo g
		ON n.CountryCode = g.id
		GROUP BY CountryCode, n.Region

		--DROP TABLE #final
		SELECT y.Region name, CAST(g.id AS VARCHAR(100)) id,
		y.CountryCode region, 'province' cat
		INTO #final
		FROM #y y LEFT JOIN DimGeo g
		ON y.Region = g.name
		AND y.CountryCode = g.region
		WHERE g.id IS NOT NULL
		AND y.Region <> ''

		UNION ALL

		SELECT y.Region name, CAST(y.CountryCode+'-'+y.Region AS VARCHAR(100)) id,
		y.CountryCode region, 'province' cat
		FROM #y y LEFT JOIN DimGeo g
		ON y.Region = g.name
		WHERE g.id IS NULL
		AND y.Region <> ''

		MERGE DimGeo T
		USING (
			SELECT f.*, g.[GeoLevelNo] lev
			FROM #final f INNER JOIN [dbo].[GeoHierarchyLevel] g
			ON f.cat = g.[GeoLevelName]
		) S
		ON (T.id = S.id AND T.cat = S.cat AND T.region = S.region)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES('geo',LOWER(S.id),S.name,LOWER(S.region),S.cat,S.lev);


		MERGE dbo.DimCountry T
		USING (
			SELECT f.*, g.[GeoLevelNo] lev
			FROM #final f INNER JOIN [dbo].[GeoHierarchyLevel] g
			ON f.cat = g.[GeoLevelName]
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = 8

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 8,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM [dbo].[NBERRawData]
		GROUP BY Indicator

		--DROP INDEX ix_fact ON FactFinal

		DELETE FROM FactFinal
		WHERE DataSourceID = 8

		INSERT INTO factfinal 
					([datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					[value]) 
		SELECT 8, r.ID, r.Period, i.ID, TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator 
			FROM [dbo].[NBERRawData] hr
			LEFT JOIN DimCountry dc
			ON hr.CountryCode = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			FROM [dbo].[NBERRawData] hr
			LEFT JOIN #final f
			ON hr.Region = F.name
			AND hr.CountryCode = f.region
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'province'
			AND f.cat = 'province'
			AND F.id IS NOT NULL
		)r 
		LEFT JOIN (
			SELECT * FROM DimIndicators WHERE DataSourceID = 8
		) i
			ON r.Indicator = i.[Indicator Name]

		--CREATE NONCLUSTERED INDEX ix_fact 
		--ON factfinal ([datasourceid], [country code], [period], [indicator code],[SubGroup] ) 
		--INCLUDE([Value])

END


GO
/****** Object:  StoredProcedure [dbo].[PreProcessOPHIData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessOPHIData]
AS
BEGIN
		
		SET NOCOUNT ON;
		
		--DROP TABLE #A
		SELECT CountryCode, CountryName, SubRegionName, CAST(NULL AS VARCHAR(200)) id
			INTO #A
		FROM OPHI_Raw_Data
		GROUP BY CountryCode, CountryName, SubRegionName
		
		UPDATE A
		SET A.id  = G.id
		FROM #A A LEFT JOIN (SELECT * FROM DimGeo WHERE cat = 'province') G
			ON A.CountryCode = G.region
			AND A.SubRegionName = g.name
		WHERE G.id IS NOT NULL

		UPDATE A
		SET A.id = LOWER(A.CountryCode)+'-'+LOWER(REPLACE(A.SubRegionName,' ','-'))
		FROM #A A
		WHERE A.id IS NULL

		MERGE DimGeo T
		USING (
			SELECT A.id,SubRegionName name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #A A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'

		) S
		ON (T.id = S.id AND T.cat = 'province')
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES('geo',S.id,S.name,S.region,S.cat,S.lev);
		
		MERGE dbo.DimCountry T
		USING (
			SELECT A.id,SubRegionName name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #A A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = 9

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 9,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM [dbo].[OPHI_Raw_Data]
		GROUP BY Indicator

		--DROP INDEX ix_fact ON FactFinal

		DELETE FROM FactFinal
		WHERE DataSourceID = 9

		INSERT INTO FactFinal 
					([datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					[value]) 
		SELECT 9, r.ID, LEFT(r.Period,4), i.ID, TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator
			FROM [dbo].[OPHI_Raw_Data] hr
			LEFT JOIN DimCountry dc
			ON hr.CountryCode = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			FROM [dbo].[OPHI_Raw_Data] hr
			LEFT JOIN #A f
			ON hr.SubRegionName = F.SubRegionName
			AND hr.CountryCode = f.CountryCode
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'province'
			AND F.id IS NOT NULL
		)r 
		LEFT JOIN (
			SELECT * FROM DimIndicators WHERE DataSourceID = 9
		) i
			ON r.Indicator = i.[Indicator Name]

		--CREATE NONCLUSTERED INDEX ix_fact 
		--ON FactFinal ([datasourceid], [country code], [period], [indicator code],[SubGroup] ) 
		--INCLUDE([Value])


END


GO
/****** Object:  StoredProcedure [dbo].[PreProcessRawData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessRawData] 
AS 
  BEGIN 
      
		SET NOCOUNT ON;
		/*
		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) RNK
			FROM DimGeo
		)
		DELETE FROM CTE WHERE RNK > 1
		*/
		EXECUTE [dbo].[IndexAndConstraint] 'DROP'

		EXECUTE [dbo].[PreProcessSpreedSheetData]
		EXECUTE [dbo].[PreProcessWDIData]
		EXECUTE [dbo].[PreProcessIMFData]
		--EXECUTE [dbo].[PreProcessSubNationalData]
		--EXECUTE [dbo].[PreProcessShapeFile]
		EXECUTE [dbo].[ProcessFinalTables]
		EXECUTE [dbo].[PreProcessDevInfoData]
		EXECUTE [dbo].[PreProcessHarvestData]
		EXECUTE [dbo].[PreProcessNBERData]
		EXECUTE [dbo].[PreProcessOPHIData]
		EXECUTE [dbo].[PreProcessSEDACData]
		EXECUTE [dbo].[ProcessAdhocData]
		--EXECUTE [dbo].[PreProcessMortalityData] 
		--EXECUTE [dbo].[PreProcessDHSData]

		EXECUTE [dbo].[IndexAndConstraint] 'CREATE'

		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		/*
			
			update i 
			set i.[Indicator Name] = case [Indicator Name]
				when 'cMx_1x1' then 'Death rates (cohort 1x1)'
				when 'cExposures_1x1' then 'Exposure to risk (cohort 1x1)'
				when 'Deaths_1x1' then  'Deaths (1x1)'
				when 'Mx_1x1' then 'Death rates (period 1x1)' 
				else [Indicator Name]
				end
					 
			from dimindicators i
			where datasourceid  = 12

		*/

		UPDATE A
		SET A.Lev = H.GeoLevelNo
		FROM UtilityAvailableDataLevel A INNER JOIN GeoHierarchyLevel H
		ON A.Category = H.GeoLevelName


  END 

GO
/****** Object:  StoredProcedure [dbo].[PreProcessSEDACData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessSEDACData]
AS
BEGIN
		SET NOCOUNT ON;

		--DROP TABLE #IMR
		SELECT CountryCode, Region, RegionCode
			, CAST(RegionCode as VARCHAR(200)) id
			INTO #IMR
		FROM [dbo].[SEDAC_IMR]
		GROUP BY CountryCode, Region, RegionCode
		
		UPDATE G
		SET G.id =	LOWER(A.id)
		--SELECT *, ROW_NUMBER() OVER PARTITION BY A.
		FROM DimGeo G INNER JOIN #IMR A
		ON A.CountryCode = G.region
		AND A.Region = G.name

		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) RNK
			FROM DimGeo
		)
		DELETE FROM CTE WHERE RNK > 1

		MERGE DimGeo T
		USING (
			SELECT A.id,A.Region name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #IMR A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'
			AND LEN(A.ID)>3

		) S
		ON (T.id = S.id AND T.cat = 'province' AND T.region = S.region)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES('geo',S.id,S.name,S.region,S.cat,S.lev);

		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) RNK
			FROM DimGeo
		)
		DELETE FROM CTE WHERE RNK > 1
		
		MERGE dbo.DimCountry T
		USING (
			SELECT A.id,A.Region name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #IMR A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		DELETE FROM [dbo].[DimIndicators]
		WHERE DataSourceID = 11
		
		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name])
		SELECT 11,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM [dbo].[SEDAC_IMR]
		GROUP BY Indicator
			UNION
		SELECT 11,LEFT(LOWER(REPLACE(indicator,' ', '_')),99), indicator 
		FROM [dbo].[SEDAC_National_Poverty_RawData]
		WHERE Indicator<>''
		GROUP BY Indicator

		--DROP INDEX ix_fact ON FactFinal

		DELETE FROM FactFinal
		WHERE DataSourceID = 11

		INSERT INTO FactFinal 
					([datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					[value]) 
		SELECT 11, r.ID, LEFT(r.Period,4), i.ID, TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator
			FROM [dbo].[SEDAC_IMR] hr
			LEFT JOIN DimCountry dc
			ON hr.CountryCode = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			FROM [dbo].[SEDAC_IMR] hr
			LEFT JOIN #IMR f
			ON hr.RegionCode = F.RegionCode
			AND hr.CountryCode = f.CountryCode
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'province'
			AND F.id IS NOT NULL
		)r 
		LEFT JOIN (
			SELECT * FROM DimIndicators WHERE DataSourceID = 11
		) i
			ON r.Indicator = i.[Indicator Name]

		--SELECT TOP 2 * FROM [dbo].[SEDAC_National_Poverty_RawData]
		--DROP TABLE #POV
		SELECT CountryCode,CountryName,Region, 'province' cat
		,CAST(NULL AS VARCHAR(100)) id
		INTO #POV
		FROM (
			SELECT CountryCode,CountryName,Region, AdmLevel, DENSE_RANK() OVER(PARTITION BY CountryCode,CountryName ORDER BY AdmLevel) rnk 
			FROM [dbo].[SEDAC_National_Poverty_RawData]
			WHERE ISNUMERIC(Region) = 0
			GROUP BY CountryCode,CountryName, Region, AdmLevel

		)A WHERE rnk = 1
		ORDER BY CountryName

		UPDATE B
		SET B.ID = IIF(G.id IS NULL, LOWER(B.CountryCode+'-'+REPLACE(B.Region,' ','-')) ,G.id)
		FROM #POV B LEFT JOIN (SELECT * FROM DimGeo WHERE cat = 'province') G
		ON B.Region = G.name
		AND B.CountryCode = G.region

		MERGE DimGeo T
		USING (
			SELECT A.id,A.Region name,LOWER(CountryCode) region, 'province' cat,G.[GeoLevelNo] lev
			FROM #POV A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'

		) S
		ON (T.id = S.id AND T.cat = 'province' AND T.region = S.region)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES('geo',S.id,S.name,S.region,S.cat,S.lev);

		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) RNK
			FROM DimGeo
		)
		DELETE FROM CTE WHERE RNK > 1
		
		MERGE dbo.DimCountry T
		USING (
			SELECT A.id,A.Region name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #POV A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY [Country Code] ORDER BY [Country Code]) RNK
			FROM DimCountry
		)
		DELETE FROM CTE WHERE RNK > 1

		DELETE FROM FactFinal
		WHERE DataSourceID = 11

		INSERT INTO FactFinal 
					([datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					[value]) 
		SELECT 11, r.ID, LEFT(r.Period,4), i.ID, TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator
			FROM [dbo].[SEDAC_National_Poverty_RawData] hr
			LEFT JOIN DimCountry dc
			ON hr.CountryCode = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			FROM [dbo].[SEDAC_National_Poverty_RawData] hr
			LEFT JOIN #POV f
			ON hr.Region = F.Region
			AND hr.CountryCode = f.CountryCode
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'province'
			AND F.id IS NOT NULL
		)r 
		LEFT JOIN (
			SELECT * FROM DimIndicators WHERE DataSourceID = 11
		) i
			ON r.Indicator = i.[Indicator Name]


END


GO
/****** Object:  StoredProcedure [dbo].[PreProcessShapeFile]    Script Date: 9/24/2015 9:02:48 AM ******/
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
/****** Object:  StoredProcedure [dbo].[PreProcessSpreedSheetData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessSpreedSheetData]
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @dyn_sql NVARCHAR(max)
				,@baseFolderLocation VARCHAR(100)
				,@rawDataFileLocation VARCHAR(100)
				,@configFileLocation VARCHAR(100)
				,@indicatorFileLocation VARCHAR(100)
	
		SET @baseFolderLocation = N'C:\Users\shahnewaz\Documents\GapMinder_DEV\spreedsheet\'
		SET @rawDataFileLocation = @baseFolderLocation + 'AllRawData.txt';
		SET @configFileLocation = @baseFolderLocation + 'Config.txt';
		SET @indicatorFileLocation = @baseFolderLocation + 'Indicators.txt';

		TRUNCATE TABLE dbo.configTable 
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.configTable 
				FROM ''' + @configFileLocation + ''' 
				WITH 
					( 
					fieldterminator = ''\t'', 
					rowterminator = ''\n'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql

		--select * from WDI_Indicator 
		UPDATE [dbo].[configTable] 
		SET    [menu level1] = ISNULL([menu level1],'N/A')
			,[menu level2] = ISNULL([menu level2],'N/A')
			,[indicator url] = ISNULL([indicator url],'N/A')
			,[download] = ISNULL([download],'N/A')
			,[id] = ISNULL([id],'N/A')
			,[scale] =ISNULL([scale],'N/A')

		TRUNCATE TABLE dbo.SpreedSheetIndicator 
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.SpreedSheetIndicator 
				FROM ''' + @indicatorFileLocation + ''' 
				WITH 
					( 
					fieldterminator = '','', 
					rowterminator = ''\n'' 
					)
			'
		EXECUTE sp_executesql @dyn_sql 

		DELETE a 
		FROM   (SELECT *, 
						Row_number() 
						OVER( 
							partition BY indicator 
							ORDER BY indicator) rnk 
				FROM   dbo.SpreedSheetIndicator)A 
		WHERE  rnk > 1

		TRUNCATE TABLE dbo.SpreedSheetAllRawData;
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.SpreedSheetAllRawData 
				FROM  '''  + @rawDataFileLocation + '''
				WITH 
					( 
					fieldterminator = '','', 
					rowterminator = ''\n'' 
					)
			'
		EXECUTE sp_executesql @dyn_sql

		DROP INDEX myindex ON dbo.SpreedSheetFactData 
		
		TRUNCATE TABLE dbo.SpreedSheetFactData 
		INSERT INTO dbo.SpreedSheetFactData 
		SELECT [filelocation], 
				[pathid], 
				[country],
				TRY_CONVERT(int, [period]),
				TRY_CONVERT(float, [value])
		FROM   [dbo].[SpreedSheetAllRawData] 

		CREATE CLUSTERED INDEX myindex ON dbo.SpreedSheetFactData (pathid) 
END


GO
/****** Object:  StoredProcedure [dbo].[PreProcessSubNationalData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PreProcessSubNationalData]
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @dyn_sql NVARCHAR(max)
				,@baseFolderLocation VARCHAR(100)
				,@rawDataFileLocation VARCHAR(100)
				,@maxRowCount int
	
		SET @baseFolderLocation = N'C:\Users\shahnewaz\Documents\GapMinder_DEV\subnational\'
		SET @rawDataFileLocation = @baseFolderLocation + 'AllSubNationalRawData.txt';
		
		DROP TABLE dbo.SubNationalData

		CREATE TABLE dbo.SubNationalData
		( 
			[indicator name] VARCHAR(max), 
			[indicator code] VARCHAR(max), 
			[country name]   VARCHAR(max), 
			[country code]   VARCHAR(max), 
			[period]         INT, 
			[value]          FLOAT 
		)
		
		TRUNCATE TABLE dbo.SubNationalData
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.SubNationalData
				FROM ''' + @rawDataFileLocation + ''' 
				WITH 
					(
					FIELDTERMINATOR = '','', 
					ROWTERMINATOR = ''\n'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql
		
		ALTER TABLE dbo.SubNationalData
        ADD [region] VARCHAR(max) 

		UPDATE dbo.SubNationalData 
		SET [region] = Replace(Substring([country name], 
								Charindex(';', [country name], 1) + 
									   1, Len( 
								[country name])), '"', ''), 
			[country name] = Replace(Substring([country name], 1, 
									  Charindex(';', [country name], 1) - 1), 
							  '"' 
							  , '') 
		WHERE  Charindex(';', [country name], 1) > 1

		DROP TABLE [dbo].[SubNationalIndicator] 

		CREATE TABLE [dbo].[SubNationalIndicator]
		( 
			[id]        INT NULL, 
			[indicator] [VARCHAR](max) NULL 
		) 
		ON [PRIMARY] 
		textimage_on [PRIMARY] 

		SET @maxRowCount = (SELECT MAX(ID) FROM DimIndicators)

		INSERT INTO [dbo].[SubNationalIndicator] 
		SELECT Row_number() OVER (ORDER BY [indicator name]) 
				+ @maxRowCount           ID, 
				[indicator name] indicator 
		FROM   (SELECT [indicator name] 
				FROM   dbo.SubNationalData 
				GROUP  BY [indicator name])A 

END

GO
/****** Object:  StoredProcedure [dbo].[PreProcessWDIData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PreProcessWDIData]
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @dyn_sql NVARCHAR(max)
				,@baseFolderLocation VARCHAR(100)
				,@rawDataFileLocation VARCHAR(100)
				,@wdiCountryData VARCHAR(100)
	
		SET @baseFolderLocation = N'C:\Users\shahnewaz\Documents\GapMinder_DEV\wdi\'
		SET @rawDataFileLocation = @baseFolderLocation + 'AllWDIRawData.txt';
		SET @wdiCountryData = @baseFolderLocation + 'Data\WDI_Country.csv';
		
		TRUNCATE TABLE dbo.WDI_Country
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.WDI_Country
				FROM ''' + @wdiCountryData + ''' 
				WITH 
					(
					FIRSTROW = 2,
					FIELDTERMINATOR = '','', 
					ROWTERMINATOR = ''\n'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql
		
		TRUNCATE TABLE dbo.WDI_Data
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.WDI_Data
				FROM ''' + @rawDataFileLocation + ''' 
				WITH 
					( 
					fieldterminator = '','', 
					rowterminator = ''\n'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql
		
		TRUNCATE TABLE dbo.WDI_Indicator
		INSERT INTO dbo.WDI_Indicator
		SELECT ROW_NUMBER() over(order by A.indicator) ID, A.indicator 
		FROM   (
				SELECT [indicator name] indicator 
				FROM   wdi_data 
				GROUP  BY [indicator name]
		)A
		
		DROP INDEX myindexwdi ON dbo.WDI_FactData
		
		TRUNCATE TABLE dbo.WDI_FactData

		INSERT INTO dbo.WDI_FactData
		SELECT	wi.id 
				,wd.[country name]
				,TRY_CONVERT(int, [period])
				,TRY_CONVERT(float, [value])
		FROM	dbo.WDI_Data wd LEFT JOIN dbo.WDI_Indicator wi 
				ON wd.[indicator name] = wi.[indicator] 

		CREATE CLUSTERED INDEX myindexwdi 
		ON dbo.WDI_FactData (pathid)
		
END


GO
/****** Object:  StoredProcedure [dbo].[ProcessAdhocData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessAdhocData] 
AS
BEGIN
			SET NOCOUNT ON;

			DECLARE @versionNo INT
			SELECT @versionNo = MAX(VersionNo)
			FROM UtilityDataVersions
			WHERE DataSource = 'spreedsheet'
			GROUP BY DataSource
			--SELECT @versionNo
		
			DECLARE @dataSourceID INT
			SELECT @dataSourceID = ID
			FROM DimDataSource
			WHERE DataSource = 'spreedsheet'
			--SELECT @dataSourceID

			--DROP TABLE #GINI
			SELECT @dataSourceID DataSource, 'gini' IndicatorCode
				INTO #GINI
			UNION ALL
			SELECT @dataSourceID DataSource, 'u5mr' IndicatorCode
			UNION ALL
			SELECT @dataSourceID DataSource, 'childSurv' IndicatorCode
		
			MERGE dbo.DimIndicators T
			USING (
				SELECT * FROM #GINI
			) S
			ON (T.[Indicator Code] = S.IndicatorCode AND T.DataSourceID = @dataSourceID)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT([DataSourceID],[Indicator Code],[Indicator Name]) 
				VALUES(S.DataSource,S.IndicatorCode,S.IndicatorCode);

			--DROP TABLE #INDICATORS
			SELECT ID,IndicatorCode INTO #INDICATORS
			FROM DimIndicators I INNER JOIN #GINI G
			ON I.[Indicator Code] = G.IndicatorCode
			AND I.DataSourceID = G.DataSource

			DELETE FROM FactSpreedSheet
			WHERE [Indicator Code] IN (
				SELECT ID FROM #INDICATORS
			) AND VersionID = @versionNo

			INSERT INTO FactSpreedSheet 
						(VersionID,
						[datasourceid], 
						[country code], 
						period, 
						[indicator code], 
						[SubGroup],
						[Age],
						[Gender],
						[value])

			SELECT VersionID,ds,CID,Period,IND,s.ID,a.ID,g.ID, Val
			FROM (
				SELECT  @versionNo VersionID, @dataSourceID ds, c.ID CID, TRY_CONVERT(INT, r.[time]) Period
				, i.ID IND, TRY_CONVERT(float,gini) Val --into #A
				,'N/A' SubGroup,'N/A' Age,'N/A' Gender
				FROM dbo.NewDataGiniU5mrChildSurv r LEFT JOIN DimCountry c
				ON r.geo = c.[Country Code]
				,#INDICATORS i
				WHERE c.[Country Code] IS NOT NULL
				AND c.[Type] = 'country'
				AND I.IndicatorCode = 'gini'
		
				UNION ALL

				SELECT  @versionNo,@dataSourceID ds, c.ID, TRY_CONVERT(INT, r.[time]) per, i.ID ind
				, TRY_CONVERT(float,u5mr)
				,'N/A' SubGroup,'N/A' Age,'N/A' Gender
				FROM dbo.NewDataGiniU5mrChildSurv r LEFT JOIN DimCountry c
				ON r.geo = c.[Country Code]
				,#INDICATORS i
				WHERE c.[Country Code] IS NOT NULL
				AND c.[Type] = 'country'
				AND I.IndicatorCode = 'u5mr'

				UNION ALL

				SELECT  @versionNo,@dataSourceID ds, c.ID, TRY_CONVERT(INT, r.[time]) per, i.ID ind
				, TRY_CONVERT(float,childSurv)
				,'N/A' SubGroup,'N/A' Age,'N/A' Gender
				FROM dbo.NewDataGiniU5mrChildSurv r LEFT JOIN DimCountry c
				ON r.geo = c.[Country Code]
				,#INDICATORS i
				WHERE c.[Country Code] IS NOT NULL
				AND c.[Type] = 'country'
				AND I.IndicatorCode = 'childSurv'
			)fd
			LEFT JOIN (
				SELECT ID, SubGroup
				FROM DimSubGroup
				WHERE  DataSourceID = @dataSourceID
			) s
			ON fd.SubGroup = s.SubGroup
			LEFT JOIN (
				SELECT ID, age
				FROM DimAge
				WHERE  DataSourceID = @dataSourceID
			) a
			ON fd.Age = a.age
			LEFT JOIN (
				SELECT ID,gender
				FROM DimGender
				WHERE  DataSourceID = @dataSourceID
			) g
			ON fd.Gender = g.gender

END


GO
/****** Object:  StoredProcedure [dbo].[ProcessDevInfoData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessDevInfoData]
AS
BEGIN
		SET NOCOUNT ON;
		--DROP TABLE #A
		SELECT Area, AreaCode
		INTO #A
		FROM dbo.AllDevInfoRawData 
		GROUP BY Area, AreaCode
		--SELECT * FROM #A

		--DROP TABLE #C
		SELECT Area, AreaCode,c.lev,c.cat INTO #C
		FROM #A g LEFT JOIN (
			SELECT * FROM DimGeo WHERE cat = 'country'
		) c
		ON LEFT(areacode,3) = c.id
		WHERE ISNUMERIC(LEFT(AreaCode, 3)) = 0
		AND C.ID IS NOT NULL
		--SELECT * FROM #C
		
		--DROP TABLE #B
		SELECT CAST(LEFT(areacode,3) AS VARCHAR(100)) iso
			, 3 l, 1 rnk, CAST('country' AS VARCHAR(100)) cat
			INTO #B
		FROM #A
		WHERE ISNUMERIC(LEFT(areacode,3)) = 0
		AND LEN(AreaCode) = 3
		group by LEFT(areacode,3)
		--SELECT * FROM #B

		INSERT INTO #B
		SELECT *,
		CASE rnk WHEN 1 THEN 'province'
				WHEN 2 THEN 'territory'
				WHEN 3 THEN 'sub territory'
				WHEN 4 THEN 'brick' end cat
		FROM (
		SELECT iso, l, row_number() OVER(PARTITION BY iso ORDER BY l) rnk 
		FROM (
			SELECT DENSE_RANK() OVER(PARTITION BY LEFT(areacode,3), LEN(areacode) ORDER BY area)
			rnk,
			LEN(areacode) l, 
			LEFT(areacode,3) iso, *
			FROM #A
			WHERE ISNUMERIC(LEFT(areacode,3)) = 0
			AND LEN(AreaCode) > 3
			)A WHERE rnk = 1
		)B
		
		--SELECT * FROM #B
		--SELECT * FROM #C
		;WITH cte (code,name,parent,rnk, cat)
		AS
		(
			SELECT CAST(areacode AS VARCHAR(100)), CAST(area AS VARCHAR(100)), CAST(b.iso AS VARCHAR(100)), b.rnk
			,b.cat
			FROM #C c inner join #B b
			ON LEN(c.areacode) = b.l
			AND LEFT(c.areacode, b.l) LIKE b.iso + '%'
			WHERE b.cat = 'province'

			UNION ALL

			SELECT CAST(areacode AS VARCHAR(100)), CAST(area AS VARCHAR(100)), CAST(ct.code AS VARCHAR(100)), ct.rnk + 1
			,b.cat
			FROM #C c inner join cte ct
			ON c.areacode LIKE ct.code + '%'
			inner join #B b
			ON LEN(c.areacode) = b.l
			AND LEFT(c.areacode, b.l) LIKE b.iso + '%'
			WHERE b.rnk = ct.rnk + 1
			AND ct.rnk < 7
		)
		
		SELECT 'geo' dim,code id, name, parent region,cat, g.GeoLevelNo lev, 
				NULL lat, NULL long
				INTO #final
		FROM cte c INNER JOIN GeoHierarchyLevel g
		ON c.cat = g.GeoLevelName

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'devinfo'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'devinfo'
		--SELECT @dataSourceID

		MERGE DimGeo T
		USING (
			SELECT * FROM #final
		) S
		ON (T.id = S.id AND T.cat = S.cat)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES(S.dim,LOWER(S.id),S.name,LOWER(S.region),S.cat,S.lev);
		
		MERGE dbo.DimCountry T
		USING (
			SELECT * FROM #final
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		MERGE [dbo].[DimSubGroup] T
		USING (
			SELECT 'N/A' SubGroup
			UNION ALL
			SELECT SUBGROUP
			FROM AllDevInfoRawData
			GROUP BY Subgroup
		) S
		ON (T.SubGroup = S.SubGroup AND T.DataSourceID = @dataSourceID)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(SubGroup,DataSourceID) 
			VALUES(S.SubGroup,@dataSourceID);

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator + ' (' + Unit + ')' [indicator]
			,Unit
			,NULL ID 
			FROM dbo.AllDevInfoRawData 
			GROUP BY Indicator,Unit
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],Unit,[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,Unit,S.ID);

		EXECUTE ChangeIndexAndConstraint 'DROP', 'devinfo'

		DELETE FROM [dbo].[FactDevInfo]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactDevInfo] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code], 
				 [SubGroup],
				 [Age],
				 [Gender],
				 [Value]) 
		
		SELECT @versionNo,@dataSourceID,c.ID, TRY_CONVERT(int, r.[Year]), i.ID, s.ID,a.id,g.id, TRY_CONVERT(float,r.DataValue)
		FROM (SELECT *,'N/A' Age,'N/A' Gender FROM dbo.AllDevInfoRawData)  r 
		LEFT JOIN (
			SELECT ID,[Indicator Name]
			FROM   DimIndicators 
			WHERE  datasourceid = @dataSourceID
		) i
			ON (r.indicator + ' (' + r.Unit + ')') = i.[Indicator Name]
		LEFT JOIN (
			SELECT ID, SubGroup
			FROM DimSubGroup
			WHERE  DataSourceID = @dataSourceID
		) s
			ON r.Subgroup = s.SubGroup
		LEFT JOIN (
			SELECT ID, [Country Code],[Type]
			FROM DimCountry
			--WHERE [Type] = 'country'
		) c
			ON r.AreaCode = c.[Country Code]
		LEFT JOIN (
				SELECT ID, age
				FROM DimAge
				WHERE  DataSourceID = @dataSourceID
		) a
		ON r.Age = a.age
		LEFT JOIN (
			SELECT ID,gender
			FROM DimGender
			WHERE  DataSourceID = @dataSourceID
		) g
		ON r.Gender = g.gender
		WHERE i.id IS NOT NULL
		AND c.id IS NOT NULL
		AND S.ID IS NOT NULL
		
		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		EXECUTE [dbo].[PostProcessFactPivot] 'devinfo',@versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'devinfo'

END


GO
/****** Object:  StoredProcedure [dbo].[ProcessDHSData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessDHSData]
AS
BEGIN
	
			SET NOCOUNT ON;

			DECLARE @versionNo INT
			SELECT @versionNo = MAX(VersionNo)
			FROM UtilityDataVersions
			WHERE DataSource = 'dhs'
			GROUP BY DataSource
			--SELECT @versionNo
		
			DECLARE @dataSourceID INT
			SELECT @dataSourceID = ID
			FROM DimDataSource
			WHERE DataSource = 'dhs'
			--SELECT @dataSourceID

			--DROP #MICS
			SELECT Stratifier 
			,Country
			,CASE Stratifier
				WHEN 'gregion' THEN IndPostfix
				ELSE Country END Region
			,CASE Stratifier
				WHEN 'sex' THEN IndPostfix
				ELSE 'N/A' END Gender
			,[Year]
			,CASE Stratifier
				WHEN 'area' THEN IndPostfix
				WHEN 'meduc' THEN IndPostfix
				WHEN 'wiq' THEN IndPostfix
				ELSE 'N/A' END SubGroup
			,CASE Stratifier
				WHEN 'mage' THEN REPLACE(Stratifier_type,' '+IndPostfix,'')
				ELSE 'N/A' END AgeGroup
			,Indicator
			,DataValue
			--,Indicator2
			INTO #MICS
			FROM (
			SELECT DataSheetName,Country,[Year],Indicator,Stratifier,Stratifier_type, Indicator2
			,SUBSTRING(Stratifier_type, CHARINDEX(' ',Stratifier_type,1)+1, LEN(Stratifier_type)) IndPostfix
			,DataValue 
			FROM [Gapminder_RAW].[dhs].[MICS_RawData]
			WHERE Indicator2 IN ('r','')
			--AND Indicator = 'anc4'
			--AND Country = 'Bhutan'
			)A
			ORDER BY Stratifier

			--DROP TABLE #GEO
			SELECT Country CountryMain, Region RegionMain, REPLACE(Country,'_',' ') Country, LTRIM(SUBSTRING(Region, CHARINDEX(']',Region,1)+1, LEN(Region))) REGION
			,CAST(NULL AS VARCHAR(100)) ISO, CAST(NULL AS VARCHAR(100)) ISO_REGION
			INTO #GEO
			FROM #MICS
			WHERE Country <> Region
			GROUP BY COUNTRY,Region

			UPDATE G
			SET G.ISO = DG.id
			FROM #GEO G INNER JOIN DimGeo DG
			ON G.Country = DG.name
			WHERE DG.cat = 'Country'

			UPDATE G
			SET G.ISO_REGION = DG.id
			FROM #GEO G INNER JOIN DimGeo DG
			ON G.ISO = DG.region
			AND G.REGION = DG.name
			WHERE DG.cat = 'province'
			AND G.ISO IS NOT NULL

			UPDATE  G
			SET G.ISO_REGION = ISO+'-'+LOWER(REGION)
			FROM #GEO G
			WHERE ISO IS NOT NULL
			AND ISO_REGION IS NULL

			DELETE FROM #GEO
			WHERE ISO IS NULL

			MERGE DimGeo T
			USING (
				SELECT * FROM #GEO
			) S
			ON (T.id = S.ISO_REGION AND T.region = S.ISO AND T.cat = 'province')
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(dim,id,name,region,cat,lev) 
				VALUES('geo',LOWER(S.ISO_REGION),S.REGION,LOWER(S.region),'province',4);
		
			MERGE dbo.DimCountry T
			USING (
				SELECT * FROM #Geo
			) S
			ON (T.[Country Code] = S.ISO_REGION AND T.[type] = 'province')
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT([type],[Country Code],[Short Name],[Country Name]) 
				VALUES('province',LOWER(S.ISO_REGION),S.REGION,S.REGION);

			MERGE [dbo].[DimSubGroup] T
			USING (
				SELECT SubGroup FROM #MICS
				GROUP BY SubGroup
			) S
			ON (T.SubGroup = S.SubGroup AND T.DataSourceID = @dataSourceID)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(SubGroup,DataSourceID) 
				VALUES(S.SubGroup,@dataSourceID);

			MERGE [dbo].[DimAge] T
			USING (
				SELECT AgeGroup FROM #MICS
				GROUP BY AgeGroup
			) S
			ON (T.age = S.AgeGroup AND T.DataSourceID = @dataSourceID)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(age,DataSourceID) 
				VALUES(S.AgeGroup,@dataSourceID);

			MERGE [dbo].[DimGender] T
			USING (
				SELECT Gender FROM #MICS
				GROUP BY Gender
			) S
			ON (T.gender = S.gender AND T.DataSourceID = @dataSourceID)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(gender,DataSourceID) 
				VALUES(S.gender,@dataSourceID);

			MERGE DimIndicators T
			USING (
				SELECT @dataSourceID DataSourceID
				,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
				, indicator
				,NULL ID 
				FROM #MICS 
				GROUP BY Indicator
			) S
			ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
				VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);

			EXECUTE ChangeIndexAndConstraint 'DROP', 'dhs'

			DELETE FROM [dbo].[FactDHS]
			WHERE VersionID = @versionNo

			INSERT INTO [dbo].[FactDHS] 
					([VersionID],
					 [DataSourceID], 
					 [Country Code], 
					 [Period], 
					 [Indicator Code], 
					 [SubGroup],
					 [Age],
					 [Gender],
					 [Value]) 
			SELECT @versionNo,@dataSourceID,c.ID, LEFT(r.[Year],4), i.ID, s.ID, ag.ID, gen.ID, r.DataValue
			FROM (
				SELECT ISO id, Indicator, SubGroup, AgeGroup, Gender, [Year], TRY_CONVERT(float,DataValue) DataValue
				FROM #MICS f LEFT JOIN (SELECT ISO,CountryMain FROM #GEO GROUP BY ISO,CountryMain) g
				ON f.Country = g.CountryMain
				--AND f.Region = g.RegionMain
				WHERE Stratifier <> 'gregion'
				AND G.ISO IS NOT NULL

				UNION ALL

				SELECT ISO id, Indicator, SubGroup, AgeGroup, Gender, [Year], TRY_CONVERT(float,DataValue) DataValue
				FROM #MICS f LEFT JOIN (
					SELECT ISO_REGION ISO,CountryMain,RegionMain FROM #GEO 
					GROUP BY ISO_REGION,CountryMain,RegionMain
				) g
				ON f.Country = g.CountryMain
				AND f.Region = g.RegionMain
				WHERE Stratifier = 'gregion'
				AND G.ISO IS NOT NULL
			)
			r 
			LEFT JOIN (
				SELECT ID,[Indicator Name] 
				FROM   DimIndicators 
				WHERE  datasourceid = @dataSourceID
			) i
				ON r.Indicator = i.[Indicator Name]
			LEFT JOIN (
				SELECT ID, SubGroup
				FROM DimSubGroup
				WHERE  DataSourceID = @dataSourceID
			) s
				ON r.Subgroup = s.SubGroup
			LEFT JOIN (
				SELECT ID, [Country Code]
				FROM DimCountry
				WHERE [Type] IN ('country', 'province')
			) c
				ON r.id = c.[Country Code]
			LEFT JOIN (
				SELECT ID, age
				FROM DimAge
				WHERE  DataSourceID = @dataSourceID
			) ag
				ON r.AgeGroup = ag.age
			LEFT JOIN (
				SELECT ID,gender
				FROM DimGender
				WHERE  DataSourceID = @dataSourceID
			) gen
				ON r.gender = gen.gender
			
			--DROP TABLE #NATIONAL
			SELECT CASE CountryName
				WHEN 'KYRGYZSTAN' THEN 'Kyrgyz Republic'
				WHEN 'CONGO (Kinshasa)' THEN 'Dem. Rep. Congo'
				WHEN 'CONGO (Brazzaville)' THEN 'Rep. Congo'
				ELSE REPLACE(CountryName,'&','AND') END
			CountryName
			,[Year]
			,[Indicator]
			,TRY_CONVERT(float,DataValue) DataValue
			INTO #NATIONAL
			FROM [Gapminder_RAW].dhs.Spatial_National_Raw_Data

			MERGE DimIndicators T
			USING (
				SELECT @dataSourceID DataSourceID
				,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
				, indicator
				,NULL ID 
				FROM #NATIONAL 
				GROUP BY Indicator
			) S
			ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
				VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);

			INSERT INTO [dbo].[FactDHS] 
					([VersionID],
					 [DataSourceID], 
					 [Country Code], 
					 [Period], 
					 [Indicator Code], 
					 [SubGroup],
					 [Age],
					 [Gender],
					 [Value]) 
			SELECT @versionNo,@dataSourceID, c.ID, r.[Year], i.ID
				,s.ID
				,a.ID
				,g.ID, r.DataValue
			FROM ( 
				SELECT * ,'N/A' SubGroup,'N/A' Age,'N/A' Gender
				FROM #NATIONAL
			
			)r 
			LEFT JOIN (
				SELECT ID,[Indicator Name] 
				FROM   DimIndicators 
				WHERE  datasourceid = @dataSourceID
			) i
				ON r.Indicator = i.[Indicator Name]
			LEFT JOIN (
				SELECT ID, [Short Name]
				FROM DimCountry
				WHERE [Type] = 'country'
			)c
				ON r.CountryName = c.[Short Name]
			LEFT JOIN (
				SELECT ID, SubGroup
				FROM DimSubGroup
				WHERE  DataSourceID = @dataSourceID
			) s
			ON r.SubGroup = s.SubGroup
			LEFT JOIN (
				SELECT ID, age
				FROM DimAge
				WHERE  DataSourceID = @dataSourceID
			) a
			ON r.Age = a.age
			LEFT JOIN (
				SELECT ID,gender
				FROM DimGender
				WHERE  DataSourceID = @dataSourceID
			) g
			ON r.Gender = g.gender


			UPDATE i
			SET i.[Indicator Code] = r.IndicatorNameAfter
			FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
			ON i.DataSourceID = r.DataSourceID
			AND i.[Indicator Name] = r.IndicatorNameBefore

			--EXECUTE [dbo].[PostProcessFactPivot] 'dhs', @versionNo

			EXECUTE ChangeIndexAndConstraint 'CREATE', 'dhs'

END


GO
/****** Object:  StoredProcedure [dbo].[ProcessFinalTables]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessFinalTables]
AS
BEGIN
	
		SET NOCOUNT ON;

		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) RNK
			FROM DimGeo
		)
		DELETE FROM CTE WHERE RNK > 1
		
		--TRUNCATE TABLE dbo.DimCountry

		--INSERT INTO dbo.DimCountry([Type],[Country Code],[Short Name], [Country Name])
		--SELECT cat,id,name,name
		--FROM DimGeo
		--ORDER BY lev

		--INSERT INTO dbo.DimCountry([Type],[Country Code],[Short Name], [Country Name])
		--	SELECT 'geo', [Country Code],[Short Name], [Long Name] 
		--	FROM dbo.WDI_Country
		--	GROUP BY [Country Code],[Short Name], [Long Name]

		--INSERT INTO dbo.DimCountry([Type],[Country Code],[Short Name], [Country Name])
		--SELECT a.*
		--FROM (
		--	SELECT CASE WHEN sd.Region is null THEN 'geo' ELSE 'region' END [Type], 
		--			sd.[Country Code],
		--			CASE WHEN sd.Region is null THEN sd.[Country Name] ELSE sd.[Country Name]+ISNULL(sd.Region,sd.[Country Code]) END [Short Name]
		--			,CASE WHEN sd.Region is null THEN sd.[Country Name] ELSE sd.[Country Name]+ISNULL(sd.Region,sd.[Country Code]) END [Country Name]
		--	FROM  SubNationalData sd
		--	WHERE region IS NOT NULL
		--	GROUP BY sd.[Country Code],sd.[Country Name],sd.Region              
		--)A LEFT JOIN DimCountry d 
		--ON a.[Country Code] = d.[Country Code]
		--WHERE d.[Country Code] IS NULL

		--INSERT INTO dbo.DimCountry([Type],[Country Code],[Short Name], [Country Name])
		--SELECT 'geo',a.country,a.country,a.country
		--FROM (
		--	SELECT  country
		--	FROM dbo.SpreedSheetFactData 
		--	GROUP BY country
		--)a LEFT JOIN DimCountry d
		--ON  a.country = d.[Short Name]
		--OR a.country = d.[Country Code]
		--WHERE d.[Short Name] IS NULL

		
		TRUNCATE TABLE [dbo].[DimIndicators]

		INSERT INTO DimIndicators([DataSourceID],[Indicator Code], [Indicator Name], TempID)
		SELECT 1,'N/A', indicator,ID 
		FROM dbo.SpreedSheetIndicator

		UNION ALL

		SELECT 2, 'N/A', indicator, ID 
		FROM WDI_Indicator

		--UNION ALL

		--SELECT 3, 'N/A' [Indicator Code], id.indicator, id.ID 
		--FROM dbo.SubNationalIndicator id

		UNION ALL

		SELECT 4,'N/A', indicator,NULL
		FROM dbo.IMFAllRawData
		GROUP BY Indicator

		UPDATE [dbo].[DimIndicators]
		SET [Indicator Code] = LEFT(LOWER(REPLACE([Indicator Name],' ', '_')),99)

		--DROP INDEX ix_fact ON FactFinal

		TRUNCATE TABLE FactFinal
		INSERT INTO factfinal 
				([datasourceid], 
				 [country code], 
				 period, 
				 [indicator code], 
				 [value]) 
		SELECT 1, 
			   dc.id, 
			   fd.period, 
			   di.id, 
			   fd.value 
		FROM   dbo.SpreedSheetFactData  fd 
			   LEFT JOIN (SELECT * 
						  FROM   DimIndicators 
						  WHERE  datasourceid = 1) di 
					  ON fd.pathid = di.tempid 
			   LEFT JOIN DimCountry dc 
					  ON fd.country = dc.[short name] 
		WHERE  di.id IS NOT NULL 
			   AND dc.id IS NOT NULL 
		
		UNION ALL 
		
		SELECT 2, 
			   dc.id, 
			   fd.period, 
			   di.id, 
			   fd.value 
		FROM   dbo.WDI_FactData fd 
			   LEFT JOIN (SELECT * 
						  FROM   dimindicators 
						  WHERE  datasourceid = 2) di 
					  ON fd.pathid = di.tempid 
			   LEFT JOIN dimcountry dc 
					  ON fd.country = dc.[short name] 
		WHERE  di.id IS NOT NULL 
			   AND dc.id IS NOT NULL 
		
		--UNION ALL 

		--SELECT 3, 
		--	   dc.id, 
		--	   fd.period, 
		--	   di.id, 
		--	   fd.value 
		--FROM   subnationaldata fd 
		--	   LEFT JOIN (SELECT * 
		--				  FROM   dimindicators 
		--				  WHERE  datasourceid = 3) di 
		--			  ON fd.[indicator name] = di.[indicator name] 
		--	   LEFT JOIN dimcountry dc 
		--			  ON fd.[country code] = dc.[country code] 
		--WHERE  di.id IS NOT NULL 
		--	   AND dc.id IS NOT NULL 

		UNION ALL

		SELECT 4, 
			dc.id, 
			LEFT(r.[time], 4), 
			di.id, 
			CASE 
				WHEN r.indicator LIKE 'population%' THEN 
					 TRY_CONVERT(float,r.[value]) * 1000000
				ELSE TRY_CONVERT(float,r.[value])
			END 
		FROM dbo.IMFAllRawData r 
		LEFT JOIN (
			SELECT * 
			FROM   DimIndicators 
			WHERE  datasourceid = 4
		) di 
		ON r.indicator = di.[indicator code] 
		LEFT JOIN dbo.DimCountry dc
		ON r.geo = dc.[country code]
		WHERE dc.ID IS NOT NULL 

		--CREATE NONCLUSTERED INDEX ix_fact 
		--ON factfinal ([datasourceid], [country code], [period], [indicator code],[SubGroup] ) 
		--INCLUDE([Value])
		
		
		/*
			Fixed pre-processing
		*/
		update DimGeo
		set cat = replace(replace(cat,'["',''),'"]','')

		update DimGeo
		set region = 'world'
		where region is null
		and cat in ('region')

		--update dc
		--set dc.[Country Code] = dg.id
		--from DimCountry dc inner join DimGeo dg
		--on dc.[Short Name] = dg.name
		
END

GO
/****** Object:  StoredProcedure [dbo].[ProcessGECONData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessGECONData]
AS
BEGIN
		SET NOCOUNT ON;
		
		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'gecon'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'gecon'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator
			,NULL ID 
			FROM [Gapminder_RAW].[gecon].[Raw_Data] 
			GROUP BY Indicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);
		
		EXECUTE ChangeIndexAndConstraint 'DROP', 'gecon'

		DELETE FROM [dbo].[FactGECON]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactGECON] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code], 
				 [SubGroup],
				 [Age],
				 [Gender],
				 [Value]) 
		SELECT @versionNo,@dataSourceID, c.ID, r.Period, i.ID
				,s.ID
				,a.ID
				,g.ID, r.DataValue
		FROM ( 
				SELECT CASE Country
				WHEN 'KYRGYZSTAN' THEN 'Kyrgyz Republic'
				WHEN 'Slovakia' THEN 'Slovak Republic'
				WHEN 'CONGO' THEN 'Rep. Congo'
				WHEN 'SouthAfrica' THEN 'South Africa'
				WHEN 'Central Africa' THEN 'Central African Republic'
				WHEN 'Czech' THEN 'Czech Republic'
				WHEN 'UK' THEN 'United Kingdom'
				ELSE Country END
				Country
				,Period
				,Indicator
				,TRY_CONVERT(float,DataValue) DataValue
				,'N/A' SubGroup,'N/A' Age,'N/A' Gender
				FROM [Gapminder_RAW].[gecon].[Raw_Data]
				WHERE PERIOD <> ''
		)r 
		LEFT JOIN (
			SELECT ID,[Indicator Name] 
			FROM   DimIndicators 
			WHERE  datasourceid = @dataSourceID
		) i
			ON r.Indicator = i.[Indicator Name]
		LEFT JOIN (
			SELECT ID, [Short Name]
			FROM DimCountry
			WHERE [Type] = 'country'
		)c
			ON r.Country = c.[Short Name]
		LEFT JOIN (
			SELECT ID, SubGroup
			FROM DimSubGroup
			WHERE  DataSourceID = @dataSourceID
		) s
		ON r.SubGroup = s.SubGroup
		LEFT JOIN (
			SELECT ID, age
			FROM DimAge
			WHERE  DataSourceID = @dataSourceID
		) a
		ON r.Age = a.age
		LEFT JOIN (
			SELECT ID,gender
			FROM DimGender
			WHERE  DataSourceID = @dataSourceID
		) g
		ON r.Gender = g.gender

		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		--EXECUTE [dbo].[PostProcessFactPivot] 'gecon', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'gecon'
		
END


GO
/****** Object:  StoredProcedure [dbo].[ProcessHarvetChoice]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessHarvetChoice]
AS
BEGIN
		SET NOCOUNT ON;

		--DROP TABLE #X
		SELECT * INTO #X
		FROM (
			SELECT ADM1_NAME_ALT name 
				,ADM0_NAME parentName
				,CAST(NULL AS VARCHAR(100)) id
				,CAST(ISO3 AS VARCHAR(100)) parent
				,'province' cat 
			FROM [GapMinder_RAW].[harvestchoice].[RawData]
			GROUP BY ADM0_NAME,ADM1_NAME_ALT,ISO3

			UNION ALL

			SELECT ADM2_NAME_ALT,ADM1_NAME_ALT, NULL, NULL, 'territory' 
			FROM [GapMinder_RAW].[harvestchoice].[RawData]
			GROUP BY ADM2_NAME_ALT,ADM1_NAME_ALT
		)A

		UPDATE x
		SET x.id = g.id
		FROM #X x INNER JOIN DimGeo g
		ON x.name = g.name
		AND x.parent = g.region
		WHERE x.cat = 'province'

		UPDATE x
		SET x.id = p.code
		FROM #X x INNER JOIN UtilityProvince p
		ON X.name = P.subdivision_name
		WHERE x.cat = 'province'
		AND id IS NULL

		UPDATE X
		SET X.ID = parent+'-'+REPLACE(x.name,' ','-')
		FROM #X x
		WHERE x.cat = 'province'
		AND id IS NULL

		UPDATE X
		SET  x.parent = y.id
		FROM #X x INNER JOIN #X y
		ON x.parentName = y.name
		WHERE x.cat = 'TERRITORY'
		AND Y.cat = 'PROVINCE'

		UPDATE X
		SET X.id = G.id
		FROM #X x INNER JOIN DimGeo g
		ON x.name = g.name
		WHERE x.cat = 'territory'
		AND G.cat = 'TERRITORY'
		AND X.id IS NULL

		UPDATE X
		SET X.ID = parent+'-'+REPLACE(x.name,' ','-')
		FROM #X x
		WHERE x.cat = 'territory'
		AND id IS NULL

		SELECT 'geo' dim,LOWER(x.id) id,name,LOWER(parent) region 
			,g.GeoLevelName cat, g.GeoLevelNo lev
			INTO #final
		FROM #X X INNER JOIN GeoHierarchyLevel g
		ON x.cat = g.GeoLevelName

		MERGE DimGeo T
		USING (
			SELECT * FROM #final
		) S
		ON (T.id = S.id AND T.cat = S.cat AND S.region = T.region)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES(S.dim,S.id,S.name,S.region,S.cat,S.lev);
		
		MERGE dbo.DimCountry T
		USING (
			SELECT * FROM #final
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		
		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'harvestchoice'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'harvestchoice'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator
			,NULL ID 
			FROM [GapMinder_RAW].[harvestchoice].[RawData]
			GROUP BY Indicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);
		
		EXECUTE ChangeIndexAndConstraint 'DROP', 'harvestchoice'

		DELETE FROM [dbo].[FactHarvestChoice]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactHarvestChoice] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code],
				 [SubGroup],
				 [Age],
				 [Gender],
				 [Value]) 
		SELECT @versionNo,@dataSourceID, r.ID, r.Period, i.ID
		,s.ID
		,a.ID
		,g.ID
		,TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator 
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender
			FROM [GapMinder_RAW].[harvestchoice].[RawData] hr
			LEFT JOIN DimCountry dc
			ON hr.ISO3 = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender
			FROM [GapMinder_RAW].[harvestchoice].[RawData] hr
			LEFT JOIN #final f
			ON hr.ADM1_NAME_ALT = F.name
			AND hr.ISO3 = f.region
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'province'
			AND f.cat = 'province'
			AND F.id IS NOT NULL

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator 
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender 
			FROM [GapMinder_RAW].[harvestchoice].[RawData] hr
			LEFT JOIN #final f
			ON hr.ADM2_NAME_ALT = F.name
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'territory'
			AND f.cat = 'territory'
			AND F.id IS NOT NULL
			
		)r 
		LEFT JOIN (
			SELECT ID,[Indicator Name] 
			FROM   DimIndicators 
			WHERE  datasourceid = @dataSourceID
		) i
			ON r.Indicator = i.[Indicator Name]
		LEFT JOIN (
			SELECT ID, SubGroup
			FROM DimSubGroup
			WHERE  DataSourceID = @dataSourceID
		) s
			ON r.SubGroup = s.SubGroup
		LEFT JOIN (
			SELECT ID, age
			FROM DimAge
			WHERE  DataSourceID = @dataSourceID
		) a
			ON r.Age = a.age
		LEFT JOIN (
			SELECT ID,gender
			FROM DimGender
			WHERE  DataSourceID = @dataSourceID
		) g
			ON r.Gender = g.gender
		
		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		EXECUTE [dbo].[PostProcessFactPivot] 'harvestchoice', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'harvestchoice'

END


GO
/****** Object:  StoredProcedure [dbo].[ProcessIMFData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessIMFData]
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @dyn_sql NVARCHAR(max)
				,@baseFolderLocation VARCHAR(100)
				,@rawDataFileLocation VARCHAR(100)
	
		SET @baseFolderLocation = N'C:\Users\shahnewaz\Documents\GapMinder_DEV\imf\'
		SET @rawDataFileLocation = @baseFolderLocation + 'AllIMFData.txt';

		TRUNCATE TABLE dbo.IMFAllRawData
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.IMFAllRawData 
				FROM ''' + @rawDataFileLocation + ''' 
				WITH 
					( 
					fieldterminator = '','', 
					rowterminator = ''0x0a'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'imf'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'imf'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator
			,NULL ID 
			FROM dbo.IMFAllRawData
			GROUP BY Indicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);

		EXECUTE ChangeIndexAndConstraint 'DROP', 'imf'

		DELETE FROM [dbo].[FactIMF]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactIMF] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code], 
				 [SubGroup],
				 [Age],
				 [Gender],
				 [Value]) 
		SELECT @versionNo,@dataSourceID, 
			dc.id, 
			TRY_CONVERT(int,LEFT(r.[time], 4)), 
			di.id,
			s.ID,
			a.ID,
			g.ID,
			CASE 
				WHEN r.indicator LIKE 'population%' THEN 
					 TRY_CONVERT(float,r.[value]) * 1000000
				ELSE TRY_CONVERT(float,r.[value])
			END 
		FROM (SELECT *,'N/A' SubGroup,'N/A' Age,'N/A' Gender FROM dbo.IMFAllRawData) r 
		LEFT JOIN (
				SELECT ID,[Indicator Name] 
				FROM   DimIndicators 
				WHERE  datasourceid = @dataSourceID
		) di 
		ON r.indicator = di.[Indicator Name] 
		LEFT JOIN (
				SELECT ID, [Country Code]
				FROM DimCountry
				WHERE [Type] = 'country'
		) dc
		ON r.geo = dc.[country code]
		LEFT JOIN (
			SELECT ID, SubGroup
			FROM DimSubGroup
			WHERE  DataSourceID = @dataSourceID
		) s
		ON R.SubGroup = s.SubGroup
		LEFT JOIN (
			SELECT ID, age
			FROM DimAge
			WHERE  DataSourceID = @dataSourceID
		) a
		ON R.Age = a.age
		LEFT JOIN (
			SELECT ID,gender
			FROM DimGender
			WHERE  DataSourceID = @dataSourceID
		) g
		ON R.Gender = g.gender

		WHERE di.id IS NOT NULL 
		AND dc.ID IS NOT NULL

		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		EXECUTE [dbo].[PostProcessFactPivot] 'imf',@versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'imf'

END


GO
/****** Object:  StoredProcedure [dbo].[ProcessMortalityData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessMortalityData] 
AS
BEGIN
		
		SET NOCOUNT ON;

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'hmd'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'hmd'
		--SELECT @dataSourceID

		MERGE [dbo].[DimAge] T
		USING (
			SELECT 'N/A' age 
			UNION ALL
			SELECT Age FROM [dbo].[MortalityOrgData]
			GROUP BY Age
		) S
		ON (T.age = S.age AND T.DataSourceID = @dataSourceID)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(age, DataSourceID) 
			VALUES(S.age, @dataSourceID);

		MERGE [dbo].[DimGender] T
		USING (
			SELECT 'N/A' gender UNION ALL SELECT 'male' UNION ALL
			SELECT 'female' UNION ALL SELECT 'both' UNION ALL
			SELECT 'others'
		) S
		ON (T.gender = S.gender AND T.DataSourceID = @dataSourceID)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(gender, DataSourceID) 
			VALUES(S.gender,@dataSourceID);

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255))[Indicator Code]
			,indicator
			,NULL ID
			FROM [dbo].[MortalityOrgData]
			GROUP BY Indicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);

		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		--DROP TABLE #A
		SELECT LEFT(CountryCode,3) countrycode
		,IIF(SUBSTRING(CountryCode,4, LEN(CountryCode))='','N/A'
			,SUBSTRING(CountryCode,4, LEN(CountryCode))
		)subgroup
		,CAST(NULL AS INT) subGroupID
		INTO #A
		FROM (
			SELECT CountryCode
			FROM [dbo].[MortalityOrgData]
			GROUP BY CountryCode
		)A
		
		--TRUNCATE TABLE [dbo].[DimSubGroup]
		MERGE [dbo].[DimSubGroup] T
		USING (
			SELECT subgroup FROM #A
			GROUP BY subgroup
		) S
		ON (T.SubGroup = S.subgroup AND T.DataSourceID = @dataSourceID)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(SubGroup, DataSourceID) 
			VALUES(S.subgroup, @dataSourceID);

		UPDATE A
		SET A.subGroupID = S.ID
		FROM #A A INNER JOIN DimSubGroup S
		ON A.subgroup = S.SubGroup
		WHERE S.DataSourceID = @dataSourceID

		EXECUTE ChangeIndexAndConstraint 'DROP', 'hmd'

		DELETE FROM dbo.FactHMD
		WHERE VersionID = @versionNo

		INSERT INTO FactHMD 
					([VersionID],
					[datasourceid], 
					[country code], 
					period, 
					[indicator code], 
					SubGroup,
					Age,
					Gender,
					[value]) 
		SELECT @versionNo, @dataSourceID,c.ID, LEFT(r.Year,4), i.ID, s.ID, ag.ID, gen.ID, r.DataValue
		FROM (
			SELECT Indicator, LEFT(CountryCode,3)id
			,IIF(SUBSTRING(CountryCode,4, LEN(CountryCode))='','N/A'
				,SUBSTRING(CountryCode,4, LEN(CountryCode))
			)subgroup,[Year],Age,'male' gender, TRY_CONVERT(float,Male) DataValue
			FROM [dbo].[MortalityOrgData] 

			UNION ALL

			SELECT Indicator, LEFT(CountryCode,3)id
			,IIF(SUBSTRING(CountryCode,4, LEN(CountryCode))='','N/A'
				,SUBSTRING(CountryCode,4, LEN(CountryCode))
			)subgroup,[Year],Age,'female' gender, TRY_CONVERT(float,Female) DataValue
			FROM [dbo].[MortalityOrgData]
			
			UNION ALL

			SELECT Indicator, LEFT(CountryCode,3)id
			,IIF(SUBSTRING(CountryCode,4, LEN(CountryCode))='','N/A'
				,SUBSTRING(CountryCode,4, LEN(CountryCode))
			)subgroup,[Year],Age,'both' gender, TRY_CONVERT(float,Total) DataValue
			FROM [dbo].[MortalityOrgData] 
		)
		r 
		LEFT JOIN (
			SELECT * FROM DimIndicators WHERE DataSourceID = @dataSourceID
		) i
			ON r.Indicator = i.[Indicator Name]
		LEFT JOIN (SELECT subgroup,subGroupID ID FROM #A GROUP BY subgroup,subGroupID) s
			ON r.Subgroup = s.SubGroup
		LEFT JOIN (
			SELECT ID, [Country Code]
			FROM DimCountry
			WHERE [Type] = 'country'
		) c
			ON r.id = c.[Country Code]
		LEFT JOIN ( 
			SELECT ID, age
			FROM DimAge
			WHERE  DataSourceID = @dataSourceID
		)ag
			ON r.Age = ag.age
		LEFT JOIN (
			SELECT ID,gender
			FROM DimGender
			WHERE  DataSourceID = @dataSourceID
		) gen
			ON r.gender = gen.gender
		--WHERE i.id IS NOT NULL
		--AND c.id IS NOT NULL
		--AND S.ID IS NOT NULL
		--AND gen.ID IS NOT NULL

		EXECUTE [dbo].[PostProcessFactPivot] 'hmd', @versionNo
		EXECUTE ChangeIndexAndConstraint 'CREATE', 'hmd'

END


GO
/****** Object:  StoredProcedure [dbo].[ProcessNBERData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessNBERData]
AS
BEGIN
		SET NOCOUNT ON;
		
		--DROP TABLE #y
		SELECT n.CountryCode, n.Region
			INTO #y
		FROM [GapMinder_RAW].[nber].[RawData] n
		INNER JOIN DimGeo g
		ON n.CountryCode = g.id
		GROUP BY CountryCode, n.Region

		--DROP TABLE #final
		SELECT y.Region name, CAST(g.id AS VARCHAR(100)) id,
		y.CountryCode region, 'province' cat
		INTO #final
		FROM #y y LEFT JOIN DimGeo g
		ON y.Region = g.name
		AND y.CountryCode = g.region
		WHERE g.id IS NOT NULL
		AND y.Region <> ''

		UNION ALL

		SELECT y.Region name, CAST(y.CountryCode+'-'+y.Region AS VARCHAR(100)) id,
		y.CountryCode region, 'province' cat
		FROM #y y LEFT JOIN DimGeo g
		ON y.Region = g.name
		WHERE g.id IS NULL
		AND y.Region <> ''

		MERGE DimGeo T
		USING (
			SELECT f.*, g.[GeoLevelNo] lev
			FROM #final f INNER JOIN [dbo].[GeoHierarchyLevel] g
			ON f.cat = g.[GeoLevelName]
		) S
		ON (T.id = S.id AND T.cat = S.cat AND T.region = S.region)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES('geo',LOWER(S.id),S.name,LOWER(S.region),S.cat,S.lev);


		MERGE dbo.DimCountry T
		USING (
			SELECT f.*, g.[GeoLevelNo] lev
			FROM #final f INNER JOIN [dbo].[GeoHierarchyLevel] g
			ON f.cat = g.[GeoLevelName]
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'nber'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'nber'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator
			,NULL ID 
			FROM [GapMinder_RAW].[nber].[RawData]
			GROUP BY Indicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);
		
		EXECUTE ChangeIndexAndConstraint 'DROP', 'nber'

		DELETE FROM [dbo].[FactNBER]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactNBER] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code],
				 [SubGroup],
				 [Age],
				 [Gender],
				 [Value]) 
		SELECT @versionNo,@dataSourceID, r.ID, r.Period, i.ID
				,s.ID
				,a.ID
				,g.ID, TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender
			FROM [GapMinder_RAW].[nber].[RawData] hr
			LEFT JOIN DimCountry dc
			ON hr.CountryCode = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender  
			FROM [GapMinder_RAW].[nber].[RawData] hr
			LEFT JOIN #final f
			ON hr.Region = F.name
			AND hr.CountryCode = f.region
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'province'
			AND f.cat = 'province'
			AND F.id IS NOT NULL
		)r 
		LEFT JOIN (
			SELECT ID,[Indicator Name] 
			FROM   DimIndicators 
			WHERE  datasourceid = @dataSourceID
		) i
			ON r.Indicator = i.[Indicator Name]
		LEFT JOIN (
			SELECT ID, SubGroup
			FROM DimSubGroup
			WHERE  DataSourceID = @dataSourceID
		) s
			ON r.SubGroup = s.SubGroup
		LEFT JOIN (
			SELECT ID, age
			FROM DimAge
			WHERE  DataSourceID = @dataSourceID
		) a
			ON r.Age = a.age
		LEFT JOIN (
			SELECT ID,gender
			FROM DimGender
			WHERE  DataSourceID = @dataSourceID
		) g
			ON r.Gender = g.gender

		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		--EXECUTE [dbo].[PostProcessFactPivot] 'nber', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'nber'


END


GO
/****** Object:  StoredProcedure [dbo].[ProcessOECDData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessOECDData]
AS
BEGIN
			SET NOCOUNT ON;
			--DROP TABLE #OECD
			SELECT CountryCode
				,CASE Sex WHEN '' THEN 'N/A'
						WHEN 'Males' THEN 'Male'
						WHEN 'Females' THEN 'Female'
					ELSE Sex END Gender
				,CASE Age WHEN '' THEN 'N/A'
					ELSE Age END Age
				,'N/A' SubGroup
				,Indicator
				,Unit + ' ( ' + PowerCode + ')' [Unit]
				,Period
				,TRY_CONVERT(float,DataValue) DataValue
			INTO #OECD
			FROM [Gapminder_RAW].[oecd].[RawData]

			DECLARE @versionNo INT
			SELECT @versionNo = MAX(VersionNo)
			FROM UtilityDataVersions
			WHERE DataSource = 'oecd'
			GROUP BY DataSource
			--SELECT @versionNo
		
			DECLARE @dataSourceID INT
			SELECT @dataSourceID = ID
			FROM DimDataSource
			WHERE DataSource = 'oecd'
			--SELECT @dataSourceID
			
			MERGE [dbo].[DimAge] T
			USING (
				SELECT Age FROM #OECD
				GROUP BY Age
			) S
			ON (T.age = S.Age AND T.DataSourceID = @datasourceID)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(DatasourceID, age) 
				VALUES(@dataSourceID,S.Age);

			MERGE [dbo].[DimGender] T
			USING (
				SELECT gender FROM #OECD
				GROUP BY gender
			) S
			ON (T.gender = S.gender AND T.DataSourceID = @datasourceID)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(DatasourceID, gender) 
				VALUES(@dataSourceID,S.gender);

			MERGE [dbo].[DimSubGroup] T
			USING (
				SELECT SubGroup FROM #OECD
				GROUP BY SubGroup
			) S
			ON (T.SubGroup = S.SubGroup AND T.DataSourceID = @datasourceID)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(DatasourceID, SubGroup) 
				VALUES(@dataSourceID,S.SubGroup);

			MERGE DimIndicators T
			USING (
				SELECT @dataSourceID DataSourceID
				,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
				, indicator
				,NULL ID
				,Unit
				FROM #OECD 
				GROUP BY Indicator,unit
			) S
			ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID],Unit) 
				VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID,Unit);

			EXECUTE ChangeIndexAndConstraint 'DROP', 'oecd'

			DELETE FROM [dbo].[FactOECD]
			WHERE VersionID = @versionNo

			INSERT INTO [dbo].[FactOECD] 
					([VersionID],
					 [DataSourceID], 
					 [Country Code], 
					 [Period], 
					 [Indicator Code], 
					 [SubGroup],
					 [Age],
					 [Gender],
					 [Value]) 
			SELECT @versionNo,@dataSourceID,c.ID, LEFT(r.Period,4), i.ID,sub.ID, ag.ID, gen.ID, r.DataValue
			FROM (
				
				SELECT * FROM #OECD
			)r 
			LEFT JOIN (
				SELECT ID,[Indicator Name] 
				FROM   DimIndicators 
				WHERE  datasourceid = @dataSourceID
			) i
				ON r.Indicator = i.[Indicator Name]
			LEFT JOIN (
				SELECT ID,[Country Code]
				FROM DimCountry
				WHERE [Type] = 'country'
			) c
				ON r.CountryCode = c.[Country Code]
			LEFT JOIN (
				SELECT ID,age
				FROM   DimAge 
				WHERE  datasourceid = @dataSourceID
			) ag
				ON r.Age = ag.age
			LEFT JOIN (
				SELECT ID,gender
				FROM   DimGender 
				WHERE  datasourceid = @dataSourceID
			) gen
				ON r.gender = gen.gender
			LEFT JOIN (
				SELECT ID,SubGroup
				FROM   DimSubGroup 
				WHERE  datasourceid = @dataSourceID
			) sub
				ON r.SubGroup = sub.SubGroup
			
			UPDATE i
			SET i.[Indicator Code] = r.IndicatorNameAfter
			FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
			ON i.DataSourceID = r.DataSourceID
			AND i.[Indicator Name] = r.IndicatorNameBefore

			--EXECUTE [dbo].[PostProcessFactPivot] 'dhs', @versionNo

			EXECUTE ChangeIndexAndConstraint 'CREATE', 'oecd'

END


GO
/****** Object:  StoredProcedure [dbo].[ProcessOPHIData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessOPHIData]
AS
BEGIN
		
		SET NOCOUNT ON;
		
		--DROP TABLE #A
		SELECT CountryCode, CountryName, SubRegionName, CAST(NULL AS VARCHAR(200)) id
			INTO #A
		FROM [Gapminder_RAW].[ophi].[Raw_Data]
		GROUP BY CountryCode, CountryName, SubRegionName
		
		UPDATE A
		SET A.id  = G.id
		FROM #A A LEFT JOIN (SELECT * FROM DimGeo WHERE cat = 'province') G
			ON A.CountryCode = G.region
			AND A.SubRegionName = g.name
		WHERE G.id IS NOT NULL

		UPDATE A
		SET A.id = LOWER(A.CountryCode)+'-'+LOWER(REPLACE(A.SubRegionName,' ','-'))
		FROM #A A
		WHERE A.id IS NULL

		MERGE DimGeo T
		USING (
			SELECT A.id,SubRegionName name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #A A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'

		) S
		ON (T.id = S.id AND T.cat = 'province')
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES('geo',S.id,S.name,S.region,S.cat,S.lev);
		
		MERGE dbo.DimCountry T
		USING (
			SELECT A.id,SubRegionName name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #A A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'ophi'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'ophi'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator
			,NULL ID 
			FROM [Gapminder_RAW].[ophi].[Raw_Data]
			GROUP BY Indicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);
		
		EXECUTE ChangeIndexAndConstraint 'DROP', 'ophi'

		DELETE FROM [dbo].[FactOPHI]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactOPHI] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code], 
				 [SubGroup],
				 [Age],
				 [Gender],
				 [Value]) 
		SELECT @versionNo,@dataSourceID, r.ID, LEFT(r.Period,4), i.ID
				,s.ID
				,a.ID
				,g.ID, TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender
			FROM [Gapminder_RAW].[ophi].[Raw_Data] hr
			LEFT JOIN DimCountry dc
			ON hr.CountryCode = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator 
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender 
			FROM [Gapminder_RAW].[ophi].[Raw_Data] hr
			LEFT JOIN #A f
			ON hr.SubRegionName = F.SubRegionName
			AND hr.CountryCode = f.CountryCode
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'province'
			AND F.id IS NOT NULL
		)r 
		LEFT JOIN (
			SELECT ID,[Indicator Name] 
			FROM   DimIndicators 
			WHERE  datasourceid = @dataSourceID
		) i
			ON r.Indicator = i.[Indicator Name]
		LEFT JOIN (
			SELECT ID, SubGroup
			FROM DimSubGroup
			WHERE  DataSourceID = @dataSourceID
		) s
		ON r.SubGroup = s.SubGroup
		LEFT JOIN (
			SELECT ID, age
			FROM DimAge
			WHERE  DataSourceID = @dataSourceID
		) a
		ON r.Age = a.age
		LEFT JOIN (
			SELECT ID,gender
			FROM DimGender
			WHERE  DataSourceID = @dataSourceID
		) g
		ON r.Gender = g.gender

		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		--EXECUTE [dbo].[PostProcessFactPivot] 'ophi', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'ophi'

END


GO
/****** Object:  StoredProcedure [dbo].[ProcessSEDACData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessSEDACData]
AS
BEGIN
		SET NOCOUNT ON;

		--DROP TABLE #IMR
		SELECT CountryCode, Region, RegionCode
			, CAST(RegionCode as VARCHAR(200)) id
			INTO #IMR
		FROM [Gapminder_RAW].[sedac].[IMR]
		GROUP BY CountryCode, Region, RegionCode
		--select * from #IMR
		
		UPDATE G
		SET G.id =	LOWER(A.id)
		--SELECT *, ROW_NUMBER() OVER PARTITION BY A.
		FROM DimGeo G INNER JOIN #IMR A
		ON A.CountryCode = G.region
		AND A.Region = G.name

		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) RNK
			FROM DimGeo
		)
		DELETE FROM CTE WHERE RNK > 1

		MERGE DimGeo T
		USING (
			SELECT A.id,A.Region name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #IMR A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'
			AND LEN(A.ID)>3

		) S
		ON (T.id = S.id AND T.cat = 'province' AND T.region = S.region)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES('geo',S.id,S.name,S.region,S.cat,S.lev);

		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) RNK
			FROM DimGeo
		)
		DELETE FROM CTE WHERE RNK > 1
		
		MERGE dbo.DimCountry T
		USING (
			SELECT A.id,A.Region name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #IMR A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'
		) S
		ON (T.[Country Code] = S.id)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'sedac'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'sedac'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator 
			FROM [Gapminder_RAW].[sedac].[IMR]
			GROUP BY Indicator
				UNION
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator 
			FROM [Gapminder_RAW].[sedac].[National_Poverty_RawData]
			WHERE Indicator<>''
			GROUP BY Indicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator);
		
		EXECUTE ChangeIndexAndConstraint 'DROP', 'sedac'

		DELETE FROM [dbo].[FactSEDAC]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactSEDAC] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code],
				 [SubGroup],
				 [Age],
				 [Gender], 
				 [Value]) 
		SELECT @versionNo,@dataSourceID, r.ID, LEFT(r.Period,4), i.ID
				,s.ID
				,a.ID
				,g.ID, TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender
			FROM [Gapminder_RAW].[sedac].[IMR] hr
			LEFT JOIN DimCountry dc
			ON hr.CountryCode = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			,'N/A' SubGroup,'N/A' Age,'N/A' Gender
			FROM [Gapminder_RAW].[sedac].[IMR] hr
			LEFT JOIN #IMR f
			ON hr.RegionCode = F.RegionCode
			AND hr.CountryCode = f.CountryCode
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'province'
			AND F.id IS NOT NULL
		)r 
		LEFT JOIN (
			SELECT ID,[Indicator Name] 
			FROM   DimIndicators 
			WHERE  datasourceid = @dataSourceID
		) i
			ON r.Indicator = i.[Indicator Name]
		LEFT JOIN (
				SELECT ID, SubGroup
				FROM DimSubGroup
				WHERE  DataSourceID = @dataSourceID
		) s
		ON r.SubGroup = s.SubGroup
		LEFT JOIN (
			SELECT ID, age
			FROM DimAge
			WHERE  DataSourceID = @dataSourceID
		) a
		ON r.Age = a.age
		LEFT JOIN (
			SELECT ID,gender
			FROM DimGender
			WHERE  DataSourceID = @dataSourceID
		) g
		ON r.Gender = g.gender

		--DROP TABLE #POV
		SELECT CountryCode,CountryName,Region, 'province' cat
		,CAST(NULL AS VARCHAR(100)) id
		INTO #POV
		FROM (
			SELECT CountryCode,CountryName,Region, AdmLevel, DENSE_RANK() OVER(PARTITION BY CountryCode,CountryName ORDER BY AdmLevel) rnk 
			FROM [Gapminder_RAW].[sedac].[National_Poverty_RawData]
			WHERE ISNUMERIC(Region) = 0
			GROUP BY CountryCode,CountryName, Region, AdmLevel

		)A WHERE rnk = 1
		ORDER BY CountryName

		UPDATE B
		SET B.ID = IIF(G.id IS NULL, LOWER(B.CountryCode+'-'+REPLACE(B.Region,' ','-')) ,G.id)
		FROM #POV B LEFT JOIN (SELECT * FROM DimGeo WHERE cat = 'province') G
		ON B.Region = G.name
		AND B.CountryCode = G.region

		MERGE DimGeo T
		USING (
			SELECT A.id,A.Region name,LOWER(CountryCode) region, 'province' cat,G.[GeoLevelNo] lev
			FROM #POV A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'

		) S
		ON (T.id = S.id AND T.cat = 'province' AND T.region = S.region)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES('geo',S.id,S.name,S.region,S.cat,S.lev);

		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) RNK
			FROM DimGeo
		)
		DELETE FROM CTE WHERE RNK > 1
		
		MERGE dbo.DimCountry T
		USING (
			SELECT A.id,A.Region name,CountryCode region, 'province' cat,G.[GeoLevelNo] lev
			FROM #POV A, [dbo].[GeoHierarchyLevel] G
			WHERE G.[GeoLevelName] = 'province'
		) S
		ON (T.[Country Code] = S.id AND T.[type] ='province')
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES(S.cat,LOWER(S.id),S.name,S.name);

		--;WITH CTE
		--AS
		--(
		--	SELECT *, ROW_NUMBER() OVER (PARTITION BY [Country Code] ORDER BY [Country Code]) RNK
		--	FROM DimCountry
		--)
		--DELETE FROM CTE WHERE RNK > 1

		INSERT INTO [dbo].[FactSEDAC] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code], 
				 [Value]) 
		SELECT @versionNo,@dataSourceID, r.ID, LEFT(r.Period,4), i.ID, TRY_CONVERT(float,r.DataValue)
		FROM ( 
			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator
			FROM [Gapminder_RAW].[sedac].[National_Poverty_RawData] hr
			LEFT JOIN DimCountry dc
			ON hr.CountryCode = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'country'

			UNION ALL

			SELECT dc.ID, hr.Period, hr.DataValue,hr.Indicator  
			FROM [Gapminder_RAW].[sedac].[National_Poverty_RawData] hr
			LEFT JOIN #POV f
			ON hr.Region = F.Region
			AND hr.CountryCode = f.CountryCode
			LEFT JOIN DimCountry dc
			ON f.id = dc.[Country Code]
			WHERE dc.[Country Code] IS NOT NULL
			AND dc.Type = 'province'
			AND F.id IS NOT NULL
		)r 
		LEFT JOIN (
			SELECT ID,[Indicator Name] 
			FROM   DimIndicators 
			WHERE  datasourceid = @dataSourceID
		) i
			ON r.Indicator = i.[Indicator Name]


		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		--EXECUTE [dbo].[PostProcessFactPivot] 'sedac', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'sedac'

END


GO
/****** Object:  StoredProcedure [dbo].[ProcessSpreedSheetData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessSpreedSheetData]
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @dyn_sql NVARCHAR(max)
				,@baseFolderLocation VARCHAR(100)
				,@rawDataFileLocation VARCHAR(100)
				,@configFileLocation VARCHAR(100)
				,@indicatorFileLocation VARCHAR(100)
	
		SET @baseFolderLocation = N'C:\Users\shahnewaz\Documents\GapMinder_DEV\spreedsheet\'
		SET @rawDataFileLocation = @baseFolderLocation + 'AllRawData.txt';
		SET @configFileLocation = @baseFolderLocation + 'Config.txt';
		SET @indicatorFileLocation = @baseFolderLocation + 'Indicators.txt';

		TRUNCATE TABLE dbo.configTable 
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.configTable 
				FROM ''' + @configFileLocation + ''' 
				WITH 
					( 
					fieldterminator = ''\t'', 
					rowterminator = ''\n'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql

		--select * from WDI_Indicator 
		UPDATE [dbo].[configTable] 
		SET    [menu level1] = ISNULL([menu level1],'N/A')
			,[menu level2] = ISNULL([menu level2],'N/A')
			,[indicator url] = ISNULL([indicator url],'N/A')
			,[download] = ISNULL([download],'N/A')
			,[id] = ISNULL([id],'N/A')
			,[scale] =ISNULL([scale],'N/A')

		TRUNCATE TABLE dbo.SpreedSheetIndicator 
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.SpreedSheetIndicator 
				FROM ''' + @indicatorFileLocation + ''' 
				WITH 
					( 
					fieldterminator = '','', 
					rowterminator = ''\n'' 
					)
			'
		EXECUTE sp_executesql @dyn_sql 

		DELETE a 
		FROM   (SELECT *, 
						Row_number() 
						OVER( 
							partition BY indicator 
							ORDER BY indicator) rnk 
				FROM   dbo.SpreedSheetIndicator)A 
		WHERE  rnk > 1

		TRUNCATE TABLE dbo.SpreedSheetAllRawData;
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.SpreedSheetAllRawData 
				FROM  '''  + @rawDataFileLocation + '''
				WITH 
					( 
					fieldterminator = '','', 
					rowterminator = ''\n'' 
					)
			'
		EXECUTE sp_executesql @dyn_sql

		UPDATE dbo.SpreedSheetIndicator
		SET indicator = REPLACE(indicator,'"','')

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'spreedsheet'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'spreedsheet'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, indicator
			,ID 
			FROM dbo.SpreedSheetIndicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);
		
		EXECUTE ChangeIndexAndConstraint 'DROP', 'spreedsheet'

		DELETE FROM [dbo].[FactSpreedSheet]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactSpreedSheet] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code],
				 [SubGroup],
				 [Age],
				 [Gender],
				 [Value]) 
		SELECT	@versionNo
				,@dataSourceID
				,dc.id 
				,TRY_CONVERT(int, fd.period) 
				,di.id
				,s.ID
				,a.ID
				,g.ID
				,TRY_CONVERT(float, fd.[value]) 
		FROM (
				SELECT *,'N/A' SubGroup,'N/A' Age,'N/A' Gender
				FROM [dbo].[SpreedSheetAllRawData]
		) fd 
			LEFT JOIN (
				SELECT ID,TempID 
				FROM   DimIndicators 
				WHERE  DataSourceID = @dataSourceID
			) di 
			ON fd.pathid = di.tempid 
			LEFT JOIN (
				SELECT ID, [Short Name]
				FROM DimCountry
				WHERE [Type] = 'country'
			) dc 
			ON fd.country = dc.[short name] 
			LEFT JOIN (
				SELECT ID, SubGroup
				FROM DimSubGroup
				WHERE  DataSourceID = @dataSourceID
			) s
			ON fd.SubGroup = s.SubGroup
			LEFT JOIN (
				SELECT ID, age
				FROM DimAge
				WHERE  DataSourceID = @dataSourceID
			) a
			ON fd.Age = a.age
			LEFT JOIN (
				SELECT ID,gender
				FROM DimGender
				WHERE  DataSourceID = @dataSourceID
			) g
			ON fd.Gender = g.gender
			WHERE  di.id IS NOT NULL 
			AND dc.id IS NOT NULL
		
		EXECUTE ProcessAdhocData

		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		EXECUTE [dbo].[PostProcessFactPivot] 'spreedsheet', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'spreedsheet'


		/*
			DROP TABLE [dbo].[DimIndicatorsMetaData]
			CREATE TABLE [dbo].[DimIndicatorsMetaData](
				[ID] [varchar](50) NULL,
				[Name] [varchar](200) NULL,
				[Val] [varchar](500) NULL
			) ON [PRIMARY]

			DECLARE @dyn_sql NVARCHAR(max)
			SET @dyn_sql = 
				N'
					BULK INSERT [dbo].[DimIndicatorsMetaData]
					FROM ''C:\Users\shahnewaz\Documents\GapMinder_DEV\spreedsheet\Settings.txt'' 
					WITH 
						( 
						fieldterminator = '','', 
						rowterminator = ''\n'' 
						) 
				'
			EXECUTE sp_executesql @dyn_sql

			UPDATE DimIndicatorsMetaData
			SET NAME = 'Scale type'
			WHERE NAME = 'Scale type (log or lin)'

			UPDATE MD
			SET Name = CASE  WHEN VAL = 'LOG' THEN 'Scale type'
								WHEN VAL LIKE 'http://' THEN 'Source link'
								WHEN VAL = '' THEN ''
							ELSE NAME END
			FROM [dbo].[DimIndicatorsMetaData] MD
			WHERE MD.ID IN (
				select ID from [dbo].[DimIndicatorsMetaData]
				where name not in ('source name','source link','scale type')
				GROUP BY ID
				HAVING COUNT(*)=3
			)

			UPDATE MD
			SET Name = CASE WHEN VAL LIKE 'http://' THEN 'Source link'
							ELSE 'Source name' END
			FROM [dbo].[DimIndicatorsMetaData] MD
			WHERE MD.ID IN (
				select ID from [dbo].[DimIndicatorsMetaData]
				where name not in ('source name','source link','scale type')
				GROUP BY ID
				HAVING COUNT(*)= 2
			)

			SELECT * INTO #A
			FROM [dbo].[DimIndicatorsMetaData]

			DROP TABLE [dbo].[DimIndicatorsMetaData]
			select *
			INTO [dbo].[DimIndicatorsMetaData]
			from (
				select * from #A

			)A
			pivot(
				max(val)
				for [name] in ([Source name],[Source link],[Scale Type])
			) as pvt




		*/

END


GO
/****** Object:  StoredProcedure [dbo].[ProcessSubNationalData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ProcessSubNationalData]
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @dyn_sql NVARCHAR(max)
				,@baseFolderLocation VARCHAR(100)
				,@rawDataFileLocation VARCHAR(100)
				,@maxRowCount int
	
		SET @baseFolderLocation = N'C:\Users\shahnewaz\Documents\GapMinder_DEV\subnational\'
		SET @rawDataFileLocation = @baseFolderLocation + 'AllSubNationalRawData.txt';
		
		DROP TABLE dbo.SubNationalData

		CREATE TABLE dbo.SubNationalData
		( 
			[indicator name] VARCHAR(max), 
			[indicator code] VARCHAR(max), 
			[country name]   VARCHAR(max), 
			[country code]   VARCHAR(max), 
			[period]         INT, 
			[value]          FLOAT 
		)
		
		TRUNCATE TABLE dbo.SubNationalData
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.SubNationalData
				FROM ''' + @rawDataFileLocation + ''' 
				WITH 
					(
					FIELDTERMINATOR = '','', 
					ROWTERMINATOR = ''\n'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql
		
		ALTER TABLE dbo.SubNationalData
        ADD [region] VARCHAR(max) 

		UPDATE dbo.SubNationalData 
		SET [region] = Replace(Substring([country name], 
								Charindex(';', [country name], 1) + 
									   1, Len( 
								[country name])), '"', ''), 
			[country name] = Replace(Substring([country name], 1, 
									  Charindex(';', [country name], 1) - 1), 
							  '"' 
							  , '') 
		WHERE  Charindex(';', [country name], 1) > 1

		SELECT CASE WHEN sd.Region IS NULL THEN 'geo' ELSE 'region' END [Type], 
		sd.[Country Code] factID,
		CAST (NULL AS VARCHAR(200)) CountryID
		,LEFT([Country Code],3) CountryCode
		,LTRIM(Region) Region
		into #a
		FROM  SubNationalData sd
		--WHERE region IS NOT NULL
		GROUP BY sd.[Country Code],sd.[Country Name],sd.Region

		UPDATE a
		SET a.CountryID = g.id
		--select * 
		FROM #a a LEFT JOIN (SELECT name,region,id FROM DimGeo WHERE cat ='province') g
		ON ISNULL(a.Region,'') = g.name
		AND a.CountryCode = g.region
		WHERE g.id IS NOT NULL

		UPDATE a
		SET a.CountryID = lower(a.CountryCode+'-'+a.Region)
		--select * 
		FROM #a a LEFT JOIN (SELECT name,region,id FROM DimGeo WHERE cat ='province') g
		ON  ISNULL(a.Region,'') = g.name
		AND a.CountryCode = g.region
		WHERE g.id IS NULL

		MERGE DimGeo T
		USING (
			SELECT * FROM #A WHERE [type]='region'
		) S
		ON (T.id = S.CountryID AND T.cat = 'province')
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(dim,id,name,region,cat,lev) 
			VALUES('geo',LOWER(S.CountryID),s.Region,LOWER(S.CountryCode),'province',4);
		
		MERGE dbo.DimCountry T
		USING (
			SELECT * FROM #A WHERE [type]='region'
		) S
		ON (T.[Country Code] = S.CountryID)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([type],[Country Code],[Short Name],[Country Name]) 
			VALUES('province',LOWER(S.CountryID),S.Region,S.Region);

		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'subnational'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'subnational'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator name],' ', '_'),'(',''),')','')),255)) [Indicator Code]
			, [indicator name] indicator
			,NULL ID 
			FROM dbo.SubNationalData 
			GROUP  BY [indicator name]
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[Indicator Code],S.indicator,S.ID);

		EXECUTE ChangeIndexAndConstraint 'DROP', 'subnational'

		DELETE FROM [dbo].[FactSubNational]
		WHERE VersionID = @versionNo

		INSERT INTO [dbo].[FactSubNational] 
				([VersionID],
				 [DataSourceID], 
				 [Country Code], 
				 [Period], 
				 [Indicator Code],
				 [SubGroup],
				 [Age],
				 [Gender],
				 [Value]) 
		SELECT	@versionNo
				,@dataSourceID
				,dc.id 
				,TRY_CONVERT(int, fd.period) 
				,di.id
				,s.ID
				,a.ID
				,g.ID
				,TRY_CONVERT(float, fd.[value]) 
		FROM (
				SELECT *,'N/A' SubGroup,'N/A' Age,'N/A' Gender
				FROM [dbo].[SubNationalData]
		) fd 
			LEFT JOIN (
				SELECT ID,[Indicator Name] 
				FROM   DimIndicators 
				WHERE  DataSourceID = @dataSourceID
			) di 
			ON fd.[indicator name] = di.[Indicator Name]
			LEFT JOIN (
				SELECT ID, A.factID
				FROM DimCountry c INNER JOIN #a A
				ON C.[Country Code] = A.CountryID
				WHERE c.[Type] = 'province'
			) dc 
			ON fd.[country code] = dc.factID
			LEFT JOIN (
				SELECT ID, SubGroup
				FROM DimSubGroup
				WHERE  DataSourceID = @dataSourceID
			) s
			ON fd.SubGroup = s.SubGroup
			LEFT JOIN (
				SELECT ID, age
				FROM DimAge
				WHERE  DataSourceID = @dataSourceID
			) a
			ON fd.Age = a.age
			LEFT JOIN (
				SELECT ID,gender
				FROM DimGender
				WHERE  DataSourceID = @dataSourceID
			) g
			ON fd.Gender = g.gender
			WHERE  di.id IS NOT NULL 
			AND dc.id IS NOT NULL
		
		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore

		--EXECUTE [dbo].[PostProcessFactPivot] 'subnational', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'subnational'
		
END

GO
/****** Object:  StoredProcedure [dbo].[ProcessWDIData]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessWDIData]
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @dyn_sql NVARCHAR(max)
				,@baseFolderLocation VARCHAR(100)
				,@rawDataFileLocation VARCHAR(100)
				,@wdiCountryData VARCHAR(100)
	
		SET @baseFolderLocation = N'C:\Users\shahnewaz\Documents\GapMinder_DEV\wdi\'
		SET @rawDataFileLocation = @baseFolderLocation + 'AllWDIRawData.txt';
		SET @wdiCountryData = @baseFolderLocation + 'Data\WDI_Country.csv';
		
		TRUNCATE TABLE dbo.WDI_Country
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.WDI_Country
				FROM ''' + @wdiCountryData + ''' 
				WITH 
					(
					FIRSTROW = 2,
					FIELDTERMINATOR = '','', 
					ROWTERMINATOR = ''\n'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql
		
		TRUNCATE TABLE dbo.WDI_Data
		SET @dyn_sql = 
			N'
				BULK INSERT dbo.WDI_Data
				FROM ''' + @rawDataFileLocation + ''' 
				WITH 
					( 
					fieldterminator = '','', 
					rowterminator = ''\n'' 
					) 
			'
		EXECUTE sp_executesql @dyn_sql
		
		TRUNCATE TABLE dbo.WDI_Indicator
		INSERT INTO dbo.WDI_Indicator(ID,indicator,indicatorCode)
		SELECT ROW_NUMBER() over(order by A.indicator) ID, A.indicator, A.[Indicator Code]
		FROM   (
				SELECT [indicator name] indicator,[Indicator Code]
				FROM   wdi_data 
				GROUP  BY [indicator name],[Indicator Code]
		)A

		;WITH CTE
		AS
		(
			SELECT *, ROW_NUMBER() OVER (PARTITION BY [IndicatorCode] ORDER BY [IndicatorCode]) RNK
			FROM dbo.WDI_Indicator
		)
		DELETE FROM CTE WHERE RNK > 1

		UPDATE dbo.WDI_Indicator
		SET indicator = REPLACE(indicator,'"','')
		
		DECLARE @versionNo INT
		SELECT @versionNo = MAX(VersionNo)
		FROM UtilityDataVersions
		WHERE DataSource = 'wdi'
		GROUP BY DataSource
		--SELECT @versionNo
		
		DECLARE @dataSourceID INT
		SELECT @dataSourceID = ID
		FROM DimDataSource
		WHERE DataSource = 'wdi'
		--SELECT @dataSourceID

		MERGE DimIndicators T
		USING (
			SELECT @dataSourceID DataSourceID
			,[IndicatorCode]
			, indicator --LTRIM(LEFT(LOWER(REPLACE(REPLACE(REPLACE([indicator],' ', '_'),'(',''),')','')),255)) 
			,ID 
			FROM dbo.WDI_Indicator
		) S
		ON (T.[DataSourceID] = S.DataSourceID AND T.[Indicator Name] = S.indicator AND T.[Indicator Code] = S.indicatorCode)
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT([DataSourceID],[Indicator Code],[Indicator Name],[TempID]) 
			VALUES(S.DataSourceID,S.[IndicatorCode],S.indicator,S.ID);

		EXECUTE ChangeIndexAndConstraint 'DROP', 'wdi'

		DELETE FROM [dbo].[FactWDI]
		WHERE VersionID = @versionNo
		
		INSERT INTO [dbo].[FactWDI] 
		(
			[VersionID],
			[DataSourceID], 
			[Country Code], 
			[Period], 
			[Indicator Code],
			[SubGroup],
			[Age],
			[Gender], 
			[Value]
		)
		SELECT 
			@versionNo,@dataSourceID, 
			dc.id, 
			TRY_CONVERT(int, fd.period), 
			di.id,
			s.ID,
			a.ID,
			g.ID ,
			TRY_CONVERT(float, fd.[value]) 
		FROM (SELECT *,'N/A' SubGroup,'N/A' Age,'N/A' Gender FROM dbo.WDI_Data) fd 
			LEFT JOIN (
				SELECT ID,[Indicator Code] 
				FROM   DimIndicators 
				WHERE  datasourceid = @dataSourceID
			) di 
			ON fd.[Indicator Code] = di.[Indicator Code]
			LEFT JOIN (
				SELECT ID,[Short Name]
				FROM DimCountry
				WHERE [Type] = 'country'
			) dc 
			ON fd.[country name] = dc.[short name] 
			LEFT JOIN (
				SELECT ID, SubGroup
				FROM DimSubGroup
				WHERE  DataSourceID = @dataSourceID
			) s
			ON fd.SubGroup = s.SubGroup
			LEFT JOIN (
				SELECT ID, age
				FROM DimAge
				WHERE  DataSourceID = @dataSourceID
			) a
			ON fd.Age = a.age
			LEFT JOIN (
				SELECT ID,gender
				FROM DimGender
				WHERE  DataSourceID = @dataSourceID
			) g
			ON fd.Gender = g.gender
		WHERE  di.id IS NOT NULL 
		AND dc.id IS NOT NULL 

		UPDATE i
		SET i.[Indicator Code] = r.IndicatorNameAfter
		FROM DimIndicators i INNER JOIN UtilityRenameIndicator r
		ON i.DataSourceID = r.DataSourceID
		AND i.[Indicator Name] = r.IndicatorNameBefore
		
		EXECUTE [dbo].[PostProcessFactPivot] 'wdi', @versionNo

		EXECUTE ChangeIndexAndConstraint 'CREATE', 'wdi'
		
END


GO
/****** Object:  StoredProcedure [dbo].[QuantityQuery]    Script Date: 9/24/2015 9:02:48 AM ******/
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
/****** Object:  StoredProcedure [dbo].[StatsQuery]    Script Date: 9/24/2015 9:02:48 AM ******/
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
				,@factTablePivoted NVARCHAR(MAX)
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
		CREATE TABLE #VERSION (ver VARCHAR(100))
		CREATE TABLE #time (period INT)
		
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

			-- extract FROM
			INSERT INTO #FROM
			SELECT x.col.value('.', 'VARCHAR(100)') AS [text()]
			FROM @XmlStr.nodes('//root//query//FROM') x(col)

			INSERT INTO #VERSION
			SELECT x.col.value('.', 'VARCHAR(100)') AS [text()]
			FROM @XmlStr.nodes('//root//query//VERSION') x(col)

			IF(@@ROWCOUNT=0 OR (SELECT TOP 1 VER FROM #VERSION)='')
			BEGIN
				TRUNCATE TABLE #VERSION
				INSERT INTO #VERSION
				SELECT Max(VersionNo)
				FROM UtilityDataVersions DV INNER JOIN #FROM F
				ON DV.DataSource = F.tab
				GROUP BY DV.DataSource
			END

			UPDATE #VERSION
			SET ver =  REPLACE(ver,'v','')
			
			DECLARE @versionID VARCHAR(10)
			SELECT TOP 1 @versionID = ver FROM #VERSION

			SELECT @dataSourceID = S.ID
			, @factTable = S.FactTableName
			,@factTablePivoted = S.FactTablePivotedName
			FROM DimDataSource S INNER JOIN #FROM F
			ON S.DataSource = F.tab

			-- extract the indicator list from SELECT clause
			INSERT INTO #whereind
			SELECT s.name
			FROM #SELECT s LEFT JOIN vDimDetails d
			ON s.name = d.[-t-id]
			WHERE d.[-t-id] IS NULL

			IF(
				SELECT COUNT(*)
				FROM #whereind I LEFT JOIN 
				(SELECT * FROM UtilityCommonlyUsedIndicators WHERE DataSourceID = @dataSourceID) C
				ON I.name = C.IndicatorCode
				WHERE C.ID IS NULL
			) = 0 AND @factTablePivoted IS NOT NULL
			BEGIN
				EXECUTE StatsQuery_Pivoted @XML

				UPDATE LogRequest
				SET [Status] = 1
				,EndTime = getdate()
				WHERE QueryUniqueID = @newId

				RETURN
			END

			select 'not in pivoted'

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
			IF(
				@@ROWCOUNT=0 
				OR (SELECT TOP 1 age FROM #whereage)='' 
				OR (SELECT TOP 1 age FROM #whereage)='*'
			)
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
			WHERE da.DataSourceID = @dataSourceID

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
				SELECT id,gender FROM DimGender WHERE gender = @gen AND DataSourceID = @dataSourceID
			END

			UPDATE G
			SET G.id = DG.ID
			FROM #wheregender G INNER JOIN DimGender DG
			ON G.gender = DG.gender
			WHERE DG.DataSourceID = @dataSourceID


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
				SELECT id,SubGroup FROM DimSubGroup WHERE SubGroup = @grp AND DataSourceID = @dataSourceID
			END

			UPDATE S
			SET S.id = DS.ID
			FROM #wheresubgroup S INNER JOIN DimSubGroup DS
			ON S.grp = DS.SubGroup
			WHERE DS.DataSourceID = @dataSourceID

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

			--SELECT @indColInSelect
	
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
								SELECT f.*,dc.[Country Code] par,dc.[Short Name] partID  FROM (SELECT VersionID,[DataSourceID],[country code], [period], [indicator code],[SubGroup],[Age],[Gender],[Value] FROM dbo.[' + @factTable + '] WHERE [DataSourceID] = ' + @dataSourceID + ' AND VersionID='+ @versionID + ') f 
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
								SELECT f.* FROM (SELECT VersionID,[DataSourceID],[country code], [period], [indicator code],[SubGroup],[Age],[Gender],[Value]  FROM dbo.[' + @factTable + '] WHERE [DataSourceID] = ' + @dataSourceID + '  AND VersionID='+ @versionID + ') f 
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
				SET @factTable = @factTable + @newId
			END

			--select * from #geoFinal
			--select * from #whereage
			--select * from #wherecat
			--select * from #whereind
			--select * from #wheregender
			--select * from #wheresubgroup
			--return

			SET @dyn_sql = N'
					SELECT ' + @colInQuerySelection + ', sum(f.Value) val,  di.[Indicator Code]
					INTO [SumTable' + @newId + ']
					FROM (SELECT VersionID,[DataSourceID],[country code], [period], [indicator code],[SubGroup],[Age],[Gender],[Value]  FROM dbo.[' + @factTable + '] WHERE [DataSourceID] = ' + @dataSourceID + '   AND VersionID='+ @versionID + ') f 
					LEFT JOIN (SELECT * FROM #geoFinal) dc
					ON f.[Country Code] = dc.ID
					LEFT JOIN ( SELECT i.[ID],i.[dataSourceID], [Indicator Code], i.[Indicator Name] FROM DimIndicators i LEFT JOIN #whereind w ON i.[Indicator Code] = w.name WHERE w.name IS NOT NULL) di
					ON f.[Indicator Code] = di.ID
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
					AND di.ID IS NOT NULL
					AND f.Period = t.period--(Period >=t.minTime AND Period <= t.maxTime)
					--AND f.Period between @start AND @END
					AND ag.ID IS NOT NULL
					AND gen.ID IS NOT NULL
					AND sg.ID IS NOT NULL
					group by ' + @colInGroupBy + ', di.[Indicator Code]
				'
			--PRINT @dyn_sql
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
/****** Object:  StoredProcedure [dbo].[StatsQuery_]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[StatsQuery_]
@XML XML
AS
BEGIN
		SET NOCOUNT ON;
		
		execute StatsQuery_Pivoted @xml
		return 

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

		SET @factTable = 'FactFinalHMD'

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

			--SELECT @indColInSelect
	
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
				PRINT @dyn_sql
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
					SELECT ' + @colInQuerySelection + ', sum(f.Value) val,  di.[Indicator Code]
					INTO [SumTable' + @newId + ']
					FROM (SELECT [DataSourceID],[country code], [period], [indicator code],[SubGroup],[Age],[Gender],[Value]  FROM dbo.[' + @factTable + '] WHERE [DataSourceID] = ' + @dataSourceID + ' ) f 
					LEFT JOIN (SELECT * FROM #geoFinal) dc
					ON f.[Country Code] = dc.ID
					LEFT JOIN ( SELECT i.[ID],i.[dataSourceID], [Indicator Code], i.[Indicator Name] FROM DimIndicators i LEFT JOIN #whereind w ON i.[Indicator Code] = w.name WHERE w.name IS NOT NULL) di
					ON f.[Indicator Code] = di.ID
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
					AND di.ID IS NOT NULL
					AND f.Period = t.period--(Period >=t.minTime AND Period <= t.maxTime)
					--AND f.Period between @start AND @END
					AND ag.ID IS NOT NULL
					AND gen.ID IS NOT NULL
					AND sg.ID IS NOT NULL
					group by ' + @colInGroupBy + ', di.[Indicator Code]
				'
			--PRINT @dyn_sql
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
/****** Object:  StoredProcedure [dbo].[StatsQuery_2]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[StatsQuery_2]
@XML XML
AS
BEGIN
		SET NOCOUNT ON;
		
		DECLARE @XmlStr XML
				,@dyn_sql NVARCHAR(MAX)
				,@dropT NVARCHAR(MAX)
				,@newId NVARCHAR(MAX)
				,@factTable NVARCHAR(MAX)
				,@factTablePivoted NVARCHAR(MAX)
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
		CREATE TABLE #VERSION (ver VARCHAR(100))
		CREATE TABLE #time (period INT)
		
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

			-- extract FROM
			INSERT INTO #FROM
			SELECT x.col.value('.', 'VARCHAR(100)') AS [text()]
			FROM @XmlStr.nodes('//root//query//FROM') x(col)

			INSERT INTO #VERSION
			SELECT x.col.value('.', 'VARCHAR(100)') AS [text()]
			FROM @XmlStr.nodes('//root//query//VERSION') x(col)

			IF(@@ROWCOUNT=0 OR (SELECT TOP 1 VER FROM #VERSION)='')
			BEGIN
				TRUNCATE TABLE #VERSION
				INSERT INTO #VERSION
				SELECT Max(VersionNo)
				FROM UtilityDataVersions DV INNER JOIN #FROM F
				ON DV.DataSource = F.tab
				GROUP BY DV.DataSource
			END

			UPDATE #VERSION
			SET ver =  REPLACE(ver,'v','')

			SELECT @dataSourceID = S.ID
			, @factTable = S.FactTableName
			,@factTablePivoted = S.FactTablePivotedName
			FROM DimDataSource S INNER JOIN #FROM F
			ON S.DataSource = F.tab

			-- extract the indicator list from SELECT clause
			INSERT INTO #whereind
			SELECT s.name
			FROM #SELECT s LEFT JOIN vDimDetails d
			ON s.name = d.[-t-id]
			WHERE d.[-t-id] IS NULL

			IF(
				SELECT COUNT(*)
				FROM #whereind I LEFT JOIN 
				(SELECT * FROM UtilityCommonlyUsedIndicators WHERE DataSourceID = @dataSourceID) C
				ON I.name = C.IndicatorCode
				WHERE C.ID IS NULL
			) = 0 AND @factTablePivoted IS NOT NULL
			BEGIN
				EXECUTE StatsQuery_Pivoted @XML

				UPDATE LogRequest
				SET [Status] = 1
				,EndTime = getdate()
				WHERE QueryUniqueID = @newId

				RETURN
			END

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
			IF(
				@@ROWCOUNT=0 
				OR (SELECT TOP 1 age FROM #whereage)='' 
				OR (SELECT TOP 1 age FROM #whereage)='*'
			)
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
			WHERE da.DataSourceID = @dataSourceID

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
				SELECT id,gender FROM DimGender WHERE gender = @gen AND DataSourceID = @dataSourceID
			END

			UPDATE G
			SET G.id = DG.ID
			FROM #wheregender G INNER JOIN DimGender DG
			ON G.gender = DG.gender
			WHERE DG.DataSourceID = @dataSourceID


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
				SELECT id,SubGroup FROM DimSubGroup WHERE SubGroup = @grp AND DataSourceID = @dataSourceID
			END

			UPDATE S
			SET S.id = DS.ID
			FROM #wheresubgroup S INNER JOIN DimSubGroup DS
			ON S.grp = DS.SubGroup
			WHERE DS.DataSourceID = @dataSourceID

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
	
			select * from #wheregeo
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

			--SELECT @indColInSelect
	
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

			select * from #geoFinal
			return;

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
				EXECUTE SP_EXECUTESQL @dyn_sql, @parmDefinition, @start = @start, @END = @END
				--exec('SELECT * FROM [FactFinal' + @newId + ']')
				SET @factTable = @factTable + @newId
			END

			--select * from #geoFinal
			--select * from #whereage
			--select * from #wherecat
			--select * from #whereind
			--select * from #wheregender
			--select * from #wheresubgroup
			--return

			SET @dyn_sql = N'
					SELECT ' + @colInQuerySelection + ', sum(f.Value) val,  di.[Indicator Code]
					INTO [SumTable' + @newId + ']
					FROM (SELECT [DataSourceID],[country code], [period], [indicator code],[SubGroup],[Age],[Gender],[Value]  FROM dbo.[' + @factTable + '] WHERE [DataSourceID] = ' + @dataSourceID + ' ) f 
					LEFT JOIN (SELECT * FROM #geoFinal) dc
					ON f.[Country Code] = dc.ID
					LEFT JOIN ( SELECT i.[ID],i.[dataSourceID], [Indicator Code], i.[Indicator Name] FROM DimIndicators i LEFT JOIN #whereind w ON i.[Indicator Code] = w.name WHERE w.name IS NOT NULL) di
					ON f.[Indicator Code] = di.ID
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
					AND di.ID IS NOT NULL
					AND f.Period = t.period--(Period >=t.minTime AND Period <= t.maxTime)
					--AND f.Period between @start AND @END
					AND ag.ID IS NOT NULL
					AND gen.ID IS NOT NULL
					AND sg.ID IS NOT NULL
					group by ' + @colInGroupBy + ', di.[Indicator Code]
				'
			--PRINT @dyn_sql
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
/****** Object:  StoredProcedure [dbo].[StatsQuery_Pivoted]    Script Date: 9/24/2015 9:02:48 AM ******/
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
		CREATE TABLE #VERSION (ver VARCHAR(100))
		CREATE TABLE #time (period INT)
		/*
			history of data level available for each source
		*/
		SET @XmlStr = @XML
		SET @newId = NEWID()

		SET @factTable = 'FactFinalHMD_Pivoted'

		BEGIN TRY
		
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

			-- extract FROM
			INSERT INTO #FROM
			SELECT x.col.value('.', 'VARCHAR(100)') AS [text()]
			FROM @XmlStr.nodes('//root//query//FROM') x(col)

			INSERT INTO #VERSION
			SELECT x.col.value('.', 'VARCHAR(100)') AS [text()]
			FROM @XmlStr.nodes('//root//query//VERSION') x(col)

			IF(@@ROWCOUNT=0 OR (SELECT TOP 1 VER FROM #VERSION)='')
			BEGIN
				TRUNCATE TABLE #VERSION
				INSERT INTO #VERSION
				SELECT Max(VersionNo)
				FROM UtilityDataVersions DV INNER JOIN #FROM F
				ON DV.DataSource = F.tab
				GROUP BY DV.DataSource
			END

			UPDATE #VERSION
			SET ver =  REPLACE(ver,'v','')

			DECLARE @versionID VARCHAR(10)
			SELECT TOP 1 @versionID = ver FROM #VERSION

	
			SELECT @dataSourceID = S.ID 
			,@factTable = ISNULL(S.[FactTablePivotedName],S.[FactTableName])
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
			WHERE da.DataSourceID = @dataSourceID

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
				SELECT id,gender FROM DimGender WHERE gender = @gen AND DataSourceID = @dataSourceID
			END

			UPDATE G
			SET G.id = DG.ID
			FROM #wheregender G INNER JOIN DimGender DG
			ON G.gender = DG.gender
			WHERE DG.DataSourceID = @dataSourceID


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
				SELECT id,SubGroup FROM DimSubGroup WHERE SubGroup = @grp AND DataSourceID = @dataSourceID
			END

			UPDATE S
			SET S.id = DS.ID
			FROM #wheresubgroup S INNER JOIN DimSubGroup DS
			ON S.grp = DS.SubGroup
			WHERE DS.DataSourceID = @dataSourceID

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
			ON dc.[Country Code] = c.id
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
				DECLARE @measureWeighted NVARCHAR(MAX)
				DECLARE @measureWeightedByPop NVARCHAR(MAX)
				DECLARE @measureNormal NVARCHAR(MAX)
				DECLARE @measureFinal NVARCHAR(MAX)

				SELECT @measureWeighted =  stuff(
					(
						SELECT ',(ISNULL(['+ I.name + '],0) * ISNULL([pop],0)) [' + I.name + ']'  
						FROM #whereind I
						LEFT JOIN (SELECT Indicator FROM UtilityIndicatorCalculation 
									WHERE CalType = 'weighted') W
						ON I.name = W.Indicator
						WHERE W.Indicator IS NOT NULL
						FOR XML PATH('')
					)
				,1,1,'')

				SELECT @measureWeightedByPop =  stuff(
					(
						SELECT ', SUM((IIF([' + I.name +'] IS NULL,0,1) * [pop])) OVER(PARTITION BY f.[DataSourceID], f.[Period], f.[SubGroup] ,f.[Age], f.[Gender]) [' + I.name + '_pop]'  
						FROM #whereind I
						LEFT JOIN (SELECT Indicator FROM UtilityIndicatorCalculation 
									WHERE CalType = 'weighted') W
						ON I.name = W.Indicator
						WHERE W.Indicator IS NOT NULL
						FOR XML PATH('')
					)
				,1,1,'')

				SELECT @measureFinal =  stuff(
					(
						SELECT ', (([' + I.name +'])/([' + I.name + '_pop])) [' + I.name + ']'  
						FROM #whereind I
						LEFT JOIN (SELECT Indicator FROM UtilityIndicatorCalculation 
									WHERE CalType = 'weighted') W
						ON I.name = W.Indicator
						WHERE W.Indicator IS NOT NULL
						FOR XML PATH('')
					)
				,1,1,'')

				SELECT @measureNormal =  stuff(
					(
						SELECT ',['+ I.name + ']'  
						FROM #whereind I
						LEFT JOIN (SELECT Indicator FROM UtilityIndicatorCalculation 
									WHERE CalType = 'weighted') W
						ON I.name = W.Indicator
						WHERE W.Indicator IS NULL
						FOR XML PATH('')
					)
				,1,1,'')

				SET @dyn_sql = N'
					SELECT [DataSourceID], [Country Code], [Period], [SubGroup]
						,[Age], [Gender],[pop],' + @measureFinal + '
					INTO [FactFinal' + @newId + ']
					FROM (
						SELECT f.VersionID, f.[DataSourceID], f.[Country Code], f.[Period], f.[SubGroup]
						,f.[Age], f.[Gender], ' + @measureNormal + ','  
						+ @measureWeighted + ',' + @measureWeightedByPop + '  
						FROM dbo.[' + @factTable + '] f 
						LEFT JOIN (SELECT * FROM #geoFinal) dc
						ON f.[Country Code] = dc.ID
						, #time t 
						WHERE dc.ID IS NOT NULL
						AND f.Period = t.period
						AND f.VersionID = '+ @versionID + '
						AND f.DataSourceID = (SELECT top 1 ID FROM DimDataSource INNER JOIN #FROM ON DataSource = tab)
					)A
				'
				--PRINT @dyn_sql
				EXECUTE SP_EXECUTESQL @dyn_sql, @parmDefinition, @start = @start, @END = @END
				--exec('SELECT * FROM [FactFinal' + @newId + ']')
				SET @factTable = 'FactFinal' + @newId
				--RETURN;
			END

			DECLARE @otherJoin VARCHAR(MAX)
			SET @otherJoin = ''

			--IF(SELECT COUNT(*) FROM #SELECT WHERE name = )
			--BEGIN
			--END

			SET @dyn_sql = N'
					SELECT ' + @colInQuerySelection + ', ' + @indColInSelectPivoted + '
					INTO [SumTable' + @newId + ']
					FROM (SELECT * FROM dbo.[' + @factTable + '] WHERE [DataSourceID] = ' + @dataSourceID + '   AND VersionID='+ @versionID + ') f 
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
			PRINT @dyn_sql

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
				SELECT ',CASE WHEN ['+ I.name +'] IS NOT NULL THEN ['+ I.name +'] ELSE dbo.fix(['+ I.name +'S] + (1. * ['+ I.name+'M] / ['+ I.name +'X]) * (LEAD(['+I.name+'], ['+ I.name +'N], ['+ I.name +'S]) OVER (partition by ' + @colsM + ' ORDER BY [time]) - ['+ I.name +'S]),4) END [' + I.name + ']'  
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
/****** Object:  StoredProcedure [dbo].[TempForFactoring]    Script Date: 9/24/2015 9:02:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TempForFactoring]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DROP TABLE subnationaldata 

      CREATE TABLE subnationaldata 
        ( 
           [indicator name] VARCHAR(max), 
           [indicator code] VARCHAR(max), 
           [country name]   VARCHAR(max), 
           [country code]   VARCHAR(max), 
           [period]         INT, 
           [value]          FLOAT 
        ) 

      TRUNCATE TABLE dbo.subnationaldata 

      BULK INSERT dbo.subnationaldata 
        FROM 'C:\Users\shahnewaz\Documents\GapMinder\allSubnationalData.txt' 
        WITH 
          ( 
            fieldterminator = ',', 
            rowterminator = '\n' 
          ) 
      ALTER TABLE dbo.subnationaldata 
        ADD [region] VARCHAR(max) 

      UPDATE subnationaldata 
      SET    [region] = Replace(Substring([country name], 
                                Charindex(';', [country name], 1) + 
                                       1, Len( 
                                [country name])), '"', ''), 
             [country name] = Replace(Substring([country name], 1, 
                                      Charindex(';', [country name], 1) - 1), 
                              '"' 
                              , '') 
      WHERE  Charindex(';', [country name], 1) > 1 

      DROP TABLE subnationalindicator 

      CREATE TABLE [dbo].[subnationalindicator] 
        ( 
           [id]        INT NULL, 
           [indicator] [VARCHAR](max) NULL 
        ) 
      ON [PRIMARY] 
      textimage_on [PRIMARY] 

      INSERT INTO subnationalindicator 
      SELECT Row_number() OVER (ORDER BY [indicator name]) 
             + 5000           ID, 
             [indicator name] indicator 
      FROM   (SELECT [indicator name] 
              FROM   subnationaldata 
              GROUP  BY [indicator name])A 

      TRUNCATE TABLE wdi_country 

      BULK INSERT wdi_country 
        FROM 
  'C:\Users\shahnewaz\Documents\GapMinder\WDI Data\Data\WDI_Country.csv' 
        WITH 
          ( 
            fieldterminator = ',', 
            rowterminator = '\n' 
          ) 
      TRUNCATE TABLE dbo.wdi_data 

      BULK INSERT dbo.wdi_data 
        FROM 'C:\Users\shahnewaz\Documents\GapMinder\allWDIRawData.txt' 
        WITH 
          ( 
            fieldterminator = ',', 
            rowterminator = '\n' 
          ) 
      
      IF Object_id('dbo.WDI_Indicator', 'U') IS NOT NULL 
        DROP TABLE wdi_indicator 

      SELECT a.indicator 
      INTO   wdi_indicator 
      FROM   (SELECT [indicator name] indicator 
              FROM   wdi_data 
              GROUP  BY [indicator name])A 

      --left join dbo.Indicator id 
      --on a.indicator = id.indicator 
      --where id.indicator is null 
      --drop table #A 
      SELECT ( Row_number() 
                 OVER( 
                   ORDER BY [indicator]) ) + 1000 ID, 
             [indicator] 
      INTO   #a 
      FROM   wdi_indicator 

      IF Object_id('dbo.WDI_Indicator', 'U') IS NOT NULL 
        DROP TABLE wdi_indicator 

      SELECT a.* 
      INTO   wdi_indicator 
      FROM   #a a 

      --left join dbo.Indicator i 
      --on a.[indicator] = i.indicator 
      --where i.indicator is null 
      ALTER TABLE wdi_indicator 
        ALTER COLUMN id INT NOT NULL 

      ALTER TABLE wdi_indicator 
        ADD PRIMARY KEY (id) 

      

      DROP INDEX myindexwdi ON dbo.factwdidata 

      TRUNCATE TABLE dbo.factwdidata 

      INSERT INTO dbo.factwdidata 
      SELECT wi.id, 
             wd.[country name], 
             CASE 
               WHEN Isnumeric([period]) = 1 THEN [period] 
               ELSE NULL 
             END, 
             CASE 
               WHEN Isnumeric([value]) = 1 THEN Cast([value] AS FLOAT) 
               ELSE 0.00 
             END 
      FROM   dbo.wdi_data wd 
             LEFT JOIN wdi_indicator wi 
                    ON wd.[indicator name] = wi.[indicator] 

      CREATE CLUSTERED INDEX myindexwdi 
        ON dbo.factwdidata (pathid) 

      TRUNCATE TABLE IMFAllRawData

      BULK INSERT IMFAllRawData
        FROM 'C:\Users\shahnewaz\Documents\GapMinder_DEV\imf\allIMFData.txt' 
        WITH 
          ( 
            fieldterminator = ',', 
            rowterminator = '0x0a' 
          ) 
      INSERT INTO dimindicators 
                  (datasourceid, 
                   [indicator code], 
                   [indicator name], 
                   tempid) 
      SELECT 4, 
             indicator, 
             indicator, 
             NULL 
      FROM   imfrawfile 
      GROUP  BY indicator 

      INSERT INTO factfinal 
                  (datasourceid, 
                   [country code], 
                   period, 
                   [indicator code], 
                   value) 
      SELECT 4, 
             dc.id, 
             LEFT(r.[time], 4), 
             di.id, 
             CASE 
               WHEN r.indicator = 'pop' THEN r.[value] * 1000000 
               ELSE r.[value] 
             END 
      FROM   imfrawfile r 
             LEFT JOIN (SELECT * 
                        FROM   dimindicators 
                        WHERE  datasourceid = 4) di 
                    ON r.indicator = di.[indicator code] 
             LEFT JOIN dimcountry dc 
                    ON r.geo = dc.[country code] 

      TRUNCATE TABLE [dbo].[incomemountain] 

      BULK INSERT [dbo].[incomemountain] 
        FROM 'C:\Users\shahnewaz\Documents\GapMinder\mountain.txt' 
        WITH 
          ( 
            fieldterminator = ';', 
            rowterminator = '0x0a' 
          ) 
      UPDATE incomemountain 
      SET    mountainshape = Replace(mountainshape, Char(13), '') 
      WHERE  RIGHT(mountainshape, 1) = Char(13) 

	  --insert into DimGeo
--select 'geo',lower([Country Code]) id, [Short Name] [name]
--, lower(left([Country Code],3)) region, 'territory' cat, NULL, NULL
--from DimCountry
--where [Type] = 'region'

END

GO
