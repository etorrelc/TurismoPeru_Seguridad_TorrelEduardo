/*
  Importacion con BCP hacia una tabla de staging.
  Ejecute primero el bloque de preparacion y despues el comando BCP indicado.
  El modelo usa EMTC_V4.persona y EMTC_V4.cliente.
  Persona: id_persona, tipo_persona, nombre, apaterno, amaterno, id_tipo_documento,
  numero_documento, estado y fecha_registro.
  Cliente: id_persona y fecha_nacimiento.
  El archivo de carga es datos/clientes.csv y contiene Documento, Nombres,
  ApellidoPaterno y ApellidoMaterno.
*/
USE [TURISMOPERU_EMTC_V4];
GO

IF OBJECT_ID(N'EMTC_V4.cliente_importacion', N'U') IS NULL
BEGIN
    CREATE TABLE EMTC_V4.cliente_importacion (
        Documento        NVARCHAR(20)  NOT NULL,
        Nombres          NVARCHAR(100) NOT NULL,
        ApellidoPaterno  NVARCHAR(100) NOT NULL,
        ApellidoMaterno  NVARCHAR(100) NULL
    );
END;
GO

IF OBJECT_ID(N'EMTC_V4.cliente_importacion_errores', N'U') IS NULL
BEGIN
    CREATE TABLE EMTC_V4.cliente_importacion_errores (
        ErrorId       INT IDENTITY(1,1) PRIMARY KEY,
        Documento     NVARCHAR(20) NULL,
        Motivo        NVARCHAR(300) NOT NULL,
        FechaRegistro DATETIME2(0) NOT NULL CONSTRAINT DF_cliente_importacion_errores_fecha DEFAULT SYSDATETIME()
    );
END;
GO

/*
  Ejemplo BCP (CSV con encabezado y cuatro columnas, separado por coma):
  Ejecutar BCP en CMD o PowerShell, ajustando la instancia y la ruta del CSV:
  bcp "TURISMOPERU_EMTC_V4.EMTC_V4.cliente_importacion" in ".\datos\clientes.csv" -S "." -T -c -t "," -r "\n" -F 2 -u
  Para autenticacion SQL, reemplace -T por -U usuario -P contrasena. No escriba secretos en este archivo.
*/

DELETE FROM EMTC_V4.cliente_importacion_errores;
GO

/*
  Configure estos valores segun los codigos existentes en su base de datos.
  id_tipo_documento se deja NULL para no inventar una clave foranea. Si esa
  columna no admite NULL, asigne aqui el id del tipo de documento correcto.
*/
DECLARE @TipoPersona NCHAR(1) = N'N';
DECLARE @IdTipoDocumento INT = NULL;
DECLARE @Estado BIT = 1;
DECLARE @FechaNacimiento DATE = NULL;

BEGIN TRY
    BEGIN TRANSACTION;

    ;WITH registros AS (
        SELECT
            Documento = NULLIF(LTRIM(RTRIM(Documento)), N''),
            Nombres = NULLIF(LTRIM(RTRIM(Nombres)), N''),
            ApellidoPaterno = NULLIF(LTRIM(RTRIM(ApellidoPaterno)), N''),
            ApellidoMaterno = NULLIF(LTRIM(RTRIM(ApellidoMaterno)), N''),
            RepetidosEnArchivo = COUNT(*) OVER (PARTITION BY NULLIF(LTRIM(RTRIM(Documento)), N''))
        FROM EMTC_V4.cliente_importacion
    )
    INSERT INTO EMTC_V4.cliente_importacion_errores (Documento, Motivo)
    SELECT Documento,
           CASE
               WHEN Documento IS NULL THEN N'Documento vacio.'
               WHEN Nombres IS NULL OR ApellidoPaterno IS NULL THEN N'Nombres y apellido paterno son obligatorios.'
               WHEN RepetidosEnArchivo > 1 THEN N'Documento duplicado dentro del archivo.'
               WHEN EXISTS (
                   SELECT 1
                   FROM EMTC_V4.cliente AS c
                   INNER JOIN EMTC_V4.persona AS p ON p.id_persona = c.id_persona
                   WHERE p.numero_documento = registros.Documento
               ) THEN N'Documento ya registrado como cliente.'
           END
    FROM registros
    WHERE Documento IS NULL
       OR Nombres IS NULL
       OR ApellidoPaterno IS NULL
       OR RepetidosEnArchivo > 1
       OR EXISTS (
           SELECT 1
           FROM EMTC_V4.cliente AS c
           INNER JOIN EMTC_V4.persona AS p ON p.id_persona = c.id_persona
           WHERE p.numero_documento = registros.Documento
       );

    DECLARE @ClientesValidos TABLE (
        Documento       NVARCHAR(20)  NOT NULL PRIMARY KEY,
        Nombres         NVARCHAR(100) NOT NULL,
        ApellidoPaterno NVARCHAR(100) NOT NULL,
        ApellidoMaterno NVARCHAR(100) NULL
    );

    INSERT INTO @ClientesValidos (Documento, Nombres, ApellidoPaterno, ApellidoMaterno)
    SELECT DISTINCT
        LTRIM(RTRIM(i.Documento)),
        LTRIM(RTRIM(i.Nombres)),
        LTRIM(RTRIM(i.ApellidoPaterno)),
        NULLIF(LTRIM(RTRIM(i.ApellidoMaterno)), N'')
    FROM EMTC_V4.cliente_importacion AS i
    WHERE NULLIF(LTRIM(RTRIM(i.Documento)), N'') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(i.Nombres)), N'') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(i.ApellidoPaterno)), N'') IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM EMTC_V4.cliente_importacion_errores AS e
          WHERE e.Documento = LTRIM(RTRIM(i.Documento))
      );

    /* Primero se crean las personas que aun no existen. */
    INSERT INTO EMTC_V4.persona (
        tipo_persona,
        nombre,
        apaterno,
        amaterno,
        id_tipo_documento,
        numero_documento,
        estado,
        fecha_registro
    )
    SELECT
        @TipoPersona,
        v.Nombres,
        v.ApellidoPaterno,
        v.ApellidoMaterno,
        @IdTipoDocumento,
        v.Documento,
        @Estado,
        SYSDATETIME()
    FROM @ClientesValidos AS v
    WHERE NOT EXISTS (
        SELECT 1
        FROM EMTC_V4.persona AS p
        WHERE p.numero_documento = v.Documento
    );

    /* Despues cada persona valida queda asociada como cliente. */
    INSERT INTO EMTC_V4.cliente (id_persona, fecha_nacimiento)
    SELECT p.id_persona, @FechaNacimiento
    FROM @ClientesValidos AS v
    INNER JOIN EMTC_V4.persona AS p ON p.numero_documento = v.Documento
    WHERE NOT EXISTS (
        SELECT 1
        FROM EMTC_V4.cliente AS c
        WHERE c.id_persona = p.id_persona
    );

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

SELECT Documento, Motivo, FechaRegistro
FROM EMTC_V4.cliente_importacion_errores
ORDER BY ErrorId;
GO
