-- postgres
-- El protocolo del modelo nuevo: la clave de la caja, el paciente que sobrevivió a la fusión de la
-- Fase 05 (un protocolo de una ficha fusionada pasa a la persona), la fecha, la sede y la obra social.
-- Los cuatro modelos de resultado de esta fase llegan a la fecha y al paciente por aquí.
DROP TABLE IF EXISTS alameda.result, alameda.analyte CASCADE;
DROP TABLE IF EXISTS alameda.lab_order CASCADE;
CREATE TABLE alameda.lab_order (
    lab_order_id integer PRIMARY KEY,
    patient_id   integer NOT NULL REFERENCES alameda.patient (patient_id),
    ordered_on   date NOT NULL,
    site_code    char(1) NOT NULL REFERENCES alameda.site (site_code),
    payer_code   varchar(20) REFERENCES alameda.payer (payer_code)
);
INSERT INTO alameda.lab_order (lab_order_id, patient_id, ordered_on, site_code, payer_code)
SELECT o."IdProtocolo", coalesce(p.merged_into_patient_id, p.patient_id), o."Fecha"::date, o."Sede",
       coalesce(y.payer_code, a.payer_code)
FROM legacy."Protocolos" AS o
JOIN alameda.patient AS p ON p.legacy_patient_id = o."IdPaciente"
LEFT JOIN alameda.payer AS y ON y.payer_id = o."IdObraSocial"
LEFT JOIN staging.payer_alias AS a ON a.written_as = o."ObraSocial";
CREATE INDEX lab_order_ordered_on_idx ON alameda.lab_order (ordered_on);
CREATE INDEX lab_order_patient_id_idx ON alameda.lab_order (patient_id);
ANALYZE alameda.lab_order;
