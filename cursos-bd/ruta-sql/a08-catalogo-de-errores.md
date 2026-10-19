# 📎 Apéndice a08 — Catálogo de errores con mensaje literal

> **Curso:** Ruta SQL · Consulta rápida y documento vivo · **3 h**
> **Usado por:** todas las fases · **Versiones cubiertas:** las de cada entrada
> **Fecha de verificación ejecutada:** la de cada entrada; los ejercicios, el 18/10/2026. **Estado:**
> abierto el 12/10/2026, cerrado el 18/10/2026. **Entradas:** 102, del laboratorio, de la carga de la
> caja, de la Fase 01, de las fases 03 a 26, del track de SQL Server (ss01 a ss05) y de las corridas
> privadas de Oracle (solo el mensaje); el curso se propuso reunir cincuenta, repartidas entre los tres
> motores, y las pasó

**Esto no se lee de corrido.** Se entra buscando el mensaje que acabas de pegar en un buscador.
Cada entrada es un error que **apareció de verdad al ejecutar** algo de este curso, con su mensaje
literal tal como salió, sin recortar la parte incómoda.

**Qué queda fuera:** errores que nadie vio. Una entrada reconstruida de memoria es un mensaje que no
existe, y un mensaje que no existe no lo encuentra nadie. Por eso este catálogo **crece con el
curso**: cada fase agrega lo que encontró al ejecutarse.

> 📝 **Los mensajes de Oracle y de SQL Server sí se publican aquí.** Un mensaje de error no es un
> resultado de rendimiento: dice qué pasó, no cuánto tardó.

---

## Índice por motor

