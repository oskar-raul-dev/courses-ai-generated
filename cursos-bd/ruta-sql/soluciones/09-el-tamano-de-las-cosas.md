# ✅ Soluciones — Fase 09: El tamaño de las cosas

> **Curso:** Ruta SQL · Solucionario de la [Fase 09](../09-el-tamano-de-las-cosas.md)
> **Ejercicios:** 24 · **Perfil:** M · **Motores:** Postgres y MySQL de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso); Python 3.13 con el entorno del curso
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todas las soluciones suponen el modelo de `uv run lab load --profile m --model`, MySQL con sus cuatro tablas
(`--engine mysql --tables Pacientes,Protocolos,ResultadoItem,Practicas`) y los scripts de
`src/09-el-tamano-de-las-cosas/` corridos en orden.

---

## 🟢 Fácil (1–7)

### Ejercicio 1

**Enunciado (resumen):** el tamaño de página.

**Solución.**

```sql
-- postgres
SHOW block_size;
```

```text
 block_size
------------
 8192
(1 row)
```

```sql
-- mysql
SELECT @@innodb_page_size, @@max_allowed_packet, @@version;
```

```text
@@innodb_page_size	@@max_allowed_packet	@@version
16384	67108864	9.7.2
```

Cuando un plan de Postgres dice `Buffers: shared hit=15`, son quince páginas de 8 kB: 120 kB que pasaron por la
memoria compartida, aunque la consulta haya usado una fila de cada una.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-1--la-página)

### Ejercicio 2

**Enunciado (resumen):** el listado, por tipo.

**Solución.** Después de `01_file_listing.sql`:

```sql
-- postgres
SELECT file_type, count(*), pg_size_pretty(sum(bytes)) AS total, pg_size_pretty(avg(bytes)::bigint) AS promedio,
       min(created_on)::date, max(created_on)::date
FROM staging.file_listing GROUP BY 1;
```

```text
    file_type    |  count  | total  | promedio |    min     |    max
-----------------+---------+--------+----------+------------+------------
 INFORME_PDF     | 1194978 | 106 GB | 93 kB    | 2013-05-01 | 2026-10-10
 ORDEN_ESCANEADA |  995898 | 378 GB | 398 kB   | 2006-03-01 | 2026-10-10
(2 rows)
```

El `COPY` lee el archivo desde la caja montada en el servidor, como `lab load`; el script nombra el perfil M en la
ruta (`/caja/m/…`).

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-2--el-listado)

### Ejercicio 3

**Enunciado (resumen):** filas contra archivos.

**Solución.**

```sql
-- postgres
SELECT pg_size_pretty(sum(bytes)) AS archivos FROM staging.file_listing;
SELECT pg_size_pretty(sum(pg_total_relation_size(c.oid))) AS legacy
FROM pg_class AS c JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE n.nspname = 'legacy' AND c.relkind = 'r';
```

```text
 archivos
----------
 484 GB
(1 row)

 legacy
---------
 2058 MB
(1 row)
```

El perfil M achica las filas (un octavo de los pacientes de la base de verdad, más o menos) pero no el tamaño de
cada archivo, que es el de una orden o un informe reales. Por eso en M los archivos son más de doscientas veces las
filas, y en la base de verdad, con muchas más filas, son 1,1 TB de 1,4.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-3--filas-contra-archivos)

### Ejercicio 4

**Enunciado (resumen):** los tipos de `result`.

**Solución.**

```sql
-- postgres
SELECT a.attname, t.typname, t.typlen, t.typalign
FROM pg_attribute AS a JOIN pg_type AS t ON t.oid = a.atttypid
WHERE a.attrelid = 'alameda.result'::regclass AND a.attnum > 0 ORDER BY a.attnum;
```

