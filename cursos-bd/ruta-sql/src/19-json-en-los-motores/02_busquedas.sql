-- Fase 19 · buscar cultivos por un resultado: la forma larga contra el documento, con y sin GIN.
-- Dos antibióticos: CIPROFLOXACINA R (común, en uno de cada cinco cultivos) y MEROPENEM R (raro,
-- solo en el panel de Pseudomonas). Los bloques leídos son la medida; el tiempo es ruido de la máquina.

\timing off

-- 1. La forma larga, con su índice de clave primaria como única ayuda.
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(DISTINCT culture_id) FROM staging.antibiogram_long
WHERE antibiotic = 'MEROPENEM' AND sensitivity = 'R';

-- 2. El documento, sin índice: la búsqueda es un *seq scan* sobre el documento.
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.culture_doc WHERE antibiogram @> '{"MEROPENEM": "R"}';

-- 3. GIN con la clase por defecto, jsonb_ops (indexa claves y valores por separado).
CREATE INDEX IF NOT EXISTS culture_doc_gin_ops ON staging.culture_doc USING gin (antibiogram jsonb_ops);
VACUUM ANALYZE staging.culture_doc;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.culture_doc WHERE antibiogram @> '{"MEROPENEM": "R"}';

-- 4. GIN con jsonb_path_ops (indexa la ruta completa clave·valor, más pequeño y más selectivo).
DROP INDEX IF EXISTS staging.culture_doc_gin_ops;
CREATE INDEX culture_doc_gin_path ON staging.culture_doc USING gin (antibiogram jsonb_path_ops);
VACUUM ANALYZE staging.culture_doc;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.culture_doc WHERE antibiogram @> '{"MEROPENEM": "R"}';

-- 5. El mismo tamaño de índice con cada clase, y el caso común con jsonb_path_ops.
SELECT pg_size_pretty(pg_relation_size('staging.culture_doc_gin_path')) AS gin_path_size;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.culture_doc WHERE antibiogram @> '{"CIPROFLOXACINA": "R"}';
