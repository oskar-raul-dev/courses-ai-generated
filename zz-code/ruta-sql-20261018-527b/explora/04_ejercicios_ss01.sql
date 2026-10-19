USE ALAMEDA;
SELECT @@VERSION AS version;
SELECT profile, seed, sha256, tables FROM lab.loaded;
SELECT COUNT(*) AS con_pena_minuscula FROM dbo.Pacientes WHERE Nombre LIKE N'peña %';
SELECT COUNT(*) AS con_pena_sin_enie FROM dbo.Pacientes WHERE Nombre LIKE N'pena %';
SELECT TOP 3 IdPaciente, LEN(Nombre) AS len, DATALENGTH(Nombre)/2 AS caracteres FROM dbo.Pacientes WHERE Nombre LIKE N'% ';
SELECT TRY_CONVERT(date, N'31/02/46', 3) AS con_try;
GO
USE ALAMEDA;
SELECT CONVERT(date, N'31/02/46', 3) AS sin_try;
GO
USE ALAMEDA;
BEGIN TRAN;
ALTER TABLE dbo.ResultadoItem WITH CHECK CHECK CONSTRAINT FK_ResultadoItem_Protocolos;
ROLLBACK;
GO
USE ALAMEDA;
SELECT is_disabled, is_not_trusted FROM sys.foreign_keys WHERE name = 'FK_ResultadoItem_Protocolos';
GO
USE ALAMEDA;
