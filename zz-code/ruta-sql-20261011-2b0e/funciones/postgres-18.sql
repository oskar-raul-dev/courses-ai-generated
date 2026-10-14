-- Checks the Postgres features the phases take for granted (P8). psql -f funciones/postgres-18.sql
\pset pager off
SELECT version();
SELECT uuidv7() AS uuidv7, uuid_extract_timestamp(uuidv7()) AS ts;
CREATE EXTENSION IF NOT EXISTS btree_gist;
DROP TABLE IF EXISTS p8_price, p8_practice;
CREATE TABLE p8_practice (code text, valid daterange, PRIMARY KEY (code, valid WITHOUT OVERLAPS));
INSERT INTO p8_practice VALUES ('660475', '[2002-09-01,2025-01-01)'), ('660475', '[2025-01-01,)');
INSERT INTO p8_practice VALUES ('660475', '[2024-06-01,2024-07-01)');   -- must fail: overlaps
CREATE TABLE p8_price (code text, valid daterange, amount numeric,
  FOREIGN KEY (code, PERIOD valid) REFERENCES p8_practice (code, PERIOD valid));
INSERT INTO p8_price VALUES ('660475', '[2003-01-01,2004-01-01)', 10);
INSERT INTO p8_price VALUES ('999999', '[2003-01-01,2004-01-01)', 10);   -- must fail: no parent
-- skip scan: index on (sede, fecha), query only on fecha
CREATE INDEX IF NOT EXISTS p8_protocol_site_date_idx ON legacy."Protocolos" ("Sede", "Fecha");
ANALYZE legacy."Protocolos";
EXPLAIN (COSTS OFF) SELECT count(*) FROM legacy."Protocolos" WHERE "Fecha" = DATE '2015-03-02';
DROP INDEX legacy.p8_protocol_site_date_idx;
SELECT name, default_version FROM pg_available_extensions
 WHERE name IN ('pgstattuple','pg_trgm','vector','pg_hint_plan','pg_stat_statements','btree_gist','pg_walinspect','amcheck')
 ORDER BY name;
CREATE EXTENSION IF NOT EXISTS pgstattuple; CREATE EXTENSION IF NOT EXISTS pg_trgm; CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT tuple_percent, dead_tuple_percent FROM pgstattuple('legacy."Pacientes"');
SELECT similarity('PEREZ PEDRO DNI 23456789', 'PEREZ PEDRO');
SELECT '[1,2,3]'::vector <-> '[1,2,4]'::vector AS l2;
SHOW wal_level;
DROP TABLE p8_price, p8_practice;
