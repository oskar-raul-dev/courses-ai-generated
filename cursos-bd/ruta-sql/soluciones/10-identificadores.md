# ✅ Soluciones — Fase 10: Identificadores

> **Curso:** Ruta SQL · Solucionario de la [Fase 10](../10-identificadores.md)
> **Ejercicios:** 26 · **Perfil:** M · **Motores:** Postgres y MySQL de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso); Python 3.13 con el entorno del curso
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todas las soluciones suponen el modelo de `uv run lab load --profile m --model` y MySQL con sus cuatro tablas de la caja.
Los UUID generados al azar y las horas van a ser otros en tu corrida.

---

## 🟢 Fácil (1–7)

### Ejercicio 1

**Enunciado (resumen):** los negativos por año.

**Solución.**

```sql
-- postgres
SELECT extract(year FROM "Fecha")::int AS anio, count(*) FILTER (WHERE "IdProtocolo" < 0) AS negativos
FROM legacy."Protocolos" GROUP BY 1 HAVING count(*) FILTER (WHERE "IdProtocolo" < 0) > 0 ORDER BY 1;
```

```text
 anio | negativos
------+-----------
 2004 |      2211
 2005 |      3256
 2006 |      3668
 2007 |      4583
 2008 |      5161
 2009 |      5711
 2010 |      7777
 2011 |      3943
(8 rows)
```

36.310 en total, el 43 % de los 84.466 protocolos de esos años. Un autonumérico aleatorio de Jet cae en todo el rango de
un entero con signo, y la mitad de ese rango es negativa; no llega al 50 % porque 2004 empieza con números secuenciales:
la replicación arranca a mediados de marzo.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-1--los-años-de-jet)

### Ejercicio 2

**Enunciado (resumen):** los números visibles que no tienen la forma de siempre.

**Solución.**

```sql
-- postgres
SELECT "IdProtocolo", "NroProtocolo", "Fecha"::date, "Sede" FROM legacy."Protocolos"
WHERE "NroProtocolo" !~ '^([A-Z]-)?[0-9]{6,7}$' ORDER BY "Fecha";
```

```text
 IdProtocolo | NroProtocolo |   Fecha    | Sede
-------------+--------------+------------+------
  1482172264 | 1482172264   | 2004-03-16 | C
   275807846 | 275807846    | 2004-03-17 | C
 -1324281976 | -1324281976  | 2004-03-19 | C
 …
   194795245 | 194795245    | 2004-03-21 | C
(13 rows)
```

Del 16 al 21 de marzo de 2004 el número visible fue el identificador de Jet, hasta que Rubén agregó `NroProtocolo` con
`DMax + 1`. Es la semana del médico que llamó para preguntar si era un chiste.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-2--la-semana-de-los-números-raros)

### Ejercicio 3

**Enunciado (resumen):** un hueco en una *identity*.

**Solución.**

```sql
-- postgres
CREATE TABLE staging.seq_demo (id bigint GENERATED ALWAYS AS IDENTITY (CACHE 20) PRIMARY KEY, note text);
INSERT INTO staging.seq_demo (note) VALUES ('uno');
BEGIN; INSERT INTO staging.seq_demo (note) VALUES ('se deshace'); ROLLBACK;
INSERT INTO staging.seq_demo (note) VALUES ('dos');
SELECT * FROM staging.seq_demo ORDER BY id;
```

```text
 id | note
----+------
  1 | uno
  3 | dos
(2 rows)
```

`nextval` no participa de la transacción: si la devolviera al deshacerse, dos sesiones tendrían que esperarse para
pedir números, y eso es lo que una secuencia existe para evitar.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-3--un-hueco)

### Ejercicio 4

**Enunciado (resumen):** la fecha de un UUIDv7.

**Solución.**

```sql
-- postgres
SELECT u, uuid_extract_version(u), uuid_extract_timestamp(u) FROM (SELECT uuidv7() AS u) AS x;
```

```text
                  u                   | uuid_extract_version |   uuid_extract_timestamp
--------------------------------------+----------------------+----------------------------
 01a13923-eb0e-7267-8cbc-bf65bccebccb |                    7 | 2026-10-14 06:40:17.678+00
(1 row)
```

El `7` que se ve en el tercer grupo (`7267`) es la versión; los primeros doce dígitos son los milisegundos.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-4--la-fecha-de-un-uuidv7)

### Ejercicio 5

**Enunciado (resumen):** un UUIDv4.

