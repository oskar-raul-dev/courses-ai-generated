-- Fase 21 · soluciones ejecutables de los ejercicios 1–16. Corre después de 01_setup.sql, 02_nombres.sql,
-- 03_recursion.sql y 04_vectores.sql. Las pruebas que escriben van sobre copias staging.ex21_* y se borran al final.

-- 1. ¿Qué usa el índice GIN de texto completo para 'perez'?
EXPLAIN (COSTS OFF)
SELECT count(*) FROM staging.patient_name WHERE name_tsv @@ to_tsquery('spanish', 'perez');

-- 2. El prefijo: 'per:*' en texto completo contra LIKE 'PER%'.
SELECT count(*) AS tsv_prefijo_en_cualquier_palabra FROM staging.patient_name WHERE name_tsv @@ to_tsquery('spanish', 'per:*');
SELECT count(*) AS like_prefijo_del_nombre FROM staging.patient_name WHERE name_norm LIKE 'PER%';

-- 3. El error de tipeo, en texto completo: 'rodriges' no es 'rodriguez'.
SELECT count(*) AS tsv_rodriges FROM staging.patient_name WHERE name_tsv @@ to_tsquery('spanish', 'rodriges');
SELECT count(*) AS tsv_rodriguez FROM staging.patient_name WHERE name_tsv @@ to_tsquery('spanish', 'rodriguez');

-- 4. El umbral de similitud: cuántos candidatos deja cada uno para 'RODRIGES CAMILA'.
SELECT set_limit(0.2); SELECT count(*) AS umbral_020 FROM staging.patient_name WHERE name_norm % 'RODRIGES CAMILA';
SELECT set_limit(0.3); SELECT count(*) AS umbral_030 FROM staging.patient_name WHERE name_norm % 'RODRIGES CAMILA';
SELECT set_limit(0.5); SELECT count(*) AS umbral_050 FROM staging.patient_name WHERE name_norm % 'RODRIGES CAMILA';
SELECT set_limit(0.3);

-- 5. Los acentos: la búsqueda con y sin acento da el mismo resultado después de normalizar.
SELECT count(*) AS con_acento FROM staging.patient_name WHERE name_norm LIKE staging.f21_unaccent(upper('pérez')) || '%';
SELECT count(*) AS sin_acento FROM staging.patient_name WHERE name_norm LIKE 'PEREZ%';

-- 6. Las palabras vacías del español: 'DE' y 'LA' no entran al vector.
SELECT to_tsvector('spanish', 'DE LA CRUZ MARIA') AS vector, to_tsquery('spanish', 'de & cruz') AS consulta_con_de;

-- 7. El stemming: 'CAMILA' y 'CAMILO' comparten raíz o no.
SELECT to_tsvector('spanish', 'CAMILA') AS camila, to_tsvector('spanish', 'CAMILO') AS camilo;

-- 8. Los pacientes con 'GARCIA', con la búsqueda normalizada, contra la que no normaliza.
SELECT count(*) AS normalizada FROM staging.patient_name WHERE name_norm LIKE '%GARCIA%';
SELECT count(*) AS sin_normalizar_mismo_universo FROM alameda.patient WHERE upper(full_name) LIKE '%GARCIA%' AND merged_into_patient_id IS NULL;
SELECT count(*) AS sin_normalizar_incluye_fusionados FROM alameda.patient WHERE upper(full_name) LIKE '%GARCIA%';

-- 9. La jerarquía completa bajo SEROLOGIA con WITH RECURSIVE: cada nodo, con su nivel.
WITH RECURSIVE baja AS (
  SELECT panel_id, component_id, 1 AS nivel FROM staging.practice_composition WHERE panel_id = 21
  UNION ALL
  SELECT b.panel_id, c.component_id, b.nivel + 1 FROM baja b JOIN staging.practice_composition c ON c.panel_id = b.component_id
)
SELECT component_id, nivel FROM baja ORDER BY nivel, component_id;

-- 10. Un ciclo en la jerarquía. Con UNION (sin ALL) la recursión termina aunque haya un ciclo.
INSERT INTO staging.practice_composition VALUES (27, 21);   -- TOXOPLASMOSIS "incluye" SEROLOGIA: ciclo
WITH RECURSIVE baja AS (
  SELECT panel_id, component_id FROM staging.practice_composition WHERE panel_id = 21
  UNION
  SELECT b.panel_id, c.component_id FROM baja b JOIN staging.practice_composition c ON c.panel_id = b.component_id
)
SELECT count(*) AS nodos_con_ciclo_y_union FROM baja;
DELETE FROM staging.practice_composition WHERE panel_id = 27 AND component_id = 21;

