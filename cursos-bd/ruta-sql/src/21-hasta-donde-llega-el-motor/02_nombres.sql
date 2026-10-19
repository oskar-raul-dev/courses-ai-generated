-- Fase 21 · la búsqueda de pacientes por nombre: LIKE, texto completo, prefijo y trigramas.
-- Cada consulta se mide con EXPLAIN (ANALYZE, BUFFERS) y sin índice primero, para que el índice tenga algo que ganar.
-- Los nombres de la caja están en mayúsculas y sin acentos después de normalizar (ver 01_setup.sql).

-- 1. La pantalla de hoy: LIKE con comodines en ambos lados, sin índice que sirva.
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.patient_name WHERE name_norm LIKE '%PEREZ%';

-- 2. Texto completo en español, sin índice: un palabra exacta, stemmeada.
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.patient_name WHERE name_tsv @@ to_tsquery('spanish', 'perez');

-- Índices: GIN sobre el vector de texto completo; GIN de trigramas sobre el nombre normalizado.
CREATE INDEX patient_name_tsv ON staging.patient_name USING gin (name_tsv);
CREATE INDEX patient_name_trgm ON staging.patient_name USING gin (name_norm gin_trgm_ops);
VACUUM ANALYZE staging.patient_name;

-- 3. Texto completo con índice: la palabra exacta.
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.patient_name WHERE name_tsv @@ to_tsquery('spanish', 'perez');

-- 4. Prefijo: lo que la recepción escribe mientras tipea, "PER".
SELECT count(*) AS con_prefijo_por_tsv FROM staging.patient_name WHERE name_tsv @@ to_tsquery('spanish', 'per:*');
SELECT count(*) AS con_prefijo_por_like FROM staging.patient_name WHERE name_norm LIKE 'PER%';

-- 5. Error de tipeo: "RODRIGES" en lugar de "RODRIGUEZ". El texto completo no lo ve; los trigramas, sí.
SELECT count(*) AS encontrados_por_tsv FROM staging.patient_name
WHERE name_tsv @@ to_tsquery('spanish', 'rodriges');
SELECT count(*) AS encontrados_por_similitud FROM staging.patient_name
WHERE name_norm % 'RODRIGES CAMILA';
SELECT patient_id, full_name, round(similarity(name_norm, 'RODRIGES CAMILA')::numeric, 2) AS similitud
FROM staging.patient_name WHERE name_norm % 'RODRIGES CAMILA'
ORDER BY similitud DESC, patient_id LIMIT 5;

-- 6. LIKE con comodines en ambos lados, con el índice de trigramas: el mismo patrón, ahora con índice.
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.patient_name WHERE name_norm LIKE '%PEREZ%';
