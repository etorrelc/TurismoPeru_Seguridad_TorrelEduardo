/*
  Importacion con BCP hacia una tabla de staging.
  Ejecute primero el bloque de preparacion y despues el comando BCP indicado.
  Este script asume que dbo.cliente tiene Documento, Nombres, ApellidoPaterno y ApellidoMaterno.
  Si su modelo separa Persona y Cliente, adapte solo el bloque final de insercion.
*/
USE [TURISMOPERU_EMTC_V4];
GO

IF OBJECT_ID(N'dbo.cliente_importacion', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.cliente_importacion (
        Documento        NVARCHAR(20)  NOT NULL,
        Nombres          NVARCHAR(100) NOT NULL,
        ApellidoPaterno  NVARCHAR(100) NOT NULL,
        ApellidoMaterno  NVARCHAR(100) NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.cliente_importacion_errores', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.cliente_importacion_errores (
        ErrorId       INT IDENTITY(1,1) PRIMARY KEY,
        Documento     NVARCHAR(20) NULL,
        Motivo        NVARCHAR(300) NOT NULL,
        FechaRegistro DATETIME2(0) NOT NULL CONSTRAINT DF_cliente_importacion_errores_fecha DEFAULT SYSDATETIME()
    );
END;
GO

/*
  Ejemplo BCP (CSV con encabezado y cuatro columnas, separado por coma):
  bcp "TURISMOPERU_EMTC_V4.dbo.cliente_importacion" in ".\\datos\\clientes.csv" -S "$(ServerName)" -T -c -t "," -r "\\n" -F 2
  Para autenticacion SQL, reemplace -T por -U usuario -P contrasena. No escriba secretos en este archivo.
*/

DELETE FROM dbo.cliente_importacion_errores;
GO

;WITH registros AS (
    SELECT
        Documento = NULLIF(LTRIM(RTRIM(Documento)), N''),
        Nombres = NULLIF(LTRIM(RTRIM(Nombres)), N''),
        ApellidoPaterno = NULLIF(LTRIM(RTRIM(ApellidoPaterno)), N''),
        ApellidoMaterno = NULLIF(LTRIM(RTRIM(ApellidoMaterno)), N''),
        RepetidosEnArchivo = COUNT(*) OVER (PARTITION BY NULLIF(LTRIM(RTRIM(Documento)), N''))
    FROM dbo.cliente_importacion
)
INSERT INTO dbo.cliente_importacion_errores (Documento, Motivo)
SELECT Documento,
       CASE
           WHEN Documento IS NULL THEN N'Documento vacio.'
           WHEN Nombres IS NULL OR ApellidoPaterno IS NULL THEN N'Nombres y apellido paterno son obligatorios.'
           WHEN RepetidosEnArchivo > 1 THEN N'Documento duplicado dentro del archivo.'
           WHEN EXISTS (SELECT 1 FROM dbo.cliente AS c WHERE c.Documento = registros.Documento) THEN N'Documento ya registrado en cliente.'
       END
FROM registros
WHERE Documento IS NULL
   OR Nombres IS NULL
   OR ApellidoPaterno IS NULL
   OR RepetidosEnArchivo > 1
   OR EXISTS (SELECT 1 FROM dbo.cliente AS c WHERE c.Documento = registros.Documento);
GO

INSERT INTO dbo.cliente (Documento, Nombres, ApellidoPaterno, ApellidoMaterno)
SELECT DISTINCT
    LTRIM(RTRIM(i.Documento)),
    LTRIM(RTRIM(i.Nombres)),
    LTRIM(RTRIM(i.ApellidoPaterno)),
    NULLIF(LTRIM(RTRIM(i.ApellidoMaterno)), N'')
FROM dbo.cliente_importacion AS i
WHERE NULLIF(LTRIM(RTRIM(i.Documento)), N'') IS NOT NULL
  AND NULLIF(LTRIM(RTRIM(i.Nombres)), N'') IS NOT NULL
  AND NULLIF(LTRIM(RTRIM(i.ApellidoPaterno)), N'') IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM dbo.cliente_importacion_errores AS e
      WHERE e.Documento = LTRIM(RTRIM(i.Documento))
  )
  AND NOT EXISTS (
      SELECT 1 FROM dbo.cliente AS c
      WHERE c.Documento = LTRIM(RTRIM(i.Documento))
  );
GO

SELECT Documento, Motivo, FechaRegistro
FROM dbo.cliente_importacion_errores
ORDER BY ErrorId;
GO
