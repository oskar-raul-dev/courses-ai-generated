# 📎 Apéndice a09 — Catálogo de errores con mensaje literal

> **Curso:** Ruta NoSQL Lite · Consulta rápida y documento vivo · **3 h**
> **Usado por:** todas las fases · **Versiones cubiertas:** las de cada entrada
> **Fecha de verificación ejecutada:** la de cada entrada. **Entradas:** 83; el curso se proponía
> reunir 50. **Estado:** cerrado el 12/10/2026, con las 25 fases escritas y corridas

**Esto no se lee de corrido.** Se entra buscando el mensaje que acabas de pegar en un buscador.
Cada entrada es un error que **apareció de verdad al ejecutar** algo de este curso, con su
mensaje literal tal como salió, sin recortar la parte incómoda.

**Qué queda fuera:** errores que nadie vio. Una entrada reconstruida de memoria es un mensaje que
no existe, y un mensaje que no existe no lo encuentra nadie. Por eso este catálogo **creció con
el curso**: cada fase añadió lo que encontró al ejecutarse, con el mismo formato que las entradas de abajo. Los números
no son consecutivos dentro de cada motor: siguen el orden en que aparecieron.

---

## Índice por motor

- **MongoDB** — [E-01](#e-01--una-transacción-en-un-mongo-sin-replica-set) ·
  [E-02](#e-02--mongodb-8-no-arranca-y-habla-del-kernel) ·
  [E-03](#e-03--el-driver-de-mongo-se-cuelga-hasta-el-timeout) · [E-20](#e-20--un-índice-compuesto-sobre-dos-arrays) ·
  [E-21](#e-21--una-función-de-fechas-sobre-un-texto) · [E-22](#e-22--el-documento-que-no-cabe-intento-grande) ·
  [E-23](#e-23--el-documento-que-no-cabe-una-sola-escritura-de-más) · [E-24](#e-24--dos-transacciones-sobre-el-mismo-documento) · [E-31](#e-31--una-clave-duplicada-contra-un-índice-único)
- **Valkey** — [E-26](#e-26--un-comando-sobre-una-clave-de-otro-tipo) ·
  [E-27](#e-27--leer-de-un-grupo-de-consumidores-que-no-existe) · [E-28](#e-28--crear-un-grupo-que-ya-existe) ·
  [E-29](#e-29--un-comando-de-un-módulo-que-no-está-cargado) · [E-30](#e-30--la-memoria-llena-con-noeviction)
- **PostgreSQL** — [E-16](#e-16--un-lote-hijo-llega-antes-que-su-tabla-padre) ·
  [E-17](#e-17--econnrefused-al-conectar-con-postgres) ·
  [E-18](#e-18--el-dataset-no-coincide-con-su-manifiesto) ·
  [E-19](#e-19--pg_stat_statements-no-existe) · [E-25](#e-25--canceling-statement-due-to-lock-timeout) ·
  [E-35](#e-35--postgres-se-queda-sin-memoria-compartida-al-construir-un-índice) ·
  [E-36](#e-36--el-grafo-hnsw-no-cabe-en-maintenance_work_mem) ·
  [E-46](#e-46--una-partición-que-ya-tiene-filas-en-la-default) ·
  [E-56](#e-56--una-consulta-recursiva-que-no-termina) · [E-66](#e-66--una-cola-que-choca-con-una-restricción-única) ·
  [E-77](#e-77--la-réplica-que-perdió-al-primario) · [E-79](#e-79--serializable-que-rechaza-una-suma) ·
  [E-80](#e-80--el-slot-que-ya-tiene-dueño) · [E-81](#e-81--un-slot-lógico-que-no-deja-arrancar) ·
  [E-83](#e-83--crear-un-slot-lógico-sin-el-wal-lógico)
- **TimescaleDB** — [E-07](#e-07--un-error-de-timescaledb-en-el-primer-arranque) ·
  [E-44](#e-44--corregir-demasiadas-filas-comprimidas) · [E-45](#e-45--demasiados-chunks-para-una-transacción)
- **OpenSearch** — [E-05](#e-05--el-contenedor-sale-con-137-sin-decir-nada) ·
  [E-47](#e-47--un-campo-que-el-mapping-no-conoce) · [E-48](#e-48--un-campo-que-no-puede-cambiar-de-tipo) ·
  [E-49](#e-49--el-cliente-reintenta-un-_reindex-largo) · [E-50](#e-50--header-overflow-al-esperar-un-_reindex) ·
  [E-51](#e-51--el-índice-cerrado-por-disco-lleno) · [E-52](#e-52--el-intervalo-de-chequeo-de-disco-tiene-mínimo)
- **Qdrant** — [E-12](#e-12--qdrant-avisa-que-puede-perder-los-datos) · [E-32](#e-32--un-vector-de-otra-dimensión) ·
  [E-33](#e-33--un-umbral-por-debajo-del-mínimo) · [E-34](#e-34--una-colección-que-no-existe) ·
  [E-37](#e-37--un-lote-más-grande-de-lo-que-acepta-la-api)
- **DuckDB** — [E-08](#e-08--duckdb-no-deja-escribir-a-un-segundo-proceso) ·
  [E-38](#e-38--dos-escritores-sobre-la-misma-fila) · [E-39](#e-39--el-nombre-de-la-columna-no-es-el-del-archivo) ·
  [E-40](#e-40--escribir-en-una-base-abierta-en-solo-lectura) · [E-41](#e-41--una-columna-generada-después-de-crear-la-tabla) ·
  [E-42](#e-42--sin-memoria-con-muchos-hilos) · [E-43](#e-43--sin-memoria-y-sin-dónde-volcar)
- **Neo4j** — [E-53](#e-53--borrar-muchos-nodos-de-una-vez-agota-la-memoria-de-transacciones) ·
  [E-54](#e-54--un-producto-cartesiano-en-un-match) ·
  [E-55](#e-55--caminos-sin-límite-agotan-la-memoria-de-transacciones)
- **Cassandra** — [E-57](#e-57--un-write-timeout-en-una-carga-que-antes-funcionaba) ·
  [E-58](#e-58--quorum-que-no-se-alcanza) · [E-59](#e-59--una-consulta-que-pide-filtrar) ·
  [E-60](#e-60--una-partición-con-demasiados-tombstones) · [E-61](#e-61--una-lectura-local-cancelada-a-los-5-s) ·
  [E-62](#e-62--un-agregado-sobre-una-partición-que-no-termina) · [E-63](#e-63--un-nodo-vivo-que-no-acepta-clientes)
- **CouchDB** — [E-09](#e-09--couchdb-repite-un-error-cada-cinco-segundos) ·
  [E-64](#e-64--un-guardado-con-una-revisión-vieja) · [E-65](#e-65--la-tableta-abierta-por-otro-proceso) ·
  [E-67](#e-67--un-antepasado-que-la-compactación-ya-borró)
- **CockroachDB** — [E-10](#e-10--cockroach-demo-corta-la-conexión-desde-tu-máquina) ·
  [E-11](#e-11--cockroachdb-no-deja-leer-crdb_internal) · [E-69](#e-69--una-extensión-de-postgres-que-cockroachdb-no-tiene) ·
  [E-70](#e-70--placement-sin-la-variable-de-sesión) · [E-71](#e-71--restart-transaction-en-una-transacción-serializable) ·
  [E-72](#e-72--una-lectura-dentro-del-intervalo-de-incertidumbre) · [E-73](#e-73--explain-con-parámetros) ·
  [E-74](#e-74--sobrevivir-a-una-región-y-no-salir-de-ella) · [E-75](#e-75--la-escritura-que-llega-tarde-a-una-fila-caliente) ·
  [E-76](#e-76--un-nodo-que-se-mata-por-el-reloj) · [E-78](#e-78--un-entero-que-llega-como-texto)
- **Docker** — [E-04](#e-04--el-puerto-ya-está-ocupado) · [E-05](#e-05--el-contenedor-sale-con-137-sin-decir-nada) ·
  [E-06](#e-06--la-descarga-se-queda-colgada)
- **Node y npm** — [E-13](#e-13--node-no-ejecuta-un-enum) ·
  [E-14](#e-14--javascript-heap-out-of-memory-al-generar) ·
  [E-15](#e-15--npm-no-ejecuta-los-scripts-de-instalación) · [E-68](#e-68--un-proceso-que-termina-sin-terminar) ·
  [E-82](#e-82--fetch-que-tumba-el-proceso-con-el-servidor-caído)
- [Cuándo usar qué](#-cuándo-usar-qué) · [Ejercicios](#-ejercicios-6)

---

## 🍃 MongoDB

### E-01 — Una transacción en un Mongo sin replica set

```text
MongoServerError: Transaction numbers are only allowed on a replica set member or mongos (code 20, IllegalOperation)
```

- **Motor y versión:** MongoDB 8.0.20 `mongo@sha256:098862b1339f…`
- **Apareció en:** Fase 00, ejecutando una transacción multi-documento contra un nodo solo
  (29/09/2026)
- **Qué lo provoca:** las transacciones multi-documento existen desde la 4.0, pero **solo en un
  replica set o a través de `mongos`**. Un `mongod` suelto no las admite.
- **Cómo confirmas que es este y no otro:** `rs.status()` en `mongosh` responde
  `MongoServerError: not running with --replSet` (verificado el 29/09/2026).
- **Cómo se sale:** arrancar con `--replSet` e iniciar el replica set, aunque sea de un nodo. El
  `compose.yaml` del curso ya lo hace ([`a02`](a02-compose-de-la-ruta.md)).
- **Si la salida correcta es no salir:** si tu sistema necesita muchas transacciones que cruzan
  documentos, la pregunta no es cómo activarlas sino por qué la frontera transaccional cruza
  agregados ([Fase 04](04-documental-romper-y-medir.md)).

### E-02 — MongoDB 8 no arranca y habla del kernel

```text
{"t":{"$date":"2026-09-29T06:44:34.795Z"},"s":"F","c":"CONTROL","id":12257600,"ctx":"main","msg":"MongoDB cannot start: Linux kernel versions 6.19 and newer has a known incompatibility with this version of MongoDB. See https://jira.mongodb.org/browse/SERVER-121912 for more information."}
```

- **Motor y versión:** MongoDB 8.0.32 (`mongo:8.0`), sobre Docker Desktop 29.8.0 con kernel
  `7.0.12-linuxkit`
- **Apareció en:** la sesión de verificación de laboratorio, levantando `documental`
  (29/09/2026)
- **Qué lo provoca:** desde la 8.0.21, `mongod` se niega a arrancar sobre los kernels 6.19 a
  7.0.13, que rompieron la caché por CPU de su TCMalloc (`rseq`).
- **Cómo confirmas que es este y no otro:** `docker info --format '{{.KernelVersion}}'` devuelve
  una versión en ese rango, y el contenedor sale al arrancar.
- **Cómo se sale:** fijar la 8.0.20, que es anterior a la protección —y está expuesta al fallo
  de fondo—, o actualizar a un kernel 7.0.14 o posterior. La tabla completa y la prueba de carga
  están en [`a02`](a02-compose-de-la-ruta.md).
- **Si la salida correcta es no salir:** en producción, la 8.0.20 sobre ese kernel no es una
  salida: es cambiar de kernel.

### E-03 — El driver de Mongo se cuelga hasta el timeout

```text
MongoServerSelectionError: Server selection timed out after 8000 ms
```

- **Motor y versión:** MongoDB 8.0.20, driver `mongodb` 7.7.0
- **Apareció en:** [`a06`](a06-lenguajes-y-drivers.md), conectando desde el host sin
  `directConnection` (29/09/2026)
- **Qué lo provoca:** el replica set se anuncia como `localhost:27017`, su dirección dentro del
  contenedor. El driver descubre esa dirección e intenta seguirla hasta tu `localhost:27017`,
  donde el laboratorio no está (o donde hay otro Mongo).
- **Cómo confirmas que es este y no otro:** con `directConnection=true` en la URL, conecta al
  instante.
- **Cómo se sale:** `mongodb://localhost:27018/?directConnection=true`.


### E-20 — Un índice compuesto sobre dos arrays

```text
MongoServerError: Index build failed: … :: caused by :: cannot index parallel arrays [assemblies] [installedParts] (code 171, CannotIndexParallelArrays)
```

- **Motor y versión:** MongoDB 8.0.20 `mongo@sha256:098862b1339f…`
- **Apareció en:** Fase 03, indexando `installedParts.serialNumber` y `assemblies.assemblyId` juntos
  (29/09/2026)
- **Qué lo provoca:** un índice compuesto no puede tener dos campos que sean arrays en el mismo
  documento: el número de entradas sería el producto de los dos.
- **Cómo confirmas que es este y no otro:** `isMultiKey` y `multiKeyPaths` en el `explain` de cada
  índice por separado.
- **Cómo se sale:** dos índices separados, o un modelo donde la consulta no cruce dos arrays.
- **Si la salida correcta es no salir:** si la consulta necesita de verdad cruzar los dos arrays,
  el agregado no es la unidad de esa lectura.

### E-21 — Una función de fechas sobre un texto

```text
MongoServerError: PlanExecutor error during aggregation :: caused by :: $dateTrunc requires 'date' to be a date, but got string (code 5439012, Location5439012)
```

- **Motor y versión:** MongoDB 8.0.20
- **Apareció en:** Fase 03, agrupando órdenes por mes con fechas guardadas como texto (29/09/2026)
- **Qué lo provoca:** el campo es `string`; las funciones de fechas necesitan `Date`.
- **Cómo confirmas que es este y no otro:** `{ $type: "$openedAt" }` en una proyección devuelve
  `string`.
- **Cómo se sale:** `$toDate` en la consulta, o convertir en el cargador, que es donde vive el
  esquema.

### E-22 — El documento que no cabe (intento grande)

```text
MongoServerError: BSONObj size: 16898785 (0x101DAE1) is invalid. Size must be between 0 and 16793600(16MB) First element: _id: "HC-10011" (code 10334)
```

- **Motor y versión:** MongoDB 8.0.20
- **Apareció en:** Fase 04, embebiendo lecturas de vuelo en una ficha, de mil en mil (29/09/2026)
- **Qué lo provoca:** el documento resultante supera el límite. El 16 793 600 del mensaje es 16 MiB
  más un margen interno; el límite de un documento es 16 777 216.
- **Cómo confirmas que es este y no otro:** `$bsonSize` del documento, cerca de 16 777 216.
- **Cómo se sale:** sacar del documento lo que crece sin cota (patrón bucket, colección aparte).
- **Si la salida correcta es no salir:** siempre es un cambio de modelo; el límite no se configura.

### E-23 — El documento que no cabe (una sola escritura de más)

```text
MongoServerError: Resulting document after update is larger than 16777216 (code 10334)
```

- **Motor y versión:** MongoDB 8.0.20
- **Apareció en:** Fase 04, con la ficha en 90 344 lecturas y una más (29/09/2026)
- **Qué lo provoca:** el mismo límite que E-22, con el mensaje que da un intento pequeño.
- **Cómo confirmas que es este y no otro:** el mismo código, 10334.
- **Cómo se sale:** como E-22.

### E-24 — Dos transacciones sobre el mismo documento

```text
MongoServerError: Caused by :: Write conflict during plan execution and yielding is disabled. :: Please retry your operation or multi-document transaction. (code 112, WriteConflict)
```

- **Motor y versión:** MongoDB 8.0.20, replica set de un nodo
- **Apareció en:** Fase 04, dos técnicos actualizando piezas distintas de la misma ficha
  (29/09/2026)
- **Qué lo provoca:** Mongo detecta los conflictos por documento, no por campo. Lleva la etiqueta
  `TransientTransactionError`.
- **Cómo confirmas que es este y no otro:** las dos escrituras tocan el mismo `_id`.
- **Cómo se sale:** reintentar (`withTransaction` lo hace solo).
- **Si la salida correcta es no salir:** si choca a menudo, lo que dos escritores tocan a la vez no
  debería vivir en el mismo documento.

### E-31 — Una clave duplicada contra un índice único

```text
MongoServerError: E11000 duplicate key error collection: condor_boss.workOrder index: pirepId_1 dup key: { pirepId: "PR-BOSS-1" } (code 11000)
```

- **Motor y versión:** MongoDB 8.0.20 `mongo@sha256:098862b1339f…`
- **Apareció en:** Fase 06, en la verificación del boss del Bloque I (29/09/2026)
- **Qué lo provoca:** una inserción con un valor que ya existe en un campo con índice único. Nombra la
  colección, el índice y el valor repetido.
- **Cómo confirmas que es este y no otro:** el código 11000 y el nombre del índice en el mensaje.
- **Cómo se sale:** tratarlo como un resultado, no como un fallo: quien lo recibe perdió la carrera, y
  la orden ya existe.
- **Si la salida correcta es no salir:** no quites el índice para que el error desaparezca: el error
  es el índice haciendo su trabajo.

---

## 🔑 Valkey

### E-26 — Un comando sobre una clave de otro tipo

```text
WRONGTYPE Operation against a key holding the wrong kind of value
```

- **Motor y versión:** Valkey 9.1.2 `valkey/valkey@sha256:418652cfb58e…`
- **Apareció en:** Fase 05, un `HGET` sobre la reserva de un foso, que es un string (29/09/2026)
- **Qué lo provoca:** cada clave tiene un tipo —string, hash, set, sorted set, stream— y cada comando
  opera sobre uno. Es lo único que Valkey comprueba de un valor.
- **Cómo confirmas que es este y no otro:** `TYPE <clave>`.
- **Cómo se sale:** casi siempre, dos partes del código usan el mismo prefijo para cosas distintas:
  separar los prefijos.

### E-27 — Leer de un grupo de consumidores que no existe

```text
NOGROUP No such key 'events:workOrder' or consumer group 'planeacion' in XREADGROUP with GROUP option
```

- **Motor y versión:** Valkey 9.1.2
- **Apareció en:** Fase 05, `XREADGROUP` antes de `XGROUP CREATE` (29/09/2026)
- **Qué lo provoca:** falta el stream, el grupo o los dos.
- **Cómo confirmas que es este y no otro:** `XINFO GROUPS <stream>`.
- **Cómo se sale:** crear el grupo antes de leer, con `MKSTREAM` si el stream puede no existir.

### E-28 — Crear un grupo que ya existe

```text
BUSYGROUP Consumer Group name already exists
```

- **Motor y versión:** Valkey 9.1.2
- **Apareció en:** Fase 05, `XGROUP CREATE` repetido (29/09/2026)
- **Qué lo provoca:** el servicio crea su grupo en cada arranque.
- **Cómo confirmas que es este y no otro:** el grupo aparece en `XINFO GROUPS`.
- **Cómo se sale:** capturar este mensaje y seguir: es inofensivo.

### E-29 — Un comando de un módulo que no está cargado

```text
ERR unknown command 'FT.SEARCH', with args beginning with: 'idx' '*'
```

- **Motor y versión:** Valkey 9.1.2, imagen sin módulos
- **Apareció en:** Fase 05, buscando sesiones por contenido (29/09/2026)
- **Qué lo provoca:** los comandos de búsqueda son de un módulo; la imagen del curso solo trae `lua`.
- **Cómo confirmas que es este y no otro:** `MODULE LIST`.
- **Si la salida correcta es no salir:** si la pregunta necesita buscar por contenido, no es de esta
  familia ([Fase 05](05-clave-valor-levantar-y-modelar.md), sección 6.1).

### E-30 — La memoria llena con `noeviction`

```text
OOM command not allowed when used memory > 'maxmemory'.
```

- **Motor y versión:** Valkey 9.1.2, `maxmemory 16mb`, `maxmemory-policy noeviction`
- **Apareció en:** Fase 06, en el punto de rotura, en torno a la sesión 100 000 (29/09/2026)
- **Qué lo provoca:** una escritura que necesita memoria con la instancia en su límite. Las lecturas
  siguen funcionando.
- **Cómo confirmas que es este y no otro:** `INFO memory` (`used_memory` contra `maxmemory`) y
  `CONFIG GET maxmemory-policy`.
- **Cómo se sale:** decidir qué no debería estar en esa instancia. Subir el límite aplaza la decisión.
- **Si la salida correcta es no salir:** este error es la rotura buena. Con `allkeys-lru` no aparece, y
  en su lugar se borran claves sin aviso (Fase 06, sección 5).

---

## 🐘 PostgreSQL

### E-16 — Un lote hijo llega antes que su tabla padre

```text
error: insert or update on table "work_order_technician" violates foreign key constraint "work_order_technician_work_order_id_fkey"
detail: 'Key (work_order_id)=(WO-0000001) is not present in table "work_order".'
```

- **Motor y versión:** PostgreSQL 18.6, driver `pg` 8.23.0
- **Apareció en:** Fase 01, en la primera versión del cargador por lotes (29/09/2026)
- **Qué lo provoca:** cada orden tiene varios técnicos, así que el lote de la tabla hija se llena
  antes que el de la tabla padre y se envía primero.
- **Cómo confirmas que es este y no otro:** el `detail` nombra una clave que sí está en el dataset
  pero todavía no en la tabla padre.
- **Cómo se sale:** cuando se llena el lote de cualquier tabla, vaciar todas en orden de
  dependencia (así lo hace `load.ts`).

### E-17 — `ECONNREFUSED` al conectar con Postgres

```text
AggregateError [ECONNREFUSED]:
  code: 'ECONNREFUSED',
  [errors]: [
    Error: connect ECONNREFUSED ::1:15432
```

- **Motor y versión:** PostgreSQL 18.6, driver `pg` 8.23.0
- **Apareció en:** Fase 01, cargando con el perfil `base` apagado (29/09/2026)
- **Qué lo provoca:** no hay nada escuchando en ese puerto de tu máquina.
- **Cómo confirmas que es este y no otro:** `docker compose ps` desde `src/lab`.
- **Cómo se sale:** `docker compose --profile base up -d --wait`, o revisar `BASE_PORT` si lo
  cambiaste en `.env`.

### E-18 — El dataset no coincide con su manifiesto

```text
Error: workOrder.ndjson: el hash no coincide con el manifiesto (0c2d14da68a3 ≠ fe139626e58b)
```

- **Herramienta:** el arnés del curso (`src/lab/harness/dataset.ts`)
- **Apareció en:** Fase 01, cargando un dataset con un solo campo cambiado (29/09/2026)
- **Qué lo provoca:** el archivo ya no es el que el generador escribió.
- **Cómo confirmas que es este y no otro:** regenera y compara el `datasetSha256` con la tabla de
  [`a05`](a05-el-dominio-de-flota.md).
- **Cómo se sale:** regenerar. **El cargador se niega a propósito:** una medición sobre otros datos
  no se compara con las del curso.

### E-19 — `pg_stat_statements` no existe

```text
ERROR:  relation "pg_stat_statements" does not exist
LINE 1: SELECT calls FROM pg_stat_statements LIMIT 1
```

- **Motor y versión:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…`
- **Apareció en:** Fase 01, al verificar su ejercicio 13 (29/09/2026)
- **Qué lo provoca:** la librería está precargada (`shared_preload_libraries`), pero la vista no
  existe hasta crear la extensión en la base.
- **Cómo confirmas que es este y no otro:** `SHOW shared_preload_libraries` sí la lista.
- **Cómo se sale:** `CREATE EXTENSION IF NOT EXISTS pg_stat_statements;` (el `schema.sql` de la
  Fase 01 lo hace).

### E-25 — `canceling statement due to lock timeout`

```text
canceling statement due to lock timeout
```

- **Motor y versión:** PostgreSQL 18.6
- **Apareció en:** Fase 04, dos transacciones sobre la misma pieza con `lock_timeout` de 2 s
  (29/09/2026)
- **Qué lo provoca:** la fila está bloqueada por otra transacción abierta, y la espera superó
  `lock_timeout`. Sin ese parámetro, la segunda transacción simplemente espera.
- **Cómo confirmas que es este y no otro:** `pg_locks` y `pg_stat_activity` muestran quién tiene la
  fila.
- **Cómo se sale:** que la primera transacción termine antes, o reintentar.

### E-35 — Postgres se queda sin memoria compartida al construir un índice

```text
psycopg.errors.DiskFull: could not resize shared memory segment "/PostgreSQL.1712005010" to 2144374272 bytes: No space left on device
```

- **Motor y versión:** PostgreSQL 18.6 con pgvector 0.8.6, en contenedor
- **Apareció en:** Fase 16, construyendo el HNSW de un millón de vectores con `maintenance_work_mem` de
  2 GB (30/09/2026)
- **Qué lo provoca:** la construcción en paralelo comparte el grafo en `/dev/shm`, y Docker le da 64 MB
  por defecto a cada contenedor. No es el disco, aunque lo diga.
- **Cómo confirmas que es este y no otro:** `df -h /dev/shm` dentro del contenedor dice `64M`.
- **Cómo se sale:** `shm_size` en el compose (el del curso lleva 2560m, [`a02`](a02-compose-de-la-ruta.md)),
  o `max_parallel_maintenance_workers = 0` para construir sin paralelismo.
- **Otra aparición:** [Fase 10](10-series-romper-y-medir.md), en el servicio `series`, que no lleva
  `shm_size`: una consulta paralela de cinco años sobre 7573 chunks pidió 73 551 744 bytes (07/10/2026).
  Ahí la salida es `SET max_parallel_workers_per_gather = 0` o `shm_size` también en `series`.
- **Y otra:** [Fase 25](25-poliglota-la-factura.md), al restaurar la base `postgres` con `pg_restore -j 4` y
  `maintenance_work_mem` de 2 GB: los dos índices HNSW se construyeron a la vez, cada uno pidió 2 144 374 752 bytes, y
  los 2560 MB de `shm_size` no alcanzan para dos (12/10/2026). La salida es restaurar los datos en paralelo y los
  índices de a uno (`--section=post-data` sin `-j`).

### E-46 — Una partición que ya tiene filas en la `DEFAULT`

```text
ERROR:  updated partition constraint for default partition "reading_part_default" would be violated by some row
```

- **Motor y versión:** PostgreSQL 18.6
- **Apareció en:** [Fase 10](10-series-romper-y-medir.md), creando la partición de octubre de 2026 cuando la
  `DEFAULT` ya tenía las lecturas posteriores a la ventana (07/10/2026)
- **Qué lo provoca:** Postgres no mueve filas de la `DEFAULT` a una partición nueva; se niega a crearla.
- **Cómo confirmas que es este y no otro:** `SELECT count(*) FROM <default> WHERE <rango de la partición>`.
- **Cómo se sale:** `DETACH` de la `DEFAULT`, crear la partición, mover las filas y volver a adjuntar la
  `DEFAULT`. Mejor: crear las particiones antes de que lleguen los datos.

### E-36 — El grafo HNSW no cabe en `maintenance_work_mem`

```text
NOTICE:  hnsw graph no longer fits into maintenance_work_mem after 966262 tuples
```

- **Motor y versión:** PostgreSQL 18.6 con pgvector 0.8.6
- **Apareció en:** Fase 16, con 2 GB para un millón de vectores de 384 dimensiones (30/09/2026)
- **Qué lo provoca:** pgvector construye el grafo en memoria mientras cabe; lo que queda lo inserta con
  el grafo en disco, más despacio.
- **Cómo confirmas que es este y no otro:** es un `NOTICE`, no un error: el índice se termina.
- **Cómo se sale:** subir `maintenance_work_mem` solo en la sesión que construye.

### E-56 — Una consulta recursiva que no termina

```text
57014 · canceling statement due to statement timeout
```

- **Motor y versión:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…`, `statement_timeout` de 120 s
- **Apareció en:** [Fase 14](14-grafos-romper-y-medir.md), con `WITH RECURSIVE … UNION ALL` sin `CYCLE` ni
  límite de profundidad sobre las estadías como aristas, y con `UNION ALL` + `CYCLE` a profundidad 6
  (07/10/2026)
- **Qué lo provoca:** sobre un grafo con ciclos, `UNION ALL` enumera caminos; sin `CYCLE` ni límite, vuelve
  por los ciclos para siempre, y con `CYCLE` los caminos sin repetir crecen más rápido que el tiempo que hay.
- **Cómo confirmas que es este y no otro:** el código `57014` es el de cualquier cancelación por tiempo; el
  `EXPLAIN ANALYZE` de la misma consulta a menos profundidad muestra el nodo `Recursive Union` con decenas de
  veces más filas que nodos distintos.
- **Cómo se sale:** `UNION` sin `ALL` si la pregunta es por nodos alcanzables; si son caminos, límite de
  profundidad y `LIMIT`. Sin `statement_timeout`, el tope lo pone el disco: pon también `temp_file_limit` en
  la sesión que explora.

### E-66 — Una cola que choca con una restricción única

```text
duplicate key value violates unique constraint "one_install_per_position"
```

- **Motor y versión:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…`; driver `pg` 8.23.0
- **Apareció en:** [Fase 19](19-offline-levantar-y-modelar.md), vaciando en el servidor la cola de una tableta
  que estuvo sin señal: dos técnicos registraron dos bombas distintas en la misma posición de la misma orden
  (11/10/2026)
- **Qué lo provoca:** la regla del dominio —un serial instalado por posición y orden— está declarada como
  `UNIQUE (work_order_id, position)`, y la segunda instalación que llega la viola.
- **Cómo confirmas que es este y no otro:** con `\set VERBOSITY verbose`, `psql` muestra el código `23505` y la
  clave: `DETAIL:  Key (work_order_id, "position")=(WO-0009951, fuel-pump-1) already exists.` El nombre de la
  restricción dice qué regla fue, y la fila que llegó primero está en `offline.part_swap`.
- **Cómo se sale:** no se reintenta: se le muestran a una persona las dos versiones, la guardada y la
  rechazada. Ojo con quién perdió: la restricción rechaza **al segundo que llega**, no al que trabajó después.

### E-77 — La réplica que perdió al primario

```text
FATAL:  streaming replication receiver "walreceiver" could not connect to the primary server: could not translate host name "primario" to address: Name or service not known
LOG:  waiting for WAL to become available at 0/4993508
```

- **Motor y versión:** PostgreSQL 18.6 `pgvector/pgvector@sha256:2ba9ca5f2e7d…`, réplica por *streaming*
  (`compose.replica.yaml`)
- **Apareció en:** [Fase 22](22-newsql-romper-y-medir.md), con el enlace entre el primario y la réplica cortado, y
  otra vez al reponerlo sin el alias del primario en la red (`partition.ts`, 11/10/2026)
- **Qué lo provoca:** la réplica no llega al primario. **Las lecturas no fallan**: la réplica sigue respondiendo con lo
  último que aplicó, y `pg_stat_wal_receiver` dijo `streaming` hasta 59 s después del corte (el
  `wal_receiver_timeout` es de 60 s). Este mensaje solo está en el log.
- **Cómo confirmas que es este y no otro:** se repite cada 5 s en el log de la réplica; `pg_stat_wal_receiver` vuelve
  sin filas.
- **Cómo se sale:** reponer el enlace. Al reconectar un contenedor a mano, con su nombre:
  `docker network connect --alias primario …`; sin el alias, el error sigue aunque la red esté de vuelta.

### E-79 — `SERIALIZABLE` que rechaza una suma

```text
error: could not serialize access due to concurrent update
code: 40001
```

- **Motor y versión:** PostgreSQL 18.6
- **Apareció en:** [Fase 22](22-newsql-romper-y-medir.md), con 3 trabajadores sumando horas al mismo motor con
  `UPDATE … SET hours_since_new = hours_since_new + 1` en `SERIALIZABLE`, sin reintento (`contention.ts`, 11/10/2026)
- **Qué lo provoca:** en `SERIALIZABLE` y `REPEATABLE READ`, Postgres no vuelve a leer una fila que otra transacción
  cambió y confirmó: aborta la segunda, aunque sea una sola sentencia. CockroachDB, con la misma sentencia, la
  reintenta solo en el servidor.
- **Cómo confirmas que es este y no otro:** `40001` y `concurrent update`; el de *write skew* dice `read/write
  dependencies` (E-71).
- **Cómo se sale:** reintentar la transacción (`withRetry`), o correr esa sentencia en `READ COMMITTED`, donde Postgres
  espera el candado y vuelve a evaluar la fila: ahí la suma es correcta.

### E-80 — El slot que ya tiene dueño

```text
error: replication slot "costura" is active for PID 7923
code: 55006
```

- **Motor y versión:** PostgreSQL 18.6, `wal_level=logical`
- **Apareció en:** [Fase 24](24-poliglota-la-costura.md), en `race.ts`, que miraba el slot con
  `pg_logical_slot_peek_changes` para saber si el relevo había terminado, mientras el relevo lo leía (12/10/2026)
- **Qué lo provoca:** un slot lógico tiene un solo consumidor a la vez; el que lo está leyendo lo tiene tomado, y
  cualquier otra lectura o avance falla, aunque sea un `peek` que no consume nada.
- **Cómo confirmas que es este y no otro:** `active` y `active_pid` en `pg_replication_slots`, y ese PID en
  `pg_stat_activity`.
- **Cómo se sale:** no mirar el slot desde un segundo proceso; para saber si el relevo va al día, comparar el resultado
  en el derivado o leer `confirmed_flush_lsn` en `pg_replication_slots`, que no toma el slot.

### E-81 — Un slot lógico que no deja arrancar

```text
FATAL:  logical replication slot "costura" exists, but "wal_level" < "logical"
HINT:  Change "wal_level" to be "logical" or higher.
LOG:  shutting down due to startup process failure
```

- **Motor y versión:** PostgreSQL 18.6
- **Apareció en:** [Fase 24](24-poliglota-la-costura.md), al volver a levantar `base` con el compose de siempre con el
  slot del CDC todavía creado; provocado a propósito para escribir esta entrada (12/10/2026)
- **Qué lo provoca:** el slot se creó con `wal_level=logical` (`compose.costura.yaml`), y Postgres se niega a arrancar
  con un nivel menor mientras exista. El contenedor sale con código 1 y el *healthcheck* nunca pasa.
- **Cómo confirmas que es este y no otro:** `docker logs condor-lab-base-1` dice el nombre del slot.
- **Cómo se sale:** levantar otra vez con `compose.costura.yaml`, borrar el slot (`setup.ts --drop` o
  `pg_drop_replication_slot`) y volver al compose de siempre ([`a02`](a02-compose-de-la-ruta.md)).

### E-83 — Crear un slot lógico sin el WAL lógico

```text
error: logical decoding requires "wal_level" >= "logical"
code: 55000
```

- **Motor y versión:** PostgreSQL 18.6, con `wal_level=replica`
- **Apareció en:** [Fase 24](24-poliglota-la-costura.md), al correr `setup.ts` con `base` levantado sin
  `compose.costura.yaml` (12/10/2026)
- **Qué lo provoca:** `pg_create_logical_replication_slot` necesita que el WAL lleve lo que la decodificación lógica
  lee, y eso solo pasa con `wal_level=logical`, que se fija al arrancar.
- **Cómo confirmas que es este y no otro:** `SHOW wal_level` devuelve `replica`.
- **Cómo se sale:** levantar `base` con `compose.costura.yaml` sumado; cambiar el nivel reinicia Postgres.

---

## 🐳 Docker

### E-04 — El puerto ya está ocupado

```text
Error response from daemon: failed to set up container networking: driver failed programming external connectivity on endpoint condor-lab-base-1 (566dd80ea4f4…): Bind for 0.0.0.0:5432 failed: port is already allocated
```

- **Motor y versión:** Docker Desktop 29.8.0, Compose v5.5.1
- **Apareció en:** [`a01`](a01-laboratorio-contenerizado.md), levantando `base` con otro Postgres
  en el 5432 (29/09/2026)
- **Qué lo provoca:** otro proceso o contenedor ya publica ese puerto en tu máquina.
- **Cómo confirmas que es este y no otro:** `docker ps --filter publish=5432`; si no sale nada,
  `lsof -nP -iTCP:5432 -sTCP:LISTEN`.
- **Cómo se sale:** cambiar el lado del host del mapeo desde `.env`
  ([`a02`](a02-compose-de-la-ruta.md)). El curso ya usa puertos desplazados por esto.

### E-05 — El contenedor sale con 137 sin decir nada

```text
NAME                    STATUS
condor-lab-busqueda-1   Exited (137) 1 second ago
```

- **Motor y versión:** OpenSearch 3.8.0, heap de 512 MB con `mem_limit: 600m`
- **Apareció en:** [`a01`](a01-laboratorio-contenerizado.md), probando límites de memoria
  (29/09/2026)
- **Qué lo provoca:** el kernel mata el proceso por falta de memoria. En la JVM, el heap no es
  toda la memoria: hay memoria fuera del heap que el límite también cuenta.
- **Cómo confirmas que es este y no otro:**
  `docker inspect <contenedor> --format '{{.State.OOMKilled}}'` devuelve `true`. **137 más
  `OOMKilled` es la firma.** Si el límite es de la VM y no del contenedor, puede pasar aunque
  `up --wait` haya devuelto 0 ([`a02`](a02-compose-de-la-ruta.md)).
- **Cómo se sale:** subir el límite (OpenSearch con heap de 512 MB necesita unos 1200 MB) o
  bajar lo que hay arriba a la vez.

### E-06 — La descarga se queda colgada

```text
failed to copy: httpReadSeeker: failed open: failed to do request: Get "https://production.cloudfront.docker.com/registry-v2/…": net/http: timeout awaiting response headers
```

- **Motor y versión:** Docker Desktop 29.8.0, descargando `couchdb:3.5.2`
- **Apareció en:** la sesión de verificación de laboratorio (29/09/2026)
- **Qué lo provoca:** la red o el CDN de Docker Hub. No es el motor.
- **Cómo confirmas que es este y no otro:** `docker compose --profile <familia> pull` por
  separado reproduce el fallo sin arrancar nada.
- **Cómo se sale:** reintentar el `pull`. Y en general, `pull` antes de `up`, para que un fallo de
  red no parezca un motor que no arranca.

---

## ⏱️ TimescaleDB

### E-07 — Un error de TimescaleDB en el primer arranque

```text
ERROR:  background worker "TimescaleDB Background Worker Scheduler for database 1" trying to connect to template database, exiting
```

- **Motor y versión:** TimescaleDB 2.30.1 sobre PostgreSQL 18 `timescale/timescaledb@sha256:9dede0e3ccc0…`
- **Apareció en:** la sesión de verificación de laboratorio, en el log del primer arranque
  (29/09/2026)
- **Qué lo provoca:** durante la inicialización, el planificador de TimescaleDB intenta conectarse
  a la base plantilla y se retira.
- **Cómo confirmas que es este y no otro:** el servicio llega a healthy igual, y el error no se
  repite después del arranque.
- **Cómo se sale:** no hay que salir: **es inocuo**. Está aquí para que nadie pierda una tarde con
  él.

### E-45 — Demasiados chunks para una transacción

```text
ERROR: out of shared memory
HINT: You might need to increase "max_locks_per_transaction".
```

- **Motor y versión:** TimescaleDB 2.30.1 sobre PostgreSQL 18.6, `max_locks_per_transaction` 128
- **Apareció en:** [Fase 10](10-series-romper-y-medir.md), con chunks de 6 horas sobre 5 M lecturas
  (7573 chunks): al insertarlas en una transacción y al hacer `DROP TABLE` (07/10/2026)
- **Qué lo provoca:** una transacción toma un candado por cada chunk (y cada índice) que toca, y la tabla
  de candados compartida tiene un tamaño fijo. No es memoria de datos.
- **Cómo confirmas que es este y no otro:** el `HINT` nombra `max_locks_per_transaction`, y
  `timescaledb_information.chunks` da miles de chunks.
- **Cómo se sale:** transacciones que toquen menos chunks (cargar por meses, borrar con `drop_chunks` por
  tandas) y chunks más grandes. Subir el parámetro mueve el borde.

### E-44 — Corregir demasiadas filas comprimidas

```text
ERROR: tuple decompression limit exceeded by operation
DETAIL: current limit: 100000, tuples decompressed: 919810
HINT: Consider increasing timescaledb.max_tuples_decompressed_per_dml_transaction or set to 0 (unlimited).
```

- **Motor y versión:** TimescaleDB 2.30.1 sobre PostgreSQL 18.6
- **Apareció en:** [Fase 09](09-series-levantar-y-modelar.md), con un `UPDATE` de marzo de 2025 en toda la
  flota sobre chunks comprimidos (07/10/2026)
- **Qué lo provoca:** modificar filas comprimidas obliga a descomprimir sus lotes enteros, y el motor
  tiene un límite por transacción para que una corrección no descomprima la historia sin querer.
- **Cómo confirmas que es este y no otro:** el `DETAIL` da las filas que habría que descomprimir: aquí
  919 810 para cambiar 839 270.
- **Cómo se sale:** filtrar por la columna de `segmentby` y en tandas, o subir el límite **solo en esa
  sesión** y recomprimir después. Si corregir es habitual, la serie no cumple la promesa de la familia
  (Fase 09, sección 8).

---

## 🔍 OpenSearch

Ver también [E-05](#e-05--el-contenedor-sale-con-137-sin-decir-nada): el límite de memoria de la JVM.

### E-47 — Un campo que el mapping no conoce

```text
{"error":{"root_cause":[{"type":"strict_dynamic_mapping_exception","reason":"mapping set to strict, dynamic introduction of [descripcion] within [_doc] is not allowed"}],"type":"strict_dynamic_mapping_exception","reason":"mapping set to strict, dynamic introduction of [descripcion] within [_doc] is not allowed"},"status":400}
```

- **Motor y versión:** OpenSearch 3.8.0
- **Apareció en:** [Fase 11](11-busqueda-levantar-y-modelar.md), indexando un documento con `descripcion`
  en un índice con `dynamic: strict` (07/10/2026)
- **Qué lo provoca:** el `mapping` es un esquema, y en modo estricto no admite campos nuevos.
- **Cómo confirmas que es este y no otro:** el mensaje nombra el campo; `GET <índice>/_mapping` no lo tiene.
- **Cómo se sale:** corregir el documento, o declarar el campo en el `mapping` si de verdad es nuevo.

### E-48 — Un campo que no puede cambiar de tipo

```text
{"error":{"root_cause":[{"type":"illegal_argument_exception","reason":"mapper [ataChapter] cannot be changed from type [integer] to [keyword]"}],"type":"illegal_argument_exception","reason":"mapper [ataChapter] cannot be changed from type [integer] to [keyword]"},"status":400}
```

- **Motor y versión:** OpenSearch 3.8.0
- **Apareció en:** [Fase 11](11-busqueda-levantar-y-modelar.md), con `PUT _mapping` sobre un campo existente
  (07/10/2026)
- **Qué lo provoca:** el tipo de un campo queda fijo en el índice: los segmentos ya escritos lo usan.
- **Cómo confirmas que es este y no otro:** el mensaje nombra el campo y los dos tipos.
- **Cómo se sale:** índice nuevo con el `mapping` corregido, carga desde la fuente y cambio de alias.

### E-49 — El cliente reintenta un `_reindex` largo

```text
TimeoutError: Request timed out
```

- **Motor y versión:** OpenSearch 3.8.0, cliente `@opensearch-project/opensearch` 3.9.0 con sus valores por
  defecto
- **Apareció en:** [Fase 11](11-busqueda-levantar-y-modelar.md), con `_reindex` de un millón y
  `wait_for_completion: true` (07/10/2026)
- **Qué lo provoca:** el cliente espera 30 s y **reintenta solo** (`attempts: 3` en el error). Cada intento
  lanza otro reindexado en el servidor: el índice destino terminó con 622 208 documentos reescritos de más.
- **Cómo confirmas que es este y no otro:** `GET _tasks?actions=*reindex` muestra tareas que siguen corriendo
  después del error, y `_cat/indices` muestra `docs.deleted` en el destino.
- **Cómo se sale:** `wait_for_completion: false` y consultar la tarea, o `maxRetries: 0` y un
  `requestTimeout` largo para esa operación.

### E-50 — `Header overflow` al esperar un `_reindex`

```text
ConnectionError: Parse Error: Header overflow
```

- **Motor y versión:** OpenSearch 3.8.0, Node 24.21.0, cliente 3.9.0
- **Apareció en:** [Fase 11](11-busqueda-levantar-y-modelar.md), con `_reindex` síncrono de un millón y la
  espera larga ya configurada (07/10/2026)
- **Qué lo provoca:** la respuesta síncrona trae una cabecera `TASK_RESOURCE_USAGE` por cada lote del
  recorrido; con un millón supera el límite de cabeceras de Node (16 kB).
- **Cómo confirmas que es este y no otro:** `curl -D -` sobre un `_reindex` pequeño muestra una línea
  `TASK_RESOURCE_USAGE` por lote.
- **Cómo se sale:** lanzar el `_reindex` como tarea (`wait_for_completion: false`) y consultar `_tasks`.

### E-51 — El índice cerrado por disco lleno

```text
429 cluster_block_exception: index [part_catalog] blocked by: [TOO_MANY_REQUESTS/12/disk usage exceeded flood-stage watermark, index has read-only-allow-delete block];
```

- **Motor y versión:** OpenSearch 3.8.0
- **Apareció en:** [Fase 12](12-busqueda-romper-y-medir.md), con los umbrales de disco bajados por debajo
  del uso real (07/10/2026)
- **Qué lo provoca:** el disco del nodo pasó el umbral de inundación (`flood_stage`) y el motor puso los
  índices en solo lectura con borrado permitido.
- **Cómo confirmas que es este y no otro:** `GET <índice>/_settings` muestra
  `index.blocks.read_only_allow_delete: true`; `_cat/allocation` el uso de disco. **No es un límite de tasa**
  aunque responda 429: un cliente que reintenta los 429 va a reintentar contra el disco lleno.
- **Cómo se sale:** liberar disco (documentos borrados sin fusionar, índices viejos de una reconstrucción) o
  subir el umbral; en esta versión el bloqueo se levantó solo cuando el disco volvió por debajo del umbral alto.

### E-52 — El intervalo de chequeo de disco tiene mínimo

```text
illegal_argument_exception: [illegal_argument_exception] Reason: failed to parse value [5s] for setting [cluster.info.update.interval], must be >= [10s]
```

- **Motor y versión:** OpenSearch 3.8.0
- **Apareció en:** [Fase 12](12-busqueda-romper-y-medir.md), preparando la prueba de disco lleno (07/10/2026)
- **Qué lo provoca:** el motor no mira el disco más seguido que cada 10 s.
- **Cómo confirmas que es este y no otro:** el mensaje da el mínimo.
- **Cómo se sale:** 10 s o más. Y contarlo: un disco que se llena tarda al menos eso en notarse.

---

## 🧬 Qdrant

### E-12 — Qdrant avisa que puede perder los datos

```text
WARN qdrant: There is a potential issue with the filesystem for storage path ./storage. Details: Container filesystem detected - storage might be lost with container re-creation
```

- **Motor y versión:** Qdrant 1.19.1 `qdrant/qdrant@sha256:12364fe851b9…`
- **Apareció en:** la sesión de verificación de laboratorio, sin volumen montado (29/09/2026)
- **Qué lo provoca:** el almacenamiento está en el sistema de archivos del contenedor, que se
  pierde al recrearlo.
- **Cómo confirmas que es este y no otro:** revisa los montajes del contenedor con
  `docker inspect --format '{{json .Mounts}}' <contenedor>` y busca `/qdrant/storage`.
- **Cómo se sale:** montar un volumen en `/qdrant/storage`, como hace el `compose.yaml` del curso.

### E-32 — Un vector de otra dimensión

```text
Error: Bad Request
```

y, en `e.data.status.error` del mismo error:

```text
Wrong input: Vector dimension error: expected dim: 384, got 3
```

- **Motor y versión:** Qdrant 1.19.1, cliente `@qdrant/js-client-rest` 1.19.0
- **Apareció en:** Fase 15, consultando con un vector de prueba (30/09/2026)
- **Qué lo provoca:** el vector de la consulta no tiene la dimensión de la colección. Casi siempre es
  otro modelo, o el vector de otra colección.
- **Cómo confirmas que es este y no otro:** **el `e.message` del cliente de TypeScript solo dice `Bad
  Request`**; el mensaje útil está en `e.data`. Con `curl` sale entero.
- **Cómo se sale:** embeber la consulta con el mismo modelo y revisión que la colección.

### E-33 — Un umbral por debajo del mínimo

```text
Unexpected Response: 422 (Unprocessable Entity)
Raw response content:
b'{"status":{"error":"Validation error in JSON body: [hnsw_config.full_scan_threshold: value 1 invalid, must be 10 or larger]"},"time":0.0}'
```

- **Motor y versión:** Qdrant 1.19.1, cliente `qdrant-client` 1.19.1 (Python)
- **Apareció en:** Fase 15, intentando forzar el HNSW con 10 000 puntos (30/09/2026)
- **Qué lo provoca:** `full_scan_threshold` e `indexing_threshold` se expresan en kB y tienen mínimo.
- **Cómo confirmas que es este y no otro:** el mensaje nombra el campo y el mínimo.
- **Cómo se sale:** 10 kB, que es lo más bajo que acepta.

### E-34 — Una colección que no existe

```text
Error: Not Found
```

y, en `e.data.status.error`:

```text
Not found: Collection `pireps` doesn't exist!
```

- **Motor y versión:** Qdrant 1.19.1
- **Apareció en:** Fase 15, con el nombre de la colección mal escrito (30/09/2026)
- **Cómo confirmas que es este y no otro:** `GET /collections` lista las que hay.
- **Cómo se sale:** el nombre exacto; las colecciones no se crean al escribir en ellas.

### E-37 — Un lote más grande de lo que acepta la API

```text
Unexpected Response: 400 (Bad Request)
Raw response content:
b'{"status":{"error":"JSON payload (40013689 bytes) is larger than allowed (limit: 33554432 bytes)."},"time":0.0}'
```

- **Motor y versión:** Qdrant 1.19.1, cliente `qdrant-client` 1.19.1
- **Apareció en:** Fase 16, cargando el millón en lotes de 5000 vectores (30/09/2026)
- **Qué lo provoca:** el cuerpo de una petición HTTP tiene un tope de 32 MiB, y 5000 vectores de 384
  números en JSON lo pasan.
- **Cómo confirmas que es este y no otro:** el mensaje da los dos tamaños.
- **Cómo se sale:** lotes más pequeños (el curso usa 1000), o gRPC.

---

## 🦆 DuckDB

### E-08 — DuckDB no deja escribir a un segundo proceso

```text
IOException: IO Error: Could not set lock on file "…/condor.duckdb": Conflicting lock is held in …/python3.13 (PID 63261) by user oskar. See also https://duckdb.org/docs/stable/connect/concurrency
```

- **Motor y versión:** DuckDB 1.5.6, desde Python 3.13
- **Apareció en:** la sesión de verificación de laboratorio, abriendo el mismo archivo desde un
  segundo proceso (29/09/2026)
- **Qué lo provoca:** DuckDB admite **un solo proceso escritor** por archivo, y lo asegura con un
  candado del sistema operativo.
- **Cómo confirmas que es este y no otro:** el mensaje nombra el PID del proceso que tiene el
  candado.
- **Cómo se sale:** que un solo proceso escriba; los demás, en solo lectura o a través de él.
- **Si la salida correcta es no salir:** si necesitas varios escritores concurrentes, no es tu
  familia: es el punto de rotura de la [Fase 08](08-analitico-romper-y-medir.md), que midió además que
  **un lector en `read_only` tampoco abre** mientras otro proceso tiene la base abierta para escribir
  (07/10/2026).

### E-38 — Dos escritores sobre la misma fila

```text
TransactionContext Error: Conflict on update!
```

- **Motor y versión:** DuckDB 1.5.6, desde Python 3.13
- **Apareció en:** [Fase 07](07-analitico-levantar-y-modelar.md), con cuatro conexiones del mismo
  proceso actualizando contadores de minutos por aeronave (07/10/2026): entre 272 y 403 de 8000
  `UPDATE` fallaron
- **Qué lo provoca:** DuckDB no pone candados de fila; usa control optimista, y si dos transacciones
  tocaron la misma fila, la segunda falla al escribir. Postgres, en el mismo caso, hace esperar a la
  segunda.
- **Cómo confirmas que es este y no otro:** con una sola conexión no aparece nunca, y su frecuencia
  cambia de corrida en corrida.
- **Cómo se sale:** reintentar la transacción entera, o cambiar el modelo: eventos que solo se
  insertan y una suma al leer (Fase 07, sección 8).

### E-39 — El nombre de la columna no es el del archivo

```text
Binder Error: Referenced column "egt_c" not found in FROM clause!
Candidate bindings: "egtC", "flightId"
```

- **Motor y versión:** DuckDB 1.5.6
- **Apareció en:** [Fase 07](07-analitico-levantar-y-modelar.md), consultando el NDJSON del
  generador con el nombre de la columna de la tabla (07/10/2026)
- **Qué lo provoca:** el archivo trae los nombres del generador en `camelCase`; la tabla los tiene en
  `snake_case` ([`a08`](a08-diccionario-y-glosario.md)).
- **Cómo confirmas que es este y no otro:** el mensaje lista los nombres candidatos del archivo.
- **Cómo se sale:** usar los del archivo, o renombrar al leer (`egtC AS egt_c`), como hace `build.py`.

### E-40 — Escribir en una base abierta en solo lectura

```text
_duckdb.InvalidInputException: Invalid Input Error: Cannot execute statement of type "INSERT" on database "condor" which is attached in read-only mode!
```

- **Motor y versión:** DuckDB 1.5.6, desde Python 3.13
- **Apareció en:** [`a03`](a03-clis-de-los-motores.md), insertando en `condor.duckdb` abierta con
  `read_only=True` (07/10/2026)
- **Qué lo provoca:** la conexión es de solo lectura, que es lo que permite que varios procesos lean
  el mismo archivo a la vez.
- **Cómo confirmas que es este y no otro:** el mensaje nombra la base y el modo.
- **Cómo se sale:** escribir desde el único proceso que abre la base en escritura, o en otra base.

### E-41 — Una columna generada después de crear la tabla

```text
Parser Error: Adding generated columns after table creation is not supported yet
```

- **Motor y versión:** DuckDB 1.5.6
- **Apareció en:** [Fase 08](08-analitico-romper-y-medir.md), añadiendo el margen de EGT como columna
  virtual a `reading_x10` (07/10/2026)
- **Qué lo provoca:** DuckDB solo admite columnas generadas en el `CREATE TABLE`.
- **Cómo confirmas que es este y no otro:** el `ALTER TABLE` lleva `GENERATED ALWAYS AS`.
- **Cómo se sale:** una vista con la expresión, o recrear la tabla con la columna generada.

### E-42 — Sin memoria con muchos hilos

```text
Out of Memory Error: failed to pin block of size 256.0 KiB (122.3 MiB/122.0 MiB used)
```

- **Motor y versión:** DuckDB 1.5.6, `memory_limit` de 128 MB y 8 hilos
- **Apareció en:** [Fase 08](08-analitico-romper-y-medir.md), ordenando 50 M filas (07/10/2026)
- **Qué lo provoca:** cada hilo necesita bloques propios en memoria, y con el límite repartido entre
  ocho no caben, aunque haya directorio temporal.
- **Cómo confirmas que es este y no otro:** el mensaje sigue con *Possible solutions*, la primera
  *Reducing the number of threads*.
- **Cómo se sale:** `SET threads = 1` terminó la misma consulta volcando 1257 MiB; o subir `memory_limit`.

### E-43 — Sin memoria y sin dónde volcar

```text
Out of Memory Error: could not allocate block of size 256.0 KiB (488.3 MiB/488.2 MiB used)
```

- **Motor y versión:** DuckDB 1.5.6, `memory_limit` de 512 MB y `temp_directory` vacío
- **Apareció en:** [Fase 08](08-analitico-romper-y-medir.md), ordenando 50 M filas (07/10/2026)
- **Qué lo provoca:** sin directorio temporal, lo que no cabe en memoria no tiene dónde ir.
- **Cómo confirmas que es este y no otro:** `SELECT current_setting('temp_directory')` devuelve vacío.
- **Cómo se sale:** un `temp_directory` con disco: con él, la misma consulta volcó 921 MiB y terminó.

---

## 🕸️ Neo4j

### E-53 — Borrar muchos nodos de una vez agota la memoria de transacciones

```text
51N72: system configuration or operation exception - memory pool out of memory. Failed to allocate memory in a memory pool. See dbms.memory.transaction.total.max in the neo4j.conf file.
The allocation of an extra 2.0 MiB would use more than the limit 358.4 MiB. Currently using 357.0 MiB. dbms.memory.transaction.total.max threshold reached
```

- **Motor y versión:** Neo4j 2026.09.0 Community, heap de 512 MB (`a02`)
- **Apareció en:** [Fase 13](13-grafos-levantar-y-modelar.md), borrando el modelo genérico (nodos con cientos
  de relaciones) con `DETACH DELETE`, también dentro de `CALL … IN TRANSACTIONS` (07/10/2026)
- **Qué lo provoca:** el límite de memoria de todas las transacciones (el 70 % del heap) no alcanza para
  borrar de una vez nodos con muchas relaciones.
- **Cómo confirmas que es este y no otro:** el mensaje nombra `dbms.memory.transaction.total.max` y el límite.
- **Cómo se sale:** borrar primero las relaciones y después los nodos, en tandas de miles que cierran su
  transacción (`… WITH r LIMIT 5000 DELETE r`), como hace `13-…/load.ts`.

### E-54 — Un producto cartesiano en un `MATCH`

```text
Neo.ClientNotification.Statement.CartesianProduct · This query builds a cartesian product between disconnected patterns. · If a part of a query contains multiple disconnected patterns, this will build a cartesian product between all those parts. This may produce a large amount of data and slow down query processing. While occasionally intended, it may often be possible to reformulate the query that avoids the use of this cross product, perhaps by adding a relationship between the different parts or by using OPTIONAL MATCH (identifier is: (a))
```

- **Motor y versión:** Neo4j 2026.09.0 Community, driver `neo4j-driver` 6.2.0 (`summary.notifications`)
- **Apareció en:** [Fase 13](13-grafos-levantar-y-modelar.md), con `MATCH (p:Part {lotNumber: …}), (a:Aircraft)`:
  1 848 809 filas (07/10/2026)
- **Qué lo provoca:** dos patrones sin relación entre ellos en el mismo `MATCH`.
- **Cómo confirmas que es este y no otro:** es un aviso, no un error; aparece ya en `EXPLAIN`.
- **Cómo se sale:** unir los dos patrones con la relación que los conecta, o separarlos con `WITH`.

### E-55 — Caminos sin límite agotan la memoria de transacciones

```text
Neo.TransientError.General.MemoryPoolOutOfMemoryError · The allocation of an extra 2.0 MiB would use more than the limit 358.4 MiB. Currently using 358.0 MiB. dbms.memory.transaction.total.max threshold reached
```

- **Motor y versión:** Neo4j 2026.09.0 Community, heap de 512 MB (`a02`)
- **Apareció en:** [Fase 14](14-grafos-romper-y-medir.md), con `MATCH p = (s:Part {…})-[:INSTALLED*]-(x)
  RETURN count(p)` sobre `workOrder-1m`, a los 3,6 s (07/10/2026)
- **Qué lo provoca:** pedir caminos de cualquier largo en un grafo con ciclos: no hay poda posible y cada
  camino ocupa memoria de la transacción hasta el límite (el 70 % del heap).
- **Cómo confirmas que es este y no otro:** es el mismo límite de E-53, pero en una lectura; la misma
  travesía con `count(DISTINCT x)` termina (96 242 nodos en 0,4 s).
- **Cómo se sale:** preguntar por nodos (`DISTINCT`) si se puede; si hacen falta caminos, límite de largo y
  `LIMIT`, o `SHORTEST k`. Es transitorio: el motor sigue sano y no hay que reiniciarlo.

---

## 🏛️ Cassandra

### E-57 — Un *write timeout* en una carga que antes funcionaba

```text
ResponseError: Server timeout during write query at consistency LOCAL_ONE (0 peer(s) acknowledged the write over 1 required)
```

- **Motor y versión:** Cassandra 5.0.9 `cassandra@sha256:8819d1b7877e…`, heap de 512 MB (`a02`); driver
  `cassandra-driver` 4.10.0 con 64 escrituras en vuelo
- **Apareció en:** [Fase 17](17-columnar-levantar-y-modelar.md), dos veces (10/10/2026): cargando `reading-5m`
  mientras Postgres cargaba 50 M de filas en la misma máquina virtual, a las 3 M de lecturas; y en la carga ×10,
  sola, a los 25 M de filas, con las compactaciones atrasadas
- **Qué lo provoca:** el nodo no confirmó la escritura antes de su `write_request_timeout` (2 s por defecto):
  el disco y la CPU estaban ocupados por otro proceso o por sus propias compactaciones, con un heap de 512 MB.
- **Cómo confirmas que es este y no otro:** el código es `writeTimeout` (4352) y nombra el nivel de
  consistencia; `nodetool compactionstats` muestra tareas pendientes. No dice que la escritura falló: dice que
  nadie confirmó a tiempo, y la fila puede estar.
- **Cómo se sale:** reintentar, que es seguro porque escribir la misma fila dos veces deja una sola
  (*upsert*); `writeAll` en `lab/harness/cassandra-trace.ts` lo hace y cuenta los reintentos. Si no bajan,
  menos concurrencia y no compartir la máquina durante la carga.

### E-58 — `QUORUM` que no se alcanza

```text
<stdin>:1:NoHostAvailable: ('Unable to complete the operation against any hosts', {<Host: 127.0.0.1:9042 datacenter1>: Unavailable('Error from server: code=1000 [Unavailable exception] message="Cannot achieve consistency level QUORUM" info={\'consistency\': \'QUORUM\', \'required_replicas\': 2, \'alive_replicas\': 1}')})
```

- **Motor y versión:** Cassandra 5.0.9, anillo de tres nodos (`lab/compose.anillo.yaml`), keyspace con
  `replication_factor` 3; `cqlsh` 6.2.0
- **Apareció en:** [Fase 17](17-columnar-levantar-y-modelar.md), leyendo en `QUORUM` con dos de los tres
  nodos detenidos (10/10/2026)
- **Qué lo provoca:** quedan vivas menos réplicas de las que pide el nivel de consistencia.
- **Cómo confirmas que es este y no otro:** el mensaje trae `required_replicas` y `alive_replicas`;
  `nodetool status` marca `DN` en los nodos caídos.
- **Cómo se sale:** devolver los nodos, o bajar el nivel sabiendo que W + R deja de superar al factor de
  replicación y que la lectura puede devolver un valor viejo.

### E-59 — Una consulta que pide filtrar

```text
InvalidRequest: Error from server: code=2200 [Invalid query] message="Cannot execute this query as it might involve data filtering and thus may have unpredictable performance. If you want to execute this query despite the performance unpredictability, use ALLOW FILTERING"
```

- **Motor y versión:** Cassandra 5.0.9, `cqlsh` 6.2.0
- **Apareció en:** [Fase 17](17-columnar-levantar-y-modelar.md), con `WHERE aircraft = 'HC-2157'` sobre
  `reading_by_aircraft_month`, cuya partition key es `(aircraft, month)` (10/10/2026)
- **Qué lo provoca:** la consulta no da la partition key entera, o filtra por una columna que no es clave,
  así que el motor no sabe qué partición leer y tendría que recorrerlas.
- **Cómo confirmas que es este y no otro:** el `WHERE` no tiene todas las columnas de la partition key por
  igualdad (o `IN`).
- **Cómo se sale:** dar la partition key entera, o crear la tabla cuya partition key es lo que sí sabes. El
  mensaje ofrece `ALLOW FILTERING`, que **la ejecuta recorriendo todo** (Fase 17, sección 8).

### E-60 — Una partición con demasiados tombstones

```text
ResponseError: Server failure during read query at consistency LOCAL_ONE (1 responses were required but only 0 replicas responded, 1 failed)
```

```text
ERROR [ReadStage-2] 2026-10-11T06:04:33,980 StorageProxy.java:2248 - Scanned over 100001 tombstones during query 'SELECT egt_c FROM condor.reading_tomb WHERE aircraft = 'HC-2157' AND month = '2025-10' LIMIT 50000 ALLOW FILTERING' (last scanned row token was -1013362864346226567 and partion key was ((HC-2157, 2025-10), 2025-10-02T03:46:40.000Z)); query aborted
```

- **Motor y versión:** Cassandra 5.0.9, un nodo; driver `cassandra-driver` 4.10.0
- **Apareció en:** [Fase 18](18-columnar-romper-y-medir.md), leyendo una partición con 100 001 celdas borradas
  una por una (11/10/2026). La primera línea es la del cliente; la segunda, la del log del nodo
- **Qué lo provoca:** la lectura recorrió más marcas de borrado que `tombstone_failure_threshold` (100 000), y
  el nodo la canceló.
- **Cómo confirmas que es este y no otro:** el mensaje del cliente es el mismo de E-61; solo el log del nodo
  dice `Scanned over … tombstones`. Desde 1001 marcas, el resultado trae un aviso en `info.warnings` (`Read 0
  live rows and 1001 tombstone cells … (see tombstone_warn_threshold)`). La errata *partion* es de Cassandra.
- **Cómo se sale:** borrar por partición, por rango o con TTL en vez de fila por fila, y compactar pasado
  `gc_grace_seconds`. Subir el umbral mueve el borde y no lo quita.

### E-61 — Una lectura local cancelada a los 5 s

```text
ResponseError: Server failure during read query at consistency LOCAL_ONE (1 responses were required but only 0 replicas responded, 1 failed)
```

```text
DEBUG [ScheduledTasks:1] 2026-10-11T06:21:47,474 MonitoringTask.java:154 - 1 operations timed out in the last 4999 msecs:
<SELECT aircraft, egt_c, ts FROM condor.reading_entity WHERE aircraft = 'HC-2157' AND ts >= '2025-09-15T00:00:00.000Z' AND ts < '2025-11-14T00:00:00.000Z' LIMIT 5000 ALLOW FILTERING>, total time 5003 msec, timeout 5000 msec
```

- **Motor y versión:** Cassandra 5.0.9, un nodo; driver `cassandra-driver` 4.10.0, páginas de 5000
- **Apareció en:** [Fase 18](18-columnar-romper-y-medir.md), con `ALLOW FILTERING` sobre la tabla por entidad de
  10 M filas (11/10/2026). La segunda línea es del `debug.log` del nodo
- **Qué lo provoca:** el nodo cancela toda lectura local que pasa de su tiempo; aquí, 5 s, aunque la lectura
  por rango del coordinador admita 10.
- **Cómo confirmas que es este y no otro:** el `debug.log` dice `operations timed out … timeout 5000 msec`; antes,
  como aviso, `operations were slow`. El cliente no lo distingue de E-60.
- **Cómo se sale:** la tabla cuya partition key contesta esa consulta.

### E-62 — Un agregado sobre una partición que no termina

```text
ResponseError: Server timeout during read query at consistency LOCAL_ONE (0 replica(s) responded over 1 required)
```

- **Motor y versión:** Cassandra 5.0.9, un nodo, heap 512 MB
- **Apareció en:** [Fase 18](18-columnar-romper-y-medir.md), con `SELECT max(egt_c)` sobre una partición sin cota
  de 5 M filas (11/10/2026)
- **Qué lo provoca:** el coordinador no recibió respuesta en `read_request_timeout` (5 s): leer la partición
  entera tarda más.
- **Cómo confirmas que es este y no otro:** dice *timeout*, no *failure*, y la consulta nombra una sola partición.
  `nodetool tablestats` muestra la partición máxima en cientos de MiB.
- **Cómo se sale:** un bucket de tiempo en la partition key, y el agregado partición por partición.

### E-63 — Un nodo vivo que no acepta clientes

```text
ERROR [epollEventLoopGroup-5-7] 2026-10-11T07:11:10,504 JVMStabilityInspector.java:123 - OutOfMemory error letting the JVM handle the error:
WARN  [epollEventLoopGroup-5-1] 2026-10-11T06:33:25,182 AbstractChannel.java:489 - Force-closing a channel whose registration task was not accepted by an event loop: [id: 0xaa2cc883, L:/127.0.0.1:9042 - R:/127.0.0.1:…]
java.util.concurrent.RejectedExecutionException: event executor terminated
```

- **Motor y versión:** Cassandra 5.0.9, un nodo, heap 512 MB; driver `cassandra-driver` 4.10.0
- **Apareció en:** [Fase 18](18-columnar-romper-y-medir.md), después de leer en una sola página una partición sin
  cota de 2 M filas, en dos corridas (11/10/2026)
- **Qué lo provoca:** el `OutOfMemoryError` mata el hilo que lo recibe y el JVM sigue. Cuando el hilo es el del
  transporte nativo, el nodo queda sin quien atienda conexiones.
- **Cómo confirmas que es este y no otro:** el driver dice `Socket was closed` o `NoHostAvailableError`, y
  `cqlsh`, `Unable to connect to any servers`; pero `nodetool info` dice `Native Transport active: true`, y
  Docker siguió marcándolo sano 14 minutos (60 reintentos del *healthcheck*). El log trae el error de memoria y,
  desde entonces, un `Force-closing` por conexión. Queda un volcado de heap en `/var/log/cassandra`.
- **Cómo se sale:** reiniciar el nodo y borrar el volcado. Que no vuelva: paginar siempre y acotar la partición.

---

## 📴 CouchDB

### E-09 — CouchDB repite un error cada cinco segundos

```text
[notice] 2026-09-29T17:51:22.243487Z nonode@nohost <0.407.0> -------- chttpd_auth_cache changes listener died because the _users database does not exist. Create the database to silence this notice.
[error] 2026-09-29T17:51:22.243658Z nonode@nohost emulator -------- Error in process <0.408.0> with exit value:
{database_does_not_exist,[{mem3_shards,load_from_db,[<<"_users">>],[{file,"src/mem3_shards.erl"},{line,463}]},…
```

- **Motor y versión:** CouchDB 3.5.2 `couchdb@sha256:8cf5f8442585…`
- **Apareció en:** la sesión de verificación de laboratorio, con un nodo solo recién creado
  (29/09/2026)
- **Qué lo provoca:** un nodo solo no crea las bases de sistema `_users` ni `_replicator`.
- **Cómo confirmas que es este y no otro:** `curl -u condor:condor localhost:15984/_users`
  devuelve `{"error":"not_found","reason":"Database does not exist."}` (verificado el
  29/09/2026).
- **Cómo se sale:** crearlas con `PUT` (el healthcheck del curso lo hace). **Sin `_replicator` no
  hay replicación persistente**, que la [Fase 19](19-offline-levantar-y-modelar.md) usa en su sección 6.3.

### E-64 — Un guardado con una revisión vieja

```text
{"error":"conflict","reason":"Document update conflict."}
```

Desde PouchDB: `409 conflict Document update conflict`.

- **Motor y versión:** CouchDB 3.5.2 `couchdb@sha256:8cf5f8442585…`; PouchDB 9.0.0 en la tableta
- **Apareció en:** [Fase 19](19-offline-levantar-y-modelar.md), guardando `WO-0009941` con un `_rev` que ya no era
  la hoja, con `curl` en el servidor y con PouchDB en la tableta (11/10/2026)
- **Qué lo provoca:** el `_rev` que viaja con el guardado no es la revisión actual de esa base. Es el bloqueo
  optimista de CouchDB, y pasa **dentro de una base**: la replicación nunca lo produce, porque acepta las dos
  ramas y deja un conflicto.
- **Cómo confirmas que es este y no otro:** HTTP 409 y `"error":"conflict"`; un `GET` del documento devuelve
  un `_rev` distinto del que mandaste.
- **Cómo se sale:** leer otra vez, aplicar el cambio sobre lo nuevo y guardar. Si pasa al resolver un conflicto,
  la ganadora cambió mientras fusionabas: vuelve a leer las hojas.

### E-65 — La tableta abierta por otro proceso

```text
OpenError IO error: lock lab/data/tablets/freddy/LOCK: Resource temporarily unavailable
```

- **Motor y versión:** PouchDB 9.0.0 en Node 24, con su adaptador LevelDB
- **Apareció en:** [Fase 19](19-offline-levantar-y-modelar.md), abriendo la tableta de Freddy desde un segundo
  proceso mientras un guion la tenía abierta (11/10/2026)
- **Qué lo provoca:** LevelDB admite **un proceso por carpeta**, y lo garantiza con el archivo `LOCK`.
- **Cómo confirmas que es este y no otro:** el error sale al primer uso de la base (`info()`, `get()`), no al
  crearla; `lsof lab/data/tablets/freddy/LOCK` muestra el proceso que la tiene.
- **Cómo se sale:** cerrar el otro proceso o llamar a `db.close()` antes de abrirla en otro; si cada proceso
  necesita su copia, que cada uno tenga su tableta y se repliquen.

### E-67 — Un antepasado que la compactación ya borró

```text
{"error":"not_found","reason":"missing"}
```

Desde PouchDB: `404 missing`.

- **Motor y versión:** CouchDB 3.5.2 `couchdb@sha256:8cf5f8442585…`; PouchDB 9.0.0 en la tableta
- **Apareció en:** [Fase 20](20-offline-romper-y-medir.md), pidiendo la revisión 1 de una orden con once hojas
  (`?rev=1-…`) después de compactar el servidor y la tableta; antes de compactar estaba (11/10/2026)
- **Qué lo provoca:** la compactación borra los cuerpos de las revisiones que no son hoja. El identificador queda en
  la historia; el contenido, no.
- **Cómo confirmas que es este y no otro:** `?revs_info=true` lista esa revisión como `missing`; un id que no existe
  contesta `"reason":"missing"` también, pero no aparece en la historia del documento.
- **Cómo se sale:** no se recupera. Una fusión que necesite el antepasado común tiene que guardar en el documento lo
  que compara, o ser un CRDT, que no lo necesita.

---

## ⚡ CockroachDB

### E-10 — `cockroach demo` corta la conexión desde tu máquina

```text
failed to connect to `user=root database=`: host.docker.internal:26259 (host.docker.internal): failed to receive message: unexpected EOF
```

- **Motor y versión:** CockroachDB 26.3.2, `cockroach demo --nodes=9 --global`
- **Apareció en:** [`a02`](a02-compose-de-la-ruta.md), conectando desde el host al perfil
  `newsql-global` (29/09/2026)
- **Qué lo provoca:** `demo` escucha solo en `127.0.0.1` dentro del contenedor y no tiene opción
  para cambiarlo: el puerto publicado no llega a ningún nodo.
- **Cómo confirmas que es este y no otro:** dentro del contenedor, todos los puertos de
  `/proc/net/tcp` están en `127.0.0.1`.
- **Cómo se sale:** el sidecar `socat` del compose del curso, que comparte la red del demo y
  reenvía el puerto.

### E-11 — CockroachDB no deja leer `crdb_internal`

```text
ERROR: Access to crdb_internal and system is restricted.
SQLSTATE: 42501
HINT: These interfaces are unsupported in production. To proceed, set the session variable allow_unsafe_internals = true (not recommended), or contact Cockroach Labs for a supported alternative.
```

- **Motor y versión:** CockroachDB 26.3.2 `cockroachdb/cockroach@sha256:bc15746ef2c2…`
- **Apareció en:** [`a02`](a02-compose-de-la-ruta.md), contando nodos con
  `crdb_internal.gossip_nodes` (29/09/2026)
- **Qué lo provoca:** las tablas internas están restringidas por defecto.
- **Cómo confirmas que es este y no otro:** el `SQLSTATE` es `42501`.
- **Cómo se sale:** usar las sentencias soportadas (`SHOW REGIONS FROM CLUSTER`,
  `SHOW RANGES`…). La variable de sesión existe, y el propio mensaje dice que no se recomienda.

### E-69 — Una extensión de Postgres que CockroachDB no tiene

```text
ERROR: unimplemented: extension "pg_stat_statements" is not yet supported
SQLSTATE: 0A000
HINT: You have attempted to use a feature that is not yet implemented.
See: https://go.crdb.dev/issue-v/54516/v26.3
```

- **Motor y versión:** CockroachDB 26.3.2 `cockroachdb/cockroach@sha256:bc15746ef2c2…`, un nodo
- **Apareció en:** [Fase 21](21-newsql-levantar-y-modelar.md), corriendo tal cual el esquema de la
  [Fase 01](01-el-dominio-de-flota-y-el-arnes.md) (11/10/2026)
- **Qué lo provoca:** `CREATE EXTENSION`. CockroachDB habla el protocolo de Postgres, pero no carga sus extensiones.
  En el mismo archivo falla también el `ANALYZE;` sin tabla, con un error de sintaxis: CockroachDB pide el nombre.
- **Cómo confirmas que es este y no otro:** el `SQLSTATE` es `0A000` (*feature not supported*) y el mensaje dice
  `unimplemented`.
- **Cómo se sale:** quitar la línea. Las estadísticas de sentencias de CockroachDB están en su consola y en
  `SHOW STATEMENTS`; las de las tablas, en `ANALYZE <tabla>` o en las que el motor recoge solo.

### E-70 — `PLACEMENT` sin la variable de sesión

```text
error: ALTER DATABASE PLACEMENT requires that the session setting enable_multiregion_placement_policy is enabled
code: XCEXF
hint: to enable, enable the session setting or the cluster setting sql.defaults.multiregion_placement_policy.enabled
```

- **Motor y versión:** CockroachDB 26.3.2, `cockroach demo --nodes=9 --global`, desde el driver `pg` 8.23.0
- **Apareció en:** [Fase 21](21-newsql-levantar-y-modelar.md), restringiendo el expediente ecuatoriano a su región
  (`placement.ts`, 11/10/2026)
- **Qué lo provoca:** `ALTER DATABASE … PLACEMENT RESTRICTED` (o `DEFAULT`) viene apagado por defecto.
- **Cómo confirmas que es este y no otro:** el código es `XCEXF`, uno propio de CockroachDB.
- **Cómo se sale:** `SET enable_multiregion_placement_policy = on` en la sesión, antes del `ALTER`. La alternativa
  de clúster que sugiere el mensaje cambia el valor para todos.

### E-71 — `restart transaction` en una transacción serializable

```text
error: restart transaction: TransactionRetryWithProtoRefreshError: TransactionRetryError: retry txn (RETRY_SERIALIZABLE): "sql txn" meta={id=0909f86e key=/Table/139/1/"SN-0004351"/0 iso=Serializable pri=0.00185114 epo=0 ts=1791759300.181344210,2 min=1791759300.181344210,0 seq=3} lock=true stat=PENDING rts=1791759300.181344210,0 gul=1791759300.681344210,0 obs={n1@1791759300.181344210,0}
code: 40001
```

En Postgres, la misma anomalía con `SERIALIZABLE`: `40001 could not serialize access due to read/write dependencies
among transactions`.

- **Motor y versión:** CockroachDB 26.3.2 `cockroachdb/cockroach@sha256:bc15746ef2c2…`, un nodo; PostgreSQL 18.6
- **Apareció en:** [Fase 21](21-newsql-levantar-y-modelar.md), con dos bases que instalan a la vez una llanta en la
  misma posición (`skew.ts`, 11/10/2026). En CockroachDB, al `COMMIT`; en Postgres, en el `UPDATE`
- **Qué lo provoca:** dos transacciones que leen lo que la otra escribe (*write skew*). `SERIALIZABLE` no puede
  ordenarlas sin contradecir lo que una de ellas leyó, y aborta una. En CockroachDB es el aislamiento por defecto.
- **Cómo confirmas que es este y no otro:** `40001` y `RETRY_SERIALIZABLE`. Otros motivos de reinicio llevan otra
  palabra en el mismo lugar (`RETRY_WRITE_TOO_OLD`, `ReadWithinUncertaintyIntervalError`, E-72).
- **Cómo se sale:** **reintentar la transacción entera** desde el `BEGIN`, porque lo que leyó ya no vale. Es parte
  del modelo de programación de CockroachDB, y la [Fase 22](22-newsql-romper-y-medir.md) lo mide con contención. Bajar a `READ COMMITTED` lo hace
  desaparecer y deja pasar la anomalía: dos llantas en la misma nariz.

### E-72 — Una lectura dentro del intervalo de incertidumbre

```text
error: restart transaction: TransactionRetryWithProtoRefreshError: ReadWithinUncertaintyIntervalError: read at time 1791759111.828504762,0 encountered previous write with future timestamp 1791759111.834201387,0 within uncertainty interval `t <= (local=1791759112.082720678,0, global=1791759112.328504762,0)`; observed timestamps: [{3 1791759112.082720678,0} {4 1791759111.828504762,0} {5 1791759111.832741637,0}]: "sql txn" meta={id=78eb6461 key=/Min iso=Serializable pri=0.02175844 epo=0 ts=1791759111.828504762,0 min=1791759111.828504762,0 seq=0} lock=false stat=PENDING rts=1791759111.828504762,0 gul=1791759112.328504762,0 obs={n3@1791759112.082720678,0 n4@1791759111.828504762,0 n5@1791759111.832741637,0}
code: 40001
```

- **Motor y versión:** CockroachDB 26.3.2, `cockroach demo --nodes=9 --global`
- **Apareció en:** [Fase 21](21-newsql-levantar-y-modelar.md), con una lectora que encuentra un valor escrito 5 ms
  después de su fecha, en un nodo que todavía no había visitado (`clock.ts`, cinco de cinco vueltas, 11/10/2026)
- **Qué lo provoca:** ningún nodo sabe si su reloj y el de otro coinciden. Un valor con fecha posterior a la de la
  lectora, pero a menos de 500 ms (`global=`, el desfase máximo permitido), **pudo escribirse antes** de que ella
  empezara. El motor intenta mover la fecha de la lectora y revalidar lo que ya leyó; si eso también cambió, la
  transacción se reinicia.
- **Cómo confirmas que es este y no otro:** `ReadWithinUncertaintyIntervalError` en el mensaje; la diferencia entre
  `read at time` y `future timestamp` es menor que la que hay hasta `global=`.
- **Cómo se sale:** reintentar, como E-71. Si pasa seguido en una lectura que puede ser un poco vieja, `AS OF SYSTEM
  TIME follower_read_timestamp()` la saca de la ventana.

### E-73 — `EXPLAIN` con parámetros

```text
error: EXPLAIN does not support placeholders
code: XXUUU
```

- **Motor y versión:** CockroachDB 26.3.2, desde el driver `pg` 8.23.0
- **Apareció en:** [Fase 21](21-newsql-levantar-y-modelar.md), midiendo las sentencias del expediente con
  `EXPLAIN ANALYZE … $1` como en Postgres (11/10/2026)
- **Qué lo provoca:** CockroachDB no prepara un `EXPLAIN`. `SHOW RANGE … FOR ROW ($1)` falla parecido:
  `could not determine data type of placeholder $1` (`42P18`).
- **Cómo confirmas que es este y no otro:** la misma sentencia sin `EXPLAIN` sí acepta `$1`.
- **Cómo se sale:** escribir los valores como literales, con el escape del driver; es lo que hace `inline()` en
  `lab/harness/crdb-explain.ts`.

### E-74 — Sobrevivir a una región y no salir de ella

```text
error: a region-survivable database cannot also have a restricted placement policy
code: 22023
```

Con una super región en lugar de la ubicación restringida, el mismo choque con otro mensaje:

```text
error: super region ecuador only has 1 region(s): at least 3 regions are required for surviving a region failure
code: 22023
hint: you must add additional regions to the database or change the survivability goal
```

- **Motor y versión:** CockroachDB 26.3.2, `cockroach demo --nodes=9 --global`
- **Apareció en:** [Fase 21](21-newsql-levantar-y-modelar.md), pidiendo `SURVIVE REGION FAILURE` sobre la base del
  expediente con `PLACEMENT RESTRICTED`, y con una super región que solo contiene a Ecuador (`placement.ts`,
  11/10/2026)
- **Qué lo provoca:** sobrevivir a la caída de una región exige votantes en otras regiones, y la ubicación
  restringida prohíbe justamente eso. **No es un límite del motor**: son dos requisitos contradictorios.
- **Cómo confirmas que es este y no otro:** el `SQLSTATE` es `22023` y el mensaje nombra las dos cosas, o el número
  de regiones de la super región.
- **Cómo se sale:** elegir. Si la ley manda, la región puede caerse y el expediente queda sin servicio mientras
  tanto; si manda la disponibilidad, alguien tiene que aceptar copias fuera del país.

### E-75 — La escritura que llega tarde a una fila caliente

```text
error: restart transaction: TransactionRetryWithProtoRefreshError: WriteTooOldError: write for key /Table/113/1/"SN-0005382"/0 at timestamp 1791779703.716998341,0 too old; must write at or above 1791779703.717719424,2: "sql txn" meta={id=3dbc81cc key=/Table/113/1/"SN-0005382"/0 iso=Serializable pri=0.00692988 epo=0 ts=1791779703.717719424,2 min=1791779703.716998341,0 seq=0} lock=true stat=PENDING rts=1791779703.716998341,0 gul=1791779704.216998341,0 obs={n1@1791779703.716998341,0 n3@1791779703.721078466,0}
code: 40001
```

- **Motor y versión:** CockroachDB 26.3.2, `cockroach demo --nodes=9 --global`
- **Apareció en:** [Fase 22](22-newsql-romper-y-medir.md), con trabajadores de tres regiones sumando horas al mismo
  motor —una fila de Colombia— leyendo y escribiendo (`contention.ts`): 4759 veces en 20 s con 48 trabajadores
  (11/10/2026)
- **Qué lo provoca:** la transacción quiere escribir con su fecha, y otra ya escribió esa clave con una fecha
  posterior. Le pasa sobre todo al que está lejos de la fila: su escritura llega un viaje después de leer, y en ese
  viaje alguien de la región de la fila ya escribió.
- **Cómo confirmas que es este y no otro:** `40001` y `WriteTooOldError` con `must write at or above`; los
  trabajadores remotos tienen medianas de segundos y los locales de milisegundos.
- **Cómo se sale:** reintentar (E-71) es lo mínimo, y no alcanza bajo contención: la sentencia atómica
  (`hours = hours + 1`), `SELECT … FOR UPDATE`, o partir la fila por región (sección 6 de la fase).

### E-76 — Un nodo que se mata por el reloj

```text
F261012 02:03:51.913580 36826 1@rpc/peer.go:524  [T1,Vsystem,n8,rnode=6,raddr=127.0.0.1:26362,class=system,rpc] 1  clock synchronization error: this node is more than 400ms away from at least half of the known nodes (0 of 1 are within the offset)
```

- **Motor y versión:** CockroachDB 26.3.2, `cockroach demo --nodes=9 --global`
- **Apareció en:** [Fase 22](22-newsql-romper-y-medir.md), en dos demos: uno quieto después de la contención y otro
  moviendo réplicas a la ubicación restringida. El demo entero terminó con código 7 (11/10/2026)
- **Qué lo provoca:** un nodo que mide su reloj contra los demás y no puede asegurar que está dentro del desfase
  permitido (el 80 % de los 500 ms) se apaga solo, en vez de servir lecturas que podrían estar mal. En el demo los
  nueve nodos comparten el reloj de la máquina: lo que llegó tarde fue el latido, por una pausa del proceso o de la
  VM, que desde adentro no se distingue de un reloj adelantado.
- **Cómo confirmas que es este y no otro:** el contenedor sale con código 7 y `OOMKilled=false`; la línea empieza con
  `F` (fatal) y dice `clock synchronization error`.
- **Cómo se sale:** en el laboratorio, recrear el demo y volver a cargar. En un clúster, sincronizar los relojes (NTP
  o el servicio de la nube) y nunca apagar el chequeo: `cockroach start` lo permite con
  `--disable-max-offset-check`, y la documentación avisa que se pierden las garantías; `cockroach demo` ni lo acepta.

### E-78 — Un entero que llega como texto

```text
error: error in argument for $2: could not parse "47311111111111111111" as type int: strconv.ParseInt: parsing "47311111111111111111": value out of range
code: 22P02
```

- **Motor y versión:** CockroachDB 26.3.2, desde el driver `pg` 8.23.0
- **Apareció en:** [Fase 22](22-newsql-romper-y-medir.md), sumando horas a un motor leyendo el valor y escribiendo el
  valor más uno (`contention.ts`, 11/10/2026)
- **Qué lo provoca:** el `INT` de CockroachDB es de 8 bytes, y `pg` devuelve los enteros de 8 bytes como texto para no
  perder precisión. `"4731" + 1` en JavaScript es `"47311"`; cada vuelta agrega un dígito hasta que no cabe.
- **Cómo confirmas que es este y no otro:** el valor del mensaje es el número original con unos pegados al final.
- **Cómo se sale:** `Number()` (o `BigInt()` si puede pasar de 2^53) antes de sumar. Y revisar lo que quedó escrito
  antes del error: en la fase, la fila quedó con 4731111111111111000.

---

## 🟩 Node y npm

### E-13 — Node no ejecuta un `enum`

```text
SyntaxError [ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX]: TypeScript enum is not supported in strip-only mode
```

- **Versión:** Node 24.21.0, ejecutando un `.ts` directamente
- **Apareció en:** [`a06`](a06-lenguajes-y-drivers.md) (29/09/2026)
- **Qué lo provoca:** Node 24 solo quita los tipos; lo que no es sintaxis "borrable" —`enum`,
  `namespace`, *parameter properties*— no puede ejecutarlo.
- **Cómo confirmas que es este y no otro:** el código es `ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX`.
- **Cómo se sale:** un objeto `as const` en lugar del `enum`, y un campo asignado en el
  constructor en lugar de la *parameter property*.

### E-14 — `JavaScript heap out of memory` al generar

```text
FATAL ERROR: Ineffective mark-compacts near heap limit Allocation failed - JavaScript heap out of memory
```

- **Versión:** Node 24.21.0, generador de [`a05`](a05-el-dominio-de-flota.md) antes del tope de
  escala
- **Apareció en:** generando `pirep-1m` sin tope (29/09/2026)
- **Qué lo provoca:** el proceso superó el límite del heap de V8. En el generador, 1 M de pireps
  multiplicaba la empresa por 85.
- **Cómo confirmas que es este y no otro:** el proceso muere con `Abort trap` y esta línea.
- **Cómo se sale:** reducir lo que se tiene en memoria —el generador limitó la escala a ×25— o,
  como último recurso, `node --max-old-space-size=<MB>`.

### E-15 — npm no ejecuta los scripts de instalación

```text
4 packages have install scripts not yet covered by allowScripts:
  leveldown@5.6.0 (install: node-gyp rebuild)
  leveldown@6.1.1 (install: node-gyp rebuild)
  onnxruntime-node@1.30.0 (postinstall: node ./script/install)
  protobufjs@7.6.6 (postinstall: node scripts/postinstall)
```

- **Versión:** npm 11.19.0, instalando las dependencias de `src/`
- **Apareció en:** [`a06`](a06-lenguajes-y-drivers.md) (29/09/2026)
- **Qué lo provoca:** npm 11 ya no ejecuta los scripts de instalación de las dependencias sin
  aprobación explícita.
- **Cómo confirmas que es este y no otro:** `npm install-scripts ls`.
- **Cómo se sale:** en este curso no hace falta: PouchDB y `transformers.js` funcionan sin esos
  scripts (verificado en macOS). Si en tu plataforma algo falla por eso,
  `npm install-scripts approve <paquete>`.

### E-68 — Un proceso que termina sin terminar

```text
Warning: Detected unsettled top-level await at file:///…/20-offline-romper-y-medir/bet.ts:52
await run(crdtDoc, crdtMerge);
^
```

- **Versión:** Node 24.21.0, con PouchDB 9.0.0 replicando contra CouchDB 3.5.2
- **Apareció en:** [Fase 20](20-offline-romper-y-medir.md), en dos de seis corridas de `bet.ts`, y una vez en la
  [Fase 19](19-offline-levantar-y-modelar.md) (`sync.ts`); siempre en una replicación que pasaba por el contador de
  bytes del arnés (11/10/2026)
- **Qué lo provoca:** Node se quedó sin nada pendiente —ni sockets ni temporizadores— mientras una promesa seguía
  esperando, y sale sin terminar el guion. El contador leía el cuerpo de cada respuesta de una copia,
  `res.clone()`, y esa copia a veces no terminaba nunca.
- **Cómo confirmas que es este y no otro:** el aviso apunta al `await` de nivel superior, no al lugar donde se colgó;
  trazas antes y después de cada paso muestran que la última en salir es la de antes de la replicación.
- **Cómo se sale:** leer el cuerpo una vez y devolver una respuesta nueva con esos bytes, sin `clone()`, como hace
  `lab/harness/couch.ts` desde entonces: ocho corridas de ocho.

### E-82 — `fetch` que tumba el proceso con el servidor caído

```text
node:net:913
      throw new ErrnoException(err, 'setTypeOfService');
      ^

Error: setTypeOfService EINVAL
    at Socket.setTypeOfService (node:net:913:13)
    at writeH1 (node:internal/deps/undici/undici:8021:16)
```

- **Versión:** Node 24.21.0, con CouchDB 3.5.2 detenido con `docker stop`
- **Apareció en:** [Fase 24](24-poliglota-la-costura.md), en la doble escritura de `run.ts`, que escribía con `fetch`
  mientras CouchDB se apagaba (12/10/2026)
- **Qué lo provoca:** el `fetch` de Node (undici) lanzó el error al preparar el socket, fuera de la promesa que la
  aplicación esperaba: el `try` alrededor del `await` no lo atrapa y el proceso termina.
- **Cómo confirmas que es este y no otro:** la traza pasa por `undici` y `setTypeOfService`, y ninguna línea de tu
  código está en ella.
- **Cómo se sale:** para hablar con un servidor que se va a caer a propósito, `node:http`, cuyos errores llegan por el
  evento `error` de la petición; así lo hacen `run.ts`, `watch.ts` y `race.ts`.

---

## 🧭 Cuándo usar qué

| Lo que ves | Empieza por |
|---|---|
| Un contenedor que sale sin mensaje | E-05: código 137 y `OOMKilled` |
| `up` que no avanza | E-06: `pull` por separado |
| Un driver que espera hasta el timeout | E-03, y en general: ¿el motor se anuncia con una dirección que desde tu máquina no existe? |
| Un error en el log del primer arranque | E-07 y E-09: ¿se repite o fue una vez? |
| Un error que menciona el kernel | E-02 |

---

## 🧪 Ejercicios (6)

### 🟢 Ejercicio 1 — Buscar por el mensaje

Copia el mensaje de E-01 en un buscador.

**Pregunta:** ¿cuántos de los primeros resultados explican que la salida es un replica set de un
nodo, y cuántos proponen abandonar Mongo?

### 🟢 Ejercicio 2 — La firma del OOM

Provoca E-05 con el procedimiento de [`a01`](a01-laboratorio-contenerizado.md).

**Objetivo:** confirmar las dos mitades de la firma: el código 137 y `OOMKilled=true`.

### 🟡 Ejercicio 3 — Error o aviso

Clasifica las entradas en tres grupos: impiden trabajar, avisan de un riesgo o son
inocuas.

**Pregunta:** ¿cuáles de las inocuas conviene tener aquí de todos modos, y por qué?

### 🟡 Ejercicio 4 — Tu propia entrada

Provoca un error nuevo en el laboratorio —el que quieras— y escribe su entrada con el formato
completo.

**Objetivo:** que el mensaje sea literal y que "cómo confirmas que es este y no otro" tenga un
comando.

### 🟠 Ejercicio 5 — La dirección que no existe

E-03 y E-10 comparten una causa de fondo.

**Pregunta:** ¿cuál es, y en qué otra familia del curso esperarías encontrarla? Predícelo antes
de llegar a esa fase.

### 🔴 Ejercicio 6 — Cuando no hay que salir

Elige una entrada con "si la salida correcta es no salir" y escribe la misma línea para otra
entrada que no la tenga.

**Objetivo:** reconocer un error que no pide un arreglo, sino un rediseño.

---

> 🏷️ **Este apéndice no lleva tag propio.** Crece con cada fase, y sus entradas se commitean con el
> prefijo de la fase que las encontró.
