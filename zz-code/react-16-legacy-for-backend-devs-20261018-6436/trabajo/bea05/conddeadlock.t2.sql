SELECT pg_sleep(0.3);
BEGIN;
UPDATE demo_stock SET remaining = remaining - 1 WHERE segment_id = 'avatar-raro' AND remaining > 0;
SELECT pg_sleep(1);
UPDATE demo_stock SET remaining = remaining - 1 WHERE segment_id = 'esclusa-de-oro' AND remaining > 0;
COMMIT;
