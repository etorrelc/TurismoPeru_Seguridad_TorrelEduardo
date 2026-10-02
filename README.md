# TurismoPeru Seguridad TorrelEduardo

Proyecto de administracion y seguridad para la base de datos **TURISMOPERU_EMTC_V4**. Implementa usuarios, roles con minimo privilegio, importacion de clientes mediante BCP, scripts de respaldo y restauracion, pruebas de seguridad y un modulo Python para el analisis de clientes, reservas y pagos.

## Tecnologias

- SQL Server y SQL Server Management Studio (SSMS)
- BCP y SQLPackage (para exportar BACPAC)
- Git y GitHub
- Python 3.10+, pandas, matplotlib, pyodbc y python-dotenv

## Requisitos

- Una instancia de SQL Server con la base `TURISMOPERU_EMTC_V4` y las tablas del modelo turistico.
- SQL Server Management Studio para ejecutar los scripts SQL sin activar el modo SQLCMD.
- Herramientas `bcp` y SQLPackage instaladas y disponibles en PATH para importacion y exportacion.
- Python 3.10 o posterior si se utilizara el reporte Python.

Los scripts usan `dbo` y los nombres de tablas solicitados en la evaluacion. Confirme las columnas de su modelo antes de ejecutarlos, especialmente en `02_importacion_exportacion/importacion.sql` y `05_reportes/consultas_reportes.sql`.

## Estructura

```text
01_usuarios_roles/              Logins, usuarios, roles y permisos
02_importacion_exportacion/     Staging e importacion BCP de clientes
03_backups/                     Backup completo, diferencial y restauracion
04_seguridad/                   Pruebas de minimo privilegio
05_reportes/                    Vista SQL para el reporte
06_python/                      Reporte HTML seguro con Python
evidencias/                     Capturas de la ejecucion real
```

## Instalacion y ejecucion

Abra los archivos SQL en SSMS y ejecutelos con F5, sin activar el modo SQLCMD. Todos utilizan la base `TURISMOPERU_EMTC_V4`; las tablas del negocio estan en el esquema `EMTC_V4` y las opciones configurables son variables T-SQL normales declaradas dentro de cada script.

1. En `01_usuarios_roles/01_logins.sql`, complete las variables de contrasena para los logins nuevos en la ventana de consulta de SSMS y ejecute como administrador de instancia. Use contrasenas unicas y no guarde la copia con secretos en Git.
2. Ejecute `01_usuarios_roles/02_users.sql`.
3. Ejecute `01_usuarios_roles/03_roles.sql`.
4. Ejecute `01_usuarios_roles/04_permisos.sql`.
5. Ejecute `04_seguridad/pruebas_permisos.sql`.

Ejecute `02_importacion_exportacion/importacion.sql` para crear el staging. Luego importe un CSV de cuatro columnas (`Documento`, `Nombres`, `ApellidoPaterno`, `ApellidoMaterno`) con el comando BCP documentado dentro de ese script y ejecute el bloque de validacion e insercion.

## Principio de minimo privilegio

Asignar `db_owner` al vendedor o al analista seria inadecuado porque ese rol permite modificar o eliminar objetos y datos, administrar permisos y, potencialmente, elevar privilegios. El vendedor solo recibe los permisos necesarios para registrar y consultar clientes y reservas. El analista recibe lectura exclusivamente. `04_seguridad/pruebas_permisos.sql` usa `EXECUTE AS USER` para demostrar que el analista puede consultar, pero SQL Server rechaza su intento de insertar un pago con el error de permiso 229.

## Backups y restauracion

En SSMS, ajuste `@BackupPath` dentro de `03_backups/backup_full.sql` y `backup_diferencial.sql` (valor de ejemplo: `C:\Respaldos`). La carpeta debe existir en el servidor y permitir la escritura por el servicio SQL Server. El backup completo nativo genera `.bak`; para el BACPAC solicitado use el comando SQLPackage documentado en `backup_full.sql` desde CMD o PowerShell. Guarde el BACPAC fuera de Git si contiene datos reales. Para recuperar, revise primero los nombres logicos con `RESTORE FILELISTONLY`, ajuste las rutas de `@FullBackup`, `@DataFile` y `@LogFile` en `03_backups/restauracion.sql` y luego ejecutelo en SSMS.

## Reporte Python

1. Ejecute `05_reportes/consultas_reportes.sql` para crear `EMTC_V4.vw_reporte_clientes_reservas_pagos`.
2. Siga los pasos de [06_python/README.md](06_python/README.md).
3. Abra `06_python/output/reporte.html` y registre la captura con datos reales en `evidencias/reporte.png`.

El reporte contiene total de clientes, total de reservas, total de ingresos, ticket promedio, reservas por estado y periodo, ingresos por medio de pago y cliente, y top 10 de clientes por reservas.

## GitHub

El repositorio debe publicarse con el nombre `TurismoPeru_Seguridad_TorrelEduardo`. Antes de publicar, verifique que `.env`, directorios virtuales, datos de importacion y backups no se incluyan. Cree al menos cinco commits que agrupen cambios reales: estructura inicial, usuarios y roles, permisos y pruebas, backups/importacion y reporte.

## Autor

Torrel Eduardo
