-- La línea base bien jugada de la Fase 12: el full-text de Postgres sobre el catálogo de la Fase 11
-- (perfil base, base busqueda_base).
--   docker compose -f lab/compose.yaml exec -T base psql -U postgres -d busqueda_base < 12-busqueda-romper-y-medir/fts.sql
\timing on
CREATE EXTENSION IF NOT EXISTS unaccent;
-- la configuración spanish, con unaccent antes del stemmer: "tórica" y "torica" son el mismo lexema
DROP TEXT SEARCH CONFIGURATION IF EXISTS es_unaccent;
CREATE TEXT SEARCH CONFIGURATION es_unaccent (COPY = spanish);
ALTER TEXT SEARCH CONFIGURATION es_unaccent
    ALTER MAPPING FOR hword, hword_part, word WITH unaccent, spanish_stem;

-- la descripción, ya analizada, en una columna generada con su índice GIN
ALTER TABLE part_catalog DROP COLUMN IF EXISTS description_tsv;
ALTER TABLE part_catalog ADD COLUMN description_tsv tsvector
    GENERATED ALWAYS AS (to_tsvector('es_unaccent', description)) STORED;
CREATE INDEX part_catalog_description_tsv ON part_catalog USING gin (description_tsv);

-- los sinónimos del almacén, como reglas de reescritura de la consulta (los mismos de catalog-index.json)
DROP TABLE IF EXISTS warehouse_synonym;
CREATE TABLE warehouse_synonym (target tsquery, substitute tsquery);
INSERT INTO warehouse_synonym VALUES
    (to_tsquery('es_unaccent', 'oring'), to_tsquery('es_unaccent', 'junta & torica')),
    (to_tsquery('es_unaccent', 'llanta'), to_tsquery('es_unaccent', 'llanta | neumatico')),
    (to_tsquery('es_unaccent', 'neumatico'), to_tsquery('es_unaccent', 'llanta | neumatico')),
    (to_tsquery('es_unaccent', 'empaque'), to_tsquery('es_unaccent', 'empaque | sello')),
    (to_tsquery('es_unaccent', 'sello'), to_tsquery('es_unaccent', 'empaque | sello'));

-- los números de parte sin separadores, en el número propio y en las grafías de los proveedores
CREATE OR REPLACE FUNCTION pn_normalize(text) RETURNS text IMMUTABLE PARALLEL SAFE
    LANGUAGE sql RETURN lower(regexp_replace($1, '[^A-Za-z0-9]', '', 'g'));
CREATE OR REPLACE FUNCTION pn_normalize_all(text[]) RETURNS text[] IMMUTABLE PARALLEL SAFE
    LANGUAGE sql RETURN ARRAY(SELECT pn_normalize(x) FROM unnest($1) x);
CREATE INDEX part_catalog_pn_norm ON part_catalog (pn_normalize(part_number));
CREATE INDEX part_catalog_spn_norm ON part_catalog USING gin (pn_normalize_all(supplier_part_numbers));
CREATE INDEX part_catalog_alternates ON part_catalog USING gin (alternates);
VACUUM ANALYZE part_catalog;

SELECT pg_size_pretty(pg_relation_size('part_catalog')) AS tabla,
       pg_size_pretty(pg_relation_size('part_catalog_description_tsv')) AS gin_descripcion,
       pg_size_pretty(pg_relation_size('part_catalog_pn_norm') + pg_relation_size('part_catalog_spn_norm')
                      + pg_relation_size('part_catalog_alternates')) AS indices_numeros,
       pg_size_pretty(pg_total_relation_size('part_catalog')) AS total;
