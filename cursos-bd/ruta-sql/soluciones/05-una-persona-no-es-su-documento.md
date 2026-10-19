# ✅ Soluciones — Fase 05: Una persona no es su documento

> **Curso:** Ruta SQL · Solucionario de la [Fase 05](../05-una-persona-no-es-su-documento.md)
> **Ejercicios:** 24 · **Perfil:** M · **Motores:** Postgres y MySQL de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Fecha de verificación ejecutada:** 13/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todas las soluciones suponen M cargado en Postgres, los ocho scripts de `src/04-un-valor-un-hecho/` y los
siete de `src/05-una-persona-no-es-su-documento/` corridos en orden. Varias usan la tabla de pares verdaderos:

```sql
-- postgres
CREATE TEMP TABLE verdad AS
SELECT a.legacy_patient_id AS pa, b.legacy_patient_id AS pb
FROM truth.patient_record AS a
JOIN truth.patient_record AS b ON a.person_id = b.person_id AND a.legacy_patient_id < b.legacy_patient_id;
CREATE INDEX ON verdad (pa, pb);
```

```text
SELECT 47533
CREATE INDEX
```

---

## 🟢 Fácil (1–7)

### Ejercicio 1

**Enunciado (resumen):** filas, personas y sobrantes de `Pacientes`.

**Solución.**

```sql
-- postgres
SELECT count(*) AS filas, count(DISTINCT person_id) AS personas,
       count(*) - count(DISTINCT person_id) AS sobrantes,
       round(100.0 * (count(*) - count(DISTINCT person_id)) / count(*), 1) AS pct
FROM truth.patient_record;
```

```text
 filas  | personas | sobrantes | pct
--------+----------+-----------+------
 242427 |   200002 |     42425 | 17.5
(1 row)
```

El 17,5 % cae dentro del 15 % al 20 % que estima Matías. Fíjate en que "sobrantes" no es lo mismo que "pares":
una persona con tres fichas aporta dos sobrantes y tres pares.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-1--cuántos-sobran)

### Ejercicio 2

**Enunciado (resumen):** `UNIQUE` sobre `document_digits`.

**Solución.**

```sql
-- postgres
ALTER TABLE staging.patient_clean ADD CONSTRAINT patient_clean_document_digits_key UNIQUE (document_digits);
SELECT count(*) FILTER (WHERE document_digits IS NULL) AS sin_documento,
       count(DISTINCT document_digits) AS documentos, count(*) AS filas
FROM staging.patient_clean;
```

```text
ERROR:  could not create unique index "patient_clean_document_digits_key"
DETAIL:  Key (document_digits)=(9496697) is duplicated.
CONTEXT:  parallel worker
 sin_documento | documentos | filas
---------------+------------+--------
          9871 |     200090 | 242427
(1 row)
```

El número que nombra el error puede ser otro en tu corrida: Postgres informa el primer duplicado que
encuentra, y con la construcción en paralelo el orden cambia. Lo que no cambia son las 9.871 filas sin documento,
que una clave primaria sobre el DNI no dejaría ni entrar.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-2--el-dni-como-clave)

### Ejercicio 3

**Enunciado (resumen):** los siete scripts, en orden.

**Solución.** Desde `src/`, con `psql` contra el laboratorio (ver [`a03`](../a03-clis-de-los-motores.md)):

```bash
for f in 05-una-persona-no-es-su-documento/0*.sql; do psql -v ON_ERROR_STOP=1 -f "$f"; done
```

Las líneas que importan de la salida:

```text
SELECT 1144780        -- 02_candidates.sql: los pares candidatos
INSERT 0 45807        -- 03_match.sql: los niveles 1 y 2
INSERT 0 242427       -- 04_identity.sql: un paciente por fila de legacy
INSERT 0 18538        -- 05_merge.sql: las fusiones registradas
UPDATE 18538          -- 05_merge.sql: los pacientes marcados
UPDATE 4389           -- 07_newborns.sql: los recién nacidos con su madre
```

Los 45.807 pares de `staging.match_review` son 19.620 del nivel automático y 26.187 del de revisión. Las 18.538
fusiones son menos que los 19.620 pares porque varios pares caen en el mismo grupo.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-3--los-siete-scripts)

### Ejercicio 4

**Enunciado (resumen):** cinco nombres por `staging.normalize_name`.

**Solución.**

```sql
-- postgres
SELECT n AS nombre, staging.normalize_name(replace(n, '.', '')) AS normalizado
FROM unnest(ARRAY['GONZALEZ MARIA ESTHER DNI 11222333 OSDE 210', 'RN GONZALEZ MARIA DNI 11222333',
                  'LOPEZ JUAN CARLOS (EL HIJO) DNI 30111222', 'SILVA ROSA - PAMI 150123456789/00',
                  'PEÑA LAURA CARMEN OTRO 9242/22']) AS n;
```

