/* Ejecutar sobre la base de datos TURISMOPERU_EMTC_V4. */
USE [TURISMOPERU_EMTC_V4];
GO

IF DATABASE_PRINCIPAL_ID(N'turismo_admin') IS NULL
    CREATE USER [turismo_admin] FOR LOGIN [turismo_admin] WITH DEFAULT_SCHEMA = [dbo];
GO

IF DATABASE_PRINCIPAL_ID(N'turismo_vendedor') IS NULL
    CREATE USER [turismo_vendedor] FOR LOGIN [turismo_vendedor] WITH DEFAULT_SCHEMA = [dbo];
GO

IF DATABASE_PRINCIPAL_ID(N'turismo_analista') IS NULL
    CREATE USER [turismo_analista] FOR LOGIN [turismo_analista] WITH DEFAULT_SCHEMA = [dbo];
GO

/* El administrador es el unico usuario del proyecto que recibe administracion completa. */
IF IS_ROLEMEMBER(N'db_owner', N'turismo_admin') = 0
    ALTER ROLE [db_owner] ADD MEMBER [turismo_admin];
GO
