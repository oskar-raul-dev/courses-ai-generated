-- postgres
-- La obra social deja de ser texto: una fila por obra social en el modelo, y una tabla de alias con
-- cada forma en que la recepción la escribió antes de 2012. La regla vive en un solo sitio: esta tabla.
CREATE SCHEMA IF NOT EXISTS alameda;

DROP TABLE IF EXISTS staging.payer_alias;
-- CASCADE: las fases siguientes apuntan a alameda.payer (F06), y sus scripts las vuelven a crear.
DROP TABLE IF EXISTS alameda.payer CASCADE;

CREATE TABLE alameda.payer (
    payer_id   integer PRIMARY KEY,                       -- el IdObraSocial de la caja, que ya era una clave
    payer_code varchar(20) NOT NULL,
    name       varchar(255) NOT NULL,
    tax_id     varchar(13),
    is_active  boolean NOT NULL,
    CONSTRAINT payer_payer_code_key UNIQUE (payer_code),
    CONSTRAINT payer_tax_id_check CHECK (tax_id ~ '^[0-9]{2}-[0-9]{8}-[0-9]$')
);

-- La obra social sin sigla de la caja no entra: un código vacío no identifica a nadie.
INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '04', 'obras_sociales.sin_sigla', 'ObrasSociales', o."IdObraSocial"::text, o."Nombre", 'payer_code NOT NULL'
FROM legacy."ObrasSociales" AS o
WHERE o."Sigla" IS NULL OR o."Sigla" = '';

INSERT INTO alameda.payer (payer_id, payer_code, name, tax_id, is_active)
SELECT o."IdObraSocial", o."Sigla", o."Nombre", o."CUIT", o."Activa"
FROM legacy."ObrasSociales" AS o
WHERE o."Sigla" <> '';

CREATE TABLE staging.payer_alias (
    written_as varchar(255) PRIMARY KEY,
    payer_code varchar(20) NOT NULL REFERENCES alameda.payer (payer_code)
);

INSERT INTO staging.payer_alias (written_as, payer_code) VALUES
    ('APROSS', 'APROSS'), ('apross', 'APROSS'), ('Apross', 'APROSS'), ('A.P.R.O.S.S.', 'APROSS'), ('IPAM', 'APROSS'),
    ('DASPU', 'DASPU'), ('Daspu', 'DASPU'),
    ('GALENO', 'GALENO'), ('Galeno', 'GALENO'),
    ('OSDE', 'OSDE'), ('Osde', 'OSDE'), ('O.S.D.E', 'OSDE'), ('osde 210', 'OSDE'), ('OSDE 310', 'OSDE'),
    ('OSECAC', 'OSECAC'), ('Osecac', 'OSECAC'), ('EMPLEADOS DE COMERCIO', 'OSECAC'),
    ('OSPRERA', 'OSPRERA'), ('Osprera', 'OSPRERA'), ('RURALES', 'OSPRERA'),
    ('PAMI', 'PAMI'), ('pami', 'PAMI'), ('Pami', 'PAMI'), ('P.A.M.I.', 'PAMI'), ('INSSJP', 'PAMI'),
    ('PARTICULAR', 'PARTICULAR'), ('Particular', 'PARTICULAR'), ('PART', 'PARTICULAR'), ('PART.', 'PARTICULAR'),
    ('SANCOR', 'SANCOR'), ('Sancor', 'SANCOR'), ('SANCOR SALUD', 'SANCOR'), ('SANCOR 3000', 'SANCOR'),
    ('SWISS MEDICAL', 'SWISS'), ('Swiss', 'SWISS'), ('SMG', 'SWISS'),
    ('UOM', 'UOM'), ('U.O.M.', 'UOM'), ('Metalurgicos', 'UOM');

-- Los protocolos anteriores a 2012 cuya obra social no se puede resolver con la tabla de alias.
INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '04', 'protocolos.obra_social_sin_resolver', 'Protocolos', p."IdProtocolo"::text, p."ObraSocial",
       CASE WHEN p."ObraSocial" IS NULL THEN 'NULL' WHEN p."ObraSocial" = '' THEN 'cadena vacía' ELSE 'sin alias' END
FROM legacy."Protocolos" AS p
LEFT JOIN staging.payer_alias AS a ON a.written_as = p."ObraSocial"
WHERE p."Fecha" < '2012-01-01' AND a.written_as IS NULL;
