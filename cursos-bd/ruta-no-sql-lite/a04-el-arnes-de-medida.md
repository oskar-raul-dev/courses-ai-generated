# 📎 Apéndice a04 — El arnés de medida

> **Curso:** Ruta NoSQL Lite · Consulta rápida · **3 h**
> **Usado por:** todas las fases B · **Versiones cubiertas:** las del `compose.yaml` de
> [`a02`](a02-compose-de-la-ruta.md)
> **Fecha de verificación ejecutada:** la de cada sección, del 29/09/2026 al 12/10/2026. **Estado:** cerrado el
> 12/10/2026, con los once motores y las mediciones del capstone

**Esto no se lee de corrido.** Es el apéndice que convierte una afirmación en evidencia: qué campo
mirar en cada motor, cuál ignorar, y cómo se cuenta lo que ningún motor reporta.

**Qué queda fuera:** benchmarking de rendimiento, generadores de carga sintética y percentiles de
latencia. Este curso **mide la forma, no la velocidad**. Hay una excepción, declarada: la
[ventana de inconsistencia](#️-la-ventana-de-inconsistencia-del-commit-a-la-copia) de la Fase 24 se reporta con
mediana y p99, porque es un tiempo por definición; lo que la sostiene como veredicto es su forma —acotada,
igual a la caída, o infinita—, no sus milisegundos.

---

## Índice

- [**Los viajes de ida y vuelta**](#-los-viajes-de-ida-y-vuelta) — ningún motor los reporta: se
  cuentan en el cliente. Es la métrica más importante del curso. ✅ Fase 01
- [**La ficha de medición**](#-la-ficha) — los cinco datos, lista para pegar. ✅ Fase 01
- [**El protocolo de la apuesta falsable**](#-el-protocolo-de-la-apuesta-falsable) — se escribe antes, no se edita después. ✅ Fases 04, 06 y 16
- [**Amplificación de escritura**](#️-amplificación-de-escritura-lo-que-se-escribe-para-guardar-un-dato), sin herramientas externas. ✅ Fases 08–09, y entre motores con el `io.stat` del contenedor, ✅ Fase 18; el *fan-out* entre motores, en la ventana de inconsistencia, ✅ Fase 24
- [**La huella de un derivado**](#️-la-huella-de-un-derivado-lo-que-se-compara-para-saber-si-se-reconstruye) — fila por fila, por huella o por resultado: si un motor se rearma desde su fuente. ✅ Fase 23
- [**La ventana de inconsistencia**](#️-la-ventana-de-inconsistencia-del-commit-a-la-copia) — del `COMMIT` a la copia, con un solo reloj, y lo que queda pendiente mientras el derivado está caído. ✅ Fase 24
- **Qué mirar en cada motor**, con el comando exacto y una salida real:

| Motor | Qué se pide | Se escribe con |
|---|---|---|
| PostgreSQL | [`EXPLAIN (ANALYZE, BUFFERS)`](#-postgresql--filas-examinadas-contra-devueltas) y `pg_stat_statements` | ✅ Fase 01 |
| MongoDB | [`explain("executionStats")`](#-mongodb--documentos-examinados-contra-devueltos) | ✅ Fase 03 |
| Valkey | [escrituras al socket, `INFO memory`, `MEMORY USAGE`](#-valkey--escrituras-al-socket-y-bytes-por-clave) | ✅ Fase 05 |
| DuckDB | [`EXPLAIN (ANALYZE, FORMAT json)`: bytes leídos](#-duckdb--bytes-leídos-contra-páginas) | ✅ Fase 07 |
| TimescaleDB | [`EXPLAIN` con chunks, WAL y lecturas por tabla](#️-timescaledb--chunks-wal-y-lecturas-por-tabla) | ✅ Fase 09 |
| OpenSearch | [aciertos contra la verdad, viajes de `_bulk`, términos](#-opensearch--aciertos-contra-la-verdad-y-términos) | ✅ Fase 11 |
| Neo4j | [`PROFILE`: *db hits* y filas](#️-neo4j--cardinalidad-de-travesía) | ✅ Fases 13–14 |
| Qdrant y `pgvector` | [recall contra la búsqueda exacta y contra la verdad de referencia](#-vectorial--recall-en-sus-dos-sentidos) | ✅ Fases 15–16 |
| Cassandra | [`TRACING ON`: particiones, SSTables y filas vivas leídas](#️-cassandra--particiones-y-sstables-tocadas) | ✅ Fase 17 |
| CouchDB y PouchDB | [lo que viaja al replicar, y qué edición sobrevive](#-couchdb--lo-que-viaja-y-qué-sobrevive) | ✅ Fase 19 |
| CockroachDB | [`EXPLAIN ANALYZE`: filas del almacén, nodos y regiones](#-cockroachdb--filas-del-almacén-nodos-y-regiones) | ✅ Fase 21; la latencia por localidad, ✅ Fase 22 |

- [**Ejercicios**](#-ejercicios-8) — ocho, de medir lo mismo en dos motores.

---

## 🔁 Los viajes de ida y vuelta

Verificado el 29/09/2026. Ningún motor reporta cuántas veces tu programa habló con él: **se cuenta
en el cliente**. `countRoundTrips` (`src/lab/harness/roundtrips.ts`) envuelve un método del driver
y suma uno por llamada; el cliente se sigue usando igual.

```ts
import { countRoundTrips } from "../lab/harness/roundtrips.ts";

const trips = countRoundTrips(client, "query"); // con pg; en otro driver, su método
await client.query("SELECT …");
console.log(trips.count); // 1
```

La primera medición que lo usa es la M-01 de la [Fase 01](01-el-dominio-de-flota-y-el-arnes.md):
**1 viaje con un `JOIN` contra 66 en N+1**, para la misma información. Ese 66 no aparece en ningún
plan, porque cada consulta del N+1 tiene un plan perfecto.

---

## 🐘 PostgreSQL · filas examinadas contra devueltas

Verificado el 29/09/2026 con PostgreSQL 18.6. `explain()` (`src/lab/harness/explain.ts`) ejecuta
`EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)` y devuelve:

- **`examined`**: la suma, en cada nodo de acceso (`… Scan`), de
  `(Actual Rows + Rows Removed by Filter + Rows Removed by Index Recheck) × Actual Loops`.
- **`returned`**: las filas del nodo raíz.
- **`sharedHit` y `sharedRead`**: bloques de 8 kB de la caché y del disco.
- **`access`**: cómo leyó cada tabla (`Index Scan on work_order using …`).

**Qué mirar:** `examined` contra `returned`, y el cociente. **Qué ignorar:** `cost`, que es una
unidad del planificador, y los tiempos, que son contexto.

**Dos trampas de Postgres 18 que el arnés ya resuelve:**

- **`Actual Rows` es un promedio por vuelta, con decimales** (`rows=1.23 loops=65`). Se multiplica
  por las vueltas y se redondea el total.
- **En un nodo paralelo, `rows` y `Rows Removed by Filter` son promedios por proceso.** Un
  `Parallel Seq Scan` con `loops=3` y `Rows Removed by Filter: 333312` descartó ≈ 1 000 000 de
  filas, no 333 312.

**Qué no es garantía:** los bloques. En tres cargas del mismo dataset, la misma consulta leyó
23 937, 23 937 y 23 938 bloques. Las filas y los viajes sí se repiten exactamente.

---

## 🍃 MongoDB · documentos examinados contra devueltos

Verificado el 29/09/2026 con MongoDB 8.0.20.

**Los viajes**, con los eventos de comando del driver: el cliente se crea con `monitorCommands: true`
y `countMongoRoundTrips` (`src/lab/harness/roundtrips.ts`) cuenta cada `commandStarted`, sin la
conversación propia del driver (`hello`, autenticación, `endSessions`). Cuenta también los `getMore`
de un cursor grande: cada lote es un viaje.

**Lo examinado**, con `explainFind` (`src/lab/harness/mongo-explain.ts`), que lee de
`explain("executionStats")`:

- **`totalDocsExamined`** — el equivalente de las filas examinadas: **el número que el curso compara**.
- **`totalKeysExamined`** — entradas de índice recorridas.
- **`nReturned`** — los devueltos.
- **el plan ganador**, resumido: `COLLSCAN`, `IXSCAN { campo: 1 }`, `EXPRESS_IXSCAN`, `FETCH`.

**Para `$lookup`**, el `explain` de la agregación trae, en la etapa `$lookup`, `totalDocsExamined`,
`totalKeysExamined`, `collectionScans` e `indexesUsed` de la colección ajena. `collectionScans: 1` sin
índice es la firma del bucle anidado que recorre la colección entera.

**Lo que Mongo no expone:** bloques o páginas leídas. Por eso, al comparar con Postgres, la medida común
son examinados contra devueltos, y los bloques de Postgres se cuentan aparte, como contexto
([Fase 04](04-documental-romper-y-medir.md) §4.8).

---

## 🔑 Valkey · escrituras al socket y bytes por clave

Verificado el 29/09/2026 con Valkey 9.1.2 e iovalkey 0.4.0.

**Los viajes**, con `countSocketWrites` (`src/lab/harness/roundtrips.ts`): envuelve el `write` del
socket del cliente y cuenta una por escritura. Se llama **después** de `connect()`, porque el socket
nace al conectar. Contar comandos no serviría: cien comandos en un pipeline son un viaje. Con 100
lecturas de sesión (`src/05-clave-valor-levantar-y-modelar/trips.ts`):

```text
   una a una con await: 100 · pipeline: 1 · Promise.all: 100 · Promise.all con autopipelining: 1
```

**Qué mide y qué no:** mide **envíos**. En `Promise.all`, los 100 salen sin esperar respuesta, así que
no son 100 esperas en serie aunque el contador diga 100. Para el curso, que compara formas, basta; si
una comparación dependiera de esa diferencia, habría que decirlo.

**Los bytes**, de dos formas que no miden lo mismo:

- **`MEMORY USAGE <clave>`** — lo que ocupa una clave con su valor. Una sesión de la Fase 05: 160
  bytes.
- **La resta de `used_memory`** (`INFO memory`) antes y después de cargar N claves, dividida por N:
  lo que la instancia creció por clave, incluidas las estructuras auxiliares. La misma sesión, con su
  entrada en el índice a mano: 206 bytes.

**La trampa de la segunda:** sin una instancia limpia, la resta sale corta. La primera versión de la
medición de la Fase 06 dio **91 bytes por sesión en vez de 155**, porque `used_memory` arrastraba
memoria liberada en pruebas anteriores. Antes de medir: `FLUSHALL SYNC`, `MEMORY PURGE` y un segundo de
espera, y otra vez `MEMORY PURGE` antes de leer el resultado. Aun así, las cifras pequeñas varían uno o
dos bytes entre corridas.

**Contra Postgres:** los bytes de Valkey son RAM; los de una tabla (`pg_table_size` +
`pg_indexes_size`) son de relación, en disco y cacheados en memoria compartida. Se pueden poner lado a
lado para ver el orden de magnitud, diciendo siempre cuál es cuál
([Fase 06](06-clave-valor-romper-y-medir.md) §4.2).

---

## 🦆 DuckDB · bytes leídos contra páginas

Verificado el 07/10/2026 con DuckDB 1.5.6. En una base por columnas, "filas examinadas" dice poco: DuckDB
recorre las 50 M filas de una agregación igual que Postgres. Lo que cambia es **cuánto de cada fila
lee**, y eso se mide en bytes.

```python
profile = json.loads(con.sql(f"EXPLAIN (ANALYZE, FORMAT json) {sql}").fetchall()[0][1])
profile["total_bytes_read"], profile["cumulative_rows_scanned"]
```

- **`total_bytes_read`** — los bytes que DuckDB leyó **de su propio archivo**. Se compara con las páginas
  de Postgres por 8 kB (`EXPLAIN (ANALYZE, BUFFERS)`, sección de PostgreSQL). Tres columnas sobre 50 M:
  203 MiB contra 4439 MiB (Fase 07, M-16).
- **`cumulative_rows_scanned`** — las filas recorridas. Baja cuando el mínimo y el máximo de cada grupo
  de filas permiten saltarlo: **0** para un valor que no existe.

Tres trampas, las tres comprobadas. **En frío o no cuenta:** con la misma conexión, la segunda vez lee 0
bytes; una conexión nueva por medición. **`count(columna)` no se puede medir**: DuckDB lo contesta con
las estadísticas y el perfil devuelve `{"result": "error"}`; se mide con `max`. **Un Parquet no entra en
`total_bytes_read`**: lo que se lee de un archivo externo se calcula con el pie del archivo
(`parquet_metadata`), y se declara como cálculo.

**Lo que no mide el perfilador, y cómo se mide** (Fase 08). Bytes **escritos**: `total_bytes_written`
dio 0 en un `UPDATE` de 50 M, así que se mide lo que crece el archivo tras un `CHECKPOINT`; del lado de
Postgres, el WAL con `pg_wal_lsn_diff(pg_current_wal_insert_lsn(), <lsn de antes>)`. **Volcado a disco:**
`system_peak_temp_dir_size` en DuckDB; en Postgres, `Temp Written Blocks` del plan en JSON, o
`external merge  Disk:` y `Disk Usage` en el texto.

## ⏱️ TimescaleDB · chunks, WAL y lecturas por tabla

Verificado el 07/10/2026 con TimescaleDB 2.30.1. Al leer, es Postgres: `EXPLAIN (ANALYZE, BUFFERS)` y el
arnés de la sección de PostgreSQL, con dos ajustes.

- **Chunks tocados:** cada chunk es una tabla `_hyper_N_M_chunk`; se cuentan los nombres distintos en el
  plan (`measure.ts` de la Fase 09). **El nodo `Custom Scan`** (ChunkAppend, DecompressChunk) no cuenta
  como filas examinadas: sus filas son las de sus hijos, o filas descomprimidas.
- **Lo que no es una consulta** —un refresco de agregado continuo, un `drop_chunks`, una compresión—
  no tiene plan. Se mide con lo que deja: el **WAL** (`pg_wal_lsn_diff(pg_current_wal_insert_lsn(), <lsn
  de antes>)`, tras un `CHECKPOINT`) y **las filas leídas** de cada tabla (`seq_tup_read +
  idx_tup_fetch` en `pg_stat_user_tables`, después de `pg_stat_force_next_flush()`). Los chunks de cada
  hypertable se leen de `timescaledb_information.chunks`: suponer el prefijo `_hyper_1_` midió 0 la
  primera vez (Fase 09, sección 9).

## 🕸️ Neo4j · cardinalidad de travesía

Verificado el 07/10/2026 con Neo4j 2026.09.0. La medida de la familia es **cuánto recorre** el motor: el
`PROFILE` de la consulta, sumado por `lab/harness/neo4j-profile.ts`.

- ***db hits*** — accesos lógicos al almacén: un nodo, una relación, una propiedad, una entrada de índice. No
  son páginas ni bytes, y no se restan contra las filas examinadas de Postgres: se compara **cómo crecen**
  cuando cambia la pregunta.
- **Filas del operador más ancho** — el tamaño máximo de la travesía, que es lo que crece con los saltos.
- **El operador de abajo** — `NodeIndexSeek` empieza por un índice; `NodeByLabelScan` recorre todo el label.

Los *db hits* varían un poco entre dos cargas del mismo dataset (219 423 y 220 020 en la Fase 13): el orden
físico del almacén cambia. Se publica el rango.

**La caché de páginas no se ve en el `PROFILE` de Community**: los aciertos y fallos de caché por operador
son de la edición Enterprise. La Fase 14 la mide desde fuera: los bytes que el contenedor leyó de disco
(`rbytes` en `io.stat` de su cgroup) y sus fallos de página mayores (`pgmajfault` en `memory.stat`), antes y
después de la consulta. En frío exige vaciar antes la caché de archivos de la máquina virtual de Docker, que
se hace desde un contenedor privilegiado de un solo uso (`14-…/cache.ts` dice cómo); sin ese paso, la
segunda corrida "en frío" lee de la memoria del sistema y sale en cero.

## 🔍 OpenSearch · aciertos contra la verdad, y términos

Verificado el 07/10/2026 con OpenSearch 3.8.0. Un buscador no reporta "documentos examinados": recorre
las listas de los términos de la consulta. Lo que mide el curso:

- **Aciertos contra la verdad del catálogo**, como en vectorial: para cada búsqueda, cuántos de los
  documentos correctos devuelve. Se cuentan con `_count` y un filtro `ids` con la verdad, no con una página
  de resultados, que tiene tope (`size` hasta 10 000 por defecto).
- **El total de coincidencias**, con `track_total_hits: true`; sin él, OpenSearch deja de contar en 10 000 y
  dice `"relation": "gte"`.
- **Los términos y lo que mide su lista**: `_validate/query?explain=true` y `_termvectors` con
  `term_statistics` (`doc_freq` incluye documentos borrados que aún no se fusionaron).
- **Los viajes**: uno por petición; `_bulk` mete miles de documentos en uno.
- **El error de una agregación**: `doc_count_error_upper_bound` en cada `terms`; si no es 0, el conteo es
  aproximado.

## 🧬 Vectorial · recall, en sus dos sentidos

Verificado el 30/09/2026 con Qdrant 1.19.1 y pgvector 0.8.6. En esta familia la consulta **siempre
devuelve k resultados**, así que no hay "examinados contra devueltos": hay **cuánto de lo devuelto
sirve**, y el curso lo mide de dos formas que no se pueden confundir.

- **Recall del índice** — qué parte de los k vecinos **exactos** devuelve el índice aproximado. La
  referencia es la búsqueda exacta: `params: { exact: true }` en Qdrant, `SET enable_indexscan = off`
  en Postgres, o el producto de todos los vectores con numpy. Se usa para comparar índices y
  parámetros (`ef`). No dice nada de si los vecinos sirven.
- **Acierto de tipo de avería** — qué parte de los k primeros comparte el tipo de avería de la
  consulta según `pirep-labels.ndjson`, la verdad de referencia del generador que **nunca se carga en
  el motor** ([`a05`](a05-el-dominio-de-flota.md)). Se usa para decidir si el resultado sirve.

**Los empates.** El 15 % de `pirep-1m` son duplicados exactos, y dos puntos con el mismo vector son igual
de correctos. El recall del índice cuenta como acierto todo resultado cuyo parecido llegue al del
décimo vecino exacto (menos 10⁻⁵), no solo los mismos ids.

**Lo estructural que sí se ve.** En Postgres, las páginas de 8 kB que toca cada consulta
(`EXPLAIN (ANALYZE, BUFFERS)`): de 357 con `ef` 10 a 2995 con 320, sobre el millón. En Qdrant, los
fallos de página mayores del cgroup (`pgmajfault` en `memory.stat`), que cuentan lecturas de disco
cuando los vectores no están en memoria (Fase 16, sección 5). Y en los dos, que el índice exista: en
Qdrant, `indexed_vectors_count`, que con 10 000 puntos era **0**.

**La memoria, del cgroup y no de `docker stats`.** `docker stats` resta la caché de archivos, y Qdrant
mapea los vectores desde disco: con el millón cargado dijo 410 MiB cuando el contenedor ocupaba 1978.
Se lee `memory.current` y, en `memory.stat`, `anon`, `file` y `file_mapped`. Vale para cualquier motor
que lea sus datos a través de la caché del sistema operativo, Postgres incluido.

## 🏛️ Cassandra · particiones y SSTables tocadas

Verificado el 10/10/2026 con Cassandra 5.0.9. No hay plan: hay **traza**, que el coordinador escribe en
`system_traces` cuando se pide —`TRACING ON` en `cqlsh`, `traceQuery: true` en el driver—, y que
`lab/harness/cassandra-trace.ts` suma. Se leen cuatro cosas, cada una con su línea literal:

- **Lecturas de partición** — `Executing single-partition query on …`, una por partición nombrada. Una
  consulta bien modelada toca las particiones que nombró y ninguna más.
- **Recorridos por rango** — `Executing seq scan across N sstables for (…]`: la consulta no sabía en qué
  partición estaba y recorre rangos de tokens. Es la firma de `ALLOW FILTERING` sin partition key.
- **SSTables abiertas** — `Merged data from memtables and N sstables`. Antes, `Bloom filter allows skipping
  sstable N` dice cuáles se descartaron sin leerlas: con cuatro SSTables, la consulta 1 de la [Fase 17](17-columnar-levantar-y-modelar.md) abre
  una por partición.
- **Filas vivas y tombstones** — `Read N live rows and M tombstone cells`. Las filas vivas leídas contra las
  devueltas son el "examinados contra devueltos" de esta familia; los tombstones son lo que se leyó para
  saber que algo ya no está: en la [Fase 18](18-columnar-romper-y-medir.md), 5040 marcas leídas para devolver
  cero, y la lectura cancelada al pasar de 100 000.

**La paginación cuenta.** El driver pide de a 5000 filas por defecto, y cada página es una petición con su
propia traza: la página siguiente **reanuda** la partición donde quedó, y esa partición aparece dos veces. El
arnés pide páginas de 50 000 para que las consultas de la Fase 17 salgan en una, y reporta cuántas pidió.

**La duración que trae la traza es contexto.** Es el tiempo del coordinador, en microsegundos, y depende de
la máquina y de lo que esté corriendo al lado. Lo que se compara es lo de arriba. Para el tamaño de lo
guardado, `nodetool flush` y después `nodetool tablestats`: particiones estimadas, tamaño máximo y medio de
partición, y ratio de compresión.

## 📴 CouchDB · lo que viaja y qué sobrevive

Verificado el 11/10/2026 con CouchDB 3.5.2 y PouchDB 9.0.0. Esta familia no tiene plan ni traza que pedir: lo que
importa pasa **entre** dos bases. `lab/harness/couch.ts` lo mide desde el cliente, de dos maneras.

**El cable.** `remote(nombre, wire)` abre la base remota con un `fetch` que cuenta cada petición HTTP y los
bytes de cuerpo en cada sentido. La replicación de PouchDB devuelve además `docs_read` y `docs_written`. Las dos
cosas juntas dicen si un filtro rinde y si el *checkpoint* funciona: en la
[Fase 19](19-offline-levantar-y-modelar.md), la bajada de las cuatro aeronaves de Freddy son 1686 documentos, 89
peticiones y 1520 KiB, y repetirla sin nada nuevo, 6 peticiones.

> ⚠️ **Suma después de leer, y sin clonar.** `wire.down += await …` lee el total **antes** de esperar, y PouchDB
> tiene varias peticiones en vuelo a la vez: las sumas se pisan. Así contó primero el arnés, 423 KiB donde eran
> 1520, y un número distinto en cada corrida. Y leer el cuerpo de una copia (`res.clone()`) colgaba a veces la
> replicación hasta que Node salía sin terminar (E-68, [Fase 20](20-offline-romper-y-medir.md)). El arnés lee el
> cuerpo una vez, suma, y le devuelve a PouchDB una respuesta nueva con esos bytes.

**Las hojas.** Un conflicto no da error, así que se busca: `conflicts(db)` recorre la base con
`allDocs({ conflicts: true })` y devuelve los documentos con más de una hoja, y `leaves(db, id)` trae todas las
hojas con su cuerpo (`open_revs: "all"`). Con eso, cada edición que alguien hizo se clasifica contra lo que quedó:
**conservada**, **en disputa** (sobrevive junto a otra incompatible), **escondida** (solo en una revisión
perdedora) o **perdida** (en ninguna hoja). Es el "examinados contra devueltos" de esta familia: lo que se
escribió contra lo que la app puede leer.

Para el historial de un documento, `GET` con `?revs_info=true`: cada revisión con `available` o `missing`, que
dice si su cuerpo sigue guardado. Para el tamaño, `GET /<base>`: `sizes.active` contra `sizes.file`; para la
tableta, `tabletBytes(nombre)`, el `du` de su carpeta con la base cerrada. LevelDB devuelve el espacio cuando su
compactación interna lo decide: una tableta compactada puede seguir midiendo casi lo mismo, y la
[Fase 20](20-offline-romper-y-medir.md) lo vio pasar de 9700 a 9144 KiB con mil guardados y de 12 864 a 2136 con
dos mil.

## ⚡ CockroachDB · filas del almacén, nodos y regiones

Verificado el 11/10/2026 con CockroachDB 26.3.2, en un nodo y en nueve (`cockroach demo --global`). El plan se
pide igual que en Postgres, `EXPLAIN ANALYZE`, pero lo que importa en la salida es otra cosa: **a cuántas máquinas,
y a cuántas regiones, fue la sentencia**. `lab/harness/crdb-explain.ts` lee el texto y devuelve:

- **Filas del almacén** — `rows decoded from KV: 780 (… , 2 gRPC calls)`: lo que se leyó de la capa distribuida,
  con las llamadas que hicieron falta. Cuenta **la entrada del índice y la fila por separado**: las 390 órdenes de
  `HC-2157` por el índice `(aircraft, opened_at)` son 780 filas del almacén. No se compara uno a uno con las filas
  examinadas de Postgres ([Fase 21](21-newsql-levantar-y-modelar.md), sección 6.2).
- **Nodos** — `kv nodes: n2, n6, n8` en cada operador: dónde estaba lo que se leyó. En un nodo, siempre `n1`.
- **Regiones** — `regions: europe-west1, us-east1, us-west1`, solo en un clúster con regiones: la métrica de esta
  familia. Incluye las comprobaciones de unicidad y de clave foránea, que en CockroachDB son operadores del plan
  (`constraint-check`), no disparadores.
- **Operadores** — `scan`, `lookup join`, `insert fast path`…, en orden.

> ⚠️ **Lo que el plan no dice de una escritura.** Un `INSERT` por el *insert fast path* no lista la región donde
> escribe, solo las que leyó para comprobar. Para saber dónde quedó la fila, y quién tuvo que confirmarla,
> `SHOW RANGE FROM TABLE <t> FOR ROW (<clave>)` después del `COMMIT`: `lease_holder_locality` y, cruzando `replicas`
> con `replica_localities`, las regiones de los `voting_replicas`. En una tabla `REGIONAL BY ROW` la clave empieza
> por la región. Es lo que hace `regions.ts` en la Fase 21.

**Sin parámetros.** CockroachDB no acepta `$1` dentro de un `EXPLAIN` ni de un `SHOW RANGE … FOR ROW` (E-73 en
[`a09`](a09-catalogo-de-errores.md)). `inline()` escribe los valores como literales con el escape del driver.

**Dónde vive cada cosa.** `SHOW RANGES FROM TABLE <t> WITH DETAILS` lista los rangos con su leaseholder, sus
réplicas votantes y no votantes, y la localidad de cada una; `SHOW ZONE CONFIGURATION FROM TABLE <t>`, la regla que
el motor intenta cumplir (`num_voters`, `voter_constraints`, `lease_preferences`). Después de cambiar una regla, el
clúster tarda en mover réplicas: en la Fase 21, `PLACEMENT RESTRICTED` tardó **minutos**, y `placement.ts` espera a
que termine antes de contar.

**El tiempo, aparte.** `execution time` sale en cada plan, y el arnés lo guarda, pero en esta familia el tiempo
es **física simulada**: la latencia entre regiones la inyecta `demo`. En la Fase 21 no sostiene ninguna
conclusión; en la [Fase 22](22-newsql-romper-y-medir.md) es el argumento, y se mide **en el servidor y sentencia por
sentencia**, nunca con el reloj del cliente sobre un lote. La herramienta es `SHOW LAST QUERY STATISTICS`, pedida
después de cada sentencia, **incluido el `COMMIT`**, que no tiene `EXPLAIN`: `lastStatement()` devuelve su
`service_latency`, lo que tardó el servidor de que llegó la sentencia a que respondió. La primera vez que se corre
una sentencia el plan puede tardar casi un segundo (836 ms en la fase): se mide después de una vuelta de
calentamiento, y se reporta la mediana.

**Postgres, sin red simulada.** Para compararlo, la fase mide su servidor con el reloj del cliente sobre la red
local de Docker, **una transacción por viaje** —el servidor más el *loopback*, no un lote— y le suma los viajes a
otro país por el RTT que el demo midió entre esas dos regiones. Es un modelo, y se declara como tal.

## ⚖️ La huella de un derivado: lo que se compara para saber si se reconstruye

Verificado el 12/10/2026. Un motor que no es la fuente de verdad tiene que poder rearmarse desde ella
([Fase 23](23-poliglota-el-diseno.md)). Ningún motor lo reporta: se arma **otra copia desde la fuente** y se compara
con la que hay, con una de tres formas según el tamaño y el motor.

- **Fila por fila**, cuando cabe recorrer las dos: la fuente por páginas (`DECLARE … CURSOR` en Postgres, de a
  10 000) y, por cada página, **las mismas claves** pedidas al derivado (`POST _all_docs` con `keys` en CouchDB), con
  una forma canónica antes de comparar. Pedir la página del derivado por rango (`startkey`) solo funciona si los dos
  lados tienen las mismas claves: con documentos de menos, la página se corre y cuenta ausentes de más (Fase 24). Lo que se normaliza se
  escribe: en `rebuild-couch.ts`, el orden de las piezas de cada orden, que Postgres no guarda.
- **Por huella**, cuando el derivado es una tabla grande en otro formato: conteo, extremos y la suma de cada columna
  numérica, por la clave que tenga sentido (por aeronave en `readings.ts`). Una corrección hecha solo en el derivado
  cambia la suma de su grupo.
- **Por resultado**, cuando lo que importa es una consulta: la misma consulta en las dos copias, comparada fila por
  fila (el costo por hora en `rebuild_duckdb.py`).

**Lo que la igualdad demuestra** es que la fuente tiene todos los campos que el derivado necesita. Si los dos lados
salieron del mismo archivo, no demuestra que sigan iguales después de un mes de escrituras: eso es la ventana de
inconsistencia de la Fase 24. Y una proyección dentro de la misma fuente se comprueba igual: en la Fase 23, el estado
de cada pieza contra su último movimiento dejó **135 557 de 740 741** sin un hecho que lo explique (M-72).

## ⏱️ La ventana de inconsistencia: del COMMIT a la copia

Verificado el 12/10/2026. Cuánto tarda una escritura confirmada en la fuente en verse en un derivado
([Fase 24](24-poliglota-la-costura.md)). Ningún motor lo reporta, y medirlo con dos relojes —el del servidor de
Postgres y el de CouchDB— mezcla su desfase con la ventana. Se mide con **un solo reloj, el de la máquina**, en dos
procesos que lo comparten:

- **El lado de la fuente:** quien escribe anota `Date.now()` cuando vuelve el `COMMIT` (`run.ts`).
- **El lado del derivado:** un observador escucha el `_changes` continuo de CouchDB y anota la primera vez que ve
  cada documento (`watch.ts`), reconectándose desde la última secuencia si el motor se cae.
- **La ventana** es la resta por orden; se reportan mediana, p99 y máximo, y **cuántas no llegaron nunca**, que
  es el número que importa. Una orden que no llega no tiene ventana: no se cuenta como una muy larga.

**Lo pendiente mientras el derivado está caído** se lee en la fuente: las filas del outbox (`count(*)`) o el WAL que
retiene el slot lógico, `pg_wal_lsn_diff(pg_current_wal_lsn(), confirmed_flush_lsn)` en `pg_replication_slots`,
muestreados cada medio segundo. El segundo crece aunque el relevo no tenga nada que entregar: el slot retiene todo el
WAL de la instancia, no solo el de las tablas que importan.

La escala es la de la máquina, no la del motor: a 200 órdenes por segundo la ventana es de decenas de milisegundos y
**ningún veredicto se sostiene sobre ella**. Lo que sí sostiene uno es su forma: acotada por el intervalo del relevo
cuando todo funciona, igual a la caída más la puesta al día cuando no, e infinita en la doble escritura.

## ✍️ Amplificación de escritura: lo que se escribe para guardar un dato

Verificado el 07/10/2026. La amplificación es el cociente entre **lo que el motor escribe** y **el dato
que querías guardar**. No hay campo que la reporte; se mide con dos lecturas antes y después.

- **Postgres y TimescaleDB:** el WAL, con `pg_wal_lsn_diff(pg_current_wal_insert_lsn(), <lsn de antes>)`
  después de un `CHECKPOINT`, y el tamaño de la tabla con `pg_relation_size`.
- **DuckDB:** lo que crece el archivo después de un `CHECKPOINT`; su perfilador no cuenta bytes escritos.

El ejemplo de la [Fase 08](08-analitico-romper-y-medir.md): un entero de 4 bytes nuevo en 50 M lecturas son
**190,7 MiB de dato**. Postgres, con `ADD COLUMN` y `UPDATE`, escribió **13 992 MiB de WAL** —una
amplificación de 73×— y dobló la tabla; DuckDB creció 51,8 MiB, menos que el dato, porque lo comprime. Y en
la [Fase 09](09-series-levantar-y-modelar.md), corregir un mes sobre chunks comprimidos escribió 654,3 MiB de
WAL contra 393,4 de la tabla normal: descomprimir también es escribir.

**Entre motores, los bytes del contenedor.** El WAL no existe en Cassandra, y el *commitlog* no cuenta las
compactaciones, que son la mayor parte. Para comparar dos motores, `lab/harness/io.ts` lee `wbytes` del
`/sys/fs/cgroup/io.stat` de cada contenedor, después de un `sync`: lo que llegó al dispositivo, con la misma
regla para todos. En Cassandra se lee cuando `nodetool compactionstats` ya no tiene tareas pendientes; en
Postgres, después de `CHECKPOINT`. El desglose lo da cada motor: `pg_stat_io` por tipo de escritura y
`system.compaction_history` por compactación. En la [Fase 18](18-columnar-romper-y-medir.md), 50 M lecturas:
**70 530 MiB en Cassandra y 70 255 en Postgres**, por caminos opuestos (M-46).

## 🪞 El protocolo de la apuesta falsable

Son seis reglas, y aquí van con cómo se cumplen en la
práctica, con algunas de las apuestas del curso como ejemplo.

1. **Se escribe antes de ejecutar, con fecha, en el documento.** Primero la apuesta, después el
   comando. La de la [Fase 04](04-documental-romper-y-medir.md) se escribió antes de ejecutar
   `measure.ts`; las de la [Fase 16](16-vectorial-romper-y-medir.md), antes de cargar el millón.
2. **Lleva un número que la pueda refutar**, en la unidad que el curso mide: *"menos de 2× de
   degradación en filas examinadas"* (F04), *"los mismos viajes y menos de 3× los bytes"* (F06), *"a no
   más de 0,02 de recall con el mismo `ef`"* (F16). Si no hay número, no hay apuesta.
3. **No se edita después.** El resultado va debajo, con el número delante, y el texto original se
   queda como estaba.
4. **Se dice si se ganó, se perdió o las dos cosas, y en qué parte.** Una apuesta con dos cláusulas
   puede perderse en su letra y ganarse en su fondo —la primera de F16: pierde con `ef` bajo, empata
   desde 80—, y se escribe así, sin redondear hacia el lado cómodo.
5. **Si se gana con facilidad, se sospecha de la medición.** Antes de publicar una victoria, revisa los
   dos planes: la línea base de F04 examinaba 14 983 filas por un índice que faltaba, y el filtro de F16
   empataba porque el planificador no usaba el HNSW. Es la regla de la Fase 14, y vale en todas.
6. **Entra a la tabla de apuestas de la [bitácora](bitacora-de-medicion.md)** con su resultado y el
   enlace a la medición que la decide.

**Una por minicurso**, es la regla general. La Fase 16 lleva dos —la de `pgvector` y la de los prefijos—
por una decisión del 30/09/2026: la de los prefijos venía de la verificación del laboratorio y
no tenía otro sitio donde medirse sobre el millón.

---

## 📋 La ficha

`formatFicha` (`src/lab/harness/ficha.ts`) imprime la ficha de medición con los cinco datos de toda
medición del curso —qué se midió, volumen con su hash, motor y digest, máquina si hay tiempos, y el comando
exacto—, lista para pegar en una fase y en la [bitácora](bitacora-de-medicion.md). La primera es
la M-01.

---

## 🧪 Ejercicios (8)

Todos de medir **lo mismo en dos motores** con el campo de este apéndice que le toca a cada uno, y explicar la
diferencia con la forma de acceso, no con el motor. Desde `src/`, con los dos perfiles del ejercicio arriba.

### 🟢 Ejercicio 1 — Examinados contra devueltos

La misma consulta polimórfica de la [Fase 04](04-documental-romper-y-medir.md) en Mongo y en Postgres con JSONB.

**Objetivo:** `totalDocsExamined`/`nReturned` contra filas examinadas/devueltas, y por qué el cociente es 1,00× (M-04).

### 🟢 Ejercicio 2 — Viajes

Una sesión de técnico en Valkey y en una tabla `UNLOGGED`, con `countRoundTrips`.

**Objetivo:** los viajes de cada operación en los dos, y la diferencia en bytes (M-09).

### 🟡 Ejercicio 3 — Bytes leídos

El costo por hora volada en DuckDB y en Postgres, con el perfil de cada uno.

**Objetivo:** bytes leídos contra páginas leídas, y qué columna explica la diferencia.

### 🟡 Ejercicio 4 — Chunks contra particiones

Dos semanas de una aeronave en TimescaleDB y en Postgres particionado por mes.

**Objetivo:** *chunks* tocados contra particiones tocadas, y en qué consulta se invierte la ventaja (M-25).

### 🟡 Ejercicio 5 — La travesía

Las aeronaves de una pieza del lote de la directiva, con `PROFILE` en Neo4j y `EXPLAIN (ANALYZE)` sobre `WITH
RECURSIVE`.

**Objetivo:** *db hits* contra filas del CTE, y por qué no son la misma unidad (M-37).

### 🟠 Ejercicio 6 — Recall en los dos sentidos

Los diez más parecidos a un reporte, en Qdrant y en `pgvector`, con y sin filtro de aeronave.

**Objetivo:** recall contra la búsqueda exacta y contra la etiqueta de `pirep-labels.ndjson`, en los dos (M-12, M-13).

### 🟠 Ejercicio 7 — Particiones tocadas

Las lecturas de un vuelo en Cassandra con `TRACING ON` y en Postgres particionado con `EXPLAIN`.

**Objetivo:** particiones tocadas en cada uno, y la decisión de modelo que explica la diferencia.

### 🔴 Ejercicio 8 — La huella de un derivado

Corrige a mano una orden en CouchDB y una lectura en TimescaleDB, y encuentra las dos con la huella de este apéndice.

**Objetivo:** cuál de las tres formas —fila por fila, por huella, por resultado— la encontró en cada motor, y cuánto
tardó.

---

> 🏷️ **Este apéndice no lleva tag propio.** El código del arnés vive en `src/` y se commitea con la
> fase que lo introduce.
