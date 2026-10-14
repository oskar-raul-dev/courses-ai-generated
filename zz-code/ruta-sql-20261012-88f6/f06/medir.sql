\echo == 4FN
SELECT (SELECT count(*) FROM staging.patient_phone) telefonos, (SELECT count(*) FROM staging.patient_physician) medicos,
       (SELECT count(*) FROM staging.patient_contact_combined) combinada;
SELECT count(*) pacientes, count(*) FILTER (WHERE f>1) con_varios_telefonos, count(*) FILTER (WHERE m>1) con_varios_medicos, count(*) FILTER (WHERE f>1 AND m>1) con_ambos
FROM (SELECT legacy_patient_id, count(DISTINCT phone) f, count(DISTINCT physician_id) m FROM staging.patient_contact_combined GROUP BY 1) x;
SELECT pg_size_pretty(pg_total_relation_size('staging.patient_phone')) tel, pg_size_pretty(pg_total_relation_size('staging.patient_physician')) med, pg_size_pretty(pg_total_relation_size('staging.patient_contact_combined')) comb;
SELECT count(*) reconstruida FROM (SELECT DISTINCT legacy_patient_id, phone FROM staging.patient_contact_combined) a JOIN (SELECT DISTINCT legacy_patient_id, physician_id FROM staging.patient_contact_combined) b USING (legacy_patient_id);
-- la anomalía: un paciente con dos teléfonos suma un médico nuevo
SELECT legacy_patient_id, count(DISTINCT phone) telefonos, count(DISTINCT physician_id) medicos, count(*) filas FROM staging.patient_contact_combined GROUP BY 1 HAVING count(DISTINCT phone) > 1 ORDER BY 1 LIMIT 3;
\echo == 5FN cíclica
SELECT (SELECT count(*) FROM staging.agreement_raw) ternaria, (SELECT count(*) FROM alameda.payer_practice) pp, (SELECT count(*) FROM alameda.practice_site) ps, (SELECT count(*) FROM alameda.payer_site) ys, (SELECT count(*) FROM alameda.agreement) vista;
SELECT count(*) espurias FROM alameda.agreement g JOIN alameda.practice_code c ON c.practice_id=g.practice_id AND c.nomenclator_code='NBU2012'
WHERE NOT EXISTS (SELECT 1 FROM staging.agreement_raw a WHERE a.payer=g.payer_code AND a.practice=c.code AND a.site=g.site_code);
SELECT count(*) perdidas FROM staging.agreement_raw a JOIN alameda.practice_code c ON c.nomenclator_code='NBU2012' AND c.code=a.practice
WHERE NOT EXISTS (SELECT 1 FROM alameda.agreement g WHERE g.payer_code=a.payer AND g.practice_id=c.practice_id AND g.site_code=a.site);
WITH pp AS (SELECT DISTINCT payer, practice FROM staging.agreement_raw), ps AS (SELECT DISTINCT practice, site FROM staging.agreement_raw)
SELECT count(*) dos_binarias, count(*) - 1422 espurias FROM pp JOIN ps USING (practice);
\echo == 5FN no cíclica
WITH t AS (SELECT * FROM staging.agreement_noncyclic),
pp AS (SELECT DISTINCT payer, practice FROM t), ps AS (SELECT DISTINCT practice, site FROM t), ys AS (SELECT DISTINCT payer, site FROM t),
j AS (SELECT pp.payer, pp.practice, ps.site FROM pp JOIN ps USING (practice) JOIN ys ON ys.payer=pp.payer AND ys.site=ps.site)
SELECT (SELECT count(*) FROM t) ternaria, (SELECT count(*) FROM pp) pp, (SELECT count(*) FROM ps) ps, (SELECT count(*) FROM ys) ys,
       (SELECT count(*) FROM j) rejoin, (SELECT count(*) FROM j WHERE NOT EXISTS (SELECT 1 FROM t WHERE t.payer=j.payer AND t.practice=j.practice AND t.site=j.site)) espurias,
       (SELECT count(*) FROM t WHERE NOT EXISTS (SELECT 1 FROM j WHERE t.payer=j.payer AND t.practice=j.practice AND t.site=j.site)) perdidas;