- **PostgreSQL** — [E-14](#e-14--copy-de-un-archivo-latin-1-en-una-base-utf-8) ·
  [E-17](#e-17--dt-no-encuentra-una-tabla-con-mayúsculas) · [E-20](#e-20--una-clave-foránea-que-no-se-puede-crear-sobre-datos-heredados) · [E-21](#e-21--el-dni-no-se-puede-declarar-único) · [E-23](#e-23--un-delete-de-paciente-que-el-disparador-no-deja-pasar) · [E-24](#e-24--without-overlaps-sobre-una-columna-entera) · [E-25](#e-25--un-rango-vacío-en-una-clave-without-overlaps) · [E-27](#e-27--texto-que-no-es-un-número-en-una-conversión) · [E-28](#e-28--volver-a-correr-un-script-que-borra-una-tabla-de-la-que-otras-dependen) · [E-30](#e-30--una-fila-que-no-tiene-partición) · [E-31](#e-31--la-clave-duplicada-después-de-una-carga-con-identificadores-propios) · [E-32](#e-32--la-secuencia-llegó-al-techo-del-integer) · [E-34](#e-34--insertar-un-valor-en-una-identidad-generated-always) · [E-35](#e-35--un-valor-demasiado-grande-para-un-índice-b-tree) · [E-38](#e-38--la-consulta-que-el-límite-de-tiempo-cancela) · [E-41](#e-41--dos-transacciones-serializable-que-se-pisan-sin-tocar-la-misma-fila) · [E-42](#e-42--repeatable-read-no-deja-escribir-una-fila-que-otra-cambió) · [E-44](#e-44--la-transacción-ociosa-que-el-servidor-corta) · [E-45](#e-45--dos-correcciones-que-se-esperan-una-a-la-otra) · [E-46](#e-46--la-espera-que-lock_timeout-corta) · [E-47](#e-47--nowait-encuentra-la-fila-tomada) · [E-50](#e-50--la-validación-de-una-restricción-que-los-datos-no-cumplen)
- **MySQL** — [E-04](#e-04--mysql-no-arranca-con---secure-file-privcaja) ·
  [E-10](#e-10--load-data-y-un-campo-vacío-en-una-columna-numérica) ·
  [E-15](#e-15--load-data-de-un-archivo-latin-1-como-utf8mb4) · [E-18](#e-18--mysql-rechaza-lo-que-en-el-sistema-viejo-siempre-entró) · [E-22](#e-22--similarity-no-existe-en-mysql) · [E-26](#e-26--without-overlaps-en-mysql) · [E-29](#e-29--un-paquete-más-grande-que-max_allowed_packet) · [E-33](#e-33--auto_increment-en-el-techo-repite-el-último-valor) · [E-36](#e-36--una-clave-de-índice-más-larga-de-lo-que-mysql-permite) · [E-37](#e-37--un-índice-sobre-text-sin-largo) · [E-39](#e-39--un-force-index-que-nombra-un-índice-que-ya-no-existe) · [E-40](#e-40--un-optimizer-hint-que-no-encuentra-lo-que-nombra) · [E-43](#e-43--un-deadlock-entre-dos-lecturas-que-después-quieren-escribir) · [E-48](#e-48--el-tiempo-de-espera-de-mysql-que-deshace-solo-la-sentencia) · [E-49](#e-49--un-algoritmo-de-ddl-que-no-corresponde-al-cambio)
- **Oracle** — [E-02](#e-02--conectarse-a-oracle-antes-de-que-esté-listo) ·
  [E-03](#e-03--oracle-sin-memoria-suficiente) ·
  [E-08](#e-08--una-tabla-externa-con-una-ruta-en-location) ·
  [E-09](#e-09--dbms_stats-no-encuentra-una-tabla-con-mayúsculas-y-minúsculas) ·
  [E-11](#e-11--add-column-en-oracle) ·
  [E-16](#e-16--oracle-guarda-bytes-latin-1-y-el-cliente-no-puede-mostrarlos) · [E-19](#e-19--ora-01400-al-cargar-una-cadena-vacía) · [E-51](#e-51--la-foto-que-el-undo-ya-no-tiene) · [E-52](#e-52--serializable-en-oracle-al-escribir-una-fila-que-otra-cambió) · [E-53](#e-53--el-deadlock-en-oracle)
- **Fases 19 a 21** — [E-54](#e-54---no-existe-para-json) · [E-55](#e-55--un-check-que-rechaza-una-sensibilidad-inválida) · [E-56](#e-56--un-update-con-subconsulta-sobre-la-misma-tabla) · [E-57](#e-57--un-índice-nombrado-sin-su-esquema) · [E-58](#e-58--el-validador-de-mongodb-rechaza-un-protocolo-sin-pagador) · [E-59](#e-59--el-operador--con-parámetros-en-psycopg) · [E-60](#e-60--un-parámetro-sin-tipo-dentro-de-la-construcción-de-jsonb) · [E-61](#e-61--un-ddl-que-se-corre-dos-veces)
- **Fase 22** — [E-62](#e-62--dos-corridas-a-la-vez-sobre-las-mismas-tablas-de-prueba) · [E-63](#e-63--percentile_cont-no-acepta-una-fecha)
- **Fase 23** — [E-64](#e-64--la-vista-sin-permisos-para-el-rol-anónimo) · [E-65](#e-65--una-fila-que-viola-la-política-de-escritura) · [E-66](#e-66--los-claims-vacíos-rompen-la-política) · [E-67](#e-67--recover-y-la-precarga-del-consumidor-en-artemis) · [E-68](#e-68--montar-las-dependencias-sobre-lib-del-contenedor-de-java)
- **Fases 25 y 26** — [E-69](#e-69--la-memoria-compartida-del-contenedor-se-llena) · [E-70](#e-70--partir-un-rango-de-precios-en-dos-sentencias) · [E-71](#e-71--un-slot-lógico-en-una-transacción-que-ya-escribió) · [E-72](#e-72--lo-que-ve-el-frontal-cuando-se-congela-legacy)
- **El laboratorio** (contenedores, carga, drivers) — [E-01](#e-01--el-puerto-del-laboratorio-ya-está-tomado) ·
  [E-05](#e-05--mongodb-se-niega-a-arrancar-por-el-kernel) ·
  [E-12](#e-12--python-lee-la-caja-como-utf-8) ·
  [E-13](#e-13--java-lee-la-caja-como-utf-8)
- **SQL Server**, del track — [E-06](#e-06--sql-server-en-podman-con-libkrun) ·
  [E-07](#e-07--sql-server-en-podman-con-rosetta) · [E-73](#e-73--bcp-in-con-la-caja-entrecomillada) · [E-74](#e-74--codepage-en-sql-server-para-linux) · [E-75](#e-75--un-csv-en-latin-1-en-bulk-insert) · [E-76](#e-76--el-driver-mssql-python-no-carga-en-debian) · [E-77](#e-77--un-agregado-sobre-una-subconsulta-en-t-sql) · [E-78](#e-78--una-fecha-aaaa-mm-dd-en-datetime-según-el-idioma-de-la-sesión) · [E-79](#e-79--la-víctima-de-un-deadlock-en-sql-server) · [E-80](#e-80--el-commit-después-de-ser-víctima) · [E-81](#e-81--conflicto-de-actualización-en-snapshot) · [E-82](#e-82--snapshot-en-una-base-que-no-lo-permite) · [E-83](#e-83--una-violación-de-unique-en-t-sql) · [E-84](#e-84--división-por-cero-dentro-de-una-transacción) · [E-85](#e-85--un-hint-de-índice-sobre-un-índice-que-no-existe) · [E-86](#e-86--un-plan-forzado-que-query-store-no-puede-aplicar) · [E-87](#e-87--quoted_identifier-apagado-en-sqlcmd) · [E-88](#e-88--newsequentialid-fuera-de-un-default) · [E-89](#e-89--el-período-de-una-tabla-temporal-a-mano) · [E-90](#e-90--una-tabla-de-historia-corregida-a-mano) · [E-91](#e-91--truncate-sobre-una-tabla-temporal) · [E-92](#e-92--drop-table-sobre-una-tabla-temporal) · [E-93](#e-93--volver-a-encender-el-versionado-con-una-historia-inválida) · [E-94](#e-94--insertar-en-la-historia-en-el-mismo-lote-que-apaga-el-versionado) · [E-95](#e-95--dab-rechaza-el-pedido-por-el-rol) · [E-96](#e-96--un-documento-inválido-en-el-tipo-json) · [E-97](#e-97--un-índice-json-sin-clave-agrupada) · [E-98](#e-98--el-contenedor-de-sql-server-muere-por-memoria) · [E-99](#e-99--dab-no-se-reconecta-después-de-recrear-sql-server) · [E-100](#e-100--cambiar-un-valor-de-solo-lectura-en-session_context) · [E-101](#e-101--un-predicado-de-bloqueo-de-la-seguridad-por-fila) · [E-102](#e-102--lab-race-declara-imposible-un-deadlock-de-sql-server)

---

## 🧱 La forma de una entrada

Cada entrada tiene la misma forma, y la numeración `E-NN` no se reutiliza:

```markdown
### E-NN · Qué pasó, en palabras del que lo sufre

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** Fase NN

    el mensaje literal, copiado de la ejecución

- **Qué lo provocó:** …
- **Cómo se confirma:** el comando que lo distingue de otro error parecido
- **Cómo se sale:** …
```

> 🧭 **Anota el error antes de arreglarlo.** Es la única regla de este catálogo: un mensaje copiado
> después de dos intentos de arreglo ya no es el mensaje del primer intento.

---

## 🧯 Entradas

### E-01 · El puerto del laboratorio ya está tomado

**Motor y versión:** Docker Desktop 29.8.0 · **Apareció en:** [`a01`](a01-laboratorio-contenerizado.md#-puerto-ocupado), 12/10/2026

```text
Error response from daemon: failed to set up container networking: driver failed programming external connectivity on endpoint alameda-lab-postgres-1 (4dbc5937244b98e0572efcb7b0c8405fe4f431f080596b0a9bd7222762784cfe): Bind for 127.0.0.1:25432 failed: port is already allocated
```

- **Qué lo provocó:** otro contenedor publicado en `127.0.0.1:25432`.
- **Cómo se confirma:** `docker ps --filter publish=25432`; si no sale nada, `lsof -nP -iTCP:25432 -sTCP:LISTEN`.
- **Cómo se sale:** `POSTGRES_PORT=25433 uv run lab up`, o la misma variable en `src/lab/.env`.

### E-02 · Conectarse a Oracle antes de que esté listo

**Motor y versión:** Oracle AI Database 26ai Free 23.26.3 · **Apareció en:** [`a01`](a01-laboratorio-contenerizado.md#️-conectarse-antes-de-tiempo), 12/10/2026

```text
ORA-12154: Cannot connect to database. Cannot find alias FREEPDB1 in
/opt/oracle/product/26ai/dbhomeFree/network/admin/tnsnames.ora.
Help: https://docs.oracle.com/error-help/db/ora-12154/
```

Un poco más tarde dentro del mismo arranque, el mensaje es otro:

```text
ORA-12541: Cannot connect. No listener at host 172.25.0.2 port 1521.
Help: https://docs.oracle.com/error-help/db/ora-12541/
```

- **Qué lo provocó:** `up -d` sin `--wait` y un `sqlplus` inmediato: el contenedor estaba `Up`, la base no.
- **Cómo se confirma:** `docker compose ps` dice `health: starting`.
- **Cómo se sale:** esperar a `healthy`; `uv run lab up` ya espera.

### E-03 · Oracle sin memoria suficiente

**Motor y versión:** Oracle AI Database 26ai Free 23.26.3, imagen de gvenzl · **Apareció en:** [`a01`](a01-laboratorio-contenerizado.md#-memoria-oracle-decide-qué-cabe), 12/10/2026

```text
Database mounted.
ORA-03113: end-of-file on communication channel
Process ID: 178
Session ID: 162 Serial number: 2802
Help: https://docs.oracle.com/error-help/db/ora-03113/
```

- **Qué lo provocó:** `ORACLE_MEMORY=512m`; el kernel mató un proceso de la instancia. El contenedor sale
  con código 41, o sigue *healthy* con un proceso menos.
- **Cómo se confirma:** `docker inspect alameda-lab-oracle-1 --format '{{.State.OOMKilled}}'` da `true`.
- **Cómo se sale:** el límite de fábrica, 3 GB (`ORACLE_MEMORY` sin definir), y un volumen nuevo.

### E-04 · MySQL no arranca con `--secure-file-priv=/caja`

**Motor y versión:** MySQL 9.7.2 · **Apareció en:** [`a02`](a02-compose-de-la-ruta.md#️-lo-que-cada-motor-trae-encendido), 11/10/2026 y 12/10/2026

```text
chown: changing ownership of '/caja': Read-only file system
chown: changing ownership of '/caja/s': Read-only file system
```

- **Qué lo provocó:** el *entrypoint* de la imagen hace un `chown` recursivo del directorio de
  `--secure-file-priv`, y la caja está montada en solo lectura.
- **Cómo se confirma:** el contenedor sale con código 1 y una línea de `chown` por archivo de la caja.
- **Cómo se sale:** `--secure-file-priv=` vacío, como trae el `compose.yaml` del curso.

### E-05 · MongoDB se niega a arrancar por el kernel

**Motor y versión:** MongoDB 9.0.2, y desde la 8.0.21 · **Apareció en:** la verificación del laboratorio ([`a02`](a02-compose-de-la-ruta.md#-las-versiones-del-curso)), 11/10/2026

```text
{"t":{"$date":"2026-10-11T22:57:24.123+00:00"},"s":"F",  "c":"CONTROL",  "id":12257600,"ctx":"main","msg":"MongoDB cannot start: Linux kernel versions 6.19 and newer has a known incompatibility with this version of MongoDB. See https://jira.mongodb.org/browse/SERVER-121912 for more information."}
```

- **Qué lo provocó:** el kernel `7.0.12-linuxkit` de Docker Desktop 29.8.0.
- **Cómo se confirma:** `docker info --format '{{.KernelVersion}}'`.
- **Cómo se sale:** `mongo:8.0.20`, la que fija el curso, hasta que el kernel llegue a 7.0.14.

### E-06 · SQL Server en Podman con `libkrun`

**Motor y versión:** SQL Server 2025 CU9 (`amd64`), Podman 6.1.3 en macOS arm64 · **Apareció en:** la verificación del laboratorio ([`a01`](a01-laboratorio-contenerizado.md#-podman-al-lado)), 11/10/2026

```text
/opt/mssql/bin/launch_sqlservr.sh: line 37:    11 Segmentation fault      (core dumped) "$@"
```

- **Qué lo provocó:** el proveedor de VM por defecto de Podman 6, que emula `amd64` con QEMU.
- **Cómo se confirma:** el contenedor sale con código 139.
- **Cómo se sale:** Docker Desktop. En Apple Silicon el track no tiene camino con Podman.

### E-07 · SQL Server en Podman con Rosetta

**Motor y versión:** SQL Server 2025 CU9 (`amd64`), Podman 6.1.3 con `applehv` · **Apareció en:** la verificación del laboratorio ([`a01`](a01-laboratorio-contenerizado.md#-podman-al-lado)), 11/10/2026

```text
assertion failed [x86_avx_state_ptr->xsave_header.xfeatures == kSupportedXFeatureBits]:
(ThreadContextSignals.cpp:414 rt_sigreturn)
```

- **Qué lo provocó:** Rosetta no reproduce el estado AVX que SQL Server 2025 espera.
- **Cómo se confirma:** el contenedor sale con código 133.
- **Cómo se sale:** Docker Desktop, igual que E-06.

### E-08 · Una tabla externa con una ruta en `LOCATION`

**Motor y versión:** Oracle AI Database 26ai Free 23.26.3 · **Apareció en:** la carga de la caja ([`a05`](a05-la-caja-y-el-generador.md#-lab-load-en-cada-motor)), 11/10/2026

```text
ORA-29913: error while processing ODCIEXTTABLEOPEN routine
ORA-29400: data cartridge error
KUP-04076: file name cannot contain a path specification: m/ResultadoItem.csv
```

- **Qué lo provocó:** `LOCATION ('m/ResultadoItem.csv')` sobre un `DIRECTORY` que apuntaba a `/caja`.
- **Cómo se confirma:** el error aparece al primer `SELECT` de la tabla externa, no al crearla.
- **Cómo se sale:** un objeto `DIRECTORY` por carpeta (`lab load` crea `CAJA_M_TABLAS` sobre
  `/caja/m/tablas`) y solo el nombre del archivo en `LOCATION`.

### E-09 · `DBMS_STATS` no encuentra una tabla con mayúsculas y minúsculas

**Motor y versión:** Oracle AI Database 26ai Free 23.26.3 · **Apareció en:** la carga de la caja ([`a05`](a05-la-caja-y-el-generador.md#-lab-load-en-cada-motor)), 12/10/2026

```text
ORA-20000: Unable to analyze TABLE "LEGACY"."PACIENTES", insufficient privileges or does not exist
ORA-06512: at "SYS.DBMS_STATS", line 45301
```

- **Qué lo provocó:** `DBMS_STATS.GATHER_TABLE_STATS('LEGACY', 'Pacientes')`. La tabla se llama
  `"Pacientes"`, con comillas, y el paquete pasa el nombre a mayúsculas si no las lleva.
- **Cómo se confirma:** el mensaje nombra `"PACIENTES"`, en mayúsculas, que no existe.
- **Cómo se sale:** pasar el nombre con sus comillas: `'"Pacientes"'`.

### E-10 · `LOAD DATA` y un campo vacío en una columna numérica

**Motor y versión:** MySQL 9.7.2 · **Apareció en:** la carga de la caja ([`a05`](a05-la-caja-y-el-generador.md#-el-formato-de-los-csv)), 12/10/2026

```text
ERROR 1366 (HY000) at line 1: Incorrect integer value: '' for column 'n' at row 4
```

- **Qué lo provocó:** un CSV con un campo vacío (el NULL de `bcp`) cargado en una columna `int` de una
  tabla de prueba. MySQL lee el vacío como texto vacío, y un texto vacío no es un entero.
- **Cómo se confirma:** la fila que nombra el mensaje tiene el campo vacío y sin comillas.
- **Cómo se sale:** leer el campo en una variable y convertirlo: `(@v) SET n = NULLIF(@v, '')`, que es
  lo que hace `lab load` en todas las columnas que no son de texto.

### E-11 · `ADD COLUMN` en Oracle

**Motor y versión:** Oracle AI Database 26ai Free 23.26.3, desde python-oracledb 26.0.1 · **Apareció en:** [`a06`](a06-python-java-y-drivers.md), 12/10/2026

```text
oracledb.exceptions.DatabaseError: ORA-03050: invalid identifier: "COLUMN" is a reserved word
Help: https://docs.oracle.com/error-help/db/ora-03050/
```

- **Qué lo provocó:** `ALTER TABLE payer ADD COLUMN active boolean`, que es la sintaxis de Postgres y
  de MySQL.
- **Cómo se confirma:** la misma sentencia sin `COLUMN` funciona.
- **Cómo se sale:** `ALTER TABLE payer ADD active boolean`.

### E-12 · Python lee la caja como UTF-8

**Motor y versión:** Python 3.13.13 · **Apareció en:** [`a06`](a06-python-java-y-drivers.md#-leer-la-caja-desde-python), 12/10/2026

```text
'utf-8' codec can't decode byte 0xf1 in position 764: invalid continuation byte
```

- **Qué lo provocó:** `open("Pacientes.csv", encoding="utf-8")` sobre un archivo en Latin-1; `0xF1` es
  la `ñ`.
- **Cómo se confirma:** el mismo archivo abre con `encoding="latin-1"`.
- **Cómo se sale:** `encoding="latin-1"`, nunca `errors="ignore"`, que borra las eñes.

### E-13 · Java lee la caja como UTF-8

**Motor y versión:** Java 25.0.4.1 · **Apareció en:** [`a06`](a06-python-java-y-drivers.md), 12/10/2026

```text
Exception in thread "main" java.nio.charset.MalformedInputException: Input length = 1
	at java.base/java.nio.charset.CoderResult.throwException(CoderResult.java:279)
```

- **Qué lo provocó:** `Files.readAllLines(path, StandardCharsets.UTF_8)` sobre `Pacientes.csv`. Es lo
  mismo que hace `Files.readAllLines(path)` sin juego de caracteres.
- **Cómo se confirma:** con `StandardCharsets.ISO_8859_1` lee las 242.427 filas de M.
- **Cómo se sale:** pasar el juego de caracteres: `Files.readAllLines(path, StandardCharsets.ISO_8859_1)`.


### E-14 · `COPY` de un archivo Latin-1 en una base UTF-8

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 01](01-la-caja-y-el-arnes.md#️-4-la-caja-cargada-y-medida), 12/10/2026

```text
ERROR:  invalid byte sequence for encoding "UTF8": 0xf1 0x6f 0x73 0x22
CONTEXT:  COPY pacientes_utf8, line 6
```

- **Qué lo provocó:** `COPY … WITH (FORMAT csv, HEADER true)` sobre `Pacientes.csv` de M, sin
  `ENCODING`. `0xF1 0x6F 0x73` es `ños`, de `43 años`, en la columna `Edad`.
- **Cómo se confirma:** la línea que nombra el mensaje tiene una eñe o un acento; el archivo se lee bien
  con `iconv -f latin1`.
- **Cómo se sale:** `ENCODING 'LATIN1'` en el `COPY`. Nunca convirtiendo el archivo antes.

### E-15 · `LOAD DATA` de un archivo Latin-1 como `utf8mb4`

**Motor y versión:** MySQL 9.7.2 · **Apareció en:** [Fase 01](01-la-caja-y-el-arnes.md#️-4-la-caja-cargada-y-medida), 12/10/2026

```text
ERROR 1366 (HY000) at line 4: Incorrect string value: '\xF1os' for column 'Edad' at row 5
```

- **Qué lo provocó:** `LOAD DATA INFILE … CHARACTER SET utf8mb4` sobre `Pacientes.csv`. Es el mismo
  número de error que E-10, por otra causa: aquí el valor no es UTF-8 válido.
- **Cómo se confirma:** la fila 5 de datos es la línea 6 del archivo, la de E-14.
- **Cómo se sale:** `CHARACTER SET latin1` en el `LOAD DATA`, como hace `lab load`.

### E-16 · Oracle guarda bytes Latin-1 y el cliente no puede mostrarlos

**Motor y versión:** Oracle AI Database 26ai Free 23.26.3, `sqlplus` de la imagen · **Apareció en:** [Fase 01](01-la-caja-y-el-arnes.md#️-4-la-caja-cargada-y-medida), 12/10/2026

```text
SP2-0784: Invalid or incomplete character beginning 0xF1 returned
Help: https://docs.oracle.com/error-help/db/sp2-0784/
```

- **Qué lo provocó:** una tabla externa sobre `Pacientes.csv` con `CHARACTERSET AL32UTF8`. **La carga no
  falla**: Oracle guarda los bytes tal cual, y el error lo da `sqlplus` al mostrarlos. Una copia con
  `CREATE TABLE … AS SELECT` también se hace sin error.
- **Cómo se confirma:** `SELECT DUMP("Edad", 16) …` muestra `61,f1,6f,73`: Latin-1 dentro de una base
  AL32UTF8.
- **Cómo se sale:** recrear la tabla externa con `CHARACTERSET WE8ISO8859P1` y volver a cargar lo que se
  copió.

### E-17 · `\dt` no encuentra una tabla con mayúsculas

**Motor y versión:** `psql` de PostgreSQL 18.6 · **Apareció en:** [`a03`](a03-clis-de-los-motores.md#-postgresql--psql), 12/10/2026

```text
Did not find any tables named "legacy.Pac*".
```

- **Qué lo provocó:** `\dt legacy.Pac*`. `psql` pasa el patrón a minúsculas, y en la caja todo empieza
  con mayúscula. `\dt legacy."Pac*"` tampoco sirve: dentro de las comillas, el `*` es literal.
- **Cómo se confirma:** `\dt legacy."Pacientes"` sí la encuentra.
- **Cómo se sale:** citar solo la parte con mayúsculas: `\dt legacy."Pac"*`.

### E-18 · MySQL rechaza lo que en el sistema viejo siempre entró

**Motor y versión:** MySQL 9.7.2 · **Apareció en:** [Fase 03](03-lo-que-sql-le-hace-al-modelo.md#-6-el-contraste-dónde-otro-motor-cambia-la-decisión), 12/10/2026

```text
ERROR 1265 (01000) at line 5: Data truncated for column 'practicas' at row 1
ERROR 1406 (22001) at line 6: Data too long for column 'obra_social' at row 1
```

- **Qué lo provocó:** un texto en una columna numérica y un valor más largo que la columna, con el modo
  estricto que MySQL 9.7 trae de fábrica (`STRICT_TRANS_TABLES`).
- **Cómo se confirma:** `SELECT @@sql_mode;`. Si el origen corría con `sql_mode = ''`, esos valores entraron
  allá truncados o convertidos, con una advertencia que nadie leyó.
- **Cómo se sale:** no apagando el modo estricto: cargando a una tabla de `staging` con columnas de texto y
  rechazando con una regla lo que no cumple el tipo.

### E-19 · `ORA-01400` al cargar una cadena vacía

**Motor y versión:** Oracle AI Database 26ai Free 23.26.3 · **Apareció en:** [Fase 03](03-lo-que-sql-le-hace-al-modelo.md#-8-el-punto-de-rotura), 12/10/2026

```text
ERROR at line 1:
ORA-01400: cannot insert NULL into ("ALAMEDA"."PRESENTACION"."OBRA_SOCIAL")
```

- **Qué lo provocó:** un `INSERT` de `''` en una columna `NOT NULL`. En Oracle, la cadena vacía es `NULL`.
- **Cómo se confirma:** `SELECT count(*) FROM … WHERE columna = ''` en el motor de origen da las filas que
  van a fallar; en Oracle esa misma consulta da siempre cero.
- **Cómo se sale:** decidir qué significa el vacío antes de migrar (desconocido, no aplica, o un valor) y
  cargarlo con esa decisión, no con un espacio en blanco.

### E-20 · Una clave foránea que no se puede crear sobre datos heredados

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 04](04-un-valor-un-hecho.md#-8-el-punto-de-rotura), 12/10/2026

```text
ERROR:  insert or update on table "result_item" violates foreign key constraint "result_item_lab_order_id_fkey"
DETAIL:  Key (lab_order_id)=(902271366) is not present in table "lab_order".
```

- **Qué lo provocó:** resultados que apuntan a protocolos borrados: 2.150 en M, de 198 protocolos.
- **Cómo se confirma:** `SELECT count(*) FROM … AS r WHERE NOT EXISTS (SELECT 1 FROM … AS o WHERE
  o.lab_order_id = r.lab_order_id);`
- **Cómo se sale:** la clave con `NOT VALID`, que protege las filas nuevas; los huérfanos a la tabla de
  rechazos; y `VALIDATE CONSTRAINT` cuando ya no quedan.

### E-21 · El DNI no se puede declarar único

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 05](05-una-persona-no-es-su-documento.md#51-la-clave-natural-que-no-era-clave), 13/10/2026

```text
ERROR:  could not create unique index "patient_clean_document_digits_key"
DETAIL:  Key (document_digits)=(9496697) is duplicated.
```

- **Qué lo provocó:** pacientes duplicados y recién nacidos cargados con el DNI de la madre. El número del
  `DETAIL` cambia entre corridas: es el primer duplicado que encuentra la construcción del índice.
- **Cómo se confirma:** `SELECT document_digits, count(*) FROM … GROUP BY 1 HAVING count(*) > 1;`
- **Cómo se sale:** no es un error de datos que se limpia: es la clave natural equivocada. Clave sustituta
  para el paciente, y el documento en su propia tabla.

### E-22 · `similarity` no existe en MySQL

**Motor y versión:** MySQL 9.7.2 · **Apareció en:** [Fase 05](05-una-persona-no-es-su-documento.md#-6-el-contraste-dónde-otro-motor-cambia-la-decisión), 13/10/2026

```text
ERROR 1305 (42000) at line 3: FUNCTION legacy.similarity does not exist
```

- **Qué lo provocó:** una consulta escrita para Postgres con `pg_trgm`. MySQL no tiene similitud por
  trigramas.
- **Cómo se confirma:** el mensaje nombra la función con el esquema delante: MySQL la buscó como función
  del usuario y no la encontró.
- **Cómo se sale:** el bloqueo en SQL y la similitud en la aplicación, sobre los pares candidatos.

### E-23 · Un `DELETE` de paciente que el disparador no deja pasar

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 05](05-una-persona-no-es-su-documento.md#55-tres-niveles-una-cola-y-una-fusión-que-nunca-borra), 13/10/2026

```text
ERROR:  a patient is never deleted: merge 1 into another patient instead
CONTEXT:  PL/pgSQL function alameda.patient_forbid_delete() line 3 at RAISE
```

- **Qué lo provocó:** un `DELETE` sobre `alameda.patient`. Es el comportamiento buscado: la fusión nunca
  borra.
- **Cómo se confirma:** `SELECT tgname FROM pg_trigger WHERE tgrelid = 'alameda.patient'::regclass;`
- **Cómo se sale:** fusionar, con una fila en `alameda.patient_merge` y las tres columnas `merged_*` del
  paciente.

### E-24 · `WITHOUT OVERLAPS` sobre una columna entera

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 07](07-el-tiempo-en-el-modelo.md#51-el-precio-como-rango-y-la-restricción-que-lo-cuida), 14/10/2026

```text
ERROR:  data type integer has no default operator class for access method "gist"
HINT:  You must specify an operator class for the index or define a default operator class for the data type.
```

- **Qué lo provocó:** una clave `PRIMARY KEY (k, v WITHOUT OVERLAPS)` con `k integer`. La restricción se implementa
  con un índice `gist`, y los tipos escalares no tienen clase de operador `gist` por defecto.
- **Cómo se confirma:** `SELECT extname FROM pg_extension WHERE extname = 'btree_gist';` no devuelve nada.
- **Cómo se sale:** `CREATE EXTENSION btree_gist;` en la base, antes de crear la tabla.

### E-25 · Un rango vacío en una clave `WITHOUT OVERLAPS`

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 07](07-el-tiempo-en-el-modelo.md#-8-el-punto-de-rotura), 14/10/2026

```text
ERROR:  empty WITHOUT OVERLAPS value found in column "valid_during" in relation "agreement_price"
```

- **Qué lo provocó:** un rango `[d, d)`, que sale de calcular el fin de una vigencia con `lead()` cuando otra
  empieza el mismo día.
- **Cómo se confirma:** `SELECT count(*) FROM … WHERE isempty(valid_during);`
- **Cómo se sale:** encontrar los días duplicados antes de cargar y decidir qué hacer con ellos (en la fase, a la
  tabla de rechazos). Una restricción de exclusión común los habría aceptado en silencio.

### E-26 · `WITHOUT OVERLAPS` en MySQL

**Motor y versión:** MySQL 9.7.2 · **Apareció en:** [Fase 07](07-el-tiempo-en-el-modelo.md#-6-el-contraste-dónde-otro-motor-cambia-la-decisión), 14/10/2026

```text
ERROR 1064 (42000) at line 4: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'WITHOUT OVERLAPS))' at line 1
```

- **Qué lo provocó:** una clave con período, que MySQL no tiene, como tampoco tiene tipos de rango.
- **Cómo se confirma:** el mensaje señala `WITHOUT OVERLAPS`.
- **Cómo se sale:** dos columnas de fecha, un `CHECK (valid_from < valid_to)` y un disparador que rechace la
  superposición, sabiendo que no protege contra dos sesiones concurrentes.

### E-27 · Texto que no es un número, en una conversión

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 08](08-los-dos-extremos-del-mismo-error.md#-8-el-punto-de-rotura), 14/10/2026

```text
ERROR:  invalid input syntax for type numeric: "HEMOLIZADA"
```

- **Qué lo provocó:** `value::numeric` sobre el valor del EAV, que guarda como texto las observaciones de la
  muestra.
- **Cómo se confirma:** `SELECT DISTINCT value FROM … WHERE value !~ '^[<>]?[0-9]+([.,][0-9]+)?$';`
- **Cómo se sale:** un `CASE` que convierte solo lo que es un número. Un `AND` con la expresión regular delante no
  alcanza: el orden de evaluación no está garantizado.

### E-28 · Volver a correr un script que borra una tabla de la que otras dependen

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 08](08-los-dos-extremos-del-mismo-error.md#56-el-modelo-del-bloque-i-con-un-comando), 14/10/2026

```text
ERROR:  cannot drop table alameda.payer because other objects depend on it
DETAIL:  constraint payer_practice_payer_code_fkey on table alameda.payer_practice depends on table alameda.payer
constraint payer_site_payer_code_fkey on table alameda.payer_site depends on table alameda.payer
HINT:  Use DROP ... CASCADE to drop the dependent objects too.
```

- **Qué lo provocó:** volver a correr el `03_payer.sql` de la Fase 04 cuando ya existían las tablas de la Fase 06
  que apuntan a `alameda.payer`.
- **Cómo se confirma:** el `DETAIL` lista las restricciones que dependen de la tabla.
- **Cómo se sale:** correr el modelo entero con `uv run lab load --profile m --model`, que borra `staging` y
  `alameda` y los rehace en orden. Los scripts que otras fases referencian borran con `CASCADE`.

### E-29 · Un paquete más grande que `max_allowed_packet`

**Motor y versión:** MySQL 9.7.2 y PyMySQL · **Apareció en:** [Fase 09](09-el-tamano-de-las-cosas.md), 14/10/2026

```text
OperationalError: (2006, "MySQL server has gone away (BrokenPipeError(32, 'Broken pipe'))")
```

- **Qué lo provocó:** un `INSERT` con un PDF de 70 MB, por encima de los 64 MB de `max_allowed_packet` del laboratorio. El servidor corta la conexión en lugar de responder con un error.
- **Cómo se confirma:** `SELECT @@max_allowed_packet;` y el tamaño del valor que se mandaba: el mismo `INSERT` con un archivo más chico pasa.
- **Cómo se sale:** guardar el archivo fuera de la base, con su ruta y su hash (Fase 09), o subir `max_allowed_packet` en el servidor y en el cliente.

### E-30 · Una fila que no tiene partición

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 09](09-el-tamano-de-las-cosas.md), 14/10/2026

```text
ERROR:  no partition of relation "result_by_month" found for row
DETAIL:  Partition key of the failing row contains (recorded_at) = (2026-11-02 09:00:00).
```

- **Qué lo provocó:** un resultado de noviembre de 2026 en una tabla particionada por mes cuyas particiones llegaban a octubre.
- **Cómo se confirma:** el `DETAIL` muestra el valor de la clave de partición; `\d+ staging.result_by_month` lista las particiones que existen.
- **Cómo se sale:** crear la partición del mes antes de que llegue (una tarea programada que crea la del mes siguiente), o una partición `DEFAULT` que reciba lo que no tiene lugar.

### E-31 · La clave duplicada después de una carga con identificadores propios

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 10](10-identificadores.md), 14/10/2026

```text
ERROR:  duplicate key value violates unique constraint "lab_order_new_pkey"
DETAIL:  Key (lab_order_id)=(1) already exists.
```

- **Qué lo provocó:** cargar los protocolos con sus números viejos en una columna `GENERATED BY DEFAULT AS IDENTITY` y después insertar uno nuevo: la secuencia seguía en 1.
- **Cómo se confirma:** `SELECT last_value FROM` la secuencia, contra el `max()` de la columna.
- **Cómo se sale:** `SELECT setval(pg_get_serial_sequence('tabla', 'columna'), max(columna)) FROM tabla;` después de toda carga con identificadores propios.

### E-32 · La secuencia llegó al techo del `integer`

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 10](10-identificadores.md), 14/10/2026

```text
ERROR:  nextval: reached maximum value of sequence "lab_order_new_lab_order_id_seq" (2147483647)
```

- **Qué lo provocó:** una columna `integer` con identidad, adelantada a 2.147.483.647 para medir el techo.
- **Cómo se confirma:** `SELECT last_value, max_value FROM pg_sequences WHERE sequencename = …`.
- **Cómo se sale:** cambiar la columna a `bigint` (y la secuencia con ella) antes de llegar: con una tabla grande, es una reescritura que conviene planear.

### E-33 · `AUTO_INCREMENT` en el techo repite el último valor

**Motor y versión:** MySQL 9.7.2 · **Apareció en:** [Fase 10](10-identificadores.md), 14/10/2026

```text
ERROR 1062 (23000) at line 3: Duplicate entry '2147483647' for key 'lab_order_new.PRIMARY'
```

- **Qué lo provocó:** una columna `int` con `AUTO_INCREMENT` que llegó a 2.147.483.647: MySQL vuelve a dar el máximo, y la clave primaria lo rechaza.
- **Cómo se confirma:** `SELECT AUTO_INCREMENT FROM information_schema.tables WHERE …` y el tipo de la columna.
- **Cómo se sale:** cambiar a `bigint` con `ALTER TABLE … MODIFY`, que en InnoDB copia la tabla.

### E-34 · Insertar un valor en una identidad `GENERATED ALWAYS`

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 10](10-identificadores.md), 14/10/2026

```text
ERROR:  cannot insert a non-DEFAULT value into column "id"
DETAIL:  Column "id" is an identity column defined as GENERATED ALWAYS.
HINT:  Use OVERRIDING SYSTEM VALUE to override.
```

- **Qué lo provocó:** un `INSERT` que traía el identificador, como el de una migración, en una columna que solo acepta los que genera el motor.
- **Cómo se confirma:** el `DETAIL` nombra la columna y su modo.
- **Cómo se sale:** `INSERT … OVERRIDING SYSTEM VALUE`, a propósito y solo en la migración; después, ajustar la secuencia (E-31).

### E-35 · Un valor demasiado grande para un índice B-tree

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 11](11-indices-y-lo-que-cuestan.md), 14/10/2026

```text
ERROR:  index row size 2984 exceeds btree version 4 maximum 2704 for index "order_note_note_idx"
DETAIL:  Index row references tuple (3,60) in relation "order_note".
HINT:  Values larger than 1/3 of a buffer page cannot be indexed.
Consider a function index of an MD5 hash of the value, or use full text indexing.
```

- **Qué lo provocó:** una nota de texto libre de 3 kB en una columna con índice B-tree: una entrada no puede pasar de un tercio de página.
- **Cómo se confirma:** el `DETAIL` señala la fila; `SELECT max(octet_length(note))` muestra el valor más largo.
- **Cómo se sale:** un índice sobre el MD5 del valor, si se busca por igualdad, o un índice GIN de texto completo, si se busca por contenido.

### E-36 · Una clave de índice más larga de lo que MySQL permite

**Motor y versión:** MySQL 9.7.2 · **Apareció en:** [Fase 11](11-indices-y-lo-que-cuestan.md), 14/10/2026

```text
ERROR 1071 (42000) at line 3: Specified key was too long; max key length is 3072 bytes
```

- **Qué lo provocó:** un índice sobre un `varchar(5000)` en `utf8mb4`, que puede ocupar hasta 20.000 bytes.
- **Cómo se confirma:** el largo declarado de la columna por 4 bytes por carácter, contra 3.072.
- **Cómo se sale:** un índice por prefijo (`note(100)`) o sobre una columna generada con el hash del valor.

### E-37 · Un índice sobre `TEXT` sin largo

**Motor y versión:** MySQL 9.7.2 · **Apareció en:** [Fase 11](11-indices-y-lo-que-cuestan.md), 14/10/2026

```text
ERROR 1170 (42000) at line 5: BLOB/TEXT column 'note' used in key specification without a key length
```

- **Qué lo provocó:** un índice sobre una columna `text`, que MySQL solo indexa por un prefijo.
- **Cómo se confirma:** el tipo de la columna en `SHOW CREATE TABLE`.
- **Cómo se sale:** declarar el prefijo (`note(100)`), sabiendo que el índice solo distingue esos primeros caracteres.

### E-38 · La consulta que el límite de tiempo cancela

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 12](12-estadisticas-y-cardinalidad.md) y [Fase 14](14-la-base-no-estaba-lenta.md), 14/10/2026

```text
ERROR:  canceling statement due to statement timeout
```

- **Qué lo provocó:** en la Fase 12, el informe de las PCR repetidas con estadísticas viejas, cortado a los 300 s; en la Fase 14, una página profunda con `OFFSET` bajo un límite de 100 ms.
- **Cómo se confirma:** `SHOW statement_timeout;` y el plan de la consulta con un caso más chico: un *nested loop* sobre una estimación de 1 fila, o un `OFFSET` grande.
- **Cómo se sale:** arreglar la causa (un `ANALYZE`, *keyset*), no subir el límite: el límite es lo único que impidió que la consulta siguiera horas.

### E-39 · Un `FORCE INDEX` que nombra un índice que ya no existe

**Motor y versión:** MySQL 9.7.2 · **Apareció en:** [Fase 13](13-el-optimizador-en-tres-motores.md), 14/10/2026

```text
ERROR 1176 (42000) at line 36: Key 'protocol_hint_fecha_idx' doesn't exist in table 'protocol_hint'
```

- **Qué lo provocó:** una consulta con un hint de índice escrita cuando el índice existía; alguien lo borró o lo renombró.
- **Cómo se confirma:** `SHOW INDEX FROM` la tabla.
- **Cómo se sale:** quitar el hint y medir el plan sin él; si el hint todavía hace falta, apuntarlo al índice nuevo, con su fecha y su medición al lado.

### E-40 · Un *optimizer hint* que no encuentra lo que nombra

**Motor y versión:** MySQL 9.7.2 · **Apareció en:** [Fase 13](13-el-optimizador-en-tres-motores.md), 14/10/2026

```text
Warning	3128	Unresolved name `p`@`select#1` `protocol_hint_gone_idx` for INDEX hint
```

- **Qué lo provocó:** un `/*+ INDEX(p …) */` con un índice que no existe. No es un error: es un aviso, y la consulta corre con el plan que elija el optimizador.
- **Cómo se confirma:** `SHOW WARNINGS` inmediatamente después de la consulta; ningún *driver* lo muestra por defecto.
- **Cómo se sale:** el mismo que E-39. El aviso es más fácil de pasar por alto que el error, así que conviene buscarlo en `performance_schema` o en los registros.

### E-41 · Dos transacciones `SERIALIZABLE` que se pisan sin tocar la misma fila

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 15](15-aislamiento-comparado.md), 14/10/2026

```text
ERROR:  could not serialize access due to read/write dependencies among transactions
DETAIL:  Reason code: Canceled on identification as a pivot, during commit attempt.
HINT:  The transaction might succeed if retried.
```

- **Qué lo provocó:** dos técnicos que en `SERIALIZABLE` leen que la muestra está libre y la toman los dos, en filas distintas. El SSI detecta el ciclo de dependencias y aborta a uno; aquí, en su `COMMIT` (SQLSTATE `40001`).
- **Cómo se confirma:** el `DETAIL` empieza con `Reason code`: es el SSI, no un conflicto de escritura. `pg_locks` muestra los `SIReadLock` de las dos transacciones antes del `COMMIT`.
- **Cómo se sale:** reintentar la transacción entera, desde el `BEGIN`, con espera aleatoria y un tope. Si la regla se puede escribir como restricción, en `READ COMMITTED` no hace falta el nivel.

### E-42 · `REPEATABLE READ` no deja escribir una fila que otra cambió

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 15](15-aislamiento-comparado.md), 14/10/2026

```text
ERROR:  could not serialize access due to concurrent update
```

- **Qué lo provocó:** dos cajas que cobran al mismo deudor en `REPEATABLE READ`; la segunda espera a la primera y, cuando la primera confirma, su `UPDATE` falla (SQLSTATE `40001`, sin `DETAIL` ni `HINT`).
- **Cómo se confirma:** el mensaje dice `concurrent update`, no `read/write dependencies`: es un conflicto de escritura sobre la misma fila.
- **Cómo se sale:** reintentar entera, o escribir el cobro como `UPDATE … SET balance = balance - …` en `READ COMMITTED`, que espera y resta sobre lo confirmado.

### E-43 · Un *deadlock* entre dos lecturas que después quieren escribir

**Motor y versión:** MySQL 9.7.2 · **Apareció en:** [Fase 15](15-aislamiento-comparado.md), 14/10/2026

```text
ERROR 1213 (40001) at line 1: Deadlock found when trying to get lock; try restarting transaction
pymysql.err.OperationalError: (1213, 'Deadlock found when trying to get lock; try restarting transaction')
```

- **Qué lo provocó:** en `SERIALIZABLE`, o con `SELECT … FOR UPDATE` en `REPEATABLE READ`, las dos transacciones toman un bloqueo compartido (o del hueco del índice) que es compatible entre ellas, y después cada una quiere escribir donde la otra tiene el suyo. MySQL deshace una entera.
- **Cómo se confirma:** `SHOW ENGINE INNODB STATUS`, sección `LATEST DETECTED DEADLOCK`, o `performance_schema.data_locks` antes de que ocurra: dos `S` (o dos `X,GAP`) concedidos y un `X` en espera.
- **Cómo se sale:** reintentar la transacción entera, como dice el mensaje. Para no llegar: bloquear con `FOR UPDATE` desde la primera lectura, en el mismo orden en todas las transacciones ([Fase 18](18-bloqueos-deadlocks-y-ddl.md)).

### E-44 · La transacción ociosa que el servidor corta

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 17](17-mvcc-y-su-factura.md), 14/10/2026

```text
psycopg.errors.IdleInTransactionSessionTimeout: terminating connection due to idle-in-transaction timeout
```

- **Qué lo provocó:** una sesión con `idle_in_transaction_session_timeout = '5s'` que abrió una transacción `REPEATABLE READ`,
  leyó, y se quedó esperando sin confirmar. El servidor cierra la conexión (SQLSTATE `25P03`); la transacción se deshace.
- **Cómo se confirma:** el registro del servidor tiene la misma línea con `FATAL`; antes de que pase, `pg_stat_activity` muestra
  la sesión en `idle in transaction`.
- **Cómo se sale:** no es un error que haya que arreglar en el servidor: es la defensa contra una transacción que retiene el
  horizonte o un bloqueo. Lo que se arregla es la aplicación que abrió la transacción y no la cerró. La conexión ya no sirve: el
  *pool* tiene que descartarla.

### E-45 · Dos correcciones que se esperan una a la otra

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 18](18-bloqueos-deadlocks-y-ddl.md), 14/10/2026

```text
ERROR:  deadlock detected
DETAIL:  Process 83965 waits for ShareLock on transaction 378885; blocked by process 83966.
Process 83966 waits for ShareLock on transaction 378884; blocked by process 83965.
HINT:  See server log for query details.
CONTEXT:  while updating tuple (0,2) in relation "hemogram"
```

- **Qué lo provocó:** dos transacciones que actualizan los mismos dos hemogramas en orden contrario (SQLSTATE `40P01`). Postgres lo
  detecta cuando una de las dos lleva `deadlock_timeout` (1 s) esperando, y aborta a esa.
- **Cómo se confirma:** el registro del servidor repite el mensaje con la consulta de cada proceso (`Process 83965: UPDATE …`).
- **Cómo se sale:** reintentar la transacción entera; para que no vuelva, tomar las filas siempre en el mismo orden (por clave).

### E-46 · La espera que `lock_timeout` corta

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 18](18-bloqueos-deadlocks-y-ddl.md), 14/10/2026

```text
ERROR:  canceling statement due to lock timeout
CONTEXT:  while updating tuple (329,31) in relation "hemogram"
```

- **Qué lo provocó:** una sesión con `lock_timeout = '1s'` que quiso actualizar un hemograma que otra tenía tomado con `FOR UPDATE`
  (SQLSTATE `55P03`). Con el mismo límite, un `ALTER TABLE` en la cola de un `ACCESS EXCLUSIVE` recibe el mismo mensaje, sin
  `CONTEXT`.
- **Cómo se confirma:** `pg_stat_activity` con `pg_blocking_pids(pid)` mientras espera.
- **Cómo se sale:** la transacción quedó abortada: `ROLLBACK` y reintentar; o encontrar al que retiene (casi siempre, una sesión
  `idle in transaction`).

### E-47 · `NOWAIT` encuentra la fila tomada

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 18](18-bloqueos-deadlocks-y-ddl.md), 14/10/2026

```text
ERROR:  could not obtain lock on row in relation "hemogram"
```

- **Qué lo provocó:** `SELECT … FOR UPDATE NOWAIT` sobre una fila que otra transacción tenía bloqueada (SQLSTATE `55P03`, el mismo
  de E-46).
- **Cómo se confirma:** el mismo `FOR UPDATE` sin `NOWAIT` queda esperando.
- **Cómo se sale:** es la respuesta pedida: la aplicación avisa que el registro está en uso, o toma otro con `SKIP LOCKED`.

### E-48 · El tiempo de espera de MySQL, que deshace solo la sentencia

**Motor y versión:** MySQL 9.7.2 · **Apareció en:** [Fase 18](18-bloqueos-deadlocks-y-ddl.md), 14/10/2026

```text
ERROR 1205 (HY000) at line 1: Lock wait timeout exceeded; try restarting transaction
```

- **Qué lo provocó:** un `UPDATE` que esperó más de `innodb_lock_wait_timeout` una fila tomada por otra transacción. El mismo mensaje
  aparece cuando un DDL espera más de `lock_wait_timeout` un *metadata lock* (que por defecto es un año).
- **Cómo se confirma:** `SELECT @@innodb_rollback_on_timeout`: con 0, como viene, la transacción **sigue abierta** con todo lo
  anterior al `UPDATE`.
- **Cómo se sale:** `ROLLBACK` explícito antes de reintentar; confirmar después de atrapar el 1205 deja la transacción a medias.

### E-49 · Un algoritmo de DDL que no corresponde al cambio

**Motor y versión:** MySQL 9.7.2 · **Apareció en:** [Fase 18](18-bloqueos-deadlocks-y-ddl.md), 14/10/2026

```text
ERROR 1846 (0A000) at line 1: ALGORITHM=INPLACE is not supported. Reason: Cannot change column type INPLACE. Try ALGORITHM=COPY.
ERROR 1846 (0A000) at line 1: ALGORITHM=INSTANT is not supported. Reason: Need to rebuild the table to change column type. Try ALGORITHM=COPY/INPLACE.
```

- **Qué lo provocó:** `ALTER TABLE … MODIFY balance decimal(14,2)` pidiendo `INPLACE` o `INSTANT`: cambiar el tipo copia la tabla.
- **Cómo se confirma:** el mismo `ALTER` con `ALGORITHM=COPY` funciona, y bloquea las escrituras mientras copia.
- **Cómo se sale:** no es un error a evitar: es el aviso de que el cambio cierra la tabla. Se hace por pasos (columna nueva, copia en
  lotes, cambio de lectura) o en una ventana.

### E-50 · La validación de una restricción que los datos no cumplen

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** [Fase 18](18-bloqueos-deadlocks-y-ddl.md), 14/10/2026

```text
ERROR:  check constraint "result_ddl_has_value" of relation "result_ddl" is violated by some row
```

- **Qué lo provocó:** `VALIDATE CONSTRAINT` de un `CHECK` agregado `NOT VALID` ("todo resultado tiene un valor") sobre los resultados
  de la caja, que traen 359.662 vacíos (SQLSTATE `23514`).
- **Cómo se confirma:** la misma condición negada en un `SELECT count(*)`.
- **Cómo se sale:** la restricción queda `NOT VALID` y vale para las filas nuevas; las viejas se corrigen o se aceptan, y recién
  entonces se valida.

### E-51 · La foto que el undo ya no tiene

**Motor y versión:** Oracle AI Database 26ai Free 23.26.3 · **Apareció en:** una corrida privada hecha para obtener el mensaje
literal, 14/10/2026; lo cita la [Fase 17](17-mvcc-y-su-factura.md)

```text
ORA-01555: snapshot too old: rollback segment number 13 with name
"_SYSSMU13_4038408623$" too small
Help: https://docs.oracle.com/error-help/db/ora-01555/
```

- **Qué lo provoca, según la documentación:** una lectura consistente que necesita registros de *undo* que otras escrituras ya
  sobrescribieron. Las condiciones de la corrida no se publican: la apuesta de la Fase 17 sigue abierta
  ([`a09`](a09-licencias-publicacion-y-riesgo.md)).
- **Cómo se confirma:** `V$UNDOSTAT` muestra las consultas más largas y los errores de "snapshot too old" por intervalo.
- **Cómo se sale:** subir `UNDO_RETENTION` (y el tamaño del *undo* para que la retención se pueda cumplir), acortar la lectura, o no
  reescribir las filas que la lectura recorre mientras dura.

### E-52 · `SERIALIZABLE` en Oracle, al escribir una fila que otra cambió

**Motor y versión:** Oracle AI Database 26ai Free 23.26.3 · **Apareció en:** una corrida privada hecha para obtener el mensaje
literal, 14/10/2026; lo cita la [Fase 15](15-aislamiento-comparado.md)

```text
ORA-08177: can't serialize access for this transaction
Help: https://docs.oracle.com/error-help/db/ora-08177/
```

- **Qué lo provoca, según la documentación:** una transacción serializable que encuentra datos cambiados por una operación
  posterior a su comienzo. Las condiciones de la corrida no se publican: la apuesta de la Fase 15 sigue abierta.
- **Cómo se confirma:** el nivel de la transacción (`SET TRANSACTION ISOLATION LEVEL SERIALIZABLE`) y la fila que intentó cambiar.
- **Cómo se sale:** reintentar la transacción entera, como el `40001` de Postgres (E-42).

### E-53 · El *deadlock* en Oracle

**Motor y versión:** Oracle AI Database 26ai Free 23.26.3 · **Apareció en:** una corrida privada hecha para obtener el mensaje
literal, 14/10/2026; lo cita la [Fase 18](18-bloqueos-deadlocks-y-ddl.md)

```text
ORA-00060: deadlock detected while waiting for resource
Help: https://docs.oracle.com/error-help/db/ora-00060/
```

- **Qué lo provoca, según la documentación:** transacciones que se esperan unas a otras, como las dos de `deadlock.race`. Qué
  sesión lo recibe y qué conserva es parte de la apuesta de la Fase 18, que sigue abierta.
- **Cómo se confirma:** el archivo de traza que Oracle escribe con cada *deadlock* (lo indica el registro de alertas) tiene el grafo
  de esperas.
- **Cómo se sale:** reintentar después de deshacer lo que corresponda; para que no vuelva, el mismo orden de filas en todas las
  transacciones (E-45).

### E-54 · `@>` no existe para `json`

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** Fase 19 (ejercicio 1)

```text
ERROR:  operator does not exist: json @> json
HINT:  No operator matches the given name and argument types. You might need to add explicit type casts.
```

- **Qué lo provoca:** usar `@>` sobre `json`, que guarda el texto y no tiene índices ni operadores de contención.
- **Cómo se confirma:** la misma consulta con `::jsonb` responde.
- **Cómo se sale:** guardar la columna como `jsonb`, o convertir con `::jsonb` antes de comparar.

### E-55 · Un `CHECK` que rechaza una sensibilidad inválida

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** Fase 19 (§5.3)

```text
ERROR:  new row for relation "culture_doc" violates check constraint "antibiogram_values_valid"
DETAIL:  Failing row contains (-1, 1, 2020-01-01, X, {"AMPICILINA": "X"}).
```

- **Qué lo provoca:** insertar un antibiograma con una sensibilidad distinta de `S`, `I` o `R`. La prueba lo provoca a propósito; la restricción está bien.
- **Cómo se confirma:** el nombre de la restricción en el mensaje.
- **Cómo se sale:** corregir el valor en la aplicación. No se quita la restricción.

### E-56 · Un `UPDATE` con subconsulta sobre la misma tabla

**Motor y versión:** MySQL 9.7 · **Apareció en:** Fase 19 (§6.1)

```text
ERROR 1093 (HY000) at line 29: You can't specify target table 'culture_doc' for update in FROM clause
```

- **Qué lo provoca:** `UPDATE culture_doc … WHERE culture_id = (SELECT MIN(culture_id) FROM culture_doc …)`: la subconsulta lee la tabla que se actualiza.
- **Cómo se confirma:** la subconsulta menciona la tabla del `UPDATE`.
- **Cómo se sale:** guardar el valor en una variable de sesión (`SELECT … INTO @cid`) antes del `UPDATE`.

### E-57 · Un índice nombrado sin su esquema

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** Fase 19 (ejercicio 9)

```text
ERROR:  relation "ex_gin_ops" does not exist
```

- **Qué lo provoca:** `pg_relation_size('ex_gin_ops')` sin esquema busca en `public`, pero el índice se creó en `staging`.
- **Cómo se confirma:** la misma consulta con `staging.ex_gin_ops` funciona.
- **Cómo se sale:** calificar los objetos con su esquema en los scripts.

### E-58 · El validador de MongoDB rechaza un protocolo sin pagador

**Motor y versión:** MongoDB 8.0.20 · **Apareció en:** Fase 20 (ejercicio 2)

```text
Document failed validation
```

- **Qué lo provoca:** insertar un documento sin `payer`, que el `$jsonSchema` marca como requerido.
- **Cómo se confirma:** el detalle del error (`e.details`) nombra el campo que falta.
- **Cómo se sale:** completar el documento. La forma no se relaja para que pase.

### E-59 · El operador `%` con parámetros en psycopg

**Motor y versión:** PostgreSQL 18.6, con psycopg 3 · **Apareció en:** Fase 21 (boss IV, primera versión de la solución)

```text
ProgrammingError: incomplete placeholder: '%'; if you want to use '%' as an operator you can double it up, i.e. use '%  (truncado en la salida del arnés)
```

- **Qué lo provoca:** el operador de similitud `%` escrito en una consulta que lleva parámetros.
- **Cómo se confirma:** la misma consulta sin parámetros funciona.
- **Cómo se sale:** escribir `%%` cuando la consulta tiene parámetros.

### E-60 · Un parámetro sin tipo dentro de la construcción de `jsonb`

**Motor y versión:** PostgreSQL 18.6, con psycopg 3 · **Apareció en:** Fase 21 (boss IV, primera versión de la solución)

```text
IndeterminateDatatype: could not determine data type of parameter $5
```

- **Qué lo provoca:** un parámetro de texto dentro de `jsonb_build_object` o de `||`, sin cast.
- **Cómo se sale:** `%s::text` en el parámetro.

### E-61 · Un DDL que se corre dos veces

**Motor y versión:** MySQL 9.7 · **Apareció en:** Fase 19 (§6, la columna generada)

```text
ERROR 1060 (42S21) at line 10: Duplicate column name 'meropenem'
```

- **Qué lo provoca:** el `ALTER TABLE … ADD COLUMN` estaba en un script de consulta que se volvió a correr.
- **Cómo se sale:** dejar el DDL en el script de preparación, que corre una vez (así quedó en `04_mysql_setup.sql`).

### E-62 · Dos corridas a la vez sobre las mismas tablas de prueba

**Motor y versión:** PostgreSQL 18.6, con psycopg 3 · **Apareció en:** Fase 22 (la prueba de marca de agua, lanzada dos veces por error)

```text
psycopg.errors.UniqueViolation: duplicate key value violates unique constraint "f22_result_pkey"
DETAIL:  Key (result_id)=(10500365) already exists.
```

- **Qué lo provocó:** una segunda corrida del experimento arrancó mientras la primera seguía viva, y las dos escribían en `staging.f22_result`.
- **Cómo se confirma:** `pg_stat_activity` muestra más sesiones de escritura que las que lanza una corrida.
- **Cómo se sale:** terminar los procesos sobrantes y correr las variantes en serie. Una prueba de concurrencia no se lanza dos veces sobre las mismas tablas.

### E-63 · `percentile_cont` no acepta una fecha

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** Fase 22 (ejercicio 6)

```text
ERROR:  function percentile_cont(numeric, timestamp without time zone) does not exist
HINT:  No function matches the given name and argument types. You might need to add explicit type casts.
```

- **Qué lo provoca:** `percentile_cont(0.5) WITHIN GROUP (ORDER BY recorded_at)` sobre un `timestamp`.
- **Cómo se sale:** calcular el percentil sobre `extract(epoch FROM recorded_at)` y comparar en segundos.

### E-64 · La vista sin permisos para el rol anónimo

**Motor y versión:** PostgreSQL 18.6, con PostgREST v16.4 · **Apareció en:** Fase 23 (ejercicio 2 y el pedido sin token)

```text
ERROR:  permission denied for view resultados
```

- **Qué lo provoca:** el rol `web_anon` (sin token) no tiene `SELECT` sobre las vistas de `api`. Es lo que se quiere.
- **Cómo se confirma:** PostgREST responde HTTP 401 con el mismo mensaje.
- **Cómo se sale:** con un token de un rol que tenga permiso; no se le da permiso a `web_anon` sobre datos.

### E-65 · Una fila que viola la política de escritura

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** Fase 23 (§7 y ejercicio 10)

```text
ERROR:  new row violates row-level security policy for table "result"
```

- **Qué lo provoca:** una política `FOR INSERT … WITH CHECK` que la fila nueva no cumple: el médico carga en un protocolo que no derivó.
- **Cómo se confirma:** `pg_policies` muestra la política de `INSERT` de la tabla.
- **Cómo se sale:** corregir la fila o el rol; no se quita la política.

### E-66 · Los claims vacíos rompen la política

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** Fase 23 (ejercicio 16, primera versión de `api.claim`)

```text
ERROR:  invalid input syntax for type json
DETAIL:  The input string ended unexpectedly.
```

- **Qué lo provoca:** después de un `set_config` en la sesión, `current_setting('request.jwt.claims', true)` devuelve `''` y no `NULL`, y `''::json` falla.
- **Cómo se sale:** `nullif(current_setting('request.jwt.claims', true), '')::json` en la función que lee los claims.

### E-67 · `recover()` y la precarga del consumidor en Artemis

**Motor y versión:** Apache Artemis 2.57.0, cliente Jakarta · **Apareció en:** Fase 23 (boss del puente, primera versión del consumidor)

```text
jakarta.jms.IllegalStateException: AMQ229027: Could not find reference on consumerId = 0, messageId = 215 queue = sih.oru
```

- **Qué lo provocó:** sesiones `CLIENT_ACKNOWLEDGE` con `recover()` para simular la caída, con varios consumidores; el broker no encontró la referencia del mensaje a reentregar, y los consumidores terminaron con 688 mensajes pendientes en la cola.
- **Cómo se confirma:** `artemis queue stat` muestra mensajes en la cola y ningún consumidor.
- **Cómo se sale:** sesiones transaccionales: `commit` cuando el mensaje se aplicó, `rollback` para que se reentregue.

### E-68 · Montar las dependencias sobre `/lib` del contenedor de Java

**Motor y versión:** Docker Desktop, imagen de Eclipse Temurin 25 · **Apareció en:** Fase 23 (boss del puente, primera versión del arnés)

```text
exec /__cacert_entrypoint.sh: no such file or directory
```

- **Qué lo provocó:** el volumen con las jars se montó en `/lib`, que en la imagen es el directorio de las bibliotecas del sistema; el contenedor no pudo arrancar su propio script.
- **Cómo se sale:** montar las dependencias en otro directorio (`/deps`) y pasarlo en el `-cp`.

### E-69 · La memoria compartida del contenedor se llena

**Motor y versión:** PostgreSQL 18.6 en Docker Desktop, con el `/dev/shm` de 64 MB que Docker da por defecto · **Apareció en:** Fase 25 (`03_cantidad.sql`, primera versión)

```text
ERROR:  could not resize shared memory segment "/PostgreSQL.2821075686" to 8388608 bytes: No space left on device
```

- **Qué lo provocó:** una consulta con cuatro subconsultas sobre 1,7 millones de filas, cada una con un *hash join* en paralelo. Los procesos paralelos se reparten el trabajo por memoria compartida dinámica, que vive en `/dev/shm`, y 64 MB no alcanzaron.
- **Cómo se confirma:** `docker exec alameda-lab-postgres-1 df -h /dev/shm`. Si dice 64M, es este error; si dice 512M, el compose del curso ya está aplicado y lo que sobra es `work_mem` (abajo).
- **Cómo se sale:** reescribir la consulta en una sola pasada (es lo que hace la versión publicada), o bajar el paralelismo de la sesión (`SET max_parallel_workers_per_gather = 0`). Desde el 18/10/2026 el compose le da a Postgres `shm_size: 512m` ([`a02`](a02-compose-de-la-ruta.md#-memoria-por-servicio)), y la misma consulta con cuatro procesos pasa hasta `work_mem = '32MB'`; con 64 MB vuelve a fallar ([M-58](bitacora-de-medicion.md#m-58--a02--el-devshm-del-contenedor-de-postgres-y-el-hash-join-en-paralelo)). Más `/dev/shm` corre el borde, no lo elimina.

### E-70 · Partir un rango de precios en dos sentencias

**Motor y versión:** PostgreSQL 18.6 · **Apareció en:** Fase 26 (el aumento de octubre del 🏆 "Un martes", al probarlo)

```text
ERROR:  update or delete on table "agreement_price" violates foreign key constraint "billed_practice_agreement_price_fkey" on table "billed_practice"
DETAIL:  Key (payer_code, practice_id, valid_during)=(PAMI, 1, [2026-07-01,)) is still referenced from table "billed_practice".
```

- **Qué lo provocó:** acortar el rango abierto de un precio a `[2026-07-01, 2026-10-01)` con un `UPDATE`, para después insertar el precio nuevo desde el 1 de octubre. Entre las dos sentencias, lo facturado de octubre se queda sin vigencia que lo cubra, y la clave foránea con período lo rechaza al final de la primera sentencia.
- **Cómo se sale:** partir el rango en **una sola sentencia**, con un CTE de escritura que acorta el viejo y devuelve lo necesario para insertar el nuevo. Postgres 18 no tiene `UPDATE … FOR PORTION OF`.

### E-71 · Un slot lógico en una transacción que ya escribió

**Motor y versión:** PostgreSQL 18.6, desde psycopg 3 · **Apareció en:** Fase 26 (el arnés del 🏆 "Un martes", primera versión)

```text
psycopg.errors.ActiveSqlTransaction: cannot create logical replication slot in transaction that has performed writes
```

- **Qué lo provocó:** mandar `04_cdc_setup.sql` entero en un solo `execute`. Con varias sentencias en un mismo mensaje, el servidor las corre en una transacción implícita, y el archivo borra filas antes de crear el slot. Con `psql`, que manda sentencia por sentencia, no pasa.
- **Cómo se sale:** correr el archivo sentencia por sentencia (`cdc.correr_sql`), o crear el slot antes de cualquier escritura, en su propia transacción.

### E-72 · Lo que ve el frontal cuando se congela legacy

**Motor y versión:** PostgreSQL 18.6, desde psycopg 3 · **Apareció en:** Fase 25 (`07_corte.py`)

```text
psycopg.errors.AdminShutdown: terminating connection due to administrator command
psycopg.errors.InsufficientPrivilege: permission denied for table Protocolos
```

- **Qué lo provocó:** el corte le quita la escritura al rol `access_frontend` y corta sus sesiones con `pg_terminate_backend`. La sesión que estaba abierta recibe el primero; la que alcanza a reconectarse antes de que termine el corte, el segundo.
- **Cómo se sale:** no se sale: es lo que tiene que ver recepción durante la ventana del corte. Lo que sí se hace es avisarle antes, y que el frontal muestre un mensaje propio en lugar del del motor.

### E-73 · `bcp in` con la caja entrecomillada

**Motor y versión:** SQL Server 2025 CU9, `bcp` de `mssql-tools18` · **Apareció en:** [ss01](ss01-la-base-en-su-motor-original.md) (`01_bcp_in.sh`)

```text
SQLState = 22001, NativeError = 0
Error = [Microsoft][ODBC Driver 18 for SQL Server]String data, right truncation
#@ Row 1, Column 1: String data, right truncation @#
"C"	"Laboratorio Central"	"RIVADAVIA 521"	"1996-03-01 00:00:00.000"
SQLState = 22008, NativeError = 0
Error = [Microsoft][ODBC Driver 18 for SQL Server]Invalid date format
```

- **Qué lo provocó:** `bcp … in -c -t,` sobre un CSV con los textos entre comillas. En modo texto, `bcp` separa por la coma y deja las comillas como parte del dato: `"C"` son tres caracteres para un `nvarchar(1)`, y una fecha entre comillas no es una fecha.
- **Cómo se confirma:** el archivo de `-e` muestra cada campo con sus comillas.
- **Cómo se sale:** no se usa `bcp in` con un CSV entrecomillado. `BULK INSERT … FORMAT = 'CSV'` o la copia masiva desde el cliente (`lab load --engine sqlserver`).

### E-74 · `CODEPAGE` en SQL Server para Linux

**Motor y versión:** SQL Server 2025 CU9 en Linux · **Apareció en:** [ss01](ss01-la-base-en-su-motor-original.md) (`02_bulk_insert.sql`)

```text
Msg 16202, Level 15, State 3, Server a07be756749e, Line 3
Keyword or statement option 'CODEPAGE' is not supported on the 'Linux' platform.
```

- **Qué lo provocó:** `BULK INSERT … WITH (CODEPAGE = '65001')`, que en Windows dice que el archivo es UTF-8. La documentación de `BULK INSERT` dice que en Linux la opción no se admite (en 2019, solo `'RAW'`).
- **Cómo se confirma:** `SELECT @@VERSION` termina en `on Linux`.
- **Cómo se sale:** quitar la opción. En Linux, `BULK INSERT` lee el archivo como UTF-8.

### E-75 · Un CSV en Latin-1 en `BULK INSERT`

**Motor y versión:** SQL Server 2025 CU9 en Linux · **Apareció en:** [ss01](ss01-la-base-en-su-motor-original.md) (`02_bulk_insert.sql`, `Pacientes`)

```text
Msg 4879, Level 16, State 1, Server a07be756749e, Line 2
Bulk load failed due to invalid column value in CSV data file /caja/m/tablas/Pacientes.csv in row 6, column 5.
Msg 7399, Level 16, State 1, Server a07be756749e, Line 2
The OLE DB provider "BULK" for linked server "(null)" reported an error. The provider did not give any information about the error.
Msg 7330, Level 16, State 2, Server a07be756749e, Line 2
Cannot fetch a row from OLE DB provider "BULK" for linked server "(null)".
```

- **Qué lo provocó:** la eñe de `43 años`, un byte de Latin-1 que no es UTF-8 válido, en un servidor que solo lee UTF-8 y no acepta `CODEPAGE` (E-74).
- **Cómo se confirma:** `iconv -f utf-8 -t utf-8 Pacientes.csv > /dev/null` falla en el mismo lugar.
- **Cómo se sale:** convertir el archivo con `iconv -f latin1 -t utf-8` antes de cargarlo, o cargar desde el cliente, que decodifica.

### E-76 · El driver `mssql-python` no carga en Debian

**Motor y versión:** `mssql-python` 1.15.0, Python 3.13 en `debian trixie-slim` (`arm64`) · **Apareció en:** [ss01](ss01-la-base-en-su-motor-original.md) (la primera carga)

```text
mssql_python.exceptions.OperationalError: Driver Error: Connection operation failed; DDBC Error: Failed to load the driver. Please read the documentation (https://github.com/microsoft/mssql-python#installation) to install the required dependencies.
```

- **Qué lo provocó:** la *wheel* trae el ODBC Driver 18 de Microsoft (`mssql_python_odbc/libs/linux/debian_ubuntu/…/libmsodbcsql-18.6.so.2.1`), pero no tres bibliotecas del sistema de las que depende.
- **Cómo se confirma:** `ldd` sobre esa biblioteca dice `not found` para `libltdl.so.7`, `libkrb5.so.3` y `libgssapi_krb5.so.2`.
- **Cómo se sale:** `apt-get install libltdl7 libkrb5-3 libgssapi-krb5-2`.

### E-77 · Un agregado sobre una subconsulta en T-SQL

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss01](ss01-la-base-en-su-motor-original.md) (`03_esquema.sql`, primera versión)

```text
Msg 130, Level 15, State 1, Server a07be756749e, Line 8
Cannot perform an aggregate function on an expression containing an aggregate or a subquery.
```

- **Qué lo provocó:** `SUM(CASE WHEN EXISTS (SELECT …) THEN 1 ELSE 0 END)`, que Postgres acepta. T-SQL no admite una subconsulta dentro de la expresión de un agregado.
- **Cómo se sale:** una subconsulta escalar por columna, o un `CROSS APPLY` que calcule el `EXISTS` antes de agregar.

### E-78 · Una fecha `aaaa-mm-dd` en `datetime`, según el idioma de la sesión

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss01](ss01-la-base-en-su-motor-original.md) (`06_ventana.sql`)

```text
Msg 242, Level 16, State 3, Server a07be756749e, Line 3
The conversion of a varchar data type to a datetime data type resulted in an out-of-range value.
Msg 242, Level 16, State 3, Server a07be756749e, Line 2
La conversión del tipo de datos varchar en datetime produjo un valor fuera de intervalo.
```

- **Qué lo provocó:** el primero, `CAST('15/03/2026' AS datetime)` con la sesión en `us_english` (orden `mdy`: no hay mes 15). El segundo, `CAST('1968-06-17 00:00:00.000' AS datetime)` con la sesión en español (orden `dmy`, que lee una cadena que empieza por el año como año, día, mes: no hay mes 17). Con un día del 1 al 12 no hay error, y la fecha se da vuelta.
- **Cómo se confirma:** `SELECT @@LANGUAGE` y `SELECT dateformat FROM sys.syslanguages WHERE name = @@LANGUAGE`.
- **Cómo se sale:** `CONVERT(datetime, texto, 121)` con el estilo explícito, `datetime2` o `date` (que leen `aaaa-mm-dd` igual con cualquier idioma), o ISO 8601 con la `T`.

### E-79 · La víctima de un *deadlock* en SQL Server

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss02](ss02-pesimista-contra-rcsi.md) (`deadlock.race`, `write_skew.race --isolation serializable`, `lost_update.race --isolation repeatable-read`)

```text
1205 Transaction (Process ID 76) was deadlocked on lock resources with another process and has been chosen as the deadlock victim. Rerun the transaction.
```

- **Qué lo provocó:** dos transacciones que piden las mismas filas en orden contrario, o dos lecturas que retienen bloqueos compartidos (`REPEATABLE READ`, o `RangeS-S` en `SERIALIZABLE`) y después quieren escribir lo mismo.
- **Cómo se confirma:** el número de proceso es el `@@SPID` de la víctima; el grafo queda en la sesión `system_health` de *Extended Events*.
- **Cómo se sale:** reintentar la transacción entera. El motor ya la deshizo: ver E-80.

### E-80 · El `COMMIT` después de ser víctima

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss02](ss02-pesimista-contra-rcsi.md) (`write_skew.race --isolation serializable`)

```text
3902 The COMMIT TRANSACTION request has no corresponding BEGIN TRANSACTION.
```

- **Qué lo provocó:** mandar el `COMMIT` de la transacción que el 1205 ya deshizo. La sesión quedó sin transacción, y lo que siga corre en *autocommit*.
- **Cómo se confirma:** `SELECT @@TRANCOUNT` da 0.
- **Cómo se sale:** `IF @@TRANCOUNT > 0 COMMIT`, o mirar `XACT_STATE()` después de cada error; `SET XACT_ABORT ON` en el código nuevo.

### E-81 · Conflicto de actualización en `SNAPSHOT`

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss02](ss02-pesimista-contra-rcsi.md) (`lost_update.race --isolation snapshot`)

```text
3960 Snapshot isolation transaction aborted due to update conflict. You cannot use snapshot isolation to access table 'dbo.debtor' directly or indirectly in database 'ss02' to update, delete, or insert the row that has been modified or deleted by another transaction. Retry the transaction or change the isolation level for the update/delete statement.
```

- **Qué lo provocó:** una transacción `SNAPSHOT` que modifica una fila que otra cambió y confirmó después de su foto. La detección no se puede apagar.
- **Cómo se sale:** reintentar la transacción. Es el `40001` del `REPEATABLE READ` de Postgres.

### E-82 · `SNAPSHOT` en una base que no lo permite

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss02](ss02-pesimista-contra-rcsi.md) (ejercicio 7)

```text
Msg 3952, Level 16, State 1, Server a07be756749e, Line 1
Snapshot isolation transaction failed accessing database 'ss02_sin_snapshot' because snapshot isolation is not allowed in this database. Use ALTER DATABASE to allow snapshot isolation.
```

- **Qué lo provocó:** `SET TRANSACTION ISOLATION LEVEL SNAPSHOT` en una base sin `ALLOW_SNAPSHOT_ISOLATION ON`, que es como viene toda base nueva.
- **Cómo se sale:** `ALTER DATABASE … SET ALLOW_SNAPSHOT_ISOLATION ON` (`src/ss02-pesimista-contra-rcsi/02_snapshot.sql`).

### E-83 · Una violación de `UNIQUE` en T-SQL

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss02](ss02-pesimista-contra-rcsi.md) (ejercicio 13)

```text
Violation of UNIQUE KEY constraint 'specimen_take_once'. Cannot insert duplicate key in object 'dbo.specimen_take'. The duplicate key value is (11231555).
```

- **Qué lo provocó:** la segunda toma de la misma muestra, con la restricción de la Fase 15. Es el Msg 2627, el `23505` de Postgres.
- **Cómo se sale:** no se sale: es la respuesta correcta. La aplicación la atrapa y le ofrece al técnico la muestra siguiente.

### E-84 · División por cero dentro de una transacción

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss02](ss02-pesimista-contra-rcsi.md) (ejercicio 21)

```text
Divide by zero error encountered.
```

- **Qué lo provocó:** el Msg 8134, en el segundo de tres `UPDATE` de una transacción.
- **Cómo se confirma qué quedó:** con `SET XACT_ABORT OFF` (el de fábrica) la transacción sigue abierta (`@@TRANCOUNT` 1) y solo se deshizo esa sentencia; con `ON`, la transacción se deshizo entera (`@@TRANCOUNT` 0) y lo que siga corre en *autocommit*.
- **Cómo se sale:** `SET XACT_ABORT ON` y `XACT_STATE()`, o `TRY…CATCH` con `ROLLBACK` explícito.

### E-85 · Un *hint* de índice sobre un índice que no existe

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss03](ss03-query-store-y-parameter-sniffing.md) (`05_roturas.sql`)

```text
Msg 308, Level 16, State 1, Server a07be756749e, Line 1
Index 'protocol_hint_fecha_idx' on table 'dbo.protocol_hint' (specified in the FROM clause) does not exist.
```

- **Qué lo provocó:** `WITH (INDEX (protocol_hint_fecha_idx))` después de borrar ese índice. La consulta falla: no hay plan alternativo.
- **Cómo se sale:** quitar el *hint* (y buscar `WITH (INDEX` en todo el código que manda SQL). Es el `ERROR 1176` de `FORCE INDEX` en MySQL (Fase 13).

### E-86 · Un plan forzado que Query Store no puede aplicar

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss03](ss03-query-store-y-parameter-sniffing.md) (`05_roturas.sql`)

```text
plan_id is_forced_plan force_failure_count last_force_failure_reason_desc
1       1              1                   NO_INDEX
```

- **Qué lo provocó:** forzar con `sp_query_store_force_plan` un plan que usa `IX_ResultadoItem_IdProtocolo`, y borrar ese índice. No hay mensaje de error: la consulta corre con el plan que elige el optimizador, y el fallo queda en `sys.query_store_plan`.
- **Cómo se confirma:** `SELECT plan_id, force_failure_count, last_force_failure_reason_desc FROM sys.query_store_plan WHERE is_forced_plan = 1`.
- **Cómo se sale:** `sp_query_store_unforce_plan`, y una alerta sobre `force_failure_count > 0`. Es el aviso 3128 del *optimizer hint* de MySQL (Fase 13), sin aviso.

### E-87 · `QUOTED_IDENTIFIER` apagado en `sqlcmd`

**Motor y versión:** SQL Server 2025 CU9, `sqlcmd` de `mssql-tools18` · **Apareció en:** [ss03](ss03-query-store-y-parameter-sniffing.md) (`06_psp.sql`, primera versión)

```text
Msg 1934, Level 16, State 1, Server a07be756749e, Line 2
SELECT failed because the following SET options have incorrect settings: 'QUOTED_IDENTIFIER'. Verify that SET options are correct for use with indexed views and/or indexes on computed columns and/or filtered indexes and/or query notifications and/or XML data type methods and/or spatial index operations.
```

- **Qué lo provocó:** usar los métodos del tipo `xml` (`.value`, `.nodes`) desde `sqlcmd`, que abre la sesión con `QUOTED_IDENTIFIER` apagado salvo que se le pase `-I`.
- **Cómo se sale:** `SET QUOTED_IDENTIFIER ON;` al principio del lote, o `sqlcmd -I`. Es la razón por la que el script de SSMS de la caja fija la opción antes de cada `CREATE TABLE`.

### E-88 · `NEWSEQUENTIALID()` fuera de un `DEFAULT`

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss04](ss04-clustered-newsequentialid-y-temporales.md) (`02_reinicio.sql`, ejercicio 3)

```text
Msg 302, Level 16, State 1, Server a07be756749e, Line 2
The newsequentialid() built-in function can only be used in a DEFAULT expression for a column of type 'uniqueidentifier' in a CREATE TABLE or ALTER TABLE statement. It cannot be combined with other operators to form a complex scalar expression.
Msg 1750, Level 16, State 1, Server a07be756749e, Line 1
Could not create constraint or index. See previous errors.
```

- **Qué lo provocó:** el primero, `SELECT NEWSEQUENTIALID()`; el segundo, un `DEFAULT CONVERT(nvarchar(36), NEWSEQUENTIALID())`. La función solo existe como `DEFAULT` de una columna `uniqueidentifier`.
- **Cómo se sale:** el `DEFAULT` en la columna y `OUTPUT inserted.<columna>` para que la aplicación conozca el valor.

### E-89 · El período de una tabla temporal, a mano

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss04](ss04-clustered-newsequentialid-y-temporales.md) (`04_temporales_roturas.sql`)

```text
Msg 13536, Level 16, State 1, Server a07be756749e, Line 2
Cannot insert an explicit value into a GENERATED ALWAYS column in table 'ss04.dbo.resultado'. Use INSERT with a column list to exclude the GENERATED ALWAYS column, or insert a DEFAULT into GENERATED ALWAYS column.
```

- **Qué lo provocó:** insertar un resultado de 2019 con `ValidoDesde` y `ValidoHasta`. El período lo pone el motor, con la hora de la transacción.
- **Cómo se sale:** para traer la historia de antes del versionado, `SET (SYSTEM_VERSIONING = OFF)`, insertar en la tabla de historia y volver a encenderlo (E-93, E-94).

### E-90 · Una tabla de historia, corregida a mano

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss04](ss04-clustered-newsequentialid-y-temporales.md) (`03_temporales.sql`)

```text
Msg 13561, Level 16, State 1, Server a07be756749e, Line 2
Cannot update rows in a temporal history table 'ss04.dbo.resultado_historia'.
```

- **Qué lo provocó:** un `UPDATE` sobre `dbo.resultado_historia` con el versionado encendido.
- **Cómo se sale:** no se sale con el versionado encendido, que es lo que se quiere de una auditoría.

### E-91 · `TRUNCATE` sobre una tabla temporal

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss04](ss04-clustered-newsequentialid-y-temporales.md) (`03_temporales.sql`)

```text
Msg 13545, Level 16, State 1, Server a07be756749e, Line 1
Truncate failed on table 'ss04.dbo.resultado' because it is not a supported operation on system-versioned tables.
```

- **Cómo se sale:** `ALTER TABLE … SET (SYSTEM_VERSIONING = OFF)` primero. Un `DELETE` sí se puede, y guarda cada fila borrada en la historia.

### E-92 · `DROP TABLE` sobre una tabla temporal

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss04](ss04-clustered-newsequentialid-y-temporales.md) (`04_temporales_roturas.sql`)

```text
Msg 13552, Level 16, State 1, Server a07be756749e, Line 2
Drop table operation failed on table 'ss04.dbo.resultado' because it is not a supported operation on system-versioned temporal tables.
```

- **Cómo se sale:** apagar el versionado y borrar las dos tablas, la actual y la de historia, que quedan como tablas comunes.

### E-93 · Volver a encender el versionado con una historia inválida

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss04](ss04-clustered-newsequentialid-y-temporales.md) (ejercicio 9)

```text
Msg 13543, Level 16, State 1, Server a07be756749e, Line 1
Setting SYSTEM_VERSIONING to ON failed because history table 'ss04.dbo.resultado_historia' contains invalid records with end of period set to a value in the future.
```

- **Qué lo provocó:** una versión traída a mano a la historia con un fin de período en 2030, con `DATA_CONSISTENCY_CHECK = ON`.
- **Cómo se sale:** cerrar el período de cada versión histórica antes del inicio de la versión siguiente (y de la actual).

### E-94 · Insertar en la historia en el mismo lote que apaga el versionado

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss04](ss04-clustered-newsequentialid-y-temporales.md) (ejercicio 9, primera versión)

```text
Msg 13559, Level 16, State 1, Server a07be756749e, Line 3
Cannot insert rows in a temporal history table 'ss04.dbo.resultado_historia'.
```

- **Qué lo provocó:** `ALTER TABLE … SET (SYSTEM_VERSIONING = OFF)` y el `INSERT` en la historia en el mismo lote: el lote se compila con el versionado todavía encendido, y no corre ninguna de las dos sentencias.
- **Cómo se sale:** un `GO` entre el `ALTER` y el `INSERT`.

### E-95 · DAB rechaza el pedido por el rol

**Motor y versión:** Data API builder 2.1.5 · **Apareció en:** [ss05](ss05-data-api-builder-y-json.md) (`03_api.py`, líneas 1 y 5)

```text
HTTP 403 · Authorization Failure: Access Not Allowed.
```

- **Qué lo provocó:** un pedido evaluado con un rol sin permisos sobre la entidad: `Anonymous` (sin identidad) o `Authenticated` (identidad sin `X-MS-API-ROLE`).
- **Cómo se confirma:** el registro de DAB dice `Authorization failed. Fail() was explicitly called.`
- **Cómo se sale:** el encabezado `X-MS-API-ROLE` con un rol que esté entre los *claims* `roles` y en los permisos de la entidad.

### E-96 · Un documento inválido en el tipo `json`

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss05](ss05-data-api-builder-y-json.md) (`04_json.sql`, ejercicio 5)

```text
Msg 13609, Level 16, State 9, Server a07be756749e, Line 2
JSON text is not properly formatted. Unexpected character '}' is found at position 18.
```

- **Qué lo provocó:** un documento con una coma de más. Con una comilla simple o una clave sin comillas, el mismo mensaje con otro carácter y otra posición.
- **Cómo se sale:** validar antes con `ISJSON(texto, OBJECT)`, sobre todo al convertir una columna `nvarchar(max)` a `json`.

### E-97 · Un índice JSON sin clave agrupada

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss05](ss05-data-api-builder-y-json.md) (sección 12)

```text
Msg 13672, Level 16, State 1, Server a07be756749e, Line 1
Table 'staging.doc_heap' needs to have a clustered primary key with less than 32 columns in it in order to create a JSON index on it.
```

- **Cómo se sale:** una clave primaria agrupada en la tabla antes de `CREATE JSON INDEX`.

### E-98 · El contenedor de SQL Server muere por memoria

**Motor y versión:** SQL Server 2025 CU9 (`amd64`) emulado en Docker Desktop sobre Apple Silicon · **Apareció en:** [ss05](ss05-data-api-builder-y-json.md) (los ejercicios sobre los 12,7 millones de resultados)

```text
$ docker inspect alameda-lab-sqlserver-1 --format '{{.State.OOMKilled}} {{.State.ExitCode}}'
true 137
```

- **Qué lo provocó:** consultas que recorren entera `alameda.result` (12.710.308 filas), repetidas varias veces. En la verificación murió con `mem_limit` de 2, 3 y 4 GB, y también con `max server memory` en 1.024 MB: la memoria que crece no es la del *buffer pool*, que `sys.dm_os_memory_clerks` mostraba chica. La causa no se aisló, y no se probó en un `x86_64` sin emulación.
- **Cómo se confirma:** el contenedor sale con código 137 y `OOMKilled=true`; el registro de SQL Server no dice nada.
- **Cómo se sale:** no se encontró una configuración que lo evite. Las consultas del track van por índice; un recorrido entero de una tabla de millones de filas, de a uno. Después de cada muerte, reiniciar también DAB (E-99).

### E-99 · DAB no se reconecta después de recrear SQL Server

**Motor y versión:** Data API builder 2.1.5 · **Apareció en:** [ss05](ss05-data-api-builder-y-json.md) (después de E-98)

```text
HTTP 500 · A network-related or instance-specific error occurred while establishing a connection to SQL Server. The server was not found or was not accessible. … (provider: TCP Provider, error: 35 - An internal exception was caught)
Error Number:11001,State:0,Class:20
```

- **Qué lo provocó:** el contenedor `sqlserver` se recreó (o se reinició) con DAB arriba, y DAB no volvió a resolver el nombre. Si DAB arranca mientras el motor no está, termina con `Unable to launch the Data API builder engine`.
- **Cómo se sale:** `docker compose --profile dab up -d --force-recreate --wait dab`, con SQL Server ya *healthy*.

### E-100 · Cambiar un valor de solo lectura en `SESSION_CONTEXT`

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss05](ss05-data-api-builder-y-json.md) (ejercicio 7)

```text
Msg 15664, Level 16, State 1, Server a07be756749e, Procedure sp_set_session_context, Line 1
Cannot set key 'patient_id' in the session context. The key has been set as read_only for this session.
```

- **Qué lo provocó:** `sp_set_session_context` sobre una clave fijada antes con `@read_only = 1`. Es lo que se quiere: DAB fija los suyos con `@read_only = 0`.

### E-101 · Un predicado de bloqueo de la seguridad por fila

**Motor y versión:** SQL Server 2025 CU9 · **Apareció en:** [ss05](ss05-data-api-builder-y-json.md) (ejercicio 16)

```text
Msg 33504, Level 16, State 1, Server a07be756749e, Line 6
The attempted operation failed because the target object 'ss05.alameda.result_nuevo' has a block predicate that conflicts with this operation. If the operation is performed on a view, the block predicate might be enforced on the underlying table. Modify the operation to target only the rows that are allowed by the block predicate.
```

- **Qué lo provocó:** un médico que inserta un resultado en un protocolo que no derivó, con `BLOCK PREDICATE … AFTER INSERT`. Es el `new row violates row-level security policy` de Postgres (Fase 23, E-65).

### E-102 · `lab race` declara imposible un *deadlock* de SQL Server

**Motor y versión:** SQL Server 2025 CU9 con `mssql-python` 1.15.0 · **Apareció en:** [ss02](ss02-pesimista-contra-rcsi.md) (`write_skew.race --isolation serializable`), 18/10/2026, al preparar los ejercicios de este apéndice

```text
 a3  ⏳ espera un bloqueo
 b3  ⏳ espera un bloqueo
 a4  ✗ imposible a4 le toca a a, que espera un bloqueo desde a3: el motor no deja ocurrir este orden
   ↳ a3  ✗ ? Driver Error: General error; DDBC Error: [Microsoft]Unspecified error occurred on SQL Server. Connection may have been terminated by the server.
   ↳ b3  ✗ ? Driver Error: General error; DDBC Error: [Microsoft]Unspecified error occurred on SQL Server. Connection may have been terminated by the server.
```

- **Qué lo provocó:** las dos sesiones se bloquean una a la otra, que es un *deadlock*, pero SQL Server no lo detectó antes de que venciera la paciencia del arnés (`--patience`, 3 s por defecto). El monitor de bloqueos de SQL Server busca ciclos cada pocos segundos, y con la emulación de Docker Desktop tardó más. El arnés declaró el orden imposible y canceló las dos sesiones con `KILL`, y el driver informa la conexión cortada.
- **Cómo se confirma:** el mismo escenario con `--patience 10` termina en un 1205 (E-79) para una de las dos y un 3902 (E-80) en su `COMMIT`. En la misma tarde, otra corrida con la paciencia de fábrica también dio el 1205: depende de cuánto tarda el monitor esa vez. **La víctima cambia de corrida en corrida** (una vez `a`, otra `b`): el orden de los pasos es fijo, la elección de SQL Server no.
- **Cómo se sale:** `--patience 10` en los escenarios de SQL Server que terminan en *deadlock*. Lo que no cambia es el resultado que importa: una sola toma de la muestra.

---

## 🧪 Ejercicios (10)

Cada ejercicio provoca un error a propósito, en el laboratorio y sin tocar nada que no se deshaga:
transacciones que terminan en `ROLLBACK`, tablas de prueba en `lab` que se borran al terminar. Antes de
correrlo, **predice el mensaje**; después, encuentra su entrada en este catálogo por el mensaje, no por el
número. Todos desde `src/lab/` o desde `src/`, con el perfil M cargado.

## 🟢 Fácil — un error, una línea (1–3)

### 🟢 Ejercicio 1 — La tabla que no aparece

En `psql`, lista las tablas de `legacy` que empiezan con `Pac` escribiendo `\dt legacy.Pac*`.

**Objetivo:** el mensaje, la entrada que lo explica y el patrón que sí funciona.

[Solución](soluciones/a08-catalogo-de-errores.md#ejercicio-1)

### 🟢 Ejercicio 2 — El DNI con puntos

En Postgres, convierte a `numeric` el DNI del paciente 2.

**Objetivo:** el mensaje literal, qué valor lo provocó, y la función de la [Fase 08](08-los-dos-extremos-del-mismo-error.md) que lo
habría evitado.

[Solución](soluciones/a08-catalogo-de-errores.md#ejercicio-2)

### 🟢 Ejercicio 3 — La consulta de Postgres en MySQL

En MySQL, con `USE legacy`, busca los pacientes cuyo nombre se parece a `RAMIREZ NELIDA` con
`similarity(Nombre, 'RAMIREZ NELIDA') > 0.5`.

**Pregunta:** ¿qué dice el mensaje, por qué nombra `legacy.similarity`, y qué pasa si no haces `USE`?

[Solución](soluciones/a08-catalogo-de-errores.md#ejercicio-3)

## 🟡 Intermedio — el modelo que dice que no (4–6)

### 🟡 Ejercicio 4 — El identificador que trae la migración

En una transacción que termines con `ROLLBACK`, crea una tabla con `id integer GENERATED ALWAYS AS IDENTITY`
e inserta una fila con `id = 1`.

**Objetivo:** las tres líneas del mensaje (`ERROR`, `DETAIL`, `HINT`) y cuándo es correcto hacer lo que
dice el `HINT`.

[Solución](soluciones/a08-catalogo-de-errores.md#ejercicio-4)

### 🟡 Ejercicio 5 — El DNI único

En una transacción que termines con `ROLLBACK`, crea un índice único sobre `legacy."Pacientes"("DNI")`.

**Pregunta:** ¿qué DNI nombra el mensaje, es siempre el mismo, y qué línea del mensaje dice que lo
encontró un proceso en paralelo?

[Solución](soluciones/a08-catalogo-de-errores.md#ejercicio-5)

### 🟡 Ejercicio 6 — El índice sobre la nota

En MySQL, crea `lab.a08_nota (id int PRIMARY KEY, note text)` y un índice sobre `note`. Borra la tabla al
terminar.

**Objetivo:** el mensaje, la sentencia que sí crea un índice, y qué pierde ese índice frente al de
Postgres sobre la misma columna.

[Solución](soluciones/a08-catalogo-de-errores.md#ejercicio-6)

## 🟠 Difícil — dos sesiones (7–8)

### 🟠 Ejercicio 7 — Esperar con límite

Escribe un `.race` en el que la sesión `a` toma con `FOR UPDATE` el deudor 1 de `staging.debtor`
([Fase 15](15-aislamiento-comparado.md)) y la `b`, con `SET LOCAL lock_timeout = '1s'`, quiere
actualizarlo. Elige la permutación para que `a` no confirme antes de que venza el límite.

**Objetivo:** el `.race`, la salida de `lab race` con el código del error, y la permutación que **no**
lo provoca, con por qué.

[Solución](soluciones/a08-catalogo-de-errores.md#ejercicio-7)

### 🟠 Ejercicio 8 — La obra social vacía

En Oracle, crea una tabla de prueba con `obra_social VARCHAR2(60) NOT NULL` e inserta una fila con `''` y
otra con `' '`. Bórrala al terminar.

**Pregunta:** ¿cuál entra y cuál no, con qué mensaje, y qué haría Postgres con las mismas dos?

[Solución](soluciones/a08-catalogo-de-errores.md#ejercicio-8)

## 🔴 Muy difícil — el mismo error con tres nombres (9–10)

### 🔴 Ejercicio 9 — Dos `40001`

Corre `15-aislamiento-comparado/lost_update.race` en `REPEATABLE READ` y `write_skew.race` en
`SERIALIZABLE`, en Postgres. Los dos terminan en `40001`.

**Objetivo:** las dos salidas, la parte del mensaje que distingue un error del otro, la entrada de cada
uno y por qué la aplicación los trata igual aunque las causas sean distintas.

[Solución](soluciones/a08-catalogo-de-errores.md#ejercicio-9)

### 🔴 Ejercicio 10 — La muestra tomada dos veces, en tres motores

Corre el *write skew* en `SERIALIZABLE` en los tres motores que lo tienen: Postgres
(`15-aislamiento-comparado/write_skew.race`), MySQL (`write_skew_mysql.race`) y, si hiciste el track,
SQL Server (`ss02-pesimista-contra-rcsi/write_skew.race`, con `--patience 10`).

**Objetivo:** el error de cada uno, en qué paso aparece (lectura, escritura o confirmación), cuántas
tomas quedaron, y una política de reintento que sirva para los tres.

[Solución](soluciones/a08-catalogo-de-errores.md#ejercicio-10)

---

> 🏷️ **Este apéndice no lleva tag propio.** Crece con los commits de las fases que le agregan
> entradas.