```text
                   nombre                    |      normalizado
---------------------------------------------+-----------------------
 GONZALEZ MARIA ESTHER DNI 11222333 OSDE 210 | GONZALEZ MARIA ESTHER
 RN GONZALEZ MARIA DNI 11222333              | GONZALEZ MARIA
 LOPEZ JUAN CARLOS (EL HIJO) DNI 30111222    | LOPEZ JUAN CARLOS
 SILVA ROSA - PAMI 150123456789/00           | SILVA ROSA
 PEÑA LAURA CARMEN OTRO 9242/22              | PENA LAURA CARMEN
(5 rows)
```

Las reglas, en el orden de la función: `unaccent` y mayúsculas (`PEÑA` → `PENA`); los paréntesis y las
palabras de documento (`(EL HIJO)`, `DNI`, `RN`, `OTRO`); los números y lo que los sigue (`11222333`, `210`,
`9242/22`); las obras sociales de `staging.payer_alias` (`OSDE`, `PAMI`); y por último todo lo que no es letra.
Ojo con la segunda fila: el `RN` se fue, y con él la única marca de que esa ficha es de un recién nacido.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-4--el-nombre-limpio)

### Ejercicio 5

**Enunciado (resumen):** cuatro similitudes.

**Solución.**

```sql
-- postgres
SELECT a, b, round(similarity(a, b)::numeric, 2) AS trigramas
FROM (VALUES ('GONZALEZ MARIA ESTHER', 'GONZALEZ MARIA'), ('GIMENEZ ROSA', 'JIMENEZ ROSA'),
             ('OLMOS PAEZ', 'OLMOS RAUL'), ('PEREZ PEDRO', 'PERES PEDRO')) AS t (a, b);
```

```text
           a           |       b        | trigramas
-----------------------+----------------+-----------
 GONZALEZ MARIA ESTHER | GONZALEZ MARIA |      0.68
 GIMENEZ ROSA          | JIMENEZ ROSA   |      0.63
 OLMOS PAEZ            | OLMOS RAUL     |      0.38
 PEREZ PEDRO           | PERES PEDRO    |      0.67
(4 rows)
```

Los trigramas miden **cuántas letras comparten**, no si son la misma persona. `GIMENEZ ROSA` y `JIMENEZ ROSA`
difieren en una letra; `OLMOS PAEZ` (el `RN`, con los dos apellidos) y `OLMOS RAUL` (el mismo chico años
después, con su nombre) comparten solo `OLMOS`. Para la función, el segundo par es más distinto, aunque sea
la misma persona.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-5--cuatro-similitudes)

### Ejercicio 6

**Enunciado (resumen):** tres documentos contra el `CHECK`.

**Solución.**

```sql
-- postgres
BEGIN;
INSERT INTO alameda.identity_document (patient_id, document_type, country, number) VALUES (1, 'DNI', 'ARG', '123456');
ROLLBACK;
BEGIN;
INSERT INTO alameda.identity_document (patient_id, document_type, country, number) VALUES (1, 'PAS', 'ARG', 'A1234567');
ROLLBACK;
BEGIN;
INSERT INTO alameda.identity_document (patient_id, document_type, country, number) VALUES (1, 'PAS', 'BOL', 'A1234567');
ROLLBACK;
```

```text
ERROR:  new row for relation "identity_document" violates check constraint "identity_document_number_check"
DETAIL:  Failing row contains (195682, 1, DNI, ARG, 123456, null).
ERROR:  new row for relation "identity_document" violates check constraint "identity_document_number_check"
DETAIL:  Failing row contains (195683, 1, PAS, ARG, A1234567, null).
INSERT 0 1
```

El primer identificador del `DETAIL` va a ser otro en tu corrida: la identidad avanza aunque la transacción
se deshaga.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-6--el-check-por-tipo)

### Ejercicio 7

**Enunciado (resumen):** borrar al paciente 1.

**Solución.**

```sql
-- postgres
DELETE FROM alameda.patient WHERE patient_id = 1;
```

```text
ERROR:  a patient is never deleted: merge 1 into another patient instead
CONTEXT:  PL/pgSQL function alameda.patient_forbid_delete() line 3 at RAISE
```

En su lugar se fusiona: una fila en `alameda.patient_merge` y `merged_into_patient_id`, `merged_at` y
`merged_by` en el paciente, que es lo que hace `05_merge.sql`. El disparador no protege contra un `TRUNCATE`,
que no dispara `BEFORE DELETE` por fila; para eso están los permisos.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-7--la-fusión-nunca-borra)

---

## 🟡 Intermedio (8–14)

### Ejercicio 8

**Enunciado (resumen):** la cobertura del bloque.

**Solución.**

```sql
-- postgres
SELECT count(*) FILTER (WHERE ca.birth_date = cb.birth_date) AS misma_fecha,
       count(*) FILTER (WHERE ca.birth_date = cb.birth_date OR ca.document_digits = cb.document_digits) AS fecha_o_documento,
       count(*) AS total
FROM verdad AS v
JOIN staging.patient_clean AS ca ON ca.legacy_patient_id = v.pa
JOIN staging.patient_clean AS cb ON cb.legacy_patient_id = v.pb;
```

