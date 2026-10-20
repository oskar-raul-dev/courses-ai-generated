BEGIN;
INSERT INTO demo_spins (idempotency_key, player_id, delivered_prize) VALUES ('doble-toque', 42, 'vidas-5')
ON CONFLICT (idempotency_key) DO NOTHING;
SELECT pg_sleep(2);
COMMIT;
