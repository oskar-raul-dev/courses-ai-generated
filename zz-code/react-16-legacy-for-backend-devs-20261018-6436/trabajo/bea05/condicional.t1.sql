BEGIN;
UPDATE demo_stock SET remaining = remaining - 1 WHERE segment_id = 'esclusa-de-oro' AND remaining > 0;
SELECT pg_sleep(2);
COMMIT;
