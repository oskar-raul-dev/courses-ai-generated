-- postgres
-- Fase 25 · el maestro de pacientes del laboratorio contra el del SIH. En Alameda el SIH vive en el Oracle
-- corporativo de Horizonte; en el laboratorio es un esquema `sih` de Postgres, armado desde la verdad del
-- generador con una regla declarada (no está en la caja, y la lección lo dice):
--   · un 35 % de las personas del laboratorio pasó por alguna clínica de la red, y está en el SIH;
--   · el SIH identifica por DNI: quien tenía libreta (LC o LE) figura con el DNI que sacó después, y quien
--     tiene pasaporte, con el pasaporte;
--   · 20.000 personas del SIH nunca se hicieron un análisis en Alameda;
--   · errores de carga del SIH: 0,5 % con día y mes invertidos en la fecha de nacimiento, 0,3 % con un
--     dígito cambiado en el documento.
-- Todo sale de md5 sobre el person_id: el mismo resultado en cada corrida.
DROP SCHEMA IF EXISTS sih CASCADE;
CREATE SCHEMA sih;
CREATE TABLE sih.patient (
    sih_patient_id  integer PRIMARY KEY,
    document_type   varchar(3) NOT NULL,
    document_number varchar(20) NOT NULL,
    birth_date      date NOT NULL,
    sex             char(1) NOT NULL
);

CREATE TEMP TABLE base AS
SELECT p.person_id,
       CASE WHEN p.document_type IN ('LC', 'LE') THEN 'DNI' ELSE p.document_type END AS document_type,
       coalesce(p.later_dni, p.document_number) AS document_number,
       p.birth_date, p.sex,
       ('x' || substr(md5('sih' || p.person_id), 1, 8))::bit(32)::bigint % 1000 AS h
FROM truth.person AS p
WHERE p.document_type IN ('DNI', 'LC', 'LE', 'PAS') AND p.birth_date IS NOT NULL AND p.sex IS NOT NULL;

INSERT INTO sih.patient
SELECT 5000000 + person_id, document_type,
       CASE WHEN h BETWEEN 0 AND 2 AND document_type = 'DNI'           -- 0,3 %: un dígito cambiado
            THEN overlay(document_number PLACING ((substr(document_number, 4, 1)::int + 1) % 10)::text FROM 4 FOR 1)
            ELSE document_number END,
       CASE WHEN h BETWEEN 3 AND 7 AND extract(day FROM birth_date) <= 12   -- 0,5 %: día y mes invertidos
                 AND extract(day FROM birth_date) <> extract(month FROM birth_date)
            THEN make_date(extract(year FROM birth_date)::int, extract(day FROM birth_date)::int,
                           extract(month FROM birth_date)::int)
            ELSE birth_date END,
       sex
FROM base
WHERE h < 350;                                                            -- el 35 % pasó por la red

INSERT INTO sih.patient                                                   -- los que nunca vinieron
SELECT 9000000 + g, 'DNI', (40000000 + g * 7)::text, date '1950-01-01' + (g * 37 % 25000), CASE WHEN g % 2 = 0 THEN 'F' ELSE 'M' END
FROM generate_series(1, 20000) AS g;
ANALYZE sih.patient;

-- El cruce: cada paciente vivo del laboratorio (sin fusionar) con su documento, contra el SIH por tipo y
-- número. Coincide la fecha y el sexo: automático. Coincide el documento y no lo demás: a revisar.
DROP TABLE IF EXISTS staging.patient_sih;
CREATE TABLE staging.patient_sih AS
SELECT p.patient_id, s.sih_patient_id,
       CASE WHEN s.birth_date = p.birth_date AND s.sex = p.sex THEN 'automatico' ELSE 'revisar' END AS status
FROM alameda.patient AS p
JOIN alameda.identity_document AS d ON d.patient_id = p.patient_id AND d.document_type = 'DNI'
JOIN sih.patient AS s ON s.document_type = 'DNI' AND s.document_number = d.number
WHERE p.merged_into_patient_id IS NULL;

-- Lo que dice el cruce, y lo que dice la verdad del cruce.
WITH v AS (
    SELECT x.status, tp.person_id = s.sih_patient_id - 5000000 AS correcto
    FROM staging.patient_sih AS x
    JOIN alameda.patient AS p USING (patient_id)
    JOIN truth.patient_record AS tp ON tp.legacy_patient_id = p.legacy_patient_id
    JOIN sih.patient AS s USING (sih_patient_id))
SELECT status AS "Estado", count(*) AS "Pares", count(*) FILTER (WHERE correcto) AS "Correctos según la verdad",
       count(*) FILTER (WHERE NOT correcto) AS "Incorrectos"
FROM v GROUP BY ROLLUP (status) ORDER BY status NULLS LAST;

-- Lo que quedó sin pareja, y cuántos de esos sí están en el SIH según la verdad.
WITH lab AS (
    SELECT p.patient_id, tp.person_id
    FROM alameda.patient AS p JOIN truth.patient_record AS tp ON tp.legacy_patient_id = p.legacy_patient_id
    WHERE p.merged_into_patient_id IS NULL
      AND NOT EXISTS (SELECT 1 FROM staging.patient_sih AS x WHERE x.patient_id = p.patient_id))
SELECT count(*) AS "Pacientes del laboratorio sin pareja",
       count(*) FILTER (WHERE EXISTS (SELECT 1 FROM sih.patient AS s WHERE s.sih_patient_id = 5000000 + lab.person_id))
           AS "De esos, en el SIH según la verdad",
       (SELECT count(*) FROM sih.patient AS s
         WHERE NOT EXISTS (SELECT 1 FROM staging.patient_sih AS x WHERE x.sih_patient_id = s.sih_patient_id))
           AS "Pacientes del SIH sin pareja"
