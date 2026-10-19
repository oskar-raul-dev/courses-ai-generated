select string_agg(column_name||':'||data_type, ', ' order by ordinal_position) from information_schema.columns where table_schema='legacy' and table_name='Hemograma';
select string_agg(column_name||':'||data_type, ', ' order by ordinal_position) from information_schema.columns where table_schema='legacy' and table_name='Quimica';
select count(*) from legacy."Hemograma"; select * from legacy."Hemograma" limit 2;
select min(o."Fecha"), max(o."Fecha"), count(*) from legacy."Hemograma" h left join legacy."Protocolos" o using ("IdProtocolo");
select count(*) from alameda.lab_order where ordered_on < '2008-01-01';
select min(ordered_on) from alameda.lab_order;
