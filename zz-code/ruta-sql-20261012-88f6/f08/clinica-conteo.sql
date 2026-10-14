\echo == tipado

WITH o AS (SELECT lab_order_id, patient_id FROM alameda.lab_order WHERE ordered_on >= '2024-01-01' AND ordered_on < '2025-01-01'),
     d AS (SELECT DISTINCT o.patient_id FROM o JOIN alameda.result AS r USING (lab_order_id)
           WHERE r.analyte_code = 'HBA1C' AND r.qualifier IS NULL AND r.value_numeric > 6.5)
SELECT count(*) FROM o JOIN d USING (patient_id) JOIN alameda.result AS r USING (lab_order_id)
WHERE r.analyte_code = 'GLU' AND r.qualifier IS NULL AND r.value_numeric > 126;
\echo == eav

WITH o AS (SELECT lab_order_id, patient_id FROM alameda.lab_order WHERE ordered_on >= '2024-01-01' AND ordered_on < '2025-01-01'),
     d AS (SELECT DISTINCT o.patient_id FROM o JOIN staging.result_eav AS r USING (lab_order_id)
           WHERE r.analyte_code = 'HBA1C'
             AND CASE WHEN r.value ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(r.value, ',', '.')::numeric END > 6.5)
SELECT count(*) FROM o JOIN d USING (patient_id) JOIN staging.result_eav AS r USING (lab_order_id)
WHERE r.analyte_code = 'GLU'
  AND CASE WHEN r.value ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(r.value, ',', '.')::numeric END > 126;
\echo == ancha

WITH o AS (SELECT lab_order_id, patient_id FROM alameda.lab_order WHERE ordered_on >= '2024-01-01' AND ordered_on < '2025-01-01'),
     d AS (SELECT DISTINCT o.patient_id FROM o JOIN staging.result_wide AS w USING (lab_order_id)
           WHERE CASE WHEN w.hba1c ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(w.hba1c, ',', '.')::numeric END > 6.5)
SELECT count(*) FROM o JOIN d USING (patient_id) JOIN staging.result_wide AS w USING (lab_order_id)
WHERE CASE WHEN w.glu ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(w.glu, ',', '.')::numeric END > 126;
\echo == jsonb

WITH o AS (SELECT lab_order_id, patient_id FROM alameda.lab_order WHERE ordered_on >= '2024-01-01' AND ordered_on < '2025-01-01'),
     d AS (SELECT DISTINCT o.patient_id FROM o JOIN staging.result_document AS j USING (lab_order_id)
           WHERE CASE WHEN jsonb_typeof(j.results -> 'hba1c') = 'number' THEN (j.results ->> 'hba1c')::numeric END > 6.5)
SELECT count(*) FROM o JOIN d USING (patient_id) JOIN staging.result_document AS j USING (lab_order_id)
WHERE CASE WHEN jsonb_typeof(j.results -> 'glu') = 'number' THEN (j.results ->> 'glu')::numeric END > 126;
