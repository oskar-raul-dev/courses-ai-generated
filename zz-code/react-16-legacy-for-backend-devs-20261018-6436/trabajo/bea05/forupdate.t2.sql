SELECT pg_sleep(0.5);
BEGIN;
SELECT clock_timestamp() AS pide_el_bloqueo \gset
SELECT remaining FROM demo_stock WHERE segment_id = 'esclusa-de-oro' FOR UPDATE;
SELECT round(extract(epoch FROM clock_timestamp() - :'pide_el_bloqueo')::numeric, 2) AS segundos_esperando;
COMMIT;