**Solución.**

```sql
-- postgres
SELECT u, uuid_extract_version(u), uuid_extract_timestamp(u) FROM (SELECT gen_random_uuid() AS u) AS x;
```

```text
                  u                   | uuid_extract_version | uuid_extract_timestamp
--------------------------------------+----------------------+------------------------
 0345fec7-e895-4b66-975f-7176739df5ed |                    4 |
(1 row)
```

Un v4 tiene 122 bits al azar y ninguna fecha: `uuid_extract_timestamp` devuelve `NULL`.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-5--un-uuidv4)

### Ejercicio 6

**Enunciado (resumen):** las tres claves en Postgres.

**Solución.** Después de `01_postgres_keys.sql` y `02_load_keys.sql`:

```sql
-- postgres
SELECT c.relname, pg_size_pretty(pg_relation_size(c.oid))
FROM pg_class AS c JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE n.nspname = 'staging' AND c.relname ~ '^order_(bigint|uuid4|uuid7)' ORDER BY 1;
```

```text
           relname           | pg_size_pretty
-----------------------------+----------------
 order_bigint                | 66 MB
 order_bigint_order_id_seq   | 8192 bytes
 order_bigint_patient_id_idx | 18 MB
 order_bigint_pkey           | 28 MB
 order_uuid4                 | 76 MB
 order_uuid4_patient_id_idx  | 18 MB
 order_uuid4_pkey            | 54 MB
 order_uuid7                 | 76 MB
 order_uuid7_patient_id_idx  | 18 MB
 order_uuid7_pkey            | 40 MB
(10 rows)
```

Las tablas con UUID ocupan 10 MB más que la de `bigint`: ocho bytes más por fila, en 1,3 millones de filas.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-6--las-tres-claves-en-postgres)

### Ejercicio 7

**Enunciado (resumen):** las tres claves en MySQL.

**Solución.** Desde `src/`, con el entorno del curso: `uv run python 10-identificadores/mysql_keys.py`.

```text
order_bigint: 1327622 filas en 24 s
order_uuid4: 1327622 filas en 28 s
order_uuid7: 1327622 filas en 32 s
order_bigint  PRIMARY                         3109 páginas    48.6 MB
order_bigint  order_bigint_patient_id_idx     2405 páginas    37.6 MB
order_uuid4   PRIMARY                         6001 páginas    93.8 MB
order_uuid4   order_uuid4_patient_id_idx      3497 páginas    54.6 MB
order_uuid7   PRIMARY                         3816 páginas    59.6 MB
order_uuid7   order_uuid7_patient_id_idx      3497 páginas    54.6 MB
```

Los tiempos son contexto: incluyen generar las claves en Python y mandarlas por la red, en lotes de 5.000.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-7--las-tres-claves-en-mysql)

---

## 🟡 Intermedio (8–14)

### Ejercicio 8

**Enunciado (resumen):** el índice por paciente en los dos motores.

**Solución.** De los ejercicios 6 y 7: en MySQL, 37,6 MB con `bigint` y 54,6 MB con cualquiera de los dos UUID; en
Postgres, 18 MB en las tres. Una entrada del índice secundario de InnoDB es el paciente más la clave primaria, porque
la fila se busca por la clave en el árbol de la tabla; en Postgres es el paciente más un puntero físico de 6 bytes, que no
depende de la clave. En MySQL, la clave primaria se paga en cada índice de la tabla.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-8--el-índice-secundario-carga-la-clave)

### Ejercicio 9

**Enunciado (resumen):** el WAL de cada carga.

**Solución.** La misma carga de `02_load_keys.sql`, con un `CHECKPOINT` y la posición del WAL antes de cada tabla:

```sql
-- postgres
CHECKPOINT;
SELECT pg_current_wal_lsn() AS a \gset
INSERT INTO staging.order_uuid4 (patient_id, ordered_on, site_code)
SELECT patient_id, ordered_on, site_code FROM alameda.lab_order ORDER BY ordered_on, lab_order_id;
SELECT pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), :'a')) AS wal_uuid4;
-- y lo mismo para las otras dos
```

```text
 wal_bigint | wal_uuid4 | wal_uuid7
------------+-----------+-----------
 280 MB     | 318 MB    | 298 MB
(1 row)
```

