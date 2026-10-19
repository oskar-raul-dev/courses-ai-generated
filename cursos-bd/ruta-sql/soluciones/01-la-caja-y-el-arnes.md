# ✅ Soluciones — Fase 01: La caja y el arnés

> **Curso:** Ruta SQL · Solucionario de la [Fase 01](../01-la-caja-y-el-arnes.md)
> **Ejercicios:** 22 · **Perfil:** M, salvo los ejercicios 3 y 7, en S · **Motores:** Postgres, MySQL y
> Oracle (estructura y conteos de la caja), los de [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Fecha de verificación ejecutada:** 12/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

---

## 🟢 Fácil (1–7)

### Ejercicio 1

**Enunciado (resumen):** levantar los tres motores y comprobar que estén sanos.

**Solución.** Desde `src/`:

```text
$ uv run lab up base contraste oracle
→ docker compose --profile base --profile contraste --profile oracle up -d --wait
…
 Container alameda-lab-postgres-1 Healthy
 Container alameda-lab-mysql-1 Healthy
 Container alameda-lab-oracle-1 Healthy
```

`uv run lab ps` lista los tres con `(healthy)` en la columna `STATUS`. Si Oracle tarda, es normal: le
lleva entre 13 y 16 s con un volumen nuevo ([`a01`](../a01-laboratorio-contenerizado.md#️-conectarse-antes-de-tiempo)).

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-1--los-tres-motores-arriba)

### Ejercicio 2

**Enunciado (resumen):** generar M y comprobar el hash.

**Solución.**

```text
$ uv run lab generate --profile m
Generando el perfil m con la semilla 1996 en …/src/lab/caja/m …
mundo: 200002 personas, 242427 filas de Pacientes, 1327622 protocolos (53 s)
…
Listo en 214 s: 200002 personas, 242427 filas de Pacientes, 1327622 protocolos, 12134453 filas de ResultadoItem.
SHA-256 de la caja: 3e59292e9918ee259e44c49c928d0b024686019fe070cc9fdca40a97fb2dd465
```

El tiempo depende de tu máquina y de lo que tengas corriendo; el hash, no.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-2--la-caja-de-m)

### Ejercicio 3

**Enunciado (resumen):** cargar S en Postgres y leer `lab.loaded`.

**Solución.**

```text
$ uv run lab load
Cargando el perfil s (caja 49cfb8db4194, semilla 1996) en postgres …
  legacy: 419 tablas (4 s)
  truth: 6 tablas (6 s)
  postgres: listo en 8 s
```

```sql
-- postgres
SELECT profile, seed, left(sha256, 12) AS caja, tables FROM lab.loaded;
```

```text
 profile | seed |     caja     | tables
---------+------+--------------+--------
 s       | 1996 | 49cfb8db4194 |    419
(1 row)
```

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-3--s-en-postgres)

### Ejercicio 4

**Enunciado (resumen):** contar las tablas de `legacy` desde `information_schema` y desde `pg_class`.

**Solución.**

```sql
-- postgres
SELECT (SELECT count(*) FROM information_schema.tables WHERE table_schema = 'legacy') AS information_schema,
       (SELECT count(*) FROM pg_class AS c JOIN pg_namespace AS n ON n.oid = c.relnamespace
         WHERE n.nspname = 'legacy' AND c.relkind = 'r') AS pg_class;
```

```text
 information_schema | pg_class
--------------------+----------
                419 |      419
(1 row)
```

Dan lo mismo porque en `legacy` solo hay tablas. `information_schema.tables` también lista vistas, y
`pg_class` también índices y secuencias: por eso el filtro `relkind = 'r'`, que se queda con las tablas.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-4--cuántas-tablas)

### Ejercicio 5

**Enunciado (resumen):** contar las tablas sin clave primaria y ver de qué grupos son.

**Solución.** El conteo de la sección 4.4 da 353. Para ver de dónde salen, agrupando por lo que el
catálogo sabe de cada tabla (las anchas son las que tienen la columna `Obs`):

