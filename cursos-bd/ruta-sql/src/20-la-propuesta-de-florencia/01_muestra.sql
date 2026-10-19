-- Fase 20 · la muestra con la que se miden los tres diseños: 50.000 protocolos de 2025 y sus resultados.
-- Corre en Postgres después de cargar truth (y del modelo alameda). Determinista: el orden es por hashtext.
-- Las correcciones NO vienen de la caja (el sistema de 2011 no guardaba auditoría); se simulan aquí, al 4 % de
-- los resultados, y el script lo registra en staging.f20_correction. Ninguna cifra de la fase depende de quién corrigió.

DROP TABLE IF EXISTS staging.f20_order, staging.f20_result, staging.f20_correction;

-- 1. Los protocolos. Sin nombre de paciente: el repositorio no publica datos identificables, y la fase no lo necesita.
CREATE TABLE staging.f20_order AS
SELECT o.lab_order_id, o.ordered_on, o.site_code, o.payer_code,
       p.patient_id, p.sex, p.birth_date
FROM alameda.lab_order o
JOIN alameda.patient p ON p.patient_id = o.patient_id
WHERE o.ordered_on >= '2025-01-01' AND o.ordered_on < '2026-01-01'
ORDER BY hashtext(o.lab_order_id::text)
LIMIT 50000;
ALTER TABLE staging.f20_order ADD PRIMARY KEY (lab_order_id);

-- 2. Sus resultados, con el nombre, la unidad y el rango del analito.
CREATE TABLE staging.f20_result AS
SELECT r.result_id, r.lab_order_id, r.analyte_code, a.name AS analyte_name, a.unit, a.reference_range,
       r.value_numeric, r.qualifier, r.value_text, r.sample_flag, r.recorded_at
FROM staging.f20_order o
JOIN alameda.result r ON r.lab_order_id = o.lab_order_id
LEFT JOIN alameda.analyte a ON a.analyte_code = r.analyte_code;
ALTER TABLE staging.f20_result ADD PRIMARY KEY (result_id);
CREATE INDEX f20_result_order ON staging.f20_result (lab_order_id);

-- 3. Correcciones simuladas: un cambio por cada 25 resultados (4 %), a la hora siguiente de la carga.
CREATE TABLE staging.f20_correction AS
SELECT row_number() OVER (ORDER BY r.result_id) AS correction_id,
       r.result_id, r.lab_order_id, r.analyte_code,
       r.recorded_at + make_interval(hours => 1 + (hashtext(r.result_id::text) & 1023) % 72) AS changed_at,
       (ARRAY['tec_ana', 'tec_luis', 'tec_mariela', 'tec_julian', 'bio_norma', 'bio_pablo'])[1 + (hashtext(r.result_id::text || 'u') & 7) % 6] AS changed_by,
       coalesce(r.value_numeric::text, r.value_text) AS old_value,
       (ARRAY['error de transcripción', 'repetición de muestra', 'hemólisis informada', 'unidad corregida', 'validación técnica'])[1 + (hashtext(r.result_id::text || 'r') & 7) % 5] AS reason
FROM staging.f20_result r
WHERE (r.result_id % 25) = 0;
ALTER TABLE staging.f20_correction ADD PRIMARY KEY (correction_id);
CREATE INDEX f20_correction_changed ON staging.f20_correction (changed_at);

VACUUM ANALYZE staging.f20_order;
VACUUM ANALYZE staging.f20_result;
VACUUM ANALYZE staging.f20_correction;

SELECT (SELECT count(*) FROM staging.f20_order)      AS orders,
       (SELECT count(*) FROM staging.f20_result)     AS results,
       (SELECT count(*) FROM staging.f20_correction) AS corrections,
       (SELECT count(DISTINCT payer_code) FROM staging.f20_order) AS payers;
