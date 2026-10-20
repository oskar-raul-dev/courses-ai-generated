SELECT pg_sleep(1);
SELECT pid, wait_event_type, wait_event, left(query, 70) AS consulta
FROM pg_stat_activity
WHERE datname = 'bea05' AND state <> 'idle' AND pid <> pg_backend_pid() AND wait_event_type = 'Lock';
