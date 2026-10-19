\set d0 '''2026-09-28'''
\set d1 '''2026-10-05'''
-- protocolos y prácticas de la semana por obra social
select coalesce(y.payer_code,'(sin)') payer, count(distinct o."IdProtocolo") prot, count(*) pract, sum(x."Cantidad") cant,
  count(*) filter (where x."Cantidad"<>1) cant_no1,
  count(*) filter (where o."Coseguro" is not null and o."Coseguro"<>0) con_coseguro
from legacy."ProtocoloPracticas" x join legacy."Protocolos" o using ("IdProtocolo")
left join alameda.payer y on y.payer_id=o."IdObraSocial"
where o."Fecha">=:d0 and o."Fecha"<:d1 group by rollup(1) order by 3 desc nulls first;
-- nomencladores
select x."Nomenclador", count(*) from legacy."ProtocoloPracticas" x join legacy."Protocolos" o using ("IdProtocolo")
where o."Fecha">=:d0 and o."Fecha"<:d1 group by 1;
-- billed_practice de la semana y precio y convenio
select count(*) bp,
  count(*) filter (where exists (select 1 from alameda.agreement a join alameda.lab_order lo on true where false)) dummy
from alameda.billed_practice b where lower(b.billed_during)>=:d0 and lower(b.billed_during)<:d1;
select o."Estado", count(*) from legacy."Protocolos" o where o."Fecha">=:d0 and o."Fecha"<:d1 group by 1;
select o."Coseguro", count(*) from legacy."Protocolos" o where o."Fecha">=:d0 and o."Fecha"<:d1 group by 1 order by 2 desc limit 10;
