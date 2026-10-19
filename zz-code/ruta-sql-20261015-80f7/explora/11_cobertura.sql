select count(distinct source_table), count(*) filter (where typed), count(*) filter (where not typed) from staging.wide_column;
select c.relname from pg_class c where c.relnamespace='legacy'::regnamespace and c.relkind='r'
 and exists (select 1 from pg_attribute a where a.attrelid=c.oid and a.attname='Obs') and exists (select 1 from pg_attribute a where a.attrelid=c.oid and a.attname='IdProtocolo')
 and c.relname not in (select source_table from staging.wide_column);
select value, count(*) from staging.rejection where phase='25' group by 1 order by 2 desc limit 10;
select source_column, count(*) from staging.wide_unmapped group by 1 order by 1;
select raw_value, count(*) from staging.wide_cell c join staging.wide_column w using (source_table,source_column) where not typed group by 1 order by 2 desc limit 15;