Después de un `CHECKPOINT`, la primera modificación de cada página escribe la página entera en el WAL. Las inserciones en
orden tocan siempre la última hoja del índice; las del UUIDv4 caen en cualquiera, y cada una que se toca por primera vez
desde el `CHECKPOINT` va entera al WAL.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-9--el-wal-de-cada-carga)

### Ejercicio 10

**Enunciado (resumen):** el volumen de una semana.

**Solución.**

```sql
-- postgres
WITH s AS (SELECT substring("NroProtocolo" from 3)::int AS n, "Fecha"::date AS d
           FROM legacy."Protocolos" WHERE "NroProtocolo" LIKE 'C-%')
SELECT (SELECT min(n) FROM s WHERE d = '2025-03-10') - (SELECT min(n) FROM s WHERE d = '2025-03-03') AS diferencia_de_numeros,
       (SELECT count(*) FROM s WHERE d >= '2025-03-03' AND d < '2025-03-10') AS protocolos_de_la_semana;
```

```text
 diferencia_de_numeros | protocolos_de_la_semana
-----------------------+-------------------------
                  1735 |                    1741
(1 row)
```

La diferencia la explica `DMax + 1`: esa semana hay 1.741 protocolos y 1.735 números distintos, seis repetidos. Para un
competidor, el error es irrelevante: sabe que la sede central atiende unos 1.700 protocolos por semana.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-10--el-volumen-de-una-semana)

### Ejercicio 11

**Enunciado (resumen):** el MD5 revertido.

**Solución.** `04_what_ids_leak.sql`:

```text
 urls_2018 | revertidas
-----------+------------
     25517 |      25517
(1 row)
```

El diccionario tiene 4.200.000 entradas (seis prefijos por 700.000 números) y se armó en 7,3 segundos en esta máquina. No
hace falta un diccionario de todos los MD5 posibles, solo de todos los números de protocolo posibles, que son pocos.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-11--el-md5-revertido)

### Ejercicio 12

**Enunciado (resumen):** la secuencia atrás.

**Solución.** `03_sequence_behind.sql`:

```text
INSERT 0 1291312
ERROR:  duplicate key value violates unique constraint "lab_order_new_pkey"
DETAIL:  Key (lab_order_id)=(1) already exists.
```

La carga trae sus identificadores (con `BY DEFAULT` está permitido) y la secuencia sigue en 1. El primer protocolo nuevo pide
1, que es el primer protocolo de 1997. El script deja afuera los negativos porque la secuencia arranca en 1; con ellos, el
problema sería el mismo.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-12--la-secuencia-atrás)

### Ejercicio 13

**Enunciado (resumen):** `setval` y el techo.

**Solución.**

```sql
-- postgres
SELECT setval(pg_get_serial_sequence('staging.lab_order_new', 'lab_order_id'), (SELECT max(lab_order_id) FROM staging.lab_order_new));
INSERT INTO staging.lab_order_new (patient_id, ordered_on) VALUES (1, '2026-10-11') RETURNING lab_order_id;
```

```text
   setval
------------
 2147413574
(1 row)

 lab_order_id
--------------
   2147413575
(1 row)
```

El máximo es un identificador aleatorio de Jet de 2006, el más alto que salió. Desde ahí, hasta 2.147.483.647, quedan 70.072
números (70.073 antes de este `INSERT`).

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-13--setval-y-el-techo)

### Ejercicio 14

**Enunciado (resumen):** `AUTO_INCREMENT` después de la misma carga.

**Solución.**

```sql
-- mysql
CREATE TABLE staging.lab_order_new (lab_order_id int NOT NULL AUTO_INCREMENT PRIMARY KEY, patient_id int NOT NULL);
INSERT INTO staging.lab_order_new SELECT IdProtocolo, IdPaciente FROM legacy.Protocolos WHERE IdProtocolo > 0;
INSERT INTO staging.lab_order_new (patient_id) VALUES (1);
SELECT max(lab_order_id),
       (SELECT auto_increment FROM information_schema.tables
        WHERE table_schema = 'staging' AND table_name = 'lab_order_new') AS siguiente
FROM staging.lab_order_new;
```

```text
+-------------------+------------+
| max(lab_order_id) | siguiente  |
+-------------------+------------+
|        2147413575 | 2147413576 |
+-------------------+------------+
```

InnoDB lleva `AUTO_INCREMENT` siempre por encima del máximo insertado, también cuando el valor viene explícito. No hay
error al día siguiente, y el contador hereda el máximo de Jet.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-14--auto_increment-después-de-una-carga)

