# 🧪 ruta-sql-20261011-2b0e · cómo correr estas pruebas

> **Curso:** ruta-sql · **Tanda:** P8, P9 y P11 · **Creado:** 2026-10-11
> **Propósito:** verificación de laboratorio de la Ruta SQL: versiones, digests, RAM, emulación, drivers, prototipo del generador y funciones de Postgres; fuentes de P9
> Se llena **mientras se prueba**: cada script nuevo entra aquí en la misma sesión. Las reglas, en
> `zz-code/README.md` § "El README de cada directorio". Si una sección no aplica, se dice por qué.

Todo se lanza **desde este directorio** (`zz-code/ruta-sql-20261011-2b0e/`), salvo que se diga otra
cosa. Lo que se encontró está en `cursos-bd/ruta-sql/prompts/verificacion-de-laboratorio/hallazgos.md`;
este README dice cómo se llegó a cada cifra.

## 1. 🎯 Qué se prueba y para qué

| Archivo | Qué prueba | Hallazgo que alimenta | Apéndice o fase |
|---|---|---|---|
| `comandos-versiones.sh`, `tags.sh` | los tags más recientes de cada imagen (D12) | H1 | `a02` |
| `comandos-pull.sh`, `imagenes.txt` | descarga, arquitectura, tamaño y digest | tabla de digests | `a02` |
| `lab/compose.yaml` | el laboratorio de prueba (no es el del curso, que escribe T1) | H2–H5, H8, H9 | `a01`, `a02` |
| `lab/medir-arranque.sh` | tiempo hasta *healthy* y RAM en reposo de un servicio | tabla de resultados | `a02` |
| `lab/esperar-artemis.sh` | tiempo hasta `AMQ221007` (Artemis no tiene *healthcheck*) | H9 | T11 |
| `lab/medir-ram-cargado.sh`, `lab/medir-todo.sh` | RAM con M cargado, los tres motores y todos los perfiles | tabla de RAM | `a02` |
| `generador/generar.py`, `generador/proporciones.py`, `comandos-generador.sh` | el prototipo del generador, su determinismo y sus proporciones | H12 | `a05` |
| `carga/cargar.sh` y `carga/*.sql` | la carga de la caja en Postgres, MySQL y Oracle | H6, H7, H12 | `a05` |
| `funciones/postgres-18.sql`, `funciones/skip-scan-y-hint-plan.sh` | las funciones de Postgres 18 que dan por supuestas las fases | H10 | F07, F10, F11, F13, F22 |
| `funciones/oracle-26ai.sql` | lo que el curso usa de Oracle en la imagen `slim` | H3 | `a02`, F19 |
| `funciones/sqlserver-2025.sql` | lo que usa el track en SQL Server 2025 | H4 | `ss01`–`ss05` |
| `comandos-podman.sh`, `podman-rosetta.conf` | SQL Server en Podman, con `libkrun` y con `applehv` + Rosetta | H4 | `a01`, track |
| `drivers/prueba.py`, `drivers/correr.sh` | *autocommit*, transacciones y `LOAD DATA LOCAL` en los cuatro drivers | H11 | `a06` |
| `java/Hola.java` | Java 25 ejecuta un archivo suelto | H13 | `a06` |
| `comandos-p9-urls.sh`, `texto-de-html.py` | las URL de las fuentes y el texto de las licencias | F1, F2 | guía §11, `a09` |
| `p11/reemplazar.py` y `p11/*.py` | el traslado a `prompts/`: reemplazos exactos que fallan si el texto no está | — | P11 |
| `comandos-inventario.sh`, `comandos-limpieza.sh` | el inventario de Docker y la limpieza contra él | — | — |

## 2. 🛠️ Prerrequisitos

- macOS arm64 con **Docker Desktop** (motor 29.8.0, VM de 7,75 GiB y 8 CPU, kernel `7.0.12-linuxkit`)
  y la integración de Rosetta activa (la trae por defecto con *Virtualization framework*).
- **Podman 6.1.3**, solo para `comandos-podman.sh`; la prueba crea su propia máquina y la borra.
- `curl`, `python3` (cualquier 3.x, solo para los scripts de consulta) y `pdftotext` (Poppler) para la
  licencia de SQL Server.
- Las imágenes de `imagenes.txt`. Nada de Python se instala en la máquina: el generador, las
  proporciones y los drivers corren en `ghcr.io/astral-sh/uv:0.11.14-python3.13-trixie-slim`, y `uv`
  resuelve psycopg, PyMySQL, mysql-connector-python y oracledb en el contenedor (caché en
  `salidas/uv-cache/`).
- **Estado previo:** ninguno. Los contenedores de otros cursos pueden estar arriba y comparten la VM:
  la RAM por contenedor no cambia, pero dos Oracle a la vez con otros cursos llenan la VM (H3).

## 3. 🧭 Reglas antes de correr

```bash
./comandos-inventario.sh antes          # contenedores, volúmenes, redes e imágenes → salidas/inventario-antes.txt
```

