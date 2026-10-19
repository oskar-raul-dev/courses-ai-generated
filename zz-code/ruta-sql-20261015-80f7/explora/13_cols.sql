select table_name||': '||string_agg(column_name||' '||data_type||coalesce(' default '||column_default,''), ', ' order by ordinal_position) from information_schema.columns where table_schema='legacy' and table_name in ('ResultadoItem','Determinaciones','Protocolos','ProtocoloPracticas') group by table_name;
select * from alameda.site;
select "CodDeterminacion","CodPractica" from legacy."Determinaciones" order by 2 limit 40;
select extract(dow from "Fecha") dow, count(*) from legacy."Protocolos" where "Fecha">='2026-09-01' and "Fecha"<'2030-01-01' group by 1 order by 1;
select "Equipo", count(*) from legacy."ResultadoItem" where "FechaCarga">='2026-10-01' group by 1;
