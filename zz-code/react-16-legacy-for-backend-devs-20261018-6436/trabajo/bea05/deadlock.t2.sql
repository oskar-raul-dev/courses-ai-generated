SELECT pg_sleep(0.3);
BEGIN;
SELECT remaining FROM demo_stock WHERE segment_id = 'avatar-raro' FOR UPDATE;
SELECT pg_sleep(1);
SELECT remaining FROM demo_stock WHERE segment_id = 'esclusa-de-oro' FOR UPDATE;
COMMIT;
