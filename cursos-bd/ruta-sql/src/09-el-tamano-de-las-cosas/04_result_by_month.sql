-- postgres
-- El resultado particionado por mes de carga, como diseño: una partición por mes desde abril de 2008.
-- Las consultas de un mes leen solo su partición (pruning), y un mes viejo se desprende entero.
DROP TABLE IF EXISTS staging.result_by_month;
CREATE TABLE staging.result_by_month (LIKE alameda.result INCLUDING DEFAULTS INCLUDING CONSTRAINTS)
    PARTITION BY RANGE (recorded_at);
DO $$
DECLARE m date;
BEGIN
    FOR m IN SELECT generate_series(date '2008-04-01', date '2026-10-01', interval '1 month')::date LOOP
        EXECUTE format('CREATE TABLE staging.%I PARTITION OF staging.result_by_month FOR VALUES FROM (%L) TO (%L)',
                       'result_' || to_char(m, 'YYYY_MM'), m, (m + interval '1 month')::date);
    END LOOP;
END
$$;
INSERT INTO staging.result_by_month SELECT * FROM alameda.result;
ANALYZE staging.result_by_month;
