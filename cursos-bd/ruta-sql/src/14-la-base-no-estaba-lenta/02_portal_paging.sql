-- postgres
-- El portal pagina los protocolos de a 20, del más nuevo al más viejo. Con OFFSET, la página n lee y descarta las
-- 20 × (n − 1) filas anteriores; con keyset ("los 20 anteriores al último que mostré"), cada página lee 20. Se mide
-- cada página con EXPLAIN (ANALYZE, BUFFERS), y después la misma lista con el statement_timeout del portal.
-- Se corre con psql.
DROP TABLE IF EXISTS staging.portal_order;
CREATE TABLE staging.portal_order AS
SELECT o.lab_order_id, o.ordered_on, o.site_code, o.patient_id, p.full_name
FROM alameda.lab_order o JOIN alameda.patient p USING (patient_id);
ALTER TABLE staging.portal_order ADD PRIMARY KEY (lab_order_id);
CREATE INDEX portal_order_newest_idx ON staging.portal_order (ordered_on DESC, lab_order_id DESC);
ANALYZE staging.portal_order;

CREATE TEMP TABLE paging (page int, method text, buffers bigint, ms numeric);
DO $$
DECLARE
  n int;
  plan jsonb;
  last_on date;
  last_id int;
BEGIN
  FOREACH n IN ARRAY ARRAY[1, 100, 1000, 5000, 20000, 50000] LOOP
    EXECUTE format('SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET %s LIMIT 20',
                   20 * (n - 1));   -- para calentar
    EXECUTE format('EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) SELECT * FROM staging.portal_order '
                   'ORDER BY ordered_on DESC, lab_order_id DESC OFFSET %s LIMIT 20', 20 * (n - 1)) INTO plan;
    INSERT INTO paging VALUES (n, 'offset', (plan #>> '{0,Plan,Shared Hit Blocks}')::bigint
                                             + (plan #>> '{0,Plan,Shared Read Blocks}')::bigint,
                               round((plan #>> '{0,Execution Time}')::numeric, 2));
    -- el último protocolo de la página anterior, que el portal guarda en el enlace de "siguiente"
    SELECT ordered_on, lab_order_id INTO last_on, last_id FROM staging.portal_order
    ORDER BY ordered_on DESC, lab_order_id DESC OFFSET greatest(20 * (n - 1) - 1, 0) LIMIT 1;
    EXECUTE format('EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) SELECT * FROM staging.portal_order '
                   'WHERE (ordered_on, lab_order_id) < (%L, %s) ORDER BY ordered_on DESC, lab_order_id DESC LIMIT 20',
                   last_on, last_id) INTO plan;
    INSERT INTO paging VALUES (n, 'keyset', (plan #>> '{0,Plan,Shared Hit Blocks}')::bigint
                                             + (plan #>> '{0,Plan,Shared Read Blocks}')::bigint,
                               round((plan #>> '{0,Execution Time}')::numeric, 2));
  END LOOP;
END $$;
SELECT page, max(buffers) FILTER (WHERE method = 'offset') AS offset_bloques,
       max(ms) FILTER (WHERE method = 'offset') AS offset_ms,
       max(buffers) FILTER (WHERE method = 'keyset') AS keyset_bloques,
       max(ms) FILTER (WHERE method = 'keyset') AS keyset_ms
FROM paging GROUP BY page ORDER BY page;

\echo == "página 1 de …": el count(*) que acompaña a cada página
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) SELECT count(*) FROM staging.portal_order;

\echo == la rotura: el portal corre con statement_timeout = 100ms
SET statement_timeout = '100ms';
\timing on
SELECT count(*) FROM (SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 99980 LIMIT 20) page_5000;
SELECT count(*) FROM (SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 999980 LIMIT 20) page_50000;
\timing off
RESET statement_timeout;
