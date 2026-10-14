\echo == ej3
SELECT valid_during, amount FROM alameda.biochemical_unit WHERE valid_during @> date '2002-09-15' OR valid_during @> date '2009-12-15' ORDER BY 1;
\echo == ej4
BEGIN;
INSERT INTO alameda.practice_price VALUES (2, '[2009-07-15,2009-08-15)', 999);
ROLLBACK;
\echo == ej5
SELECT p.description, x.valid_during, x.amount FROM alameda.practice_price x JOIN alameda.practice p USING (practice_id)
WHERE x.practice_id = 2 AND x.valid_during @> date '2009-07-15';
\echo == ej10
SELECT count(*) filas, count(DISTINCT (payer_code, practice_id, valid_from)) dias, count(DISTINCT (payer_code, practice_id)) combinaciones FROM staging.price_2025 WHERE same_day > 1;
\echo == ej21 cuántas obras sociales y meses
SELECT count(DISTINCT payer_code) obras, count(*) vigencias FROM alameda.agreement_price;
