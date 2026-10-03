# 📎 Apéndice a09 — Catálogo de errores con mensaje literal

> **Curso:** Ruta NoSQL Lite · Consulta rápida y documento vivo · **3 h**
> **Usado por:** todas las fases · **Versiones cubiertas:** las de cada entrada
> **Fecha de verificación ejecutada:** la de cada entrada. **Entradas:** 37 de las 50 que el curso
> se propone reunir

**Esto no se lee de corrido.** Se entra buscando el mensaje que acabas de pegar en un buscador.
Cada entrada es un error que **apareció de verdad al ejecutar** algo de este curso, con su
mensaje literal tal como salió, sin recortar la parte incómoda.

**Qué queda fuera:** errores que nadie vio. Una entrada reconstruida de memoria es un mensaje que
no existe, y un mensaje que no existe no lo encuentra nadie. Por eso este catálogo **crece con
el curso**: cada fase añade lo que encontró al ejecutarse (formato en
`prompts/formato-bitacora-de-medicion.md` §6).

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
  [E-36](#e-36--el-grafo-hnsw-no-cabe-en-maintenance_work_mem)
- **TimescaleDB** — [E-07](#e-07--un-error-de-timescaledb-en-el-primer-arranque)
- **OpenSearch** — [E-05](#e-05--el-contenedor-sale-con-137-sin-decir-nada)
- **Qdrant** — [E-12](#e-12--qdrant-avisa-que-puede-perder-los-datos) · [E-32](#e-32--un-vector-de-otra-dimensión) ·
  [E-33](#e-33--un-umbral-por-debajo-del-mínimo) · [E-34](#e-34--una-colección-que-no-existe) ·
  [E-37](#e-37--un-lote-más-grande-de-lo-que-acepta-la-api)
- **DuckDB** — [E-08](#e-08--duckdb-no-deja-escribir-a-un-segundo-proceso)
- **CouchDB** — [E-09](#e-09--couchdb-repite-un-error-cada-cinco-segundos)
- **CockroachDB** — [E-10](#e-10--cockroach-demo-corta-la-conexión-desde-tu-máquina) ·
  [E-11](#e-11--cockroachdb-no-deja-leer-crdb_internal)
- **Docker** — [E-04](#e-04--el-puerto-ya-está-ocupado) · [E-05](#e-05--el-contenedor-sale-con-137-sin-decir-nada) ·
  [E-06](#e-06--la-descarga-se-queda-colgada)
- **Node y npm** — [E-13](#e-13--node-no-ejecuta-un-enum) ·
  [E-14](#e-14--javascript-heap-out-of-memory-al-generar) ·
  [E-15](#e-15--npm-no-ejecuta-los-scripts-de-instalación)
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

---

## 🔍 OpenSearch

Ver [E-05](#e-05--el-contenedor-sale-con-137-sin-decir-nada): el límite de memoria de la JVM.

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
  familia: es el punto de rotura de la [Fase 08](08-analitico-romper-y-medir.md).

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
  hay replicación persistente**, que es lo que F19 enseña.

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
