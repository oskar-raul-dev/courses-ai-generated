\set d0 '''2026-09-28'''
\set d1 '''2026-10-05'''
with p as (
 select o."IdProtocolo", y.payer_code, o."Coseguro", sum(ap.amount * x."Cantidad") total, count(*) n, count(ap.amount) con_precio
 from legacy."Protocolos" o join legacy."ProtocoloPracticas" x using ("IdProtocolo")
 join alameda.payer y on y.payer_id=o."IdObraSocial"
 left join alameda.practice_code c on c.nomenclator_code=x."Nomenclador" and c.code=x."CodigoPractica"
 left join alameda.agreement_price ap on ap.payer_code=y.payer_code and ap.practice_id=c.practice_id and ap.valid_during @> o."Fecha"::date
 where o."Fecha">=:d0 and o."Fecha"<:d1 group by 1,2,3)
select payer_code, count(*), count("Coseguro") cos, round(avg("Coseguro"/nullif(total,0)),3) ratio_avg,
 count(*) filter (where "Coseguro"=total) igual, count(*) filter (where "Coseguro">total) mayor, sum(n-con_precio) sin_precio
from p group by 1 order by 1;
