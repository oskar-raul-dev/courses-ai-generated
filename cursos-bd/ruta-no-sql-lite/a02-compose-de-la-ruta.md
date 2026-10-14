# 📎 Apéndice a02 — El `compose.yaml` de la ruta

> **Curso:** Ruta NoSQL Lite · Consulta rápida · **2 h**
> **Usado por:** todas las fases · **Versiones cubiertas:** las diez imágenes de la tabla de
> digests, más `alpine/socat` 1.8.1.3 · Docker Compose v5.5.1
> **Fecha de verificación ejecutada:** 29/09/2026, **en macOS arm64** (Docker Desktop 29.8.0,
> VM de 8 GB). Linux y Windows 11 (WSL2): **no ejecutado todavía en esas plataformas**.

**Esto no se lee de corrido.** Se entra por el índice buscando algo concreto y se sale. Es el
único sitio del curso donde vive una versión: el archivo
[`src/lab/compose.yaml`](src/lab/compose.yaml), del que se levanta solo la familia que toca.

**Qué queda fuera:** instalar Docker y el ciclo de comandos, que es de
[`a01`](a01-laboratorio-contenerizado.md); cargar datos, que es de
[`a05`](a05-el-dominio-de-flota.md); y todo lo que sea orquestación, escalado, redes
personalizadas o secretos. Esto es un laboratorio en una máquina, no un despliegue. Compose por
dentro está en el apéndice a10 del curso *Docker Legacy Node*.

---

## Índice

