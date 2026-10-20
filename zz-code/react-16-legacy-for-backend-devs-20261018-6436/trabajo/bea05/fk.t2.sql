SELECT pg_sleep(0.3);
BEGIN;
INSERT INTO demo_requests (idempotency_key, player_id) VALUES ('giro-b', 42);
SELECT pg_sleep(1);
SELECT free_spins FROM demo_players WHERE id = 42 FOR UPDATE;
COMMIT;
