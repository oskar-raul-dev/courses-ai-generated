select count(*) total, count(*) filter (where tp.person_id<>top.person_id) mal,
 count(*) filter (where o.ordered_on<'2008-01-01') pre08, count(*) filter (where o.ordered_on<'2008-01-01' and tp.person_id<>top.person_id) mal_pre08
from alameda.lab_order o join alameda.patient p on p.patient_id=o.patient_id
join truth.patient_record tp on tp.legacy_patient_id=p.legacy_patient_id
join truth.order_payer top on top.legacy_protocol_id=o.lab_order_id;
select count(*) from alameda.patient where merged_into_patient_id is not null;
select count(*) from alameda.patient_merge;
