SELECT pg_sleep(1);
SELECT state, now() - state_change > interval '0.5 second' AS inactiva_hace_rato, left(query, 50) AS ultima_consulta
FROM pg_stat_activity WHERE datname = 'bea05' AND state = 'idle in transaction';
