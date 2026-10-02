/* Ejecutar en SSMS. Ajuste @BackupPath a una carpeta existente con permisos para SQL Server. */
USE [master];
GO
DECLARE @DatabaseName SYSNAME = N'TURISMOPERU_EMTC_V4';
DECLARE @BackupPath NVARCHAR(260) = N'C:\Respaldos';
DECLARE @FileName NVARCHAR(400) = @BackupPath + N'\' + @DatabaseName + N'_Full.bak';
DECLARE @sql NVARCHAR(MAX) = N'BACKUP DATABASE ' + QUOTENAME(@DatabaseName)
    + N' TO DISK = N''' + REPLACE(@FileName, N'''', N'''''') + N''''
    + N' WITH INIT, COMPRESSION, CHECKSUM, STATS = 10, NAME = N''' + @DatabaseName + N' Full Backup'';';
EXEC sys.sp_executesql @sql;
GO

/*
  Exportacion BACPAC: SQLPackage se ejecuta desde consola, no mediante T-SQL.
  SqlPackage /Action:Export /SourceServerName:"localhost\SQLEXPRESS" /SourceDatabaseName:"TURISMOPERU_EMTC_V4" /TargetFile:"C:\Respaldos\TURISMOPERU_EMTC_V4_Full.bacpac"
*/
