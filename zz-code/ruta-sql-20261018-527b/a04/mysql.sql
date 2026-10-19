SELECT '== tamanos';
ANALYZE TABLE legacy.Pacientes;
SELECT table_rows, ROUND(data_length/1048576, 1) AS datos_mb, ROUND(index_length/1048576, 1) AS indices_mb, ROUND(data_free/1048576, 1) AS libre_mb
FROM information_schema.TABLES WHERE table_schema = 'legacy' AND table_name = 'Pacientes';
SELECT '== innodb_table_stats';
SELECT n_rows, clustered_index_size, sum_of_other_index_sizes FROM mysql.innodb_table_stats WHERE database_name = 'legacy' AND table_name = 'Pacientes';
SELECT '== format tree';
EXPLAIN FORMAT=TREE SELECT count(*) FROM legacy.Pacientes WHERE Nombre LIKE '%DNI%';
SELECT '== digest';
TRUNCATE performance_schema.events_statements_summary_by_digest;
SELECT count(*) FROM legacy.Pacientes WHERE Nombre LIKE '%DNI%';
SELECT count(*) FROM legacy.Pacientes WHERE Nombre LIKE '%PASAP%';
SELECT count_star AS calls, sum_rows_examined AS examinadas, sum_rows_sent AS enviadas, LEFT(digest_text, 70) AS consulta
FROM performance_schema.events_statements_summary_by_digest WHERE digest_text LIKE '%Pacientes%LIKE%' AND digest_text NOT LIKE '%digest%';
