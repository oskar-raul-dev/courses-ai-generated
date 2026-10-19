-- postgres
-- Los tres métodos de join sobre la misma consulta: los resultados de septiembre de 2026 del laboratorio central
-- (10.255 protocolos) y de un centro chico (2.626). Cada método se fuerza apagando los otros dos, en la sesión.
-- Una ejecución para calentar, y el plan con EXPLAIN (ANALYZE, BUFFERS). Se corre con psql después de
-- 01_generic_plans.sql, que crea staging.order_site.
\set q 'SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id) WHERE o.site_code = :''site'' AND o.ordered_on >= ''2026-09-01'' GROUP BY r.analyte_code'

\set site C
\echo == central, elegido
:q \g /dev/null
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) :q;
\echo == central, nested loop
SET enable_hashjoin = off; SET enable_mergejoin = off;
:q \g /dev/null
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) :q;
\echo == central, merge join
SET enable_nestloop = off; SET enable_mergejoin = on;
:q \g /dev/null
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) :q;
RESET enable_hashjoin; RESET enable_mergejoin; RESET enable_nestloop;

\set site V
\echo == centro V, elegido
:q \g /dev/null
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) :q;
\echo == centro V, hash join
SET enable_nestloop = off; SET enable_mergejoin = off;
:q \g /dev/null
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) :q;
\echo == centro V, merge join
SET enable_hashjoin = off; SET enable_mergejoin = on;
:q \g /dev/null
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) :q;
RESET enable_hashjoin; RESET enable_mergejoin; RESET enable_nestloop;
