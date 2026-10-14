-- la grilla: cada práctica en cada mes en que existía
CREATE TEMP TABLE grid AS
SELECT m.month, p.practice_id FROM (SELECT DISTINCT month FROM staging.monthly_price) m CROSS JOIN alameda.practice p
WHERE p.practice_id <> 19 OR m.month >= '2020-01-01';
-- el precio correcto: la UB de la práctica por la UB del mes
CREATE TEMP TABLE correct AS
SELECT g.month, g.practice_id, round(p.ub * u.amount, 2) AS amount
FROM grid g JOIN alameda.practice p USING (practice_id) JOIN alameda.biochemical_unit u ON u.valid_during @> g.month;
\echo == la unión de las 280 tablas, consultada por mes
WITH u AS (SELECT g.month, g.practice_id, count(m.*) n, min(m.amount) a, max(m.amount) b FROM grid g LEFT JOIN staging.monthly_price m USING (month, practice_id) GROUP BY 1,2)
SELECT CASE WHEN n = 0 THEN 'sin fila' WHEN n = 1 AND abs(a - c.amount) <= 0.01 * c.amount THEN 'una fila correcta' WHEN n = 1 THEN 'una fila incorrecta' ELSE 'dos filas' END resultado,
       count(*) pares, count(DISTINCT u.month) meses
FROM u JOIN correct c USING (month, practice_id) GROUP BY 1 ORDER BY 1;
\echo == as-of sobre alameda.practice_price
WITH a AS (SELECT g.month, g.practice_id, (SELECT count(*) FROM alameda.practice_price p WHERE p.practice_id = g.practice_id AND p.valid_during @> g.month) n,
                  (SELECT max(amount) FROM alameda.practice_price p WHERE p.practice_id = g.practice_id AND p.valid_during @> g.month) a FROM grid g)
SELECT CASE WHEN n = 0 THEN 'sin fila' WHEN abs(a - c.amount) <= 0.01 * c.amount THEN 'una fila correcta' ELSE 'una fila incorrecta' END resultado,
       count(*) pares, count(DISTINCT a.month) meses
FROM a JOIN correct c USING (month, practice_id) GROUP BY 1 ORDER BY 1;
\echo == meses con algún problema
SELECT count(DISTINCT month) FILTER (WHERE n = 2) meses_con_dos, count(DISTINCT month) FILTER (WHERE n = 0) meses_con_faltante,
       count(DISTINCT month) FILTER (WHERE n <> 1) meses_con_algo
FROM (SELECT g.month, count(m.*) n FROM grid g LEFT JOIN staging.monthly_price m USING (month, practice_id) GROUP BY g.month, g.practice_id) x;
\echo == as-of con la reconstrucción por la UB
SELECT count(*) pares, count(*) FILTER (WHERE abs(coalesce(p.amount, round(pr.ub * u.amount, 2)) - c.amount) <= 0.01 * c.amount) correctos
FROM grid g JOIN correct c USING (month, practice_id) JOIN alameda.practice pr USING (practice_id)
JOIN alameda.biochemical_unit u ON u.valid_during @> g.month
LEFT JOIN alameda.practice_price p ON p.practice_id = g.practice_id AND p.valid_during @> g.month;
\echo == marzo de 2002
SELECT count(*) FROM alameda.practice_price WHERE valid_during @> date '2002-03-15';
SELECT count(*) FROM alameda.biochemical_unit WHERE valid_during @> date '2002-03-15';
