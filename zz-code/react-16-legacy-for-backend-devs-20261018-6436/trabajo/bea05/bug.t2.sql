SELECT pg_sleep(0.5);
BEGIN;
SELECT remaining FROM demo_stock WHERE segment_id = 'esclusa-de-oro';
SELECT pg_sleep(1);
UPDATE demo_stock SET remaining = remaining - 1 WHERE segment_id = 'esclusa-de-oro';
INSERT INTO demo_spins (idempotency_key, player_id, delivered_prize) VALUES ('k-2', 43, 'esclusa-de-oro');
COMMIT;
SELECT remaining FROM demo_stock WHERE segment_id = 'esclusa-de-oro';
SELECT count(*) AS entregadas FROM demo_spins WHERE delivered_prize = 'esclusa-de-oro';
