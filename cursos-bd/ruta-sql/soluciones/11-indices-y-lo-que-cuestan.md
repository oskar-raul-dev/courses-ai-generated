# ✅ Soluciones — Fase 11: Índices y lo que cuestan

> **Curso:** Ruta SQL · Solucionario de la [Fase 11](../11-indices-y-lo-que-cuestan.md)
> **Ejercicios:** 28 · **Perfil:** M · **Motores:** Postgres y MySQL de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todas las soluciones suponen el modelo de `uv run lab load --profile m --model`, las tablas de staging de las fases 08 a 10,
y los scripts de `src/11-indices-y-lo-que-cuestan/` corridos con `psql` (los dos primeros usan `\gset` y `\ir`). Para comparar
dos índices sobre la misma consulta, las soluciones borran el otro dentro de una transacción que después se deshace: el DDL de
Postgres es transaccional.

---

## 🟢 Fácil (1–7)

### Ejercicio 1

**Enunciado (resumen):** las columnas del `AutoIndex`.

**Solución.**

```sql
-- postgres
SELECT count(*) AS columnas, count(DISTINCT table_name) AS tablas
FROM information_schema.columns
WHERE table_schema = 'legacy' AND (column_name ~* '(id|key|code|num)$' OR column_name ~* '^(id|key|code|num)');
```

```text
 columnas | tablas
----------+--------
      135 |     98
(1 row)
```

La documentación de Access dice que la opción compara el comienzo o el final del nombre; la lista `ID;key;code;num` es la que
reportan los usuarios como valor de fábrica. `~*` compara sin distinguir mayúsculas, como Access.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-1--el-autoindex-sobre-la-caja)

### Ejercicio 2

**Enunciado (resumen):** las glucemias de octubre de 2024 con `(analyte_code, recorded_at)`.

**Solución.**

```sql
-- postgres
BEGIN;
DROP INDEX staging.result_recent_recorded_at_analyte_code_idx;
DROP INDEX staging.result_recent_recorded_at_brin;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_recent
WHERE analyte_code = 'GLU' AND recorded_at >= '2024-10-01' AND recorded_at < '2024-11-01';
ROLLBACK;
```

```text
 Aggregate (actual rows=1.00 loops=1)
   Buffers: shared hit=1 read=36
   ->  Index Only Scan using result_recent_analyte_code_recorded_at_idx on result_recent (actual rows=9671.00 loops=1)
         Index Cond: ((analyte_code = 'GLU'::text) AND (recorded_at >= '2024-10-01 00:00:00'::timestamp without time zone) AND (recorded_at < '2024-11-01 00:00:00'::timestamp without time zone))
         Heap Fetches: 0
         Index Searches: 1
```

Una búsqueda, un tramo contiguo del índice, y ninguna visita a la tabla: las dos columnas que pide `count(*)` con ese filtro
están en el índice.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-2--el-compuesto-bien-ordenado)

### Ejercicio 3

**Enunciado (resumen):** la misma con `(recorded_at, analyte_code)`.

**Solución.** Lo mismo, borrando el otro compuesto y el BRIN en la transacción:

```text
 Aggregate (actual rows=1.00 loops=1)
   Buffers: shared hit=16 read=577
   ->  Index Only Scan using result_recent_recorded_at_analyte_code_idx on result_recent (actual rows=9671.00 loops=1)
         Heap Fetches: 0
         Index Searches: 1
```

593 bloques: el tramo de octubre entero, con las 33 determinaciones mezcladas, y la de glucemia filtrada dentro del índice. Con
la igualdad primero, el tramo es solo el de las glucemias.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-3--el-compuesto-al-revés)

### Ejercicio 4

**Enunciado (resumen):** el *skip scan*.

**Solución.**

```sql
-- postgres
BEGIN;
DROP INDEX staging.result_recent_recorded_at_analyte_code_idx;
DROP INDEX staging.result_recent_recorded_at_brin;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_recent WHERE recorded_at >= '2024-10-15' AND recorded_at < '2024-10-16';
ROLLBACK;
```

