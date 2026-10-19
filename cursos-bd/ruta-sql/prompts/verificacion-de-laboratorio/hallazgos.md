# 🔬 Hallazgos de la verificación de laboratorio (P8) y de las fuentes (P9)
## Ruta SQL

> **Qué es esto:** lo que apareció al levantar de verdad los servicios del laboratorio —versiones,
> digests, memoria, emulación, errores con su mensaje literal— y lo que dicen hoy los libros base y
> las licencias. Es la fuente de la que beben `a01` (emulación), `a02` (digests y tabla de RAM),
> `a05` (perfiles y generador), `a06` (drivers), `a08` (errores) y `a09` (licencias).
> **Cómo se reproduce:** los scripts, el `compose.yaml` de prueba, los *logs* y las salidas crudas
> están en el directorio de la sesión, `zz-code/ruta-sql-20261011-2b0e/`, con su `README.md` de corrida
> y medición. Este archivo vive en `prompts/` y no viaja al repositorio público.
> **Plataforma:** macOS 26.7.1 en Apple M1 Pro (32 GB), Docker Desktop con motor 29.8.0, VM de
> 7,75 GiB y 8 CPU con kernel `7.0.12-linuxkit`; Podman 6.1.3. Linux y Windows 11 con WSL2 quedan
> sin verificar (D-06), declarados como pendiente transversal.
> **Regla de publicación:** ningún tiempo de carga ni de consulta de Oracle ni de SQL Server aparece
> aquí (alcance §6.1, que se mantiene por D20). Sí aparecen su arranque y su memoria, que son datos de
> dimensionamiento del laboratorio y que `a02` publica.
> **Vigencia:** 2026-10-11.

---

## 📊 Resultados · macOS arm64 · 11/10/2026

Cada servicio se midió con la configuración del `compose.yaml` de prueba: tiempo desde `up` hasta el
primer *healthcheck* verde (**sin la descarga**) y memoria en reposo un minuto después, según `docker
stats`. Los tiempos son contexto, nunca argumento.

| Perfil | Servicio | Imagen elegida | Arquitectura | Listo en | RAM en reposo |
|---|---|---|---|---|---|
| `base` | `postgres` | `pgvector/pgvector:0.8.7-pg18` (Postgres 18.6) | arm64 nativa | 3 s | 130 MiB |
| `contraste` | `mysql` | `mysql:9.7.2` (§H1) | arm64 nativa | 9 s | 488 MiB |
| `oracle` | `oracle` | `gvenzl/oracle-free:23.26.3-slim-faststart` (§H3) | arm64 nativa | 39 s | 2,40 GiB |
| `mongo` | `mongo` | `mongo:8.0.20` (§H2) | arm64 nativa | 4 s | 88 MiB |
| `api` | `api` | `postgrest/postgrest:v16.4` (§H8) | arm64 nativa | 8 s | 18 MiB |
| `puente` | `broker` | `apache/artemis:2.57.0` (§H9) | arm64 nativa | 3 s | 364 MiB |
| `puente` | `bridge` | `eclipse-temurin:25.0.4.1_1-jdk-noble` (§H13) | arm64 nativa | — | sin medir (T11) |
| `sqlserver` | `sqlserver` | `mcr.microsoft.com/mssql/server:2025-CU9-ubuntu-24.04` (§H4) | **amd64, con Rosetta** | 14 s | 996 MiB |

**Digests**, tal como los resolvió Docker Hub, MCR o GHCR el 11/10/2026:

| Imagen | Digest |
|---|---|
| `pgvector/pgvector:0.8.7-pg18` | `sha256:2358fcba361ed2233a5ed81b5fe4ca779ccb304120ce531a3bf51c0ed7e2bc11` |
| `postgres:18.6` (descartada, sin `vector`) | `sha256:74935e72241653ca55e0414067e6d8763aceb8a810eb51b452253ec3dcfc4336` |
| `mysql:9.7.2` | `sha256:e2bde46db6563855d7177adb5f0b57b9dc663f5a20927a90f4259d3312068497` |
| `mysql:8.4.11` (descartada: la LTS anterior, §H1) | `sha256:6ea90827b1100f8f2ae306a539f86d2c264a26ed435a2a9f75551dd5c3aeb242` |
| `gvenzl/oracle-free:23.26.3-slim-faststart` | `sha256:f5ff19033860d662c821cb04eb10483fa94f14f78eae252d054291ea07028093` |
| `container-registry.oracle.com/database/free:latest` (descartada, §H3) | `sha256:f988b0c04c4c386cd306a2a914c0d7a9702d83acc31b064a28ad8eb6278a8fba` |
| `mongo:8.0.20` | `sha256:098862b1339f031900ca66cf8fef799e616d6324fa41b9a263f2ec899552c1ef` |
| `mongo:9.0.2` (no arranca, §H2) | `sha256:bac22ea7710d774103dcad3ec8ac13cba1eb378f488e3ce8a6b3a1adf2ba9dcc` |
| `postgrest/postgrest:v16.4` | `sha256:d155c6718ed9a9f990d159a2ab7c0a3f16944dbb6d0a0344557421042acfe0df` |
| `apache/artemis:2.57.0` | `sha256:0f32b054e1f4adc45fc64824ebb0586579ffd563ce37d75b5a10d27db19a3889` |
| `eclipse-temurin:25.0.4.1_1-jdk-noble` | `sha256:589ff4cc3f71aab462e7048a47a0d10edf57fbccde3fceea2281e610bf5880b4` |
| `mcr.microsoft.com/mssql/server:2025-CU9-ubuntu-24.04` | `sha256:2b5b581621126574f3d1f75e78d3eebe8d05aedb59ad0cfdf9aa42cb0634d726` |
| `ghcr.io/astral-sh/uv:0.11.14-python3.13-trixie-slim` (solo para las pruebas) | `sha256:0f373734b28e2dea75993003daacf1badd7aa88f3ba88e8d1b4779dabf54ad08` |

### 🧮 La tabla de RAM

Con el perfil M cargado en los tres motores (§H12) y después de un recorrido completo de
`ResultadoItem` en cada uno:

| Combinación | Medido | Suma con el pico de cada servicio |
|---|---|---|
| `base` + `contraste` + `oracle` (los tres motores, M cargado) | 292 MiB + 930 MiB + 1,19 GiB ≈ **2,4 GiB** | ≈ 3,6 GiB (Oracle recién creado llega a 2,4 GiB) |
| todos los perfiles a la vez, M cargado | ≈ **3,0 GiB** | ≈ **5,3 GiB** |
| `base` + `sqlserver` (el track) | 130 MiB + 996 MiB | ≈ 1,2 GiB |

**La lectura para `a02`:** un Mac de 16 GB da por defecto a Docker Desktop una VM de 8 GB, y en esa
VM **entra el laboratorio entero**, con M cargado y todos los perfiles arriba, con más de 2 GB de
margen. El requisito de 16 GB del alcance §4 se sostiene. `docker stats` no cuenta la caché de
archivos de la VM, y Oracle oscila mucho (2,40 GiB recién creado, 0,78–1,19 GiB después): `a02`
publica el pico, no el promedio. Con **dos Oracle a la vez** (las dos imágenes del §H3) más los
contenedores de otro curso, la VM se llenó y `sqlplus` dejó de responder: es el ejercicio de `a01`
del contenedor que no llega a *healthy*, servido.

---

## H1 · Las versiones según D12 · 11/10/2026

La última estable de cada producto, o la última LTS donde el fabricante tiene esa línea, comprobadas
en su registro de imágenes y en la página del fabricante:

| Producto | Elegida | Por qué | Lo que se descartó |
|---|---|---|---|
| PostgreSQL | **18.6** | la última estable; la 19 está en `19beta4` | — |
| MySQL | **9.7.2 LTS** | 9.7 es la LTS de la serie 9 desde el 21/04/2026 (soporte *premier* hasta el 30/04/2031) | 8.4 (la LTS anterior, que el alcance nombraba) y 26.7 (*innovation*, la primera con versión de calendario) |
| Oracle Database Free | **23.26.3**, que el banner llama "Oracle AI Database 26ai Free" | la única línea de Free | — |
| MongoDB | **8.0.20**, como parche temporal (§H2) | 9.0.2, la última, no arranca con el kernel de Docker Desktop | 9.0.2 y 8.0.32 |
| PostgREST | **v16.4** | la última | v14.18, rama de mantenimiento |
| Apache Artemis | **2.57.0** | la última; el proyecto dejó de llamarse ActiveMQ Artemis (§H9) | `apache/activemq-artemis`, congelada en 2.44.0 |
| SQL Server | **2025 CU9** (17.0.5005.3) | el último CU de la última versión | — |
| Java | **25 LTS** (Temurin 25.0.4.1) | la última LTS; Oskar la eligió sobre Java 21 (D19) | 21 |

