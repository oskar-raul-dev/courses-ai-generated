select table_name||': '||string_agg(column_name||' '||data_type, ', ' order by ordinal_position) from information_schema.columns where table_schema='alameda' and table_name in ('order_payer','patient','patient_record','person','patient_merge','identity_document','lab_order','referral','result_value') group by table_name;
select count(*) from alameda.analyte; select string_agg(analyte_code, ' ' order by analyte_code) from alameda.analyte;
select relname, relrowsecurity from pg_class where relnamespace='alameda'::regnamespace and relrowsecurity;
select count(*), sum(case when pg_class.relkind='r' then 1 else 0 end) from pg_class where relnamespace='alameda'::regnamespace;