```text
    attname    |  typname  | typlen | typalign
---------------+-----------+--------+----------
 result_id     | int4      |      4 | i
 lab_order_id  | int4      |      4 | i
 analyte_code  | varchar   |     -1 | i
 value_numeric | numeric   |     -1 | i
 qualifier     | bpchar    |     -1 | i
 value_text    | varchar   |     -1 | i
 sample_flag   | varchar   |     -1 | i
 recorded_at   | timestamp |      8 | d
(8 rows)
```

Tres de largo fijo (`typlen` positivo): los dos `integer` y el `timestamp`. Las otras cinco tienen largo variable
(`-1`), y Postgres las guarda con una cabecera de 1 byte cuando son cortas, sin alinear.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-4--los-tipos-de-result)

### Ejercicio 5

**Enunciado (resumen):** `result` en los dos órdenes.

**Solución.** Después de `03_alignment.sql`:

```sql
-- postgres
SELECT 'como está' AS orden, pg_size_pretty(pg_table_size('staging.result_as_is')) AS tamano,
       pg_table_size('staging.result_as_is') / 8192 AS bloques
UNION ALL
SELECT 'reordenada', pg_size_pretty(pg_table_size('staging.result_reordered')),
       pg_table_size('staging.result_reordered') / 8192;
```

```text
   orden    | tamano | bloques
------------+--------+---------
 como está  | 686 MB |   87835
 reordenada | 686 MB |   87835
(2 rows)
```

Y el ancho promedio de la fila, sobre las primeras cien mil:

```text
 bytes_fila_como_esta
----------------------
                 54.8

 bytes_fila_reordenada
-----------------------
                  49.8
```

Cinco bytes menos por fila, y ni un bloque menos: cada fila ocupa un múltiplo de 8 bytes, y caben las mismas por
página.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-5--result-reordenada)

### Ejercicio 6

**Enunciado (resumen):** `fillfactor = 70`.

**Solución.**

```sql
-- postgres
CREATE TABLE staging.lab_order_ff (LIKE alameda.lab_order) WITH (fillfactor = 70);
INSERT INTO staging.lab_order_ff SELECT * FROM alameda.lab_order;
SELECT 'fillfactor 100' AS t, pg_size_pretty(pg_table_size('alameda.lab_order'))
UNION ALL SELECT 'fillfactor 70', pg_size_pretty(pg_table_size('staging.lab_order_ff'));
```

```text
       t        | pg_size_pretty
----------------+----------------
 fillfactor 100 | 68 MB
 fillfactor 70  | 97 MB
(2 rows)
```

El 30 % libre de cada página es para que una actualización pueda escribir la versión nueva de la fila en la misma
página. Si la tabla casi no se actualiza, como `lab_order`, es espacio que se paga en cada lectura sin usarse nunca.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-6--fillfactor)

### Ejercicio 7

**Enunciado (resumen):** la tabla y su TOAST.

**Solución.** Después de `02_report_files.sql`:

```sql
-- postgres
SELECT c.relname, t.relname AS toast,
       pg_size_pretty(pg_relation_size(c.oid)) AS tabla, pg_size_pretty(pg_relation_size(t.oid)) AS en_toast
FROM pg_class AS c JOIN pg_class AS t ON t.oid = c.reltoastrelid
WHERE c.oid = 'staging.report_pdf_bytea'::regclass;
```

```text
     relname      |     toast
------------------+----------------
 report_pdf_bytea | pg_toast_19538
(1 row)
```

La tabla ocupa 120 kB y su TOAST 187 MB (la tabla de la sección 5.3). El número de la tabla TOAST es el OID de la
tabla original, y va a ser otro en tu base.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-7--el-pdf-en-toast)

---

## 🟡 Intermedio (8–14)

### Ejercicio 8

**Enunciado (resumen):** metadatos, largo y contenido.

