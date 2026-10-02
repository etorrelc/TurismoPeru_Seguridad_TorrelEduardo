/* Ejecutar en SSMS. Requiere backup_full.sql; ajuste @BackupPath a su carpeta de respaldos. */
USE [master];
GO
DECLARE @DatabaseName SYSNAME = N'TURISMOPERU_EMTC_V4';
DECLARE @BackupPath NVARCHAR(260) = N'C:\Respaldos';
DECLARE @FileName NVARCHAR(400) = @BackupPath + N'\' + @DatabaseName + N'_Diferencial.bak';
DECLARE @sql NVARCHAR(MAX) = N'BACKUP DATABASE ' + QUOTENAME(@DatabaseName)
    + N' TO DISK = N''' + REPLACE(@FileName, N'''', N'''''') + N''''
    + N' WITH DIFFERENTIAL, INIT, COMPRESSION, CHECKSUM, STATS = 10, NAME = N''' + @DatabaseName + N' Differential Backup'';';
EXEC sys.sp_executesql @sql;
GO
