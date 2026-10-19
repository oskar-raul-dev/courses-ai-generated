# ✅ Soluciones — Fase 07: El tiempo en el modelo

> **Curso:** Ruta SQL · Solucionario de la [Fase 07](../07-el-tiempo-en-el-modelo.md)
> **Ejercicios:** 24 · **Perfil:** M · **Motores:** Postgres y MySQL de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todas las soluciones suponen M cargado en Postgres y los scripts de F04, F05, F06 y F07 corridos en orden (F07
usa `alameda.payer`, `alameda.practice`, `alameda.practice_code` y `alameda.patient`).

---

## 🟢 Fácil (1–7)

### Ejercicio 1

**Enunciado (resumen):** las 280 tablas en el catálogo.

**Solución.**

```sql
-- postgres
SELECT count(*) AS tablas, pg_size_pretty(sum(pg_total_relation_size(c.oid))) AS tamano, sum(c.reltuples)::bigint AS filas
FROM pg_class AS c JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE n.nspname = 'legacy' AND c.relname ~ '^Precios_[0-9]{4}_[0-9]{2}$';
```

```text
 tablas | tamano  | filas
--------+---------+-------
    280 | 2240 kB | 20554
(1 row)
```

`reltuples` es una estimación, pero en tablas chicas recién analizadas coincide con el conteo: las 20.554 son
las que `01_monthly_prices.sql` junta en `staging.monthly_price`.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-1--las-280-tablas)

### Ejercicio 2

**Enunciado (resumen):** filas por práctica y mes.

**Solución.**

```sql
-- postgres
WITH grid AS (SELECT m.month, p.practice_id
              FROM (SELECT DISTINCT month FROM staging.monthly_price) AS m CROSS JOIN alameda.practice AS p
              WHERE p.practice_id <> 19 OR m.month >= '2020-01-01'),
     c AS (SELECT g.month, g.practice_id, count(x.*) AS n
           FROM grid AS g LEFT JOIN staging.monthly_price AS x USING (month, practice_id) GROUP BY 1, 2)
SELECT n AS filas_en_el_mes, count(*) AS pares_mes_practica, count(DISTINCT month) AS meses
FROM c GROUP BY 1 ORDER BY 1;
```

```text
 filas_en_el_mes | pares_mes_practica | meses
-----------------+--------------------+-------
               0 |                425 |   219
               1 |              20180 |   280
               2 |                187 |   131
(3 rows)
```

La práctica 19 es la PCR de COVID, que no existe antes de 2020; sin esa condición, la grilla contaría como
faltantes 208 meses en que la práctica no existía.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-2--una-dos-o-ninguna)

### Ejercicio 3

**Enunciado (resumen):** la UB de dos meses.

**Solución.**

```sql
-- postgres
SELECT valid_during, amount FROM alameda.biochemical_unit
WHERE valid_during @> date '2002-09-15' OR valid_during @> date '2009-12-15' ORDER BY 1;
```

```text
      valid_during       | amount
-------------------------+--------
 [2002-09-01,2002-10-01) | 1.2000
 [2009-12-01,2010-01-01) | 3.9427
(2 rows)
```

Cada valor es la mediana de `Valor / UB` de las filas de ese mes. La mediana, y no el promedio, porque las
filas pegadas dos veces (un 10 % más caras) son pocas y la mediana no se mueve por ellas.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-3--la-unidad-bioquímica-de-un-mes)

### Ejercicio 4

**Enunciado (resumen):** un precio que se superpone.

**Solución.**

```sql
-- postgres
BEGIN;
INSERT INTO alameda.practice_price VALUES (2, '[2009-07-15,2009-08-15)', 999);
ROLLBACK;
```

```text
ERROR:  conflicting key value violates exclusion constraint "practice_price_pkey"
DETAIL:  Key (practice_id, valid_during)=(2, [2009-07-15,2009-08-15)) conflicts with existing key (practice_id, valid_during)=(2, [2009-07-01,2009-08-01)).
```

`WITHOUT OVERLAPS` se implementa como una restricción de exclusión, y el mensaje lo dice así aunque la
restricción se haya declarado como clave primaria.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-4--un-precio-que-se-superpone)

### Ejercicio 5

**Enunciado (resumen):** el precio de la glucemia el 15 de julio de 2009.

**Solución.**

