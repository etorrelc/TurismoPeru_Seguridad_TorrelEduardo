/*
  Ejecutar en SQL Server como un administrador de instancia.
  Ejemplo con sqlcmd:
  sqlcmd -S .\\SQLEXPRESS -E -i 01_logins.sql \
    -v AdminPassword="UnaClaveLargaYUnica#2026" \
       VendedorPassword="OtraClaveLargaYUnica#2026" \
       AnalistaPassword="TerceraClaveLargaYUnica#2026"
*/
USE [master];
GO

IF SUSER_ID(N'turismo_admin') IS NULL
    CREATE LOGIN [turismo_admin]
        WITH PASSWORD = '$(AdminPassword)', CHECK_POLICY = ON, CHECK_EXPIRATION = ON;
GO

IF SUSER_ID(N'turismo_vendedor') IS NULL
    CREATE LOGIN [turismo_vendedor]
        WITH PASSWORD = '$(VendedorPassword)', CHECK_POLICY = ON, CHECK_EXPIRATION = ON;
GO

IF SUSER_ID(N'turismo_analista') IS NULL
    CREATE LOGIN [turismo_analista]
        WITH PASSWORD = '$(AnalistaPassword)', CHECK_POLICY = ON, CHECK_EXPIRATION = ON;
GO

PRINT 'Logins verificados o creados. Las contrasenas no se almacenan en este repositorio.';
GO
