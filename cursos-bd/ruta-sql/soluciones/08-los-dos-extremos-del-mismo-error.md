# ✅ Soluciones — Fase 08: Los dos extremos del mismo error

> **Curso:** Ruta SQL · Solucionario de la [Fase 08](../08-los-dos-extremos-del-mismo-error.md)
> **Ejercicios:** 26 · **Perfil:** M · **Motores:** Postgres de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todas las soluciones suponen el modelo de `uv run lab load --profile m --model`. El boss del bloque no está aquí:
es un encargo, y su solución no se publica.

Las estimaciones de filas de los planes cambian un poco cada vez que se corre `ANALYZE`, porque las estadísticas
salen de una muestra. Los bloques y las filas reales no cambian.

---

## 🟢 Fácil (1–7)

### Ejercicio 1

**Enunciado (resumen):** las tablas anchas en el catálogo.

**Solución.**

```sql
-- postgres
SELECT count(*) AS tablas_anchas,
       string_agg(table_name, ', ' ORDER BY table_name)
         FILTER (WHERE table_name IN ('Quimica', 'Hemograma', 'HemoglobinaGlicosilada')) AS ejemplos
FROM (SELECT table_name FROM information_schema.columns WHERE table_schema = 'legacy' AND column_name = 'Obs'
      INTERSECT
      SELECT table_name FROM information_schema.columns WHERE table_schema = 'legacy' AND column_name = 'IdProtocolo') AS t;
```

```text
 tablas_anchas |                  ejemplos
---------------+--------------------------------------------
            71 | HemoglobinaGlicosilada, Hemograma, Quimica
(1 row)
```

El catálogo encuentra lo que la historia cuenta: una tabla por examen, todas con el protocolo y una columna de
observaciones para lo que no entraba en las demás.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-1--las-71-tablas-anchas)

### Ejercicio 2

**Enunciado (resumen):** los estados del valor.

**Solución.**

```sql
-- postgres
SELECT state, count(*) FROM truth.result_value GROUP BY 1 ORDER BY 2 DESC;
```

```text
    state    |  count
-------------+---------
 comma       | 5405033
 dot         | 5377744
 below       |  359747
 empty       |  359737
 above       |  239894
 hemolyzed   |  239687
 qualitative |  152611
(7 rows)
```

`hemolyzed` agrupa las tres observaciones sobre la muestra (`HEMOLIZADA`, `REPETIR` y `MUESTRA INSUFICIENTE`).
Son proporciones que el generador fija (D30 en `a05`), así que tu caja da exactamente estas.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-2--los-estados-del-valor)

### Ejercicio 3

**Enunciado (resumen):** convertir el texto a número.

**Solución.**

```sql
-- postgres
SELECT count(*) FROM staging.result_eav WHERE analyte_code = 'GLU' AND value::numeric > 126;
```

```text
ERROR:  invalid input syntax for type numeric: "HEMOLIZADA"
```

Un solo valor que no es un número aborta la consulta entera, y lo mismo pasa con el `replace` de la coma y el
`ltrim` de los calificadores agregados.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-3--el-primer-hemolizada)

### Ejercicio 4

**Enunciado (resumen):** filas y tamaño de los cuatro modelos.

**Solución.**

```sql
-- postgres
SELECT (SELECT count(*) FROM alameda.lab_order) AS protocolos, (SELECT count(*) FROM alameda.result) AS tipado,
       (SELECT count(*) FROM staging.result_eav) AS eav, (SELECT count(*) FROM staging.result_wide) AS ancha,
       (SELECT count(*) FROM staging.result_document) AS documento;
SELECT 'tipado' AS modelo, pg_size_pretty(pg_table_size('alameda.result')) AS tabla, pg_size_pretty(pg_indexes_size('alameda.result')) AS indices
UNION ALL SELECT 'eav', pg_size_pretty(pg_table_size('staging.result_eav')), pg_size_pretty(pg_indexes_size('staging.result_eav'))
UNION ALL SELECT 'ancha', pg_size_pretty(pg_table_size('staging.result_wide')), pg_size_pretty(pg_indexes_size('staging.result_wide'))
UNION ALL SELECT 'jsonb', pg_size_pretty(pg_table_size('staging.result_document')), pg_size_pretty(pg_indexes_size('staging.result_document'));
```

