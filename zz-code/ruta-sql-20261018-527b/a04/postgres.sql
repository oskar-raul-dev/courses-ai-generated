\echo == extensiones
SELECT extname, extversion FROM pg_extension WHERE extname IN ('pg_stat_statements','pgstattuple') ORDER BY 1;
\echo == tamanos
SELECT pg_size_pretty(pg_relation_size('legacy."Pacientes"')) AS tabla,
       pg_size_pretty(pg_indexes_size('legacy."Pacientes"')) AS indices,
       pg_size_pretty(pg_total_relation_size('legacy."Pacientes"')) AS total,
       pg_relation_size('legacy."Pacientes"') / 8192 AS bloques;
\echo == pgstattuple
SELECT tuple_count, dead_tuple_count, round(free_percent::numeric, 1) AS libre_pct, round(tuple_percent::numeric, 1) AS ocupado_pct
FROM pgstattuple('legacy."Pacientes"');
\echo == pg_stat_user_tables
SELECT relname, seq_scan, idx_scan, n_live_tup, n_dead_tup, last_autovacuum IS NOT NULL AS hubo_autovacuum
FROM pg_stat_user_tables WHERE schemaname = 'legacy' AND relname IN ('Pacientes','Protocolos') ORDER BY 1;
\echo == wal
CREATE TABLE lab.a04_wal AS SELECT "IdPaciente", "Nombre", "DNI" FROM legacy."Pacientes" WHERE "IdPaciente" <= 1000;
EXPLAIN (ANALYZE, WAL, COSTS OFF, TIMING OFF, SUMMARY OFF) UPDATE lab.a04_wal SET "DNI" = "DNI" WHERE "IdPaciente" <= 100;
EXPLAIN (ANALYZE, WAL, COSTS OFF, TIMING OFF, SUMMARY OFF) UPDATE lab.a04_wal SET "DNI" = "DNI" WHERE "IdPaciente" <= 100;
DROP TABLE lab.a04_wal;
\echo == pg_stat_statements
SELECT pg_stat_statements_reset() IS NOT NULL AS reiniciado;
SELECT count(*) FROM legacy."Pacientes" WHERE "Nombre" LIKE '%DNI%';
SELECT count(*) FROM legacy."Pacientes" WHERE "Nombre" LIKE '%PASAP%';
SELECT calls, rows, shared_blks_hit + shared_blks_read AS bloques, left(query, 70) AS consulta
FROM pg_stat_statements WHERE query LIKE '%Pacientes%LIKE%' AND query NOT LIKE '%pg_stat_statements%' ORDER BY calls DESC;