```sql
-- postgres
SELECT p.description, x.valid_during, x.amount
FROM alameda.practice_price AS x JOIN alameda.practice AS p USING (practice_id)
WHERE x.practice_id = 2 AND x.valid_during @> date '2009-07-15';
```

```text
 description |      valid_during       | amount
-------------+-------------------------+--------
 GLUCEMIA    | [2009-07-01,2009-08-01) | 7.3400
(1 row)
```

El rango es semiabierto: incluye el 1 de julio y excluye el 1 de agosto, y por eso dos meses seguidos no se
superponen.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-5--as-of)

### Ejercicio 6

**Enunciado (resumen):** la pregunta de Norma.

**Solución.** Después de `05_result_history.sql`:

```sql
-- postgres
SET application_name = 'lucia2';
UPDATE staging.result_item_current SET value_text = '156' WHERE result_item_id = 12123358;
SET application_name = 'norma';
UPDATE staging.result_item_current SET value_text = '165' WHERE result_item_id = 12123358;
RESET application_name;

SELECT h.value_text AS decia, h.recorded_by AS lo_cargo, h.replaced_by AS lo_cambio,
       upper(h.system_during) AS cuando
FROM staging.result_item_history AS h WHERE h.result_item_id = 12123358
UNION ALL
SELECT c.value_text, c.recorded_by, NULL, NULL
FROM staging.result_item_current AS c WHERE c.result_item_id = 12123358
ORDER BY cuando NULLS LAST;
```

```text
 decia |   lo_cargo   | lo_cambio |            cuando
-------+--------------+-----------+-------------------------------
 165   | carga-legacy | lucia2    | 2026-10-14 05:15:15.218698+00
 156   | lucia2       | norma     | 2026-10-14 05:15:16.227524+00
 165   | norma        |           |
(3 rows)
```

Las horas van a ser las de tu corrida. El disparador usa `clock_timestamp()` y no `now()`: dentro de una
transacción, `now()` es la hora de su comienzo, y dos correcciones en la misma transacción tendrían la misma.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-6--la-pregunta-de-norma)

### Ejercicio 7

**Enunciado (resumen):** `WITHOUT OVERLAPS` en MySQL.

**Solución.**

```sql
-- mysql
CREATE TABLE practice_price (practice_id int, valid_from date, valid_to date, amount decimal(19,4),
                             PRIMARY KEY (practice_id, valid_from, valid_to WITHOUT OVERLAPS));
```

```text
ERROR 1064 (42000) at line 4: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'WITHOUT OVERLAPS))' at line 1
```

MySQL 9.7 no tiene la sintaxis ni tipos de rango. En su lugar: dos columnas, un `CHECK (valid_from <
valid_to)`, y un disparador que rechaza la superposición (ejercicio 20).

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-7--without-overlaps-en-mysql)

---

## 🟡 Intermedio (8–14)

### Ejercicio 8

**Enunciado (resumen):** clasificar las filas por la UB que implican.

**Solución.**

```sql
-- postgres
WITH ub AS (SELECT month, percentile_cont(0.5) WITHIN GROUP (ORDER BY implied_ub) AS ub
            FROM staging.monthly_price GROUP BY 1)
SELECT count(*) AS filas,
       count(*) FILTER (WHERE abs(m.implied_ub / ub.ub - 1) < 0.01) AS coherentes,
       count(*) FILTER (WHERE abs(m.implied_ub / ub.ub - 1) >= 0.01) AS incoherentes,
       min(m.implied_ub / ub.ub) FILTER (WHERE abs(m.implied_ub / ub.ub - 1) >= 0.01),
       max(m.implied_ub / ub.ub) FILTER (WHERE abs(m.implied_ub / ub.ub - 1) >= 0.01)
FROM staging.monthly_price AS m JOIN ub USING (month);
```

```text
 filas | coherentes | incoherentes |        min        |        max
-------+------------+--------------+-------------------+--------------------
 20554 |      20367 |          187 | 1.099247220384894 | 1.1008005822416302
(1 row)
```

Y en cada par duplicado hay exactamente una fila coherente:

```text
 n | ok | count
---+----+-------
 2 |  1 |   187
(1 row)
```

La tolerancia del 1 % separa el redondeo a centavos (que mueve la UB implicada unas milésimas) del 10 % de la
fila pegada.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-8--las-filas-pegadas-dos-veces)