```text
 protocolos |  tipado  |   eav    |  ancha  | documento
------------+----------+----------+---------+-----------
    1327622 | 12132303 | 12132303 | 1276062 |   1276062
(1 row)

 modelo |  tabla  | indices
--------+---------+---------
 tipado | 684 MB  | 448 MB
 eav    | 1049 MB | 368 MB
 ancha  | 109 MB  | 27 MB
 jsonb  | 294 MB  | 27 MB
(4 rows)
```

Hay 1.327.622 protocolos y 1.276.062 con resultados: los demás son anteriores a abril de 2008 (sus resultados
están en las tablas anchas) o no tienen ninguno.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-4--los-cuatro-modelos)

### Ejercicio 5

**Enunciado (resumen):** el parser contra la verdad.

**Solución.**

```sql
-- postgres
SELECT t.state, count(*) AS filas,
       count(*) FILTER (WHERE r.value_numeric IS NOT DISTINCT FROM t.value_numeric
                          AND r.qualifier IS NOT DISTINCT FROM t.qualifier
                          AND r.value_text IS NOT DISTINCT FROM t.value_text) AS iguales
FROM alameda.result AS r JOIN truth.result_value AS t ON t.legacy_result_item_id = r.result_id
GROUP BY 1 ORDER BY 2 DESC;
```

```text
    state    |  filas  | iguales
-------------+---------+---------
 comma       | 5404040 | 5404040
 dot         | 5376808 | 5376808
 below       |  359687 |  359687
 empty       |  359662 |  359662
 above       |  239851 |  239851
 hemolyzed   |  239644 |  239644
 qualitative |  152611 |  152611
(7 rows)
```

Las filas son las de la verdad menos las de los 2.150 resultados huérfanos de la Fase 04, que el modelo no
carga. `IS NOT DISTINCT FROM` compara también los `NULL`: con `=`, ningún vacío contaría como igual.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-5--el-parser-contra-la-verdad)

### Ejercicio 6

**Enunciado (resumen):** un informe en los cuatro modelos.

**Solución.**

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF)
SELECT r.analyte_code, r.value_numeric, r.qualifier, r.value_text, r.sample_flag, a.unit, a.reference_range
FROM alameda.result AS r JOIN alameda.analyte AS a USING (analyte_code) WHERE r.lab_order_id = 11232670;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF)
SELECT analyte_code, value, unit, reference_range FROM staging.result_eav WHERE lab_order_id = 11232670;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) SELECT * FROM staging.result_wide WHERE lab_order_id = 11232670;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) SELECT results FROM staging.result_document WHERE lab_order_id = 11232670;
```

Las primeras líneas de cada plan:

```text
 Hash Join (actual rows=13.00 loops=1)
   Buffers: shared hit=3 read=3

 Bitmap Heap Scan on result_eav (actual rows=13.00 loops=1)
   Buffers: shared hit=1 read=3

 Index Scan using result_wide_pkey on result_wide (actual rows=1.00 loops=1)
   Buffers: shared hit=3 read=1

 Index Scan using result_document_pkey on result_document (actual rows=1.00 loops=1)
   Buffers: shared hit=3 read=1
```

El tipado lee dos bloques más porque busca la unidad y el rango en `alameda.analyte`, que el EAV repite en cada
fila. Seis contra cuatro bloques no deciden nada.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-6--un-informe-en-cuatro-modelos)

### Ejercicio 7

**Enunciado (resumen):** el documento de un protocolo.

**Solución.**

```sql
-- postgres
SELECT lab_order_id, results FROM staging.result_document WHERE lab_order_id = 11000001;
```

```text
 lab_order_id |                                                results
--------------+-------------------------------------------------------------------------------------------------------
     11000001 | {"tg": 393.0000, "col": 116.0000, "hdl": 42.0000, "ldl": "<25.0000", "urea": 32.0000, "uric": 4.0000}
