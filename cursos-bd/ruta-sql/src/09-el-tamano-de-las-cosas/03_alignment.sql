-- postgres
-- El orden de las columnas, en dos tablas: alameda.result reordenada (casi todo es de largo variable) y
-- una de protocolos con booleanos entre columnas de 8 bytes, donde el relleno por alineación sí pesa.
DROP TABLE IF EXISTS staging.result_as_is, staging.result_reordered, staging.align_bad, staging.align_good;
CREATE TABLE staging.result_as_is AS SELECT * FROM alameda.result;
CREATE TABLE staging.result_reordered AS
SELECT recorded_at, result_id, lab_order_id, value_numeric, analyte_code, qualifier, value_text, sample_flag
FROM alameda.result;

CREATE TABLE staging.align_bad (is_urgent boolean, lab_order_id bigint, is_signed boolean, patient_id bigint,
                                is_billed boolean, ordered_at timestamp);
CREATE TABLE staging.align_good (lab_order_id bigint, patient_id bigint, ordered_at timestamp,
                                 is_urgent boolean, is_signed boolean, is_billed boolean);
INSERT INTO staging.align_bad
SELECT o.lab_order_id % 7 = 0, o.lab_order_id, true, o.patient_id, o.payer_code IS NOT NULL, o.ordered_on
FROM alameda.lab_order AS o;
INSERT INTO staging.align_good
SELECT lab_order_id, patient_id, ordered_at, is_urgent, is_signed, is_billed FROM staging.align_bad;
VACUUM ANALYZE staging.result_as_is, staging.result_reordered, staging.align_bad, staging.align_good;
