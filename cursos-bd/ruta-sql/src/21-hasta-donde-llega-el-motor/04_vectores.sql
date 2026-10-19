-- Fase 21 · pgvector como muestra breve: el vector NO es semántico. Es un vector de 64 cubetas de trigramas con hash
-- (pg_trgm), para mostrar la mecánica: distancia, orden y el costo de buscar sin índice. Con 75 prácticas, la búsqueda
-- exacta es la respuesta; un índice HNSW no compra nada aquí.

DROP TABLE IF EXISTS staging.practice_vec;
CREATE TABLE staging.practice_vec AS
WITH tri AS (
  SELECT p."IdPractica" AS id, p."Descripcion" AS descr, t AS trigram
  FROM legacy."Practicas" p, unnest(show_trgm(upper(p."Descripcion"))) AS t
),
cub AS (
  SELECT id, descr, abs(hashtext(trigram)) % 64 AS bucket, count(*) AS n
  FROM tri GROUP BY id, descr, bucket
),
tot AS (SELECT id, sum(n) AS total FROM cub GROUP BY id)
SELECT c.id, c.descr,
       ('[' || string_agg(
          coalesce((SELECT round((cc.n::numeric / t.total), 4)::text FROM cub cc WHERE cc.id = c.id AND cc.bucket = g.b), '0'),
          ',' ORDER BY g.b) || ']')::vector(64) AS emb
FROM (SELECT DISTINCT id, descr FROM cub) c
JOIN tot t ON t.id = c.id
CROSS JOIN generate_series(0, 63) AS g(b)
GROUP BY c.id, c.descr;

-- La búsqueda exacta: las cinco prácticas más cercanas a "HEMOGRAMA COMPLETO" por distancia coseno.
SELECT p.descr, round((p.emb <=> q.emb)::numeric, 3) AS distancia
FROM staging.practice_vec p, (SELECT emb FROM staging.practice_vec WHERE id = 1) q
WHERE p.id <> 1
ORDER BY p.emb <=> q.emb
LIMIT 5;

-- Lo que cuesta sin índice: un escaneo de las 75 filas, sin nada que ganar por el índice.
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF)
SELECT p.id FROM staging.practice_vec p ORDER BY p.emb <=> (SELECT emb FROM staging.practice_vec WHERE id = 1) LIMIT 5;
