\set d0 '''2026-09-28'''
\set d1 '''2026-10-05'''
with w as (
 select b.*, x."IdProtocolo", x."Cantidad", o."Sede", o."Coseguro"
 from alameda.billed_practice b join legacy."ProtocoloPracticas" x on x."Id"=b.legacy_order_practice_id
 join legacy."Protocolos" o using ("IdProtocolo")
 where lower(b.billed_during)>=:d0 and lower(b.billed_during)<:d1)
select payer_code, count(*) n,
 count(*) filter (where exists (select 1 from alameda.agreement a where a.payer_code=w.payer_code and a.practice_id=w.practice_id and a.site_code=w."Sede")) en_conv,
 count(*) filter (where exists (select 1 from alameda.payer_practice a where a.payer_code=w.payer_code and a.practice_id=w.practice_id)) cubre,
 count(*) filter (where exists (select 1 from alameda.payer_site a where a.payer_code=w.payer_code and a.site_code=w."Sede")) sede_ok
from w group by rollup(1) order by 2 desc;
select payer_code, count(*) from alameda.payer_practice group by 1 order by 1;
select count(*) from alameda.practice;