```text
 misma_fecha | fecha_o_documento | total
-------------+-------------------+-------
       46414 |             47120 | 47533
(1 row)
```

El documento suma 706 pares que la fecha no juntaba, y quedan 413 que nada junta. Esos 413 son el techo de
cualquier *matcher* que use este bloque: su exhaustividad no puede pasar del 99,1 %.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-8--lo-que-el-bloque-deja-afuera)

### Ejercicio 9

**Enunciado (resumen):** la curva del umbral con trigramas solos.

**Solución.**

```sql
-- postgres
SELECT t AS umbral, count(*) AS aceptados, count(*) FILTER (WHERE v.pa IS NULL) AS falsos,
       round(100.0 * count(*) FILTER (WHERE v.pa IS NULL) / nullif(count(*), 0), 2) AS pct_falsos,
       round(100.0 * count(*) FILTER (WHERE v.pa IS NOT NULL) / (SELECT count(*) FROM verdad), 1) AS exhaustividad
FROM unnest(ARRAY[0.4, 0.5, 0.6, 0.7, 0.8]) AS t
JOIN staging.match_candidate AS c ON c.name_similarity >= t
LEFT JOIN verdad AS v ON v.pa = c.patient_a AND v.pb = c.patient_b
GROUP BY t ORDER BY t;
```

```text
 umbral | aceptados | falsos | pct_falsos | exhaustividad
--------+-----------+--------+------------+---------------
    0.4 |     45787 |   4128 |       9.02 |          87.6
    0.5 |     41747 |   1020 |       2.44 |          85.7
    0.6 |     39884 |    364 |       0.91 |          83.1
    0.7 |     34504 |    163 |       0.47 |          72.2
    0.8 |     30850 |     89 |       0.29 |          64.7
(5 rows)
```

`pct_falsos` es el complemento de la precisión: con 0,6, la precisión es 99,09 %. El `LEFT JOIN` contra la
verdad es toda la técnica; sin una verdad, esta tabla no se puede hacer.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-9--la-curva-del-umbral)

### Ejercicio 10

**Enunciado (resumen):** la regla combinada.

**Solución.**

```sql
-- postgres
SELECT t AS umbral, count(*) AS aceptados, count(*) FILTER (WHERE v.pa IS NULL) AS falsos,
       round(100.0 * count(*) FILTER (WHERE v.pa IS NULL) / nullif(count(*), 0), 2) AS pct_falsos,
       round(100.0 * count(*) FILTER (WHERE v.pa IS NOT NULL) / (SELECT count(*) FROM verdad), 1) AS exhaustividad
FROM unnest(ARRAY[0.5, 0.6, 0.7]) AS t
JOIN staging.match_candidate AS c ON (c.same_document AND c.same_birth_date) OR c.name_similarity >= t
LEFT JOIN verdad AS v ON v.pa = c.patient_a AND v.pb = c.patient_b
GROUP BY t ORDER BY t;

SELECT count(*) AS doc_y_fecha, count(*) FILTER (WHERE v.pa IS NULL) AS falsos
FROM staging.match_candidate AS c
LEFT JOIN verdad AS v ON v.pa = c.patient_a AND v.pb = c.patient_b
WHERE c.same_document AND c.same_birth_date;
```

```text
 umbral | aceptados | falsos | pct_falsos | exhaustividad
--------+-----------+--------+------------+---------------
    0.5 |     41960 |   1020 |       2.43 |          86.1
    0.6 |     41112 |    364 |       0.89 |          85.7
    0.7 |     40469 |    163 |       0.40 |          84.8
(3 rows)

 doc_y_fecha | falsos
-------------+--------
       28822 |      0
(1 row)
```

La señal del documento con la fecha suma exhaustividad sin sumar falsos: con 0,7, la regla combinada pierde
apenas un punto contra 0,6 y tiene la mitad de falsos. Por eso el nivel automático de la fase empieza por ahí.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-10--la-señal-que-los-trigramas-no-ven)

### Ejercicio 11

**Enunciado (resumen):** la fonética como regla, y Soundex en dos motores.

**Solución.**

```sql
-- postgres
SELECT count(*) AS aceptados, count(*) FILTER (WHERE v.pa IS NULL) AS falsos,
       round(100.0 * count(*) FILTER (WHERE v.pa IS NULL) / count(*), 2) AS pct_falsos,
       round(100.0 * count(*) FILTER (WHERE v.pa IS NOT NULL) / 47533, 1) AS exhaustividad
FROM staging.match_candidate AS c
JOIN staging.patient_clean AS a ON a.legacy_patient_id = c.patient_a
JOIN staging.patient_clean AS b ON b.legacy_patient_id = c.patient_b
LEFT JOIN verdad AS v ON v.pa = c.patient_a AND v.pb = c.patient_b
WHERE c.same_birth_date
  AND dmetaphone(split_part(a.norm_name, ' ', 1)) = dmetaphone(split_part(b.norm_name, ' ', 1));

SELECT n, soundex(n), dmetaphone(n)
FROM unnest(ARRAY['GIMENEZ', 'JIMENEZ', 'VAZQUEZ', 'BASQUEZ']) AS n;
```