```sql
-- postgres
SELECT CASE WHEN c.relname ~ '^Precios_[0-9]{4}_[0-9]{2}$' THEN 'precios mensuales'
            WHEN EXISTS (SELECT 1 FROM information_schema.columns AS col
                         WHERE col.table_schema = 'legacy' AND col.table_name = c.relname AND col.column_name = 'Obs')
              THEN 'anchas, con Obs'
            ELSE 'las demás' END AS grupo,
       count(*) AS tablas,
       count(*) FILTER (WHERE NOT EXISTS (SELECT 1 FROM pg_constraint AS k
                                          WHERE k.conrelid = c.oid AND k.contype = 'p')) AS sin_clave
FROM pg_class AS c JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE n.nspname = 'legacy' AND c.relkind = 'r'
GROUP BY 1 ORDER BY 2 DESC;
```

```text
       grupo       | tablas | sin_clave
-------------------+--------+-----------
 precios mensuales |    280 |       280
 anchas, con Obs   |     71 |        21
 las demás         |     68 |        52
(3 rows)
```

Las 280 copias mensuales de precios no tienen clave ninguna; diez nombres al azar de la lista salen
casi todos de ahí (`Precios_2004_11`, `Precios_2019_12`…), con alguna de las demás, como
`ObrasSocialesViejas` o `Copia de Pacientes`.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-5--las-que-no-tienen-clave)

### Ejercicio 6

**Enunciado (resumen):** las cinco tablas más pesadas y el peso de las dos primeras.

**Solución.** La consulta de la sección 4.4 con `LIMIT 5`:

```text
       tabla        | filas_estimadas | tamano
--------------------+-----------------+---------
 ResultadoItem      |        12134152 | 1309 MB
 ProtocoloPracticas |         6131824 | 461 MB
 Protocolos         |         1327622 | 151 MB
 Comprobantes       |          570046 | 58 MB
 Pacientes          |          242427 | 38 MB
```

`legacy` entero ocupa 2.061 MB (`sum(pg_total_relation_size(…))`), y las dos primeras suman 1.770 MB:
**el 86 %**. Lo que el curso optimice en esas dos tablas es casi todo lo que hay para optimizar.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-6--lo-que-pesa)

### Ejercicio 7

**Enunciado (resumen):** la prueba de fuego en S, contra el manifiesto de S.

**Solución.**

```sql
-- postgres
SELECT count(*) AS nombre_con_dni FROM legacy."Pacientes" WHERE "Nombre" LIKE '%DNI%';
```

```text
 nombre_con_dni
----------------
           1959
(1 row)
```

Y en `src/lab/caja/s/MANIFIESTO.json`, `"Pacientes.Nombre LIKE '%DNI%'": 1959`. Coinciden.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-7--la-prueba-de-fuego-en-s)

## 🟡 Intermedio (8–13)

### Ejercicio 8

**Enunciado (resumen):** las cuatro tablas de M en MySQL, con sus filas.

**Solución.**

```text
$ uv run lab load --profile m --engine mysql --tables Pacientes,Protocolos,ResultadoItem,Practicas
Cargando el perfil m (caja 3e59292e9918, semilla 1996) en mysql …
  mysql: 4 tablas en 38 s
```

```sql
-- mysql
SELECT 'Pacientes', count(*) FROM Pacientes UNION ALL SELECT 'Practicas', count(*) FROM Practicas
UNION ALL SELECT 'Protocolos', count(*) FROM Protocolos UNION ALL SELECT 'ResultadoItem', count(*) FROM ResultadoItem;
```

```text
Pacientes	count(*)
Pacientes	242427
Practicas	75
Protocolos	1327622
ResultadoItem	12134453
```

Los mismos que en Postgres y que en el manifiesto. `lab load` ya lo había comprobado al cargar.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-8--las-mismas-cuatro-en-mysql)

### Ejercicio 9

**Enunciado (resumen):** los dos `EXPLAIN (ANALYZE, BUFFERS)` de la sección 4.5, leídos campo por campo.

**Solución.** Las salidas son las de la sección. Lo que se lee en ellas:

- **Por la clave:** un `Index Scan` sobre `Protocolos_pkey`, con `Index Searches: 1`: una sola bajada
  por el índice. `Buffers: shared hit=1 read=3`: cuatro páginas, tres de ellas del disco porque nadie
  las había leído antes.
