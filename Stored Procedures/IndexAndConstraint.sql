IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[IndexAndConstraint]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[IndexAndConstraint]
GO

/****** Object:  StoredProcedure [dbo].[IndexAndConstraint]    Script Date: 8/17/2015 10:37:57 AM ******/
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

				CREATE NONCLUSTERED INDEX NON_FactFinal_Period
				ON dbo.FactFinal ([Period])

				CREATE NONCLUSTERED INDEX ix_fact 
				ON factfinal ([datasourceid], [country code], [period], [indicator code],[SubGroup] ) 
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
			END

		ELSE
			BEGIN
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

			END

END

GO