```text
 Aggregate (actual rows=1.00 loops=1)
   Buffers: shared hit=85 read=154
   ->  Index Only Scan using result_recent_analyte_code_recorded_at_idx on result_recent (actual rows=5397.00 loops=1)
         Heap Fetches: 0
         Index Searches: 65
         Buffers: shared hit=85 read=154
```

Unas dos búsquedas por cada una de las 33 determinaciones: una para encontrar el valor siguiente de la primera columna y otra
para el rango de fechas dentro de él. Antes de Postgres 18 el plan habría sido una recorrida de la tabla o del índice entero.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-4--el-skip-scan)

### Ejercicio 5

**Enunciado (resumen):** el tamaño del índice parcial.

**Solución.**

```sql
-- postgres
SELECT c.relname, pg_size_pretty(pg_relation_size(c.oid))
FROM pg_class AS c JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE n.nspname = 'staging' AND c.relname LIKE 'result_recent%' ORDER BY 1;
```

```text
                  relname                   | pg_size_pretty
--------------------------------------------+----------------
 result_recent                              | 225 MB
 result_recent_analyte_code_recorded_at_idx | 110 MB
 result_recent_glu_value_idx                | 5232 kB
 result_recent_lab_order_id_incl_idx        | 121 MB
 result_recent_pkey                         | 85 MB
 result_recent_recorded_at_analyte_code_idx | 110 MB
 result_recent_recorded_at_brin             | 24 kB
(7 rows)
```

El parcial indexa solo las glucemias, que son una de cada diecisiete filas: 5.232 kB.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-5--el-tamaño-de-un-parcial)

### Ejercicio 6

**Enunciado (resumen):** el tamaño del BRIN.

**Solución.** En la misma lista: 24 kB el BRIN, 110 MB cualquiera de los B-tree que empiezan o terminan en la fecha. El BRIN
guarda dos valores por cada 128 páginas de tabla (225 MB son unas 28.800 páginas, unos 225 rangos), no un valor por fila.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-6--el-tamaño-de-un-brin)

### Ejercicio 7

**Enunciado (resumen):** un *index-only scan*.

**Solución.**

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT analyte_code, value_numeric FROM staging.result_recent WHERE lab_order_id BETWEEN 10800000 AND 10801000;
```

```text
 Index Only Scan using result_recent_lab_order_id_incl_idx on result_recent (actual rows=10412.00 loops=1)
   Index Cond: ((lab_order_id >= 10800000) AND (lab_order_id <= 10801000))
   Heap Fetches: 0
   Index Searches: 1
   Buffers: shared hit=1 read=43
```

`03_index_kinds.sql` termina con `VACUUM ANALYZE`, y todas las páginas están marcadas como visibles.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-7--un-index-only-scan)

---

## 🟡 Intermedio (8–14)

### Ejercicio 8

**Enunciado (resumen):** el mapa de visibilidad.

**Solución.**

```sql
-- postgres
UPDATE staging.result_recent SET recorded_at = recorded_at WHERE lab_order_id BETWEEN 10800000 AND 10800500;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT analyte_code, value_numeric FROM staging.result_recent WHERE lab_order_id BETWEEN 10800000 AND 10801000;
VACUUM staging.result_recent;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT analyte_code, value_numeric FROM staging.result_recent WHERE lab_order_id BETWEEN 10800000 AND 10801000;
```

```text
 Index Only Scan using result_recent_lab_order_id_incl_idx on result_recent (actual rows=10412.00 loops=1)
   Heap Fetches: 10560
   Buffers: shared hit=1149

 Index Only Scan using result_recent_lab_order_id_incl_idx on result_recent (actual rows=10412.00 loops=1)
   Heap Fetches: 170
   Buffers: shared hit=84