(1 row)
```

El valor con calificador queda como **texto**: `"<25.0000"`. Es una decisión de `05_jsonb.sql`, no del tipo
`jsonb`: se podría guardar como un objeto (`{"value": 25, "qualifier": "<"}`). Así como está, cualquier consulta
que compare números ignora los valores con calificador sin avisar, igual que la consulta clínica de la fase.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-7--el-documento)

---

## 🟡 Intermedio (8–14)

### Ejercicio 8

**Enunciado (resumen):** la consulta clínica en el modelo tipado.

**Solución.** La consulta es la de la sección 5.3, con `EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, SUMMARY ON)`
delante. Las líneas que importan:

```text
 Aggregate  (cost=422787.50..422787.51 rows=1 width=8) (actual rows=1.00 loops=1)
   Buffers: shared hit=107001 read=69901, temp read=2009 written=2009
   ->  Hash Join  (cost=216680.85..408524.70 rows=141842 width=0) (actual rows=31083.00 loops=1)
               ->  Gather  (cost=1000.00..187674.98 rows=230695 width=4) (actual rows=428014.00 loops=1)
                     ->  Parallel Seq Scan on result r  (cost=0.00..163605.48 rows=96123 width=4) (actual rows=142671.33 loops=3)
                           Filter: ((qualifier IS NULL) AND (value_numeric > '126'::numeric) AND ((analyte_code)::text = 'GLU'::text))
                                 ->  Parallel Seq Scan on result r_1  (cost=0.00..163605.48 rows=121150 width=4) (actual rows=83053.67 loops=3)
                                       Filter: ((qualifier IS NULL) AND (value_numeric > 6.5) AND ((analyte_code)::text = 'HBA1C'::text))
```

176.902 bloques: la tabla entera dos veces (unos 87.800 cada una) y el índice de fechas. Sin el `count(*)` y sin
`EXPLAIN`, devuelve 31.083.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-8--en-el-modelo-tipado)

### Ejercicio 9

**Enunciado (resumen):** la misma consulta en el EAV.

**Solución.**

```sql
-- postgres
WITH o AS (SELECT lab_order_id, patient_id FROM alameda.lab_order WHERE ordered_on >= '2024-01-01' AND ordered_on < '2025-01-01'),
     d AS (SELECT DISTINCT o.patient_id FROM o JOIN staging.result_eav AS r USING (lab_order_id)
           WHERE r.analyte_code = 'HBA1C'
             AND CASE WHEN r.value ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(r.value, ',', '.')::numeric END > 6.5)
SELECT count(*) FROM o JOIN d USING (patient_id) JOIN staging.result_eav AS r USING (lab_order_id)
WHERE r.analyte_code = 'GLU'
  AND CASE WHEN r.value ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(r.value, ',', '.')::numeric END > 126;
```

```text
 Aggregate  (cost=600103.57..600103.58 rows=1 width=8) (actual rows=1.00 loops=1)
   Buffers: shared hit=1924 read=267836, temp read=1797 written=1797
   ->  Hash Join  (cost=296874.42..585703.82 rows=196627 width=0) (actual rows=31083.00 loops=1)
```

269.760 bloques y 31.083 glucemias. La expresión regular deja afuera los valores con calificador, igual que
`qualifier IS NULL` en el tipado: por eso las dos dan lo mismo.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-9--en-el-eav)

### Ejercicio 10

**Enunciado (resumen):** la misma consulta en la tabla ancha.

**Solución.**

```sql
-- postgres
WITH o AS (SELECT lab_order_id, patient_id FROM alameda.lab_order WHERE ordered_on >= '2024-01-01' AND ordered_on < '2025-01-01'),
     d AS (SELECT DISTINCT o.patient_id FROM o JOIN staging.result_wide AS w USING (lab_order_id)
           WHERE CASE WHEN w.hba1c ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(w.hba1c, ',', '.')::numeric END > 6.5)
SELECT count(*) FROM o JOIN d USING (patient_id) JOIN staging.result_wide AS w USING (lab_order_id)
WHERE CASE WHEN w.glu ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(w.glu, ',', '.')::numeric END > 126;
```

```text
 Aggregate  (cost=120986.68..120986.69 rows=1 width=8) (actual rows=1.00 loops=1)
   Buffers: shared hit=15324 read=13980 written=1161, temp read=1071 written=1071
   ->  Hash Join  (cost=62379.09..106995.91 rows=33034 width=0) (actual rows=31083.00 loops=1)