-- 11. La cadena de derivaciones desde el antibiograma: de dónde sale, paso a paso.
WITH RECURSIVE sube AS (
  SELECT source_id, derived_id, 1 AS nivel FROM staging.practice_derivation WHERE derived_id = 71
  UNION ALL
  SELECT d.source_id, s.derived_id, s.nivel + 1 FROM sube s JOIN staging.practice_derivation d ON d.derived_id = s.source_id
)
SELECT source_id, derived_id, nivel FROM sube ORDER BY nivel;

-- 12. La distancia: coseno y euclídea entre HEMOGRAMA y el resto, para ver que el orden puede cambiar.
SELECT p.descr, round((p.emb <=> q.emb)::numeric, 3) AS coseno, round((p.emb <-> q.emb)::numeric, 3) AS euclidea
FROM staging.practice_vec p, (SELECT emb FROM staging.practice_vec WHERE id = 1) q
WHERE p.id <> 1 ORDER BY p.emb <=> q.emb LIMIT 3;

-- 13. Un índice HNSW sobre 75 vectores. Con el vector de referencia como subconsulta escalar, el planificador lo usa
--     (con enable_seqscan apagado, para forzarlo: el índice es para escalas que esta caja no tiene).
--     La forma con JOIN contra una subconsulta no lo usa; se mide en la salida.
CREATE INDEX IF NOT EXISTS practice_vec_hnsw ON staging.practice_vec USING hnsw (emb vector_cosine_ops);
SET enable_seqscan = off;
EXPLAIN (COSTS OFF) SELECT p.id FROM staging.practice_vec p ORDER BY p.emb <=> (SELECT emb FROM staging.practice_vec WHERE id = 1) LIMIT 5;
EXPLAIN (COSTS OFF) SELECT p.id FROM staging.practice_vec p, (SELECT emb FROM staging.practice_vec WHERE id = 1) q ORDER BY p.emb <=> q.emb LIMIT 5;
SET enable_seqscan = on;
DROP INDEX staging.practice_vec_hnsw;

-- 14. Apellido con inicial: 'PEREZ J' con texto completo, y con trigramas.
SELECT count(*) AS tsv_perez_j FROM staging.patient_name WHERE name_tsv @@ to_tsquery('spanish', 'perez & j:*');
SELECT count(*) AS trgm_perez_j FROM staging.patient_name WHERE name_norm % 'PEREZ J';

-- 15. Rendimiento de la búsqueda con prefijo sobre la copia: el índice GIN de tsv contra ninguno.
CREATE TABLE staging.ex21_names AS SELECT * FROM staging.patient_name;
ALTER TABLE staging.ex21_names ADD PRIMARY KEY (patient_id);
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.ex21_names WHERE name_tsv @@ to_tsquery('spanish', 'perez:*');
CREATE INDEX ex21_tsv ON staging.ex21_names USING gin (name_tsv);
VACUUM ANALYZE staging.ex21_names;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.ex21_names WHERE name_tsv @@ to_tsquery('spanish', 'perez:*');

-- 16. La recursión y el informe fijo: cuántos nodos ve el informe de cuatro niveles, después de agregar un nivel más.
INSERT INTO staging.practice_composition VALUES (22, 900), (900, 901), (901, 902), (902, 903);
SELECT count(DISTINCT n) AS nodos_distintos_del_informe_fijo FROM (
  SELECT c1.component_id AS n FROM staging.practice_composition c1 WHERE c1.panel_id = 21
  UNION ALL SELECT c2.component_id FROM staging.practice_composition c1
  LEFT JOIN staging.practice_composition c2 ON c2.panel_id = c1.component_id WHERE c1.panel_id = 21
  UNION ALL SELECT c3.component_id FROM staging.practice_composition c1
  LEFT JOIN staging.practice_composition c2 ON c2.panel_id = c1.component_id
  LEFT JOIN staging.practice_composition c3 ON c3.panel_id = c2.component_id WHERE c1.panel_id = 21
  UNION ALL SELECT c4.component_id FROM staging.practice_composition c1
  LEFT JOIN staging.practice_composition c2 ON c2.panel_id = c1.component_id
  LEFT JOIN staging.practice_composition c3 ON c3.panel_id = c2.component_id
  LEFT JOIN staging.practice_composition c4 ON c4.panel_id = c3.component_id WHERE c1.panel_id = 21
) x WHERE n IS NOT NULL;
WITH RECURSIVE baja AS (
  SELECT panel_id, component_id FROM staging.practice_composition WHERE panel_id = 21
  UNION
  SELECT b.panel_id, c.component_id FROM baja b JOIN staging.practice_composition c ON c.panel_id = b.component_id
)
SELECT count(*) AS nodos_recursivos FROM baja;
DELETE FROM staging.practice_composition WHERE component_id IN (900, 901, 902, 903) OR panel_id IN (900, 901, 902);

-- Limpieza de las copias de este ejercicio.
DROP TABLE IF EXISTS staging.ex21_names;