```

El `UPDATE` que no cambia nada igual escribe versiones nuevas, y deja en el índice entradas viejas y nuevas: por eso hay más
*heap fetches* (10.560) que filas devueltas (10.412). El `VACUUM` limpia y vuelve a marcar las páginas; las 170 que quedan son
de páginas que todavía tenían algo que el `VACUUM` no pudo marcar en esa pasada.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-8--el-mapa-de-visibilidad)

### Ejercicio 9

**Enunciado (resumen):** el BRIN y el orden físico.

**Solución.**

```sql
-- postgres
CREATE INDEX result_as_is_recorded_at_brin ON staging.result_as_is USING brin (recorded_at);
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_as_is WHERE recorded_at >= '2024-10-15' AND recorded_at < '2024-10-16';
SELECT tablename, correlation FROM pg_stats
WHERE schemaname = 'staging' AND tablename IN ('result_recent', 'result_as_is') AND attname = 'recorded_at';
```

```text
 Finalize Aggregate (actual rows=1.00 loops=1)
   Buffers: shared hit=47 read=3711 written=220
               ->  Parallel Bitmap Heap Scan on result_as_is (actual rows=1799.00 loops=3)
                     Rows Removed by Index Recheck: 167101
                     ->  Bitmap Index Scan on result_as_is_recorded_at_brin (actual rows=37120.00 loops=1)
```

En la copia ordenada (con la transacción que borra los otros índices de `result_recent`):

```text
 Aggregate (actual rows=1.00 loops=1)
   Buffers: shared hit=8 read=128
   ->  Bitmap Heap Scan on result_recent (actual rows=5397.00 loops=1)
         Rows Removed by Index Recheck: 12317
         ->  Bitmap Index Scan on result_recent_recorded_at_brin (actual rows=1280.00 loops=1)
```

La correlación es 1 en `result_recent` y 0,06 en `result_as_is`. En la tabla sin orden, cada rango de 128 páginas tiene fechas de
casi todos los años, el BRIN no descarta casi nada, y el motor revisa fila por fila. El `actual rows` del `Bitmap Index Scan` de un
BRIN cuenta páginas candidatas por diez (1.280 son 128 páginas), no filas.

Dos cosas mueven estos números. **El ejercicio 8, si lo corriste antes:** su `UPDATE` cambia filas de junio y julio de 2024, y
sus versiones nuevas van al final de la tabla, al último rango del BRIN, que pasa a cubrir de junio de 2024 a diciembre de 2025.
Después de ese `UPDATE` y su `VACUUM`, la copia ordenada lee 717 bloques y descarta 93.538 filas: el `VACUUM` no vuelve a
resumir un rango ensanchado (`brin_desummarize_range` seguido de `brin_summarize_range`, o `REINDEX`, sí). **La carga:** en la validación del 14/10/2026,
sobre una carga nueva, la tabla sin orden leyó 4.014 bloques y descartó 181.362 filas, porque su orden físico es el que dejó el
`INSERT … SELECT`, que no ordena nada.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-9--el-brin-y-el-orden-físico)

### Ejercicio 10

**Enunciado (resumen):** el parcial, con y sin.

**Solución.**

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_recent WHERE analyte_code = 'GLU' AND qualifier IS NULL AND value_numeric > 250;
BEGIN; DROP INDEX staging.result_recent_glu_value_idx;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_recent WHERE analyte_code = 'GLU' AND qualifier IS NULL AND value_numeric > 250;
ROLLBACK;
```

```text
 Aggregate (actual rows=1.00 loops=1)
   Buffers: shared hit=70 read=11677 written=109
   ->  Bitmap Heap Scan on result_recent (actual rows=10137.00 loops=1)
         ->  Bitmap Index Scan on result_recent_glu_value_idx (actual rows=14883.00 loops=1)

 Finalize Aggregate (actual rows=1.00 loops=1)
   Buffers: shared hit=11129 read=18463 written=875
               ->  Parallel Bitmap Heap Scan on result_recent (actual rows=3379.00 loops=3)
                     ->  Bitmap Index Scan on result_recent_analyte_code_recorded_at_idx (actual rows=237185.00 loops=1)
```

El parcial devuelve 14.883 candidatos (las glucemias mayores que 250, con o sin calificador) y la tabla descarta las calificadas.
Sin él, el motor trae las 237.185 glucemias y filtra el valor en la tabla. Si el índice incluyera `qualifier`, o el predicado lo
pidiera (`WHERE analyte_code = 'GLU' AND qualifier IS NULL`), la tabla tendría menos que descartar.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-10--el-parcial-con-y-sin)

### Ejercicio 11

**Enunciado (resumen):** la expresión exacta.

