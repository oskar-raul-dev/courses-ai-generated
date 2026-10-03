# 📎 Apéndice a03 — CLIs de los diez motores

> **Curso:** Ruta NoSQL Lite · Consulta rápida · **3 h**
> **Usado por:** todas las fases A · **Versiones cubiertas:** las del `compose.yaml` de
> [`a02`](a02-compose-de-la-ruta.md)
> **Fecha de verificación ejecutada:** la de cada sección. **Estado:** esqueleto; crece con el
> curso y se cierra al final (Tanda 6)

**Esto no se lee de corrido.** Se entra por el motor y se sale. Cada sección tiene la misma forma:
conectar desde el contenedor y desde tu máquina · listar lo que haya · insertar un registro del
dominio de Cóndor · consultarlo · contar · borrar · salir. Y las dos cosas que aquí se consultan
más que la sintaxis: **cómo se pide el plan de ejecución** y **cómo se sale sin dejar el proceso
colgado**.

**Qué queda fuera:** administración, usuarios y permisos, backup y tuning, y cualquier comparación
entre productos de la misma familia, que es materia de los cursos profundos de `ruta-no-sql/`.

---

## Índice

| Motor | CLI | Se escribe con |
|---|---|---|
| PostgreSQL (`base`) | [`psql`](#-postgresql--psql) | ✅ Fase 01 |
| MongoDB (`documental`) | [`mongosh`](#-mongodb--mongosh) | ✅ Fase 03 |
| Valkey (`clave-valor`) | [`valkey-cli`](#-valkey--valkey-cli) | ✅ Fase 05 |
| DuckDB (analítico) | `duckdb` | 🚧 Fase 07 |
| TimescaleDB (`series`) | `psql` | 🚧 Fase 09 |
| OpenSearch (`busqueda`) | `curl` | 🚧 Fase 11 |
| Neo4j (`grafos`) | `cypher-shell` | 🚧 Fase 13 |
| Qdrant (`vectorial`) | [API HTTP](#-qdrant--api-http) | ✅ Fase 15 |
| Cassandra (`columnar`) | `cqlsh` | 🚧 Fase 17 |
| CouchDB (`offline`) | HTTP y Fauxton | 🚧 Fase 19 |
| CockroachDB (`newsql`) | `cockroach sql` | 🚧 Fase 21 |

Cada sección se escribe **ejecutando** sus comandos contra el laboratorio, con la salida real, en
la fase que abre su familia.

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

## 🧭 Cuándo usar qué

🚧 Se completa al cerrar el apéndice: la tabla de "cómo pido el plan" y "cómo salgo" de los diez
motores, lado a lado.

---

## 🧪 Ejercicios

🚧 Diez al cerrar el apéndice, uno por motor: conectar y responder una pregunta del dominio.

---

> 🏷️ **Este apéndice no lleva tag propio.** Cada sección se commitea con el prefijo de la fase que
> la escribió.
