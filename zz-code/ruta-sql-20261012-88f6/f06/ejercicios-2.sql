\echo == ej17
CREATE OR REPLACE FUNCTION pg_temp.spurious_join_rows(tbl regclass) RETURNS bigint LANGUAGE plpgsql AS $$
DECLARE n bigint;
BEGIN
    EXECUTE format($q$
        WITH pp AS (SELECT DISTINCT payer, practice FROM %1$s),
             ps AS (SELECT DISTINCT practice, site FROM %1$s),
             ys AS (SELECT DISTINCT payer, site FROM %1$s)
        SELECT count(*) FROM (
            SELECT pp.payer, pp.practice, ps.site
            FROM pp JOIN ps USING (practice) JOIN ys ON ys.payer = pp.payer AND ys.site = ps.site
            EXCEPT
            SELECT payer, practice, site FROM %1$s) AS x$q$, tbl) INTO n;
    RETURN n;
END $$;
SELECT 'staging.agreement_raw' AS tabla, pg_temp.spurious_join_rows('staging.agreement_raw') AS espurias
UNION ALL
SELECT 'staging.agreement_noncyclic', pg_temp.spurious_join_rows('staging.agreement_noncyclic');
\echo == ej19
BEGIN;
INSERT INTO alameda.nomenclator VALUES ('NBU2016', 'Nomenclador Bioquímico Único, actualización 2016', '2017-01-01');
INSERT INTO alameda.practice_code (nomenclator_code, code, practice_id)
SELECT 'NBU2016', code, practice_id FROM alameda.practice_code WHERE nomenclator_code = 'NBU2012';
SELECT nomenclator_code, count(*) FROM alameda.practice_code GROUP BY 1 ORDER BY 1;
ROLLBACK;
\echo == ej11
SELECT count(*) filas_en_la_planilla FROM alameda.payer_practice pp JOIN alameda.payer_site ys ON ys.payer_code = pp.payer_code AND ys.site_code = 'V' WHERE pp.practice_id = 20;
