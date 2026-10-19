-- Fase 19 · soluciones ejecutables (ejercicios 1–11, 14–21). Corre después de 01_setup.sql y 02_busquedas.sql.
-- Las pruebas que escriben van sobre copias staging.ex_* y se borran al final. No modifica staging.culture_doc.

\set ON_ERROR_STOP 0

-- Limpieza de corridas anteriores: el script es reproducible desde cero.
DROP INDEX IF EXISTS staging.ex_gin_ops;
DROP INDEX IF EXISTS staging.ex_gin_path;
DROP TABLE IF EXISTS staging.ex_doc, staging.ex_ins, staging.ex_ins_src, staging.ex_w, staging.ex_w0, staging.ex_w1, staging.ex_upd, staging.ex_check;

-- 1. json no tiene el operador @>.
SELECT '{"a": 1}'::json @> '{"a": 1}'::json AS resultado;

-- 2. -> devuelve jsonb (con comillas); ->> devuelve texto.
SELECT culture_id, antibiogram ->> 'MEROPENEM' AS como_texto, antibiogram -> 'MEROPENEM' AS como_jsonb
FROM staging.culture_doc WHERE antibiogram ? 'MEROPENEM' ORDER BY culture_id LIMIT 3;

-- 3. Antibióticos que aparecen en *Enterococcus faecalis*.
SELECT count(DISTINCT k) AS antibioticos, string_agg(DISTINCT k, ', ' ORDER BY k) AS lista
FROM staging.culture_doc, jsonb_object_keys(antibiogram) AS k
WHERE germ = 'Enterococcus faecalis';

-- 4. Cultivos con algún antibiótico resistente, con jsonpath.
SELECT count(*) AS con_algun_r FROM staging.culture_doc WHERE antibiogram @@ '$.* == "R"';

-- 5. Índice de expresión: sirve para la expresión exacta, no para otra clave.
CREATE INDEX culture_doc_cipro_expr ON staging.culture_doc ((antibiogram ->> 'CIPROFLOXACINA'));
ANALYZE staging.culture_doc;
EXPLAIN (COSTS OFF) SELECT count(*) FROM staging.culture_doc WHERE antibiogram ->> 'CIPROFLOXACINA' = 'R';
EXPLAIN (COSTS OFF) SELECT count(*) FROM staging.culture_doc WHERE antibiogram ->> 'MEROPENEM' = 'R';
DROP INDEX staging.culture_doc_cipro_expr;

-- 6. El documento frente a sus filas largas, para un mismo cultivo.
SELECT pg_column_size(antibiogram) AS bytes_documento,
       (SELECT sum(pg_column_size(l.*)) FROM staging.antibiogram_long l WHERE l.culture_id = c.culture_id) AS bytes_filas
FROM staging.culture_doc c WHERE culture_id = (SELECT min(culture_id) FROM staging.culture_doc WHERE person_id = 4977);

-- 7. La igualdad de jsonb ignora el orden de las claves.
SELECT '{"a": "R", "b": "S"}'::jsonb = '{"b": "S", "a": "R"}'::jsonb AS iguales,
       '{"a": "R", "b": "S"}'::text  = '{"b": "S", "a": "R"}'::text  AS iguales_como_texto;

-- 8. Cultivos con cuatro o más resistencias.
SELECT count(*) AS cuatro_o_mas_r
FROM staging.culture_doc c
WHERE (SELECT count(*) FROM jsonb_each_text(c.antibiogram) e WHERE e.value = 'R') >= 4;

-- 9. Dos GIN, su tamaño y la búsqueda por meropenem: los números de §5.1, reproducidos.
CREATE INDEX ex_gin_ops  ON staging.culture_doc USING gin (antibiogram jsonb_ops);
CREATE INDEX ex_gin_path ON staging.culture_doc USING gin (antibiogram jsonb_path_ops);
SELECT pg_size_pretty(pg_relation_size('staging.ex_gin_ops'))  AS jsonb_ops,
       pg_size_pretty(pg_relation_size('staging.ex_gin_path')) AS jsonb_path_ops;
DROP INDEX staging.ex_gin_ops;
DROP INDEX staging.ex_gin_path;

-- 10. Lo común: CIPROFLOXACINA R devuelve más del 20 % de la tabla; el índice ya no compensa.
CREATE INDEX ex_gin_path ON staging.culture_doc USING gin (antibiogram jsonb_path_ops);
SELECT count(*) AS cultivos_cipro_r,
       round(100.0 * count(*) / (SELECT count(*) FROM staging.culture_doc), 1) AS porcentaje
FROM staging.culture_doc WHERE antibiogram @> '{"CIPROFLOXACINA": "R"}';
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.culture_doc WHERE antibiogram @> '{"CIPROFLOXACINA": "R"}';
DROP INDEX staging.ex_gin_path;

