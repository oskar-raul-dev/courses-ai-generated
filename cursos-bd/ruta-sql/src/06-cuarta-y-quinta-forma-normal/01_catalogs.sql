-- postgres
-- El nomenclador como dato y no como columna. Una práctica es una fila; cada nomenclador le da un
-- código; la equivalencia entre dos códigos es tener la misma práctica, y no hace falta otra tabla.
CREATE SCHEMA IF NOT EXISTS alameda;
DROP VIEW IF EXISTS alameda.agreement;
DROP TABLE IF EXISTS alameda.payer_practice, alameda.practice_site, alameda.payer_site;
DROP TABLE IF EXISTS alameda.practice_code, alameda.practice, alameda.nomenclator, alameda.site;

CREATE TABLE alameda.nomenclator (
    nomenclator_code varchar(10) PRIMARY KEY,
    name             varchar(100) NOT NULL,
    valid_from       date NOT NULL
);
INSERT INTO alameda.nomenclator VALUES
    ('INOS', 'Nomenclador del INOS', '1997-01-01'),
    ('NBU', 'Nomenclador Bioquímico Único', '2006-01-01'),
    ('NBU2012', 'Nomenclador Bioquímico Único, versión 2012', '2013-01-01');

CREATE TABLE alameda.practice (
    practice_id integer PRIMARY KEY,
    description varchar(255) NOT NULL,
    ub          numeric(8, 2) NOT NULL
);
INSERT INTO alameda.practice (practice_id, description, ub)
SELECT "IdPractica", "Descripcion", "UB" FROM legacy."Practicas";

CREATE TABLE alameda.practice_code (
    nomenclator_code varchar(10) NOT NULL REFERENCES alameda.nomenclator (nomenclator_code),
    code             varchar(20) NOT NULL,
    practice_id      integer NOT NULL REFERENCES alameda.practice (practice_id),
    CONSTRAINT practice_code_pkey PRIMARY KEY (nomenclator_code, code),
    -- una práctica tiene a lo sumo un código en cada nomenclador
    CONSTRAINT practice_code_nomenclator_code_practice_id_key UNIQUE (nomenclator_code, practice_id)
);
INSERT INTO alameda.practice_code (nomenclator_code, code, practice_id)
SELECT v.nomenclator_code, v.code, p."IdPractica"
FROM legacy."Practicas" AS p
CROSS JOIN LATERAL (VALUES ('INOS', p."CodINOS"), ('NBU', p."CodNBU"), ('NBU2012', p."CodNBU2012"))
     AS v (nomenclator_code, code)
WHERE v.code IS NOT NULL;

CREATE TABLE alameda.site (
    site_code  char(1) PRIMARY KEY,
    name       varchar(100) NOT NULL,
    opened_on  date NOT NULL
);
INSERT INTO alameda.site (site_code, name, opened_on)
SELECT "CodSede", "Nombre", "FechaApertura"::date FROM legacy."Sedes";