### Ejercicio 9

**Enunciado (resumen):** la vigencia sin fin contra la clave.

**Solución.**

```sql
-- postgres
BEGIN;
TRUNCATE alameda.agreement_price CASCADE;
INSERT INTO alameda.agreement_price (payer_code, practice_id, valid_during, amount)
SELECT y.payer_code, c.practice_id, daterange(x."VigenciaDesde"::date, NULL), x."Valor"
FROM legacy."Precios" AS x
JOIN alameda.payer AS y ON y.payer_id = x."IdObraSocial"
JOIN alameda.practice_code AS c ON c.nomenclator_code = 'NBU2012' AND c.code = x."CodPractica";
ROLLBACK;
```

```text
NOTICE:  truncate cascades to table "billed_practice"
TRUNCATE TABLE
ERROR:  conflicting key value violates exclusion constraint "agreement_price_pkey"
DETAIL:  Key (payer_code, practice_id, valid_during)=(PAMI, 1, [2025-05-01,)) conflicts with existing key (payer_code, practice_id, valid_during)=(PAMI, 1, [2025-01-01,)).
```

`[2025-01-01,)` llega hasta el infinito, y `[2025-05-01,)` empieza adentro. Toda vigencia sin fin se superpone
con todas las que vienen después, así que falla la segunda de cualquier combinación.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-9--la-vigencia-sin-fin)

### Ejercicio 10

**Enunciado (resumen):** vigencias del mismo día.

**Solución.**

```sql
-- postgres
SELECT count(*) AS filas, count(DISTINCT (payer_code, practice_id, valid_from)) AS dias,
       count(DISTINCT (payer_code, practice_id)) AS combinaciones
FROM staging.price_2025 WHERE same_day > 1;
```

```text
 filas | dias | combinaciones
-------+------+---------------
   380 |  190 |           172
(1 row)
```

Cada día duplicado tiene dos filas, y algunas combinaciones tienen más de un día duplicado. Las 380 van a
`precios.vigencia_duplicada`.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-10--el-día-duplicado)

### Ejercicio 11

**Enunciado (resumen):** exclusión contra `WITHOUT OVERLAPS`, con el fin calculado.

**Solución.**

```sql
-- postgres
BEGIN;
CREATE TEMP TABLE ap (payer_code varchar(20), practice_id int, valid_during daterange, amount numeric,
  EXCLUDE USING gist (payer_code WITH =, practice_id WITH =, valid_during WITH &&));
INSERT INTO ap SELECT payer_code, practice_id, daterange(valid_from, valid_to), amount FROM staging.price_2025;
SELECT count(*) AS filas, count(*) FILTER (WHERE isempty(valid_during)) AS vacias FROM ap;
ROLLBACK;

BEGIN;
TRUNCATE alameda.agreement_price CASCADE;
INSERT INTO alameda.agreement_price (payer_code, practice_id, valid_during, amount)
SELECT payer_code, practice_id, daterange(valid_from, valid_to), amount FROM staging.price_2025;
ROLLBACK;
```

```text
INSERT 0 6878
 filas | vacias
-------+--------
  6878 |    190
(1 row)

ERROR:  empty WITHOUT OVERLAPS value found in column "valid_during" in relation "agreement_price"
```

Las 190 vacías son la primera fila de cada día duplicado: `lead()` le da como fin el comienzo de la segunda,
que es el mismo día. La exclusión las acepta porque un rango vacío no se superpone con nada; `WITHOUT OVERLAPS`
las rechaza.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-11--la-exclusión-que-deja-pasar)

### Ejercicio 12

**Enunciado (resumen):** la clave foránea con período y lo que deja afuera.

**Solución.** Después de `04_billed_practice.sql`:

```sql
-- postgres
WITH r AS (SELECT split_part(value, ' ', 1) AS payer, split_part(value, ' ', 2)::int AS practice_id,
                  split_part(value, ' ', 3)::date AS d
           FROM staging.rejection WHERE rule = 'facturacion.practica_sin_precio_vigente'),
     first AS (SELECT payer_code, practice_id, min(valid_from) AS f FROM staging.price_2025 GROUP BY 1, 2)
SELECT CASE WHEN f.f IS NULL THEN 'sin ninguna vigencia'
            WHEN r.d < f.f THEN 'antes de la primera vigencia'
            WHEN EXISTS (SELECT 1 FROM staging.price_2025 AS p
                         WHERE p.payer_code = r.payer AND p.practice_id = r.practice_id AND p.same_day > 1
                           AND p.valid_from <= r.d AND (p.valid_to IS NULL OR p.valid_to > r.d))
                 THEN 'en el período de una vigencia duplicada'
            ELSE 'otra' END AS motivo,
       count(*)
FROM r LEFT JOIN first AS f ON f.payer_code = r.payer AND f.practice_id = r.practice_id
GROUP BY 1 ORDER BY 2 DESC;
```

