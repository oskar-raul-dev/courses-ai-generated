BEGIN;
INSERT INTO demo_requests (idempotency_key, player_id) VALUES ('giro-a', 42);
SELECT pg_sleep(1);
SELECT free_spins FROM demo_players WHERE id = 42 FOR UPDATE;
COMMIT;
