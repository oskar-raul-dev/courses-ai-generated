-- postgres
-- Los precios de 2002 a 2025 como rangos. Un precio vale para una práctica durante un período, y dos
-- precios de la misma práctica no se superponen: lo dice la clave primaria, con WITHOUT OVERLAPS.
-- La fila pegada dos veces en una copia mensual (un 10 % más cara) va a la tabla de rechazos.
CREATE EXTENSION IF NOT EXISTS btree_gist;          -- gist para las columnas escalares de la clave
DELETE FROM staging.rejection WHERE phase = '07';

-- El valor de la unidad bioquímica de cada mes, como lo implican las filas bien cargadas (la mediana
-- de Valor / UB). Tiene un solo rango por mes, y la exclusión con gist es la restricción de debajo de
-- WITHOUT OVERLAPS, escrita a mano.
DROP TABLE IF EXISTS alameda.practice_price, alameda.biochemical_unit;
CREATE TABLE alameda.biochemical_unit (
    valid_during daterange NOT NULL,
    amount       numeric(19, 4) NOT NULL,
    CONSTRAINT biochemical_unit_valid_during_excl EXCLUDE USING gist (valid_during WITH &&)
);
INSERT INTO alameda.biochemical_unit (valid_during, amount)
SELECT daterange(month, (month + interval '1 month')::date),
       round(percentile_cont(0.5) WITHIN GROUP (ORDER BY implied_ub)::numeric, 4)
FROM staging.monthly_price GROUP BY month;

INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '07', 'precios.pegado_dos_veces', 'Precios_' || to_char(m.month, 'YYYY_MM'), m.code, m.amount::text,
       'implica una UB de ' || round(m.implied_ub / u.amount, 3) || ' veces la del mes'
FROM staging.monthly_price AS m
JOIN alameda.biochemical_unit AS u ON u.valid_during @> m.month
WHERE abs(m.implied_ub / u.amount - 1) >= 0.01;

CREATE TABLE alameda.practice_price (
    practice_id  integer NOT NULL REFERENCES alameda.practice (practice_id),
    valid_during daterange NOT NULL,
    amount       numeric(19, 4) NOT NULL,
    CONSTRAINT practice_price_pkey PRIMARY KEY (practice_id, valid_during WITHOUT OVERLAPS)
);
INSERT INTO alameda.practice_price (practice_id, valid_during, amount)
SELECT m.practice_id, daterange(m.month, (m.month + interval '1 month')::date), m.amount
FROM staging.monthly_price AS m
JOIN alameda.biochemical_unit AS u ON u.valid_during @> m.month
WHERE abs(m.implied_ub / u.amount - 1) < 0.01;

INSERT INTO staging.rule_baseline (rule, source_rows, truth_rows)
VALUES ('precios.pegado_dos_veces', (SELECT count(*) FROM staging.monthly_price), NULL)
ON CONFLICT (rule) DO UPDATE SET source_rows = EXCLUDED.source_rows;