```text
                 motivo                  | count
-----------------------------------------+-------
 en el período de una vigencia duplicada | 73855
 antes de la primera vigencia            | 35641
(2 rows)
```

Las de antes de la primera vigencia no son un error de la tabla de 2025: son prácticas de enero de 2025 de
combinaciones cuya primera vigencia empieza en febrero. Su precio, si existe, está en las copias mensuales, que no
son por obra social (ejercicio 21).

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-12--la-clave-foránea-con-período)

### Ejercicio 13

**Enunciado (resumen):** lo que vale la duda.

**Solución.**

```sql
-- postgres
WITH d AS (SELECT payer_code, practice_id, valid_from, max(valid_to) AS valid_to, bool_or(valid_to IS NULL) AS abierta,
                  min(amount) AS lo, max(amount) AS hi
           FROM staging.price_2025 WHERE same_day > 1 GROUP BY 1, 2, 3)
SELECT count(*) AS practicas, round(sum(d.hi - d.lo)) AS diferencia_en_pesos,
       round(avg((d.hi / d.lo - 1) * 100), 1) AS pct
FROM staging.rejection AS r
JOIN d ON d.payer_code = split_part(r.value, ' ', 1) AND d.practice_id = split_part(r.value, ' ', 2)::int
      AND split_part(r.value, ' ', 3)::date >= d.valid_from
      AND (d.abierta OR split_part(r.value, ' ', 3)::date < d.valid_to)
WHERE r.rule = 'facturacion.practica_sin_precio_vigente';
```

```text
 practicas | diferencia_en_pesos | pct
-----------+---------------------+-----
     73855 |            60958377 |  4.0
(1 row)
```

La trampa del ejercicio es agrupar también por `valid_to`: las dos filas del día duplicado tienen fines distintos
(la primera termina ese mismo día), y agrupadas por fin no se encuentran nunca. Agrupando así, la diferencia da
cero.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-13--lo-que-vale-la-duda)

### Ejercicio 14

**Enunciado (resumen):** marzo de 2002.

**Solución.**

```sql
-- postgres
SELECT count(*) FROM alameda.practice_price WHERE valid_during @> date '2002-03-15';
SELECT count(*) FROM alameda.biochemical_unit WHERE valid_during @> date '2002-03-15';
```

```text
 count
-------
     0
(1 row)

 count
-------
     0
(1 row)
```

La primera copia es de septiembre de 2002: marzo se perdió antes de que existiera la costumbre de copiar, y
Rubén lo reconstruyó en papel. El modelo no tiene de dónde sacarlo, y cero filas dice exactamente eso. Un precio
"aproximado" sería peor: parecería un dato.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-14--marzo-de-2002)

---

## 🟠 Difícil (15–20)

### Ejercicio 15

**Enunciado (resumen):** la apuesta, mes por mes.

**Solución.**

