# 📎 Apéndice a03 — CLIs de los once motores

> **Curso:** Ruta NoSQL Lite · Consulta rápida · **3 h**
> **Usado por:** todas las fases A · **Versiones cubiertas:** las del `compose.yaml` de
> [`a02`](a02-compose-de-la-ruta.md)
> **Fecha de verificación ejecutada:** la de cada sección, del 29/09/2026 al 11/10/2026. **Estado:** cerrado el
> 12/10/2026, con los once motores del laboratorio

**Esto no se lee de corrido.** Se entra por el motor y se sale. Cada sección tiene la misma forma:
conectar desde el contenedor y desde tu máquina · listar lo que haya · insertar un registro del
dominio de Cóndor · consultarlo · contar · borrar · salir. Y las dos cosas que aquí se consultan
más que la sintaxis: **cómo se pide el plan de ejecución** y **cómo se sale sin dejar el proceso
colgado**.

**Qué queda fuera:** administración, usuarios y permisos, backup y tuning, y cualquier comparación
entre productos de la misma familia, que es materia de los cursos profundos de la ruta NoSQL de este repositorio.

---

## Índice

| Motor | CLI | Se escribe con |
|---|---|---|
| PostgreSQL (`base`) | [`psql`](#-postgresql--psql) | ✅ Fase 01 |
| MongoDB (`documental`) | [`mongosh`](#-mongodb--mongosh) | ✅ Fase 03 |
| Valkey (`clave-valor`) | [`valkey-cli`](#-valkey--valkey-cli) | ✅ Fase 05 |
| DuckDB (analítico, embebido) | [Python](#-duckdb--desde-python) | ✅ Fase 07 |
| TimescaleDB (`series`) | [`psql`](#️-timescaledb--psql) | ✅ Fase 09 |
| OpenSearch (`busqueda`) | [`curl`](#-opensearch--curl) | ✅ Fase 11 |
| Neo4j (`grafos`) | [`cypher-shell`](#️-neo4j--cypher-shell) | ✅ Fase 13 |
| Qdrant (`vectorial`) | [API HTTP](#-qdrant--api-http) | ✅ Fase 15 |
| Cassandra (`columnar`) | [`cqlsh`](#️-cassandra--cqlsh) | ✅ Fase 17 |
| CouchDB (`offline`) | [HTTP y Fauxton](#-couchdb--http-y-fauxton) | ✅ Fase 19 |
| CockroachDB (`newsql`) | [`cockroach sql`](#-cockroachdb--cockroach-sql) | ✅ Fase 21 |

Cada sección se escribe **ejecutando** sus comandos contra el laboratorio, con la salida real, en
la fase que abre su familia.

- [Cuándo usar qué: el plan y la salida, lado a lado](#-cuándo-usar-qué) · [Ejercicios](#-ejercicios-10)

---

## 🐘 PostgreSQL · `psql`

Verificado el 29/09/2026 con PostgreSQL 18.6 (`base`) y `psql` 18.0 en tu máquina.

**Conectar**, desde el contenedor o desde tu máquina (con `psql` instalado):

```bash
cd src/lab
docker compose exec base psql -U postgres
PGPASSWORD=condor psql -h localhost -p 15432 -U postgres
```

**Listar** las tablas con `\dt`, y una tabla con `\d work_order`:

```text
                  List of tables
 Schema |         Name          | Type  |  Owner
--------+-----------------------+-------+----------
 public | aircraft              | table | postgres
 public | assembly              | table | postgres
 public | hangar                | table | postgres
 public | part                  | table | postgres
 public | part_catalog          | table | postgres
```

**Insertar, consultar, contar y borrar**, con una base del dominio:

```sql
INSERT INTO hangar VALUES ('MVP', 'Estación Mitú', 'Mitú', 'CO', 1);
SELECT hangar_id, name, pits FROM hangar ORDER BY hangar_id;
SELECT count(*) FROM work_order WHERE aircraft = 'HK-12372';   -- 1097 con workOrder-1m
DELETE FROM hangar WHERE hangar_id = 'MVP';
```

**Pedir el plan:** `EXPLAIN (ANALYZE, BUFFERS)` delante de la consulta. Cómo se lee, campo por
campo, está en la [Fase 01](01-el-dominio-de-flota-y-el-arnes.md) §4.4; qué números extrae el curso,
en [`a04`](a04-el-arnes-de-medida.md).

```text
 Aggregate  (cost=1215.08..1215.09 rows=1 width=8) (actual time=0.366..0.366 rows=1.00 loops=1)
   Buffers: shared hit=233
   ->  Index Only Scan using work_order_aircraft_opened_at on work_order  (cost=0.42..1212.75 rows=933 width=0) (actual time=0.023..0.314 rows=1097.00 loops=1)
         Index Cond: (aircraft = 'HK-12372'::text)
         Heap Fetches: 228
         Index Searches: 1
```

**Salir:** `\q`. Desde un script, `client.end()` ([`a06`](a06-lenguajes-y-drivers.md)).

---

## 🍃 MongoDB · `mongosh`

Verificado el 29/09/2026 con MongoDB 8.0.20 (`documental`).

**Conectar:** desde el contenedor, o desde tu máquina con la URL de [`a06`](a06-lenguajes-y-drivers.md)
(con `directConnection=true`):

```bash
cd src/lab
docker compose exec documental mongosh condor_ref
```

**Listar, insertar, consultar, contar y borrar**, con una base del dominio:

```javascript
db.getCollectionNames()
// [ 'aircraft', 'assembly', 'hangar', 'part', 'partCatalog', 'pirep', 'supplier', 'technician', 'workOrder' ]
db.hangar.insertOne({ _id: "MVP", hangarId: "MVP", name: "Estación Mitú", city: "Mitú", country: "CO", pits: 1 })
db.hangar.find({}, { name: 1 }).sort({ _id: 1 })
db.workOrder.countDocuments({ aircraft: "HC-10265" })   // 371 con part-1m
db.hangar.deleteOne({ _id: "MVP" })
```

**Pedir el plan:** `.explain("executionStats")` al final de un `find` o de un `aggregate`. Qué campos
mirar está en la [Fase 03](03-documental-levantar-y-modelar.md) §6.5 y en [`a04`](a04-el-arnes-de-medida.md).

**Salir:** `exit` o `Ctrl+D`. Desde un script, `client.close()`.

---

## 🔑 Valkey · `valkey-cli`

Verificado el 29/09/2026 con Valkey 9.1.2 (`clave-valor`) y `valkey-cli` 9.1.2, el de la imagen.

**Conectar:** desde el contenedor. En tu máquina no hace falta instalar nada; si ya tienes
`valkey-cli` o `redis-cli`, `-p 16379` apunta al laboratorio (no se verificó desde el anfitrión,
que no tenía ninguno de los dos).

```bash
cd src/lab
docker compose exec clave-valor valkey-cli
```

**Insertar, consultar, contar y borrar**, con una base del dominio:

```text
> HSET hangar:MVP name "Estación Mitú" city Mitú country CO pits 1
4
> HGETALL hangar:MVP
name
Estación Mitú
city
Mitú
country
CO
pits
1
> DBSIZE
100917
> DEL hangar:MVP
1
```

**Listar lo que hay** no es una consulta: es recorrer claves con `SCAN`. Y tiene una trampa: `MATCH`
filtra **después** de recorrer cada página, así que una página puede volver vacía sin que el recorrido
haya terminado. Solo termina cuando el cursor vuelve a `0`:

```text
> SCAN 0 MATCH hangar:* COUNT 1000
5440

```

La primera línea es el cursor siguiente, 5440; la lista de claves de esa página, vacía.

`KEYS patrón` devuelve todo de una vez, pero bloquea la instancia mientras recorre: fuera del
laboratorio, no se usa.

**Pedir el plan:** no hay. Lo que se pide en su lugar es **qué ocupa** —`MEMORY USAGE <clave>`,
`OBJECT ENCODING <clave>`, `TYPE <clave>`— y **qué se ejecutó**, con `INFO commandstats` (tras
`CONFIG RESETSTAT` para empezar de cero):

```text
> INFO commandstats
# Commandstats
cmdstat_config|resetstat:calls=1,usec=143,usec_per_call=143.00,rejected_calls=0,failed_calls=0
cmdstat_hgetall:calls=1,usec=6,usec_per_call=6.00,rejected_calls=0,failed_calls=0
```

El costo de un comando lo dice su complejidad en la documentación (O(1), O(log N), O(N)); cómo usa el
curso todo esto, en la [Fase 05](05-clave-valor-levantar-y-modelar.md) y en
[`a04`](a04-el-arnes-de-medida.md).

**Salir:** `exit` o `Ctrl+D`. Desde un script, `await client.quit()` ([`a06`](a06-lenguajes-y-drivers.md)).

---

## 🦆 DuckDB · desde Python

Verificado el 07/10/2026 con DuckDB 1.5.6, con la base de la [Fase 07](07-analitico-levantar-y-modelar.md)
construida en `src/lab/data/analitico/condor.duckdb`.

**Conectar:** no hay servidor ni contenedor; DuckDB vive dentro del proceso que lo abre. El curso no
instala el binario `duckdb`: se usa el paquete de Python del `uv.lock` ([`a06`](a06-lenguajes-y-drivers.md)),
desde `src/`. `read_only=True` deja que varios procesos lean a la vez; sin él, el primero que abre el
archivo se queda con el candado (E-08 en [`a09`](a09-catalogo-de-errores.md)).

**Listar y consultar:**

```text
$ uv run python -c "import duckdb; print(duckdb.connect('lab/data/analitico/condor.duckdb', read_only=True).sql('SHOW TABLES'))"
aircraft · reading · reading_x10 · work_order        (resumida)

$ uv run python -c "import duckdb; c = duckdb.connect('lab/data/analitico/condor.duckdb', read_only=True); print(c.sql('SELECT count(*) FROM reading'))"
5000000                                              (resumida)
```

**Insertar** en una base abierta en solo lectura falla, y lo dice:

```text
_duckdb.InvalidInputException: Invalid Input Error: Cannot execute statement of type "INSERT" on database "condor" which is attached in read-only mode!
```

Para probar escrituras, una base en memoria (`duckdb.connect()` sin archivo) o un archivo aparte:

```bash
uv run python -c "import duckdb; c = duckdb.connect(); c.sql('CREATE TABLE landing (registration VARCHAR, flight_minutes INTEGER)'); c.sql(\"INSERT INTO landing VALUES ('HK-4207', 84)\"); print(c.sql('SELECT * FROM landing')); c.sql(\"DELETE FROM landing WHERE registration = 'HK-4207'\"); print(c.sql('SELECT count(*) FROM landing'))"
```

Devuelve la fila `HK-4207 | 84` y, después del borrado, `0`.

**Consultar un archivo sin cargarlo:** `SELECT … FROM 'lab/data/analitico/reading.parquet'`, o
`read_json(…)` y `read_csv(…)` con un NDJSON o un CSV.

**Pedir el plan:** `EXPLAIN` da el árbol de operadores; para `avg(egt_c)` de una aeronave, un
`SEQ_SCAN` sobre `reading` con `Projections: egt_c` y `Filters: aircraft='HK-4207'`: las columnas que
lee y el filtro que usa para saltar grupos de filas. `EXPLAIN ANALYZE` lo ejecuta, y
`EXPLAIN (ANALYZE, FORMAT json)` da el perfil con `total_bytes_read`, que es lo que mide el curso
([`a04`](a04-el-arnes-de-medida.md)).

**Salir:** cerrar la conexión (`con.close()`, o un bloque `with duckdb.connect(…) as con:`). Es lo que
suelta el candado del archivo.

---

## 🕸️ Neo4j · `cypher-shell`

Verificado el 07/10/2026 con Neo4j 2026.09.0 Community (`grafos`), con el grafo de la
[Fase 13](13-grafos-levantar-y-modelar.md) cargado.

**Conectar:** desde el contenedor, `docker compose exec grafos cypher-shell -u neo4j -p condor-mro`; desde tu
máquina, Bolt en el 17687 y la consola web en `http://localhost:17474`. Las sentencias terminan en `;`.

**Listar** bases y labels:

```text
$ echo "SHOW DATABASES YIELD name, currentStatus;" | docker compose exec -T grafos cypher-shell -u neo4j -p condor-mro
"neo4j", "online"
"system", "online"
$ echo "CALL db.labels() YIELD label RETURN collect(label) AS labels;" | …
["Aircraft", "Part", "WorkOrder", "Assembly", "Supplier"]
```

Community tiene una sola base de usuario, `neo4j`: no hay `CREATE DATABASE`.

**Insertar, contar y borrar:**

```text
$ echo "CREATE (:Part {serialNumber: 'SN-PRUEBA', lotNumber: 'LOT-PRUEBA'}); MATCH (p:Part {lotNumber: 'LOT-PRUEBA'}) RETURN count(p) AS n; MATCH (p:Part {serialNumber: 'SN-PRUEBA'}) DELETE p;" | …
n
1
```

Un nodo con relaciones no se borra con `DELETE`: hace falta `DETACH DELETE`, y muchos de una vez agotan la
memoria de transacciones (E-53 en [`a09`](a09-catalogo-de-errores.md)).

**Pedir el plan:** `EXPLAIN` no ejecuta; `PROFILE` ejecuta y da, por operador, filas, *db hits* y aciertos de
caché. Con `--format verbose` sale en tabla; al final, `Total database accesses: 56`.

**Salir:** `:exit`.

---

## ⏱️ TimescaleDB · `psql`

Verificado el 07/10/2026 con TimescaleDB 2.30.1 sobre PostgreSQL 18.6 (`series`), con la base `condor`
de la [Fase 09](09-series-levantar-y-modelar.md).

**Conectar:** es Postgres, así que la CLI es `psql`, como en la sección de PostgreSQL. Desde el
contenedor, `docker compose exec series psql -U postgres -d condor`; desde tu máquina, el puerto 15433.

**Listar** las hypertables y sus chunks, que son lo que `\dt` no cuenta bien:

```text
$ psql … -c "SELECT hypertable_name, num_chunks, compression_enabled FROM timescaledb_information.hypertables"
 reading_x10     |        219 | t
 reading_month   |         64 | f
 reading         |        271 | f

$ psql … -c "SELECT chunk_name, range_start, range_end, is_compressed FROM timescaledb_information.chunks WHERE hypertable_name = 'reading' ORDER BY range_start LIMIT 2"
 _hyper_1_1_chunk | 2021-09-30 00:00:00+00 | 2021-10-07 00:00:00+00 | f
 _hyper_1_2_chunk | 2021-10-07 00:00:00+00 | 2021-10-14 00:00:00+00 | f
```

(Salidas recortadas a las filas.) **Insertar, contar y borrar** son SQL normal; la fila va sola al chunk
de su semana:

```text
$ psql … -c "INSERT INTO reading VALUES ('HK-4207', 'FL-PRUEBA', '2026-09-29 10:00', 16000, 220, 700, 88, 100, 80, 420)" \
         -c "SELECT count(*) FROM reading WHERE aircraft = 'HK-4207' AND ts >= '2026-09-29'" -c "DELETE FROM reading WHERE flight_id = 'FL-PRUEBA'"
INSERT 0 1
 274
DELETE 1
```

**Pedir el plan:** `EXPLAIN (ANALYZE, BUFFERS)`, como en Postgres. Lo propio de esta familia es **contar
los chunks** del plan: dos semanas de marzo de 2025 tocan tres (`_hyper_1_179_chunk` a
`_hyper_1_181_chunk`), cada uno con su recorrido; los demás no aparecen.

**Salir:** `\q`, como en `psql`.

---

## 🔍 OpenSearch · `curl`

Verificado el 07/10/2026 con OpenSearch 3.8.0 (`busqueda`), con el catálogo de la
[Fase 11](11-busqueda-levantar-y-modelar.md) cargado.

**Conectar:** no hay CLI; se habla con la API REST en el puerto 19200, sin usuario (la seguridad está
desactivada en el laboratorio, [`a02`](a02-compose-de-la-ruta.md)). Desde un script, el cliente de
[`a06`](a06-lenguajes-y-drivers.md).

**Listar** índices con `_cat`, que es la vista en columnas para personas:

```text
$ curl -s 'localhost:19200/_cat/indices/part_catalog?v&h=index,docs.count,store.size'
index        docs.count store.size
part_catalog    1000000    166.5mb
```

El tamaño depende de cuántos segmentos se han fusionado: un índice recién cargado, como este, ronda los 166–170
MB; la [Fase 11, §6.6](11-busqueda-levantar-y-modelar.md) da 170,2 MB después de corregir 500 precios y borrar
1000 documentos.

**Insertar, contar y borrar.** `?refresh=true` hace que el cambio se vea en la siguiente búsqueda; sin él,
aparece en el próximo refresco, hasta un segundo después:

```text
$ curl -s -X PUT 'localhost:19200/part_catalog/_doc/99-000001-01?refresh=true' -H 'content-type: application/json' \
    -d '{"partNumber":"99-000001-01","description":"junta tórica de prueba","category":"consumable","ataChapter":20}'
{"_index":"part_catalog","_id":"99-000001-01","_version":1,"result":"created","forced_refresh":true,…}
$ curl -s 'localhost:19200/part_catalog/_count' -H 'content-type: application/json' -d '{"query":{"match":{"description":"prueba"}}}'
{"count":1,…}
$ curl -s -X DELETE 'localhost:19200/part_catalog/_doc/99-000001-01?refresh=true'
{"_index":"part_catalog","_id":"99-000001-01","_version":2,"result":"deleted",…}
```

**Pedir el plan:** no hay `EXPLAIN`, pero hay tres cosas que hacen su papel. `_validate/query?explain=true`
da la consulta reescrita en términos; `_analyze`, los términos que produce un texto; y `"profile": true` en
la búsqueda, el árbol de consultas de Lucene con sus tiempos. Para *"juntas toricas tren"*, el perfil dice
`ConstantScore(#description:junt #description:toric #description:tren)`: tres términos obligatorios.

**Salir:** no hay sesión: HTTP sin estado.

---

## 🧬 Qdrant · API HTTP

Verificado el 30/09/2026 con Qdrant 1.19.1 (`vectorial`), con `pirep-10k` cargado por la
[Fase 15](15-vectorial-levantar-y-modelar.md).

**Conectar:** no hay CLI; se habla con la API HTTP, desde tu máquina, en el puerto 16333. `curl` basta, y
en `http://localhost:16333/dashboard` hay una interfaz web para mirar colecciones. Desde un script, los
clientes de [`a06`](a06-lenguajes-y-drivers.md).

**Listar** las colecciones y mirar una:

```text
$ curl -s localhost:16333/collections
{"result":{"collections":[{"name":"pirep"}]},"status":"ok","time":0.000025042}
$ curl -s localhost:16333/collections/pirep        (recortada)
{"status": "green", "points_count": 10000, "indexed_vectors_count": 0, "segments_count": 4}
```

`indexed_vectors_count: 0` no es un error: con 10 000 puntos, Qdrant no construye el HNSW (Fase 15,
§6.5). Es lo primero que conviene mirar.

**Consultar un punto, contar y recorrer con filtro:**

```text
$ curl -s localhost:16333/collections/pirep/points/0        (payload)
{"pirepId": "PR-0000001", "aircraft": "HK-4447", "ataChapter": 22, "reportedAt": "2021-10-01T07:52:15Z", "text": "piloto automatico se desconecta solo en carreteo tramo IQT-LQM, verificar antes del proximo vuelo"}

$ curl -s -X POST localhost:16333/collections/pirep/points/count -H 'content-type: application/json' \
    -d '{"filter":{"must":[{"key":"ataChapter","match":{"value":32}}]},"exact":true}'
{"result":{"count":3815},"status":"ok","time":0.000857417}

$ curl -s -X POST localhost:16333/collections/pirep/points/scroll -H 'content-type: application/json' \
    -d '{"filter":{"must":[{"key":"aircraft","match":{"value":"HC-1499"}}]},"limit":2,"with_payload":["pirepId","text"]}'
```

`scroll` es la lectura exacta, sin vector: lo que la situación 3 de la Fase 15 debió usar.

**Buscar por parecido** sin calcular un vector: con el id de un punto en lugar del vector, Qdrant busca
los parecidos a ese punto.

```text
$ curl -s -X POST localhost:16333/collections/pirep/points/query -H 'content-type: application/json' \
    -d '{"query":0,"limit":3,"with_payload":["text"]}'
0.972 piloto automatico se desconecta solo en descenso, verificar antes del proximo vuelo
0.971 piloto automatico se desconecta solo en ascenso inicial tramo IQT-VVC, segundo vuelo con lo mismo
0.97  tripluacion informa piloto automatico se desconecta solo en rodaje tramo VVC-LQM, segundo vuelo con lo mismo
```

(Salida resumida a parecido y texto.) **Insertar** un punto pide un vector de 384 números, así que se
hace desde la ingesta de la Fase 15, no a mano. **Borrar** un id que no existe no da error:

```text
$ curl -s -X POST localhost:16333/collections/pirep/points/delete -H 'content-type: application/json' -d '{"points":[999999]}'
{"result":{"operation_id":15,"status":"acknowledged"},"status":"ok","time":0.000583667}
```

**Pedir el plan:** no hay. Lo que se pide en su lugar es la búsqueda exacta —`"params": {"exact": true}`
en la consulta— para medir el índice contra ella, e `indexed_vectors_count` para saber si el índice
existe ([`a04`](a04-el-arnes-de-medida.md)).

**Salir:** no hay sesión que cerrar: HTTP sin estado.

---

## 🏛️ Cassandra · `cqlsh`

Verificado el 10/10/2026 con Cassandra 5.0.9 (`columnar`) y `cqlsh` 6.2.0, con las tablas de la
[Fase 17](17-columnar-levantar-y-modelar.md) cargadas.

**Conectar:** desde el contenedor, `docker compose exec columnar cqlsh`; desde tu máquina, el driver en el
19042 ([`a06`](a06-lenguajes-y-drivers.md)). Las sentencias terminan en `;`. Antes de que el nodo acepte
conexiones pasa alrededor de un minuto: un `Connection refused` en ese rato es normal.

**Listar** keyspaces y tablas:

```text
$ docker compose exec -T columnar cqlsh -e "DESCRIBE KEYSPACES; USE condor; DESCRIBE TABLES;"
condor  system_auth         system_schema  system_views
system  system_distributed  system_traces  system_virtual_schema

egt_exceedance_by_day      reading_by_flight
reading_by_aircraft_month  reading_x10_by_aircraft_month
```

`DESCRIBE TABLE condor.reading_by_flight` devuelve el `CREATE TABLE` completo, con la partition key entre
los dobles paréntesis de `PRIMARY KEY`.

**Insertar, contar y borrar:**

```text
$ docker compose exec -T columnar cqlsh -e "INSERT INTO condor.reading_by_flight (flight_id, ts, egt_c) VALUES ('FL-PRUEBA', '2026-10-10 12:00:00', 700); SELECT count(*) FROM condor.reading_by_flight WHERE flight_id = 'FL-PRUEBA'; DELETE FROM condor.reading_by_flight WHERE flight_id = 'FL-PRUEBA';"
 count
-------
     1
```

Un `INSERT` sobre una clave que existe la reemplaza sin error, y un `DELETE` no borra: escribe una marca de
borrado, un *tombstone*, que la [Fase 18](18-columnar-romper-y-medir.md) mide. Un `count(*)` sin partition key recorre la tabla entera.

**Pedir el plan:** no hay plan, hay traza. `TRACING ON` y la consulta; cada partición aparece como
`Executing single-partition query`, y los filtros de Bloom dicen qué SSTables se saltaron:

```text
$ docker compose exec -T columnar cqlsh -e "TRACING ON; PAGING OFF; SELECT count(*) FROM condor.reading_by_aircraft_month WHERE aircraft = 'HC-2157' AND month IN ('2025-09', '2025-10', '2025-11') AND ts >= '2025-09-15' AND ts < '2025-11-14';"
  9666
Warnings :
Aggregation query used on multiple partition keys (IN restriction)
…
Executing single-partition query on reading_by_aircraft_month
Skipped 0/4 non-slice-intersecting sstables, included 0 due to tombstones
Bloom filter allows skipping sstable 190
Bloom filter allows skipping sstable 283
Bloom filter allows skipping sstable 292
Merged data from memtables and 1 sstables
Read 2560 live rows and 0 tombstone cells
…
```

(Traza recortada a la primera de tres particiones.) El nivel de consistencia de la sesión se cambia con
`CONSISTENCY QUORUM;`, y `PAGING OFF` evita que `cqlsh` pida confirmación cada 100 filas.

**Salir:** `exit;`.

---

## 📴 CouchDB · HTTP y Fauxton

Verificado el 11/10/2026 con CouchDB 3.5.2 (`offline`) y `curl` en tu máquina, con las bases de la
[Fase 19](19-offline-levantar-y-modelar.md) cargadas.

**Conectar:** CouchDB no tiene un shell: **su CLI es HTTP**. Cualquier `curl` con usuario y clave en el 15984
basta, y la interfaz web, Fauxton, está en `http://localhost:15984/_utils`. Todas las respuestas son JSON.

**Listar** bases y documentos:

```text
$ curl -s -u condor:condor localhost:15984/_all_dbs
["_replicator","_users","f19_trip","work_order","work_order_vvc"]
```

`GET /work_order` devuelve `doc_count` y `sizes` (`active` es lo vivo, `file` lo que ocupa el archivo), y
`GET /work_order/_all_docs?limit=5` los primeros ids. Un documento, con la historia de sus revisiones:

```text
$ curl -s -u condor:condor 'localhost:15984/work_order/WO-0009941?revs_info=true'
{"_id":"WO-0009941","_rev":"7-4735404195ebaef589103a8dd00cd3b1",…,"_revs_info":[{"rev":"7-4735404195ebaef589103a8dd00cd3b1","status":"available"},{"rev":"6-ace1bf317331378024e081dda0511f70","status":"available"},{"rev":"5-f4847f155025d6fb5698f2d5dbc3006d","status":"missing"},…]}
```

**Insertar, cambiar y borrar.** `PUT /<base>/<id>` con el cuerpo crea; para cambiar o borrar hay que mandar el
`_rev` que se leyó, y si no es la hoja actual la respuesta es un 409 (E-64 en
[`a09`](a09-catalogo-de-errores.md)). Borrar (`DELETE /<base>/<id>?rev=…`) también es una revisión nueva: contesta con
`"rev":"2-…"`, y un `GET` después, con `{"error":"not_found","reason":"deleted"}`.

**Los conflictos, a mano.** Un conflicto solo nace al replicar, pero se puede fabricar con lo mismo que usa la
replicación: `_bulk_docs` con `new_edits: false`, que guarda revisiones con el `_rev` y la historia que se le
dan. Dos hijas de la misma revisión 1:

```text
$ curl -s -u condor:condor localhost:15984/f19_demo -X PUT
{"ok":true}
$ curl -s -u condor:condor -H 'content-type: application/json' localhost:15984/f19_demo/WO-0009951 -X PUT -d '{"aircraft":"HK-5258"}'
{"ok":true,"id":"WO-0009951","rev":"1-7666c7b2a66e2423954796ec1141cd2b"}
$ curl -s -u condor:condor -H 'content-type: application/json' localhost:15984/f19_demo/_bulk_docs -X POST -d '{"new_edits":false,"docs":[
    {"_id":"WO-0009951","_rev":"2-aaaa","_revisions":{"start":2,"ids":["aaaa","7666c7b2a66e2423954796ec1141cd2b"]},"aircraft":"HK-5258","fuelPump1":"SN-0004130","by":"T-004"},
    {"_id":"WO-0009951","_rev":"2-ffff","_revisions":{"start":2,"ids":["ffff","7666c7b2a66e2423954796ec1141cd2b"]},"aircraft":"HK-5258","fuelPump1":"SN-0000829","by":"T-009"}]}'
[]
$ curl -s -u condor:condor 'localhost:15984/f19_demo/WO-0009951?conflicts=true'
{"_id":"WO-0009951","_rev":"2-ffff","aircraft":"HK-5258","fuelPump1":"SN-0000829","by":"T-009","_conflicts":["2-aaaa"]}
```

Las dos ramas tienen el mismo largo, así que gana la de `_rev` mayor como texto: `2-ffff`. Sin `?conflicts=true`,
el mismo `GET` no dice nada de `2-aaaa`. Todas las hojas, con su cuerpo, con `?open_revs=all` y
`-H 'accept: application/json'`. **Resolver** es una sola llamada: la fusión sobre la ganadora y el borrado de
la perdedora.

```text
$ curl -s -u condor:condor -H 'content-type: application/json' localhost:15984/f19_demo/_bulk_docs -X POST -d '{"docs":[
    {"_id":"WO-0009951","_rev":"2-ffff","aircraft":"HK-5258","fuelPump1":["SN-0004130","SN-0000829"],"disputed":true},
    {"_id":"WO-0009951","_rev":"2-aaaa","_deleted":true}]}'
[{"ok":true,"id":"WO-0009951","rev":"3-c60b481870ea2aac07538e4617f9446e"},{"ok":true,"id":"WO-0009951","rev":"3-bc1e92d3266b235ab548d2734240152c"}]
```

**Pedir el plan:** no hay plan. Lo que se pide es el registro de cambios, `GET /<base>/_changes?limit=…`
(cada entrada con su `seq`, el id y la revisión), y el estado de las replicaciones persistentes:

```text
$ curl -s -u condor:condor localhost:15984/_scheduler/docs/_replicator/vvc
{"database":"_replicator","doc_id":"vvc",…,"state":"completed","error_count":0,"info":{"revisions_checked":1686,"missing_revisions_found":1686,"docs_read":1686,"docs_written":1686,…}}
```

**Salir:** no hay sesión que cerrar. `DELETE /f19_demo` borra la base de prueba.

---

## ⚡ CockroachDB · `cockroach sql`

Verificado el 11/10/2026 con CockroachDB 26.3.2 (`newsql`), con la base `condor` de la
[Fase 21](21-newsql-levantar-y-modelar.md) cargada.

**Conectar:** desde el contenedor, `docker compose exec newsql cockroach sql --insecure -d condor`. Desde tu
máquina sirve cualquier cliente de Postgres en el 26258, usuario `root` y sin contraseña: `psql -h localhost -p
26258 -U root condor` o el driver `pg` ([`a06`](a06-lenguajes-y-drivers.md)). Para `newsql-global`, las tres puertas
de [`a02`](a02-compose-de-la-ruta.md) (26259, 26260 y 26261, un nodo por región); desde dentro del contenedor, los
nueve nodos escuchan en `localhost:26257` a `26265`. Con `-e` y sin terminal, la salida sale separada por
tabuladores; `--format=table` la dibuja.

**Listar** bases y tablas, con el número estimado de filas:

```text
$ docker compose exec -T newsql cockroach sql --insecure -d condor --format=table -e "SELECT table_name, estimated_row_count FROM [SHOW TABLES] WHERE table_name LIKE 'work%' ORDER BY 1"
       table_name       | estimated_row_count
------------------------+----------------------
  work_order            |               10000
  work_order_movement   |               12696
  work_order_technician |               14848
(3 rows)
```

`SHOW DATABASES` trae, además del dueño, las columnas `primary_region`, `regions` y `survival_goal`, vacías en un
nodo; `SHOW CREATE TABLE work_order` devuelve el `CREATE TABLE` completo, con la localidad si la tiene. Los
corchetes (`[SHOW TABLES]`) convierten cualquier `SHOW` en una tabla que se puede filtrar con `SELECT`.

**Insertar, contar y borrar:** SQL de Postgres, sin sorpresas.

```text
$ docker compose exec -T newsql cockroach sql --insecure -d condor -e "INSERT INTO hangar VALUES ('PRB', 'Prueba', 'Bogotá', 'CO', 1); SELECT count(*) FROM hangar; DELETE FROM hangar WHERE hangar_id = 'PRB'"
INSERT 0 1
count
7
DELETE 1
```

La diferencia está en el aislamiento: `SHOW transaction_isolation` devuelve `serializable`, y una transacción que no
se puede ordenar con otra termina en `40001` y se reintenta (E-71 en [`a09`](a09-catalogo-de-errores.md)).

**Pedir el plan:** `EXPLAIN ANALYZE`, sin `BUFFERS` y **sin parámetros** (E-73). La salida dice cuántas filas se
leyeron del almacén distribuido y en qué nodos:

```text
$ docker compose exec -T newsql cockroach sql --insecure -d condor -e "EXPLAIN ANALYZE SELECT work_order_id, type FROM work_order WHERE aircraft = 'HC-2157' AND opened_at >= '2026-01-01'"
info
planning time: 515µs
execution time: 2ms
distribution: local
plan type: custom
rows decoded from KV: 126 (12 KiB, 2 gRPC calls)

• index join (streamer)
│ sql nodes: n1
│ kv nodes: n1
│ KV rows decoded: 63
│ actual row count: 63
│ table: work_order@work_order_pkey
│
└── • scan
      sql nodes: n1
      kv nodes: n1
      KV rows decoded: 63
      actual row count: 63
      table: work_order@work_order_aircraft_opened_at
      spans: [/'HC-2157'/'2026-01-01 00:00:00+00' - /'HC-2157']
```

(Plan recortado: sin los tiempos y la CPU de cada operador.) En un clúster con regiones, cada operador trae
además `regions:`. Lo que no trae un plan es dónde vive cada cosa, y eso lo dicen los rangos:

```text
$ docker compose exec -T newsql cockroach sql --insecure -d condor --format=table -e "SELECT range_id, lease_holder, replicas FROM [SHOW RANGES FROM TABLE work_order WITH DETAILS]"
  range_id | lease_holder | replicas
-----------+--------------+-----------
        88 |            1 | {1}
(1 row)
```

`SHOW RANGE FROM TABLE work_order FOR ROW ('WO-0009965')` dice el rango de una fila sola, y `SHOW REGIONS FROM
CLUSTER`, las regiones y sus zonas. Las tablas internas (`crdb_internal`) están cerradas (E-11).

**Salir:** `\q`.

---

## 🧭 Cuándo usar qué

Las dos cosas que se consultan más que la sintaxis, lado a lado. Cada celda resume su sección; el detalle y la
salida real están arriba, y qué número sacar de cada plan, en [`a04`](a04-el-arnes-de-medida.md).

| Motor | Pedir el plan | Lo que se mira en él | Salir |
|---|---|---|---|
| PostgreSQL | `EXPLAIN (ANALYZE, BUFFERS)` | filas examinadas contra devueltas, `Buffers` | `\q`; `client.end()` |
| MongoDB | `.explain("executionStats")` | `totalDocsExamined` contra `nReturned` | `exit`; `client.close()` |
| Valkey | no hay: `MEMORY USAGE`, `INFO commandstats` | bytes por clave y comandos ejecutados | `exit`; `client.quit()` |
| DuckDB | `EXPLAIN (ANALYZE, FORMAT json)` | `total_bytes_read`, columnas leídas | `con.close()` o `with` |
| TimescaleDB | `EXPLAIN (ANALYZE, BUFFERS)` | los *chunks* que toca | `\q` |
| OpenSearch | `"profile": true`, `_validate/query?explain=true` | los términos de la consulta reescrita | no hay sesión |
| Neo4j | `PROFILE` (`EXPLAIN` no ejecuta) | *db hits* y filas por operador | `:exit` |
| Qdrant | no hay: la búsqueda exacta (`"exact": true`) | recall contra ella, `indexed_vectors_count` | no hay sesión |
| Cassandra | `TRACING ON` | particiones y SSTables tocadas | `exit;` |
| CouchDB | no hay: `_changes` y `_scheduler/docs` | qué cambió y qué replica | no hay sesión |
| CockroachDB | `EXPLAIN ANALYZE`, sin parámetros (E-73) | filas del almacén, nodos y regiones | `\q` |

**Cuatro de once no tienen plan**, y no es un defecto: Valkey, Qdrant y CouchDB no planifican una consulta, la
ejecutan, y lo que se mide es lo que ocupa, lo que acierta o lo que viaja. **Tres no tienen sesión**: OpenSearch,
Qdrant y CouchDB hablan HTTP sin estado, y salir es no hacer nada; lo que queda colgado, si algo, es el proceso de
tu script, y [`a06`](a06-lenguajes-y-drivers.md) dice cómo cerrarlo.

---

## 🧪 Ejercicios (10)

Uno por familia, con su motor: conectar con la CLI de su sección y responder una pregunta del dominio de Cóndor. La
respuesta se compara con la de la fase que cargó ese motor; si no coincide, lo primero es revisar que el dataset sea
el del curso ([`a05`](a05-el-dominio-de-flota.md)).

### 🟢 Ejercicio 1 — MongoDB

Con `mongosh`, cuenta las órdenes de trabajo de la aeronave que usa la [Fase 03](03-documental-levantar-y-modelar.md)
y pide su `explain("executionStats")`.

**Objetivo:** el conteo, y `totalDocsExamined` igual a `nReturned`.

### 🟢 Ejercicio 2 — Valkey

Con `valkey-cli`, crea la sesión de un técnico como la de la [Fase 05](05-clave-valor-levantar-y-modelar.md), con su
vencimiento.

**Objetivo:** su `TTL`, su `MEMORY USAGE`, y que desaparezca sola al vencer.

### 🟢 Ejercicio 3 — DuckDB

Desde Python, el promedio de EGT de una aeronave sobre `condor.duckdb` de la
[Fase 07](07-analitico-levantar-y-modelar.md).

**Objetivo:** el número, y en el perfil `total_bytes_read` con una sola columna de lecturas leída.

### 🟢 Ejercicio 4 — TimescaleDB

Con `psql` contra `series`, las lecturas de dos semanas de una aeronave.

**Objetivo:** el conteo, y cuántos *chunks* toca el plan.

### 🟢 Ejercicio 5 — OpenSearch

Con `curl`, la búsqueda *"juntas toricas tren"* sobre el catálogo de la [Fase 11](11-busqueda-levantar-y-modelar.md).

**Objetivo:** los tres primeros números de parte, y los términos que muestra el perfil.

### 🟢 Ejercicio 6 — Neo4j

Con `cypher-shell`, las aeronaves en que estuvo alguna vez una pieza del lote `LOT-2022-117`.

**Objetivo:** la lista contra `answers.json` ([`a05`](a05-el-dominio-de-flota.md)), y los *db hits* de `PROFILE`.

### 🟢 Ejercicio 7 — Qdrant

Con la API HTTP, los cinco reportes más parecidos a uno de la [Fase 15](15-vectorial-levantar-y-modelar.md), con y sin
`"exact": true`.

**Objetivo:** cuántos de los cinco coinciden entre las dos búsquedas.

### 🟢 Ejercicio 8 — Cassandra

Con `cqlsh`, las lecturas de una aeronave en un mes, con `TRACING ON`.

**Objetivo:** el conteo, y una sola partición tocada.

### 🟢 Ejercicio 9 — CouchDB

Con `curl`, una orden de `work_order` de la [Fase 19](19-offline-levantar-y-modelar.md) y sus revisiones
(`?revs_info=true`).

**Objetivo:** cuántas revisiones tiene, y si alguna de las órdenes del viaje de Freddy tiene conflictos.

### 🟢 Ejercicio 10 — CockroachDB

Con `cockroach sql`, la fila de una orden del expediente de la [Fase 21](21-newsql-levantar-y-modelar.md) y su rango
(`SHOW RANGE … FOR ROW`).

**Objetivo:** en qué nodo vive su *leaseholder*, y en qué región.

---

> 🏷️ **Este apéndice no lleva tag propio.** Cada sección se commitea con el prefijo de la fase que
> la escribió.