- **Por el número:** un `Parallel Seq Scan` con dos *workers* y el proceso principal (`loops=3`).
  Cada uno descartó en promedio 442.540 filas (`Rows Removed by Filter`) y entre los tres devolvieron
  una (`rows=0.33` por vuelta). `Buffers: shared hit=15696`: la tabla entera, toda en memoria porque
  un `count(*)` anterior la había leído.
- **La diferencia:** 4 bloques contra 15.696, para la misma fila: unas 3.900 veces más trabajo.

> ⚠️ **Error típico:** comparar `Execution Time` (3 ms contra 30 ms, una razón de 10) en lugar de los
> bloques (una razón de casi 4.000). El tiempo esconde la diferencia porque la tabla ya estaba en
> memoria.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-9--un-plan-campo-por-campo)

### Ejercicio 10

**Enunciado (resumen):** las dos consultas en MySQL, y de dónde salen `Rows fetched before execution`
y las filas estimadas del recorrido.

**Solución.** Las salidas son las de la sección 4.5. `Rows fetched before execution` es una tabla
*const*: cuando el `WHERE` es una igualdad sobre la clave primaria, MySQL sabe que hay a lo sumo una
fila, la lee **mientras optimiza** y la ejecución ya no toca la tabla.

La estimación sale de dos cosas: MySQL cree que la tabla tiene 1.319.488 filas (lo que dice
`information_schema.tables`, ejercicio 17), y sin estadísticas ni índice sobre `NroProtocolo` supone que
una igualdad deja pasar el 10 %. Sale 131.949, contra la una que devolvió.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-10--el-mismo-plan-en-mysql)

### Ejercicio 11

**Enunciado (resumen):** la estructura de los dos planes en Oracle.

**Solución.** Con `Protocolos` de M cargada:

```bash
uv run lab measure --engine oracle --profile m -c 'SELECT * FROM legacy."Protocolos" WHERE "IdProtocolo" = 10006666'
uv run lab measure --engine oracle --profile m -c "SELECT * FROM legacy.\"Protocolos\" WHERE \"NroProtocolo\" = 'C-0048213'"
```

Las salidas son las dos estructuras de la sección 4.5: `TABLE ACCESS BY INDEX ROWID` con un `INDEX
UNIQUE SCAN` sobre `SYS_C008718` para la clave, y `TABLE ACCESS FULL` para el número. El nombre del
índice puede ser otro en tu base: lo inventa Oracle al crear la clave sin nombre. Ninguna línea trae
números de ejecución, y no debe traerlos: `lab measure` sin `--private` usa `EXPLAIN PLAN`, que no
ejecuta la consulta.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-11--la-estructura-en-oracle)

### Ejercicio 12

**Enunciado (resumen):** `COPY` de `Pacientes.csv` de M sin `ENCODING` y con `ENCODING 'LATIN1'`.

**Solución.**

```sql
-- postgres
CREATE TABLE public.pacientes_utf8 (LIKE legacy."Pacientes");
COPY public.pacientes_utf8 FROM '/caja/m/tablas/Pacientes.csv' WITH (FORMAT csv, HEADER true);
```

```text
ERROR:  invalid byte sequence for encoding "UTF8": 0xf1 0x6f 0x73 0x22
CONTEXT:  COPY pacientes_utf8, line 6
```

`0xF1 0x6F 0x73 0x22` es `ños"` en Latin-1: la línea 6 del archivo es la fila del paciente 5, cuya edad
dice `43 años`. Con la codificación declarada:

```sql
-- postgres
COPY public.pacientes_latin1 FROM '/caja/m/tablas/Pacientes.csv' WITH (FORMAT csv, HEADER true, ENCODING 'LATIN1');
```

```text
COPY 242427
```

Postgres convierte cada byte de Latin-1 a UTF-8 al leerlo, y la base queda bien codificada.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-12--la-carga-sucia-en-postgres)

### Ejercicio 13

**Enunciado (resumen):** la misma carga en MySQL con `CHARACTER SET utf8mb4`.

**Solución.**