```

29.304 bloques. Lo que la tabla ancha no tiene es una condición por determinación: la columna ya es la
determinación, y una fila por protocolo pesa muy poco cuando casi todas sus columnas están vacías.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-10--en-la-tabla-ancha)

### Ejercicio 11

**Enunciado (resumen):** la misma consulta en el documento.

**Solución.**

```sql
-- postgres
WITH o AS (SELECT lab_order_id, patient_id FROM alameda.lab_order WHERE ordered_on >= '2024-01-01' AND ordered_on < '2025-01-01'),
     d AS (SELECT DISTINCT o.patient_id FROM o JOIN staging.result_document AS j USING (lab_order_id)
           WHERE CASE WHEN jsonb_typeof(j.results -> 'hba1c') = 'number' THEN (j.results ->> 'hba1c')::numeric END > 6.5)
SELECT count(*) FROM o JOIN d USING (patient_id) JOIN staging.result_document AS j USING (lab_order_id)
WHERE CASE WHEN jsonb_typeof(j.results -> 'glu') = 'number' THEN (j.results ->> 'glu')::numeric END > 126;
```

```text
 Aggregate  (cost=181645.60..181645.61 rows=1 width=8) (actual rows=1.00 loops=1)
   Buffers: shared hit=1637 read=75611, temp read=1071 written=1071
   ->  Hash Join  (cost=92707.56..167654.83 rows=33034 width=0) (actual rows=31083.00 loops=1)
```

77.248 bloques. El `CASE` con `jsonb_typeof` hace en el documento lo que la expresión regular hace en el texto:
deja afuera `"<25.0000"` y `"HEMOLIZADA"`.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-11--en-el-documento)

### Ejercicio 12

**Enunciado (resumen):** las estimaciones del join final.

**Solución.** De los cuatro planes:

| Modelo | Estimadas | Reales | Error |
|---|---|---|---|
| EAV | 196.627 | 31.083 | 6,3× |
| tipado | 141.842 | 31.083 | 4,6× |
| `jsonb` | 33.034 | 31.083 | 1,06× |
| ancha | 33.034 | 31.083 | 1,06× |

En los modelos de una fila por protocolo, la condición es una expresión sobre una sola fila, y el optimizador,
que no sabe nada de una expresión, usa su selectividad por defecto: un tercio. En esta caja, un tercio de los
protocolos tiene una glucemia mayor que 126, así que acierta por casualidad (425.354 estimadas contra 428.014
reales en el recorrido). En los modelos de una fila por resultado, la condición combina la determinación y el
valor, Postgres multiplica sus selectividades como si fueran independientes, y el error se agranda en cada join
con los protocolos y en el `DISTINCT` por paciente.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-12--las-estimaciones)

### Ejercicio 13

**Enunciado (resumen):** la expresión regular delante de la conversión.

**Solución.**

```sql
-- postgres
SELECT count(*) FROM staging.result_eav
WHERE value ~ '^[0-9]+([.,][0-9]+)?$' AND analyte_code = 'GLU' AND replace(value, ',', '.')::numeric > 126;
```

```text
 count
--------
 428014
(1 row)
```

Funciona porque esta vez el plan evaluó la expresión regular primero. La documentación de Postgres lo dice sin
vueltas: el orden de evaluación de las partes de una expresión no está definido, y un `AND` no garantiza que la
izquierda se evalúe antes. Con otro plan, otras estadísticas u otra versión, el mismo `HEMOLIZADA` aparece. El
`CASE` sí garantiza el orden.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-13--el-orden-del-and)

### Ejercicio 14

**Enunciado (resumen):** personas con glucemias en las dos épocas.

**Solución.**

```sql
-- postgres
WITH viejas AS (SELECT DISTINCT r.person_id FROM legacy."Quimica" AS q
                JOIN legacy."Protocolos" AS o ON o."IdProtocolo" = q."IdProtocolo"
                JOIN truth.patient_record AS r ON r.legacy_patient_id = o."IdPaciente"
                WHERE q."Glucemia" IS NOT NULL),
     nuevas AS (SELECT DISTINCT r.person_id FROM alameda.result AS x
                JOIN legacy."Protocolos" AS o ON o."IdProtocolo" = x.lab_order_id
                JOIN truth.patient_record AS r ON r.legacy_patient_id = o."IdPaciente"
                WHERE x.analyte_code = 'GLU')
