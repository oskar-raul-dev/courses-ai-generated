\echo == ej1
SELECT count(*) filas, count(DISTINCT payer) obras_sociales, count(DISTINCT practice) practicas, count(DISTINCT site) sedes FROM staging.agreement_raw;
\echo == ej4
SELECT count(*) FILTER (WHERE "Telefono" LIKE '% / %') con_dos_telefonos, count(*) pacientes FROM legacy."Pacientes";
\echo == ej5
SELECT p.description, c.nomenclator_code, c.code FROM alameda.practice_code c JOIN alameda.practice p USING (practice_id) WHERE p.practice_id = 4 ORDER BY 2;
\echo == ej6
SELECT s.site_code, s.name, count(a.*) convenios FROM alameda.site s LEFT JOIN staging.agreement_raw a ON a.site = s.site_code GROUP BY 1, 2 ORDER BY 1;
\echo == ej14
SELECT seed, count(*) ternaria,
  (SELECT count(*) FROM (SELECT pp.payer, pp.practice, ps.site
      FROM (SELECT DISTINCT payer, practice FROM staging.agreement_raw r WHERE ('x' || substr(md5(seed || '/' || payer || '/' || practice || '/' || site), 1, 7))::bit(28)::int % 10 <> 0) pp
      JOIN (SELECT DISTINCT practice, site FROM staging.agreement_raw r WHERE ('x' || substr(md5(seed || '/' || payer || '/' || practice || '/' || site), 1, 7))::bit(28)::int % 10 <> 0) ps USING (practice)
      JOIN (SELECT DISTINCT payer, site FROM staging.agreement_raw r WHERE ('x' || substr(md5(seed || '/' || payer || '/' || practice || '/' || site), 1, 7))::bit(28)::int % 10 <> 0) ys ON ys.payer = pp.payer AND ys.site = ps.site) j) - count(*) espurias
FROM (VALUES ('1996'), ('1997'), ('2026')) v (seed)
JOIN staging.agreement_raw r ON ('x' || substr(md5(seed || '/' || payer || '/' || practice || '/' || site), 1, 7))::bit(28)::int % 10 <> 0
GROUP BY seed ORDER BY seed;
\echo == ej18
CREATE TEMP TABLE agreement_exclusion AS
SELECT payer, practice, site FROM staging.agreement_raw EXCEPT SELECT payer, practice, site FROM staging.agreement_noncyclic;
WITH t AS (SELECT * FROM staging.agreement_noncyclic),
pp AS (SELECT DISTINCT payer, practice FROM t), ps AS (SELECT DISTINCT practice, site FROM t), ys AS (SELECT DISTINCT payer, site FROM t),
v AS (SELECT pp.payer, pp.practice, ps.site FROM pp JOIN ps USING (practice) JOIN ys ON ys.payer = pp.payer AND ys.site = ps.site
      EXCEPT SELECT payer, practice, site FROM agreement_exclusion)
SELECT (SELECT count(*) FROM agreement_exclusion) excepciones, (SELECT count(*) FROM v) vista,
       (SELECT count(*) FROM (SELECT * FROM v EXCEPT SELECT * FROM t) x) espurias, (SELECT count(*) FROM (SELECT * FROM t EXCEPT SELECT * FROM v) x) perdidas;
-- solo las excepciones que hacen falta: las que el join volvería a inventar
WITH t AS (SELECT * FROM staging.agreement_noncyclic),
pp AS (SELECT DISTINCT payer, practice FROM t), ps AS (SELECT DISTINCT practice, site FROM t), ys AS (SELECT DISTINCT payer, site FROM t),
j AS (SELECT pp.payer, pp.practice, ps.site FROM pp JOIN ps USING (practice) JOIN ys ON ys.payer = pp.payer AND ys.site = ps.site)
SELECT count(*) excepciones_necesarias FROM (SELECT * FROM j EXCEPT SELECT * FROM t) x;
