-- postgres
-- Fase 25 · ejercicios 1 a 16. Antes: 01 a 06, y 05_convivencia.py recién corrido (el slot sigue creado).
-- No cambia nada: lo que escribe, lo escribe dentro de una transacción que se revierte.

\echo '== Ejercicio 1: columnas tipadas y de texto'
SELECT typed AS tipada, count(*) AS columnas, count(DISTINCT source_table) AS tablas
FROM staging.wide_column GROUP BY typed ORDER BY typed DESC;

\echo '== Ejercicio 2: los valores rechazados'
SELECT rule, value, count(*) FROM staging.rejection WHERE phase = '25' AND rule LIKE 'anchas.%'
GROUP BY 1, 2 ORDER BY 3 DESC;

\echo '== Ejercicio 3: lo que trajo Hemograma'
SELECT source_column, count(*) AS resultados FROM staging.wide_result
WHERE source_table = 'Hemograma' GROUP BY 1 ORDER BY 1;

\echo '== Ejercicio 4: las unidades que el modelo no contaba'
SELECT count(*) FILTER (WHERE x."Cantidad" <> 1) AS practicas_con_cantidad,
       sum(x."Cantidad") - count(*) AS unidades_de_mas
FROM legacy."ProtocoloPracticas" AS x
JOIN alameda.billed_practice AS b ON b.legacy_order_practice_id = x."Id";

\echo '== Ejercicio 5: el slot'
SELECT slot_name, plugin, slot_type, active, confirmed_flush_lsn IS NOT NULL AS tiene_posicion
FROM pg_replication_slots WHERE slot_name = 'f25_legacy';

\echo '== Ejercicio 6: lo que puede hacer el frontal'
SELECT table_name, string_agg(privilege_type, ', ' ORDER BY privilege_type) AS permisos
FROM information_schema.role_table_grants
WHERE grantee = 'access_frontend' AND table_schema = 'legacy' GROUP BY 1 ORDER BY 1;

\echo '== Ejercicio 7: los antecedentes de la señora'
SELECT count(*) AS antes_de_2008, min(o.ordered_on) AS primero
FROM truth.planted_case AS c
JOIN truth.patient_record AS tp ON tp.person_id = c.person_id
JOIN alameda.patient AS p ON p.legacy_patient_id = tp.legacy_patient_id
JOIN alameda.lab_order AS o ON o.patient_id = coalesce(p.merged_into_patient_id, p.patient_id)
JOIN staging.wide_result AS w ON w.lab_order_id = o.lab_order_id
WHERE c.case_code = 'boss-1-lady';

\echo '== Ejercicio 8: VER OBS sin observación'
SELECT count(*) AS ver_obs,
       count(*) FILTER (WHERE NOT EXISTS (SELECT 1 FROM staging.wide_unmapped AS u
                                          WHERE u.source_table = c.source_table AND u.lab_order_id = c.lab_order_id
                                            AND u.source_column = 'Obs')) AS sin_obs
FROM staging.wide_cell AS c WHERE btrim(c.raw_value) = 'VER OBS';

\echo '== Ejercicio 9: la suma de control de la hemoglobina'
SELECT (SELECT sum(replace(btrim(raw_value), ',', '.')::numeric) FROM staging.wide_cell AS c
         JOIN staging.wide_result USING (source_table, lab_order_id, source_column)
         WHERE c.source_table = 'Hemograma' AND c.source_column = 'Hemoglobina') AS origen,
       (SELECT sum(t.value_numeric) FROM staging.wide_result AS w JOIN alameda.result AS t USING (result_id)
         WHERE w.source_table = 'Hemograma' AND w.source_column = 'Hemoglobina') AS destino;

\echo '== Ejercicio 10: lo que borraría deshacer Ferritina'
SELECT count(*) AS resultados, min(result_id), max(result_id)
FROM staging.wide_result WHERE source_table = 'Ferritina';

