# 🔬 Hallazgos de la sesión de verificación de laboratorio (T10)

> **Qué es esto:** el registro de lo que apareció al levantar los diez motores de verdad —
> errores con su mensaje literal, versiones que no funcionan y por qué, decisiones de fijado
> de imágenes—. Es la fuente de la que beben `a02` (digests y RAM), `a06` (clientes y
> modelo), `a09` (catálogo de errores) y `a10` (licencias).
> **Cómo se reproduce:** `compose.yaml` y `medir.sh` de esta carpeta; los datos crudos están
> en `resultados-<plataforma>.tsv` y los logs completos en `logs-<plataforma>/`.
> **Plataformas:** macOS arm64 verificada el 29/09/2026. Linux, pendiente. Windows 11
> (WSL2), aplazada a propósito: se valida al trabajar el curso.

---

## 📊 Resultados · macOS arm64 · 29/09/2026

Docker Desktop 29.8.0, VM con kernel `7.0.12-linuxkit` y 7,75 GiB. Cada familia se midió sola,
con la configuración del `compose.yaml`, en reposo y tras un minuto de espera. Los tiempos son
hasta el primer healthcheck verde, **no incluyen la descarga**, y son contexto, nunca argumento.

| Familia | Imagen | Healthy en | RAM en reposo | Digest |
|---|---|---|---|---|
| base | `pgvector/pgvector:0.8.6-pg18` | 3 s | 33 MiB | `sha256:2ba9ca5f2e7d…` |
| documental | `mongo:8.0.20` (§H1) | 4 s | 115 MiB | `sha256:098862b1339f…` |
| clave-valor | `valkey/valkey:9.1` (9.1.2) | 3 s | 12 MiB | `sha256:418652cfb58e…` |
| analítico | DuckDB 1.5.6, embebido en Python | — | — | — |
| series | `timescale/timescaledb:2.30.1-pg18` | 3 s | 88 MiB | `sha256:9dede0e3ccc0…` |
| busqueda | `opensearchproject/opensearch:3.8.0`, heap 512 MB | 17 s | 1020 MiB | `sha256:fafe3fc35870…` |
| grafos | `neo4j:2026.09.0-community`, heap 512 MB | 13 s | 529 MiB | `sha256:91fb0bf237c4…` |
| vectorial | `qdrant/qdrant:v1.19.1` | 3 s | 58 MiB | `sha256:12364fe851b9…` |
| columnar | `cassandra:5.0` (5.0.9), heap 512 MB | 62 s | 1,16 GiB | `sha256:8819d1b7877e…` |
| offline | `couchdb:3.5.2` (§H9) | 5 s | 99 MiB | `sha256:8cf5f8442585…` |
| newsql | `cockroachdb/cockroach:v26.3.2`, un nodo | 4 s | 318 MiB | `sha256:bc15746ef2c2…` |

Los digests completos están en `resultados-darwin-arm64.tsv`.

**La lectura para `a02`:** los tres motores JVM —Cassandra, OpenSearch y Neo4j— suman
**≈ 2,7 GiB aun con el heap limitado**. Los otros siete motores con servidor, juntos, no
llegan a 750 MiB. En una VM de 8 GB cabe Postgres más cualquier familia, y también las
tres JVM a la vez, pero no con holgura: ahí se fija la advertencia de RAM.

---

## H1 · MongoDB 8.0 no arranca en Docker Desktop para macOS · 29/09/2026

**Qué pasó.** `mongo:8.0` (que hoy resuelve a la 8.0.32) no llegó nunca a *healthy*:
245 s en *unhealthy* hasta que el script se rindió. El proceso termina en el arranque con
un error fatal, y lo hace a propósito:

```text
{"t":{"$date":"2026-09-29T06:44:34.795Z"},"s":"F","c":"CONTROL","id":12257600,"ctx":"main","msg":"MongoDB cannot start: Linux kernel versions 6.19 and newer has a known incompatibility with this version of MongoDB. See https://jira.mongodb.org/browse/SERVER-121912 for more information."}
```

**El entorno.** Docker Desktop 29.8.0, cuya VM corre el kernel `7.0.12-linuxkit`. En
macOS el contenedor no usa el kernel del Mac sino el de esa VM, así que **el kernel lo
decide la versión de Docker Desktop**, no la del sistema operativo.

