# 📎 Apéndice a04 — El arnés de forma

> **Curso:** Ruta SQL · Consulta rápida · **3 h**
> **Usado por:** todas las fases que miden · **Versiones cubiertas:** las del `compose.yaml` del
> curso, que fija el apéndice [`a02`](a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Fecha de verificación ejecutada:** la de cada sección; los tamaños, el WAL, las estadísticas
> acumuladas, SQL Server y los ejercicios, el 18/10/2026 con el perfil M. **Estado:** abierto el
> 12/10/2026 con la receta de `lab measure`, cerrado el 18/10/2026

**Esto no se lee de corrido.** Se entra buscando qué significa un campo de una salida y se sale.
Cada campo de cada salida que el curso mide **se explica una vez aquí**, y las fases enlazan a esa
explicación en lugar de repetirla.

**Qué queda fuera:** herramientas de monitoreo, APM y *dashboards*. Y los tiempos como argumento:
este curso mide **la forma** —bloques, filas examinadas contra devueltas, estimadas contra reales,
bytes de tabla, de índice y de WAL, filas bloqueadas—, porque la forma no depende de la máquina.

> 🔒 **De Oracle, este apéndice enseña a leer, no publica.** Muestra cómo se pide la estructura de un
> plan con `EXPLAIN PLAN` y `DBMS_XPLAN`, y cómo se corre una apuesta sin resolver en tu máquina.
> Ninguna salida con estadísticas de ejecución de Oracle aparece en el curso.

---

## Índice

| Qué se mide | Motor | Verificado |
|---|---|---|
| [`uv run lab measure` y su salida](#-uv-run-lab-measure-y-su-salida): `EXPLAIN (ANALYZE, BUFFERS)` campo por campo, `EXPLAIN ANALYZE` y los `Handler_read`, `EXPLAIN PLAN` y `DBMS_XPLAN` | los tres | ✅ 12/10/2026 |
| [Tamaño de tablas e índices, y el relleno](#-tamaño-de-tablas-e-índices-y-el-relleno) | PostgreSQL y MySQL | ✅ 18/10/2026 |
| [Bytes de WAL, con `EXPLAIN (ANALYZE, WAL)`](#️-bytes-de-wal-con-explain-analyze-wal) | PostgreSQL | ✅ 18/10/2026 |
| [Las estadísticas acumuladas: por consulta y por tabla](#-las-estadísticas-acumuladas-por-consulta-y-por-tabla) | PostgreSQL y MySQL | ✅ 18/10/2026 |
| [`uv run lab race`: el intercalado determinista de sesiones](#-uv-run-lab-race-sesiones-en-un-orden-fijo) | PostgreSQL y MySQL | ✅ 14/10/2026 |
| [SQL Server, en el track](#-sql-server-en-el-track) | SQL Server | ✅ 18/10/2026 |
| [Cuándo usar qué](#-cuándo-usar-qué) · [Ejercicios](#-ejercicios-8) | — | — |

---

## 📐 `uv run lab measure` y su salida

Verificado el 12/10/2026 con el perfil M cargado ([`a05`](a05-la-caja-y-el-generador.md)).

`lab measure` ejecuta una consulta en un motor y devuelve **su forma**: cuántas filas devolvió,
cuántas tuvo que mirar para devolverlas, cuántos bloques leyó y el plan. Desde `src/`:

```bash
uv run lab measure -c "SELECT count(*) FROM legacy.\"Pacientes\" WHERE \"Nombre\" LIKE '%DNI%'"
uv run lab measure --engine mysql -c "SELECT count(*) FROM legacy.Pacientes WHERE Nombre LIKE '%DNI%'"
uv run lab measure --engine oracle --profile m -f consulta.sql
```

`-c` recibe la consulta y `-f`, un archivo que la contiene. **La primera línea es siempre la misma**:
motor, perfil, el hash corto de la caja cargada y la imagen con su digest. Son los datos 2 y 3 de toda
medición publicada; el perfil y la caja salen de `lab.loaded`, y en Oracle se dicen con `--profile`.

**Postgres**, con `EXPLAIN (ANALYZE, BUFFERS)` por debajo:

```text
📐 lab measure · postgres · perfil m · caja 3e59292e9918 · pgvector/pgvector:0.8.7-pg18@sha256:2358fcba361e…
filas devueltas: 1 (estimadas: 1)
bloques: 4160 (en caché 0, leídos 4160)
filas examinadas en las hojas del plan: 242427
plan:
  Aggregate · estimadas 1 · reales 1 · bloques 4160
    Gather · estimadas 2 · reales 3 · bloques 4160
      Aggregate · estimadas 1 · reales 3 · bloques 4160
        Seq Scan on Pacientes · estimadas 7949 · reales 18936 · descartadas 223491 · bloques 4160
tiempo: 29.3 ms (contexto, no argumento)
```

| Campo | Qué es | Qué mirar |
|---|---|---|
| `filas devueltas` | las que llegaron al cliente, y las que el planificador esperaba | casi nunca es el problema |
| `bloques` | páginas de 8 KB que tocó la consulta: las que ya estaban en memoria y las que pidió al disco | **la medida de trabajo del curso**: no depende de la máquina |
| `filas examinadas en las hojas` | las que leyeron los nodos que tocan tablas o índices, sumando las que el filtro descartó | contra las devueltas: 242.427 miradas para contar 18.936 |
| `estimadas` · `reales` | lo que el planificador creyó y lo que pasó, en cada nodo | una diferencia grande explica un mal plan |
| `descartadas` | filas que el nodo leyó y su filtro tiró | trabajo sin resultado |
| `tiempo` | la ejecución, en esta máquina | **contexto**: nunca sostiene una conclusión |

Postgres 18 informa las filas reales como promedio por vuelta del nodo; `lab measure` las multiplica
por las vueltas, así que `reales` es el total. El `Gather` con `reales 3` son los tres procesos de la
consulta paralela (dos *workers* y el principal), cada uno con su conteo parcial.

**MySQL**, con los contadores `Handler_read_%` de la sesión y `EXPLAIN ANALYZE`:

```text
📐 lab measure · mysql · perfil m · caja 3e59292e9918 · mysql:9.7.2@sha256:e2bde46db656…
contadores Handler_read: first 1 · key 1 · next 0 · rnd_next 242428
filas examinadas (suma de los contadores): 242430
plan (EXPLAIN ANALYZE):
  -> Aggregate: count(0)  (cost=32064 rows=1) (actual time=104..104 rows=1 loops=1)
      -> Filter: (legacy.Pacientes.Nombre like '%DNI%')  (cost=25915 rows=26690) (actual time=2.62..103 rows=18936 loops=1)
          -> Table scan on Pacientes  (cost=25915 rows=240233) (actual time=1.06..74.3 rows=242427 loops=1)
```

`rnd_next` cuenta filas leídas recorriendo la tabla; `key` y `next`, entradas de un índice. Su suma es
la versión de MySQL de "filas examinadas". No coincide a la unidad con las filas de la tabla:
`rnd_next` cuenta también el intento que encuentra el fin (242.428 para 242.427 filas), y `first` y
`key` registran dos lecturas por índice que el plan, un recorrido de tabla, no muestra. **Se mira el
orden de magnitud**, que aquí es el mismo que en Postgres. En el plan, el `rows=` de `cost=(…)` es la
estimación y el de `actual …`, lo real. **`EXPLAIN FORMAT=TREE`**, sin `ANALYZE`, da el mismo árbol sin
ejecutar la consulta: solo `cost` y `rows` estimadas, y sirve para ver el plan de una consulta que no
quieres correr.

**Oracle**, solo la estructura, de `EXPLAIN PLAN` sin ejecutar la consulta:

```text
📐 lab measure · oracle · perfil m · caja 3e59292e9918 · gvenzl/oracle-free:23.26.3-slim-faststart@sha256:f5ff19033860…
🔒 solo la estructura del plan: de Oracle el curso no publica números (apéndice a09)
  Plan hash value: 1420814344

  ----------------------------------------
  | Id  | Operation          | Name      |
  ----------------------------------------
  |   0 | SELECT STATEMENT   |           |
  |   1 |  SORT AGGREGATE    |           |
  |*  2 |   TABLE ACCESS FULL| Pacientes |
  ----------------------------------------

  Predicate Information (identified by operation id):
  ---------------------------------------------------

     2 - filter("Nombre" LIKE '%DNI%')
```

Se lee de adentro hacia afuera: el `TABLE ACCESS FULL` recorre la tabla, el asterisco marca la
operación que tiene un predicado (abajo, el filtro), y `SORT AGGREGATE` cuenta. Con `--private`, `lab
measure` ejecuta la consulta y muestra las estadísticas de ejecución **solo en tu terminal**: es como
se resuelve una apuesta 🪞🔒, y esa salida no se publica.

---

## 🏁 `uv run lab race`: sesiones en un orden fijo

Verificado el 14/10/2026 con el perfil M cargado y las tablas de la
[Fase 15](15-aislamiento-comparado.md) (`src/15-aislamiento-comparado/01_setup.sql`).

Una anomalía de concurrencia que aparece "a veces" no se puede estudiar ni publicar. `lab race` la hace aparecer **siempre**:
cada sesión es una conexión con su propio hilo, y el arnés manda los pasos de a uno, en el orden de una **permutación**. No
manda el siguiente hasta que cada sesión ocupada terminó su paso o **está esperando un bloqueo según el catálogo del motor**:
`pg_blocking_pids()` en Postgres; `performance_schema.data_lock_waits` y `metadata_locks` en MySQL. Sin `sleep` y sin repetir
hasta que salga. La idea es la del *isolation tester* con que Postgres prueba su propio aislamiento.

El escenario es un archivo `.race`:

```text
-- @engine postgres                     postgres o mysql (--engine lo cambia)
-- @isolation repeatable read           el valor de {isolation} (--isolation lo cambia)
-- @setup TRUNCATE staging.specimen_take        antes de cada permutación, una sentencia por línea
-- @check SELECT count(*) FROM staging.specimen_take    al final: lo que quedó confirmado
-- @teardown …                          después de cada permutación
a1: BEGIN ISOLATION LEVEL {isolation};
b1: BEGIN ISOLATION LEVEL {isolation};
a2: SELECT …;                           la letra es la sesión; el paso sigue hasta la próxima etiqueta
-- @permutation a1 b1 a2 b2 a3 b3 a4 b4 una o varias; sin ninguna, el orden del archivo
```

Desde `src/`:

```bash
uv run lab race -f 15-aislamiento-comparado/write_skew.race --isolation serializable
uv run lab race -f 15-aislamiento-comparado/lost_update.race --isolation repeatable-read --sql
uv run lab race -f escenario.race --permutation "a1 b1 b2 a2"
```

```text
🏁 lab race · postgres · permutación a1 a2 b1 b2 a3 b3 a4 b4 · repeatable read
 a1  BEGIN
 a2  1 fila  (28.00)
 b1  BEGIN
 b2  1 fila  (28.00)
 a3  UPDATE 1
 b3  ⏳ espera un bloqueo
 a4  COMMIT
   ↳ b3  ✗ 40001 could not serialize access due to concurrent update
 b4  ROLLBACK
resultado: a sin errores · b con error 40001 en b3
comprobación: 1 fila  (18.00)
```

| Campo | Qué es | Qué mirar |
|---|---|---|
| `1 fila  (28.00)` | lo que devolvió un `SELECT`: cuántas filas y, hasta tres, sus valores | lo que **vio** esa sesión en ese momento |
| `UPDATE 1`, `INSERT 1` | la etiqueta del motor: filas afectadas | 0 donde esperabas 1 es una fila que otro ya cambió |
| `⏳ espera un bloqueo` | el paso no terminó y el catálogo lo muestra esperando | quién lo bloquea lo dice `pg_locks` ([Fase 18](18-bloqueos-deadlocks-y-ddl.md)) |
| `↳ b3 …` | un paso bloqueado que terminó después, con su resultado; sale debajo del paso que lo destrabó | aquí aparecen los errores de serialización y los *deadlocks* |
| `✗ 40001`, `✗ 1213` | el error, con el código del motor (SQLSTATE en Postgres, número en MySQL) | el que la aplicación tiene que atrapar ([`a08`](a08-catalogo-de-errores.md)) |
| `✗ imposible` | el siguiente paso le toca a una sesión que espera a otra que no avanza: el motor no deja que ese orden ocurra | es un resultado, no una falla del arnés: el nivel lo impidió esperando |
| `resultado` | qué sesiones terminaron con error, y en qué paso | |
| `comprobación` | lo que devolvió cada `@check`, con todo confirmado o deshecho | la anomalía se juzga aquí: dos tomas de la misma muestra, un saldo que no cierra |

Tres reglas que el arnés no puede cumplir por ti:

- **El `@setup` deja el estado igual en cada corrida.** En MySQL eso es `TRUNCATE` y no `DELETE`: el `DELETE` deja registros
  marcados como borrados en el índice hasta que InnoDB los purga, y una lectura bloqueante bloquea uno de esos registros o
  solo el hueco del final según si el *purge* ya pasó. La misma permutación dio dos resultados distintos hasta que el *setup*
  cambió a `TRUNCATE`.
- **Una sesión espera; nunca se le manda un paso nuevo.** Si la permutación lo pide, el arnés espera `--patience` segundos
  (3 por defecto, más que el `deadlock_timeout` de un segundo de Postgres, para que un *deadlock* alcance a detectarse); si
  sigue bloqueada, cancela lo pendiente y declara el orden imposible.
- **Los valores van escritos.** Un paso no puede usar lo que leyó otro: si la aplicación escribe el saldo que calculó, el
  escenario escribe ese número (en `lost_update.race`, 18,00 y 23,00 sobre un saldo de 28,00).

Desde Python, el mismo arnés acepta pasos que son funciones y corren en el hilo de la sesión, con su conexión; así una caja
llama al web service fiscal en medio de su transacción ([Fase 16](16-el-folio-sin-huecos.md)):

```python
from lab.race import Race
race = Race("postgres", setup=["TRUNCATE staging.specimen_take"])
race.isolation = "SERIALIZABLE"
race.step("a1", "BEGIN ISOLATION LEVEL {isolation}").step("a2", lambda conn: conn.execute("SELECT 1").fetchone())
outcomes = race.run(["a1", "a2"])          # una lista de Outcome: label, text, error, rows, value
```

`lab race` no mide carga: el orden fijo es justamente lo contrario de la carga. Para cuánto pasa con cuatro técnicos a la vez,
las fases usan hilos de verdad y cuentan el resultado (`technicians.py` en la [Fase 15](15-aislamiento-comparado.md)).

> ⚠️ **Por qué `data_lock_waits` y no `information_schema.innodb_trx`.** La primera versión del arnés miraba `innodb_trx`, y
> no vio nunca la espera. Medido: con un `UPDATE` que empieza a esperar a los 0,3 s, `innodb_trx` consultada cada 5 ms desde
> antes **no mostró la espera en ninguna de 272 consultas**; consultada cada 200 ms, la mostró en 8 de 10. Se comporta como una
> foto que no se renueva mientras se la sigue leyendo seguido; la documentación de MySQL solo advierte que esos datos son "un
> vistazo" a algo que cambia rápido. `performance_schema.data_lock_waits` mostró la espera en cada consulta.

---

## 📏 Tamaño de tablas e índices, y el relleno

Verificado el 18/10/2026 con el perfil M.

**Postgres** da el tamaño exacto, en bytes, y `pgstattuple` lee la tabla entera para decir cuánto de eso
son filas vivas, filas muertas y espacio libre:

```sql
SELECT pg_size_pretty(pg_relation_size('legacy."Pacientes"'))       AS tabla,
       pg_size_pretty(pg_indexes_size('legacy."Pacientes"'))        AS indices,
       pg_size_pretty(pg_total_relation_size('legacy."Pacientes"')) AS total,
       pg_relation_size('legacy."Pacientes"') / 8192                AS bloques;
SELECT tuple_count, dead_tuple_count, free_percent, tuple_percent FROM pgstattuple('legacy."Pacientes"');
```

```text
 tabla | indices | total | bloques
-------+---------+-------+---------
 33 MB | 5344 kB | 38 MB |    4160

 tuple_count | dead_tuple_count | libre_pct | ocupado_pct
-------------+------------------+-----------+-------------
      242427 |                0 |       0.8 |        94.6
```

| Campo | Qué es | Qué mirar |
|---|---|---|
| `pg_relation_size` | la tabla sola, sin índices ni TOAST | dividido por 8.192, los bloques que lee un `Seq Scan`: los 4.160 de `lab measure` |
| `pg_indexes_size` | todos los índices de la tabla | contra la tabla: un índice más grande que su tabla es una pregunta |
| `pg_total_relation_size` | tabla, índices y TOAST | lo que ocupa en disco |
| `dead_tuple_count` | versiones viejas que `VACUUM` todavía no limpió | la factura de la [Fase 17](17-mvcc-y-su-factura.md) |
| `free_percent` | espacio libre dentro de las páginas | después de un `VACUUM`, el hueco que dejó: se reutiliza, no se devuelve |

**MySQL** da estimaciones, de las estadísticas de InnoDB, y en páginas de 16 KB:

```sql
ANALYZE TABLE legacy.Pacientes;
SELECT table_rows, data_length, index_length, data_free FROM information_schema.TABLES
WHERE table_schema = 'legacy' AND table_name = 'Pacientes';
SELECT n_rows, clustered_index_size, sum_of_other_index_sizes FROM mysql.innodb_table_stats
WHERE database_name = 'legacy' AND table_name = 'Pacientes';
```

```text
| TABLE_ROWS | datos_mb | indices_mb | libre_mb |
|     240606 |     29.6 |        0.0 |      7.0 |
| n_rows | clustered_index_size | sum_of_other_index_sizes |
| 240606 |                 1892 |                        0 |
```

`table_rows` es una **estimación**: 240.606 para 242.427 filas reales. `data_length` es el índice
*clustered*, que en InnoDB **es la tabla** (1.892 páginas de 16 KB); `index_length`, los índices
secundarios, que aquí no hay. Para comparar con Postgres se comparan bytes, no "bloques": 29,6 MB contra
33 MB, la misma caja.

---

## ✍️ Bytes de WAL, con `EXPLAIN (ANALYZE, WAL)`

Verificado el 18/10/2026. `WAL` en el `EXPLAIN` cuenta lo que la sentencia escribió en el registro de
transacciones; es lo que la [Fase 08](08-los-dos-extremos-del-mismo-error.md) y la
[Fase 19](19-json-en-los-motores.md) comparan entre una fila y un documento. Sobre una copia de 1.000
pacientes, el mismo `UPDATE` de 100 filas dos veces seguidas:

```sql
EXPLAIN (ANALYZE, WAL, COSTS OFF, TIMING OFF, SUMMARY OFF)
UPDATE lab.a04_wal SET "DNI" = "DNI" WHERE "IdPaciente" <= 100;
```

```text
 Update on a04_wal (actual rows=0.00 loops=1)
   Buffers: shared hit=309 dirtied=1 written=4
   WAL: records=200 bytes=15995
…
 Update on a04_wal (actual rows=0.00 loops=1)
   Buffers: shared hit=282 dirtied=2 written=1
   WAL: records=174 fpi=1 bytes=22754
```

| Campo | Qué es | Qué mirar |
|---|---|---|
| `records` | entradas del WAL que escribió la sentencia | contra las filas: 200 para 100 filas en esta copia sin índices; cada índice que se actualiza agrega las suyas |
| `fpi` | *full page images*: la primera escritura de una página después de un *checkpoint* la copia entera | la segunda corrida escribió **más** con **menos** registros, por una página entera |
| `bytes` | lo que se escribió | dividido por las filas, el costo por fila; **se mide en régimen**, sin `fpi`, o se dice |

Una sola corrida de WAL no se publica: la página entera aparece o no según dónde cayó el *checkpoint*.
Se calienta, se repite y se dice cuántas corridas tuvieron `fpi`.

---

## 📊 Las estadísticas acumuladas: por consulta y por tabla

Verificado el 18/10/2026. `lab measure` mide una ejecución; estas vistas acumulan **todas** desde el
último reinicio, y son lo que la [Fase 14](14-la-base-no-estaba-lenta.md) usa para encontrar la
consulta que pesa.

**Por consulta.** Postgres con `pg_stat_statements` (cargada en el `compose.yaml`) y MySQL con el
*digest* de `performance_schema`. Los dos **normalizan** el texto: los literales pasan a `$1` o `?`, y dos
consultas que solo cambian el valor son una fila:

```text
-- Postgres: después de pg_stat_statements_reset() y dos LIKE distintos
 calls | rows | bloques | consulta
     2 |    2 |    8320 | SELECT count(*) FROM legacy."Pacientes" WHERE "Nombre" LIKE $1

-- MySQL: después de TRUNCATE performance_schema.events_statements_summary_by_digest
| calls | examinadas | enviadas | consulta                                                             |
|     2 |     484854 |        2 | SELECT COUNT ( * ) FROM `legacy` . `Pacientes` WHERE `Nombre` LIKE ? |
```

`bloques` es `shared_blks_hit + shared_blks_read`. `examinadas` contra `enviadas` es la versión
acumulada de "filas examinadas contra devueltas": 484.854 miradas para mandar 2.

**Por tabla.** `pg_stat_user_tables` cuenta cómo se lee cada tabla y cuántas filas muertas tiene:

```text
  relname   | seq_scan | idx_scan | n_live_tup | n_dead_tup | hubo_autovacuum
 Pacientes  |       75 |    17902 |     242427 |          0 | t
 Protocolos |      539 |    28490 |    1327622 |       5898 | t
```

`seq_scan` contra `idx_scan` dice si la tabla se recorre o se busca; `n_dead_tup` es una estimación de
lo que `pgstattuple` cuenta exacto, y es lo que mira el autovacuum para decidir si le toca.

> ⚠️ **Reiniciar estas vistas borra la historia de todos.** `pg_stat_statements_reset()` y el `TRUNCATE`
> del *digest* son de toda la instancia. En el laboratorio no importa; en un servidor compartido, sí.

---

## 🪟 SQL Server, en el track

Verificado el 18/10/2026, con la caja M en la base `ALAMEDA` ([ss01](ss01-la-base-en-su-motor-original.md)).
Los dos comandos aceptan `--engine sqlserver` con el extra del track:

```bash
uv run --extra sqlserver lab measure --engine sqlserver -c "SELECT count(*) FROM dbo.Pacientes WHERE Nombre LIKE '%DNI%'"
uv run --extra sqlserver lab race -f ss02-pesimista-contra-rcsi/lost_update.race --isolation snapshot
```

```text
📐 lab measure · sqlserver · perfil m · caja 258082ddb7fa · mcr.microsoft.com/mssql/server:2025-CU9-ubuntu-24.04@sha256:2b5b58162112…
🔒 solo la estructura del plan: de SQL Server el curso no publica números (apéndice a09)
  Compute Scalar
    Stream Aggregate (Aggregate)
      Clustered Index Scan on Pacientes.PK_Pacientes
```

`lab measure` pide el plan estimado (`SHOWPLAN_XML`), sin ejecutar la consulta, y lo dibuja como árbol:
cada línea es un operador físico, con el lógico entre paréntesis cuando difiere, y el índice que usa. Se
lee como el de Oracle, de adentro hacia afuera: aquí, el recorrido del índice *clustered* (que es la
tabla, [ss04](ss04-clustered-newsequentialid-y-temporales.md)), el conteo y el cálculo del resultado. Con
`--private` ejecuta con `STATISTICS XML` y agrega lecturas y filas reales, solo en tu terminal.

`lab race` funciona igual que con los otros dos motores, con dos agregados en el `.race`:

- **`@database`** elige la base (`-- @database ss02`), porque en SQL Server cada base es una conexión.
- **`--isolation snapshot`** se escribe `SNAPSHOT` en `{isolation}`, y necesita la base con
  `ALLOW_SNAPSHOT_ISOLATION ON` (`02_snapshot.sql` de ss02).

```text
🏁 lab race · sqlserver · permutación a1 a2 b1 b2 a3 b3 a4 b4 · snapshot
 a2  1 fila  (28.00)
 b2  1 fila  (28.00)
 a3  UPDATE 1
 b3  ⏳ espera un bloqueo
 a4  COMMIT
   ↳ b3  ✗ 3960 Snapshot isolation transaction aborted due to update conflict. …
resultado: a sin errores · b con error 3960 en b3
comprobación: 1 fila  (18.00)
```

La espera la detecta con `sys.dm_exec_requests.blocking_session_id`, y el error es el número nativo de
SQL Server (3960, 1205), no el SQLSTATE. Es un comportamiento, no una medida de rendimiento: se publica.

> ⚠️ **Con SQL Server, `--patience 10` en los escenarios que terminan en *deadlock*.** Postgres detecta un
> ciclo al segundo; SQL Server lo busca cada pocos segundos, y con la emulación tardó más que los 3 s de
> fábrica: el arnés declaró el orden imposible y cortó las dos sesiones (E-102 en
> [`a08`](a08-catalogo-de-errores.md)). Y aunque el orden de los pasos es fijo, **la víctima no**: en dos
> corridas seguidas, SQL Server eligió una vez `a` y otra `b`.

---

## 🧭 Cuándo usar qué

| Quieres saber | Postgres | MySQL | Oracle y SQL Server |
|---|---|---|---|
| cuánto trabajo hizo una consulta | `lab measure`: bloques y filas examinadas | `lab measure`: `Handler_read` | `lab measure`: la estructura; con `--private`, lo demás en tu terminal |
| si el planificador se equivocó | `estimadas` contra `reales` en cada nodo | `rows=` de `cost` contra el de `actual` | `--private` |
| el plan sin ejecutar | `EXPLAIN` sin `ANALYZE` | `EXPLAIN FORMAT=TREE` | `lab measure` |
| cuánto ocupa una tabla | `pg_relation_size`, `pg_total_relation_size` | `information_schema.TABLES` (estimado) | — |
| cuánto de eso es basura | `pgstattuple` | `data_free` | — |
| cuánto escribe una sentencia | `EXPLAIN (ANALYZE, WAL)` | — | — |
| qué consulta pesa más, acumulado | `pg_stat_statements` | `events_statements_summary_by_digest` | Query Store en SQL Server ([ss03](ss03-query-store-y-parameter-sniffing.md)) |
| cómo se lee una tabla | `pg_stat_user_tables` | — | — |
| qué índices no se usan | `pg_stat_user_indexes` | `sys.schema_unused_indexes` | — |
| qué pasa con dos sesiones en un orden | `lab race` | `lab race` | `lab race --engine sqlserver` |
| cuánto pasa con muchas sesiones a la vez | hilos de verdad, no `lab race` | ídem | ídem |

---

## ⚠️ Advertencias

- **Las unidades no se cruzan.** Bloques de 8 KB en Postgres, filas examinadas en MySQL, páginas de
  16 KB en InnoDB. Una comparación entre motores se hace en la misma unidad o se dice por qué no.
- **Las estimaciones de MySQL son estimaciones.** `table_rows` y `n_rows` cambian con cada `ANALYZE
  TABLE`.
- **El WAL de una corrida suelta miente** si cayó una página entera. Se mide en régimen.
- **Ningún número de Oracle o de SQL Server sale de `--private`** hacia un documento publicado
  ([`a09`](a09-licencias-publicacion-y-riesgo.md)).

---

## 📚 Referencias

> ⚠️ Las URL y sus contenidos cambian. Todas se consultaron el 18/10/2026.

- **`EXPLAIN` en Postgres** — https://www.postgresql.org/docs/current/sql-explain.html — `BUFFERS` y `WAL`.
- **`pgstattuple`** — https://www.postgresql.org/docs/current/pgstattuple.html
- **`pg_stat_statements`** — https://www.postgresql.org/docs/current/pgstatstatements.html
- **Las vistas de estadísticas** — https://www.postgresql.org/docs/current/monitoring-stats.html —
  `pg_stat_user_tables`.
- **`EXPLAIN` en MySQL** — https://dev.mysql.com/doc/refman/9.7/en/explain.html — `FORMAT=TREE` y `ANALYZE`.
- **El *digest* de `performance_schema`** — https://dev.mysql.com/doc/refman/9.7/en/performance-schema-statement-summary-tables.html
- **El *isolation tester* de Postgres** — https://github.com/postgres/postgres/tree/master/src/test/isolation
  — la idea detrás de `lab race`.

**Orden sugerido:** `lab measure` la primera vez que una fase mide; los tamaños y el WAL en el Bloque II;
las estadísticas acumuladas en la Fase 14; `lab race` antes de la Fase 15.

---

## 🧪 Ejercicios (8)

Todos desde `src/`, con el perfil M cargado (en MySQL, `--tables Pacientes,Protocolos,ResultadoItem,Practicas`
y las tablas de `15-aislamiento-comparado/01_setup_mysql.sql`). Cada uno mide lo mismo en Postgres y en
MySQL, y pide explicar la diferencia.

## 🟢 Fácil — leer la salida (1–2)

### 🟢 Ejercicio 1 — Buscar lo que no está

Mide con `lab measure`, en Postgres y en MySQL, cuántos pacientes tienen `PASAP` en el nombre. Predice
antes cuántas filas examina cada motor para contestar.

**Objetivo:** las dos salidas, cuántos bloques y cuántas filas examinadas, y por qué el resultado (cero)
no cambia el trabajo.

[Solución](soluciones/a04-el-arnes-de-forma.md#ejercicio-1)

### 🟢 Ejercicio 2 — El nodo que se equivocó

En la salida de Postgres de la primera sección (el `LIKE '%DNI%'`), encuentra el nodo con la estimación
más lejos de lo real.

**Pregunta:** ¿cuánto se equivocó, en qué sentido, y por qué en esta consulta no cambia el plan?

[Solución](soluciones/a04-el-arnes-de-forma.md#ejercicio-2)

## 🟡 Intermedio — la misma tabla, dos motores (3–5)

### 🟡 Ejercicio 3 — Cuánto ocupa `Pacientes`

Mide el tamaño de `legacy.Pacientes` en los dos motores.

**Objetivo:** el tamaño de cada uno en bytes y en sus páginas, cuántas filas cree tener MySQL contra
cuántas tiene, y una frase sobre por qué `index_length` da cero.

[Solución](soluciones/a04-el-arnes-de-forma.md#ejercicio-3)

### 🟡 Ejercicio 4 — Dos consultas que son una

Reinicia las estadísticas por consulta en los dos motores, corre el `LIKE '%DNI%'` y el `LIKE '%PASAP%'`,
y lee qué acumuló cada uno.

**Objetivo:** cuántas filas aparecen en cada vista, con qué texto, y qué número de una se corresponde
con qué número de la otra.

[Solución](soluciones/a04-el-arnes-de-forma.md#ejercicio-4)

### 🟡 Ejercicio 5 — Cien filas al WAL

Sobre una copia de los primeros 1.000 pacientes en `lab`, corre tres veces seguidas `EXPLAIN (ANALYZE,
WAL)` de un `UPDATE` que no cambia nada en 100 filas. Borra la copia al terminar.

**Pregunta:** ¿cuántos registros y bytes por corrida, cuál tuvo `fpi`, y qué número darías como "bytes
de WAL por fila"?

[Solución](soluciones/a04-el-arnes-de-forma.md#ejercicio-5)

## 🟠 Difícil — lo que deja una escritura (6–7)

### 🟠 Ejercicio 6 — La misma carrera

Corre `15-aislamiento-comparado/lost_update.race` y `lost_update_mysql.race` en `REPEATABLE READ`.

**Objetivo:** las dos salidas de `lab race`, qué saldo quedó en cada motor, y qué línea de cada salida
lo explica.

[Solución](soluciones/a04-el-arnes-de-forma.md#ejercicio-6)

### 🟠 Ejercicio 7 — La mitad de las filas, dos veces

Copia `legacy."Pacientes"` a `lab` con el autovacuum apagado, actualiza la mitad de las filas sin
cambiar nada, y mide con `pgstattuple` y `pg_relation_size` antes y después de un `VACUUM`. Borra la
copia al terminar.

**Pregunta:** ¿cuántos bloques antes, después del `UPDATE` y después del `VACUUM`? ¿Por qué el `VACUUM` no
achica la tabla, y qué hace con el espacio?

[Solución](soluciones/a04-el-arnes-de-forma.md#ejercicio-7)

## 🔴 Muy difícil — la afirmación (8)

### 🔴 Ejercicio 8 — «MySQL lee menos»

Un colega mira las salidas del ejercicio 1 y escribe: *"para el mismo `LIKE`, Postgres lee 4.160 y MySQL
242.489: MySQL lee sesenta veces más"*.

**Objetivo:** explica qué está mal en la frase, rehaz la comparación en una unidad común con los números
de los ejercicios 1 y 3, y escribe la medición que la sostendría con los cinco datos de una medición
publicada.

[Solución](soluciones/a04-el-arnes-de-forma.md#ejercicio-8)

---

> 🏷️ **Este apéndice no lleva tag propio.** Crece con los commits de las fases que le agregan
> recetas.