```sql
-- mysql
CREATE TABLE prueba.pacientes_utf8 LIKE legacy.Pacientes;
LOAD DATA INFILE '/caja/m/tablas/Pacientes.csv' INTO TABLE prueba.pacientes_utf8
  CHARACTER SET utf8mb4 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
  LINES TERMINATED BY '\r\n' IGNORE 1 LINES
  (IdPaciente, Nombre, DNI, @fn, Edad, Sexo, Telefono, Direccion, ObraSocial, NroAfiliado, Sede, @fa)
  SET FechaNac = NULLIF(@fn, ''), FechaAlta = NULLIF(@fa, '');
```

```text
ERROR 1366 (HY000) at line 4: Incorrect string value: '\xF1os' for column 'Edad' at row 5
```

La fila 5 de MySQL es la línea 6 de Postgres: MySQL cuenta filas de datos después del `IGNORE 1 LINES`,
y Postgres cuenta líneas del archivo, encabezado incluido. Las dos señalan al paciente 5. (El `at line 4`
es la línea del script del cliente donde empezó la sentencia, no del CSV.)

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-13--la-carga-sucia-en-mysql)

## 🟠 Difícil (14–19)

### Ejercicio 14

**Enunciado (resumen):** una tabla externa de Oracle con `CHARACTERSET AL32UTF8`, la fila 5 y una copia.

**Solución de referencia.** La tabla externa se crea sin error, y consultarla tampoco falla en la base:
el error aparece en el cliente, al mostrar la columna.

```text
SP2-0784: Invalid or incomplete character beginning 0xF1 returned
Help: https://docs.oracle.com/error-help/db/sp2-0784/
```

La copia, con `CREATE TABLE pacientes_copia AS SELECT * FROM pacientes_utf8`, se hace sin queja, y
`DUMP` muestra lo que quedó guardado:

```sql
-- oracle
SELECT DUMP("Edad", 16) AS bytes FROM pacientes_copia WHERE "IdPaciente" = '5';
```

```text
BYTES
------------------------------------------------------------
Typ=1 Len=7: 34,33,20,61,f1,6f,73
```

`34 33 20 61 F1 6F 73` es `43 años` en Latin-1, guardado byte por byte en una base AL32UTF8. **Es más
peligroso** porque no hay un momento en que la carga falle: los bytes inválidos pasan a una tabla real
y el error aparece después, en otro programa, cuando alguien intente mostrar o exportar esa fila. Postgres
y MySQL te detienen en la puerta.

**Rúbrica.** Una respuesta correcta tiene que:
- predecir, o reconocer después, que Oracle no da error en la carga;
- mostrar los bytes con `DUMP` y explicar qué son;
- decir dónde aparece el error y por qué eso es peor que un rechazo en la carga.

Y queda invalidada si:
- publica algún número de rendimiento de Oracle (la regla vale también aquí).

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-14--la-carga-sucia-en-oracle)

### Ejercicio 15

**Enunciado (resumen):** filas estimadas contra reales en el plan de la prueba de fuego.

**Solución de referencia.** En el plan de la sección 4.5:

```text
->  Parallel Seq Scan on "Pacientes"  (cost=0.00..5406.95 rows=7850 width=0) (actual time=0.553..69.899 rows=6312.00 loops=3)
```

`rows=7850` es la estimación **por proceso**, y `rows=6312.00` el promedio real por vuelta, en tres
vueltas. El total real es 6.312 × 3 = 18.936. El total estimado es mayor que 7.850 pero menor que tres
veces eso: Postgres reparte su estimación suponiendo que el proceso principal trabaja menos que los
*workers*, y con dos *workers* divide por 2,4. Estimó unas 18.840 filas para 18.936: casi exacto, porque
`lab load` termina con un `ANALYZE` y las estadísticas de `Nombre` están frescas.

**Rúbrica.** Una respuesta correcta tiene que:
- distinguir la estimación por proceso del total;
- multiplicar las reales por `loops` para llegar a 18.936;
- relacionar la buena estimación con las estadísticas, que la [Fase 12](../12-estadisticas-y-cardinalidad.md) desarrolla.

Y queda invalidada si:
- compara 7.850 con 18.936 sin decir que una es por proceso y la otra total.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-15--estimadas-contra-reales)

### Ejercicio 16

**Enunciado (resumen):** el mismo plan, recién reiniciado Postgres y otra vez.

