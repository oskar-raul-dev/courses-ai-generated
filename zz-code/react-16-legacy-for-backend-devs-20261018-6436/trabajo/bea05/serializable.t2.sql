SELECT pg_sleep(0.5);
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT remaining FROM demo_stock WHERE segment_id = 'esclusa-de-oro';
SELECT pg_sleep(1);
UPDATE demo_stock SET remaining = remaining - 1 WHERE segment_id = 'esclusa-de-oro';
ROLLBACK;