- Todo lo que crea la sesión lleva la etiqueta **`curso=ruta-sql`** (contenedores, volúmenes y red del
  proyecto de Compose `ruta-sql-p8`, y los `docker run --rm`).
- **Puertos aleatorios en `127.0.0.1`** (`127.0.0.1::5432`): Docker elige el puerto; nunca los de por
  defecto. `docker compose -f lab/compose.yaml port <servicio> <puerto>` dice cuál tocó.
- **Cambios temporales en la máquina:** la máquina de Podman `ruta-sql-p8` (se crea y se borra en la
  prueba). Rosetta se activa con `CONTAINERS_CONF_OVERRIDE` apuntando a `podman-rosetta.conf`: el
  `containers.conf` del usuario no se toca. `podman machine init` deja la imagen de la VM en
  `~/.local/share/containers/podman/machine/<proveedor>/cache/` (unos 900 MB); la de `applehv` la creó
  esta sesión y se borró con `rm -rf ~/.local/share/containers/podman/machine/applehv`. La de
  `libkrun` ya existía (3/10/2026) y no se tocó.

## 4. ▶️ Cómo se corre

En el orden en que se corrió el 11/10/2026:

```bash
./comandos-versiones.sh                 # → salidas/tags-AAAAMMDD.txt
./comandos-pull.sh                      # lee imagenes.txt → salidas/pull.tsv (imagen, arquitectura, bytes, digest, segundos)

./comandos-generador.sh s               # → salidas/caja/s/  (imprime conteos, segundos y SHA-256)
./comandos-generador.sh s salidas/caja-bis   # segunda corrida: el SHA-256 tiene que coincidir; después rm -rf salidas/caja-bis
./comandos-generador.sh m               # → salidas/caja/m/  (unos 70 s)
docker run --rm --label curso=ruta-sql -v "$PWD":/w -w /w ghcr.io/astral-sh/uv:0.11.14-python3.13-trixie-slim \
  python generador/proporciones.py salidas/caja/m      # → proporciones contra la historia

lab/medir-arranque.sh base postgres 60  # perfil, servicio, segundos de espera → salidas/arranque-darwin-arm64.tsv
lab/medir-arranque.sh contraste mysql 60
lab/medir-arranque.sh oracle oracle 60
carga/cargar.sh postgres m              # → salidas/carga-postgres-m.log
carga/cargar.sh mysql m
carga/cargar.sh oracle m                # tiempos privados: no salen de salidas/
lab/medir-ram-cargado.sh                # → salidas/ram-cargado-darwin-arm64.tsv
lab/medir-arranque.sh mongo mongo 30    # 9.0.2: no arranca (H2)
MONGO_IMAGE=mongo:8.0.20 lab/medir-arranque.sh mongo mongo 30
lab/medir-arranque.sh "base --profile api" api 20
lab/medir-arranque.sh puente broker 30 && lab/esperar-artemis.sh
docker compose -f lab/compose.yaml --profile base exec -T postgres psql -U postgres -d alameda -f - < funciones/postgres-18.sql
funciones/skip-scan-y-hint-plan.sh
lab/medir-arranque.sh oracle-oficial oracle-oficial 60
docker exec -i ruta-sql-p8-oracle-1 sqlplus -s alameda/lab@//localhost/FREEPDB1 < funciones/oracle-26ai.sql
lab/medir-arranque.sh sqlserver sqlserver 60
docker exec -i ruta-sql-p8-sqlserver-1 /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P 'Lab-2026-pass' -W -s '|' < funciones/sqlserver-2025.sql

./comandos-podman.sh crear && ./comandos-podman.sh probar && ./comandos-podman.sh borrar          # libkrun (QEMU)
PROVIDER=applehv ROSETTA=1 ./comandos-podman.sh crear && PROVIDER=applehv ROSETTA=1 ./comandos-podman.sh probar
PROVIDER=applehv ./comandos-podman.sh borrar

MYSQL_LOCAL_INFILE=1 docker compose -f lab/compose.yaml --profile base --profile contraste --profile oracle up -d --wait postgres mysql oracle
drivers/correr.sh                       # → salidas/drivers.log
lab/medir-todo.sh                       # todos los perfiles a la vez
docker run --rm --label curso=ruta-sql -v "$PWD/java":/j -w /j eclipse-temurin:25.0.4.1_1-jdk-noble java Hola.java
./comandos-p9-urls.sh                   # → salidas/p9-urls.tsv
./comandos-limpieza.sh
```

**Artemis:** la primera medición fue sin `--no-autotune` (484 s); el `compose.yaml` ya trae
`--no-autotune`. Para repetir la lenta: `ARTEMIS_EXTRA_ARGS="--http-host 0.0.0.0 --relax-jolokia"`.
**MySQL:** el `compose.yaml` ya trae `--secure-file-priv=`; el fallo de H5 se reproduce con
`--secure-file-priv=/caja`.