**Solución de referencia.** Después de `docker restart alameda-lab-postgres-1`:

```text
   Buffers: shared read=4160
         Buffers: shared read=4160
 Execution Time: 27.918 ms
---
   Buffers: shared hit=4160
         Buffers: shared hit=4160
 Execution Time: 16.112 ms
```

La primera vez, las 4.160 páginas vinieron del disco (`read`); la segunda, de la memoria compartida de
Postgres (`hit`). **El total es el mismo porque la consulta hizo el mismo trabajo**: recorrer
`Pacientes` entera. Lo que cambió es de dónde salieron las páginas, y por eso el tiempo. Por eso el
curso compara `hit + read`, y no cada uno por separado ni el tiempo.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar los dos planes, con `read` en el primero y `hit` en el segundo;
- explicar por qué la suma no cambia;
- no concluir nada sobre la consulta a partir del cambio de tiempo.

Y queda invalidada si:
- atribuye la mejora a la consulta o a un índice.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-16--en-memoria-o-del-disco)

### Ejercicio 17

**Enunciado (resumen):** `table_rows` contra `count(*)` en MySQL.

**Solución de referencia.**

```sql
-- mysql
SELECT table_name, table_rows FROM information_schema.tables WHERE table_schema = 'legacy' ORDER BY table_name;
```

```text
TABLE_NAME	TABLE_ROWS
Pacientes	240233
Practicas	75
Protocolos	1319488
ResultadoItem	12108863
```

Contra 242.427, 75, 1.327.622 y 12.134.453 del `count(*)` (ejercicio 8). En InnoDB, `table_rows` es una
**estimación** que sale de muestrear páginas, igual que `reltuples` en Postgres (`Pacientes` decía
239.414). Sirve para el planificador y para saber el orden de magnitud. **Para la prueba de fuego se
usa `count(*)`**, porque compara un número exacto con otro exacto.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar la diferencia con números;
- llamar a `table_rows` una estimación y decir de dónde sale;
- elegir `count(*)` para verificar una carga.

Y queda invalidada si:
- usa `table_rows` para verificar la carga.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-17--las-filas-que-mysql-cree-tener)

### Ejercicio 18

**Enunciado (resumen):** la prueba de fuego en los tres motores, y por qué coinciden.

**Solución de referencia.** Postgres y MySQL, 18.936 (secciones 4.6 y 4.5). Oracle:

```sql
-- oracle
SELECT count(*) AS nombre_con_dni FROM legacy."Pacientes" WHERE "Nombre" LIKE '%DNI%';
```

```text
NOMBRE_CON_DNI
--------------
	 18936
```

**Por qué coinciden aunque MySQL no distinga mayúsculas:** porque en `Nombre` no hay ningún `dni` en
minúsculas. Se comprueba en Postgres, que sí distingue:

```sql
-- postgres
SELECT count(*) FILTER (WHERE "Nombre" LIKE '%DNI%') AS like_dni, count(*) FILTER (WHERE "Nombre" ILIKE '%dni%') AS ilike_dni
FROM legacy."Pacientes";
```

```text
 like_dni | ilike_dni
----------+-----------
    18936 |     18936
(1 row)
```

