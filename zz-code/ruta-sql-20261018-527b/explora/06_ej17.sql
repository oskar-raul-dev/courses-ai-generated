USE ALAMEDA;
SET LANGUAGE Spanish;
SELECT COUNT(*) AS dadas_vuelta
FROM dbo.Pacientes AS p
CROSS APPLY (SELECT CONVERT(varchar(23), p.FechaNac, 121) AS texto) AS t
WHERE TRY_CAST(t.texto AS datetime) IS NOT NULL AND TRY_CAST(t.texto AS datetime) <> p.FechaNac;
SET LANGUAGE us_english;
SELECT dateformat FROM sys.syslanguages WHERE name = N'Español';
GO