SELECT (SELECT count(*) FROM viejas) AS viejas, (SELECT count(*) FROM nuevas) AS nuevas,
       (SELECT count(*) FROM viejas JOIN nuevas USING (person_id)) AS ambas;
```

```text
 viejas | nuevas | ambas
--------+--------+-------
   7382 | 175030 |  7377
(1 row)
```

La solución cuenta personas con la verdad del generador, que sabe quién es quién. Con el modelo, sin la verdad,
habría que contar por el paciente que sobrevivió a la fusión, y daría más, porque la Fase 05 no fusionó a todos.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-14--las-dos-épocas)

---

## 🟠 Difícil (15–20)

### Ejercicio 15

**Enunciado (resumen):** un índice sobre el valor en el tipado.

**Solución.**

```sql
-- postgres
CREATE INDEX result_analyte_code_value_numeric_idx ON alameda.result (analyte_code, value_numeric);
ANALYZE alameda.result;
-- la consulta clínica, con EXPLAIN (ANALYZE, BUFFERS)
```

```text
 Aggregate  (cost=383269.98..383269.99 rows=1 width=8) (actual rows=1.00 loops=1)
   Buffers: shared hit=15059 read=161387 written=12, temp read=2009 written=2009
                     ->  Parallel Bitmap Heap Scan on result r  (cost=6172.13..142047.03 rows=97691 width=4) (actual rows=142671.33 loops=3)
                           ->  Bitmap Index Scan on result_analyte_code_value_numeric_idx  (cost=0.00..6113.52 rows=246496 width=0) (actual rows=442426.00 loops=1)
```

El plan usa el índice y lee 176.446 bloques: casi lo mismo. Las 428.014 glucemias mayores que 126 están
repartidas en toda la tabla, porque se cargaron en el orden de los protocolos, y el índice las encuentra pero
el *heap* tiene que visitar casi todas sus páginas. Un índice no cambia dónde están las filas; el orden físico y
el particionado son de la [Fase 09](../09-el-tamano-de-las-cosas.md).

**Rúbrica.** Una respuesta correcta tiene que:
- ver que el índice se usa y que los bloques no bajan;
- explicarlo por la distribución de las filas en las páginas, no por el índice.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-15--un-índice-sobre-el-valor)

### Ejercicio 16

**Enunciado (resumen):** estadísticas extendidas.

**Solución.**

```sql
-- postgres
CREATE STATISTICS result_analyte_code_value_numeric_stat (mcv, dependencies)
    ON analyte_code, value_numeric FROM alameda.result;
ANALYZE alameda.result;
-- la consulta clínica, con EXPLAIN (ANALYZE, BUFFERS)
```

```text
   ->  Hash Join  (cost=218729.13..412838.85 rows=150205 width=0) (actual rows=31083.00 loops=1)
               ->  Gather  (cost=1000.00..189614.49 rows=250100 width=4) (actual rows=428014.00 loops=1)
```

La estimación no mejora (150.205 contra 31.083). Las estadísticas `mcv` guardan las combinaciones más
frecuentes de valores, y con un número continuo casi no hay combinaciones repetidas; `dependencies` sirve para
igualdades, no para un `>`. Lo que le falta al optimizador es un histograma del valor **por determinación**, y
Postgres no lo tiene. La [Fase 12](../12-estadisticas-y-cardinalidad.md) vuelve sobre esto.

**Rúbrica.** Una respuesta correcta tiene que:
- medir antes y después con la misma consulta;
- explicar por qué ni `mcv` ni `dependencies` describen "glucemias mayores que 126".

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-16--estadísticas-extendidas)

### Ejercicio 17

**Enunciado (resumen):** por qué el EAV pesa más.

**Solución.**

```sql
-- postgres
SELECT pg_size_pretty(sum(pg_column_size(unit) + pg_column_size(reference_range))::bigint) AS unidad_y_rango,
       pg_size_pretty(sum(pg_column_size(value))::bigint) AS valor_texto
FROM staging.result_eav;
SELECT pg_size_pretty(sum(pg_column_size(value_numeric))::bigint) AS numero,
       pg_size_pretty(sum(coalesce(pg_column_size(qualifier), 0) + coalesce(pg_column_size(value_text), 0)
                          + coalesce(pg_column_size(sample_flag), 0))::bigint) AS resto