-- 11. Reordenar por meropenem: un índice btree de expresión, una búsqueda por ese índice, CLUSTER y vuelta a medir.
--     Un índice GIN no ordena el heap; un btree sí, y CLUSTER lo usa para reescribir la tabla en ese orden.
CREATE TABLE staging.ex_doc AS SELECT * FROM staging.culture_doc;
ALTER TABLE staging.ex_doc ADD PRIMARY KEY (culture_id);
CREATE INDEX ex11_mero_btree ON staging.ex_doc ((antibiogram ->> 'MEROPENEM'));
VACUUM ANALYZE staging.ex_doc;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.ex_doc WHERE antibiogram ->> 'MEROPENEM' = 'R';
CLUSTER staging.ex_doc USING ex11_mero_btree;
VACUUM ANALYZE staging.ex_doc;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.ex_doc WHERE antibiogram ->> 'MEROPENEM' = 'R';
DROP TABLE staging.ex_doc;

-- 14. El WAL de insertar 1.000 cultivos, sin GIN y con GIN jsonb_path_ops.
CREATE TABLE staging.ex_ins (LIKE staging.culture_doc INCLUDING DEFAULTS);
CREATE TABLE staging.ex_ins_src AS SELECT * FROM staging.culture_doc WHERE culture_id <= 1000;
DO $$
DECLARE b0 pg_lsn; b1 pg_lsn;
BEGIN
  SELECT pg_current_wal_insert_lsn() INTO b0;
  INSERT INTO staging.ex_ins SELECT * FROM staging.ex_ins_src;
  SELECT pg_current_wal_insert_lsn() INTO b1;
  RAISE NOTICE 'sin GIN: % bytes de WAL para 1.000 cultivos', pg_wal_lsn_diff(b1, b0);
  TRUNCATE staging.ex_ins;
  CREATE INDEX ex_ins_gin ON staging.ex_ins USING gin (antibiogram jsonb_path_ops);
  SELECT pg_current_wal_insert_lsn() INTO b0;
  INSERT INTO staging.ex_ins SELECT * FROM staging.ex_ins_src;
  SELECT pg_current_wal_insert_lsn() INTO b1;
  RAISE NOTICE 'con GIN jsonb_path_ops: % bytes de WAL para 1.000 cultivos', pg_wal_lsn_diff(b1, b0);
END $$;
DROP TABLE staging.ex_ins;
DROP TABLE staging.ex_ins_src;

-- 15. Cuántas claves distintas hay en todos los antibiogramas: el esquema que nadie escribió.
SELECT count(DISTINCT k) AS claves_distintas FROM staging.culture_doc, jsonb_object_keys(antibiogram) AS k;

-- 16. Corregir sin reescribir: jsonb_set contra reconstruir el documento entero, cinco cultivos.
--     Se calienta cada forma antes de medir: la primera escritura después de un CHECKPOINT lleva imágenes de página.
CREATE TABLE staging.ex_upd AS SELECT * FROM staging.culture_doc WHERE culture_id IN (
  SELECT culture_id FROM staging.culture_doc ORDER BY culture_id LIMIT 5);
ALTER TABLE staging.ex_upd ADD PRIMARY KEY (culture_id);
CHECKPOINT;
UPDATE staging.ex_upd SET antibiogram = jsonb_set(antibiogram, '{CIPROFLOXACINA}', '"R"');
UPDATE staging.ex_upd u SET antibiogram = (
  SELECT jsonb_object_agg(l.antibiotic, CASE WHEN l.antibiotic = 'CIPROFLOXACINA' THEN 'R' ELSE l.sensitivity END)
  FROM staging.antibiogram_long l WHERE l.culture_id = u.culture_id);
DO $$
DECLARE b0 pg_lsn; b1 pg_lsn; w_set bigint; w_full bigint;
BEGIN
  SELECT pg_current_wal_insert_lsn() INTO b0;
  UPDATE staging.ex_upd SET antibiogram = jsonb_set(antibiogram, '{CIPROFLOXACINA}', '"S"');
  SELECT pg_current_wal_insert_lsn() INTO b1;
  w_set := pg_wal_lsn_diff(b1, b0);
  SELECT pg_current_wal_insert_lsn() INTO b0;
  UPDATE staging.ex_upd u SET antibiogram = (
    SELECT jsonb_object_agg(l.antibiotic, CASE WHEN l.antibiotic = 'CIPROFLOXACINA' THEN 'S' ELSE l.sensitivity END)
    FROM staging.antibiogram_long l WHERE l.culture_id = u.culture_id);
  SELECT pg_current_wal_insert_lsn() INTO b1;
  w_full := pg_wal_lsn_diff(b1, b0);
  RAISE NOTICE 'jsonb_set en 5 cultivos: % bytes; documento entero: % bytes', w_set, w_full;
END $$;
DROP TABLE staging.ex_upd;