- [Arrancar en dos comandos](#-arrancar-en-dos-comandos)
- [Perfiles y nombres de servicio](#️-perfiles-y-nombres-de-servicio)
- [Las imágenes: digests y fecha](#-las-imágenes-digests-y-fecha)
- [Healthchecks, y los tres que hacen algo más](#-healthchecks-y-los-tres-que-hacen-algo-más)
- [Puertos](#-puertos)
- [Volúmenes y qué borra `down -v`](#-volúmenes-y-qué-borra-down--v)
- [Memoria: límites y qué cabe a la vez](#-memoria-límites-y-qué-cabe-a-la-vez)
- [`newsql-global`: nueve nodos para F21 y F22](#-newsql-global-nueve-nodos-para-f21-y-f22)
- [El anillo de Cassandra: tres nodos para F17–F18](#️-el-anillo-de-cassandra-tres-nodos-para-f17f18)
- [Postgres con réplica: Bogotá y Quito para F22](#-postgres-con-réplica-bogotá-y-quito-para-f22)
- [`base` con el WAL lógico: la costura de F24](#-base-con-el-wal-lógico-la-costura-de-f24)
- [MongoDB 8.0.20 y el kernel](#-mongodb-8020-y-el-kernel)
- [Cuándo usar qué](#-cuándo-usar-qué)
- [Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-6)

---

## 🚀 Arrancar en dos comandos

```bash
cd src/lab
docker compose --profile base --profile documental up -d --wait
```

`base` es Postgres, la línea base de todas las mediciones: **va siempre**, al lado de la
familia que toque. Si algún puerto choca con algo tuyo, copia `.env.example` como `.env` y cambia
solo ese número (ver Puertos).

---

## 🗂️ Perfiles y nombres de servicio

**Un perfil por familia, y el servicio se llama igual que el perfil.** Se nombran por familia y
no por producto para que cambiar de motor no rompa ni un comando ya escrito en las fases.

| Perfil y servicio | Motor | Fases |
|---|---|---|
| `base` | PostgreSQL 18 + pgvector | todas |
| `documental` | MongoDB | F03–F04 |
| `clave-valor` | Valkey | F05–F06 |
| `series` | TimescaleDB | F09–F10 |
| `busqueda` | OpenSearch | F11–F12 |
| `grafos` | Neo4j Community | F13–F14 |
| `vectorial` | Qdrant | F15–F16 |
| `columnar` | Cassandra | F17–F18 |
| `offline` | CouchDB | F19–F20 |
| `newsql` | CockroachDB, un nodo | F21 |
| `newsql-global` | CockroachDB, nueve nodos en tres regiones | F21 (desde la sección 6.3), F22 y el boss del Bloque IV |

El analítico embebido no tiene perfil: DuckDB corre dentro del proceso de Python, sin servidor
([`a06`](a06-lenguajes-y-drivers.md)). Para apagar todo de una vez está `--profile "*"`.

---

## 📌 Las imágenes: digests y fecha

Cada imagen va fijada por **digest del índice multiarquitectura**, con el tag legible en un
comentario. El mismo digest resuelve a `arm64` en un Mac y a `amd64` en Linux o WSL2, así que el
archivo es uno solo para las tres plataformas. Verificado ejecutando el 29/09/2026:

| Servicio | Tag | Digest |
|---|---|---|
| `base` | `pgvector/pgvector:0.8.6-pg18` (PostgreSQL 18.6) | `sha256:2ba9ca5f2e7daa0f0e7723cba1ee9167bab54efd3640516a44ac1a928dd67e7a` |
| `documental` | `mongo:8.0.20` | `sha256:098862b1339f031900ca66cf8fef799e616d6324fa41b9a263f2ec899552c1ef` |
| `clave-valor` | `valkey/valkey:9.1` (9.1.2) | `sha256:418652cfb58ef879d4978c33553735d7147016032d5aefaa14c828e611eb9dfd` |
| `series` | `timescale/timescaledb:2.30.1-pg18` | `sha256:9dede0e3ccc071cf71935b17f76bf243331df0b1575338c8ac294640fcf12a36` |
| `busqueda` | `opensearchproject/opensearch:3.8.0` | `sha256:fafe3fc3587088674669235575aa166228c48bdb940294a8cdbbc1da75236a40` |
| `grafos` | `neo4j:2026.09.0-community` | `sha256:91fb0bf237c41b7b3dcbe84703aa0b82e0d7d067b16e1c8ab21f03fc679edf4e` |
| `vectorial` | `qdrant/qdrant:v1.19.1` | `sha256:12364fe851b9f17356fc88189fc06d1b521262e04659ec7345975b00c9246a10` |
| `columnar` | `cassandra:5.0` (5.0.9) | `sha256:8819d1b7877ee6621751a761cc163332e9c3eaf671c8ef672f7c77a7c5bff05f` |
| `offline` | `couchdb:3.5.2` | `sha256:8cf5f8442585c346d2717ff0ad95605731d2f19f67b8367840baa8d3b24ebc31` |
| `newsql`, `newsql-global` | `cockroachdb/cockroach:v26.3.2` | `sha256:bc15746ef2c2493b2cfd46a76898a745587d068b1a259fff3c4447c3f3b36ea2` |
| `newsql-global-puerta` | `alpine/socat` (1.8.1.3) | `sha256:5ffbd6ae916cbad86a58fabe0d6d5a6fd5c2b47ddf031e82996baac9300e732f` |

> 📝 **Tres imágenes con historia de licencia**, y las tres están explicadas en
> [`a10`](a10-licencias-y-riesgo.md): TimescaleDB usa la imagen **con Timescale License** y no la
> `-oss`, porque los roll-ups continuos y la compresión de F09 son TSL; CockroachDB es libre en
> un nodo y en modo `demo`, pero no en un clúster; y Cassandra está aquí, en lugar de ScyllaDB,
> justamente por licencia.

**Actualizar una imagen es cambiar una línea:** el digest nuevo, el tag del comentario y la fecha
de este apéndice. Y volver a ejecutar las pruebas de la sección de Volúmenes antes de dar por
buena la actualización.

---

## 🩺 Healthchecks, y los tres que hacen algo más

Todos los servicios tienen healthcheck, y por eso `up -d --wait` devuelve **cuando el motor
acepta conexiones**, no cuando el contenedor arrancó. La mayoría solo comprueba (`pg_isready`,
`valkey-cli ping`, `cqlsh`, `cypher-shell`, `curl` a la API…). Tres hacen algo más, y conviene
saber por qué antes de tocarlos:

**`documental` inicia el replica set.** Mongo arranca con `--replSet rs0`, y el healthcheck, la
primera vez, ejecuta `rs.initiate()`; después solo comprueba. Sin replica set **no hay
transacciones multi-documento**, y F04 las necesita. Lo que pasa sin él es parte de F04, y el
error literal está en [`a09`](a09-catalogo-de-errores.md).

**`offline` crea las bases de sistema de CouchDB.** Un nodo solo no crea `_users` ni
`_replicator`, y el log repite esto cada 5 s:

```text
[notice] … chttpd_auth_cache changes listener died because the _users database does not exist. Create the database to silence this notice.
[error] … Error in process <0.408.0> with exit value:
{database_does_not_exist,[{mem3_shards,load_from_db,[<<"_users">>],…
```

No es cosmético: sin `_replicator` no hay replicaciones persistentes, que la
[Fase 19](19-offline-levantar-y-modelar.md) usa en su sección 6.3.
El healthcheck hace `PUT` de las dos bases —si ya existen, CouchDB responde 412 y sigue— y
después comprueba `/_up`. La documentación de CouchDB nombra una tercera, `_global_changes`, que
solo alimenta el feed de cambios de todo el servidor; el curso no la usa y no se crea. También
documenta una alternativa, `[couchdb] single_node = true` en la configuración, que el curso **no
ha verificado**.

**`vectorial` no tiene `curl`.** La imagen de Qdrant no lo trae, así que el healthcheck abre el
puerto con `bash` y lee la respuesta de `/readyz`. Si ves ese bloque raro en el archivo, es
eso y nada más.

---

## 🔌 Puertos

**Los puertos del host están desplazados** para que el laboratorio arranque a la primera aunque
ya tengas un Postgres, un Mongo o un Redis instalados. Dentro de la red del laboratorio, los
servicios usan su puerto de siempre; el desplazamiento solo afecta a lo que corre en tu máquina.

| Servicio | En tu máquina | Dentro | Variable |
|---|---|---|---|
| `base` | 15432 | 5432 | `BASE_PORT` |
| `documental` | 27018 | 27017 | `DOCUMENTAL_PORT` |
| `clave-valor` | 16379 | 6379 | `CLAVE_VALOR_PORT` |
| `series` | 15433 | 5432 | `SERIES_PORT` |
| `busqueda` | 19200 | 9200 | `BUSQUEDA_PORT` |
| `grafos` | 17474 (HTTP), 17687 (Bolt) | 7474, 7687 | `GRAFOS_HTTP_PORT`, `GRAFOS_BOLT_PORT` |
| `vectorial` | 16333 (HTTP), 16334 (gRPC) | 6333, 6334 | `VECTORIAL_HTTP_PORT`, `VECTORIAL_GRPC_PORT` |
| `columnar` | 19042 | 9042 | `COLUMNAR_PORT` |
| `offline` | 15984 | 5984 | `OFFLINE_PORT` |
| `newsql` | 26258 (SQL), 18080 (consola) | 26257, 8080 | `NEWSQL_PORT`, `NEWSQL_UI_PORT` |
| `newsql-global` | 26259 (n1, `us-east1`), 26260 (n4, `us-west1`), 26261 (n7, `europe-west1`) | 26257, 26260 y 26263, a través del sidecar | `NEWSQL_GLOBAL_PORT`, `NEWSQL_GLOBAL_PORT_2`, `NEWSQL_GLOBAL_PORT_3` |
| `primario` y `replica` (`compose.replica.yaml`) | 15440, 15441 | 5432 | `REPLICA_PRIMARIO_PORT`, `REPLICA_LECTURA_PORT` |

**Si aun así choca:** `cp .env.example .env` y cambia solo el número que moleste. El diagnóstico
de un puerto ocupado está en [`a01`](a01-laboratorio-contenerizado.md).

**Credenciales del laboratorio:** `postgres` / `condor` en `base` y `series`; `neo4j` /
`condor-mro` en `grafos`; `condor` / `condor` en `offline`. El resto va sin autenticación.

> ⚠️ **Son credenciales de laboratorio, en claro y en el repositorio.** Nada de este archivo se
> expone fuera de tu máquina.

---

## 💾 Volúmenes y qué borra `down -v`

Cada familia con servidor tiene su volumen con nombre, `condor-lab_<familia>-data`, montado en la
ruta donde el motor escribe. **Verificado el 29/09/2026 en las diez familias:** se escribe un
marcador, se apaga sin `-v`, se vuelve a levantar y el marcador sigue ahí.

Hizo falta comprobarlo una por una porque **cuatro imágenes no declaran volumen** —Valkey,
OpenSearch, Qdrant y CockroachDB—, y un volumen montado en la ruta equivocada no falla: solo
pierde los datos en silencio al recrear el contenedor. Qdrant es el único que avisa:

```text
WARN qdrant: There is a potential issue with the filesystem for storage path ./storage. Details: Container filesystem detected - storage might be lost with container re-creation
```

**`down` conserva los volúmenes; `down -v` los borra.** Con el perfil, solo los de esa familia.
`newsql-global` es la excepción: no tiene volumen, sus datos viven en memoria y **se pierden
siempre al apagar**.

La prueba es reproducible con [`src/lab/check/verificar-lab.sh`](src/lab/check/verificar-lab.sh): para
cada familia escribe un marcador, apaga sin `-v`, levanta y comprueba que el marcador sigue. **Corre en un
proyecto de compose aparte (`condor-lab-check`)** con sus propios volúmenes, así que su `down -v` nunca
toca los datos que cargaste en el laboratorio; como usa los mismos puertos, antes se detiene el
laboratorio con `docker compose stop`. Deja su registro en `src/lab/data/`.

---

## 🧠 Memoria: límites y qué cabe a la vez

**Solo las tres familias sobre JVM llevan límite de memoria**, porque son las únicas que pueden
tumbar la máquina, y las tres llevan además el heap fijado:

| Servicio | Heap | `mem_limit` | En reposo |
|---|---|---|---|
| `columnar` | 512 MB (`MAX_HEAP_SIZE`) | 1600 MB | 1,11 GiB |
| `busqueda` | 512 MB (`OPENSEARCH_JAVA_OPTS`) | 1400 MB | 920 MiB |
| `grafos` | 512 MB, más 256 MB de page cache | 1 GB | 487 MiB |

**El heap de Cassandra no es opcional.** Sin `MAX_HEAP_SIZE`, Cassandra calcula el heap a partir
de la RAM de la máquina, y en reposo ocupó **4,63 GiB**. **El límite tampoco es un número
cualquiera.** Con 600 MB, OpenSearch muere con `Exited (137)` y `OOMKilled=true`, porque la JVM
gasta memoria fuera del heap. Con 1200 MB arrancó al 88 %, y por eso el archivo le da 1400.

Los límites están medidos en reposo. **Bajo la carga de las fases B pueden quedarse cortos**, y
si una fase los sube, lo dice y lo justifica.

**RAM en reposo de las familias sin límite**, con el compose definitivo y un dato escrito (las de la tabla
de arriba y `newsql`, medidas de nuevo el 14/10/2026 tras estabilizarse; el resto, del 29/09/2026):
`base` 29 MiB · `clave-valor` 10 MiB · `series` 84 MiB · `offline` 97 MiB · `vectorial`
223 MiB · `documental` 242 MiB · `newsql` 420 MiB · `newsql-global` 1,1–1,4 GiB vacío, y hasta 4,8 GiB con una
base de `workOrder-10k` y las réplicas moviéndose ([Fase 21](21-newsql-levantar-y-modelar.md)).

**Qué cabe a la vez en una VM de 8 GB**, medido el 29/09/2026 con otros contenedores ajenos al
curso ocupando ~1,25 GiB al lado:

| Combinación | Resultado | RAM del laboratorio |
|---|---|---|
| `base` + una familia JVM | ✅ | ~950 MiB |
| `base` + las tres JVM | ✅ | 2,57 GiB |
| las diez familias a la vez | ✅ las diez healthy | 3,43 GiB |
| las diez + `newsql-global` | ❌ el demo muere por OOM al minuto | — |

**En 16 GB: no medido.** La suma en reposo —3,43 GiB más 1,4 GiB del demo— sugiere que todo cabe
con holgura, pero es una estimación, no una medición.

> ⚠️ **Un `--wait` en verde no garantiza que el servicio siga vivo un minuto después.** En el
> último caso de la tabla, `up -d --wait` devolvió 0: el demo llegó a healthy, y el kernel de la
> VM lo mató durante el minuto siguiente. `docker compose ps -a` lo delata con `Exited (137)`.

**La regla práctica:** `base` más la familia de la fase, siempre. Todo el laboratorio a la vez
cabe en 8 GB. **`newsql-global` se levanta solo, o con `base`.**

**`base` lleva `shm_size: 2560m`**, añadido el 30/09/2026 por la [Fase 16](16-vectorial-romper-y-medir.md).
Docker le da a cada contenedor un `/dev/shm` de 64 MB, y Postgres construye un índice en paralelo en
memoria compartida: el HNSW de un millón de vectores con `maintenance_work_mem` de 2 GB falló con
`could not resize shared memory segment … No space left on device` ([`a09`](a09-catalogo-de-errores.md)
E-35). No es un límite de memoria: es el tamaño máximo de ese sistema de archivos, y solo se ocupa
mientras se construye el índice.

---

## 🌍 `newsql-global`: nueve nodos para F21 y F22

F21 pone la geografía en el esquema y F22 mide la latencia de commit entre regiones, y para las dos hacen falta
varias regiones. Este perfil levanta `cockroach demo --nodes=9 --global`: nueve nodos en tres regiones simuladas
(`us-east1`, `us-west1` y `europe-west1`) **con latencia entre regiones inyectada**, y **exento de licencia** (por
qué, en [`a10`](a10-licencias-y-riesgo.md)). Los nueve nodos son **un solo proceso**, y sus datos viven en memoria.

```bash
docker compose --profile newsql-global up -d --wait
```

Tiene tres piezas raras, y las tres son necesarias:

- **`tty: true` y `stdin_open: true`**, porque `demo` es un shell interactivo y, sin terminal,
  termina en cuanto arranca.
- **Un sidecar, `newsql-global-puerta`**, porque `demo` solo escucha en `127.0.0.1` y no tiene
  opción para cambiarlo. Publicar el puerto a secas no sirve: desde tu máquina, la conexión muere
  con `failed to receive message: unexpected EOF`. El sidecar es `socat`, comparte la red del
  demo (`network_mode: "service:newsql-global"`) y **publica un nodo de cada región**: el 26259 llega a n1
  (`us-east1`), el 26260 a n4 (`us-west1`) y el 26261 a n7 (`europe-west1`). La
  [Fase 21](21-newsql-levantar-y-modelar.md) le agregó las dos últimas, porque medir "desde dónde se escribe" exige
  entrar por un nodo de esa región. Ocupa menos de 10 MiB.
- **La memoria acotada.** Con los valores por defecto (caché de 64 MiB y memoria SQL de 256 MiB **por nodo**) y dos
  bases de `workOrder-10k`, el demo pasó de 5,9 GiB y lo mató el OOM de la VM. El compose le baja la caché a 32 MiB
  (`--cache=32MiB`) y le pone `GOMEMLIMIT: 3GiB`, que obliga al recolector de Go a trabajar antes. Llegar ahí costó
  dos intentos que no sirvieron: **la memoria SQL a 64 MiB por nodo** dejó la creación de un índice en
  `Backfilling index` para siempre, sin ningún error, y **`GOMEMLIMIT` en 4500 MiB** dejó morir por OOM dos corridas de
  once, con picos de 4,8 GiB en las que sobrevivieron. Con 3 GiB, el camino completo de la
  [Fase 21](21-newsql-levantar-y-modelar.md) —cargar una base, restringir la ubicación, medir las regiones y el
  reloj— terminó en 674 s con un pico de 3,6 GiB. Una corrida no prueba que no vuelva a pasar: la Fase 21 trabaja con
  **una base por demo recién creado**, y si una conexión se corta sola, `docker inspect condor-lab-newsql-global-1
  --format '{{.State.OOMKilled}}'` dice si fue la memoria.

La prueba de que funciona, desde tu máquina:

```text
$ cockroach sql --insecure --host=localhost:26259 -e "SHOW REGIONS FROM CLUSTER"
     region    |  zones
---------------+----------
  europe-west1 | {b,c,d}
  us-east1     | {b,c,d}
  us-west1     | {a,b,c}
(3 rows)
```

(En la verificación el cliente corrió en un contenedor, con `--host=host.docker.internal:26259`;
desde un `cockroach` instalado en tu máquina, el host es `localhost`.)

**El demo también se puede matar solo.** En la [Fase 22](22-newsql-romper-y-medir.md), dos demos terminaron con
código 7, sin OOM, con `clock synchronization error: this node is more than 400ms away from at least half of the
known nodes` (E-76 en [`a09`](a09-catalogo-de-errores.md)). Los nueve nodos comparten el reloj de tu máquina: lo que
se atrasa es un latido, por una pausa del proceso o de la VM, y el nodo no lo distingue de un reloj desfasado.
`demo` no acepta la opción que apaga ese chequeo. Si pasa, se recrea el demo y se vuelve a cargar.

---

## 🏛️ El anillo de Cassandra: tres nodos para F17–F18

El servicio `columnar` es un nodo solo, y en un nodo la consistencia ajustable no tiene a quién referirse.
Para ejecutarla, `src/lab/compose.anillo.yaml` levanta **tres nodos** de la misma imagen y con el mismo heap
fijado, en un proyecto de compose aparte (`condor-anillo`):

```bash
docker compose -f lab/compose.anillo.yaml up -d --wait      # desde src/
docker compose -f lab/compose.anillo.yaml exec c1 nodetool status
docker compose -f lab/compose.anillo.yaml down -v
```

Tres decisiones, cada una por algo que pasa si no se toma:

- **Proyecto aparte**, para que su `down -v` borre solo sus tres volúmenes y nunca los del laboratorio.
- **Sin puertos publicados.** Cada nodo se anuncia con su dirección de la red de Docker, que desde tu máquina
  no existe (el mismo problema de E-03 en [`a09`](a09-catalogo-de-errores.md)); se entra con `docker compose
  exec … cqlsh`.
- **Los nodos entran de uno en uno** (`depends_on` con `service_healthy`): Cassandra desaconseja que dos nodos
  se unan al anillo a la vez.

**Lo que cuesta**, medido el 10/10/2026: **207 s** hasta que el tercero está sano, y en reposo
**1,22, 1,16 y 1,14 GiB**, unos 3,5 GiB. **Con el laboratorio detenido**: no cabe al lado de los otros
motores JVM, y la [Fase 17](17-columnar-levantar-y-modelar.md) lo usa así.

---

## 🔁 Postgres con réplica: Bogotá y Quito para F22

La línea base bien jugada de la [Fase 22](22-newsql-romper-y-medir.md) es un primario y una réplica de lectura por
*streaming*. `src/lab/compose.replica.yaml` los levanta en un proyecto aparte (`condor-replica`), como el anillo, con
la misma imagen de `base`:

```bash
docker compose -f lab/compose.replica.yaml up -d --wait      # desde src/
docker compose -f lab/compose.replica.yaml exec primario psql -U postgres -c "SELECT client_addr, state FROM pg_stat_replication"
docker compose -f lab/compose.replica.yaml down -v
```

Dos detalles. El primario agrega al crearse una línea a `pg_hba.conf` para dejar entrar a la réplica
(`replica/primario-replicacion.sh`), y la réplica se copia la primera vez con `pg_basebackup -R`
(`replica/replica.sh`). Y cada uno vive en su red —`bogota` y `quito`— con una tercera, `enlace`, entre los dos:
cortar el enlace es `docker network disconnect condor-replica_enlace condor-replica-primario-1`, y reponerlo, **con su
nombre**: `docker network connect --alias primario …`. Sin el alias, la réplica no vuelve a encontrar al primario
(E-77). Con el expediente cargado, ocupan 54 y 64 MiB.

---

## 🧵 `base` con el WAL lógico: la costura de F24

El CDC de la [Fase 24](24-poliglota-la-costura.md) lee el WAL con un slot lógico, y eso exige `wal_level=logical`.
`base` corre con el nivel por defecto, `replica`. El cambio no va en `compose.yaml`: va en
`src/lab/compose.costura.yaml`, que **se suma** al compose del laboratorio y cambia solo el comando de `base`. No es
un proyecto aparte, como la réplica o el anillo: usa el mismo volumen y los mismos datos.

```bash
docker compose -f lab/compose.yaml -f lab/compose.costura.yaml --profile base --profile offline up -d --wait   # desde src/
docker compose -f lab/compose.yaml exec base psql -U postgres -c "SHOW wal_level"                                     # logical
```

Va en su propio archivo por las mediciones de WAL de las fases [10](10-series-romper-y-medir.md) y
[18](18-columnar-romper-y-medir.md), hechas con `replica`: el nivel lógico escribe algo más en algunos registros, y
esas cifras tienen que seguir reproduciéndose con el compose de siempre. Cambiar de nivel reinicia `base`.

**Antes de volver al compose de siempre, borra los slots lógicos** (`node 24-poliglota-la-costura/setup.ts --drop`).
Con uno vivo y `wal_level=replica`, Postgres no arranca ([E-81](a09-catalogo-de-errores.md#e-81--un-slot-lógico-que-no-deja-arrancar)).

---

## 🍃 MongoDB 8.0.20 y el kernel

**`documental` está fijado en la 8.0.20 exacta, y es un parche temporal.** Desde la 8.0.21,
MongoDB comprueba la versión del kernel al arrancar y **se niega a arrancar** sobre los kernels
6.19 a 7.0.13:

```text
MongoDB cannot start: Linux kernel versions 6.19 and newer has a known incompatibility with this version of MongoDB. See https://jira.mongodb.org/browse/SERVER-121912 for more information.
```

Docker Desktop 29.8.0 trae el kernel `7.0.12-linuxkit`, justo dentro del rango. La causa de fondo
es un cambio de `rseq` en el kernel 6.19 que rompió la caché por CPU del TCMalloc que MongoDB 8
lleva dentro. Linux lo trató como regresión, y el comportamiento anterior volvió en la 7.0.14.

| MongoDB | Kernel 6.19 a 7.0.13 | Kernel 7.0.14 o posterior |
|---|---|---|
| 8.0.0 a 8.0.20 | **arranca**, pero expuesta al fallo de fondo | arranca |
| 8.0.21 a 8.0.29 | se niega a arrancar | se niega a arrancar |
| 8.0.30 o posterior | se niega a arrancar | arranca |

**La 8.0.20 arranca porque es anterior a la protección, no porque esté arreglada.** Por eso se
probó con carga en esta VM el 29/09/2026: 32 trabajadores durante 10 minutos, 19 323 operaciones
y 1,29 M de documentos, **sin una sola caída ni un reinicio**. Los reportes del fallo hablan de
caídas cada ~30 s bajo migraciones de CPU, así que es evidencia fuerte de que aquí no se dispara;
no es una prueba de ausencia. **Suficiente para el laboratorio del curso, no para producción.**

**Cuándo se deshace:** cuando `docker info --format '{{.KernelVersion}}'` devuelva 7.0.14 o
posterior, se vuelve a la 8.0 vigente. En Linux decide el kernel de tu host (`uname -r`); en
WSL2, el que instala `wsl --update`.

---

## 🧭 Cuándo usar qué

| Situación | Perfiles | Nota |
|---|---|---|
| Una fase A o B de cualquier familia | `base` + la familia | lo normal |
| F21 (desde la sección 6.3), F22 y el boss del Bloque IV | `newsql-global`, con `base` o el par de `compose.replica.yaml` si hace falta | nada más arriba, y **una base a la vez** en un demo recién creado |
| Boss de un bloque | `base` + las familias del bloque | el Bloque II tiene una sola familia sobre JVM (búsqueda), pero el boss junta tres motores: vigila la RAM |
| Capstone (F23–F25) | los que decida tu diseño, sin `newsql-global` | todo el laboratorio cabe en 8 GB; la F24, con `compose.costura.yaml` sumado |
| Apagar todo | `--profile "*" down` | conserva los datos |
| Empezar una familia de cero | `--profile <familia> down -v` | datos regenerables con [`a05`](a05-el-dominio-de-flota.md) |
| Actualizar una imagen | digest, comentario y fecha, y `verificar-lab.sh` | un volumen mal montado no falla: pierde datos |

---

## ⚠️ Advertencias

- **No cambies el nombre del proyecto** (`name: condor-lab`). Los volúmenes llevan ese prefijo, y
  con otro nombre Compose crea volúmenes nuevos y vacíos sin avisar.
- **Los tiempos de arranque dependen de lo que haya arriba.** Cassandra tarda unos 60 s sola; en
  la verificación, con el daemon congestionado, tardó 1190 s.
- **Linux y WSL2 no están verificados todavía.** El archivo es el mismo, pero la memoria
  disponible, el kernel (y con él MongoDB) y los permisos de volumen pueden cambiar el resultado.

---

## 📚 Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación de estos productos suele cubrir solo
> la última versión. Este apéndice se verificó con las versiones de la tabla de digests.

- **Compose: perfiles** — https://docs.docker.com/compose/how-tos/profiles/
- **Compose: `up --wait` y healthchecks** — https://docs.docker.com/reference/cli/docker/compose/up/
- **Compose: `network_mode: service:`** — https://docs.docker.com/reference/compose-file/services/#network_mode
- **Imagen oficial de PostgreSQL**, el cambio de `PGDATA` en la 18 — https://hub.docker.com/_/postgres
- **Cassandra en Docker**, heap y variables — https://hub.docker.com/_/cassandra
- **OpenSearch en Docker** — https://docs.opensearch.org/latest/install-and-configure/install-opensearch/docker/
- **Neo4j: configuración por variables de entorno** — https://neo4j.com/docs/operations-manual/current/docker/configuration/
- **CouchDB en un nodo** y sus bases de sistema — https://docs.couchdb.org/en/stable/setup/single-node.html
- **`cockroach demo`** — https://docs.cockroachlabs.com/docs/stable/cockroach-demo
- **SERVER-121912** y **SERVER-125742** — https://jira.mongodb.org/browse/SERVER-121912 ·
  https://jira.mongodb.org/browse/SERVER-125742

**Orden sugerido:** la tabla de perfiles antes de la primera fase; Memoria antes de levantar más
de una familia JVM; y MongoDB y el kernel cada vez que actualices Docker Desktop.

---

## 🧪 Ejercicios (6)

### 🟢 Ejercicio 1 — El laboratorio mínimo

Levanta `base` y `documental` con `--wait` y conéctate a los dos **desde tu máquina**, por los
puertos desplazados.

**Objetivo:** confirmar que los dos responden en 15432 y 27018, y saber sin mirar la tabla qué
puerto de la red interna usan.

### 🟢 Ejercicio 2 — Un puerto propio

Crea un `.env` que mueva `base` al 25432 y vuelve a levantar.

**Pregunta:** ¿hizo falta tocar `compose.yaml`? ¿Cambió algo para los demás servicios de la red
del laboratorio?

### 🟡 Ejercicio 3 — La prueba de persistencia, a mano

Con `clave-valor` arriba, haz `SET lab:marker 42`, después `down` sin `-v`, levanta de nuevo y haz
`GET`. Repite con `down -v`.

**Objetivo:** ver qué conserva cada uno. **Pregunta:** ¿qué hace falta para que Valkey guarde el
dato al apagar, si no tiene AOF activado? (Se retoma en F06.)

### 🟡 Ejercicio 4 — El replica set que no se ve

Levanta `documental`, entra con `mongosh` y ejecuta `rs.status().members[0].stateStr`.

**Objetivo:** encontrar en `compose.yaml` qué lo inició, y explicar qué dejaría de funcionar en
F04 si quitaras `--replSet`.

### 🟠 Ejercicio 5 — Lo que cabe en tu máquina

Levanta las tres familias JVM con `base`, espera un minuto y toma `docker stats --no-stream`.
Después añade `newsql-global`.

**Objetivo:** comparar tus números con la tabla de Memoria y, si algo muere, confirmar con
`docker compose ps -a` y `docker inspect` que fue OOM, aunque `--wait` haya devuelto 0.

### 🔴 Ejercicio 6 — Actualizar una imagen sin romper nada

Elige un servicio, busca su tag vigente más reciente y cambia el digest. Ejecuta
`check/verificar-lab.sh <familia>` desde `src/lab` para ese servicio.

**Objetivo:** decidir, con la prueba de persistencia y la RAM en reposo delante, si la
actualización se queda. **Pregunta:** si eligieras `documental`, ¿qué versión podrías poner hoy en
tu máquina, y por qué?

---

> 🏷️ **Este apéndice deja un archivo en el repositorio**: `src/lab/compose.yaml`, con su
> `.env.example`. El commit se etiqueta `apendice-a02-compose`.