FROM alameda.result;
```

```text
 unidad_y_rango | valor_texto
----------------+-------------
 230 MB         | 55 MB

 numero |  resto
--------+---------
 64 MB  | 5882 kB
```

Casi toda la diferencia (365 MB entre 1.049 y 684) son los 230 MB de unidad y rango repetidos, que la Fase 04 ya
había medido, más el equipo y el resto de las columnas de texto. El número como texto (55 MB) y como `numeric`
(64 MB) pesan parecido: lo que ahorra el tipado no es el formato del número, es no repetir lo que es de la
determinación.

**Rúbrica.** Una respuesta correcta tiene que:
- medir por columna, no por tabla;
- atribuir la diferencia a la dependencia transitiva, no al tipo del valor.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-17--el-peso-de-una-fila)

### Ejercicio 18

**Enunciado (resumen):** dos filas contra el `CHECK`.

**Solución.**

```sql
-- postgres
BEGIN;
INSERT INTO alameda.result VALUES (-1, 10197772, 'GLU', 126, NULL, NULL, 'HEMOLIZADA', now());
ROLLBACK;
BEGIN;
INSERT INTO alameda.result VALUES (-1, 10197772, 'GLU', NULL, '<', NULL, NULL, now());
ROLLBACK;
```

```text
ERROR:  new row for relation "result" violates check constraint "result_value_check"
DETAIL:  Failing row contains (-1, 10197772, GLU, 126.0000, null, null, HEMOLIZADA, 2026-10-14 05:41:33.971129).
ERROR:  new row for relation "result" violates check constraint "result_value_check"
DETAIL:  Failing row contains (-1, 10197772, GLU, null, <, null, null, 2026-10-14 05:41:33.973695).
```

Una muestra hemolizada no tiene valor, y un `<` sin número no dice nada. En el EAV, las dos filas entrarían como
texto.

**Rúbrica.** Una respuesta correcta tiene que:
- reproducir los dos errores;
- decir qué regla del laboratorio expresa cada parte del `CHECK`.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-18--el-check-del-valor)

### Ejercicio 19

**Enunciado (resumen):** las glucemias de las tablas anchas.

**Solución.**

```sql
-- postgres
SELECT count(*) AS valores,
       count(*) FILTER (WHERE "Glucemia" ~ '^\s*[<>]?\s*[0-9]+([.,][0-9]+)?\s*$') AS numericos,
       count(*) FILTER (WHERE "Glucemia" !~ '^\s*[<>]?\s*[0-9]+([.,][0-9]+)?\s*$') AS no_numericos
FROM legacy."Quimica" WHERE "Glucemia" IS NOT NULL;
SELECT "Glucemia", count(*) FROM legacy."Quimica"
WHERE "Glucemia" !~ '^\s*[<>]?\s*[0-9]+([.,][0-9]+)?\s*$' GROUP BY 1 ORDER BY 2 DESC;
```

```text
 valores | numericos | no_numericos
---------+-----------+--------------
   32564 |     31260 |         1304

 Glucemia | count
----------+-------
 VER OBS  |   447
          |   442
 -        |   415
```

Tres formas de decir "no hay valor", y ninguna es una de las del EAV. `VER OBS` manda a la columna `Obs`, donde
puede estar el valor o la razón; un parser para las tablas anchas tiene que decidir qué hacer con cada una, y
documentarlo, antes de juntarlas con el modelo tipado.

**Rúbrica.** Una respuesta correcta tiene que:
- separar lo numérico de lo que no lo es con el mismo patrón que el modelo;
- proponer qué hace el modelo con cada una de las tres formas.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-19--las-tablas-anchas-al-modelo-tipado)

### Ejercicio 20

**Enunciado (resumen):** el documento con un índice GIN.

**Solución.**

```sql
-- postgres
CREATE INDEX result_document_results_idx ON staging.result_document USING gin (results jsonb_path_ops);
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF)
SELECT count(*) FROM staging.result_document WHERE results @? '$.glu ? (@ > 126)';
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF)
SELECT count(*) FROM staging.result_document WHERE results @> '{"glu": 126}';
```

```text
               ->  Parallel Seq Scan on result_document (actual rows=142671.33 loops=3)
                     Filter: (results @? '$."glu"?(@ > 126)'::jsonpath)
   Buffers: shared hit=576 read=37376

   ->  Bitmap Heap Scan on result_document (actual rows=3251.00 loops=1)
         ->  Bitmap Index Scan on result_document_results_idx (actual rows=3251.00 loops=1)
               Index Cond: (results @> '{"glu": 126}'::jsonb)
   Buffers: shared hit=129 read=2967
