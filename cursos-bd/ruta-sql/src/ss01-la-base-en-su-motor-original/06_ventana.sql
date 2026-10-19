-- sqlserver
-- ss01 · §5.3 y §8. La ventana del año de dos dígitos, en vivo, y el idioma de la sesión.
--   ./sqlcmd.sh < 06_ventana.sql
USE ALAMEDA;
GO
-- 1. El corte de la instancia. Es una opción avanzada: hay que mostrarlas para verla.
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'two digit year cutoff';
GO
-- 2. Las tres fechas de la Fase 04, con el estilo 3 (dd/mm/aa) que usa fn_ExtraerFecha.
SELECT t.texto, TRY_CONVERT(date, t.texto, 3) AS con_el_corte_de_la_instancia
FROM (VALUES (N'12/03/46'), (N'19/04/36'), (N'15/03/25'), (N'01/01/49'), (N'01/01/50')) AS t (texto);
GO
-- 3. El corte que usa Windows (y por eso VBA): 2029. Es de la instancia, no de una sesión, y la documentación
--    dice que vale "immediately". Se cambia y se consulta en esta misma conexión; 06b_conexion_nueva.sql
--    consulta desde otra y lo deja como estaba. Antes de correrlo, apuesta qué da cada una.
EXEC sp_configure 'two digit year cutoff', 2029; RECONFIGURE;
SELECT t.texto, TRY_CONVERT(date, t.texto, 3) AS con_corte_2029_en_la_misma_conexion
FROM (VALUES (N'12/03/46'), (N'19/04/36'), (N'15/03/25'), (N'01/01/49'), (N'01/01/50')) AS t (texto);
GO
-- 4. El idioma de la sesión decide cómo se lee una fecha sin estilo. El contenedor viene en us_english.
SELECT @@LANGUAGE AS idioma, (SELECT dateformat FROM sys.syslanguages WHERE name = @@LANGUAGE) AS orden;
SELECT CAST('15/03/2026' AS datetime) AS quince_de_marzo;
GO
SET LANGUAGE Spanish;
SELECT @@LANGUAGE AS idioma, CAST('15/03/2026' AS datetime) AS quince_de_marzo, CAST('03/04/2026' AS datetime) AS tres_de_abril;
GO
-- 5. El formato que no depende del idioma: AAAAMMDD, o ISO 8601 con la T.
SET LANGUAGE us_english;
SELECT CAST('20260315' AS datetime) AS sin_ambiguedad, CAST('2026-03-15T00:00:00' AS datetime) AS iso_8601;
GO
-- 6. Las fechas como las escribió bcp en la caja ('aaaa-mm-dd hh:mi:ss.mmm'), con la sesión en español.
--    datetime las lee según el idioma; datetime2 y date, no.
SET LANGUAGE Spanish;
SELECT CAST('2026-03-04 00:00:00.000' AS datetime) AS como_datetime, CAST('2026-03-04 00:00:00.000' AS datetime2(3)) AS como_datetime2;
GO
SET LANGUAGE Spanish;
SELECT CAST('1968-06-17 00:00:00.000' AS datetime) AS nacimiento_de_la_primera_paciente;
GO
SET LANGUAGE us_english;
GO
