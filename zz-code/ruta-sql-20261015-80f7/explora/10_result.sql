select tgname, tgrelid::regclass from pg_trigger where not tgisinternal and tgrelid::regclass::text like 'alameda.%';
select conname, conrelid::regclass, pg_get_constraintdef(oid) from pg_constraint where confrelid='alameda.result'::regclass or conrelid='alameda.result'::regclass;
select pg_size_pretty(pg_total_relation_size('alameda.result')), (select count(*) from alameda.result);
select indexrelid::regclass from pg_index where indrelid='alameda.result'::regclass;
select polname, polrelid::regclass from pg_policy;