```sql
-- postgres
CREATE TEMP TABLE grid AS
SELECT m.month, p.practice_id FROM (SELECT DISTINCT month FROM staging.monthly_price) AS m CROSS JOIN alameda.practice AS p
WHERE p.practice_id <> 19 OR m.month >= '2020-01-01';
CREATE TEMP TABLE correct AS
SELECT g.month, g.practice_id, round(p.ub * u.amount, 2) AS amount
FROM grid AS g JOIN alameda.practice AS p USING (practice_id)
JOIN alameda.biochemical_unit AS u ON u.valid_during @> g.month;

-- la unión de las copias
WITH u AS (SELECT g.month, g.practice_id, count(m.*) AS n, min(m.amount) AS a
           FROM grid AS g LEFT JOIN staging.monthly_price AS m USING (month, practice_id) GROUP BY 1, 2)
SELECT CASE WHEN n = 0 THEN 'sin fila' WHEN n = 1 AND abs(a - c.amount) <= 0.01 * c.amount THEN 'una fila correcta'
            WHEN n = 1 THEN 'una fila incorrecta' ELSE 'dos filas' END AS resultado,
       count(*) AS pares, count(DISTINCT u.month) AS meses
FROM u JOIN correct AS c USING (month, practice_id) GROUP BY 1 ORDER BY 1;

-- la consulta as-of sobre los rangos
WITH a AS (SELECT g.month, g.practice_id,
                  (SELECT count(*) FROM alameda.practice_price AS p WHERE p.practice_id = g.practice_id AND p.valid_during @> g.month) AS n,
                  (SELECT max(amount) FROM alameda.practice_price AS p WHERE p.practice_id = g.practice_id AND p.valid_during @> g.month) AS a
           FROM grid AS g)
SELECT CASE WHEN n = 0 THEN 'sin fila' WHEN abs(a - c.amount) <= 0.01 * c.amount THEN 'una fila correcta'
            ELSE 'una fila incorrecta' END AS resultado,
       count(*) AS pares, count(DISTINCT a.month) AS meses
FROM a JOIN correct AS c USING (month, practice_id) GROUP BY 1 ORDER BY 1;
```

```text
     resultado     | pares | meses
-------------------+-------+-------
 dos filas         |   187 |   131
 sin fila          |   425 |   219
 una fila correcta | 20180 |   280
(3 rows)

     resultado     | pares | meses
-------------------+-------+-------
 sin fila          |   425 |   219
 una fila correcta | 20367 |   280
(2 rows)
```

La unión falla en 248 meses (131 con dos filas, 219 con alguna faltante; algunos tienen las dos cosas). Los
rangos arreglan los 131 y no los 219.

**Rúbrica.** Una respuesta correcta tiene que:
- definir "correcto" sin usar la misma fila que se evalúa (aquí, la UB del mes por la de la práctica);
- separar los dos defectos, y decir cuál arregla el modelo y cuál no.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-15--la-apuesta-mes-por-mes)

### Ejercicio 16

**Enunciado (resumen):** completar con la UB del mes.

**Solución de referencia.**

```sql
-- postgres
SELECT count(*) AS pares,
       count(*) FILTER (WHERE abs(coalesce(p.amount, round(pr.ub * u.amount, 2)) - c.amount) <= 0.01 * c.amount) AS correctos
FROM grid AS g JOIN correct AS c USING (month, practice_id) JOIN alameda.practice AS pr USING (practice_id)
JOIN alameda.biochemical_unit AS u ON u.valid_during @> g.month
LEFT JOIN alameda.practice_price AS p ON p.practice_id = g.practice_id AND p.valid_during @> g.month;
```

```text
 pares | correctos
-------+-----------
 20792 |     20792
(1 row)
```

Es legítima **aquí** porque en Alameda el precio no es un dato primario: es la UB de la práctica por el valor de
la unidad del mes, y los dos factores están guardados. Cuando el precio es negociado práctica por práctica (como
los de 2025, por obra social), no hay fórmula, y un hueco se queda hueco.

**Rúbrica.** Una respuesta correcta tiene que:
- reconstruir solo donde no hay precio (`coalesce`), no reemplazar los que hay;
- decir de qué depende que la reconstrucción sea válida;
- marcar las filas reconstruidas, si se guardan, para que no pasen por datos originales.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-16--reconstruir-con-la-ub)

### Ejercicio 17

**Enunciado (resumen):** la corrección retroactiva.

**Solución.** Después de `06_bitemporal.sql`:

```sql
-- postgres
INSERT INTO staging.agreement_price_bitemporal VALUES
    ('OSDE', 7, '[2025-03-01,)', '[2025-03-01 09:00-03,)', 21000);
UPDATE staging.agreement_price_bitemporal SET recorded_during = tstzrange(lower(recorded_during), '2025-05-12 10:00-03')
WHERE payer_code = 'OSDE' AND practice_id = 7 AND upper_inf(recorded_during);
INSERT INTO staging.agreement_price_bitemporal VALUES
    ('OSDE', 7, '[2025-03-01,2025-04-01)', '[2025-05-12 10:00-03,)', 21000),
    ('OSDE', 7, '[2025-04-01,)', '[2025-05-12 10:00-03,)', 23100);

SELECT 'lo que se sabía el 30/04' AS segun, amount FROM staging.agreement_price_bitemporal
WHERE payer_code = 'OSDE' AND practice_id = 7 AND valid_during @> date '2025-04-20'
  AND recorded_during @> timestamptz '2025-04-30 12:00-03'
UNION ALL
SELECT 'lo que se sabe hoy', amount FROM staging.agreement_price_bitemporal
WHERE payer_code = 'OSDE' AND practice_id = 7 AND valid_during @> date '2025-04-20' AND recorded_during @> now();
```

