# TurismoPeru Seguridad TorrelEduardo

Proyecto de administracion y seguridad para la base de datos **TurismoPeru_TorrelEduardo**. Implementa usuarios, roles con minimo privilegio, importacion de clientes mediante BCP, scripts de respaldo y restauracion, pruebas de seguridad y un modulo Python para el analisis de clientes, reservas y pagos.

## Tecnologias

- SQL Server y `sqlcmd`
- BCP y SQLPackage (para exportar BACPAC)
- Git y GitHub
- Python 3.10+, pandas, matplotlib, pyodbc y python-dotenv

## Requisitos

- Una instancia de SQL Server con la base `TurismoPeru_TorrelEduardo` y las tablas del modelo turistico.
- Herramientas `sqlcmd`, `bcp` y SQLPackage instaladas y disponibles en PATH.
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

Desde la raiz, reemplace las variables entre comillas por valores de su equipo. Use contrasenas unicas; no las guarde en archivos SQL ni en Git.

```powershell
sqlcmd -S ".\SQLEXPRESS" -E -i .\01_usuarios_roles\01_logins.sql -v AdminPassword="CAMBIAR" VendedorPassword="CAMBIAR" AnalistaPassword="CAMBIAR"
sqlcmd -S ".\SQLEXPRESS" -E -i .\01_usuarios_roles\02_users.sql -v DatabaseName="TurismoPeru_TorrelEduardo"
sqlcmd -S ".\SQLEXPRESS" -E -i .\01_usuarios_roles\03_roles.sql -v DatabaseName="TurismoPeru_TorrelEduardo"
sqlcmd -S ".\SQLEXPRESS" -E -i .\01_usuarios_roles\04_permisos.sql -v DatabaseName="TurismoPeru_TorrelEduardo" TableSchema="dbo"
sqlcmd -S ".\SQLEXPRESS" -E -i .\04_seguridad\pruebas_permisos.sql -v DatabaseName="TurismoPeru_TorrelEduardo"
```

Ejecute `02_importacion_exportacion/importacion.sql` para crear el staging. Luego importe un CSV de cuatro columnas (`Documento`, `Nombres`, `ApellidoPaterno`, `ApellidoMaterno`) con el comando BCP documentado dentro de ese script y ejecute el bloque de validacion e insercion.

## Principio de minimo privilegio

Asignar `db_owner` al vendedor o al analista seria inadecuado porque ese rol permite modificar o eliminar objetos y datos, administrar permisos y, potencialmente, elevar privilegios. El vendedor solo recibe los permisos necesarios para registrar y consultar clientes y reservas. El analista recibe lectura exclusivamente. `04_seguridad/pruebas_permisos.sql` usa `EXECUTE AS USER` para demostrar que el analista puede consultar, pero SQL Server rechaza su intento de insertar un pago con el error de permiso 229.

## Backups y restauracion

Ejecute `03_backups/backup_full.sql` y `backup_diferencial.sql` con `DatabaseName` y `BackupPath`. El backup completo nativo genera `.bak`; para el BACPAC solicitado use el comando SQLPackage documentado en `backup_full.sql`. Guarde el BACPAC fuera de Git si contiene datos reales. Para recuperar, revise primero los nombres logicos con `RESTORE FILELISTONLY` y luego adapte y ejecute `03_backups/restauracion.sql`.

## Reporte Python

1. Ejecute `05_reportes/consultas_reportes.sql` para crear `dbo.vw_reporte_clientes_reservas_pagos`.
2. Siga los pasos de [06_python/README.md](06_python/README.md).
3. Abra `06_python/output/reporte.html` y registre la captura con datos reales en `evidencias/reporte.png`.

El reporte contiene total de clientes, total de reservas, total de ingresos, ticket promedio, reservas por estado y periodo, ingresos por medio de pago y cliente, y top 10 de clientes por reservas.

## GitHub

El repositorio debe publicarse con el nombre `TurismoPeru_Seguridad_TorrelEduardo`. Antes de publicar, verifique que `.env`, directorios virtuales, datos de importacion y backups no se incluyan. Cree al menos cinco commits que agrupen cambios reales: estructura inicial, usuarios y roles, permisos y pruebas, backups/importacion y reporte.

## Autor

Torrel Eduardo
