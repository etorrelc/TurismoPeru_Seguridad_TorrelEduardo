/* Backup completo nativo. Ajuste BackupPath a una carpeta existente y con permisos para SQL Server. */
USE [master];
GO
DECLARE @DatabaseName SYSNAME = N'$(DatabaseName)';
DECLARE @BackupPath NVARCHAR(260) = N'$(BackupPath)';
DECLARE @FileName NVARCHAR(400) = @BackupPath + N'\\' + @DatabaseName + N'_Full.bak';
DECLARE @sql NVARCHAR(MAX) = N'BACKUP DATABASE ' + QUOTENAME(@DatabaseName)
    + N' TO DISK = N''' + REPLACE(@FileName, N'''', N'''''') + N''''
    + N' WITH INIT, COMPRESSION, CHECKSUM, STATS = 10, NAME = N''' + @DatabaseName + N' Full Backup'';';
EXEC sys.sp_executesql @sql;
GO

/*
  Exportacion BACPAC: SQLPackage se ejecuta desde consola, no mediante T-SQL.
  SqlPackage /Action:Export /SourceServerName:"localhost\\SQLEXPRESS" /SourceDatabaseName:"$(DatabaseName)"
             /TargetFile:"C:\\Respaldos\\$(DatabaseName)_Full.bacpac"
*/
