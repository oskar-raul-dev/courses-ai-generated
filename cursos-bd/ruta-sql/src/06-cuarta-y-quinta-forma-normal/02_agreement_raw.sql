-- postgres
-- La planilla de convenios de 2026, tal como la trae la caja: una fila por obra social, práctica
-- (código NBU 2012) y sede. Después de este script se carga con
--   python3 -I 06-cuarta-y-quinta-forma-normal/xlsx_to_csv.py lab/caja/m/planillas/convenios_2026.xlsx \
--     | psql -c "\copy staging.agreement_raw FROM STDIN CSV HEADER"
DROP TABLE IF EXISTS staging.agreement_noncyclic, staging.agreement_raw;
CREATE TABLE staging.agreement_raw (
    payer    varchar(20) NOT NULL,
    practice varchar(20) NOT NULL,
    site     char(1) NOT NULL,
    CONSTRAINT agreement_raw_pkey PRIMARY KEY (payer, practice, site)
);
