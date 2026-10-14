SELECT CASE WHEN c.relname = 'reading_part_default' THEN 'default' ELSE substr(c.relname, 14, 4) END AS year,
       count(*) AS partitions, round(sum(pg_total_relation_size(c.oid)) / 1048576.0) AS mib
FROM pg_inherits i JOIN pg_class c ON c.oid = i.inhrelid
WHERE i.inhparent = 'reading_part'::regclass GROUP BY 1 ORDER BY 1;
