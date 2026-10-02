/* Ejecutar sobre la base de datos TURISMOPERU_EMTC_V4. */
USE [TURISMOPERU_EMTC_V4];
GO

IF DATABASE_PRINCIPAL_ID(N'rol_vendedor') IS NULL
    CREATE ROLE [rol_vendedor] AUTHORIZATION [dbo];
GO

IF DATABASE_PRINCIPAL_ID(N'rol_analista') IS NULL
    CREATE ROLE [rol_analista] AUTHORIZATION [dbo];
GO

IF IS_ROLEMEMBER(N'rol_vendedor', N'turismo_vendedor') = 0
    ALTER ROLE [rol_vendedor] ADD MEMBER [turismo_vendedor];
GO

IF IS_ROLEMEMBER(N'rol_analista', N'turismo_analista') = 0
    ALTER ROLE [rol_analista] ADD MEMBER [turismo_analista];
GO