**Solución.**

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_eav WHERE analyte_code = 'GLU'
  AND CASE WHEN value ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(value, ',', '.')::numeric END > 250;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_eav WHERE analyte_code = 'GLU'
  AND CASE WHEN value ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(value, ',', '.')::numeric(10,2) END > 250;
```

```text
   Buffers: shared hit=45 read=27778
                     ->  Bitmap Index Scan on result_eav_glu_parsed_idx (actual rows=30666.00 loops=1)

   Buffers: shared hit=6884 read=129296 written=43
                     ->  Bitmap Index Scan on result_eav_glu_parsed_idx (actual rows=713354.00 loops=1)
```

Con la expresión exacta, el índice devuelve las 30.666 glucemias que pasan el valor. Con `numeric(10,2)`, la expresión es otra; el
índice solo sirve por su predicado (`analyte_code = 'GLU'`) y devuelve las 713.354 glucemias, que la tabla filtra después.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-11--la-expresión-exacta)

### Ejercicio 12

**Enunciado (resumen):** GIN, selectivo y no.

**Solución.**

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.patient_clean WHERE norm_name LIKE '%SOSA GUTIERREZ%';
BEGIN; DROP INDEX staging.patient_clean_norm_name_trgm_idx;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.patient_clean WHERE norm_name LIKE '%SOSA GUTIERREZ%';
ROLLBACK;
-- y lo mismo con '%BUSTOS%'
```

```text
   ->  Bitmap Heap Scan on patient_clean (actual rows=12.00 loops=1)
         Buffers: shared hit=92
         ->  Bitmap Index Scan on patient_clean_norm_name_trgm_idx (actual rows=18.00 loops=1)
               ->  Parallel Seq Scan on patient_clean (actual rows=6.00 loops=2)
                     Buffers: shared hit=2112
```

Con `'%BUSTOS%'`, 4.662 pacientes: 1.895 bloques con el índice y 2.112 sin él. El índice GIN de trigramas devuelve candidatos (18
para 12 aciertos: los trigramas coinciden sin que la cadena esté entera) y el motor los revisa en la tabla.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-12--gin-selectivo-y-no)

### Ejercicio 13

**Enunciado (resumen):** el WAL sin índices.

**Solución.** La primera vuelta de `01_write_cost.sql`: 28 MB de WAL para 200.000 filas, **146,8 bytes por fila**. Cada fila es un
registro de inserción en la tabla con su cabecera de registro (24 bytes), la información del bloque y la fila con su cabecera de 23
bytes; las páginas nuevas de la tabla no se escriben enteras porque la tabla se vació con `TRUNCATE` y cada página es nueva.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-13--el-wal-sin-índices)

### Ejercicio 14

**Enunciado (resumen):** el WAL con ocho índices.

**Solución.** `psql -f 11-indices-y-lo-que-cuestan/01_write_cost.sql`:

```text
 indexes |          index_added          |  wal   | bytes_per_row | added_per_row
---------+-------------------------------+--------+---------------+---------------
       0 | (ninguno)                     | 28 MB  |         146.8 |
       1 | PRIMARY KEY (result_id)       | 36 MB  |         190.4 |          43.6
       2 | (lab_order_id)                | 48 MB  |         250.8 |          60.4
       3 | (analyte_code)                | 57 MB  |         298.9 |          48.1
       4 | (recorded_at)                 | 70 MB  |         365.0 |          66.1
       5 | (analyte_code, value_numeric) | 87 MB  |         454.2 |          89.2
       6 | (value_numeric)               | 101 MB |         528.9 |          74.7
       7 | (lab_order_id, analyte_code)  | 116 MB |         607.5 |          78.6
       8 | (value_text)                  | 128 MB |         672.4 |          64.9
(9 rows)
```

```sql
-- postgres
SELECT pg_size_pretty(pg_table_size('staging.result_write')) AS tabla,
       pg_size_pretty(pg_indexes_size('staging.result_write')) AS ocho_indices;
```

```text
 tabla | ocho_indices
-------+--------------
 11 MB | 32 MB
```