**Solución.**

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT lab_order_id, created_on FROM staging.report_pdf_bytea WHERE created_on = '2026-10-02';
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT sum(length(pdf)) FROM staging.report_pdf_bytea WHERE created_on = '2026-10-02';
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT sum(length(pdf || ''::bytea)) FROM staging.report_pdf_bytea WHERE created_on = '2026-10-02';
```

```text
 Seq Scan on report_pdf_bytea (actual rows=531.00 loops=1)
   Buffers: shared hit=15

 Aggregate (actual rows=1.00 loops=1)
   Buffers: shared hit=15

 Aggregate (actual rows=1.00 loops=1)
   Buffers: shared hit=7862
```

El puntero TOAST guarda el largo del valor, así que `length(pdf)` lo contesta sin ir a buscarlo. Concatenar obliga
a reconstruir el valor entero, y ahí aparecen los 7.847 bloques de TOAST de esos 531 informes.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-8--metadatos-sin-el-pdf)

### Ejercicio 9

**Enunciado (resumen):** por qué el objeto grande ocupa más.

**Solución.**

```sql
-- postgres
SELECT count(*) AS chunks, round(avg(length(data))) AS bytes_por_chunk FROM pg_largeobject;
```

```text
 chunks | bytes_por_chunk
--------+-----------------
  93588 |            2027
(1 row)
```

Cada objeto grande se parte en trozos de 2 kB (un cuarto de página), y cada trozo es una fila de `pg_largeobject`
con su cabecera y su entrada en el índice. Son 93.588 filas para 181 MB de PDF; TOAST también trocea, pero en trozos
más grandes y sin índice propio por objeto.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-9--el-objeto-grande)

### Ejercicio 10

**Enunciado (resumen):** los hashes contra los PDF.

**Solución.**

```sql
-- postgres
SELECT count(*) AS archivos, count(*) FILTER (WHERE f.sha256 = sha256(b.pdf)) AS coinciden
FROM staging.report_file AS f JOIN staging.report_pdf_bytea AS b USING (lab_order_id);
SELECT lab_order_id, file_path, bytes, encode(sha256, 'hex') FROM staging.report_file ORDER BY 1 LIMIT 2;
```

```text
 archivos | coinciden
----------+-----------
     2000 |      2000
(1 row)

 lab_order_id |         file_path          | bytes |                              encode
--------------+----------------------------+-------+------------------------------------------------------------------
     11228469 | informes/2026/11228469.pdf | 81936 | 24fe2d2f483d6d492e2a48bb97a80626b98b819e00e27901e59581638dc05699
     11228470 | informes/2026/11228470.pdf | 87808 | 41866c2b8ff667aa662315c833372f4205d76ef9fb6e7aa30c3b4f788a085c0e
(2 rows)
```

Un hash distinto demuestra que el archivo del disco no es el que se registró: se cambió, se corrompió o se
reemplazó. No dice cuál de las tres cosas, ni cuál es el bueno; para eso hay que tener el original en otro lado.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-10--ruta-y-hash)

### Ejercicio 11

**Enunciado (resumen):** el relleno que sí se ahorra.

**Solución.**

```sql
-- postgres
SELECT 'booleanos entre bigint' AS orden, pg_size_pretty(pg_table_size('staging.align_bad')) AS tamano,
       pg_table_size('staging.align_bad') / 8192 AS bloques
UNION ALL SELECT 'bigint primero', pg_size_pretty(pg_table_size('staging.align_good')),
       pg_table_size('staging.align_good') / 8192;
SELECT pg_column_size(b.*) AS mala, (SELECT pg_column_size(g.*) FROM staging.align_good AS g LIMIT 1) AS buena
FROM staging.align_bad AS b LIMIT 1;
```

```text
         orden          | tamano | bloques
------------------------+--------+---------
 booleanos entre bigint | 97 MB  |   12414
 bigint primero         | 76 MB  |    9767
(2 rows)

 mala | buena
------+-------
   72 |    51
