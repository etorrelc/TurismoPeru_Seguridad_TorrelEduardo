/* Ejecutar despues de crear usuarios, roles y permisos. */
USE [$(DatabaseName)];
GO

/* El analista puede consultar. */
EXECUTE AS USER = N'turismo_analista';
SELECT TOP (10) * FROM dbo.cliente;
REVERT;
GO

/* El analista no puede modificar. El error 229 confirma que SQL Server rechazo la operacion. */
BEGIN TRY
    EXECUTE AS USER = N'turismo_analista';
    INSERT INTO dbo.pago (Monto) VALUES (0);
    REVERT;
    THROW 51000, 'Fallo de seguridad: el analista pudo insertar en pago.', 1;
END TRY
BEGIN CATCH
    IF USER_NAME() = N'turismo_analista' REVERT;
    SELECT ERROR_NUMBER() AS NumeroError, ERROR_MESSAGE() AS Mensaje;
    IF ERROR_NUMBER() = 229
        PRINT 'PRUEBA EXITOSA: el analista no puede insertar pagos.';
    ELSE IF ERROR_NUMBER() = 51000
        THROW;
    ELSE
        PRINT 'Revise las columnas obligatorias de dbo.pago; el permiso debe rechazarse con error 229.';
END CATCH;
GO

/* El vendedor tampoco puede eliminar clientes. */
BEGIN TRY
    EXECUTE AS USER = N'turismo_vendedor';
    DELETE FROM dbo.cliente WHERE 1 = 0;
    REVERT;
    THROW 51001, 'Fallo de seguridad: el vendedor pudo eliminar clientes.', 1;
END TRY
BEGIN CATCH
    IF USER_NAME() = N'turismo_vendedor' REVERT;
    SELECT ERROR_NUMBER() AS NumeroError, ERROR_MESSAGE() AS Mensaje;
    IF ERROR_NUMBER() = 229
        PRINT 'PRUEBA EXITOSA: el vendedor no puede eliminar clientes.';
    ELSE IF ERROR_NUMBER() = 51001
        THROW;
END CATCH;
GO