**La causa de fondo.** El kernel 6.19 reescribió `rseq` (*restartable sequences*) y dejó
de actualizar el campo `cpu_id_start` en cada reprogramación de un hilo, algo que el ABI
nunca había garantizado. El TCMalloc que MongoDB 8.x trae incorporado dependía de esa
escritura para saber cuándo invalidar su caché por CPU. Sin ella, la caché queda obsoleta
y `mongod` termina en `SIGSEGV` al migrar hilos entre CPUs: se han reportado caídas
periódicas al poco de arrancar. Linus Torvalds lo trató como regresión del kernel, y el
comportamiento anterior volvió en **Linux 7.0.14**.

**Qué hizo MongoDB, por versión** (SERVER-121912 y SERVER-125742):

| Versión de MongoDB | Kernel 6.19 a 7.0.13 | Kernel 7.0.14 o posterior |
|---|---|---|
| 8.0.0 a 8.0.20 | **arranca**, pero expuesta al fallo de fondo | arranca |
| 8.0.21 a 8.0.29 · 8.3.0 a 8.3.8 | **se niega a arrancar** (el error de arriba) | se niega a arrancar |
| 8.0.30 o posterior · 8.3.9 o posterior | **se niega a arrancar** | arranca |

**Por qué corre la 8.0.20.** Porque es anterior a la protección que añadió SERVER-121912,
no porque tenga arreglado el fallo. Lleva el mismo TCMalloc que las demás 8.x, así que
sobre este kernel **está expuesta a la caída por `SIGSEGV`**. El kernel 7.0.12 cae
exactamente en el rango roto, y por eso ni siquiera la 8.0.30, que ya corrige la
protección, sirve aquí: solo la levanta para 7.0.14 en adelante. Que un `bd-lab-mongo`
8.0.20 lleve dos días arriba en esta misma máquina demuestra que en reposo no se dispara;
**no demuestra que aguante carga**, y las fases de rotura (F04) lo van a cargar.

**Decisión del laboratorio.** `mongo:8.0.20` fijada por digest como **parche temporal**,
con esta nota enlazada desde el `compose.yaml`. Se vuelve a la 8.0 vigente en cuanto
Docker Desktop traiga un kernel 7.0.14 o posterior.

**Alternativas descartadas por ahora:**

- `GLIBC_TUNABLES=glibc.pthread.rseq=…` en el contenedor, que la comunidad reporta como
  paliativo: hace que glibc tome `rseq` y TCMalloc pierda su caché por CPU. Degrada el
  rendimiento del asignador y hay reportes de que no alcanza en todos los casos. En un
  curso que mide, un motor con el asignador cambiado **ensucia la medición**.
- Bajar a un kernel 6.18 o anterior: en macOS no se elige, viene con Docker Desktop.

**La prueba de carga (29/09/2026).** `medir-carga-mongo.sh` con `comprobaciones/mongo_carga.mjs`:
32 trabajadores durante 10 minutos contra la 8.0.20 en el kernel 7.0.12. Cada ciclo inserta un
lote de 200 órdenes, lee por índice y hace crecer un array con `$push`. El log confirma que el
asignador es el afectado (`"allocator":"tcmalloc-google"`).

```text
FIN · operaciones: 19323 · fallos: 0 · documentos: 1288200
cliente terminó con 0 · mongod: status=running exit=0 oom=false restarts=0
```

**Aguantó:** ni `SIGSEGV`, ni reinicios, ni errores del driver. Los reportes del fallo hablan
de caídas cada ~30 s con migraciones de CPU, así que diez minutos bajo carga concurrente sin
caer **es evidencia fuerte de que en esta VM no se dispara**. No es una prueba de ausencia: es
una ejecución, en arm64 y sobre linuxkit. Suficiente para el laboratorio del curso, no para
producción. El parche temporal se mantiene.

**Pendientes que abre:**

- [x] Prueba de carga sobre la 8.0.20 en esta VM: pasó (arriba).
- [ ] Comprobar el kernel de la VM en cada actualización de Docker Desktop
      (`docker info --format '{{.KernelVersion}}'`).
- [ ] En Linux nativo, el kernel es el del host: anotar cuál tiene la máquina de prueba.
- [ ] Llevarlo a `a09` con el mensaje literal, a `a01` como advertencia de macOS, y a
      F03 si sigue vigente cuando se escriba.

