-- postgres
-- Un plan fijado envejece con el rango. La consulta del central de 02_join_methods.sql con el nested loop forzado y
-- con el hash join forzado, desde distintas fechas de inicio: el mes, el año, cinco años, catorce y todo. El mejor
-- de tres tiempos de cada uno. Se corre con psql después de 01_generic_plans.sql.
CREATE TEMP TABLE timing (since date, method text, ms numeric);
DO $$
DECLARE d date; m text; t0 timestamptz; i int; best numeric;
BEGIN
  FOREACH d IN ARRAY ARRAY['2026-09-01','2026-01-01','2022-01-01','2012-01-01','1997-01-01']::date[] LOOP
    FOREACH m IN ARRAY ARRAY['nested','hash'] LOOP
      PERFORM set_config('enable_hashjoin', CASE WHEN m='nested' THEN 'off' ELSE 'on' END, true);
      PERFORM set_config('enable_nestloop', CASE WHEN m='hash' THEN 'off' ELSE 'on' END, true);
      PERFORM set_config('enable_mergejoin', 'off', true);
      best := NULL;
      FOR i IN 1..3 LOOP
        t0 := clock_timestamp();
        PERFORM r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id)
          WHERE o.site_code = 'C' AND o.ordered_on >= d GROUP BY r.analyte_code;
        best := least(coalesce(best, 1e9), extract(epoch FROM clock_timestamp() - t0) * 1000);
      END LOOP;
      INSERT INTO timing VALUES (d, m, round(best, 1));
    END LOOP;
  END LOOP;
END $$;
SELECT since, max(ms) FILTER (WHERE method = 'nested') AS nested, max(ms) FILTER (WHERE method = 'hash') AS hash
FROM timing GROUP BY 1 ORDER BY 1 DESC;
SELECT count(*) FILTER (WHERE ordered_on >= '2026-01-01') AS desde_2026, count(*) FILTER (WHERE ordered_on >= '2022-01-01') AS desde_2022,
       count(*) FILTER (WHERE ordered_on >= '2012-01-01') AS desde_2012, count(*) AS todos
FROM staging.order_site WHERE site_code = 'C';
