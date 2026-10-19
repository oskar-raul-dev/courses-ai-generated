SELECT host_platform, host_distribution, host_release FROM sys.dm_os_host_info;
SELECT CURRENT_TIMEZONE() AS zona, CURRENT_TIMEZONE_ID() AS zona_id, SERVERPROPERTY('IsIntegratedSecurityOnly') AS solo_windows,
       SERVERPROPERTY('Collation') AS intercalacion, @@LANGUAGE AS idioma;
SELECT servicename, status_desc FROM sys.dm_server_services;
GO
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
GO
EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;
GO
EXEC sp_configure 'filestream access level', 2; RECONFIGURE;
GO
EXEC sp_configure 'show advanced options', 0; RECONFIGURE;
GO
SELECT name, value_in_use FROM sys.configurations WHERE name IN ('xp_cmdshell', 'filestream access level', 'show advanced options');
GO