(1 row)
```

Cada `boolean` delante de un `bigint` o un `timestamp` arrastra siete bytes de relleno: tres booleanos, 21 bytes.
Agrupados al final, ocupan tres.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-11--el-relleno-que-sí-se-ahorra)

### Ejercicio 12

**Enunciado (resumen):** InnoDB en orden de clave.

**Solución.**

```sql
-- mysql
CREATE DATABASE IF NOT EXISTS staging;
CREATE TABLE staging.protocolos_en_orden LIKE legacy.Protocolos;
INSERT INTO staging.protocolos_en_orden SELECT * FROM legacy.Protocolos ORDER BY IdProtocolo;
ANALYZE TABLE legacy.Protocolos, staging.protocolos_en_orden;
SELECT database_name, table_name, index_name, stat_value AS paginas
FROM mysql.innodb_index_stats WHERE table_name IN ('Protocolos', 'protocolos_en_orden') AND stat_name = 'size';
```

```text
+---------------+---------------------+------------+---------+
| database_name | table_name          | index_name | paginas |
+---------------+---------------------+------------+---------+
| legacy        | Protocolos          | PRIMARY    |    6441 |
| staging       | protocolos_en_orden | PRIMARY    |    6184 |
+---------------+---------------------+------------+---------+
```

`LOAD DATA` cargó el archivo en el orden en que lo escribió el generador, que es el de la fecha. Los protocolos de
2004 a 2011 tienen los identificadores aleatorios de la replicación de Jet (36.310 de ellos negativos), así que entran
en el árbol en cualquier lugar y parten páginas. La copia en `staging` y no en `legacy`: en `legacy` no se crea nada.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-12--innodb-en-orden-de-clave)

### Ejercicio 13

**Enunciado (resumen):** el índice secundario en dos motores.

**Solución.**

```sql
-- mysql
CREATE INDEX protocolos_en_orden_idpaciente_idx ON staging.protocolos_en_orden (IdPaciente);
ANALYZE TABLE staging.protocolos_en_orden;
SELECT index_name, stat_value AS paginas, round(stat_value * @@innodb_page_size / 1024 / 1024, 1) AS mb
FROM mysql.innodb_index_stats WHERE table_name = 'protocolos_en_orden' AND stat_name = 'size';
```

```text
+------------------------------------+---------+------+
| index_name                         | paginas | mb   |
+------------------------------------+---------+------+
| PRIMARY                            |    6184 | 96.6 |
| protocolos_en_orden_idpaciente_idx |    1379 | 21.5 |
+------------------------------------+---------+------+
```

```sql
-- postgres
CREATE TABLE staging.protocol_copy AS SELECT * FROM legacy."Protocolos";
CREATE INDEX protocol_copy_patient_idx ON staging.protocol_copy ("IdPaciente");
SELECT pg_size_pretty(pg_relation_size('staging.protocol_copy_patient_idx')) AS indice_por_paciente;
```

```text
 indice_por_paciente
---------------------
 14 MB
(1 row)
```

La entrada de InnoDB guarda el paciente y la clave primaria (para ir a buscar la fila en el árbol de la tabla); la de
Postgres, el paciente y un puntero físico a la página y la posición. El tamaño también depende de cuánto llena cada
motor sus páginas al construir el índice.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-13--el-índice-secundario-en-dos-motores)

### Ejercicio 14

**Enunciado (resumen):** los archivos por año.

**Solución.**

```sql
-- postgres
SELECT extract(year FROM created_on)::int AS anio,
       pg_size_pretty(sum(bytes) FILTER (WHERE file_type = 'ORDEN_ESCANEADA')) AS ordenes,
       pg_size_pretty(sum(bytes) FILTER (WHERE file_type = 'INFORME_PDF')) AS pdf
FROM staging.file_listing GROUP BY 1 ORDER BY 1;
```

Un extracto:

```text
 anio | ordenes |   pdf
------+---------+---------
 2010 | 26 GB   |
 2011 | 16 GB   |
 2012 | 4704 MB |
 2013 | 4951 MB | 1323 MB
 2019 | 5843 MB | 2334 MB
 2020 | 21 GB   | 8750 MB
 2025 | 43 GB   | 17 GB
