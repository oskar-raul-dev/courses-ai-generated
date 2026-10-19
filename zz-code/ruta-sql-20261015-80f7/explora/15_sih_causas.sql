-- revisar: por qué
select case when s.sex<>p.sex then 'sexo distinto' when p.birth_date is null then 'lab sin fecha'
 when p.birth_date > current_date then 'lab: fecha en el futuro'
 when p.birth_date = tr.birth_date and s.birth_date<>tr.birth_date then 'SIH: error sembrado'
 when p.birth_date <> tr.birth_date then 'lab: fecha distinta de la verdad' else 'otra' end causa,
 (tp.person_id = s.sih_patient_id-5000000) correcto, count(*)
from staging.patient_sih x join alameda.patient p using (patient_id) join sih.patient s using (sih_patient_id)
join truth.patient_record tp on tp.legacy_patient_id=p.legacy_patient_id join truth.person tr on tr.person_id=tp.person_id
where x.status='revisar' group by 1,2 order by 3 desc;
-- incorrectos: quiénes
select tr.document_type, (select case_code from truth.planted_case c where c.person_id=tp.person_id) plantado, count(*)
from staging.patient_sih x join alameda.patient p using (patient_id) join sih.patient s using (sih_patient_id)
join truth.patient_record tp on tp.legacy_patient_id=p.legacy_patient_id join truth.person tr on tr.person_id=tp.person_id
where tp.person_id <> s.sih_patient_id-5000000 group by 1,2;
-- sin pareja pero en el SIH: por qué
with lab as (select p.patient_id, tp.person_id from alameda.patient p join truth.patient_record tp on tp.legacy_patient_id=p.legacy_patient_id
 where p.merged_into_patient_id is null and not exists (select 1 from staging.patient_sih x where x.patient_id=p.patient_id)
 and exists (select 1 from sih.patient s where s.sih_patient_id=5000000+tp.person_id))
select case when not exists (select 1 from alameda.identity_document d where d.patient_id=lab.patient_id) then 'lab: sin documento'
 when exists (select 1 from alameda.identity_document d where d.patient_id=lab.patient_id and d.document_type in ('LC','LE')) then 'lab: libreta; SIH: DNI posterior'
 when tr.document_type='PAS' then 'pasaporte'
 when exists (select 1 from alameda.identity_document d join sih.patient s on s.sih_patient_id=5000000+lab.person_id where d.patient_id=lab.patient_id and d.number<>s.document_number) then 'número distinto'
 else 'otra' end causa, count(*)
from lab join truth.person tr on tr.person_id=lab.person_id group by 1 order by 2 desc;
-- ¿cuántas personas del lab tienen más de una ficha viva?
select count(*) from (select tp.person_id from alameda.patient p join truth.patient_record tp on tp.legacy_patient_id=p.legacy_patient_id where p.merged_into_patient_id is null group by 1 having count(*)>1) z;
