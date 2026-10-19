-- postgres
-- Turnos.csv tal cual llega, y su campo multivalor convertido en una fila por examen. La tabla de
-- turnos es otra fase; aquí solo se separa lo que la 1FN pide separar.
DROP TABLE IF EXISTS staging.appointment_exam;
DROP TABLE IF EXISTS staging.appointment_raw;

CREATE TABLE staging.appointment_raw (
    "IdTurno" integer PRIMARY KEY, "Fecha" text, "Hora" text, "Paciente" text, "Telefono" text,
    "ExamenesSolicitados" text, "Estado" text, "Observaciones" text
);
COPY staging.appointment_raw FROM '/caja/m/turnos/Turnos.csv' WITH (FORMAT csv, HEADER true);

CREATE TABLE staging.appointment_exam (
    appointment_id integer NOT NULL REFERENCES staging.appointment_raw ("IdTurno"),
    exam_code      varchar(10) NOT NULL,
    CONSTRAINT appointment_exam_pkey PRIMARY KEY (appointment_id, exam_code)
);
INSERT INTO staging.appointment_exam (appointment_id, exam_code)
SELECT t."IdTurno", e.exam_code
FROM staging.appointment_raw AS t
CROSS JOIN LATERAL string_to_table(t."ExamenesSolicitados", ';') AS e (exam_code);

SELECT count(DISTINCT appointment_id) AS turnos, count(*) AS examenes FROM staging.appointment_exam;
SELECT count(*) AS turnos_con_pcr FROM staging.appointment_exam WHERE exam_code = 'PCR';