En otras dos corridas, el total sin índices y con ocho se repitió (146,7–146,8 y 672,4), y el reparto no: el primer índice sumó
unos 16 bytes, y en la tercera corrida el séptimo sumó 138,4 y el octavo 5,1. Medir dos veces es parte de la solución, y lo que
se compara entre corridas es la suma.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-14--el-wal-con-ocho)

---

## 🟠 Difícil (15–21)

### Ejercicio 15

**Enunciado (resumen):** ¿en proporción al ancho?

**Solución de referencia.** No. El de `analyte_code` (unos 4 bytes de clave) agrega 48,1 bytes; el de `recorded_at` (8), 66,1; el de
`(analyte_code, value_numeric)` (unos 12), 89,2; el de `value_text`, nulo en casi todas las filas, 64,9. Cada inserción en un B-tree es
un registro de WAL con una parte fija (cabecera, bloque, puntero a la fila) que pesa más que la clave. Lo que sí mueve el número es el
orden: un índice cuyas entradas llegan en desorden toca más páginas distintas desde el `CHECKPOINT`, y cada página nueva se escribe
entera una vez.

**Rúbrica.** Una respuesta correcta tiene que:
- comparar el agregado de cada índice con su ancho, con números;
- separar la parte fija del registro de la clave;
- mencionar el efecto del orden de llegada.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-15--en-proporción-al-ancho)

### Ejercicio 16

**Enunciado (resumen):** HOT con las páginas llenas.

**Solución.** La primera variante de `02_hot_updates.sql`:

```text
                       variant                       | updates | hot  | pct_hot |  wal  | wal_per_update
 1. tres índices, fillfactor 100                     |    9488 |   98 |       1 | 21 MB |           2272
```

Con `fillfactor` 100, las páginas se cargaron llenas, y la versión nueva de una fila corregida no cabe en su página: va a otra, y los
tres índices reciben una entrada. Las 98 HOT son de páginas que tenían algún resto de espacio. Son 9.488 actualizaciones y no
10.000 porque solo hay 9.488 resultados numéricos con `result_id` múltiplo de 20 entre los 200.000.

**Rúbrica.** Una respuesta correcta tiene que:
- atribuir la falta de HOT al espacio libre, no a los índices;
- leer `n_tup_hot_upd` contra `n_tup_upd`.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-16--hot-con-las-páginas-llenas)

### Ejercicio 17

**Enunciado (resumen):** HOT con lugar.

**Solución.**

```text
 2. tres índices, fillfactor 90                      |    9488 | 9488 |     100 | 12 MB |           1363
```

Todas HOT, con 1.363 bytes de WAL por actualización contra 2.272 de la variante llena. Las dos pagan la página entera en el WAL la
primera vez que la tocan después del `CHECKPOINT`; la HOT no paga además las páginas de los índices.

**Rúbrica.** Una respuesta correcta tiene que:
- comparar el WAL por actualización de las dos variantes;
- explicar qué parte del WAL se ahorra con HOT.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-17--hot-con-lugar)

### Ejercicio 18

**Enunciado (resumen):** el cuarto índice.

**Solución.**

```text
 3. cuarto índice sobre recorded_at, fillfactor 90   |    9488 | 9488 |     100 | 12 MB |           1364
 4. cuarto índice sobre value_numeric, fillfactor 90 |    9488 |    0 |       0 | 25 MB |           2763
```

Los separa la columna, no la cantidad. La corrección cambia `value_numeric`: si un índice la cubre, la entrada vieja del índice ya no
sirve, y la actualización no puede ser HOT, haya o no lugar en la página. El índice sobre `recorded_at`, que no cambia, no le hace
nada.

**Rúbrica.** Una respuesta correcta tiene que:
- decir que HOT depende de las columnas indexadas que cambian;
- mostrar el doble de WAL de la cuarta variante.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-18--el-cuarto-índice)

### Ejercicio 19

**Enunciado (resumen):** correcciones juntas.

**Solución.** Con `ORDER BY result_id LIMIT 10000` sin el `% 20`, y `fillfactor` 90, la primera versión del experimento dio:

```text
 2. tres índices, fillfactor 90                      |   10000 | 1300 |      13 | 4910 kB |            503
```

