with w as (select x."IdProtocolo" oid, pc.practice_id from legacy."ProtocoloPracticas" x join legacy."Protocolos" o using ("IdProtocolo")
 join alameda.practice_code pc on pc.nomenclator_code=x."Nomenclador" and pc.code=x."CodigoPractica" where o."Fecha">='2026-01-01' and o."Fecha"<'2026-10-12')
select count(*) filter (where practice_id in (21,34)) paneles, count(*) filter (where practice_id in (22,23,25,26,27,28,49)) componentes,
 (select count(*) from w a join staging.practice_composition k on k.component_id=a.practice_id join w b on b.oid=a.oid and b.practice_id=k.panel_id) juntas
from w;
