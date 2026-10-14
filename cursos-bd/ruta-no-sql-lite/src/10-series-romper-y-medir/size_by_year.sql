-- El tamaño de reading_x10 por año, antes y después de comprimir (perfil series, base condor), y el de
-- las particiones de Postgres del mismo año (perfil base, base series_base: ver size_by_year_base.sql).
SELECT extract(year FROM c.range_start)::int AS year, count(*) AS chunks,
       count(*) FILTER (WHERE c.is_compressed) AS compressed,
       round(sum(coalesce(s.before_compression_total_bytes, hypertable_size_bytes)) / 1048576.0) AS before_mib,
       round(sum(coalesce(s.after_compression_total_bytes, hypertable_size_bytes)) / 1048576.0) AS after_mib
FROM timescaledb_information.chunks c
LEFT JOIN chunk_compression_stats('reading_x10') s ON s.chunk_name = c.chunk_name
CROSS JOIN LATERAL (SELECT pg_total_relation_size(format('%I.%I', c.chunk_schema, c.chunk_name)) AS hypertable_size_bytes) z
WHERE c.hypertable_name = 'reading_x10'
GROUP BY 1 ORDER BY 1;
