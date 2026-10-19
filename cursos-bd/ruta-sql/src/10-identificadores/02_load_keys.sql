-- postgres
-- Carga las tres tablas de 01_postgres_keys.sql en el orden de llegada de los protocolos. El UUIDv7 se
-- corre a la fecha del protocolo con el argumento de uuidv7(), para que su tiempo sea el del protocolo.
INSERT INTO staging.order_bigint (patient_id, ordered_on, site_code)
SELECT patient_id, ordered_on, site_code FROM alameda.lab_order ORDER BY ordered_on, lab_order_id;
INSERT INTO staging.order_uuid4 (patient_id, ordered_on, site_code)
SELECT patient_id, ordered_on, site_code FROM alameda.lab_order ORDER BY ordered_on, lab_order_id;
INSERT INTO staging.order_uuid7 (order_id, patient_id, ordered_on, site_code)
SELECT uuidv7(ordered_on - now()), patient_id, ordered_on, site_code
FROM alameda.lab_order ORDER BY ordered_on, lab_order_id;
