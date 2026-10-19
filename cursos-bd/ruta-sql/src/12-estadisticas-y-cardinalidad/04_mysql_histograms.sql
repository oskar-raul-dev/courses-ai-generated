-- mysql
-- Los histogramas de MySQL. Una copia de Protocolos en staging, sin índices secundarios: un histograma solo
-- interviene en columnas sin índice, porque con índice MySQL cuenta en el índice. Se corre con el cliente mysql.
DROP TABLE IF EXISTS staging.protocol_hist;
CREATE TABLE staging.protocol_hist LIKE legacy.Protocolos;
INSERT INTO staging.protocol_hist SELECT * FROM legacy.Protocolos;
ANALYZE TABLE staging.protocol_hist;

SELECT 'sin histograma' AS etapa;
EXPLAIN FORMAT=TREE SELECT count(*) FROM staging.protocol_hist
WHERE Fecha >= '2015-03-10' AND Fecha < '2015-03-11';

ANALYZE TABLE staging.protocol_hist UPDATE HISTOGRAM ON Fecha, Sede WITH 100 BUCKETS;

SELECT 'con histograma' AS etapa;
SELECT column_name, histogram->>'$."histogram-type"' AS kind, JSON_LENGTH(histogram, '$.buckets') AS buckets,
       histogram->>'$."sampling-rate"' AS sampling_rate
FROM information_schema.column_statistics WHERE schema_name = 'staging' AND table_name = 'protocol_hist';
-- las dos mitades del rango por separado, y juntas
EXPLAIN FORMAT=TREE SELECT count(*) FROM staging.protocol_hist WHERE Fecha >= '2015-03-10';
EXPLAIN FORMAT=TREE SELECT count(*) FROM staging.protocol_hist WHERE Fecha < '2015-03-11';
EXPLAIN FORMAT=TREE SELECT count(*) FROM staging.protocol_hist
WHERE Fecha >= '2015-03-10' AND Fecha < '2015-03-11';
EXPLAIN FORMAT=TREE SELECT count(*) FROM staging.protocol_hist WHERE Fecha = '2015-03-10';
SELECT sum(Fecha >= '2015-03-10') AS desde, sum(Fecha < '2015-03-11') AS hasta,
       sum(Fecha >= '2015-03-10' AND Fecha < '2015-03-11') AS el_dia, count(*) AS total
FROM staging.protocol_hist;
EXPLAIN FORMAT=TREE SELECT count(*) FROM staging.protocol_hist WHERE Sede = 'E';
SELECT count(*) FROM staging.protocol_hist WHERE Sede = 'E';

-- el histograma no se actualiza solo, salvo que se pida
ANALYZE TABLE staging.protocol_hist UPDATE HISTOGRAM ON Fecha WITH 100 BUCKETS AUTO UPDATE;
SELECT column_name, histogram->>'$."auto-update"' AS auto_update, histogram->>'$."last-updated"' AS last_updated
FROM information_schema.column_statistics WHERE schema_name = 'staging' AND table_name = 'protocol_hist';