```text
 aceptados | falsos | pct_falsos | exhaustividad
-----------+--------+------------+---------------
     65320 |  18906 |      28.94 |          97.6
(1 row)

    n    | soundex | dmetaphone
---------+---------+------------
 GIMENEZ | G552    | JMNS
 JIMENEZ | J552    | JMNS
 VAZQUEZ | V220    | FSKS
 BASQUEZ | B220    | PSKS
(4 rows)
```

```sql
-- mysql
SELECT n, SOUNDEX(n) FROM (SELECT 'GIMENEZ' n UNION ALL SELECT 'JIMENEZ' UNION ALL SELECT 'VAZQUEZ'
                           UNION ALL SELECT 'BASQUEZ') AS x;
```

```text
+---------+------------+
| n       | SOUNDEX(n) |
+---------+------------+
| GIMENEZ | G520       |
| JIMENEZ | J520       |
| VAZQUEZ | V200       |
| BASQUEZ | B200       |
+---------+------------+
```

Una regla con 97,6 % de exhaustividad y 28,94 % de falsos es un **bloque**, no una decisión: junta casi todos
los pares verdaderos en un conjunto chico, sobre el que después decide otra señal. Daitch-Mokotoff, la que la
documentación de Postgres recomienda para nombres no ingleses, da un resultado parecido en la misma regla
(97,2 % y 31,85 %). Ningún Soundex junta `GIMENEZ` con `JIMENEZ`, porque conserva la primera letra; Double
Metaphone sí.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-11--la-fonética)

### Ejercicio 12

**Enunciado (resumen):** las madres, contra la verdad.

**Solución.**

```sql
-- postgres
SELECT count(*) AS recien_nacidos FROM staging.document_candidate WHERE document_type = 'RN';
SELECT count(*) AS enlazados,
       count(*) FILTER (WHERE rm.person_id = t.mother_person_id) AS correctos,
       count(*) FILTER (WHERE rm.person_id IS DISTINCT FROM t.mother_person_id) AS incorrectos
FROM alameda.patient AS n
JOIN truth.patient_record AS rn ON rn.legacy_patient_id = n.legacy_patient_id
JOIN truth.person AS t ON t.person_id = rn.person_id
JOIN alameda.patient AS m ON m.patient_id = n.mother_patient_id
JOIN truth.patient_record AS rm ON rm.legacy_patient_id = m.legacy_patient_id;
```

```text
 recien_nacidos
----------------
           5408
(1 row)

 enlazados | correctos | incorrectos
-----------+-----------+-------------
      4389 |      4389 |           0
(1 row)
```

Las tres condiciones de `07_newborns.sql` (mujer, doce años mayor y una sola candidata) son las que llevan los
errores a cero. Los 1.019 sin madre son, por construcción, los que no cumplen alguna de las tres o cuyo número no está en
`identity_document`.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-12--la-madre)

### Ejercicio 13

**Enunciado (resumen):** la primera versión de `pasaporte_sin_pais`.

**Solución.**

```sql
-- postgres
SELECT count(*) AS pasaporte_sin_pais, count(*) FILTER (WHERE t.document_type = 'OTRO') AS no_son_pasaportes
FROM legacy."Pacientes" AS l
JOIN truth.patient_record AS r ON r.legacy_patient_id = l."IdPaciente"
JOIN truth.person AS t USING (person_id)
WHERE l."Nombre" !~ '^RN ' AND l."Nombre" !~ '\mOTRO\M' AND l."DNI" ~ '^[A-Za-z]';

SELECT l."Nombre", l."DNI" FROM legacy."Pacientes" AS l
WHERE l."Nombre" !~ '^RN ' AND l."Nombre" !~ '\mOTRO\M' AND l."DNI" ~ '^OTRO'
ORDER BY l."IdPaciente" LIMIT 3;
```

```text
 pasaporte_sin_pais | no_son_pasaportes
--------------------+-------------------
               5202 |                65
(1 row)

         Nombre         |     DNI
------------------------+--------------
 GOMEZ NORMA            | OTRO 1771/19
 CABRERA OLGA VALENTINA | OTRO 9441/25
 IBAÑEZ MARIELA ROMINA  | OTRO 8559/25
(3 rows)
```

La regla "empieza con letra, entonces es un pasaporte" encontraba también `OTRO …`, que empieza con la `O`. Es
el mismo error que la `P` de `P.A.M.I.` en la [Fase 04](../04-un-valor-un-hecho.md): un patrón que acierta en lo que buscaba y no mira qué
más encuentra. La medición contra la verdad lo hizo visible; sin ella, 65 refugiados habrían quedado como
pasaportes sin país.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-13--los-pasaportes-que-no-lo-eran)

