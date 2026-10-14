-- postgres
-- Una regla nueva en la tabla de rechazos: el mismo código de práctica dos veces en un mes de precios.
DO $$
DECLARE t text;
BEGIN
    FOR t IN SELECT table_name FROM information_schema.tables
             WHERE table_schema = 'legacy' AND table_name ~ '^Precios_[0-9]{4}_[0-9]{2}$' LOOP
        EXECUTE format($q$
            INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
            SELECT '04', 'precios.codigo_repetido_en_el_mes', %L, "CodPractica", string_agg("Valor"::text, ' · '), count(*)::text || ' filas'
            FROM legacy.%I GROUP BY "CodPractica" HAVING count(*) > 1 $q$, t, t);
    END LOOP;
END $$;

INSERT INTO staging.rule_baseline (rule, source_rows, truth_rows)
VALUES ('precios.codigo_repetido_en_el_mes', 280, NULL);

SELECT * FROM staging.rejection_report WHERE "Regla" LIKE 'precios.%';
SELECT source_table, source_key, value FROM staging.rejection WHERE rule = 'precios.codigo_repetido_en_el_mes' AND source_table = 'Precios_2009_12';