**MySQL 9.7 cambia una línea del alcance** (§8 decía "MySQL (8.4 LTS)") y nada del temario: lo que
el curso usa de MySQL existe en las dos. Trae al *Community* el optimizador *hypergraph* y DML sobre
*JSON Duality Views*, que F13 y F19 pueden nombrar sin depender de ellos.

---

## H2 · MongoDB 9.0 no arranca en Docker Desktop · 11/10/2026

El mismo hallazgo que la NoSQL Lite registró el 29/09/2026 (su §H1), y con el mismo kernel
`7.0.12-linuxkit`: `mongo:9.0.2` termina en el arranque, a propósito.

```text
{"t":{"$date":"2026-10-11T22:57:24.123+00:00"},"s":"F",  "c":"CONTROL",  "id":12257600,"ctx":"main","msg":"MongoDB cannot start: Linux kernel versions 6.19 and newer has a known incompatibility with this version of MongoDB. See https://jira.mongodb.org/browse/SERVER-121912 for more information."}
```

**Decisión:** `mongo:8.0.20` fijada por digest, la misma que usa la Lite, que arranca en 4 s con
88 MiB. Es anterior a la protección de SERVER-121912, **no** tiene arreglado el fallo de fondo, y en
reposo no se dispara. F20 la carga poco (es el invitado del duelo), pero `a02` lo dice con estas
palabras y enlaza el ticket. Se vuelve a la versión vigente cuando Docker Desktop traiga un kernel
7.0.14 o posterior.

---

## H3 · Oracle Free corre nativo en arm64 · 11/10/2026

El riesgo declarado en el alcance §8 no se materializó: **las dos imágenes son arm64 nativas**, sin
emulación, y traen la misma versión (`Oracle AI Database 26ai Free Release 23.26.3.0.0`).

| | `gvenzl/oracle-free:23.26.3-slim-faststart` | `container-registry.oracle.com/database/free` |
|---|---|---|
| Tamaño | 6,0 GB | 13,1 GB |
| Descarga | 87 s | 778 s |
| Listo en | 39 s | 16 s (trae la base creada) |
| RAM en reposo | 2,40 GiB | 2,02 GiB |
| Usuario de la aplicación | por variable (`APP_USER`) | con un script propio |
| *Healthcheck* | `healthcheck.sh`, cada 5 s | el suyo, cada 60 s (se acortó en la prueba) |

**Decisión (D21, Oskar, 11/10/2026): la de gvenzl.** La mitad de disco y el usuario por variable
pesan más que 23 s de arranque. Antes de elegirla se comprobó que la variante `slim` no pierde nada
que el curso use: *JSON Relational Duality View* con inserción a través de la vista, tipo `JSON`,
tipo `VECTOR`, `uuid()`, `EXPLAIN PLAN` con `DBMS_XPLAN` y `undo_management=AUTO`. El límite de
Free es de 2 CPU, 2 GB de RAM y 12 GB de datos de usuario: M ocupa unos 630 MB en Oracle.

**Pendiente para T1:** ninguna de las dos imágenes trae SQLcl, que `a03` prefiere a `sqlplus`.
`a03` decide si usa la imagen de SQLcl de Oracle o se queda con `sqlplus`, que sí viene.

---

## H4 · SQL Server con Rosetta: sí en Docker Desktop, no en Podman · 11/10/2026

**En Docker Desktop funciona.** `mcr.microsoft.com/mssql/server:2025-CU9-ubuntu-24.04` (amd64)
arranca en 14 s y queda en 996 MiB. Docker Desktop no usa Rosetta tal cual: registra su propio
`rosetta-wrapper` en `binfmt_misc`. Con `MSSQL_PID=Developer` el motor se presenta como
**"Enterprise Developer Edition (64-bit)"**: en 2025 Microsoft partió Developer en Enterprise
Developer y Standard Developer. Funcionan el tipo `json` nativo, `READ_COMMITTED_SNAPSHOT`, las tablas
temporales con `SYSTEM_VERSIONING` y `NEWSEQUENTIALID()`, y **Query Store viene encendido por
defecto** en una base nueva.

