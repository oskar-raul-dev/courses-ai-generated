select count(*) nuevos, count(*) filter (where w.result_id is not null) en_rango_anchas,
 count(*) filter (where w.result_id is not null and t.lab_order_id = w.lab_order_id) con_protocolo_de_ancha
from legacy."ResultadoItem" li join alameda.result t on t.result_id=li."IdItem"
left join staging.wide_result w on w.result_id=li."IdItem" where li."IdItem">12134453;
select "IdProtocolo" from legacy."Protocolos" order by 1 desc limit 3;
select width_bucket("IdProtocolo", -2147483648, 2147483647, 8) b, count(*), min("IdProtocolo"), max("IdProtocolo") from legacy."Protocolos" where "Fecha"<'2026-10-12' group by 1 order by 1;
select min("IdProtocolo"), max("IdProtocolo") from legacy."Protocolos" where "Fecha">='2026-01-01' and "Fecha"<'2026-10-12';
-- prácticas sin precio / sin destino del día
with lx as (select x.*, o."IdObraSocial", o."Fecha" from legacy."ProtocoloPracticas" x join legacy."Protocolos" o using ("IdProtocolo") where x."Id">6132114)
select (select payer_code from alameda.payer where payer_id=lx."IdObraSocial") payer, lx."Nomenclador",
 count(*), count(*) filter (where exists (select 1 from alameda.billed_practice b where b.legacy_order_practice_id=lx."Id")) fact,
 count(*) filter (where exists (select 1 from alameda.practice_code c where c.nomenclator_code=lx."Nomenclador" and c.code=lx."CodigoPractica")) mapea
from lx group by 1,2 order by 1,2;