**Las licencias** (P9), a mano y en este orden: `curl` con un *user agent* de navegador sobre
`https://www.oracle.com/downloads/licenses/oracle-free-license.html` y sobre el *Licensing Information*
de Oracle (`salidas/licencias/`), `python3 texto-de-html.py` para pasarlos a texto, y `grep -n -i
"benchmark\|disclos\|publish\|test"`. La de SQL Server: el PDF de *Developer, Express and Evaluation*
enlazado desde `https://www.microsoft.com/en-us/useterms`, con `pdftotext -layout` y `grep -n -A4
benchmark`. La licencia que trae la imagen (`/usr/share/doc/mssql-server/license/1033/license.txt`,
UTF-16) solo remite a `aka.ms/useterms`.

## 5. 📏 Cómo se mide

- **Máquina:** Apple M1 Pro, 32 GB, macOS 26.7.1; la VM de Docker Desktop tiene 7,75 GiB, que es lo que
  Docker Desktop da por defecto a un Mac de 16 GB: por eso la tabla de RAM es representativa.
- **Arranque:** una corrida por servicio, desde `docker compose up -d` hasta el primer *healthcheck*
  verde, **sin la descarga**. Es contexto, no argumento.
- **RAM:** `docker stats --no-stream` (no cuenta la caché de archivos de la VM), un minuto después del
  arranque, y otra vez con M cargado tras un recorrido completo de `ResultadoItem` y 30 s de reposo. Se
  publica el pico de cada servicio, porque Oracle oscila mucho (2,40 GiB recién creado; 0,78–1,19 GiB
  después).
- **Cargas:** tiempo de pared de `carga/cargar.sh` (`total_seconds`), una corrida, con la caja montada
  en solo lectura. Las de Oracle quedan en `salidas/` y no se publican.
- **Generador:** segundos que imprime el propio script dentro del contenedor.

## 6. 🧮 Los intermedios que amasan la salida

- La tabla de resultados de `hallazgos.md` sale de `salidas/arranque-darwin-arm64.tsv` (columnas:
  fecha, servicio, imagen, arquitectura, segundos, estado, memoria) redondeando la memoria a MiB.
- Los digests salen de la columna 4 de `salidas/pull.tsv`.
- "≈ 2,4 GiB" es la suma de las tres filas "M cargado" de `salidas/ram-cargado-darwin-arm64.tsv`;
  "≈ 3,0 GiB", la de las siete filas "todo arriba"; "≈ 5,3 GiB", la suma del pico de cada servicio en
  los dos archivos (Oracle 2,40 GiB, SQL Server 996 MiB, MySQL 930 MiB, Artemis 405 MiB, Mongo
  289 MiB, Postgres 292 MiB, PostgREST 18 MiB).
- Las proporciones de H12 salen tal cual de `generador/proporciones.py` (`salidas/proporciones-m.txt`).

## 7. ✅ Qué se espera ver

Al 11/10/2026: el SHA-256 del perfil S con la semilla 1979 es
`57eaa40f9f15be1951bbc56e98b61678c3ebbb67af0ab93f8c24bbb437e701ba` y el de M,
`3b727a51242d0b818553f4802954f0e07b028cc1f2cd617a8e536da8fa51aa41`. Postgres 18.6 carga M en unos 16 s y
MySQL 9.7.2 en unos 51 s. `mongo:9.0.2` termina con `MongoDB cannot start`. SQL Server en Podman sale
con 139 (`libkrun`) o 133 (`applehv` + Rosetta). Los cuatro drivers dicen `default_autocommit=False` y
`other_session_sees_uncommitted=False`. Todo, en `hallazgos.md`.

## 8. 📂 Salidas

`salidas/` (1,1 GB, no se versiona): `caja/s` y `caja/m` (la caja generada), `logs/` (un log por
servicio), los `.tsv` y `.log` de cada script, `licencias/` (los textos descargados) y `uv-cache/`. Se
regenera corriendo §4. Al curso se copió solo lo que dice `hallazgos.md`; ninguna cifra de Oracle ni de
SQL Server fuera del arranque y la memoria.

## 9. 🧹 Limpieza

```bash
./comandos-limpieza.sh      # compose down -v, todo lo etiquetado, imágenes descartadas, inventario después y diff
```

Hecha el 11/10/2026: contenedores, volúmenes y redes iguales al inventario inicial (hubo que borrar a
mano dos volúmenes anónimos que dejó `docker compose rm -sf`; quedaron en el script). **Se conservan
las nueve imágenes elegidas** para T1: `pgvector/pgvector:0.8.7-pg18`, `mysql:9.7.2`,
`gvenzl/oracle-free:23.26.3-slim-faststart`, `mongo:8.0.20`, `postgrest/postgrest:v16.4`,
`apache/artemis:2.57.0`, `eclipse-temurin:25.0.4.1_1-jdk-noble`,
`mcr.microsoft.com/mssql/server:2025-CU9-ubuntu-24.04` y la de `uv`. Para liberarlas: `docker image rm`
con esos nombres (ninguna estaba antes de la sesión). La máquina de Podman se borró.

## 10. 🚫 Qué se dejó fuera

La caja generada y las licencias descargadas, que viven en `salidas/` y se regeneran con §4. Ningún
secreto: las contraseñas del `compose.yaml` (`lab`, `Lab-2026-pass`) son de prueba local.