**En Podman no arranca, por ninguno de los dos caminos.** La máquina se creó para la prueba y se
borró al terminar, con permiso de Oskar:

- Con el proveedor por defecto de Podman 6 en macOS, **`libkrun`**, que no ofrece Rosetta y emula con
  QEMU:

  ```text
  /opt/mssql/bin/launch_sqlservr.sh: line 37:    11 Segmentation fault      (core dumped) "$@"
  ```

  Código de salida 139.
- Con el proveedor **`applehv`** y Rosetta activado (`[machine] rosetta = true`, que en esta versión
  no viene activo por defecto):

  ```text
  assertion failed [x86_avx_state_ptr->xsave_header.xfeatures == kSupportedXFeatureBits]:
  (ThreadContextSignals.cpp:414 rt_sigreturn)
  ```

  Código de salida 133. Rosetta no reproduce el estado AVX que SQL Server 2025 espera.

**Alternativa decidida:** en Apple Silicon el track exige **Docker Desktop**, y `ss01` lo dice en el
encabezado junto a la emulación. Podman sigue sirviendo para todo el camino base. Podman en Linux
x86_64 o en WSL2 corre la imagen sin emulación, y queda sin verificar (D-06). El alcance §8 cambia el
riesgo declarado por este hecho.

---

## H5 · El entrypoint de MySQL hace `chown` del directorio de `--secure-file-priv` · 11/10/2026

Con la caja montada en solo lectura en `/caja` y `--secure-file-priv=/caja`, el contenedor muere en
el arranque: el entrypoint intenta un `chown` recursivo de ese directorio y falla en cada archivo.

```text
chown: changing ownership of '/caja/m/ResultadoItem.csv': Read-only file system
```

**Decisión para `a02`:** `--secure-file-priv=` (vacío: sin restricción de directorio), que en un
laboratorio local no expone nada, y la caja en solo lectura. `local_infile` viene **apagado** en el
servidor; `a05` decide si `lab load` usa `LOAD DATA INFILE` del lado del servidor (lo que se probó, sin
tocar `local_infile`) o `LOCAL`, que exige encenderlo (§H11).

---

## H6 · Para la intercalación por defecto de MySQL, Ñ es N · 11/10/2026

Con `utf8mb4_0900_ai_ci`, la de MySQL 8 y 9, `WHERE Nombre LIKE '%Ñ%'` devuelve **149.919 de 251.851
pacientes**, el 60 %, porque esa intercalación no distingue acentos y trata `Ñ` como `N`. Los bytes se
guardaron bien (`NUÑEZ` = `4E55C391455A`). Es material para F04 o F05 (búsqueda de personas por
nombre) y una entrada para `a07`, al lado de la intercalación por defecto de Postgres, que no hace
lo mismo.

---

## H7 · `KUP-04076`: una tabla externa de Oracle no acepta rutas · 11/10/2026

`LOCATION ('m/ResultadoItem.csv')` sobre un `DIRECTORY` que apunta a `/caja`:

```text
ORA-29913: error while processing ODCIEXTTABLEOPEN routine
ORA-29400: data cartridge error
KUP-04076: file name cannot contain a path specification: m/ResultadoItem.csv
```

Se sale con un objeto `DIRECTORY` por perfil (`caja_m` sobre `/caja/m`). Entrada para `a08` y receta
para `a05`, que carga `legacy` en Oracle por tablas externas y `CREATE TABLE … AS SELECT`.

---

## H8 · `postgrest --ready` no acepta el host por defecto · 11/10/2026

El *healthcheck* natural de la imagen (que no trae `curl` ni `wget`) falla, aunque el servidor ya
responde:

```text
ERROR: The `--ready` flag cannot be used when server-host is configured as "!4". Please update your server-host config to "localhost".
```

Se arregla con `PGRST_ADMIN_SERVER_HOST=localhost` y `PGRST_ADMIN_SERVER_PORT=3001`: el servidor
principal sigue escuchando en todas las interfaces, y `--ready` consulta el de administración. Con eso
queda *healthy* en 8 s y `GET /` contesta 200.

---

## H9 · Apache Artemis: otro nombre, y un arranque de ocho minutos · 11/10/2026

