/*
  Ejecutar en SSMS como un administrador de instancia.
  En la ventana de consulta, sustituya NULL por N'su contrasena segura'
  para cada login que deba crearse. No guarde esas contrasenas en Git.
*/
USE [master];
GO

DECLARE @AdminPassword NVARCHAR(128) = NULL;
DECLARE @VendedorPassword NVARCHAR(128) = NULL;
DECLARE @AnalistaPassword NVARCHAR(128) = NULL;
DECLARE @sql NVARCHAR(MAX);

/* Validar la configuracion antes de crear cualquiera de los logins. */
IF (SUSER_ID(N'turismo_admin') IS NULL AND NULLIF(@AdminPassword, N'') IS NULL)
   OR (SUSER_ID(N'turismo_vendedor') IS NULL AND NULLIF(@VendedorPassword, N'') IS NULL)
   OR (SUSER_ID(N'turismo_analista') IS NULL AND NULLIF(@AnalistaPassword, N'') IS NULL)
    THROW 51002, 'Complete las contrasenas de los logins nuevos en las variables T-SQL al inicio del script.', 1;

IF SUSER_ID(N'turismo_admin') IS NULL
BEGIN
    SET @sql = N'CREATE LOGIN [turismo_admin] WITH PASSWORD = N'''
        + REPLACE(@AdminPassword, N'''', N'''''')
        + N''', CHECK_POLICY = ON, CHECK_EXPIRATION = ON;';
    EXEC sys.sp_executesql @sql;
END;

IF SUSER_ID(N'turismo_vendedor') IS NULL
BEGIN
    SET @sql = N'CREATE LOGIN [turismo_vendedor] WITH PASSWORD = N'''
        + REPLACE(@VendedorPassword, N'''', N'''''')
        + N''', CHECK_POLICY = ON, CHECK_EXPIRATION = ON;';
    EXEC sys.sp_executesql @sql;
END;

IF SUSER_ID(N'turismo_analista') IS NULL
BEGIN
    SET @sql = N'CREATE LOGIN [turismo_analista] WITH PASSWORD = N'''
        + REPLACE(@AnalistaPassword, N'''', N'''''')
        + N''', CHECK_POLICY = ON, CHECK_EXPIRATION = ON;';
    EXEC sys.sp_executesql @sql;
END;

PRINT 'Logins verificados o creados. Las contrasenas no se almacenan en este repositorio.';
GO
