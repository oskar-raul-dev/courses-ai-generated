-- sqlserver
-- ss01 · §7. La otra conexión: después de 06_ventana.sql, que dejó el corte en 2029.
--   ./sqlcmd.sh < 06b_conexion_nueva.sql
SELECT value_in_use AS corte_de_la_instancia FROM sys.configurations WHERE name = 'two digit year cutoff';
SELECT t.texto, TRY_CONVERT(date, t.texto, 3) AS con_corte_2029_en_otra_conexion
FROM (VALUES (N'12/03/46'), (N'19/04/36'), (N'15/03/25'), (N'01/01/49'), (N'01/01/50')) AS t (texto);
GO
-- Se deja todo como estaba: el corte en 2049 y las opciones avanzadas ocultas.
EXEC sp_configure 'two digit year cutoff', 2049; RECONFIGURE;
EXEC sp_configure 'show advanced options', 0; RECONFIGURE;
GO