```text
          segun           |   amount
--------------------------+------------
 lo que se sabía el 30/04 | 21000.0000
 lo que se sabe hoy       | 23100.0000
(2 rows)
```

La corrección no borra nada: cierra el período de registro de lo que se sabía y agrega dos filas nuevas, la de
marzo (que no cambió) y la de abril en adelante.

**Rúbrica.** Una respuesta correcta tiene que:
- cerrar `recorded_during` en lugar de actualizar el monto;
- volver a registrar el tramo que no cambió (marzo), o la consulta de hoy no lo encuentra;
- contestar las dos preguntas con dos instantes de registro distintos.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-17--la-corrección-retroactiva)

### Ejercicio 18

**Enunciado (resumen):** una tercera versión que se superpone.

**Solución.**

```sql
-- postgres
INSERT INTO staging.agreement_price_bitemporal VALUES ('OSDE', 7, '[2025-04-15,)', '[2025-06-01 10:00-03,)', 24000);
```

```text
ERROR:  conflicting key value violates exclusion constraint "agreement_price_bitemporal_excl"
DETAIL:  Key (payer_code, practice_id, valid_during, recorded_during)=(OSDE, 7, [2025-04-15,), ["2025-06-01 13:00:00+00",)) conflicts with existing key (payer_code, practice_id, valid_during, recorded_during)=(OSDE, 7, [2025-04-01,), ["2025-05-12 13:00:00+00",)).
```

El rechazo es correcto: el 1 de junio la base ya decía que desde el 1 de abril valía 23.100, y la fila nueva
dice otra cosa para el mismo tiempo válido. Hay que registrarla igual que en el ejercicio 17: cerrar el
registro de `[2025-04-01,)` el 1 de junio y agregar `[2025-04-01,2025-04-15)` a 23.100 y `[2025-04-15,)` a
24.000, las dos registradas desde el 1 de junio.

**Rúbrica.** Una respuesta correcta tiene que:
- leer el `DETAIL` y decir con qué fila choca;
- registrar la corrección partiendo el tramo vigente, sin tocar lo que se sabía antes.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-18--la-corrección-que-se-superpone)

### Ejercicio 19

**Enunciado (resumen):** la 6FN contra la 3FN.

**Solución.**

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS, COSTS ON, TIMING OFF, SUMMARY ON)
SELECT p.patient_id, p.full_name FROM alameda.patient AS p
WHERE p.sex = 'F' AND p.birth_date >= '1950-01-01' AND p.birth_date < '1951-01-01';

EXPLAIN (ANALYZE, BUFFERS, COSTS ON, TIMING OFF, SUMMARY ON)
SELECT a.patient_id, n.full_name
FROM staging.patient_anchor AS a
JOIN staging.patient_anchor_sex AS s ON s.patient_id = a.patient_id AND s.valid_during @> date '2026-01-01'
JOIN staging.patient_anchor_birth_date AS b ON b.patient_id = a.patient_id AND b.valid_during @> date '2026-01-01'
JOIN staging.patient_anchor_name AS n ON n.patient_id = a.patient_id AND n.valid_during @> date '2026-01-01'
WHERE s.sex = 'F' AND b.birth_date >= '1950-01-01' AND b.birth_date < '1951-01-01';
```

Las líneas que importan:

```text
 Gather  (cost=1000.00..6006.87 rows=1013 width=22) (actual rows=1014.00 loops=1)
   Buffers: shared hit=2410

 Gather  (cost=5016.07..8721.43 rows=764 width=22) (actual rows=884.00 loops=1)
   Buffers: shared hit=13285
   ->  Nested Loop  (…) (actual rows=442.00 loops=2)
         ->  Nested Loop  (…)
               ->  Parallel Hash Join  (…)
                     ->  Parallel Seq Scan on patient_anchor a  (…)
                     ->  Parallel Hash
                           ->  Parallel Seq Scan on patient_anchor_birth_date b  (…)
               ->  Index Scan using patient_anchor_sex_pkey on patient_anchor_sex s  (… loops=1764)
         ->  Index Scan using patient_anchor_name_pkey on patient_anchor_name n  (… loops=884)