El 10 % libre de una página alcanza para unas catorce versiones nuevas de las ciento cuarenta filas que caben en ella. Si se
corrigen todas las filas de la página, las primeras catorce son HOT y el resto no. Y como las diez mil correcciones caen en unas
setenta páginas, el WAL total es mucho menor que con correcciones dispersas: cada página se escribe entera una sola vez.

**Rúbrica.** Una respuesta correcta tiene que:
- relacionar el espacio libre con cuántas filas de la página se corrigen;
- notar que el WAL por actualización baja con la concentración.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-19--correcciones-juntas)

### Ejercicio 20

**Enunciado (resumen):** la nota larga.

**Solución.** `04_free_text_index.sql` carga la nota larga y después intenta el índice:

```text
INSERT 0 529
INSERT 0 1
ERROR:  index row size 2984 exceeds btree version 4 maximum 2704 for index "order_note_note_idx"
DETAIL:  Index row references tuple (3,59) in relation "order_note".
HINT:  Values larger than 1/3 of a buffer page cannot be indexed.
Consider a function index of an MD5 hash of the value, or use full text indexing.
```

Y con el índice creado antes, sobre las notas cortas:

```sql
-- postgres
DELETE FROM staging.order_note WHERE lab_order_id = -1;
CREATE INDEX order_note_note_idx ON staging.order_note (note);
INSERT INTO staging.order_note SELECT -1, (SELECT string_agg(md5(g::text), ' ') FROM generate_series(1, 90) AS g);
```

```text
DELETE 1
CREATE INDEX
ERROR:  index row size 2984 exceeds btree version 4 maximum 2704 for index "order_note_note_idx"
```

El segundo es el peligroso: el índice funciona durante meses, y un día una nota no se puede guardar.

**Rúbrica.** Una respuesta correcta tiene que:
- reproducir los dos momentos;
- explicar por qué el segundo llega en producción.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-20--la-nota-larga)

### Ejercicio 21

**Enunciado (resumen):** la nota larga en MySQL.

**Solución.**

```sql
-- mysql
CREATE TABLE staging.order_note (lab_order_id int PRIMARY KEY, note varchar(5000));
CREATE INDEX order_note_note_idx ON staging.order_note (note);
CREATE TABLE staging.order_note_text (lab_order_id int PRIMARY KEY, note text);
CREATE INDEX order_note_text_note_idx ON staging.order_note_text (note);
CREATE INDEX order_note_text_note_idx ON staging.order_note_text (note(100));
```

```text
ERROR 1071 (42000) at line 3: Specified key was too long; max key length is 3072 bytes
ERROR 1170 (42000) at line 5: BLOB/TEXT column 'note' used in key specification without a key length
```

El índice por prefijo se crea (`Sub_part` 100 en `SHOW INDEX`). Indexa los primeros cien caracteres: sirve para buscar por el
comienzo, y no garantiza unicidad. `varchar(5000)` en `utf8mb4` puede ocupar 20.000 bytes, y MySQL lo rechaza al declararlo.

**Rúbrica.** Una respuesta correcta tiene que:
- reproducir los dos errores y el índice por prefijo;
- decir qué consultas sirve un índice por prefijo y cuáles no.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-21--la-nota-larga-en-mysql)

---

## 🔴 Muy difícil (22–28)

### Ejercicio 22

**Enunciado (resumen):** el índice sobre el MD5.

**Solución de referencia.**

```sql
-- postgres
CREATE INDEX order_note_note_md5_idx ON staging.order_note (md5(note));
EXPLAIN (COSTS OFF) SELECT * FROM staging.order_note WHERE md5(note) = md5('OBS 1');
```

```text
 Bitmap Heap Scan on order_note
   Recheck Cond: (md5(note) = '9f9c4ed1697f1b204e9a016d12feb2f1'::text)
   ->  Bitmap Index Scan on order_note_note_md5_idx
         Index Cond: (md5(note) = '9f9c4ed1697f1b204e9a016d12feb2f1'::text)
```

