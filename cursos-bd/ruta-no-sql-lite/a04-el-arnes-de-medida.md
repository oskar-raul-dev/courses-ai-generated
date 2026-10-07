# 📎 Apéndice a04 — El arnés de medida

> **Curso:** Ruta NoSQL Lite · Consulta rápida · **3 h**
> **Usado por:** todas las fases B · **Versiones cubiertas:** las del `compose.yaml` de
> [`a02`](a02-compose-de-la-ruta.md)
> **Fecha de verificación ejecutada:** la de cada sección. **Estado:** esqueleto; crece con el
> curso y se cierra al final (Tanda 6)

**Esto no se lee de corrido.** Es el apéndice que convierte una afirmación en evidencia: qué campo
mirar en cada motor, cuál ignorar, y cómo se cuenta lo que ningún motor reporta.

**Qué queda fuera:** benchmarking de rendimiento, generadores de carga sintética y percentiles de
latencia. Este curso **mide la forma, no la velocidad**.

---

## Índice

- [**Los viajes de ida y vuelta**](#-los-viajes-de-ida-y-vuelta) — ningún motor los reporta: se
  cuentan en el cliente. Es la métrica más importante del curso. ✅ Fase 01
- [**La ficha de medición**](#-la-ficha) — los cinco datos, lista para pegar. ✅ Fase 01
- [**El protocolo de la apuesta falsable**](#-el-protocolo-de-la-apuesta-falsable) — se escribe antes, no se edita después. ✅ Fases 04, 06 y 16
- **Fan-out y amplificación de escritura**, sin herramientas externas. 🚧 la primera fase B que los mida (F06 no los necesitó)
- **Qué mirar en cada motor**, con el comando exacto y una salida real:

| Motor | Qué se pide | Se escribe con |
|---|---|---|
| PostgreSQL | [`EXPLAIN (ANALYZE, BUFFERS)`](#-postgresql--filas-examinadas-contra-devueltas) y `pg_stat_statements` | ✅ Fase 01 |
| MongoDB | [`explain("executionStats")`](#-mongodb--documentos-examinados-contra-devueltos) | ✅ Fase 03 |
| Valkey | [escrituras al socket, `INFO memory`, `MEMORY USAGE`](#-valkey--escrituras-al-socket-y-bytes-por-clave) | ✅ Fase 05 |
| DuckDB | `EXPLAIN ANALYZE` | 🚧 Fase 07 |
| TimescaleDB | `EXPLAIN` sobre hypertables, tamaño de chunks | 🚧 Fase 09 |
| OpenSearch | `profile` | 🚧 Fase 11 |
| Neo4j | `PROFILE` | 🚧 Fase 13 |
| Qdrant y `pgvector` | [recall contra la búsqueda exacta y contra la verdad de referencia](#-vectorial--recall-en-sus-dos-sentidos) | ✅ Fases 15–16 |
| Cassandra | `TRACING ON` | 🚧 Fase 17 |
| CouchDB | volumen de replicación y revisiones | 🚧 Fase 19 |
| CockroachDB | `EXPLAIN ANALYZE`, latencia por localidad | 🚧 Fase 21 |

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

## 🪞 El protocolo de la apuesta falsable

Son seis reglas, y aquí van con cómo se cumplen en la
práctica, con las cuatro apuestas publicadas hasta ahora como ejemplo.

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

## 🧪 Ejercicios

🚧 Ocho al cerrar el apéndice, todos de medir lo mismo en dos motores y explicar la diferencia.

---

> 🏷️ **Este apéndice no lleva tag propio.** El código del arnés vive en `src/` y se commitea con la
> fase que lo introduce.