```

En 2012 las órdenes dejan de ser mapas de bits de Access (2,4 MB) y pasan a JPG (310 kB), después del pasaje a SQL
Server de 2011. En 2020 el volumen de protocolos se multiplica con la pandemia, y con él los archivos. El tamaño de la
base sigue al negocio, no a una decisión técnica.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-14--los-archivos-por-año)

---

## 🟠 Difícil (15–20)

### Ejercicio 15

**Enunciado (resumen):** las particiones.

**Solución.** Después de `04_result_by_month.sql`:

```sql
-- postgres
SELECT count(*) AS particiones FROM pg_inherits WHERE inhparent = 'staging.result_by_month'::regclass;
SELECT pg_size_pretty(sum(pg_table_size(inhrelid))) FROM pg_inherits WHERE inhparent = 'staging.result_by_month'::regclass;
```

```text
 particiones
-------------
         223
(1 row)

 pg_size_pretty
----------------
 692 MB
(1 row)
```

Seis megabytes más que la tabla entera (686 MB): la última página de cada partición queda a medio llenar.

**Rúbrica.** Una respuesta correcta tiene que:
- contar desde el catálogo, no desde los nombres;
- explicar la diferencia de tamaño con la tabla entera.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-15--particionar-result)

### Ejercicio 16

**Enunciado (resumen):** el *pruning*.

**Solución.**

```sql
-- postgres
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_as_is
WHERE recorded_at >= '2024-10-01' AND recorded_at < '2024-11-01' AND analyte_code = 'GLU';
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_by_month
WHERE recorded_at >= '2024-10-01' AND recorded_at < '2024-11-01' AND analyte_code = 'GLU';
```

```text
 Finalize Aggregate (actual rows=1.00 loops=1)
   Buffers: shared read=87808
               ->  Parallel Seq Scan on result_as_is (actual rows=3223.67 loops=3)

 Finalize Aggregate (actual rows=1.00 loops=1)
   Buffers: shared hit=871 read=302
               ->  Parallel Seq Scan on result_2024_10 result_by_month (actual rows=4835.50 loops=2)
```

La línea es `Parallel Seq Scan on result_2024_10`: el plan solo nombra la partición del mes. Las dos devuelven
9.671 glucemias. La tabla entera sin índice sobre la fecha recorre todo; la [Fase 11](../11-indices-y-lo-que-cuestan.md) le pone un BRIN y compara.

**Rúbrica.** Una respuesta correcta tiene que:
- señalar la línea del plan con la partición;
- no atribuir la mejora a un índice, porque no hay ninguno.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-16--el-pruning)

### Ejercicio 17

**Enunciado (resumen):** el WAL de sacar un mes.

**Solución.**

```sql
-- postgres
CHECKPOINT;
SELECT pg_current_wal_lsn() AS antes \gset
DELETE FROM staging.result_as_is WHERE recorded_at >= '2025-01-01' AND recorded_at < '2025-02-01';
SELECT pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), :'antes')) AS wal_del_delete_enero_2025;
CHECKPOINT;
SELECT pg_current_wal_lsn() AS antes \gset
ALTER TABLE staging.result_by_month DETACH PARTITION staging.result_2025_01;
DROP TABLE staging.result_2025_01;
SELECT pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), :'antes')) AS wal_del_detach_y_drop_enero_2025;
```

```text
DELETE 174933
 wal_del_delete_enero_2025
---------------------------
 20 MB
(1 row)

 wal_del_detach_y_drop_enero_2025
----------------------------------
 179 kB
(1 row)
```

El `CHECKPOINT` antes de cada medición hace que las dos paguen la primera escritura de cada página (*full-page
write*) en igualdad de condiciones. Con abril de 2008, un mes de 9.065 filas, el `DELETE` escribe 1.170 kB y el
`DETACH` con `DROP`, 178 kB: el segundo no depende del tamaño del mes.

**Rúbrica.** Una respuesta correcta tiene que:
- medir en bytes de WAL, no en tiempo;
- explicar por qué el `DELETE` crece con las filas y el `DETACH` no.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-17--desprender-un-mes)

### Ejercicio 18

**Enunciado (resumen):** el PDF de 70 MB en MySQL.

**Solución.** El script, corrido con el entorno del curso en la red del laboratorio:

```python
import os
import pymysql
from lab import config