**Por qué se publica el de Oracle:** es un conteo de la caja, el mismo dato del generador en los tres
motores, no un resultado de rendimiento ([`a09`](../a09-licencias-publicacion-y-riesgo.md#-qué-sí-se-publica-de-oracle-y-de-sql-server)).

**Rúbrica.** Una respuesta correcta tiene que:
- dar los tres conteos;
- comprobar con `ILIKE` que la intercalación no cambia el resultado en estos datos;
- distinguir un conteo de datos de una medición.

Y queda invalidada si:
- supone que coinciden "porque es el mismo SQL", sin mirar la intercalación.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-18--la-prueba-de-fuego-en-tres-motores)

### Ejercicio 19

**Enunciado (resumen):** un script que compare las 419 tablas con sus CSV.

**Solución de referencia.** Con el entorno del curso (`uv run python contar_todo.py src/lab/caja/m`,
desde `src/`):

```python
"""El arnés no se cree a sí mismo: las filas de cada tabla de legacy contra las del CSV de la caja."""
import csv
import sys
from pathlib import Path

import psycopg
from psycopg import sql

from lab import config
from lab.generator import schema

caja = Path(sys.argv[1]) / "tablas"
distintas = 0
with psycopg.connect(**config.POSTGRES) as conn:
    for t in schema.TABLES.values():
        encoding = "latin-1" if t.encoding == "latin-1" else "utf-8"
        with open(caja / f"{t.name}.csv", encoding=encoding, newline="") as fh:
            en_csv = sum(1 for _ in csv.reader(fh)) - 1          # menos el encabezado
        en_base = conn.execute(sql.SQL("SELECT count(*) FROM {}").format(
            sql.Identifier("legacy", t.name))).fetchone()[0]
        if en_csv != en_base:
            distintas += 1
            print(f"{t.name}: CSV {en_csv} · base {en_base}")
print(f"{len(schema.TABLES)} tablas comparadas, {distintas} distintas")
```

```text
419 tablas comparadas, 0 distintas
```

`csv.reader` cuenta **registros**, no líneas: un campo entre comillas puede tener un salto de línea
adentro, y `wc -l` lo contaría dos veces. `sql.Identifier` pone las comillas que exigen nombres como
`Errores de pegado` o `Hoja1$`.

**Rúbrica.** Una respuesta correcta tiene que:
- comparar las 419, no solo las del manifiesto;
- contar registros CSV, con la codificación de cada archivo;
- citar los nombres de tabla de forma segura.

Y queda invalidada si:
- cuenta con `wc -l`, o arma el nombre de la tabla concatenando texto.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-19--todas-las-tablas-contra-sus-csv)

## 🔴 Muy difícil (20–22)

### Ejercicio 20

**Enunciado (resumen):** qué son las 6.639 filas con documento en `Nombre` que el `LIKE` no ve.

**Solución de referencia.** Primero, que la diferencia sea toda de un lado:

```sql
-- postgres
SELECT count(*) FILTER (WHERE 'dni_in_name' = ANY (r.dirt) AND p."Nombre" NOT LIKE '%DNI%') AS documento_sin_la_palabra,
       count(*) FILTER (WHERE NOT 'dni_in_name' = ANY (r.dirt) AND p."Nombre" LIKE '%DNI%') AS la_palabra_sin_documento
FROM legacy."Pacientes" AS p
JOIN truth.patient_record AS r ON r.legacy_patient_id = p."IdPaciente";
```

```text
 documento_sin_la_palabra | la_palabra_sin_documento
--------------------------+--------------------------
                     6639 |                        0
(1 row)
```

El `LIKE` no tiene falsos positivos: todo lo que encuentra es un documento. Lo que le falta, clasificado
por cómo está escrito:

```sql
-- postgres
SELECT CASE
         WHEN p."Nombre" LIKE '%D.N.I.%'                    THEN 'D.N.I. con puntos'
         WHEN p."Nombre" ~ '\m(LC|LE)\M'                    THEN 'libreta: LC o LE'
         WHEN p."Nombre" ~ '\m(P|PASAP|PASAPORTE)\M'        THEN 'pasaporte'
         WHEN p."Nombre" ~ '\mOTRO\M'                       THEN 'OTRO'
         WHEN p."Nombre" ~ '[0-9]{1,2}\.[0-9]{3}\.[0-9]{3}' THEN 'número con puntos, sin prefijo'
         WHEN p."Nombre" ~ '[0-9]{7,8}'                     THEN 'número solo'
         ELSE 'otra forma'
       END AS como_esta_escrito,
       count(*) AS filas
FROM legacy."Pacientes" AS p
JOIN truth.patient_record AS r ON r.legacy_patient_id = p."IdPaciente"
WHERE 'dni_in_name' = ANY (r.dirt) AND p."Nombre" NOT LIKE '%DNI%'
GROUP BY 1
ORDER BY 2 DESC;
```

```text
 como_esta_escrito | filas
-------------------+-------
 número solo       |  3632
 libreta: LC o LE  |  1531
 D.N.I. con puntos |  1455
 pasaporte         |    18
 OTRO              |     3
(5 rows)
```