**Fuentes:**
[SERVER-121912](https://jira.mongodb.org/browse/SERVER-121912) ·
[SERVER-125742](https://jira.mongodb.org/browse/SERVER-125742) ·
[anuncio en el foro de MongoDB](https://www.mongodb.com/community/forums/t/mongodb-8-x-and-linux-kernel-6-19/337547) ·
[análisis técnico de TCMalloc y rseq](https://miliucci.org/post/mongodb-tcmalloc-rseq/)

---

## H2 · CouchDB: descarga colgada y medición inválida · 29/09/2026

La descarga de `couchdb:3.5.2` falló con un timeout del CDN de Docker Hub, y
`docker compose up` se quedó esperando:

```text
failed to copy: httpReadSeeker: failed open: failed to do request: Get "https://production.cloudfront.docker.com/registry-v2/…": net/http: timeout awaiting response headers
```

Terminó llegando a healthy, pero esa medición **no valía**: los 12 289 s incluían la descarga
y el digest quedó vacío. Se repitió con la imagen ya descargada (§H9), y la fila inválida se
borró de `resultados-darwin-arm64.tsv`. Al
curso le deja una advertencia para `a01`: `docker compose pull` antes de `up`, para que un
fallo de red no se confunda con un motor que no arranca.

## H3 · Cassandra: 1190 s en una tanda, 62 s en la siguiente · 29/09/2026

En la primera tanda, Cassandra tardó 1190 s en estar healthy. Repetida sola con la misma
configuración, tardó 62 s, en línea con los 60 s de la medición de la mañana. El script
consulta el estado cada 2 s, así que 1190 s implican que cada consulta tardaba unos 10 s:
**el daemon de Docker estaba congestionado**, justo cuando CouchDB tampoco podía descargar.
Se da por buena la de 62 s. La lección para el curso: una medición anómala se repite antes de
creerla, y **el tiempo de arranque es contexto, nunca argumento**.

## H4 · TimescaleDB: las funciones del curso no están en la imagen libre

F09 y F10 usan roll-ups continuos y compresión. Esas dos funciones son **Timescale License
(TSL)**, *source-available*, y no vienen en la imagen `-oss` (Apache 2.0). El laboratorio usa
`timescale/timescaledb:2.30.1-pg18`, la imagen con TSL. Es el mismo tipo de licencia que llevó
a descartar ScyllaDB, pero aquí no hay alternativa sin perder justo lo que F09 enseña. Va a
`a10`, y el veredicto de F10 tiene que decirlo: **el particionado declarativo de Postgres no
tiene esta restricción**. Además, el primer arranque deja en el log un error inocuo que conviene
tener en `a09` para que nadie se asuste:

```text
ERROR:  background worker "TimescaleDB Background Worker Scheduler for database 1" trying to connect to template database, exiting
```

## H5 · CockroachDB: un nodo sí, varias regiones con licencia

Desde la 24.3, CockroachDB se distribuye bajo la *CockroachDB Software License* y ya no hay
edición Core. Lo que eso significa para el curso:

- **Un nodo (`start-single-node`) no necesita clave y no se limita.** El laboratorio de F21
  arranca así, y lo medido arriba es eso.
- **Un clúster de varios nodos sí la necesita:** tiene 7 días de gracia y después queda
  **limitado a 5 transacciones SQL concurrentes**. La licencia *Enterprise Free* es gratis
  por debajo de 10 M USD de facturación anual, se renueva cada año y **obliga a enviar
  telemetría**.
- **F21/F22 y el boss del Bloque IV necesitan varias "regiones"**, y por tanto varios nodos.
  Decisión pendiente: o clúster de varios nodos con clave *Enterprise Free* (declarando la
  telemetría), o `cockroach demo` con localidad simulada, que también está exento. **Hay que
  probarlo antes de escribir F21.**

Fuentes: [Licensing FAQs](https://docs.cockroachlabs.com/docs/stable/licensing-faqs) ·
[SD Times](https://sdtimes.com/os/cockroachdb-retires-self-hosted-core-offering-makes-enterprise-version-free-for-companies-under-10m-in-annual-revenue/) ·
[InfoQ](https://www.infoq.com/news/2024/09/cockroachdb-license-concerns/)

## H6 · DuckDB: lectura por columnas visible y el candado del archivo

Con DuckDB 1.5.6 y 2 M filas de 6 columnas, el `EXPLAIN ANALYZE` de una agregación muestra que
el `TABLE_SCAN` **proyecta 3 columnas de 6**: es la tesis de F07 visible en el plan. El punto de
rotura de F08 —un segundo proceso que intenta escribir en el mismo archivo— se reproduce con
este mensaje literal, para `a09`:

```text
IOException: IO Error: Could not set lock on file "…/condor.duckdb": Conflicting lock is held in …/python3.13 (PID 63261) by user oskar. See also https://duckdb.org/docs/stable/connect/concurrency
```

Aviso para `a06`: en macOS y en Windows, `multiprocessing` arranca los procesos hijos
reimportando el script, así que **todo script con procesos necesita la guarda
`if __name__ == "__main__"`**. Sin ella, el hijo reejecuta el script entero y no reporta nada.

## H7 · iovalkey contra Valkey 9.1.2

`iovalkey` 0.4.0 funciona contra Valkey 9.1.2 en todo lo que el curso necesita: el candado
con `SET … NX PX` (el segundo terminal recibe `null`), la liberación atómica en Lua con
`defineCommand` (con el token ajeno devuelve 0 y con el propio, 1) y un pipeline de 100
comandos sin errores. Queda confirmada la decisión 17 del alcance.

## H8 · e5-small: paridad confirmada, prefijos todavía sin demostrar

Revisión fijada: `intfloat/multilingual-e5-small@614241f622f53c4eeff9890bdc4f31cfecc418b3`.
sentence-transformers 6.1.0 (Python, pesos de PyTorch) y `@huggingface/transformers` 4.3.0
(Node, ONNX en fp32, cargado **directamente del repositorio de intfloat**, sin port de
Xenova) dan el mismo vector para el mismo texto: **coseno 1,000000, diferencia máxima
1,5 × 10⁻⁷** en los 5 textos. Queda confirmada la decisión 18.

**Lo que no se confirmó:** la decisión 18 dice que olvidar los prefijos `query:` y `passage:`
es un anti-patrón medible. En esta muestra de 5 reportes **el orden de los resultados no
cambió**: quitar los prefijos solo subió todas las similitudes unos 0,05. No demuestra que los
prefijos den igual —cinco textos no miden recall—, pero tampoco demuestra que importen. **Es una
apuesta falsable para F15**, que se mide sobre el corpus de 26 000 reportes, no un hecho del
curso. Y un segundo aprendizaje sale gratis: **las similitudes de e5 se agolpan entre 0,8 y
0,9**, así que un umbral absoluto del tipo *"parecido si > 0,8"* no significa nada.

## H9 · CouchDB en un nodo: faltan las bases de sistema · 29/09/2026

`couchdb:3.5.2` arranca en 4 s, pero un nodo solo **no crea `_users` ni `_replicator`**, y el log
repite cada 5 s un error de proceso (26 veces en la primera medición):

```text
[notice] … chttpd_auth_cache changes listener died because the _users database does not exist. Create the database to silence this notice.
[error] … Error in process <0.408.0> with exit value:
{database_does_not_exist,[{mem3_shards,load_from_db,[<<"_users">>],…
```

No es cosmético: **sin `_replicator` no hay replicaciones persistentes**, que es justo lo que
F19 enseña. El `compose.yaml` las crea en el healthcheck con `PUT` idempotente (si ya existen,
CouchDB devuelve 412 y se sigue), igual que el `rs.initiate` de Mongo. Con el arreglo, el error
aparece una sola vez antes del primer healthcheck y no vuelve. Medición válida: **5 s y
99 MiB**. El log sin el arreglo se conserva en `logs-darwin-arm64/offline-sin-bases-de-sistema.log`.
Va a `a09` con su mensaje literal y a `a02` como razón del healthcheck.

## H10 · CockroachDB en varias regiones sin licencia: `cockroach demo --global` · 29/09/2026

Es la prueba para la decisión que abrió §H5. `cockroach demo` está exento de licencia, igual que
`start-single-node`, y su modo `--global` levanta nueve nodos en tres regiones simuladas **con
latencia entre regiones inyectada**. Se probó con `cockroachdb/cockroach:v26.3.2`:

```bash
docker run -d --name t10-crdb-demo cockroachdb/cockroach:v26.3.2 \
  demo --nodes=9 --global --insecure --no-example-database -e "SELECT pg_sleep(600)"
```

- **Regiones:** `SHOW REGIONS FROM CLUSTER` devuelve `europe-west1`, `us-east1` y
  `us-west1`, con tres zonas cada una.
- **Localidad en el esquema:** `CREATE DATABASE condor PRIMARY REGION "us-east1" REGIONS
  "us-west1", "europe-west1"` y una tabla `LOCALITY REGIONAL BY ROW` se crean sin error.
- **La física aparece en el `COMMIT`.** Con el gateway en `us-east1` y `EXPLAIN ANALYZE` de
  un `INSERT` de una fila (*insert fast path*, *auto commit*), en seis ejecuciones:

  | Fila en | Tiempo de ejecución en el servidor |
  |---|---|
  | `us-east1` (local) | 67, 68 y 69 ms |
  | `europe-west1` (remota) | 133, 133 y 134 ms |

  Los ~65 ms de diferencia son la latencia simulada entre regiones: **es el número que F22
  necesita, y sale estable**.
- **Sin licencia:** `SHOW CLUSTER SETTING enterprise.license` devuelve vacío, y ni el log ni
  las consultas mencionan limitación ni telemetría.
- **RAM:** los nueve nodos juntos ocupan **1,71 GiB** en reposo.

**Un error de método que conviene contar en F22:** el primer intento midió con el reloj del
host 20 `INSERT` mandados en un solo `-e`, y la fila local salió *más lenta* que la remota
(4,7 s contra 3,9 s). Un lote en un solo `-e` es una sola transacción, y el reloj del host
mide además el arranque del cliente. **La latencia de commit se mide en el servidor, sentencia
por sentencia.**

**Lo que el modo demo no da:** los datos viven en memoria y se pierden al salir, así que cada
sesión recarga desde el generador. Y la latencia es simulada: es fija y reproducible, que para
un curso que mide la forma es una ventaja, pero **no es una red real**, y hay que decirlo.

## H11 · El `compose.yaml` definitivo (`src/lab/`) · 29/09/2026

Verificado con `verificar-lab.sh`: **las diez familias persisten tras `down` y `up`**. Se
escribe un marcador, se apaga sin `-v`, se levanta y el marcador sigue ahí, lo que prueba que
cada volumen está montado donde el motor escribe de verdad. Hacía falta, porque cuatro imágenes
(Valkey, OpenSearch, Qdrant y CockroachDB) no declaran volumen y la ruta sale de su
documentación. Qdrant, sin volumen, avisa en el arranque: `There is a potential issue with the
filesystem for storage path ./storage. Details: Container filesystem detected - storage might
be lost with container re-creation`.

RAM en reposo con el compose definitivo y un marcador escrito (`lab-darwin-arm64.tsv`): base
29 MiB · documental 242 MiB · clave-valor 10 MiB · series 84 MiB · búsqueda 944 MiB · grafos
429 MiB · vectorial 223 MiB · columnar 1,11 GiB · offline 97 MiB · newsql 344 MiB. Documental
y vectorial suben respecto de la tabla de T10 porque ya tienen datos: el replica set de Mongo
con un documento y una colección de Qdrant.

## H12 · `cockroach demo` solo escucha en 127.0.0.1

El perfil `newsql-global` arranca bien como servicio (healthy en 6 s, 1,1–1,4 GiB), pero desde
el host la conexión muere:

```text
failed to connect to `user=root database=`: host.docker.internal:26259 (host.docker.internal): failed to receive message: unexpected EOF
```

Leyendo `/proc/net/tcp` dentro del contenedor: los nueve nodos escuchan en `127.0.0.1` (SQL en
26257–26265 y HTTP en 8080–8088), y `demo` no tiene opción para cambiarlo. Además necesita
`tty: true` y `stdin_open: true`, porque es un shell interactivo y sin terminal termina al
arrancar. **La solución es un sidecar** `alpine/socat` con `network_mode: "service:newsql-global"`,
que escucha en 26300 y reenvía a `127.0.0.1:26257`. Verificado: `SHOW REGIONS FROM CLUSTER`
desde el host devuelve las tres regiones, y el sidecar ocupa menos de 1 MiB.

Y un error para `a09`: CockroachDB 26 restringe las tablas internas.

```text
ERROR: Access to crdb_internal and system is restricted.
SQLSTATE: 42501
HINT: These interfaces are unsupported in production. To proceed, set the session variable allow_unsafe_internals = true (not recommended), or contact Cockroach Labs for a supported alternative.
```

## H13 · Qué cabe a la vez en una VM de 8 GB · 29/09/2026

`combinaciones.sh`, con 7934 MiB en la VM y **otros contenedores ajenos al curso ocupando
~1,25 GiB** al lado. RAM del laboratorio sumada, un minuto después de estar healthy:

| Combinación | Healthy | RAM del laboratorio |
|---|---|---|
| base + búsqueda | 2/2 | 948 MiB |
| base + las tres JVM | 4/4 | 2634 MiB |
| las diez familias | 10/10 | 3516 MiB |
| las diez + `newsql-global` | **el demo muere por OOM** | — |

En el último caso, `up --wait` **devolvió 0**: el demo llegó a healthy y el kernel de la VM lo
mató durante el minuto siguiente (`OOMKilled=true`, sin `mem_limit` propio: fue la VM entera
la que se quedó sin memoria). **Un `--wait` en verde no garantiza que el servicio siga vivo un
minuto después.** Regla para `a02`: `newsql-global` se levanta solo, o con `base`. La columna
de 16 GB no se midió: la VM se dejó en 8 GB a propósito.