Sirve para encontrar una nota idéntica, siempre que la consulta escriba `md5(note)`. No sirve para buscar una palabra adentro, ni para
ordenar, ni para un `LIKE`. Para una observación de texto libre, lo que se busca es contenido, y eso es GIN con búsqueda de texto
completo.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar el plan con el índice;
- listar las búsquedas que no sirve.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-22--el-índice-sobre-el-md5)

### Ejercicio 23

**Enunciado (resumen):** qué índices se usan.

**Solución de referencia.** Sobre `staging.result_write` con los ocho índices y sus 200.000 filas, con los contadores en cero y tres
consultas conocidas (el informe de un protocolo, la clínica y las glucemias de un día):

```sql
-- postgres
SELECT pg_stat_reset_single_table_counters('staging.result_write'::regclass);
SELECT count(*) FROM staging.result_write WHERE lab_order_id = (SELECT min(lab_order_id) FROM staging.write_source);
SELECT count(*) FROM staging.result_write AS r1 JOIN staging.result_write AS r2 USING (lab_order_id)
WHERE r1.analyte_code = 'HBA1C' AND r1.value_numeric > 6.5 AND r2.analyte_code = 'GLU' AND r2.value_numeric > 126;
SELECT count(*) FROM staging.result_write WHERE analyte_code = 'GLU' AND recorded_at >= '2025-01-02' AND recorded_at < '2025-01-03';
SELECT pg_stat_force_next_flush();
SELECT indexrelname, idx_scan FROM pg_stat_user_indexes WHERE relname = 'result_write' ORDER BY idx_scan DESC, indexrelname;
```

```text
                indexrelname                 | idx_scan
---------------------------------------------+----------
 result_write_lab_order_id_analyte_code_idx  |        4
 result_write_analyte_code_idx               |        1
 result_write_analyte_code_value_numeric_idx |        1
 result_write_lab_order_id_idx               |        1
 result_write_recorded_at_idx                |        1
 result_write_pkey                           |        0
 result_write_value_numeric_idx              |        0
 result_write_value_text_idx                 |        0
(8 rows)
```

Tres sin uso: la clave primaria (ninguna de estas consultas busca un resultado por su identificador, pero la restricción hace falta
igual), el de `value_numeric` y el de `value_text`. Y hay redundancia: `(lab_order_id)` y `(lab_order_id, analyte_code)` hacen el
mismo trabajo, y el segundo alcanza para los dos.

**Rúbrica.** Una respuesta correcta tiene que:
- poner los contadores en cero antes de medir;
- distinguir un índice sin uso que se puede borrar de uno que sostiene una restricción;
- encontrar los índices redundantes por prefijo.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-23--qué-índices-se-usan)

### Ejercicio 24

**Enunciado (resumen):** los índices de `alameda.result`.

**Solución de referencia.**

| Índice | La consulta que lo pide | Lo que cuesta |
|---|---|---|
| `PRIMARY KEY (result_id)` | la integridad; las correcciones por resultado | ~44 bytes de WAL por fila |
| `(lab_order_id, analyte_code)` | el informe de un protocolo; los joins | ~79 bytes; no toca HOT |
| `(analyte_code, recorded_at)` | las determinaciones de un período (y con *skip scan*, las de un día) | ~66 bytes; no toca HOT |
| un parcial por valor para las determinaciones que se consultan por valor (glucemia, HbA1c) | la consulta clínica | chico, y **mata HOT** en las correcciones de esas determinaciones |

Sin índice sobre `value_numeric` para toda la tabla ni sobre `value_text`. El parcial por valor se discute con números: cada
corrección de una glucemia deja de ser HOT (el doble de WAL), y la consulta clínica corre unas veces por mes.

**Rúbrica.** Una respuesta correcta tiene que:
- justificar cada índice con una consulta conocida;
- dar su costo de escritura con los números de la fase;
- decidir el índice por valor sabiendo que mata HOT.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-24--los-índices-de-result)

### Ejercicio 25

**Enunciado (resumen):** ¿BRIN o particionado?

**Solución de referencia.** Si la tabla crece en orden de fecha, el BRIN da casi todo lo que da el particionado para leer un período
(136 bloques para un día, 24 kB de índice) sin ninguna partición que crear por adelantado. Lo que el BRIN no da es desprender un mes:
borrar un período sigue siendo un `DELETE` de 20 MB de WAL, contra los 179 kB de un `DETACH` (Fase 09). Y el BRIN pierde su efecto si
la tabla deja de estar ordenada (una carga masiva fuera de orden, como la de `alameda.result`); el particionado no.