-- 17. Un CHECK que duele: exigir al menos tres antibióticos. Una subconsulta no sirve en un CHECK; una función
--     IMMUTABLE sí. Se agrega con NOT VALID (no revisa las filas existentes), se cuentan las que violarían, y se valida.
CREATE OR REPLACE FUNCTION staging.n_antibiotics(doc jsonb) RETURNS integer
  LANGUAGE sql IMMUTABLE AS $$ SELECT count(*)::integer FROM jsonb_object_keys(doc) $$;
CREATE TABLE staging.ex_check AS SELECT * FROM staging.culture_doc;
ALTER TABLE staging.ex_check ADD PRIMARY KEY (culture_id);
ALTER TABLE staging.ex_check ADD CONSTRAINT min_three CHECK (staging.n_antibiotics(antibiogram) >= 3) NOT VALID;
SELECT count(*) AS cultivos_que_violarian FROM staging.ex_check WHERE staging.n_antibiotics(antibiogram) < 3;
ALTER TABLE staging.ex_check VALIDATE CONSTRAINT min_three;
DROP TABLE staging.ex_check;
DROP FUNCTION staging.n_antibiotics(jsonb);

-- 18. Reconstruir la forma larga desde el documento: la diferencia debe ser cero en las dos direcciones.
SELECT count(*) AS en_documento_no_en_larga FROM (
  SELECT c.culture_id, e.key, e.value FROM staging.culture_doc c, jsonb_each_text(c.antibiogram) e
  EXCEPT SELECT culture_id, antibiotic, sensitivity FROM staging.antibiogram_long) x;
SELECT count(*) AS en_larga_no_en_documento FROM (
  SELECT culture_id, antibiotic, sensitivity FROM staging.antibiogram_long
  EXCEPT SELECT c.culture_id, e.key, e.value FROM staging.culture_doc c, jsonb_each_text(c.antibiogram) e) y;

-- 19. El reporte de resistencia a ciprofloxacina por germen, sobre el documento y sobre la larga.
SELECT germ, count(*) FILTER (WHERE antibiogram ->> 'CIPROFLOXACINA' = 'R') AS r_documento
FROM staging.culture_doc GROUP BY germ ORDER BY germ;
SELECT germ, count(DISTINCT culture_id) AS r_larga
FROM staging.antibiogram_long WHERE antibiotic = 'CIPROFLOXACINA' AND sensitivity = 'R' GROUP BY germ ORDER BY germ;

-- 20. Un documento inválido sin CHECK, y una vista que lo encuentra sin borrarlo.
INSERT INTO staging.culture_doc VALUES (-3, 1, '2020-01-01', 'Prueba', '{"AMPICILINA": "X", "CIPROFLOXACINA": "R"}');
CREATE OR REPLACE VIEW staging.culture_doc_invalid AS
SELECT c.culture_id, e.key, e.value FROM staging.culture_doc c, jsonb_each_text(c.antibiogram) e
WHERE e.value NOT IN ('S', 'I', 'R');
SELECT * FROM staging.culture_doc_invalid;
DELETE FROM staging.culture_doc WHERE culture_id = -3;
DROP VIEW staging.culture_doc_invalid;

-- 21. El costo de los índices en la escritura: 5.000 cultivos, sin índice, con GIN y con GIN más expresión.
CREATE TABLE staging.ex_w AS SELECT * FROM staging.culture_doc WHERE culture_id <= 5000;
CREATE TABLE staging.ex_w0 (LIKE staging.culture_doc INCLUDING DEFAULTS);
DO $$
DECLARE b0 pg_lsn; b1 pg_lsn; t0 timestamptz; t1 timestamptz;
BEGIN
  t0 := clock_timestamp(); SELECT pg_current_wal_insert_lsn() INTO b0;
  INSERT INTO staging.ex_w0 SELECT * FROM staging.ex_w;
  SELECT pg_current_wal_insert_lsn() INTO b1; t1 := clock_timestamp();
  RAISE NOTICE 'sin índice: % bytes, % ms', pg_wal_lsn_diff(b1, b0), round(extract(milliseconds from t1 - t0));
  DROP TABLE staging.ex_w0;
  CREATE TABLE staging.ex_w1 (LIKE staging.culture_doc INCLUDING DEFAULTS);
  CREATE INDEX ex_w1_gin ON staging.ex_w1 USING gin (antibiogram jsonb_path_ops);
  CREATE INDEX ex_w1_expr ON staging.ex_w1 ((antibiogram ->> 'MEROPENEM'));
  t0 := clock_timestamp(); SELECT pg_current_wal_insert_lsn() INTO b0;
  INSERT INTO staging.ex_w1 SELECT * FROM staging.ex_w;
  SELECT pg_current_wal_insert_lsn() INTO b1; t1 := clock_timestamp();
  RAISE NOTICE 'con GIN y expresión: % bytes, % ms', pg_wal_lsn_diff(b1, b0), round(extract(milliseconds from t1 - t0));
  DROP TABLE staging.ex_w1;
END $$;
DROP TABLE staging.ex_w;
