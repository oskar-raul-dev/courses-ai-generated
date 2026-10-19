-- postgres
-- pg_stat_statements, el Query Store de pobre. Se vacían sus contadores, se corre la pantalla de resultados de las
-- dos maneras (una consulta por protocolo con \gexec, y una sola consulta para los 60), y se lee lo que quedó: cada
-- consulta normalizada (las constantes pasan a $1), cuántas veces corrió y cuánto tardó en total. Se corre con psql.
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT pg_stat_statements_reset() IS NOT NULL AS reset;

-- uno por protocolo: \gexec ejecuta como sentencia cada fila que devuelve la consulta
SELECT format('SELECT * FROM alameda.result WHERE lab_order_id = %s', lab_order_id)
FROM (SELECT lab_order_id FROM alameda.lab_order ORDER BY lab_order_id DESC LIMIT 60) screen \gexec

-- una sola consulta para la pantalla
SELECT r.* FROM alameda.result r
WHERE r.lab_order_id IN (SELECT lab_order_id FROM alameda.lab_order ORDER BY lab_order_id DESC LIMIT 60) \g /dev/null

SELECT calls, rows, round(total_exec_time::numeric, 2) AS total_ms, round(mean_exec_time::numeric, 3) AS mean_ms,
       left(regexp_replace(query, '\s+', ' ', 'g'), 70) AS query
FROM pg_stat_statements
WHERE query ILIKE '%alameda.result%' AND query NOT ILIKE '%pg_stat_statements%' AND query NOT ILIKE '%format(%'
ORDER BY calls DESC;
