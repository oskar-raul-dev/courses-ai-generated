\pset pager off
\set q 'SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id) WHERE o.site_code = ''C'' AND o.ordered_on >= ''2026-09-01'' GROUP BY r.analyte_code'
\timing on
\echo == elegido x5
:q \g /dev/null
:q \g /dev/null
:q \g /dev/null
:q \g /dev/null
:q \g /dev/null
\echo == nested x5
SET enable_hashjoin = off; SET enable_mergejoin = off;
:q \g /dev/null
:q \g /dev/null
:q \g /dev/null
:q \g /dev/null
:q \g /dev/null
RESET enable_hashjoin; RESET enable_mergejoin;
\timing off
\echo == random_page_cost 1.1
SET random_page_cost = 1.1;
EXPLAIN :q;
