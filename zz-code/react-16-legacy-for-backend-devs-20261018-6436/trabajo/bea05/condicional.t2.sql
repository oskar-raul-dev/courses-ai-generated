SELECT pg_sleep(0.5);
SELECT clock_timestamp() AS empieza \gset
UPDATE demo_stock SET remaining = remaining - 1 WHERE segment_id = 'esclusa-de-oro' AND remaining > 0;
SELECT round(extract(epoch FROM clock_timestamp() - :'empieza')::numeric, 2) AS segundos;