\echo '== Ejercicio 11: la clave ocupada'
BEGIN;
SELECT staging.f25_apply_result(jsonb_build_object(
    'IdItem', (SELECT min(result_id) FROM staging.wide_result), 'IdProtocolo', 11000000,
    'CodDeterminacion', 'GLU', 'Valor', '99', 'FechaCarga', '2026-10-12 09:00:00'));
SELECT rule, detail FROM staging.rejection WHERE rule = 'cdc.clave_ocupada';
SELECT t.lab_order_id = w.lab_order_id AS sigue_siendo_la_migrada
FROM staging.wide_result AS w JOIN alameda.result AS t USING (result_id)
WHERE w.result_id = (SELECT min(result_id) FROM staging.wide_result);
ROLLBACK;

\echo '== Ejercicio 12: la posición contra el slot'
SELECT p.applied_lsn, s.confirmed_flush_lsn, p.applied_lsn <= s.confirmed_flush_lsn AS slot_al_dia
FROM staging.f25_cdc_position AS p JOIN pg_replication_slots AS s ON s.slot_name = p.slot_name;

\echo '== Ejercicio 13: el atraso'
SELECT count(*) AS transacciones,
       round(percentile_cont(0.5) WITHIN GROUP (ORDER BY extract(epoch FROM applied_at - committed_at))::numeric * 1000) AS mediana_ms,
       round(percentile_cont(0.95) WITHIN GROUP (ORDER BY extract(epoch FROM applied_at - committed_at))::numeric * 1000) AS p95_ms
FROM staging.f25_cdc_log;

\echo '== Ejercicio 14: a revisar, pero la misma persona'
SELECT x.status, count(*) FILTER (WHERE tp.person_id = x.sih_patient_id - 5000000) AS misma,
       count(*) FILTER (WHERE tp.person_id <> x.sih_patient_id - 5000000) AS otra
FROM staging.patient_sih AS x JOIN alameda.patient AS p USING (patient_id)
JOIN truth.patient_record AS tp ON tp.legacy_patient_id = p.legacy_patient_id
GROUP BY 1 ORDER BY 1;

\echo '== Ejercicio 15: mil cubetas en vez de cien'
WITH l AS (SELECT sih_patient_id % 1000 AS cubeta, md5(string_agg(sih_patient_id || '|' || patient_id || '|' || status, ','
                  ORDER BY sih_patient_id)) AS h, count(*) AS n FROM staging.patient_sih GROUP BY 1),
     s AS (SELECT sih_patient_id % 1000 AS cubeta, md5(string_agg(sih_patient_id || '|' || patient_id || '|' || status, ','
                  ORDER BY sih_patient_id)) AS h FROM sih.lab_link GROUP BY 1)
SELECT count(*) AS cubetas, count(*) FILTER (WHERE l.h <> s.h) AS distintas,
       sum(n) FILTER (WHERE l.h <> s.h) AS filas_a_bajar
FROM l JOIN s USING (cubeta);

\echo '== Ejercicio 16: cuándo choca la identidad con un número de 2004'
SELECT (SELECT max("IdProtocolo") FROM legacy."Protocolos" WHERE "Fecha" >= '2012-01-01' AND "Fecha" < '2026-10-12') AS ultimo,
       min("IdProtocolo") AS primer_aleatorio_por_encima,
       min("IdProtocolo") - (SELECT max("IdProtocolo") FROM legacy."Protocolos"
                             WHERE "Fecha" >= '2012-01-01' AND "Fecha" < '2026-10-12') AS numeros_libres,
       (SELECT round(count(*) / 365.0) FROM legacy."Protocolos" WHERE "Fecha" >= '2025-10-01' AND "Fecha" < '2026-10-01') AS por_dia
FROM legacy."Protocolos"
WHERE "Fecha" < '2012-01-01'
  AND "IdProtocolo" > (SELECT max("IdProtocolo") FROM legacy."Protocolos" WHERE "Fecha" >= '2012-01-01' AND "Fecha" < '2026-10-12');