### Ejercicio 14

**Enunciado (resumen):** las nueve libretas fuera de formato.

**Solución.**

```sql
-- postgres
SELECT j.value, l."Nombre", staging.extract_dni_2016(l."Nombre") AS parser_2016
FROM staging.rejection AS j
JOIN legacy."Pacientes" AS l ON l."IdPaciente" = j.source_key::int
WHERE j.rule = 'pacientes.numero_fuera_de_formato'
ORDER BY j.source_key::int;
```

```text
 value |                 Nombre                  | parser_2016
-------+-----------------------------------------+-------------
 LC 12 | PEREYRA ROMINA NORMA LC 12 482 807      | 12
 LC 16 | LUNA MOLINA ROSA LC 16 802 064          | 16
 LE 18 | VILLARREAL LUCAS PEDRO LE 18 770 162    | 18
 LC 10 | FLORES MIRTA ADRIANA LC 10 538 656      | 10
 LC 15 | GUTIERREZ TERESA MILAGROS LC 15 125 609 | 15
 LE 13 | RUIZ GOMEZ ANGEL ANGEL LE 13 600 661    | 13
 LE 11 | NUÑEZ JORGE LE 11 744 085               | 11
 LE 16 | SOSA JUAN MATIAS LE 16 087 258          | 16
 LE 13 | IBAÑEZ PEDRO LUIS LE 13 021 532         | 13
(9 rows)
```

El parser toma "lo que sigue hasta el próximo espacio", y con el número escrito en grupos se queda con el
primero. Nadie lo había notado en veinte años porque `12` es un texto válido en un campo de texto. Lo descubrió
el `CHECK` de `identity_document`, al primer intento de carga: la regla de rechazo vino después.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-14--las-libretas-con-espacios)

---

## 🟠 Difícil (15–20)

### Ejercicio 15

**Enunciado (resumen):** el cuadrado, con 1.000 y 2.000 pacientes.

**Solución.**

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS)
WITH muestra AS MATERIALIZED (SELECT legacy_patient_id, norm_name FROM staging.patient_clean
                              ORDER BY legacy_patient_id LIMIT 1000)
SELECT count(*) FROM muestra a JOIN muestra b
  ON a.legacy_patient_id < b.legacy_patient_id AND similarity(a.norm_name, b.norm_name) >= 0.6;
```

Las líneas que importan, para 1.000 y para 2.000:

```text
   ->  Nested Loop  (cost=0.00..27530.00 rows=111111 width=0) (actual time=2.257..1746.994 rows=161.00 loops=1)
         Rows Removed by Join Filter: 999839
 Execution Time: 1747.561 ms

   ->  Nested Loop  (cost=0.00..110060.00 rows=444444 width=0) (actual time=4.773..7098.902 rows=619.00 loops=1)
         Rows Removed by Join Filter: 3999381
 Execution Time: 7111.211 ms
```

La fórmula: filas descartadas más devueltas = *n*². Con 1.000, 999.839 + 161 = 1.000.000; con 2.000, 3.999.381 +
619 = 4.000.000. El `Nested Loop` evalúa la condición completa sobre los *n*² pares, incluidos los que `a < b`
descarta, porque el filtro es uno solo. Duplicar *n* cuadruplica las filas, y el tiempo lo sigue: 1,7 s y 7,1 s.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-15--el-cuadrado)

### Ejercicio 16

**Enunciado (resumen):** el plan con bloqueo.

**Solución.**

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM staging.patient_clean a JOIN staging.patient_clean b
  ON a.legacy_patient_id < b.legacy_patient_id
 AND (a.birth_date = b.birth_date OR a.document_digits = b.document_digits);
```

```text
   ->  Nested Loop  (cost=0.94..740514.98 rows=502132 width=0) (actual time=71.193..1425.758 rows=572390.00 loops=2)
         ->  Parallel Seq Scan on patient_clean a  (cost=0.00..3538.04 rows=142604 width=16) (actual time=0.004..7.305 rows=121213.50 loops=2)
         ->  Bitmap Heap Scan on patient_clean b  (cost=0.94..5.13 rows=4 width=16) (actual time=0.009..0.011 rows=4.72 loops=242427)
               Rows Removed by Filter: 6
               ->  BitmapOr  (cost=0.94..0.94 rows=11 width=0) (actual time=0.005..0.005 rows=0.00 loops=242427)
                     ->  Bitmap Index Scan on patient_clean_birth_date_idx  (cost=0.00..0.49 rows=9 width=0) (actual time=0.002..0.002 rows=10.37 loops=242427)
                     ->  Bitmap Index Scan on patient_clean_document_digits_idx  (cost=0.00..0.44 rows=1 width=0) (actual time=0.003..0.003 rows=1.26 loops=242427)
 Execution Time: 1476.901 ms
```

