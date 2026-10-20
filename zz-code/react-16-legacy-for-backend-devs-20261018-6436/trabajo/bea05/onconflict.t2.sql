SELECT pg_sleep(0.5);
SELECT clock_timestamp() AS empieza \gset
INSERT INTO demo_spins (idempotency_key, player_id, delivered_prize) VALUES ('doble-toque', 42, 'vidas-5')
ON CONFLICT (idempotency_key) DO NOTHING;
SELECT round(extract(epoch FROM clock_timestamp() - :'empieza')::numeric, 2) AS segundos;
INSERT INTO demo_spins (idempotency_key, player_id, delivered_prize) VALUES ('doble-toque', 42, 'vidas-5');
