-- Fase 19 · MySQL: la búsqueda por un resultado en el JSON, con y sin columna generada indexada,
-- y el redo que escribe corregir un antibiótico en cada forma. Corre en la base staging, con EXPLAIN ANALYZE (8.0.18+).

-- 1. El documento sin índice: MySQL lee todas las filas del JSON.
EXPLAIN ANALYZE
SELECT COUNT(*) FROM staging.culture_doc IGNORE INDEX (culture_doc_meropenem)
WHERE JSON_UNQUOTE(JSON_EXTRACT(antibiogram, '$.MEROPENEM')) = 'R';

-- 2. La columna generada indexada (ALTER en 04_mysql_setup.sql, ya aplicado): la vía de acceso, el JSON la fuente.

EXPLAIN ANALYZE
SELECT COUNT(*) FROM staging.culture_doc WHERE meropenem = 'R';

-- 3. Redo por corrección. InnoDB escribe el redo del cambio; el contador global mide cuántos bytes entraron.
--    Cada forma se corre cuatro veces, alternando S y R para que siempre cambie algo; se reporta la última.
SELECT MIN(culture_id) INTO @cid FROM staging.culture_doc WHERE person_id = 4977;
SELECT VARIABLE_VALUE INTO @a FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
UPDATE staging.antibiogram_long SET sensitivity = 'R' WHERE culture_id = @cid AND antibiotic = 'CIPROFLOXACINA';
SELECT VARIABLE_VALUE INTO @b FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
SELECT 'fila larga, corrida 1' AS forma, @b - @a AS redo_bytes;

SELECT VARIABLE_VALUE INTO @a FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
UPDATE staging.antibiogram_long SET sensitivity = 'S' WHERE culture_id = @cid AND antibiotic = 'CIPROFLOXACINA';
SELECT VARIABLE_VALUE INTO @b FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
SELECT 'fila larga, corrida 2' AS forma, @b - @a AS redo_bytes;

SELECT VARIABLE_VALUE INTO @a FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
UPDATE staging.antibiogram_long SET sensitivity = 'R' WHERE culture_id = @cid AND antibiotic = 'CIPROFLOXACINA';
SELECT VARIABLE_VALUE INTO @b FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
SELECT 'fila larga, corrida 3' AS forma, @b - @a AS redo_bytes;

SELECT VARIABLE_VALUE INTO @a FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
UPDATE staging.antibiogram_long SET sensitivity = 'S' WHERE culture_id = @cid AND antibiotic = 'CIPROFLOXACINA';
SELECT VARIABLE_VALUE INTO @b FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
SELECT 'fila larga, corrida 4' AS forma, @b - @a AS redo_bytes;

SELECT VARIABLE_VALUE INTO @a FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
UPDATE staging.culture_doc SET antibiogram = JSON_SET(antibiogram, '$.CIPROFLOXACINA', 'R') WHERE culture_id = @cid;
SELECT VARIABLE_VALUE INTO @b FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
SELECT 'documento JSON_SET, corrida 1' AS forma, @b - @a AS redo_bytes;

SELECT VARIABLE_VALUE INTO @a FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
UPDATE staging.culture_doc SET antibiogram = JSON_SET(antibiogram, '$.CIPROFLOXACINA', 'S') WHERE culture_id = @cid;
SELECT VARIABLE_VALUE INTO @b FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
SELECT 'documento JSON_SET, corrida 2' AS forma, @b - @a AS redo_bytes;

SELECT VARIABLE_VALUE INTO @a FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
UPDATE staging.culture_doc SET antibiogram = JSON_SET(antibiogram, '$.CIPROFLOXACINA', 'R') WHERE culture_id = @cid;
SELECT VARIABLE_VALUE INTO @b FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
SELECT 'documento JSON_SET, corrida 3' AS forma, @b - @a AS redo_bytes;

SELECT VARIABLE_VALUE INTO @a FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
UPDATE staging.culture_doc SET antibiogram = JSON_SET(antibiogram, '$.CIPROFLOXACINA', 'S') WHERE culture_id = @cid;
SELECT VARIABLE_VALUE INTO @b FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_os_log_written';
SELECT 'documento JSON_SET, corrida 4' AS forma, @b - @a AS redo_bytes;