```

La diferencia de filas no es un error: la 6FN contesta "al 1 de enero de 2026", y cada atributo vale desde el
alta del paciente. Los que llegaron después no existen todavía en esa fecha; en la 3FN no hay fecha que
preguntar.

**Rúbrica.** Una respuesta correcta tiene que:
- comparar bloques y estimaciones, no tiempos;
- explicar la diferencia de filas por el tiempo válido;
- decir qué pasaría con la estimación si cada atributo tuviera varias versiones.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-19--la-sexta-forma-normal)

### Ejercicio 20

**Enunciado (resumen):** el disparador de MySQL.

**Solución de referencia.**

```sql
-- mysql
CREATE TABLE practice_price (
  practice_id int NOT NULL, valid_from date NOT NULL, valid_to date NOT NULL DEFAULT '9999-12-31',
  amount decimal(19,4) NOT NULL,
  PRIMARY KEY (practice_id, valid_from),
  CONSTRAINT practice_price_valid_check CHECK (valid_from < valid_to)
);
DELIMITER //
CREATE TRIGGER practice_price_no_overlap BEFORE INSERT ON practice_price FOR EACH ROW
BEGIN
  IF EXISTS (SELECT 1 FROM practice_price p WHERE p.practice_id = NEW.practice_id
             AND p.valid_from < NEW.valid_to AND NEW.valid_from < p.valid_to) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'practice_price: overlapping validity';
  END IF;
END//
DELIMITER ;
INSERT INTO practice_price VALUES (7, '2025-01-01', '2025-03-01', 10), (7, '2025-03-01', '9999-12-31', 11);
INSERT INTO practice_price VALUES (7, '2025-05-01', '9999-12-31', 12);
```

```text
ERROR 1644 (45000) at line 20: practice_price: overlapping validity
```

**El caso en que no alcanza:** dos sesiones que insertan a la vez rangos que se tocan. El `SELECT` del
disparador es una lectura consistente que no bloquea, y ninguna de las dos ve la fila de la otra antes de
confirmar. Además, el disparador es `BEFORE INSERT`: un `UPDATE` que mueva un rango no lo dispara, y necesita
el suyo.

**Rúbrica.** Una respuesta correcta tiene que:
- usar la condición de superposición de intervalos semiabiertos (`a < d AND c < b`);
- nombrar los dos huecos: la concurrencia y el `UPDATE`;
- no presentar el disparador como equivalente a una restricción del motor.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-20--el-disparador-de-mysql)

---

## 🔴 Muy difícil (21–24)

### Ejercicio 21

**Enunciado (resumen):** un precio por obra social, desde 2002.

**Solución de referencia.** Una tabla, con la obra social como parte de la clave y un valor especial para "todas":

- `alameda.agreement_price (payer_code, practice_id, valid_during, amount, source)`, con `payer_code` que
  admite una fila de "precio general" (una obra social ficticia `GENERAL` en `alameda.payer`, o `payer_code`
  nulo con un índice único parcial aparte), y `source` que dice de dónde vino (`copia_mensual`, `precios_2025`,
  `reconstruido`).
- La carga de 2002–2024: las 20.367 filas de `practice_price` como precio general. La de 2025 en adelante: las
  6.498 vigencias por obra social.
- La consulta *as-of*: primero el precio de la obra social; si no hay, el general.

```sql
-- postgres
SELECT count(DISTINCT payer_code) AS obras, count(*) AS vigencias FROM alameda.agreement_price;
```

```text
 obras | vigencias
-------+-----------
    11 |      6498
