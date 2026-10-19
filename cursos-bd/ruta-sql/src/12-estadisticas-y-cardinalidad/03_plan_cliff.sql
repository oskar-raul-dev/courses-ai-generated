-- postgres
-- El precipicio del plan. Un filtro por rango de fechas sobre staging.result_as_is (los resultados en el orden
-- en que los dejó el sistema viejo: recorded_at tiene correlación 0,06 con el orden físico), con un B-tree en
-- recorded_at. Se barre el ancho del rango y, para cada ancho, se mide lo que elige el optimizador y lo que
-- tarda cada uno de los tres métodos de acceso forzados. Cada medición corre una vez para calentar y tres veces
-- más, y se queda la mediana.
-- Se corre con psql; el barrido entero tarda unos minutos.
-- el BRIN de la Fase 11 sobre esta misma columna se quita: con la tabla desordenada lee casi todo, y el barrido
-- compara los tres métodos sobre el B-tree
DROP INDEX IF EXISTS staging.result_as_is_recorded_at_brin;
CREATE INDEX IF NOT EXISTS result_as_is_recorded_at_idx ON staging.result_as_is (recorded_at);
ANALYZE staging.result_as_is;

DROP TABLE IF EXISTS staging.plan_cliff;
CREATE TABLE staging.plan_cliff (
  width       interval NOT NULL,
  method      text     NOT NULL,   -- 'elegido', 'index', 'bitmap', 'seq'
  scan_node   text     NOT NULL,
  est_rows    bigint   NOT NULL,
  actual_rows bigint   NOT NULL,
  ms          numeric  NOT NULL,
  PRIMARY KEY (width, method)
);

CREATE OR REPLACE FUNCTION staging.measure_cliff(p_width interval, p_method text) RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
  q    text := format('SELECT count(*), avg(value_numeric) FROM staging.result_as_is '
                      'WHERE recorded_at >= %L AND recorded_at < %L',
                      timestamp '2015-01-01', timestamp '2015-01-01' + p_width);
  plan jsonb;
  est  jsonb;
  actual bigint;
  times numeric[] := '{}';
BEGIN
  -- set_config(..., true) vale hasta el final de la transacción, y el DO de abajo es una sola transacción:
  -- cada llamada vuelve a prender los tres métodos antes de apagar los que corresponden
  PERFORM set_config('enable_seqscan', 'on', true), set_config('enable_indexscan', 'on', true),
          set_config('enable_bitmapscan', 'on', true);
  IF p_method = 'index'  THEN PERFORM set_config('enable_seqscan', 'off', true), set_config('enable_bitmapscan', 'off', true); END IF;
  IF p_method = 'bitmap' THEN PERFORM set_config('enable_seqscan', 'off', true), set_config('enable_indexscan', 'off', true); END IF;
  IF p_method = 'seq'    THEN PERFORM set_config('enable_indexscan', 'off', true), set_config('enable_bitmapscan', 'off', true); END IF;
  EXECUTE 'EXPLAIN (FORMAT JSON) ' || replace(q, 'count(*), avg(value_numeric)', 'value_numeric') INTO est;
  EXECUTE q INTO actual;   -- la primera, para calentar; count(*) es la columna que queda
  EXECUTE 'EXPLAIN (ANALYZE, TIMING OFF, FORMAT JSON) ' || q INTO plan;
  FOR i IN 1..3 LOOP
    EXECUTE 'EXPLAIN (ANALYZE, TIMING OFF, FORMAT JSON) ' || q INTO plan;
    times := times || (plan #>> '{0,Execution Time}')::numeric;
  END LOOP;
  INSERT INTO staging.plan_cliff VALUES (
    p_width, p_method,
    jsonb_path_query_first(plan, '$[0].Plan.** ? (@."Node Type" like_regex "Scan$")."Node Type"') #>> '{}',
    (jsonb_path_query_first(est, '$[0].Plan."Plan Rows"') #>> '{}')::bigint,
    actual,
    round((SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY t) FROM unnest(times) t)::numeric, 1));
END $$;

DO $$
DECLARE
  w interval;
  m text;
BEGIN
  FOREACH w IN ARRAY ARRAY['1 day','1 week','1 month','2 months','3 months','6 months',
                            '1 year','2 years','4 years','6 years','10 years']::interval[] LOOP
    FOREACH m IN ARRAY ARRAY['elegido','index','bitmap','seq'] LOOP
      PERFORM staging.measure_cliff(w, m);
    END LOOP;
  END LOOP;
END $$;

SELECT width, max(scan_node) FILTER (WHERE method = 'elegido') AS elegido,
       max(est_rows) FILTER (WHERE method = 'elegido') AS estimadas,
       max(actual_rows) AS reales,
       max(ms) FILTER (WHERE method = 'index')  AS index_ms,
       max(ms) FILTER (WHERE method = 'bitmap') AS bitmap_ms,
       max(ms) FILTER (WHERE method = 'seq')    AS seq_ms,
       max(ms) FILTER (WHERE method = 'elegido') AS elegido_ms
FROM staging.plan_cliff GROUP BY width ORDER BY width;
