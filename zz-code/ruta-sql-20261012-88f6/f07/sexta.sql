\echo == 3FN
EXPLAIN (ANALYZE, BUFFERS, COSTS ON, TIMING OFF, SUMMARY ON)
SELECT p.patient_id, p.full_name FROM alameda.patient AS p
WHERE p.sex = 'F' AND p.birth_date >= '1950-01-01' AND p.birth_date < '1951-01-01';
\echo == 6FN, al 1 de enero de 2026
EXPLAIN (ANALYZE, BUFFERS, COSTS ON, TIMING OFF, SUMMARY ON)
SELECT a.patient_id, n.full_name
FROM staging.patient_anchor AS a
JOIN staging.patient_anchor_sex AS s ON s.patient_id = a.patient_id AND s.valid_during @> date '2026-01-01'
JOIN staging.patient_anchor_birth_date AS b ON b.patient_id = a.patient_id AND b.valid_during @> date '2026-01-01'
JOIN staging.patient_anchor_name AS n ON n.patient_id = a.patient_id AND n.valid_during @> date '2026-01-01'
WHERE s.sex = 'F' AND b.birth_date >= '1950-01-01' AND b.birth_date < '1951-01-01';
SELECT pg_size_pretty(pg_total_relation_size('alameda.patient')) tercera,
       pg_size_pretty(pg_total_relation_size('staging.patient_anchor') + pg_total_relation_size('staging.patient_anchor_name')
       + pg_total_relation_size('staging.patient_anchor_birth_date') + pg_total_relation_size('staging.patient_anchor_sex')) sexta;
