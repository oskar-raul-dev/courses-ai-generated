select min("Fecha"), max("Fecha") from legacy."Protocolos" where "Fecha" < '2030-01-01';
select date_trunc('week',"Fecha")::date as semana, count(*) from legacy."Protocolos"
where "Fecha" >= '2026-08-01' and "Fecha" < '2030-01-01' group by 1 order by 1 desc limit 12;
