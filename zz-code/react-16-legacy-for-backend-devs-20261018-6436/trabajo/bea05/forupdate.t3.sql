SELECT pg_sleep(1);
SELECT pid, state, wait_event_type, wait_event, left(query, 60) AS consulta
FROM pg_stat_activity
WHERE datname = 'bea05' AND state <> 'idle' AND query NOT LIKE '%pg_stat_activity%'
ORDER BY xact_start;
SELECT blocked.pid AS bloqueado, blocking.pid AS bloqueante,
       left(blocked.query, 40) AS espera, left(blocking.query, 40) AS culpable
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking ON blocking.pid = ANY(pg_blocking_pids(blocked.pid));
