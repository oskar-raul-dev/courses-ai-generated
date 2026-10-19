-- postgres
-- El costo de escritura de cada índice, en bytes de WAL por fila. Se cargan los 200.000 primeros resultados
-- de 2025 en una tabla con cero, uno, … ocho índices, y se mide el WAL de cada carga después de un
-- CHECKPOINT. Se corre con psql (usa \gset): psql -f 11-indices-y-lo-que-cuestan/01_write_cost.sql
DROP TABLE IF EXISTS staging.write_cost, staging.write_source;
CREATE TABLE staging.write_source AS
SELECT * FROM alameda.result WHERE recorded_at >= '2025-01-01' ORDER BY recorded_at, result_id LIMIT 200000;
CREATE TABLE staging.write_cost (indexes integer PRIMARY KEY, index_added text, wal_bytes bigint, bytes_per_row numeric);
CREATE TABLE IF NOT EXISTS staging.result_write (LIKE alameda.result);

\set n 0
\set idx '(ninguno)'
\ir write_cost_round.sql
\set n 1
\set idx 'PRIMARY KEY (result_id)'
ALTER TABLE staging.result_write ADD PRIMARY KEY (result_id);
\ir write_cost_round.sql
\set n 2
\set idx '(lab_order_id)'
CREATE INDEX result_write_lab_order_id_idx ON staging.result_write (lab_order_id);
\ir write_cost_round.sql
\set n 3
\set idx '(analyte_code)'
CREATE INDEX result_write_analyte_code_idx ON staging.result_write (analyte_code);
\ir write_cost_round.sql
\set n 4
\set idx '(recorded_at)'
CREATE INDEX result_write_recorded_at_idx ON staging.result_write (recorded_at);
\ir write_cost_round.sql
\set n 5
\set idx '(analyte_code, value_numeric)'
CREATE INDEX result_write_analyte_code_value_numeric_idx ON staging.result_write (analyte_code, value_numeric);
\ir write_cost_round.sql
\set n 6
\set idx '(value_numeric)'
CREATE INDEX result_write_value_numeric_idx ON staging.result_write (value_numeric);
\ir write_cost_round.sql
\set n 7
\set idx '(lab_order_id, analyte_code)'
CREATE INDEX result_write_lab_order_id_analyte_code_idx ON staging.result_write (lab_order_id, analyte_code);
\ir write_cost_round.sql
\set n 8
\set idx '(value_text)'
CREATE INDEX result_write_value_text_idx ON staging.result_write (value_text);
\ir write_cost_round.sql

SELECT indexes, index_added, pg_size_pretty(wal_bytes) AS wal, bytes_per_row,
       bytes_per_row - lag(bytes_per_row) OVER (ORDER BY indexes) AS added_per_row
FROM staging.write_cost ORDER BY indexes;
