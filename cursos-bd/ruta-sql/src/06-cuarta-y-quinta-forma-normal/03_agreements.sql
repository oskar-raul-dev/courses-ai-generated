-- postgres
-- Los convenios de 2026 en quinta forma normal. La regla de Alameda es cíclica: si la obra social
-- cubre la práctica, la sede hace la práctica y la sede atiende a la obra social, el convenio existe.
-- Por eso se guardan los tres hechos binarios, y el convenio es su join.
--
-- Antes: 02_agreement_raw.sql y la carga de la planilla que indica.
CREATE TABLE alameda.payer_practice (
    payer_code  varchar(20) NOT NULL REFERENCES alameda.payer (payer_code),
    practice_id integer NOT NULL REFERENCES alameda.practice (practice_id),
    CONSTRAINT payer_practice_pkey PRIMARY KEY (payer_code, practice_id)
);
CREATE TABLE alameda.practice_site (
    practice_id integer NOT NULL REFERENCES alameda.practice (practice_id),
    site_code   char(1) NOT NULL REFERENCES alameda.site (site_code),
    CONSTRAINT practice_site_pkey PRIMARY KEY (practice_id, site_code)
);
CREATE TABLE alameda.payer_site (
    payer_code varchar(20) NOT NULL REFERENCES alameda.payer (payer_code),
    site_code  char(1) NOT NULL REFERENCES alameda.site (site_code),
    CONSTRAINT payer_site_pkey PRIMARY KEY (payer_code, site_code)
);

INSERT INTO alameda.payer_practice
SELECT DISTINCT a.payer, c.practice_id
FROM staging.agreement_raw AS a
JOIN alameda.practice_code AS c ON c.nomenclator_code = 'NBU2012' AND c.code = a.practice;
INSERT INTO alameda.practice_site
SELECT DISTINCT c.practice_id, a.site
FROM staging.agreement_raw AS a
JOIN alameda.practice_code AS c ON c.nomenclator_code = 'NBU2012' AND c.code = a.practice;
INSERT INTO alameda.payer_site
SELECT DISTINCT a.payer, a.site FROM staging.agreement_raw AS a;

CREATE VIEW alameda.agreement AS
SELECT pp.payer_code, pp.practice_id, ps.site_code
FROM alameda.payer_practice AS pp
JOIN alameda.practice_site AS ps ON ps.practice_id = pp.practice_id
JOIN alameda.payer_site AS ys ON ys.payer_code = pp.payer_code AND ys.site_code = ps.site_code;