**Rúbrica.** Una respuesta correcta tiene que:
- comparar lectura de un período y salida de un período;
- nombrar la condición del BRIN (el orden físico).

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-25--brin-o-particionado)

### Ejercicio 26

**Enunciado (resumen):** el *skip scan* en MySQL.

**Solución.**

```sql
-- mysql
CREATE INDEX protocolos_en_orden_sede_fecha_idx ON staging.protocolos_en_orden (Sede, Fecha);
ANALYZE TABLE staging.protocolos_en_orden;
EXPLAIN FORMAT=TREE SELECT count(*) FROM staging.protocolos_en_orden WHERE Fecha >= '2024-10-15' AND Fecha < '2024-10-16';
```

```text
-> Aggregate: count(0)  (cost=70678 rows=1)
    -> Filter: ((staging.protocolos_en_orden.Fecha >= TIMESTAMP'2024-10-15 00:00:00') and (staging.protocolos_en_orden.Fecha < TIMESTAMP'2024-10-16 00:00:00'))  (cost=36949 rows=146386)
        -> Covering index skip scan on protocolos_en_orden using protocolos_en_orden_sede_fecha_idx over '2024-10-15 00:00:00.000' <= Fecha < '2024-10-16 00:00:00.000'  (cost=36949 rows=146386)
```

La línea es `Covering index skip scan`. La estimación de 146.386 filas para un día (fueron unas quinientas) es la de MySQL sin un
histograma de esa columna; la [Fase 12](../12-estadisticas-y-cardinalidad.md) trata los histogramas.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-26--el-skip-scan-en-mysql)

### Ejercicio 27

**Enunciado (resumen):** los 135 de 2011, para `Protocolos` y `ResultadoItem`.

**Solución de referencia.** De los seis que el `AutoIndex` crea en esas dos tablas: `IdProtocolo` en las dos se conserva (la clave
de `Protocolos`, y la clave foránea por la que el informe lee sus resultados); `IdPaciente` en `Protocolos` se conserva (la historia
de un paciente); `IdItem` es la clave primaria de `ResultadoItem` y ya tiene su índice; `IdObraSocial` e `IdMedico` no, salvo que
una consulta conocida los pida (la presentación mensual filtra por obra social y mes: un compuesto `(payer_code, ordered_on)` le sirve
más que uno por obra social sola).

**Rúbrica.** Una respuesta correcta tiene que:
- decidir por consulta, no por nombre;
- reemplazar índices simples por compuestos cuando la consulta filtra por dos columnas.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-27--los-135-de-2011)

### Ejercicio 28

**Enunciado (resumen):** cuándo no indexar.

**Solución de referencia.**

```sql
-- postgres
SELECT pg_size_pretty(pg_table_size('staging.file_listing')) AS listado, (SELECT count(*) FROM staging.file_listing) AS filas,
       pg_size_pretty(pg_table_size('alameda.analyte')) AS determinaciones, (SELECT count(*) FROM alameda.analyte) AS filas_det;
```

```text
 listado |  filas  | determinaciones | filas_det
---------+---------+-----------------+-----------
 195 MB  | 2190876 | 8192 bytes      |        33
(1 row)
```

`alameda.analyte`: 33 filas en una página. Ningún índice además de la clave le compra nada; recorrerla es leer una página.
`staging.file_listing`: 2,2 millones de filas, y la consulta conocida es "los archivos de un protocolo" (para migrarlos o mostrarlos).
Esa sí pide un índice por `lab_order_id`, porque sin él cada búsqueda lee 195 MB. La tabla casi no se escribe, así que el índice
cuesta poco.

**Rúbrica.** Una respuesta correcta tiene que:
- medir el tamaño de cada tabla;
- decidir con una consulta conocida y su frecuencia de escritura.

[← Volver al ejercicio](../11-indices-y-lo-que-cuestan.md#-ejercicio-28--cuándo-no-indexar)
