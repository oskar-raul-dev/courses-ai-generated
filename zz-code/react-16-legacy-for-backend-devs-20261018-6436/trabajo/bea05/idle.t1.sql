BEGIN;
UPDATE demo_stock SET remaining = remaining WHERE segment_id = 'esclusa-de-oro';
SELECT pg_sleep(0.01);
\! sleep 2
COMMIT;