---

## 🟠 Difícil (15–20)

### Ejercicio 15

**Enunciado (resumen):** el techo en los dos motores.

**Solución.**

```sql
-- mysql
INSERT INTO staging.lab_order_new (lab_order_id, patient_id) VALUES (2147483646, 1);
INSERT INTO staging.lab_order_new (patient_id) VALUES (1);
INSERT INTO staging.lab_order_new (patient_id) VALUES (1);
```

```text
ERROR 1062 (23000) at line 3: Duplicate entry '2147483647' for key 'lab_order_new.PRIMARY'
```

```sql
-- postgres
SELECT setval(pg_get_serial_sequence('staging.lab_order_new', 'lab_order_id'), 2147483647);
INSERT INTO staging.lab_order_new (patient_id, ordered_on) VALUES (1, '2026-10-11');
```

```text
ERROR:  nextval: reached maximum value of sequence "lab_order_new_lab_order_id_seq" (2147483647)
```

MySQL llega al techo, se queda ahí y repite el último valor, así que el error es de clave duplicada y no dice nada del
techo. Postgres lo dice. Con `bigint`, ninguno de los dos llega.

**Rúbrica.** Una respuesta correcta tiene que:
- reproducir los dos mensajes;
- explicar por qué el de MySQL no menciona el techo.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-15--el-techo-en-los-dos-motores)

### Ejercicio 16

**Enunciado (resumen):** clave interna e identificador público.

**Solución de referencia.**

```sql
-- postgres
ALTER TABLE staging.order_bigint ADD COLUMN public_id uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE staging.order_bigint ADD CONSTRAINT order_bigint_public_id_key UNIQUE (public_id);
SELECT c.relname, pg_size_pretty(pg_relation_size(c.oid))
FROM pg_class AS c JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE n.nspname = 'staging' AND c.relname LIKE 'order_bigint%' ORDER BY 1;
```

```text
           relname           | pg_size_pretty
-----------------------------+----------------
 order_bigint                | 87 MB
 order_bigint_order_id_seq   | 8192 bytes
 order_bigint_patient_id_idx | 14 MB
 order_bigint_pkey           | 28 MB
 order_bigint_public_id_key  | 40 MB
(5 rows)
```

El índice nuevo mide 40 MB, construido de una vez y ordenado; con las inserciones del día a día, al azar, se acerca a los 54
MB del primario con UUIDv4. La clave primaria sigue en 28 MB, y el `ADD COLUMN` con un valor por defecto volátil reescribió
la tabla (de 66 a 87 MB) y reconstruyó el índice por paciente, que quedó en 14 MB, más compacto que los 18 de la carga
fila por fila. En MySQL el beneficio es mayor: la clave interna `bigint` mantiene chicos todos los secundarios.

**Rúbrica.** Una respuesta correcta tiene que:
- poner el identificador público en una columna aparte, con índice único;
- medir el índice nuevo y decir qué índices no crecieron;
- notar que agregar la columna reescribió la tabla.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-16--la-clave-interna-y-el-público)

### Ejercicio 17

**Enunciado (resumen):** divisiones de página.

**Solución.**

```sql
-- mysql
SELECT table_name, index_name, stat_value AS hojas FROM mysql.innodb_index_stats
WHERE database_name = 'staging' AND table_name LIKE 'order_%' AND stat_name = 'n_leaf_pages' AND index_name = 'PRIMARY';
```

```text
+--------------+------------+-------+
| table_name   | index_name | hojas |
+--------------+------------+-------+
| order_bigint | PRIMARY    |  3103 |
| order_uuid4  | PRIMARY    |  5190 |
| order_uuid7  | PRIMARY    |  3794 |
+--------------+------------+-------+
```

Con UUIDv4 hay 5.190 hojas contra 3.794 con v7, para las mismas filas del mismo ancho: las hojas del v4 están a medio llenar,
porque cada división parte una hoja llena en dos mitades y las inserciones siguientes caen en cualquier lado. Y el v4 tiene
6.001 páginas en total: 811 páginas que no son hojas (los niveles internos del árbol y el espacio reservado de los
segmentos), contra 22 del v7.

**Rúbrica.** Una respuesta correcta tiene que:
- comparar a igual ancho (v4 contra v7), para aislar el efecto del orden;
- explicar la diferencia entre hojas y páginas totales.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-17--divisiones-de-página)

### Ejercicio 18

**Enunciado (resumen):** *hi/lo*.

