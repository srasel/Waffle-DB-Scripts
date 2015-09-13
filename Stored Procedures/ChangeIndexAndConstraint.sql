IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChangeIndexAndConstraint]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ChangeIndexAndConstraint]
GO

/****** Object:  StoredProcedure [dbo].[ChangeIndexAndConstraint]    Script Date: 8/17/2015 10:37:57 AM ******/
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