```

`jsonb_path_ops` indexa pares de camino y valor: sirve para igualdades (`@>`, y `@?` con `==`), no para
comparaciones de orden. La pregunta clínica es un `>`, y el índice no la ayuda; "glucemia exactamente 126", sí. Es
la diferencia entre un documento consultado por contenido y uno consultado por rango, y es del Bloque IV.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar los dos planes;
- explicar qué operadores acelera la clase de operador.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-20--el-documento-con-índice)

---

## 🔴 Muy difícil (21–26)

### Ejercicio 21

**Enunciado (resumen):** la vitamina D en los cuatro modelos.

**Solución de referencia.**

- **Tipado:** `INSERT INTO alameda.analyte VALUES ('VITD', 'Vitamina D', 'ng/mL', '30 - 100', …)`. Ninguna
  consulta cambia.
- **EAV:** nada; el primer resultado con `analyte_code = 'VITD'` lo crea. Ninguna consulta cambia, y ninguna
  regla defiende que el código exista.
- **`jsonb`:** nada; la clave `"vitd"` aparece en los documentos nuevos. Ninguna consulta cambia, y ninguna
  regla defiende el nombre de la clave (`"vit_d"` y `"vitd"` serían dos determinaciones).
- **Ancha:** `ALTER TABLE staging.result_wide ADD COLUMN vitd varchar(50)`, y cada consulta que liste columnas, o
  una tabla ancha nueva, como hacía Rubén.

**Rúbrica.** Una respuesta correcta tiene que:
- dar la sentencia de cada modelo;
- distinguir "no hay que cambiar nada" de "nada lo controla".

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-21--una-determinación-nueva)

### Ejercicio 22

**Enunciado (resumen):** un dato que está bien en un EAV.

**Solución de referencia.** Las observaciones de las tablas anchas (`Obs`) y los campos que cada equipo agrega a
un resultado y nadie filtra (la lectura del equipo, un número de lote, una nota del bioquímico). Se leen con el
informe y no se consultan por valor: nadie pregunta "¿qué protocolos tienen el lote 4471?" sin saber antes el
protocolo. Un EAV (`result_note`: resultado, clave, valor como texto) los guarda sin un `ALTER TABLE` por cada
equipo nuevo, y no promete tipos que no tiene.

**Rúbrica.** Una respuesta correcta tiene que:
- elegir un dato real de la caja o de la historia;
- argumentar que no se consulta por valor;
- decir qué regla se pierde y por qué no importa.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-22--cuándo-gana-el-eav)

### Ejercicio 23

**Enunciado (resumen):** la consulta clínica con los valores calificados.

**Solución de referencia.** La regla clínica: un `>x` con `x ≥ 126` es mayor que 126; un `<x` no lo es para
este umbral, y en la caja los `<` de glucemia llegan hasta 30 y los de glicosilada hasta 2,1.

```sql
-- postgres
WITH o AS (SELECT lab_order_id, patient_id FROM alameda.lab_order WHERE ordered_on >= '2024-01-01' AND ordered_on < '2025-01-01'),
     d AS (SELECT DISTINCT o.patient_id FROM o JOIN alameda.result AS r USING (lab_order_id)
           WHERE r.analyte_code = 'HBA1C'
             AND (r.qualifier IS NULL AND r.value_numeric > 6.5 OR r.qualifier = '>' AND r.value_numeric >= 6.5))
SELECT count(*) FROM o JOIN d USING (patient_id) JOIN alameda.result AS r USING (lab_order_id)
WHERE r.analyte_code = 'GLU'
  AND (r.qualifier IS NULL AND r.value_numeric > 126 OR r.qualifier = '>' AND r.value_numeric >= 126);
```

```text
 count
-------
 32691