conn = pymysql.connect(host=config.MYSQL["host"], port=config.MYSQL["port"], user="root",
                       password=config.PASSWORD, database="staging")
with conn.cursor() as cur:
    cur.execute("SELECT @@max_allowed_packet")
    print("max_allowed_packet:", cur.fetchone()[0])
    cur.execute("DROP TABLE IF EXISTS report_pdf")
    cur.execute("CREATE TABLE report_pdf (lab_order_id int PRIMARY KEY, pdf longblob NOT NULL)")
    for mb in (10, 70):
        try:
            cur.execute("INSERT INTO report_pdf VALUES (%s, %s)", (mb, os.urandom(mb * 1024 * 1024)))
            conn.commit()
            print(f"{mb} MB: guardado")
        except Exception as exc:
            print(f"{mb} MB: {type(exc).__name__}: {exc}")
            break
```

```text
max_allowed_packet: 67108864
10 MB: guardado
70 MB: OperationalError: (2006, "MySQL server has gone away (BrokenPipeError(32, 'Broken pipe'))")
```

El límite está en el servidor (`max_allowed_packet` global) y también en el cliente: `mysql`, por ejemplo, tiene el
suyo. Hay que subir los dos, y el servidor guarda la sentencia entera en memoria mientras la procesa.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar que 10 MB entra y 70 MB no;
- relacionar el mensaje con `max_allowed_packet` aunque no lo nombre.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-18--el-pdf-de-70-mb)

### Ejercicio 19

**Enunciado (resumen):** qué parte del respaldo son archivos.

**Solución de referencia.** En la caja M: 484 GB de archivos y 2.058 MB de filas, el 99,6 % del respaldo son archivos.
En la base de verdad, según la historia: 1,1 TB de 1,4, el 79 %. Si los archivos salen, el respaldo de la base es de
unos 300 GB, y el de los archivos se hace aparte y de forma incremental: un archivo que no cambia nunca se copia una vez.

**Rúbrica.** Una respuesta correcta tiene que:
- usar las dos fuentes (la caja y la historia) y decir por qué difieren;
- distinguir el tamaño del respaldo completo del costo de un respaldo incremental de archivos que no cambian.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-19--el-respaldo)

### Ejercicio 20

**Enunciado (resumen):** un resultado de noviembre de 2026.

**Solución.**

```sql
-- postgres
INSERT INTO staging.result_by_month VALUES (-1, 11232670, 'GLU', 100, NULL, NULL, NULL, '2026-11-02 09:00');
```

```text
ERROR:  no partition of relation "result_by_month" found for row
DETAIL:  Partition key of the failing row contains (recorded_at) = (2026-11-02 09:00:00).
```

Las dos formas: crear las particiones por adelantado (un trabajo programado que crea la del mes que viene, o varias
de golpe), o una partición `DEFAULT` que reciba lo que no tiene lugar. La segunda no falla nunca, pero obliga a mudar
las filas cuando se crea la partición del mes, y mientras están ahí, el *pruning* no las descarta.

**Rúbrica.** Una respuesta correcta tiene que:
- reproducir el error;
- comparar las dos formas por lo que cuestan después, no solo por si evitan el error.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-20--noviembre-sin-partición)

---

## 🔴 Muy difícil (21–24)

### Ejercicio 21

**Enunciado (resumen):** dónde vive el informe firmado.

**Solución de referencia.** El resultado firmado vive en la base (es el dato que Norma firma). El PDF entregado vive
afuera, en un almacén con su propio respaldo y sin escritura después de creado, y la base guarda su ruta, su tamaño y
su SHA-256, en la misma transacción en que se registra la entrega. Lo que garantiza cada parte: la base, qué se firmó
y cuándo; el hash, que el PDF es el que se entregó; el almacén, que el archivo existe. Si el almacén pierde el archivo,
se regenera desde el resultado, y su hash dirá si es idéntico.

**Rúbrica.** Una respuesta correcta tiene que:
- separar el dato firmado del documento derivado;
- usar el hash como prueba, no solo como índice;
- decir qué pasa si se pierde el archivo.

Y queda invalidada si:
- guarda solo la ruta, sin forma de probar que el archivo no cambió.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-21--el-informe-firmado)

### Ejercicio 22

**Enunciado (resumen):** sacar el terabyte.

**Solución de referencia.** Por lotes, de lo más viejo a lo más nuevo, y en este orden por archivo:

1. leer el archivo de la base y calcular su SHA-256;
2. escribirlo en el almacén y volver a leerlo de ahí;
3. comparar el hash de lo leído con el calculado;
4. registrar ruta, tamaño y hash en la tabla de archivos;
5. recién entonces, en otra transacción, borrar el archivo de la base.

Con los números de la caja M, son 2.190.876 archivos y 484 GB; a un ritmo de, por ejemplo, 50 MB por segundo
(una suposición), son casi tres horas solo de copia, sin contar las verificaciones. El borrado no devuelve espacio al
sistema de archivos hasta reorganizar la tabla (en SQL Server, comprimir el archivo de datos), y eso es otra ventana.

**Rúbrica.** Una respuesta correcta tiene que:
- verificar cada archivo en el destino antes de borrarlo del origen;
- trabajar por lotes que se puedan reanudar;
- declarar las suposiciones de ritmo.

Y queda invalidada si:
- borra antes de verificar.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-22--sacar-el-terabyte)

### Ejercicio 23

**Enunciado (resumen):** el LOB de Oracle.

**Solución.** No publicamos el resultado: es un número de Oracle (ver [`a09`](../a09-licencias-publicacion-y-riesgo.md)).
Lo que hay que hacer, en `sqlplus`: una tabla con una columna `BLOB` (`SecureFiles` es el valor por defecto), dos mil
filas con un BLOB de unos 90 kB cada una, y con `SET AUTOTRACE TRACEONLY STATISTICS`, la consulta por fecha que no pide
el BLOB y la que lee su contenido (`DBMS_LOB.SUBSTR` sobre todo el largo). Qué mirar: las *consistent gets* de cada una.
La documentación de *SecureFiles LOB Storage* explica cuándo el LOB se guarda en la fila (hasta unos 4.000 bytes) y
cuándo fuera, y por qué una consulta sin el LOB no toca sus segmentos.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-23--el-lob-de-oracle)

### Ejercicio 24

**Enunciado (resumen):** ¿por mes o por sede?

**Solución de referencia.** Por mes de carga. Las consultas conocidas de Alameda filtran por período (la presentación
mensual, los resultados del día, el informe de un mes), y el mes viejo se desprende entero, como midió la sección 5.5.
Por sede, la partición del laboratorio central se llevaría más de la mitad de las filas (la [Fase 13](../13-el-optimizador-en-tres-motores.md) lo mide), el
*pruning* solo ayudaría a las consultas de una sede chica, y no habría nada que desprender.

**La consulta que empeora:** la historia de un paciente, que no filtra por mes y recorre las 223 particiones. Se
resuelve con un índice por protocolo en cada partición (la [Fase 11](../11-indices-y-lo-que-cuestan.md)), no con otra clave de partición.

**Rúbrica.** Una respuesta correcta tiene que:
- decidir con las consultas conocidas;
- nombrar la consulta que empeora y cómo se compensa;
- usar la medición de *pruning* y la de desprender.

[← Volver al ejercicio](../09-el-tamano-de-las-cosas.md#-ejercicio-24--por-mes-o-por-sede)