Suman 6.639. **El número solo** es la regla del parser de 1998 (*"si no encuentra la palabra, el primer
número de siete u ocho cifras"*), las **libretas** son el parche de 2005, y `D.N.I.` es la recepción
escribiendo como le enseñaron. Cada fila de esta tabla es un parche de la genealogía del parser, y la
[Fase 05](../05-una-persona-no-es-su-documento.md) los resuelve con un modelo, no con más patrones.

**Rúbrica.** Una respuesta correcta tiene que:
- usar `truth` para **medir**, cruzando por `IdPaciente`;
- comprobar que no hay falsos positivos antes de clasificar;
- llegar a una clasificación que sume 6.639, y relacionar sus grupos con la historia.

Y queda invalidada si:
- clasifica sin cruzar con `truth`, o la suma no cierra.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-20--18936-contra-25575)

### Ejercicio 21

**Enunciado (resumen):** convertir `Pacientes.csv` a UTF-8 con `iconv` y compararlo con el manifiesto.

**Solución de referencia.**

Desde `src/lab/caja/m/`:

```text
$ iconv -f latin1 -t utf-8 tablas/Pacientes.csv > /tmp/Pacientes.csv
$ shasum -a 256 tablas/Pacientes.csv /tmp/Pacientes.csv
cb984383d915cf9cb840d5999d1e8b8bdf9ae37cfc0b789382504f20f09e5b75  tablas/Pacientes.csv
775873a3b59bce460b420d7a1f78a86f7ffba524fb22972d19badf9fc3d8830f  /tmp/Pacientes.csv
$ grep -o '"tablas/Pacientes.csv": "[0-9a-f]*"' MANIFIESTO.json
"tablas/Pacientes.csv": "cb984383d915cf9cb840d5999d1e8b8bdf9ae37cfc0b789382504f20f09e5b75"
```

El original coincide con el manifiesto y el convertido no. El original pesa 37.216.239 bytes y el
convertido 37.313.768.

El convertido tiene 97.529 bytes más, uno por cada carácter acentuado, que en UTF-8 ocupa dos. El
argumento:

1. **El archivo convertido ya no es la caja**: no coincide con el manifiesto, y nadie puede demostrar que
   lo que cargaste es lo que todos los demás cargaron.
2. **La codificación es un dato**, como la fecha o el DNI: el `LEEME.txt` dice "un par salieron en
   Latin-1", y declararla en la carga es tratarlo como tal.
3. **Mañana llega otro archivo** con otra codificación, y la regla "convertir antes" depende de que
   alguien se acuerde; la declaración en la carga queda escrita.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar que el hash cambió y que el archivo deja de coincidir con el manifiesto;
- argumentar por la trazabilidad, no por la comodidad.

Y queda invalidada si:
- acepta convertir la caja "porque el resultado en la base es el mismo".

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-21--arreglemos-el-csv-antes)

### Ejercicio 22

**Enunciado (resumen):** qué afirmación comparativa se sostiene con bloques de Postgres, filas de MySQL y
estructura de Oracle.

**Solución de referencia.** Se sostiene una afirmación **sobre la forma**: los tres motores eligen un
índice único para la clave y un recorrido completo para `NroProtocolo`, y los tres examinan del orden de
la tabla entera para encontrar una fila. Eso sale de los tres planes sin ningún número de Oracle.

No se sostiene ninguna afirmación **de cantidad entre motores**: Postgres cuenta páginas de 8 KB, MySQL
cuenta filas y Oracle no publica nada. "Postgres lee menos que MySQL" compara unidades distintas. Para
comparar Postgres y MySQL habría que medir la misma unidad en los dos (filas examinadas, que `lab
measure` da en los dos, o páginas de InnoDB desde `performance_schema`), y Oracle queda siempre como
apuesta sin resolver.

**Rúbrica.** Una respuesta correcta tiene que:
- separar la forma del plan, que se compara, de las cantidades, que no;
- nombrar las unidades de cada motor;
- proponer una medición con la misma unidad para Postgres y MySQL.

Y queda invalidada si:
- compara bloques de Postgres con filas de MySQL, o usa un número de Oracle.

[← Volver al ejercicio](../01-la-caja-y-el-arnes.md#-ejercicio-22--qué-se-puede-comparar)