**El nombre.** El 18/11/2025 la ASF separó Artemis de ActiveMQ como proyecto propio: hoy es **Apache
Artemis**, con sitio en `artemis.apache.org`, `groupId` `org.apache.artemis` e imagen `apache/artemis`.
La imagen vieja, `apache/activemq-artemis`, quedó en 2.44.0. Los paquetes Java del broker y sus
mensajes de *log* todavía dicen `org.apache.activemq.artemis`.

**El arranque.** La primera vez que se crea la instancia, `artemis create` mide el disco para ajustar
el *journal*, y sobre el sistema de archivos del contenedor en Docker Desktop eso tardó **484 s**:

```text
done! Your system can make 0.1 writes per millisecond, your journal-buffer-timeout will be 10404000
```

Con `EXTRA_ARGS=--http-host 0.0.0.0 --relax-jolokia --no-autotune`, el broker queda activo
(`AMQ221007: Server is now active`) en **3 s**. T11 lo fija así, y decide si la instancia va en un
volumen nombrado.

---

## H10 · Las funciones de Postgres que las fases dan por supuestas · 11/10/2026

Todas existen en 18.6, ejecutadas sobre el perfil M:

| Función | Fase | Resultado |
|---|---|---|
| `uuidv7()` y `uuid_extract_timestamp()` | F10 | ✅ |
| `PRIMARY KEY (…, valid WITHOUT OVERLAPS)` | F07 | ✅ rechaza el solapamiento con `conflicting key value violates exclusion constraint "p8_practice_pkey"` |
| `FOREIGN KEY (…, PERIOD valid)` | F07 | ✅ rechaza el hijo sin padre vigente |
| *skip scan* de B-tree | F11 | ✅ índice en `(Sede, Fecha)`, filtro solo por `Fecha`: `Index Only Scan` con `Index Searches: 9` |
| `pgstattuple`, `pg_trgm`, `vector` 0.8.7, `pg_stat_statements`, `btree_gist`, `amcheck`, `pg_walinspect` | varias | ✅ disponibles en la imagen |
| `pg_hint_plan` | F13 | ❌ **no viene en la imagen**; está en el apt de PGDG como `postgresql-18-pg-hint-plan` 1.8.0 |

**`pg_hint_plan`, la alternativa decidida:** la imagen del curso no cambia por una función que usa una
sola fase. F13 explica que Postgres no tiene *hints* en el núcleo, y deja `pg_hint_plan` como
ejercicio 🔥 con una imagen derivada de dos líneas (`FROM` la del curso y `apt-get install
postgresql-18-pg-hint-plan`), que el ejercicio construye y el `compose.yaml` no trae.

**Para F22:** `wal_level` viene en `replica`; la decodificación lógica exige `logical`, y `a02` lo
pone en el `command` del servicio. Lo mismo para `shared_preload_libraries=pg_stat_statements`, que
`a04` necesita.

---

## H11 · Los drivers de Python · 11/10/2026

Probados con `uv run` en un contenedor dentro de la red del laboratorio, con la misma secuencia en los
cuatro: dos conexiones, un `INSERT` sin confirmar en la primera, un `count(*)` en la segunda y un
`rollback`.

| Driver | Versión | *Autocommit* por defecto | La otra sesión ve lo no confirmado | `LOAD DATA LOCAL` |
|---|---|---|---|---|
| psycopg 3 (`psycopg[binary]`) | 3.3.6 | apagado; tras el `INSERT`, `INTRANS` | no | — |
| mysql-connector-python | 26.7.0 | apagado | no | ✅ 142.290 filas |
| PyMySQL | 1.2.3 | apagado | no | ✅ 142.290 filas |
| python-oracledb | 26.0.1, modo *thin* | apagado | no | — |

**Decisión (D22, Oskar, 11/10/2026): PyMySQL.** Los dos de MySQL se comportan igual en lo que la
propuesta de apéndices §14 pedía mirar (transacciones y `LOAD DATA`). PyMySQL es Python puro, con
licencia MIT y sin dependencia de Oracle, lo que encaja con el riesgo a cinco años que cuenta `a09`.
`mysql-connector-python` ya sigue la versión de calendario del servidor (26.7.0). **`python-oracledb`
en modo *thin* no necesita Instant Client**, confirmado. `LOAD DATA LOCAL` exige `local_infile=1` en
el servidor y la opción en el cliente (`local_infile=True` en PyMySQL).

