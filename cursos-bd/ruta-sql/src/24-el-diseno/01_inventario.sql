-- postgres
-- Fase 24 · el inventario del modelo: lo que existe en `alameda`, tabla por tabla, con lo que la protege.
-- Es el anexo del documento de diseño: el diseño se defiende con lo que está construido y medido, no con
-- lo que se dibujó. Solo lee el catálogo; no cambia nada.
SELECT c.relname AS "Tabla",
       c.reltuples::bigint AS "Filas (estimadas)",
       pg_size_pretty(pg_total_relation_size(c.oid)) AS "Tamaño con índices",
       count(*) FILTER (WHERE k.contype = 'p') AS "PK",
       count(*) FILTER (WHERE k.contype = 'f') AS "FK",
       count(*) FILTER (WHERE k.contype = 'c') AS "CHECK",
       count(*) FILTER (WHERE k.contype = 'x') AS "Exclusión",
       count(*) FILTER (WHERE k.contype = 'u') AS "UNIQUE",
       (SELECT count(*) FROM pg_index AS i WHERE i.indrelid = c.oid) AS "Índices",
       CASE WHEN c.relrowsecurity THEN 'sí' ELSE '' END AS "RLS",
       (SELECT count(*) FROM pg_trigger AS t WHERE t.tgrelid = c.oid AND NOT t.tgisinternal) AS "Triggers"
FROM pg_class AS c
LEFT JOIN pg_constraint AS k ON k.conrelid = c.oid
WHERE c.relnamespace = 'alameda'::regnamespace AND c.relkind IN ('r', 'p')
GROUP BY c.oid, c.relname, c.reltuples, c.relrowsecurity
ORDER BY pg_total_relation_size(c.oid) DESC;

-- Las restricciones que no son PK ni FK: son las reglas del negocio que la base hace cumplir sola.
SELECT k.conrelid::regclass AS "Tabla", k.conname AS "Restricción", pg_get_constraintdef(k.oid) AS "Definición"
FROM pg_constraint AS k
WHERE k.connamespace = 'alameda'::regnamespace AND k.contype IN ('c', 'x', 'u')
  AND k.conname NOT LIKE '%_not_null'
ORDER BY 1, 2;

-- Lo que el modelo deja de lado, en la tabla de rechazos: cada regla con su fase y su volumen.
SELECT phase AS "Fase", rule AS "Regla", count(*) AS "Filas rechazadas"
FROM staging.rejection GROUP BY 1, 2 ORDER BY 1, 3 DESC;
