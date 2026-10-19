with t as (select c.relname, c.reltuples::bigint filas,
  (select string_agg(a.attname, ',' order by a.attnum) from pg_attribute a where a.attrelid=c.oid and a.attnum>0 and not a.attisdropped and a.attname not in ('Id','IdProtocolo','Fecha')) cols,
  (select k.conkey is not null from pg_constraint k where k.conrelid=c.oid and k.contype='p') pk
 from pg_class c where c.relnamespace='legacy'::regnamespace and c.relkind='r'
 and exists (select 1 from pg_attribute a where a.attrelid=c.oid and a.attname='IdProtocolo')
 and exists (select 1 from pg_attribute a where a.attrelid=c.oid and a.attname='Obs'))
select count(*), sum(filas) from t;