---

## H12 · El prototipo del generador · 11/10/2026

Un generador en Python de biblioteca estándar, con semilla, que escribe la parte de la caja que más
pesa —`Pacientes` (en **Latin-1**, a propósito), `Protocolos` y `ResultadoItem`— y la verdad en
archivos aparte: `truth/patient_person.csv` (qué registro es qué persona, qué suciedad tiene y si
nació en el futuro) y `truth/result_value.csv` (qué valor quiso escribir el equipo y en qué estado
quedó). Es un prototipo: `a05` lo reescribe en T1 con el resto de la caja.

**Determinismo:** dos corridas con la semilla 1979 dan el mismo SHA-256 sobre los cinco archivos.

**Proporciones medidas contra la historia** (perfil M):

| Suciedad | Historia | Generado |
|---|---|---|
| filas que repiten a una persona | 15–20 % | 17,5 % |
| nacidos en el futuro | 4.000 de 1,9 M (0,21 %) | 0,19 % |
| DNI dentro de `Nombre` | sin cifra (el parser falla en el 10 %) | 10,9 % (propuesto) |
| DNI vacío · DNI compartido por más de una fila | sin cifra | 6,2 % · 22,0 % |
| resultados con coma · con punto | sin cifra | 45 % · 45 % (propuesto) |
| `< 0,5`, `>1000`, `HEMOLIZADA`, vacío | sin cifra | 3 % · 2 % · 2 % · 3 % (propuesto) |

Los tipos de duplicado siguen la historia: mismo DNI con otro nombre, mismo nombre con DNI vacío,
recién nacido con el DNI de la madre y pasaporte en el campo DNI. **Ningún dato es real**: los nombres
salen de listas de nombres y apellidos comunes, y los DNI de un rango plausible al azar.

**Los perfiles calibrados:**

| Perfil | Personas | Pacientes | Protocolos | Resultados | CSV | Generación |
|---|---|---|---|---|---|---|
| S | 20.740 | 25.185 | 142.290 | 1,68 M | 84 MB | 7 s |
| M | 207.821 | 251.851 | 1,43 M | 16,8 M | 917 MB | 71 s |
| L | ~1 M | ~1,2 M | ~7 M | ~84 M | ~4,5 GB | sin generar (opcional, D4) |

**Cargas de M**, tiempo de pared desde el CSV montado en el contenedor (contexto, no argumento):
Postgres con `COPY`, **16 s** (850 MB en disco para `ResultadoItem`); MySQL con `LOAD DATA INFILE`,
**51 s** (814 MB). Oracle con tablas externas y `CREATE TABLE … AS SELECT` también carga M en un
tiempo razonable; su número queda en la salida privada (alcance §6.1). M entra en el laboratorio con
los tres motores (tabla de RAM, arriba), así que **M no se achica**: queda en unos 250.000 pacientes y
17 millones de resultados, un poco por encima de lo que el alcance §7.1 estimaba.

---

## H13 · Java 25 · 11/10/2026

`eclipse-temurin:25.0.4.1_1-jdk-noble`, arm64 nativa, ejecuta un archivo suelto sin proyecto
(`java Hola.java`, con el `void main()` implícito de Java 25). **D19 (Oskar, 11/10/2026):** Java 25
LTS reemplaza a Java 21 en el boss del puente y en `a10`, por D12. La prueba de concepto del Access de
museo se escribió con el Java de la máquina; T14 la vuelve a ejecutar con Java 25 y anota lo que cambie.

---

## 📚 P9 · Las fuentes base · 11/10/2026

### F1 · Los seis libros

Comprobados en la página de la editorial o del autor. Los capítulos los comprueba la tanda que los
cita.