(1 row)
```

1.608 glucemias más. La consulta original las ignoraba sin avisar, y en los otros tres modelos habría que
escribir esta regla sobre texto.

**Rúbrica.** Una respuesta correcta tiene que:
- escribir la regla para `<` y para `>` y justificarla;
- medir la diferencia.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-23--los-valores-con-calificador)

### Ejercicio 24

**Enunciado (resumen):** la consulta clínica con `lab measure`.

**Solución de referencia.**

```text
📐 lab measure · postgres · perfil m · caja 3e59292e9918 · pgvector/pgvector:0.8.7-pg18@sha256:2358fcba361e…
filas devueltas: 1 (estimadas: 1)
bloques: 176903 (en caché 99726, leídos 77177)
filas examinadas en las hojas del plan: 24805266
plan:
  Aggregate · estimadas 1 · reales 1 · bloques 176903
    Bitmap Heap Scan on lab_order · estimadas 180774 · reales 180220 · bloques 1345
      Bitmap Index Scan using lab_order_ordered_on_idx · estimadas 180774 · reales 180220 · bloques 162
    Hash Join · estimadas 155947 · reales 31083 · bloques 176903
      Hash Join · estimadas 155947 · reales 68659 · bloques 89124
        Gather · estimadas 237891 · reales 428014 · bloques 87779
          Seq Scan on result · estimadas 99121 · reales 428014.0 · descartadas 11704290 · bloques 87779
…
tiempo: 1362.9 ms (contexto, no argumento)
```

La línea del error es `Hash Join · estimadas 155947 · reales 31083`: cinco veces. La estimación es otra que en la
fase (141.842) porque entre las dos corridas hubo un `ANALYZE`; los bloques (176.903) son los mismos. Las
24.805.266 filas examinadas son las dos lecturas enteras de `result`.

**Rúbrica.** Una respuesta correcta tiene que:
- señalar el nodo donde la estimación se separa de lo real;
- explicar por qué la estimación cambió y los bloques no.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-24--con-lab-measure)

### Ejercicio 25

**Enunciado (resumen):** por qué el Bloque II arranca con el tipado.

**Solución de referencia.** Tres argumentos, con números:

1. **Se convierte una vez.** El parser coincide con la verdad en los 12.132.303 resultados, y después nadie más
   convierte: en el EAV, cada consulta repite la conversión y arriesga el `HEMOLIZADA`.
2. **El motor lo defiende.** El `CHECK` rechaza un número con bandera de muestra; el EAV lo guarda.
3. **Pesa lo que tiene que pesar.** 684 MB contra 1.049, porque la unidad y el rango son de la determinación.

Y lo que se le reconoce a Matías: la forma es la suya. Una fila por resultado, sin un `ALTER TABLE` por
determinación nueva. El modelo tipado es su EAV terminado.

**Rúbrica.** Una respuesta correcta tiene que:
- usar números de la fase, no adjetivos;
- reconocer lo que el EAV resolvió bien;
- no afirmar que el tipado gana las mediciones de la fase, porque no las gana.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-25--el-modelo-del-bloque-ii)

### Ejercicio 26

**Enunciado (resumen):** ¿documento o tipado como fuente?

**Solución de referencia.** El tipado es la fuente y el documento se deriva. La lectura del informe cuesta lo mismo
en los dos (cuatro y seis bloques), así que servir desde el documento no compra nada en la lectura de uno; en la
consulta clínica, el documento lee menos (77.248 contra 176.902), pero no defiende nada: un `"glu":
"HEMOLIZADA"` entra igual que un número. Si el portal o la app necesitan el documento, se arma desde el tipado
(como hace `05_jsonb.sql`), y se mantiene con la escritura: una vista materializada, o una tabla que se actualiza
en la misma transacción que el resultado. Eso es el boss del Bloque IV.

**Rúbrica.** Una respuesta correcta tiene que:
- decidir cuál es la fuente y cuál se deriva;
- usar las dos mediciones (informe y consulta clínica);
- decir cómo se mantiene el derivado, y cuándo puede atrasarse.

Y queda invalidada si:
- elige el documento como fuente porque leyó menos bloques en la consulta clínica, sin decir qué pierde.

[← Volver al ejercicio](../08-los-dos-extremos-del-mismo-error.md#-ejercicio-26--documento-o-tipado)
