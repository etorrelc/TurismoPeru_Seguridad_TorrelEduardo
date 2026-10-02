/*
  Restauracion de backup completo y opcional diferencial.
  Revise las rutas logicas con RESTORE FILELISTONLY antes de ejecutar MOVE.
*/
USE [master];
GO
DECLARE @DatabaseName SYSNAME = N'$(DatabaseName)';
DECLARE @FullBackup NVARCHAR(260) = N'$(FullBackupPath)';
DECLARE @DataFile NVARCHAR(260) = N'$(DataFilePath)';
DECLARE @LogFile NVARCHAR(260) = N'$(LogFilePath)';

DECLARE @sql NVARCHAR(MAX) = N'
ALTER DATABASE ' + QUOTENAME(@DatabaseName) + N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
RESTORE DATABASE ' + QUOTENAME(@DatabaseName) + N'
FROM DISK = N''' + REPLACE(@FullBackup, N'''', N'''''') + N'''
WITH REPLACE,
     MOVE N''' + @DatabaseName + N''' TO N''' + REPLACE(@DataFile, N'''', N'''''') + N''',
     MOVE N''' + @DatabaseName + N'_log'' TO N''' + REPLACE(@LogFile, N'''', N'''''') + N''',
     RECOVERY, STATS = 10;
ALTER DATABASE ' + QUOTENAME(@DatabaseName) + N' SET MULTI_USER;';
EXEC sys.sp_executesql @sql;
GO

/* Para restaurar tambien un diferencial, cambie RECOVERY por NORECOVERY arriba y ejecute:
RESTORE DATABASE [$(DatabaseName)] FROM DISK = N'$(DifferentialBackupPath)' WITH RECOVERY, STATS = 10;
*/
