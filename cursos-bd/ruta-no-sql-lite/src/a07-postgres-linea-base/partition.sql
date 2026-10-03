-- Particionado declarativo por rango (a07): las lecturas por mes. Con un rango en el WHERE,
-- el planificador descarta las particiones que no pueden tener filas (partition pruning).
DROP TABLE IF EXISTS reading_p;
CREATE TABLE reading_p (LIKE reading INCLUDING DEFAULTS) PARTITION BY RANGE (ts);
DO $$
DECLARE m date := date '2021-10-01';
BEGIN
  WHILE m < date '2026-10-01' LOOP
    EXECUTE format('CREATE TABLE reading_p_%s PARTITION OF reading_p FOR VALUES FROM (%L) TO (%L)',
                   to_char(m, 'YYYYMM'), m, m + interval '1 month');
    m := m + interval '1 month';
  END LOOP;
END $$;
ALTER TABLE reading_p ADD PRIMARY KEY (aircraft, ts);
INSERT INTO reading_p SELECT * FROM reading;
ANALYZE reading_p;