Por paciente, el índice de fecha devuelve 10,37 filas y el de documento 1,26: unas 11,6 filas por paciente, y
unos 2,8 millones en total para los 242.427. De esas, seis por paciente caen en el filtro `a < b` (o son él
mismo), y quedan 4,72 por paciente en promedio: 572.390 por cada uno de los dos procesos, 1.144.780 pares. Contra
los 58.800 millones del autojoin sin bloqueo, son unas veinte mil veces menos comparaciones.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-16--el-plan-con-bloqueo)

### Ejercicio 17

**Enunciado (resumen):** `documento_de_otro_paciente` contra la cola.

**Solución.**

```sql
-- postgres
SELECT count(*) AS rechazos,
       count(*) FILTER (WHERE q.tier = 'automatic') AS ya_fusionados_por_otro_par,
       count(*) FILTER (WHERE q.tier = 'review') AS en_la_cola,
       count(*) FILTER (WHERE q.patient_a IS NULL) AS fuera_de_la_cola
FROM staging.rejection AS j
JOIN alameda.patient AS p ON p.legacy_patient_id = j.source_key::int
JOIN alameda.identity_document AS d ON d.document_type = split_part(j.value, ' ', 1) AND d.country = 'ARG'
                                    AND d.number = split_part(j.value, ' ', 2)
JOIN alameda.patient AS o ON o.patient_id = d.patient_id
LEFT JOIN staging.match_review AS q ON q.patient_a = least(p.legacy_patient_id, o.legacy_patient_id)
                                   AND q.patient_b = greatest(p.legacy_patient_id, o.legacy_patient_id)
WHERE j.rule = 'pacientes.documento_de_otro_paciente';
```

```text
 rechazos | ya_fusionados_por_otro_par | en_la_cola | fuera_de_la_cola
----------+----------------------------+------------+------------------
     9049 |                          0 |       9048 |                1
(1 row)
```

**Propuesta de orden.** Primero los 9.048 pares de la cola que además comparten documento: en esta caja son
todos la misma persona, y se revisan rápido porque la evidencia es fuerte. Después, el resto de la cola por
similitud descendente. Lo que se espera es que la proporción de "personas distintas" crezca a medida que se
baja.

**Rúbrica.** Una respuesta correcta tiene que:
- cruzar por el par ordenado (`least`, `greatest`), no por un paciente solo;
- usar el documento para ordenar la cola, no para fusionar sin revisión;
- decir por qué el 100 % de esta caja no autoriza a saltarse la revisión (un DNI mal tipeado).

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-17--el-documento-como-prioridad)

### Ejercicio 18

**Enunciado (resumen):** a quién pierde el *matcher*.

**Solución.**

```sql
-- postgres
CREATE TEMP TABLE verdad_sucia AS
SELECT a.legacy_patient_id AS pa, b.legacy_patient_id AS pb, a.dirt AS da, b.dirt AS db
FROM truth.patient_record AS a
JOIN truth.patient_record AS b ON a.person_id = b.person_id AND a.legacy_patient_id < b.legacy_patient_id;

SELECT count(*) AS perdidos,
       count(*) FILTER (WHERE 'newborn_mother_dni' = ANY (da || db)) AS con_recien_nacido
FROM verdad_sucia AS v
LEFT JOIN staging.match_candidate AS c ON c.patient_a = v.pa AND c.patient_b = v.pb
WHERE c.patient_a IS NULL OR NOT ((c.same_document AND c.same_birth_date) OR c.name_similarity >= 0.6);

SELECT round(100.0 * count(*) FILTER (WHERE c.patient_a IS NOT NULL
                                      AND ((c.same_document AND c.same_birth_date) OR c.name_similarity >= 0.6))
             / count(*), 1) AS exhaustividad_sin_rn,
       count(*) AS pares_sin_rn
FROM verdad_sucia AS v
LEFT JOIN staging.match_candidate AS c ON c.patient_a = v.pa AND c.patient_b = v.pb
WHERE NOT 'newborn_mother_dni' = ANY (da || db);
```

```text
 perdidos | con_recien_nacido
----------+-------------------
     6414 |              6116
(1 row)

 exhaustividad_sin_rn | pares_sin_rn
----------------------+--------------
                 99.0 |        40482
(1 row)
```

El 95 % de lo que se pierde tiene un `RN` de un lado. El resto, 298 pares sin `RN`, quedan bajo el umbral o fuera
del bloque. La conclusión es de modelo, no de umbral: el recién nacido necesita otro
camino (ejercicio 21).

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-18--a-quién-pierde-el-matcher)

### Ejercicio 19

**Enunciado (resumen):** el nivel automático sobre las filas del LIS.

**Solución.**