FROM lab;

-- Por qué no casan, según la verdad: lo que es del SIH y lo que es del propio laboratorio.
SELECT CASE WHEN p.sex IS NULL THEN 'laboratorio: sin sexo'
            WHEN s.sex <> p.sex THEN 'sexo distinto'
            WHEN p.birth_date IS NULL THEN 'laboratorio: sin fecha de nacimiento'
            WHEN p.birth_date = tr.birth_date AND s.birth_date <> tr.birth_date THEN 'SIH: otra fecha (día y mes invertidos, u otra persona)'
            WHEN p.birth_date <> tr.birth_date THEN 'laboratorio: fecha distinta de la verdad'
            ELSE 'otra' END AS "A revisar, por qué",
       count(*) FILTER (WHERE tp.person_id = s.sih_patient_id - 5000000) AS "Misma persona",
       count(*) FILTER (WHERE tp.person_id <> s.sih_patient_id - 5000000) AS "Otra persona"
FROM staging.patient_sih AS x
JOIN alameda.patient AS p USING (patient_id)
JOIN sih.patient AS s USING (sih_patient_id)
JOIN truth.patient_record AS tp ON tp.legacy_patient_id = p.legacy_patient_id
JOIN truth.person AS tr ON tr.person_id = tp.person_id
WHERE x.status = 'revisar'
GROUP BY 1 ORDER BY 2 DESC;

WITH lab AS (
    SELECT p.patient_id, tp.person_id
    FROM alameda.patient AS p JOIN truth.patient_record AS tp ON tp.legacy_patient_id = p.legacy_patient_id
    WHERE p.merged_into_patient_id IS NULL
      AND NOT EXISTS (SELECT 1 FROM staging.patient_sih AS x WHERE x.patient_id = p.patient_id)
      AND EXISTS (SELECT 1 FROM sih.patient AS s WHERE s.sih_patient_id = 5000000 + tp.person_id))
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM alameda.identity_document AS d WHERE d.patient_id = lab.patient_id)
                 THEN 'laboratorio: la ficha no tiene documento'
            WHEN EXISTS (SELECT 1 FROM alameda.identity_document AS d
                         WHERE d.patient_id = lab.patient_id AND d.document_type IN ('LC', 'LE'))
                 THEN 'laboratorio: libreta; SIH: el DNI que sacó después'
            WHEN tr.document_type = 'PAS' THEN 'pasaporte'
            ELSE 'número distinto' END AS "En el SIH y sin pareja, por qué",
       count(*) AS "Pacientes"
FROM lab JOIN truth.person AS tr ON tr.person_id = lab.person_id
GROUP BY 1 ORDER BY 2 DESC;

-- La reconciliación entre motores. El cruce se copia al SIH (en Alameda, una tabla del Oracle que lee la
-- internación), y desde ese momento hay dos copias que pueden divergir. No se puede hacer un JOIN entre
-- motores: cada lado calcula, por su cuenta, una huella por cubeta (los dos últimos dígitos del id del
-- SIH), y solo se comparan las cubetas. Una cubeta distinta se baja a filas; las demás, no.
DROP TABLE IF EXISTS sih.lab_link;
CREATE TABLE sih.lab_link AS SELECT sih_patient_id, patient_id, status FROM staging.patient_sih;
-- Alguien de la internación "corrige" tres filas del lado del SIH.
UPDATE sih.lab_link SET status = 'automatico'
WHERE sih_patient_id IN (SELECT sih_patient_id FROM sih.lab_link WHERE status = 'revisar' ORDER BY 1 LIMIT 3);

CREATE TEMP TABLE huella_lab AS                                       -- corre en el motor del laboratorio
SELECT sih_patient_id % 100 AS cubeta, count(*) AS filas,
       md5(string_agg(sih_patient_id || '|' || patient_id || '|' || status, ',' ORDER BY sih_patient_id)) AS huella
FROM staging.patient_sih GROUP BY 1;
CREATE TEMP TABLE huella_sih AS                                       -- corre en el Oracle del SIH
SELECT sih_patient_id % 100 AS cubeta, count(*) AS filas,
       md5(string_agg(sih_patient_id || '|' || patient_id || '|' || status, ',' ORDER BY sih_patient_id)) AS huella
FROM sih.lab_link GROUP BY 1;

SELECT count(*) AS "Cubetas", count(*) FILTER (WHERE l.huella IS DISTINCT FROM s.huella) AS "Cubetas distintas",
       sum(l.filas) AS "Filas detrás de las cubetas",
       sum(l.filas) FILTER (WHERE l.huella IS DISTINCT FROM s.huella) AS "Filas que hay que bajar"
FROM huella_lab AS l FULL JOIN huella_sih AS s USING (cubeta);

SELECT l.sih_patient_id, l.patient_id, l.status AS "En el laboratorio", s.status AS "En el SIH"
FROM staging.patient_sih AS l JOIN sih.lab_link AS s USING (sih_patient_id)
WHERE l.sih_patient_id % 100 IN (SELECT cubeta FROM huella_lab AS a JOIN huella_sih AS b USING (cubeta)
                                 WHERE a.huella <> b.huella)
  AND (l.patient_id, l.status) IS DISTINCT FROM (s.patient_id, s.status)
ORDER BY 1;