| Libro | Edición que cita el curso | Editorial y año | Dónde se comprobó |
|---|---|---|---|
| C. J. Date, *SQL and Relational Theory: How to Write Accurate SQL Code* | 3.ª | O'Reilly, 2015 | catálogo de O'Reilly (ISBN 978-1-4919-4117-1); `oreilly.com` devuelve 403 a `curl`, se leyó por el buscador |
| Markus Winand, *SQL Performance Explained* | única (con actualizaciones del PDF) | edición del autor, 2012 | `sql-performance-explained.com` (200) y ISBN 978-3-9503078-2-5; el sitio es `use-the-index-luke.com` (200) |
| Bill Karwin, *SQL Antipatterns, Volume 1: Avoiding the Pitfalls of Database Programming* | la de 2022 (la 2.ª del libro de 2010) | Pragmatic Bookshelf, 2022 | `pragprog.com/titles/bksap1/` (200), ISBN 978-1-68050-898-7 |
| Martin Kleppmann y Chris Riccomini, *Designing Data-Intensive Applications* | **2.ª** | O'Reilly, marzo de 2026 | la entrada del blog de Kleppmann del 24/03/2026 (200) |
| Richard T. Snodgrass, *Developing Time-Oriented Database Applications in SQL* | única | Morgan Kaufmann, 1999 | `shop.elsevier.com` (200), ISBN 978-1-55860-436-0; el PDF que el autor publicaba en `cs.arizona.edu` no resolvía por DNS el 11/10/2026 |
| Darl Kuhn y Thomas Kyte, *Expert Oracle Database Architecture* | **4.ª**, sobre Oracle 21c | Apress, 2021 (los catálogos dicen 2022) | `link.springer.com/book/10.1007/978-1-4842-7499-6` (200) |

Dos cambios respecto de la guía §11: Kleppmann tiene **coautor y segunda edición**, y el de Kyte es
de **Kuhn y Kyte**, y cubre 21c. Ninguno cubre Oracle 23ai/26ai: las fases que los citen lo advierten,
como pide la guía.

### F2 · Lo que dicen hoy las licencias sobre publicar resultados

**SQL Server 2025 Developer, Express y Evaluation** — *Microsoft Software License Terms*, PDF fechado
el 05/12/2025, enlazado desde `microsoft.com/useterms`. La licencia que trae la imagen solo remite a
`aka.ms/useterms`. El texto, §5:

> **BENCHMARK TESTING.** You must obtain Microsoft's prior written approval to disclose to a third
> party the results of any benchmark test of the software.

La misma licencia, §1.a.i: Developer se usa "to design, develop, test and demonstrate your programs"
y "You may not use the software in a production environment". La cláusula está, y la regla del curso
se aplica tal cual.

**Oracle AI Database Free** — según el *Database Licensing Information User Manual* de 23ai/26ai (tabla
1-1), "is released under the Oracle Free Use Terms and Conditions", en
`oracle.com/downloads/licenses/oracle-free-license.html` ("Last updated: 9 June 2021"). **Ese texto no
tiene cláusula de benchmark**: se buscaron "benchmark", "disclos", "publish" y "test", y solo aparece
"testing" en el otorgamiento de la licencia. Lo que sí tiene, y toca a un curso:

> You are granted the right to use the Programs to provide third party training in the use of the
> Programs and associated Separately Licensed Technology only if there is express authorization of
> such use by Oracle on the Program's download page or in the Program Documentation.

**Decisión (D20, Oskar, 11/10/2026): la regla del curso se mantiene.** Ningún número de Oracle se
publica: el lector de empresa corre Oracle bajo un contrato (OMA u OLSA) que sí lleva la cláusula, y la
apuesta sin resolver ya es parte del diseño. Lo que cambia es **cómo se justifica**: el alcance §6.1
deja de decir que "las licencias de Oracle y de SQL Server prohíben" y separa los dos casos. `a09`
cita los dos textos, dice que Oracle Free no tiene la cláusula y por qué el curso igual no publica, y
trata la frase de *third party training* como riesgo declarado, sin asesoramiento legal. Los límites
de Free para `a09`: 2 CPU, 2 GB de RAM y 12 GB de datos de usuario por instancia.

---

## 📌 Pendientes que deja P8

- **Linux y Windows 11 con WSL2:** sin verificar (D-06), como en la Lite.
- **SQLcl** (§H3), en T1 con `a03`.
- **El servicio `bridge`** del boss del puente: su memoria se mide en T11, cuando exista.
- **El perfil L** no se generó: es opcional (D4) y ocupa unos 4,5 GB de CSV más la carga en cada
  motor. `a05` dice cuánto disco pide.
- **Las proporciones que la historia no fija** (tabla de §H12, "propuesto") las confirma `a05` en el
  paso 1 de T1.