(1 row)
```

**Rúbrica.** Una respuesta correcta tiene que:
- no inventar precios por obra social antes de 2025 copiando el general a cada una;
- dejar escrita la regla de precedencia (obra social sobre general);
- guardar el origen de cada fila;
- resolver las 35.641 prácticas de antes de la primera vigencia con el precio general, y decir que es una
  decisión de negocio.

Y queda invalidada si:
- usa dos tablas con la misma semántica y una `UNION` en cada consulta.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-21--un-precio-por-obra-social-desde-2002)

### Ejercicio 22

**Enunciado (resumen):** la historia de un protocolo entero.

**Solución de referencia.**

```sql
-- postgres
CREATE INDEX IF NOT EXISTS result_item_current_lab_order_id_idx ON staging.result_item_current (lab_order_id);
SELECT c.analyte_code, h.value_text AS decia, h.recorded_by AS lo_cargo, h.replaced_by AS lo_cambio,
       upper(h.system_during) AS cuando, c.value_text AS dice_hoy
FROM staging.result_item_current AS c
JOIN staging.result_item_history AS h USING (result_item_id)
WHERE c.lab_order_id = 11232670
ORDER BY upper(h.system_during);
```

```text
 analyte_code | decia |   lo_cargo   | lo_cambio |            cuando             | dice_hoy
--------------+-------+--------------+-----------+-------------------------------+----------
 GLU          | 165   | carga-legacy | lucia2    | 2026-10-14 05:15:15.218698+00 | 165
 GLU          | 156   | lucia2       | norma     | 2026-10-14 05:15:16.227524+00 | 165
(2 rows)
```

De los 13 resultados del protocolo, solo la glucemia tiene correcciones. La consulta necesita un índice por
`lab_order_id` en la tabla actual; la historia ya tiene uno por `result_item_id`, que es el primer campo de su
clave.

**Rúbrica.** Una respuesta correcta tiene que:
- partir del protocolo y llegar a la historia por el resultado;
- ordenar por el fin del período de registro (el momento del cambio);
- nombrar el índice que hace falta.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-22--la-historia-de-un-protocolo)

### Ejercicio 23

**Enunciado (resumen):** *Flashback* en Oracle.

**Solución.** No publicamos el resultado: es un número de Oracle (ver [`a09`](../a09-licencias-publicacion-y-riesgo.md)).
Lo que hay que hacer, en `sqlplus`:

```sql
-- oracle
CREATE TABLE result_demo (result_item_id NUMBER PRIMARY KEY, value_text VARCHAR2(50));
INSERT INTO result_demo VALUES (1, '165');
COMMIT;
UPDATE result_demo SET value_text = '156' WHERE result_item_id = 1;
COMMIT;
SELECT value_text FROM result_demo AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '30' SECOND) WHERE result_item_id = 1;
SHOW PARAMETER undo_retention
```

Qué mirar: si la consulta `AS OF` devuelve `165` sin ninguna tabla de historia, y qué dice `undo_retention`.
Después, repite la consulta con un intervalo mayor que la retención y mira si todavía contesta o falla por falta
de *undo*. La documentación (*Using Oracle Flashback Technology*) explica por qué la retención no es una
garantía salvo que se configure, y por qué para la pregunta de Norma, que puede llegar años después, hace falta
*Flashback Data Archive* o una tabla de historia.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-23--flashback)

### Ejercicio 24

**Enunciado (resumen):** ¿tiempo válido para los resultados?

**Solución de referencia.** Sí, para una parte. El tiempo de transacción (quién cambió qué y cuándo) es
obligatorio para todo resultado firmado. El tiempo válido aparece cuando el resultado describe algo que tiene
fecha distinta de su carga: la muestra se tomó el lunes y el resultado se cargó el martes, y la pregunta clínica
es "¿cuál era la glucemia del paciente el lunes?". Esa fecha ya existe (la de la toma de muestra, en el
protocolo), y alcanza con guardarla; un rango de validez por resultado no agrega nada, porque un resultado es
un hecho de un instante.

**Lo que cuesta ir más allá:** un rango y una restricción por resultado, sobre 12 millones de filas, y una
condición más en cada consulta, para contestar una pregunta que ya contesta la fecha de la muestra.

**Rúbrica.** Una respuesta correcta tiene que:
- separar los dos tiempos y decidir sobre cada uno;
- anclar la decisión en un caso de Alameda (la firma de Norma, la toma de muestra);
- decir qué no se modela y por qué.

Y queda invalidada si:
- propone lo bitemporal para los resultados sin decir qué pregunta contesta que hoy no se pueda contestar.

[← Volver al ejercicio](../07-el-tiempo-en-el-modelo.md#-ejercicio-24--bitemporal-para-los-resultados)
