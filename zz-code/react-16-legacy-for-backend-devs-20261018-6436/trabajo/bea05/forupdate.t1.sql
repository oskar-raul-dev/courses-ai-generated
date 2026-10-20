BEGIN;
SELECT remaining FROM demo_stock WHERE segment_id = 'esclusa-de-oro' FOR UPDATE;
SELECT pg_sleep(2);
UPDATE demo_stock SET remaining = remaining - 1 WHERE segment_id = 'esclusa-de-oro';
COMMIT;
