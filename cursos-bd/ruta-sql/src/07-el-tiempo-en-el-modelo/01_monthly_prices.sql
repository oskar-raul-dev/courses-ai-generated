-- postgres
-- Las 280 copias mensuales de Precios en una sola tabla de staging, con el mes como dato. Para cada
-- fila se guarda también el valor de la unidad bioquímica que implica (Valor / UB de la práctica):
-- en un mes, todas las filas bien cargadas implican el mismo valor.
DROP TABLE IF EXISTS staging.monthly_price;
CREATE TABLE staging.monthly_price (
    month       date NOT NULL,
    code        varchar(20) NOT NULL,
    amount      numeric(19, 4) NOT NULL,
    practice_id integer,
    implied_ub  numeric(19, 4)
);

DO $$
DECLARE t record;
BEGIN
    FOR t IN SELECT table_name FROM information_schema.tables
             WHERE table_schema = 'legacy' AND table_name ~ '^Precios_[0-9]{4}_[0-9]{2}$' ORDER BY 1
    LOOP
        EXECUTE format('INSERT INTO staging.monthly_price (month, code, amount)
                        SELECT to_date(%L, ''YYYY_MM''), "CodPractica", "Valor" FROM legacy.%I',
                       substr(t.table_name, 9), t.table_name);
    END LOOP;
END
$$;

-- El código depende del nomenclador del mes: INOS hasta 2005, NBU después (la PCR de COVID solo existe
-- en el NBU 2012).
UPDATE staging.monthly_price AS m SET practice_id = c.practice_id
FROM alameda.practice_code AS c
WHERE c.code = m.code
  AND c.nomenclator_code = CASE WHEN m.month < '2006-01-01' THEN 'INOS'
                                WHEN m.code = '660519' THEN 'NBU2012' ELSE 'NBU' END;
UPDATE staging.monthly_price AS m SET implied_ub = round(m.amount / p.ub, 4)
FROM alameda.practice AS p WHERE p.practice_id = m.practice_id;
CREATE INDEX monthly_price_month_practice_id_idx ON staging.monthly_price (month, practice_id);
ANALYZE staging.monthly_price;