**Solución.**

```sql
-- postgres
CREATE SEQUENCE staging.hilo_seq INCREMENT BY 50;
SELECT nextval('staging.hilo_seq') AS primera_sesion;   -- desde una sesión
SELECT nextval('staging.hilo_seq') AS segunda_sesion;   -- desde otra
```

```text
 primera_sesion
----------------
              1
 segunda_sesion
----------------
             51
```

Un ORM con el optimizador `pooled` (Hibernate) o *hi/lo* pide un valor y se reserva cincuenta: la primera sesión usa del 1 al
50 sin volver a la base, la segunda del 51 al 100. Una sesión que termina con 30 usados deja 20 de hueco. La secuencia de la
base tiene que tener el mismo `INCREMENT BY` que el ORM espera, o los rangos se pisan.

**Rúbrica.** Una respuesta correcta tiene que:
- explicar qué reserva cada sesión;
- decir qué pasa si el incremento de la base y el del ORM no coinciden.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-18--hilo)

### Ejercicio 19

**Enunciado (resumen):** el diccionario para el perfil S.

**Solución.**

```sql
-- postgres
\timing on
SELECT count(*), sum(length(md5(p || lpad(n::text, 7, '0'))))
FROM unnest(ARRAY['C-', 'A-', 'V-', 'J-', 'R-', 'E-']) AS p CROSS JOIN generate_series(1, 70000) AS n;
```

```text
 count  |   sum
--------+----------
 420000 | 13440000
(1 row)

Time: 344.567 ms
```

Un tercio de segundo. El `sum(length(…))` obliga a calcular cada hash: con solo `count(*)` sobre una subconsulta, el
optimizador puede no calcularlos. En la base de verdad, con unos cinco millones de números en la sede central, el
diccionario crece en proporción, y sigue siendo un trabajo de minutos.

**Rúbrica.** Una respuesta correcta tiene que:
- forzar el cálculo de los hashes;
- extrapolar el tamaño del espacio, no del tiempo de esta máquina.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-19--el-diccionario-del-perfil-s)

### Ejercicio 20

**Enunciado (resumen):** un UUIDv7 en la URL del hisopado de 2020.

**Solución de referencia.** No. El UUIDv7 dice el día y la hora en que se creó el protocolo, y en 2020 el día de un hisopado
es un dato de salud: quien vea el enlace (un empleador, un familiar) sabe cuándo la persona se testeó, aunque no vea el
resultado. La alternativa es un UUIDv4 o un *token* al azar para la URL, y el v7, si se quiere por orden, como clave
interna que no sale.

**Rúbrica.** Una respuesta correcta tiene que:
- leer la fecha de un v7 con `uuid_extract_timestamp`;
- argumentar por qué esa fecha es sensible en un laboratorio;
- separar el identificador interno del público.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-20--la-fecha-como-dato)

---

## 🔴 Muy difícil (21–26)

### Ejercicio 21

**Enunciado (resumen):** el enlace reenviado.

**Solución de referencia.** Falla la autorización, no el identificador. El enlace es opaco y el empleador no lo adivinó: se
lo dieron. **El ID opaco no arregla un IDOR**: lo que hace falta es que el portal, en cada pedido, verifique que quien pide
el protocolo es el paciente (o alguien que él autorizó, como su médico), con una sesión autenticada. Un enlace sin
autenticación es un secreto compartido, y un secreto que se reenvía deja de serlo. En la [Fase 23](../23-la-base-como-producto.md), la regla vive en la base,
como seguridad por fila.

**Rúbrica.** Una respuesta correcta tiene que:
- separar adivinar un identificador de usar uno ajeno;
- proponer una regla de autorización por pedido;
- decir dónde se verifica.

Y queda invalidada si:
- propone un identificador más largo como solución.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-21--el-idor)

### Ejercicio 22

**Enunciado (resumen):** qué hacer con los identificadores de Jet.

**Solución de referencia.** Conservarlos como **identificador heredado**, en su columna, y darle a cada protocolo una clave
`bigint` nueva. Renumerar sin conservar el viejo rompe cada referencia de afuera: los PDF del listado (`ordenes/2006/-2075483110.bmp`),
los correos, el SIH, los papeles. Conservarlos como clave obliga a convivir con 36.310 negativos, con 84.466 aleatorios entre
2004 y 2011, y con un máximo a 70.072 números del techo de `integer` (ejercicio 13). La columna heredada lleva un índice único
y se usa solo para resolver referencias viejas.