```sql
-- postgres
SELECT count(*) AS filas_lis,
       count(DISTINCT coalesce(p.merged_into_patient_id, p.patient_id)) AS pacientes_tras_la_fusion,
       count(DISTINCT r.person_id) AS personas
FROM legacy."MIG_LIS_PACIENTES" AS m
JOIN alameda.patient AS p ON p.legacy_patient_id = m."ORIGEN_ID"
JOIN truth.patient_record AS r ON r.legacy_patient_id = m."ORIGEN_ID";

SELECT count(*) AS grupos_con_dos_personas FROM (
  SELECT coalesce(p.merged_into_patient_id, p.patient_id)
  FROM legacy."MIG_LIS_PACIENTES" AS m
  JOIN alameda.patient AS p ON p.legacy_patient_id = m."ORIGEN_ID"
  JOIN truth.patient_record AS r ON r.legacy_patient_id = m."ORIGEN_ID"
  GROUP BY 1 HAVING count(DISTINCT r.person_id) > 1) AS x;
```

```text
 filas_lis | pacientes_tras_la_fusion | personas
-----------+--------------------------+----------
      4737 |                     4727 |     4720
(1 row)

 grupos_con_dos_personas
-------------------------
                       0
(1 row)
```

El nivel automático habría juntado 10 de las 17 copias sobrantes del LIS sin mezclar a nadie; las otras 7
seguirían separadas. La tabla del LIS tiene pocas copias de la misma persona porque es una muestra (una de
cada cuatro fichas anteriores a junio de 2012). El problema no era la muestra, era la política del
importador: una ficha, un paciente.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-19--el-lis-otra-vez)

### Ejercicio 20

**Enunciado (resumen):** el costo de la cola y su reparto.

**Solución de referencia.** Con medio minuto por par, que es una suposición y se dice, los 26.187 pares son
785.610 segundos: **unas 218 horas**, cinco semanas y media de una persona a tiempo completo. Con un minuto por
par, el doble.

**Un reparto defendible:**

1. Los 9.048 pares con documento compartido (ejercicio 17): evidencia fuerte, revisión rápida.
2. El resto por similitud descendente: los primeros son casi seguros, los últimos casi siempre distintos.
3. Un corte acordado: por debajo de cierta similitud, el par se descarta sin revisar, y se mide con una
   muestra cuántos verdaderos se pierden.
4. Lo que nunca se revisa en lote: pares con un `RN` o con sexo distinto, que necesitan la ficha en papel.

**Rúbrica.** Una respuesta correcta tiene que:
- declarar la suposición de tiempo por par y dar la cuenta;
- ordenar con datos medidos (documento compartido, similitud), no por orden de llegada;
- proponer cómo medir lo que se pierde con el corte.

Y queda invalidada si:
- propone bajar el umbral automático para achicar la cola sin medir los falsos que agrega.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-20--el-costo-de-la-cola)

---

## 🔴 Muy difícil (21–24)

### Ejercicio 21

**Enunciado (resumen):** el recién nacido, años después, a través de la madre.

**Solución de referencia.**

```sql
-- postgres
WITH rn AS (
    SELECT n.legacy_patient_id AS rn_id, n.birth_date, split_part(n.full_name, ' ', 1) AS surname
    FROM alameda.patient AS n WHERE n.mother_patient_id IS NOT NULL
),
candidate AS (
    SELECT rn.rn_id, c.legacy_patient_id AS later_id
    FROM rn
    JOIN staging.patient_clean AS c ON c.birth_date = rn.birth_date
                                   AND split_part(c.norm_name, ' ', 1) = rn.surname
                                   AND c.legacy_patient_id <> rn.rn_id
    JOIN legacy."Pacientes" AS l ON l."IdPaciente" = c.legacy_patient_id AND l."Nombre" !~ '^RN '
)
SELECT count(*) AS propuestos,
       count(*) FILTER (WHERE v.pa IS NOT NULL) AS misma_persona,
       count(*) FILTER (WHERE v.pa IS NULL) AS personas_distintas
FROM candidate AS k
LEFT JOIN verdad AS v ON v.pa = least(k.rn_id, k.later_id) AND v.pb = greatest(k.rn_id, k.later_id);
```

```text
 propuestos | misma_persona | personas_distintas
------------+---------------+--------------------
       5469 |          5113 |                356
(1 row)
```

5.113 pares correctos que los trigramas no encontraban, con un 6,5 % de falsos (356). Es mucho mejor que nada y
mucho peor que el nivel automático: **va a la cola**, con una marca propia, porque el revisor tiene que mirar
otra cosa (¿la madre de esta ficha es la misma?).

**Rúbrica.** Una respuesta correcta tiene que:
- usar la relación con la madre o la fecha de nacimiento, no la similitud del nombre completo;
- medir la propuesta contra la verdad, con falsos y verdaderos;
- mandar el resultado a revisión, no a fusión automática.

Y queda invalidada si:
- fusiona los 5.469 pares sin revisión.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-21--el-recién-nacido-años-después)

### Ejercicio 22

**Enunciado (resumen):** deshacer una fusión sin perder que existió.

**Solución de referencia.** El `UPDATE` directo funciona, y ese es el problema:

```sql
-- postgres
BEGIN;
SELECT patient_id, merged_into_patient_id, merged_by FROM alameda.patient
WHERE patient_id = (SELECT min(merged_patient_id) FROM alameda.patient_merge);
UPDATE alameda.patient SET merged_into_patient_id = NULL, merged_at = NULL, merged_by = NULL
WHERE patient_id = (SELECT min(merged_patient_id) FROM alameda.patient_merge);
UPDATE alameda.patient SET merged_at = now()
WHERE patient_id = (SELECT min(merged_patient_id) FROM alameda.patient_merge);
ROLLBACK;
```

```text
 patient_id | merged_into_patient_id |  merged_by
------------+------------------------+-------------
       2604 |                    490 | matcher-f05
(1 row)

UPDATE 1
ERROR:  new row for relation "patient" violates check constraint "patient_merged_check"
DETAIL:  Failing row contains (2604, 2604, MARTINEZ LILIANA, 1971-08-31, F, null, null, 2026-10-13 17:04:02.595942+00, null).
```

El primer `UPDATE` deja al paciente como si nunca se hubiera fusionado. `patient_merge` todavía tiene la fila,
pero nada dice que se deshizo, ni quién, ni por qué. El `CHECK` sí impide estados a medias, como el segundo
`UPDATE`.

**El cambio al esquema:** `patient_merge` gana `undone_at`, `undone_by` y `undo_reason`. La unicidad de
`merged_patient_id` pasa a ser un índice único parcial `WHERE undone_at IS NULL`, porque un paciente puede
fusionarse, separarse y volver a fusionarse. Deshacer es una transacción con dos sentencias: marcar la fila de
`patient_merge` y limpiar las tres columnas del paciente. Lo que esta fase todavía no resuelve es qué
protocolos eran de quién mientras estuvieron fusionados; eso es tiempo en el modelo, y es de la [Fase 07](../07-el-tiempo-en-el-modelo.md).

**Rúbrica.** Una respuesta correcta tiene que:
- conservar la fila de la fusión y agregarle quién la deshizo, cuándo y por qué;
- hacer las dos escrituras en una transacción;
- explicar por qué la unicidad tiene que pasar a ser parcial.

Y queda invalidada si:
- borra la fila de `patient_merge`.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-22--deshacer-una-fusión)

### Ejercicio 23

**Enunciado (resumen):** la apuesta de Jaro-Winkler en Oracle.

**Solución.** No publicamos el resultado: es un número de Oracle (ver [`a09`](../a09-licencias-publicacion-y-riesgo.md)).
Lo que hay que hacer, en `sqlplus`:

```sql
-- oracle
SELECT UTL_MATCH.JARO_WINKLER_SIMILARITY('OLMOS PAEZ', 'OLMOS RAUL') AS jw,
       UTL_MATCH.EDIT_DISTANCE_SIMILARITY('OLMOS PAEZ', 'OLMOS RAUL') AS ed
FROM dual;
```

Y lo mismo con los otros tres pares de la sección 5.4. Qué mirar: si el par de `OLMOS` sube mucho más que con
trigramas (0,38). Si sube, la hipótesis se sostiene, y su segunda mitad es la preocupante: Jaro-Winkler premia
el prefijo, y en una población donde muchas familias comparten el primer apellido, el prefijo es justo lo que no
distingue a dos personas. La documentación de `UTL_MATCH` describe las cuatro funciones; el peso del prefijo
viene de la definición de Winkler, que puedes leer en Christen (en las referencias de la fase).

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-23--jaro-winkler)

### Ejercicio 24

**Enunciado (resumen):** el nivel automático, defendido ante Norma.

**Solución de referencia.** El nivel 1 de la fase: **mismo documento, misma fecha de nacimiento y trigramas ≥
0,8**. Medido: 19.620 pares, 0 falsos, el 41 % de los pares verdaderos; 18.538 fusiones. Todo lo demás va a
la cola, que se revisa en el orden del ejercicio 20.

**La defensa ante Norma** empieza por el costo del error, no por el porcentaje. Un falso positivo pone en el
informe que ella firma los antecedentes de otra persona. La regla con mejores números de la fase (0,6, con
0,89 % de falsos) haría eso 364 veces en M. El nivel 1 no lo hizo ninguna vez contra la verdad de la caja, y
cada fusión queda con quién y cuándo, y se puede deshacer (ejercicio 22).

**Lo que hay que admitir:** el 0 es de esta caja, que no simula un DNI mal tipeado que coincida con otra
persona nacida el mismo día. Por eso se propone una auditoría: una muestra de las fusiones automáticas,
revisada a mano cada mes, con el número publicado.

**Rúbrica.** Una respuesta correcta tiene que:
- proponer una regla con su precisión y su exhaustividad medidas;
- poner el costo asimétrico del error por delante del porcentaje;
- decir qué pasa con lo que no fusiona y cómo se deshace una fusión equivocada;
- admitir el límite de la medición y proponer cómo vigilarlo.

Y queda invalidada si:
- elige el umbral que maximiza la exhaustividad;
- propone borrar los duplicados.

[← Volver al ejercicio](../05-una-persona-no-es-su-documento.md#-ejercicio-24--el-umbral-de-norma)
