-- La línea base bien jugada para las consultas de measure.ts: un índice por consulta conocida.
--   docker compose -f lab/compose.yaml exec -T base psql -U postgres -d analitico < 07-analitico-levantar-y-modelar/indexes.sql
\timing on
-- tres columnas por aeronave: el índice cubriente permite contestar sin tocar la tabla
CREATE INDEX reading_x10_cover ON reading_x10 (aircraft) INCLUDE (egt_c, fuel_flow_pph);
-- mínimo y máximo por cada 128 páginas: lo más parecido a los grupos de filas de DuckDB
CREATE INDEX reading_x10_aircraft_brin ON reading_x10 USING brin (aircraft);
CREATE INDEX reading_x10_egt_brin ON reading_x10 USING brin (egt_c);
-- el mapa de visibilidad al día, o el index-only scan vuelve a la tabla
VACUUM ANALYZE reading_x10;
SELECT indexrelname, pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes WHERE relname = 'reading_x10' ORDER BY 1;