**Rúbrica.** Una respuesta correcta tiene que:
- decir qué referencias de afuera usan el identificador viejo;
- usar los números de la caja;
- no depender del orden de los identificadores de Jet para nada.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-22--los-identificadores-de-jet)

### Ejercicio 23

**Enunciado (resumen):** `SYS_GUID()` en Oracle.

**Solución.** No publicamos el resultado: es un número de Oracle (ver [`a09`](../a09-licencias-publicacion-y-riesgo.md)). Lo que
hay que hacer, en `sqlplus`: una tabla con `order_id RAW(16) DEFAULT SYS_GUID() PRIMARY KEY` y las columnas de los protocolos,
cargada en el orden de llegada desde una tabla con los protocolos de M; después, `SELECT SYS_GUID() FROM dual CONNECT BY LEVEL
<= 5` para ver cómo cambian los valores seguidos, y el tamaño del índice con `DBMS_SPACE.SPACE_USAGE`. Qué mirar: si los
valores de una misma sesión comparten casi todos sus bytes y solo cambian unos pocos en el medio, el índice crece en orden. La
documentación de `SYS_GUID` describe de qué partes está hecho el valor, y por qué no es un UUID estándar.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-23--sys_guid)

### Ejercicio 24

**Enunciado (resumen):** la clave de la app sin conexión.

**Solución de referencia.** UUIDv7 generado en el teléfono como **identificador del protocolo en la app**, y una clave interna
`bigint` que asigna la base al sincronizar. El teléfono necesita poder crear el protocolo y sus resultados sin preguntarle a
nadie, y un v7 lo permite; la base quiere una clave angosta y ordenada para sus índices (en MySQL, el v7 como primaria cuesta
un 23 % de índice primario y un 45 % en cada secundario; en Postgres, 40 MB contra 28). El v7 queda con un índice único, para
que una sincronización repetida no duplique el protocolo. Y no sale en ninguna URL, por la fecha que filtra.

**Rúbrica.** Una respuesta correcta tiene que:
- justificar por qué la app necesita generar su identificador;
- usar los números de la fase para decidir dónde vive el UUID;
- resolver la sincronización repetida.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-24--uuid-como-clave)

### Ejercicio 25

**Enunciado (resumen):** `integer` o `bigint` para `result_id`.

**Solución de referencia.** En la caja M, `result` tiene 12,1 millones de filas y en 2025 sumó 2.056.411. La base de verdad tiene
unos 140 millones, unas once veces más: a ese ritmo, unos 23 millones por año. Desde 140 millones hasta 2.147 millones, un
`integer` duraría unos 85 años con el volumen de 2025, y menos si el volumen sigue creciendo como desde 2020. Pero el ahorro de
`integer` es de cuatro bytes por fila y por índice, y la Fase 09 mostró que en `result` ni siquiera se ve en la tabla (el
relleno lo absorbe). `bigint`: el costo es casi nulo y el techo desaparece.

**Rúbrica.** Una respuesta correcta tiene que:
- hacer la cuenta con el volumen medido y el de la historia;
- comparar el ahorro de `integer` con su riesgo;
- recordar el caso de los identificadores de Jet, que llegaron cerca del techo sin crecer.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-25--integer-o-bigint-para-result)

### Ejercicio 26

**Enunciado (resumen):** la URL del portal nuevo.

**Solución de referencia.** Un UUIDv4 (122 bits al azar) o un *token* de 128 bits codificado en base64url, en una columna con
índice único. En 2025 la caja tiene 192.614 protocolos; con 2^122 valores posibles, la probabilidad de acertar uno existente al
azar es de unos 3,6 · 10^-32 por intento: aun con mil millones de intentos por segundo durante un siglo, no se acierta ninguno.
El espacio tiene que ser grande contra la cantidad de protocolos que existen, no contra los de un día. Y, como en el ejercicio 21,
esto evita que se recorran, no que se reenvíen.

**Rúbrica.** Una respuesta correcta tiene que:
- elegir un identificador al azar, no derivado del protocolo;
- hacer la cuenta del espacio contra los protocolos existentes;
- recordar que la autorización sigue haciendo falta.

Y queda invalidada si:
- propone un hash del número de protocolo, con o sin sal fija.

[← Volver al ejercicio](../10-identificadores.md#-ejercicio-26--la-url-del-portal-nuevo)
