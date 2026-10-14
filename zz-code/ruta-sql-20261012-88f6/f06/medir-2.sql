\echo == 4FN: pacientes que pierden el teléfono en la combinada
SELECT count(DISTINCT f.legacy_patient_id) pacientes_con_telefono_sin_medico FROM staging.patient_phone f
WHERE NOT EXISTS (SELECT 1 FROM staging.patient_physician m WHERE m.legacy_patient_id=f.legacy_patient_id);
SELECT round(count(*)::numeric / count(DISTINCT (legacy_patient_id, phone)), 2) copias_por_telefono FROM staging.patient_contact_combined;
BEGIN;
UPDATE staging.patient_contact_combined SET phone = '4999999' WHERE legacy_patient_id = 33 AND phone = (SELECT min(phone) FROM staging.patient_phone WHERE legacy_patient_id = 33);
UPDATE staging.patient_phone SET phone = '4999999' WHERE legacy_patient_id = 33 AND phone = (SELECT min(phone) FROM staging.patient_phone WHERE legacy_patient_id = 33);
ROLLBACK;
\echo == 5FN: una práctica nueva en una sede
WITH cand AS (SELECT p.practice_id, s.site_code FROM alameda.practice p CROSS JOIN alameda.site s
  WHERE NOT EXISTS (SELECT 1 FROM alameda.practice_site x WHERE x.practice_id=p.practice_id AND x.site_code=s.site_code)
    AND EXISTS (SELECT 1 FROM alameda.payer_practice pp WHERE pp.practice_id=p.practice_id))
SELECT c.practice_id, pr.description, c.site_code,
  (SELECT count(*) FROM alameda.payer_practice pp JOIN alameda.payer_site ys ON ys.payer_code=pp.payer_code AND ys.site_code=c.site_code WHERE pp.practice_id=c.practice_id) filas_en_la_ternaria
FROM cand c JOIN alameda.practice pr USING (practice_id) ORDER BY filas_en_la_ternaria DESC, 1, 3 LIMIT 3;
SELECT count(*) pares_practica_sede_sin_convenio FROM alameda.practice p CROSS JOIN alameda.site s WHERE NOT EXISTS (SELECT 1 FROM alameda.practice_site x WHERE x.practice_id=p.practice_id AND x.site_code=s.site_code);
\echo == costo de leer el convenio
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF) SELECT 1 FROM staging.agreement_raw WHERE payer='OSDE' AND practice='660007' AND site='V';
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF) SELECT 1 FROM alameda.agreement WHERE payer_code='OSDE' AND practice_id=7 AND site_code='V';
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF) SELECT count(*) FROM alameda.agreement;
\echo == la rotura en plata: prácticas de 2026 que caen en convenios espurios de la variante no cíclica
WITH t AS (SELECT * FROM staging.agreement_noncyclic),
pp AS (SELECT DISTINCT payer, practice FROM t), ps AS (SELECT DISTINCT practice, site FROM t), ys AS (SELECT DISTINCT payer, site FROM t),
spur AS (SELECT pp.payer, pp.practice, ps.site FROM pp JOIN ps USING (practice) JOIN ys ON ys.payer=pp.payer AND ys.site=ps.site
         EXCEPT SELECT payer, practice, site FROM t)
SELECT count(*) practicas_2026, count(DISTINCT o."IdProtocolo") protocolos
FROM legacy."ProtocoloPracticas" x JOIN legacy."Protocolos" o USING ("IdProtocolo")
JOIN alameda.payer y ON y.payer_id = o."IdObraSocial"
JOIN spur s ON s.payer = y.payer_code AND s.practice = x."CodigoPractica" AND s.site = o."Sede"
WHERE x."Nomenclador" = 'NBU2012' AND o."Fecha" >= '2026-01-01';
\echo == catálogos: traducir INOS a NBU 2012
SELECT count(*) filas_inos,
  count(*) FILTER (WHERE e."CodNBU2012" IS NOT NULL) por_equivalencias,
  count(*) FILTER (WHERE t.code IS NOT NULL) por_practice_code
FROM legacy."ProtocoloPracticas" pp
LEFT JOIN legacy."EquivalenciasCodigos" e ON e."CodINOS" = pp."CodigoPractica"
LEFT JOIN alameda.practice_code f ON f.nomenclator_code='INOS' AND f.code = pp."CodigoPractica"
LEFT JOIN alameda.practice_code t ON t.nomenclator_code='NBU2012' AND t.practice_id = f.practice_id
WHERE pp."Nomenclador" = 'INOS';
SELECT nomenclator_code, count(*) FROM alameda.practice_code GROUP BY 1 ORDER BY 1;
SELECT count(*) codigos_en_dos_nomencladores FROM (SELECT code FROM alameda.practice_code GROUP BY 1 HAVING count(*)>1) x;
SELECT count(*) mismo_codigo_otra_practica FROM alameda.practice_code a JOIN alameda.practice_code b ON a.code=b.code AND a.nomenclator_code<b.nomenclator_code AND a.practice_id<>b.practice_id;
