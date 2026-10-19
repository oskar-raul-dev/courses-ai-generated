# 📎 Apéndice a01 — Laboratorio contenerizado en tres plataformas

> **Curso:** Ruta SQL · Consulta rápida · **3 h**
> **Usado por:** todas las fases · **Versiones cubiertas:** Docker Desktop con motor 29.8.0 (kernel
> de la VM `7.0.12-linuxkit`) y Docker Compose v5.5.1, en macOS 26.7.1 sobre Apple M1 Pro
> **Fecha de verificación ejecutada:** 12/10/2026, **solo en macOS arm64**. Linux y Windows 11 con
> WSL2 están escritos desde la documentación oficial y marcados donde aplica: **no ejecutado todavía
> en esta plataforma**. Podman se probó solo con SQL Server, el 11/10/2026.

**Esto no se lee de corrido.** Se entra por el índice buscando algo concreto y se sale. Resuelve una
sola cosa: que tengas Postgres, MySQL y Oracle levantados a la vez en tu máquina, con la caja de
Alameda montada, sin aprender de contenedores nada que no necesites.

**Qué queda fuera:** qué es una imagen o una capa, las redes de contenedores, el `Dockerfile`, los
*registries* y el mecanismo de la emulación. Todo eso está en el curso *Docker Legacy Node*, del mismo autor, que aquí se nombra y no se repite. El `compose.yaml` de la ruta (perfiles,
digests, *healthchecks* y la tabla de RAM) es de [`a02`](a02-compose-de-la-ruta.md); la caja y el
generador, de [`a05`](a05-la-caja-y-el-generador.md); `uv` y los drivers, de
[`a06`](a06-python-java-y-drivers.md).

---

## Índice

- [Lo que necesitas antes de empezar](#-lo-que-necesitas-antes-de-empezar)
- [macOS arm64 y la tabla de emulación](#-macos-arm64-y-la-tabla-de-emulación)
- [Linux](#-linux)
- [Windows 11 con WSL2](#-windows-11-con-wsl2)
- [El ciclo en seis comandos](#-el-ciclo-en-seis-comandos)
- [Conectarse antes de tiempo](#️-conectarse-antes-de-tiempo)
- [Puerto ocupado](#-puerto-ocupado)
- [Memoria: Oracle decide qué cabe](#-memoria-oracle-decide-qué-cabe)
- [Podman al lado](#-podman-al-lado)
- [Limpiar y recuperar disco](#-limpiar-y-recuperar-disco)
- [Cuándo usar qué](#-cuándo-usar-qué)
- [Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-8)

---

## 🧰 Lo que necesitas antes de empezar

**16 GB de RAM en la máquina**, con 8 GB para la VM de contenedores; con eso entra el laboratorio
entero, como mide [`a02`](a02-compose-de-la-ruta.md#-la-tabla-de-ram). **Unos 12 GB de disco para
imágenes**, de los que Oracle se lleva la mitad, más los datos: la caja del perfil M ocupa 2,2 GB en
CSV y Postgres, con M cargado, otros 4,3 GB. Y el repositorio clonado, porque el laboratorio vive en
`src/lab/`.

| Imagen (perfil) | En disco |
|---|---|
| Oracle Free (`oracle`) | 6,04 GB |
| SQL Server 2025 (`sqlserver`, el track) | 2,42 GB |
| MySQL 9.7 (`contraste`) | 1,3 GB |
| MongoDB 8.0 (`mongo`, solo F20) | 1,26 GB |
| Postgres 18 con pgvector (`base`) | 660 MB |

La prueba de que todo está en su sitio es la misma en las tres plataformas:

```bash
docker info --format '{{.OperatingSystem}} · kernel {{.KernelVersion}} · {{.NCPU}} CPU · {{.MemTotal}} bytes'
docker compose version
```

```text
Docker Desktop · kernel 7.0.12-linuxkit · 8 CPU · 8319770624 bytes
Docker Compose version v5.5.1
```

Mira el segundo y el último campo de la primera línea. **El kernel no es el de tu sistema
operativo**, salvo en Linux: es el de la VM que pone Docker Desktop, y cambia cuando lo actualizas.
Los 8.319.770.624 bytes son los 7,75 GiB que Docker Desktop le dio a la VM en una máquina de 32 GB.

---

## 🍎 macOS arm64 y la tabla de emulación

Verificado el 12/10/2026 con Docker Desktop 29.8.0 en un M1 Pro.

**Instalar:** Docker Desktop desde su web oficial, o `brew install --cask docker`. Ábrelo una vez para
que cree la VM, y en *Settings → Resources* dale **8 GB como mínimo**.

**La arquitectura sí importa aquí, y por un solo motor.** Cuatro de las cinco imágenes del
laboratorio tienen *build* nativo `arm64`; SQL Server no lo tiene. Esto es lo que reporta cada
contenedor desde adentro:

```bash
for c in postgres mysql oracle sqlserver; do
  printf "%s\t%s\t" $c "$(docker exec alameda-lab-$c-1 uname -m)"
  docker image inspect "$(docker inspect alameda-lab-$c-1 --format '{{.Image}}')" --format '{{.Architecture}}'
done
```

```text
postgres	aarch64	arm64
mysql	aarch64	arm64
oracle	aarch64	arm64
sqlserver	x86_64	amd64
```

| Servicio | Imagen | En Apple Silicon |
|---|---|---|
| `postgres` | `arm64` | nativa |
| `mysql` | `arm64` | nativa |
| `oracle` | `arm64` | nativa: la de gvenzl y la oficial de Oracle traen las dos `arm64` |
| `mongo` | `arm64` | nativa |
| `sqlserver` | **solo `amd64`** | **emulada**: arranca en Docker Desktop, **no arranca en Podman** |

SQL Server solo lo usa el track opcional, así que el camino base no emula nada. En Docker Desktop
corre con la emulación de Rosetta y queda *healthy* en 12 s. En Podman no arranca, como se cuenta en
[Podman al lado](#-podman-al-lado). Por eso el track pide Docker Desktop en Apple Silicon, y lo dice en
el encabezado de [ss01](ss01-la-base-en-su-motor-original.md).

> 📝 **El `x86_64` de la última fila no es tu Mac.** Es lo que el binario de SQL Server cree tener
> debajo: la VM traduce cada instrucción. Los tiempos de SQL Server en un Mac no se parecen a los de
> un x86 nativo, y es una razón más para que el curso no publique números de ese motor ([`a09`](a09-licencias-publicacion-y-riesgo.md)).

**Docker Desktop o Colima.** Colima es la alternativa de código abierto en macOS. **Colima no está
verificado en este curso**: si lo usas, comprueba con `docker info` el kernel y la memoria de su VM
antes del primer `up`, y ten en cuenta que la emulación de `amd64` depende de cómo arranques su VM.

---

## 🐧 Linux

> ⚠️ **No ejecutado todavía en esta plataforma.** Receta de la documentación oficial.

El caso fácil, porque no hay VM: los contenedores usan **el kernel de tu host** y toda tu RAM. En
x86_64 ninguna imagen se emula, SQL Server incluido. En un Linux `arm64` (una Raspberry Pi 5, una VM
de Graviton), SQL Server no corre.

**Instalar:** Docker Engine y el plugin de Compose desde el repositorio oficial de Docker para tu
distribución, no el paquete `docker.io`, que suele ir atrasado. **Sin `sudo`:** agrega tu usuario al
grupo `docker` y abre una sesión nueva.

```bash
sudo usermod -aG docker "$USER"
```

> ⚠️ Pertenecer al grupo `docker` equivale a ser root en esa máquina. En un portátil personal es el
> trato habitual; en una máquina compartida, usa el modo *rootless* (lo explica el curso de Docker).

**Memoria:** no hay VM que la limite, así que el único freno son los `mem_limit` del
[`compose.yaml`](a02-compose-de-la-ruta.md#-memoria-por-servicio). No los quites.

---

## 🪟 Windows 11 con WSL2

> ⚠️ **No ejecutado todavía en esta plataforma.** Receta de la documentación oficial.

**Instalar:** `wsl --install` en una terminal de administrador, reiniciar, y después Docker Desktop
con el backend WSL2. Todo lo que sigue se ejecuta **dentro** de la distribución Linux, no en
PowerShell.

**Dónde vive el repositorio: esto es lo que más muerde.** Clónalo en el sistema de archivos de Linux
(`~/cursos/…`), **nunca en `/mnt/c/…`**. La caja de M son 2,2 GB en 439 archivos, y `lab load` los
lee todos: desde `/mnt/c`, cada lectura cruza la frontera entre Windows y Linux. VS Code abre la
carpeta de Linux sin problema con su extensión de WSL.

**Memoria:** WSL2 toma por defecto una parte de la RAM de Windows. Para fijarla, crea
`%UserProfile%\.wslconfig` y reinicia con `wsl --shutdown`:

```text
[wsl2]
memory=8GB
```

**Arquitectura:** en un PC x86_64, SQL Server corre sin emulación. En un Windows sobre ARM, la
situación es la de macOS sin la garantía de Rosetta: no se verificó.

---

## 🔁 El ciclo en seis comandos

Todo se ejecuta desde `src/`, con el CLI del curso. **`uv run lab` no esconde nada:** imprime el
comando de Compose que ejecuta, y puedes escribirlo tú mismo desde `src/lab/` (los perfiles, en
[`a02`](a02-compose-de-la-ruta.md#-los-perfiles)).

| Comando del curso | Qué hace |
|---|---|
| `uv run lab up base contraste oracle` | levanta los perfiles y **no devuelve hasta que el *healthcheck* está verde** |
| `uv run lab ps` | qué está arriba, su estado de salud y sus puertos |
| `docker compose logs --tail 50 oracle` | las últimas líneas del log de un servicio (desde `src/lab/`) |
| `docker compose exec postgres psql -U postgres -d alameda` | abre un proceso **dentro** del contenedor |
| `uv run lab down` | apaga y borra contenedores y red; **los datos se quedan** |
| `uv run lab down -v` | lo mismo, **y borra los volúmenes: los datos cargados se pierden** |

Así se ve el primero, con los tres motores ya creados:

```text
$ uv run lab up base contraste oracle
→ docker compose --profile base --profile contraste --profile oracle up -d --wait
 Container alameda-lab-postgres-1 Waiting
 Container alameda-lab-mysql-1 Waiting
 Container alameda-lab-oracle-1 Waiting
 Container alameda-lab-mysql-1 Healthy
 Container alameda-lab-oracle-1 Healthy
 Container alameda-lab-postgres-1 Healthy
```

Y el `exec`, que es la forma de entrar sin instalar ningún cliente:

```text
$ docker compose exec postgres psql -U postgres -d alameda -c '\dn'
      List of schemas
  Name  |       Owner
--------+-------------------
 lab    | postgres
 legacy | postgres
 public | pg_database_owner
 truth  | postgres
(4 rows)
```

Los esquemas `legacy` y `truth` los crea `lab load` ([`a05`](a05-la-caja-y-el-generador.md)); `lab`
guarda qué caja se cargó. Los clientes de cada motor y sus comandos están en
[`a03`](a03-clis-de-los-motores.md).

> 💡 **`up` siempre con `--wait`**, y `lab up` ya lo pone. Sin él, `up -d` devuelve cuando el
> contenedor arranca, no cuando el motor acepta conexiones, y con Oracle eso son unos segundos de
> diferencia que se ven en la sección siguiente.

> 💡 **`docker compose pull` antes del primer `up`.** Oracle son 6 GB: con `pull` aparte, una
> descarga lenta se ve como descarga lenta y no como un motor que no arranca.

---

## ⏱️ Conectarse antes de tiempo

El primer error de casi todo el mundo con Oracle: `up -d` sin `--wait` y conectarse enseguida. El
contenedor ya está `Up`, pero la base todavía no:

```text
$ docker compose --profile oracle up -d
 Container alameda-lab-oracle-1 Started
$ docker compose exec oracle sqlplus -s -L system/lab@FREEPDB1
ERROR:
ORA-12154: Cannot connect to database. Cannot find alias FREEPDB1 in
/opt/oracle/product/26ai/dbhomeFree/network/admin/tnsnames.ora.
Help: https://docs.oracle.com/error-help/db/ora-12154/


SP2-0751: Unable to connect to Oracle.  Exiting SQL*Plus
Help: https://docs.oracle.com/error-help/db/sp2-0751/
```

Según el instante en que llegues, el mensaje es otro: si el alias ya existe pero el *listener* no,
`ORA-12541: Cannot connect. No listener at host 172.25.0.2 port 1521.` Los dos dicen lo mismo:
**todavía no**. 🩺 `docker compose ps` lo confirma con `Up Less than a second (health: starting)`, y
seis segundos después, `Up 6 seconds (healthy)`; ahí `sqlplus` conecta. Con un volumen nuevo y
`lab up`, que espera, **Oracle tarda en estar *healthy* entre 13 y 16 s** en esta máquina; los
tiempos de los demás están en [`a02`](a02-compose-de-la-ruta.md#-healthchecks-y-cuánto-tarda-cada-uno).
Los dos mensajes están en el [catálogo de errores](a08-catalogo-de-errores.md).

---

## 🚪 Puerto ocupado

El laboratorio publica sus puertos solo en `127.0.0.1` y desplazados a `2xxxx` (`25432`, `23306`,
`21521`), justamente para no chocar con el Postgres o el MySQL que ya tengas instalado. Aun así puede
pasar, por ejemplo con otro contenedor tuyo en el 25432:

```text
$ uv run lab up
→ docker compose --profile base up -d --wait
…
 Container alameda-lab-postgres-1 Starting
Error response from daemon: failed to set up container networking: driver failed programming external connectivity on endpoint alameda-lab-postgres-1 (4dbc5937244b98e0572efcb7b0c8405fe4f431f080596b0a9bd7222762784cfe): Bind for 127.0.0.1:25432 failed: port is already allocated
```

🩺 **Quién lo tiene.** Primero, entre los contenedores:

```bash
docker ps --filter publish=25432 --format 'table {{.Names}}\t{{.Ports}}'
```

```text
NAMES           PORTS
otro-postgres   127.0.0.1:25432->5432/tcp
```

Si no sale nada, lo tiene un proceso del sistema: `lsof -nP -iTCP:25432 -sTCP:LISTEN` en macOS y
Linux.

**Cómo se sale:** cambias el lado del host con su variable, sin tocar el `compose.yaml`.

```text
$ POSTGRES_PORT=25433 uv run lab up
→ docker compose --profile base up -d --wait
 Container alameda-lab-postgres-1 Recreate
 Container alameda-lab-postgres-1 Recreated
 Container alameda-lab-postgres-1 Starting
 Container alameda-lab-postgres-1 Started
 Container alameda-lab-postgres-1 Waiting
 Container alameda-lab-postgres-1 Healthy
```

`uv run lab ps` muestra el puerto nuevo en su última columna: `127.0.0.1:25433->5432/tcp`.

Para que el cambio dure, ponlo en `src/lab/.env` (`POSTGRES_PORT=25433`), que el CLI y Compose leen
los dos, y que git ignora. Las variables de todos los servicios están en
[`a02`](a02-compose-de-la-ruta.md#-puertos-y-variables).

> 🩻 Tras el error, el contenedor queda en `Created`, no en `Up`. El siguiente `up` lo recrea solo: es
> el `Recreate` de arriba.

---

## 🧠 Memoria: Oracle decide qué cabe

**Oracle es el único servicio que no entra en cualquier límite.** El `compose.yaml` le da 3 GB, y la
imagen avisa en su primera línea si le das menos de 2:

```text
CONTAINER: starting up...
CONTAINER: WARNING: The container has less than 2 GB memory available to run Oracle Database Free.
There are currently only 512 MiB available inside the container.
There have been known cases of Oracle Database Free not starting because of insufficient memory.
```

Lo que pasa después **no siempre es lo mismo**, y eso es lo que hay que saber reconocer. Tres
arranques seguidos con `ORACLE_MEMORY=512m`, el 12/10/2026, con un volumen nuevo cada vez:

| Intento | `docker compose ps -a` | `docker inspect` | Lo último del log |
|---|---|---|---|
| 1 | `Up 10 seconds (healthy)` | `oom=true exit=0` | `Database opened.` |
| 2 | `Exited (41)` | `oom=true exit=41` | `Database opened.` y un error en la consulta siguiente |
| 3 | `Exited (41)` | `oom=true exit=41` | `ORA-03113: end-of-file on communication channel` |

El tercero, con el log alrededor del error:

```text
Redo Buffers		    4530176 bytes
Database mounted.
ORA-03113: end-of-file on communication channel
Process ID: 178
Session ID: 162 Serial number: 2802
Help: https://docs.oracle.com/error-help/db/ora-03113/
```

🩺 **La firma es `OOMKilled=true`, y nada más.** El kernel no mata el proceso principal del
contenedor sino uno de los procesos de la instancia, así que el código de salida lo decide el script de
arranque de la imagen (41, no el 137 habitual), y a veces el contenedor ni siquiera sale: queda
*healthy* con un proceso menos. **`docker inspect … --format '{{.State.OOMKilled}}'` es la pregunta,
no el código ni el estado.**

**Dónde está el piso** depende de lo que haya alrededor. El mismo día, con la VM sola, Oracle arrancó
con 768 MB y con 1 GB, dos de dos. Con los otros tres motores arriba y M cargado, **no arrancó con
1 GB ni con 1,5 GB**, tres intentos, y la causa exacta no la aislé. Por eso el curso le da 3 GB y no
el mínimo que funcionó una vez.

**Lo que cabe a la vez**, con la tabla completa en
[`a02`](a02-compose-de-la-ruta.md#-la-tabla-de-ram): los tres motores con M cargado ocupan unos
3,1 GiB en reposo, y el laboratorio entero, con SQL Server, unos 3,8 GiB. En una VM de 8 GB sobra.

---

## 🦭 Podman al lado

> ⚠️ **El camino base no se ejecutó con Podman en este curso.** Se probó solo SQL Server, con Podman
> 6.1.3 en macOS, el 11/10/2026. Lo demás sale de la documentación.

El CLI del curso usa Podman si se lo pides con una variable: `LAB_COMPOSE="podman compose" uv run lab
up`. `podman compose` delega en un proveedor (`docker-compose` o `podman-compose`), y **no se comportan
igual en todo**: si algo falla solo con Podman, lo primero es saber cuál estás usando.

**SQL Server no arranca en Podman sobre Apple Silicon, por ninguno de los dos caminos.** Con el
proveedor de VM por defecto de Podman 6 en macOS, `libkrun`, que emula con QEMU:

```text
/opt/mssql/bin/launch_sqlservr.sh: line 37:    11 Segmentation fault      (core dumped) "$@"
```

Y con `applehv` y Rosetta activado (`[machine] rosetta = true`), que llega más lejos:

```text
assertion failed [x86_avx_state_ptr->xsave_header.xfeatures == kSupportedXFeatureBits]:
(ThreadContextSignals.cpp:414 rt_sigreturn)
```

Rosetta no reproduce el estado AVX que SQL Server 2025 espera. Las dos diferencias de Podman que sí
pueden morder en el camino base son las de siempre: corre *rootless* por defecto, y los UID de dentro
del contenedor se traducen a otro rango en el host, así que un volumen montado desde tu disco puede
aparecer con otro dueño. La caja se monta en solo lectura, así que el laboratorio no debería notarlo.

---

## 🧹 Limpiar y recuperar disco

**Mira antes de borrar:**

```text
$ docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          37        14        26.22GB   9.572GB (36%)
Containers      17        7         524.3MB   490.6MB (93%)
Local Volumes   33        15        93.24GB   7.549GB (8%)
Build Cache     169       10        22.64GB   11.98GB
```

Esa es la máquina donde se verificó el apéndice, con otros cursos al lado. Tu reparto será otro.

**Todo lo que crea el laboratorio lleva la etiqueta `curso=ruta-sql`**: contenedores, volúmenes y
red. Con eso se ve qué es del curso sin adivinar por el nombre:

```bash
docker volume ls --filter label=curso=ruta-sql
docker system df -v | grep alameda-lab
```

**Del más acotado al más amplio:**

| Qué quieres borrar | Comando | Qué pierdes |
|---|---|---|
| los datos cargados | `uv run lab down -v` | los volúmenes del laboratorio; la caja en CSV se queda |
| la caja de un perfil | `rm -r src/lab/caja/m` | el CSV de M; `uv run lab generate --profile m` lo rehace, idéntico |
| una imagen que ya no usas | `docker image rm` con su digest | la imagen; vuelve con `pull` |
| todo lo que Docker considere sin uso | `docker system prune` | **también lo de otros proyectos**: léelo antes de confirmar |

> ⚠️ **`docker volume prune` y `docker system prune --volumes` no saben qué es de este curso.**
> Borran los volúmenes sin uso de cualquier proyecto de la máquina. Para el laboratorio, `lab down -v`
> es suficiente y no toca nada ajeno.

---

## 🧭 Cuándo usar qué

| Situación | Haz esto | Por qué |
|---|---|---|
| Empiezas a trabajar | `uv run lab up` con los perfiles de la fase | devuelve cuando los motores aceptan conexiones |
| `ORA-12154` u `ORA-12541` al conectar | `uv run lab ps`, y esperar `healthy` | la base tarda unos segundos más que el contenedor |
| Un servicio sale con `Exited`, o se porta raro | `docker inspect … --format '{{.State.OOMKilled}}'` | `OOMKilled` dice si fue memoria, sea cual sea el código o el estado |
| `port is already allocated` | `docker ps --filter publish=PUERTO`, y la variable del puerto | casi siempre es otro contenedor tuyo |
| Terminas por hoy | `uv run lab down` | libera RAM y conserva lo cargado |
| Quieres la base limpia | `uv run lab down -v` y `uv run lab load` | la caja regenera lo mismo, byte por byte |
| Te quedas sin disco | `docker system df`, y el comando más acotado de la tabla | no borrar lo de otros proyectos |
| Vas a hacer el track en un Mac | Docker Desktop, no Podman | SQL Server solo es `amd64` |

---

## ⚠️ Advertencias

- **`down -v` no pide confirmación.** La caja se regenera idéntica, pero volver a cargar M en los tres
  motores lleva unos minutos.
- **Un contenedor *healthy* no es una base cargada.** `healthy` significa que el motor acepta
  conexiones. Los datos los pone `lab load` ([`a05`](a05-la-caja-y-el-generador.md)).
- **Los tiempos de arranque dependen de lo que tengas arriba.** Antes de medir algo, `uv run lab
  down` y solo los perfiles que toca.

---

## 📚 Referencias

> ⚠️ Las URL y sus contenidos cambian, y la documentación de estas herramientas suele cubrir solo la
> última versión. Este apéndice se verificó con Docker Desktop 29.8.0 y Compose v5.5.1.

- **Docker Desktop para Mac** — https://docs.docker.com/desktop/setup/install/mac-install/ —
  instalación y ajustes de recursos.
- **Docker Engine en Linux** — https://docs.docker.com/engine/install/ — los repositorios oficiales
  por distribución.
- **Pasos posteriores en Linux** — https://docs.docker.com/engine/install/linux-postinstall/ — el
  grupo `docker` y lo que implica.
- **Docker Desktop con WSL2** — https://docs.docker.com/desktop/features/wsl/ — el backend y dónde
  guardar los archivos.
- **Configuración de WSL** — https://learn.microsoft.com/en-us/windows/wsl/wsl-config — el archivo
  `.wslconfig`.
- **Referencia de `docker compose`** — https://docs.docker.com/reference/cli/docker/compose/ — `up
  --wait`, perfiles y `down -v`.
- **Podman Compose** — https://docs.podman.io/en/latest/markdown/podman-compose.1.html — qué
  proveedor usa y cómo se elige.
- **ORA-03113** — https://docs.oracle.com/error-help/db/ora-03113/ — el mensaje de la sección de
  memoria.
- **El curso *Docker Legacy Node***, del mismo autor: memoria y límites, Apple Silicon y
  emulación, y Docker contra Podman. Lectura sugerida, no requisito.

**Orden sugerido:** tu plataforma antes de instalar nada; el ciclo la primera vez que levantes el
laboratorio; memoria antes de levantar Oracle al lado de otra cosa pesada; limpiar cuando `docker
system df` empiece a preocuparte.

---

## 🧪 Ejercicios (8)

## 🟢 Fácil — el ciclo (1–3)

### 🟢 Ejercicio 1 — La prueba de que todo está en su sitio

Ejecuta los dos comandos de *Lo que necesitas antes de empezar* y anota el kernel y la memoria total.

**Pregunta:** ¿ese kernel es el de tu sistema operativo o el de una VM, y qué lo cambia en tu
plataforma? ¿Te alcanza la memoria para los tres motores con M cargado?

[Solución](soluciones/a01-laboratorio-contenerizado.md#ejercicio-1)

### 🟢 Ejercicio 2 — Qué borra cada `down`

Levanta el perfil `base`, entra con `exec` a `psql` y ejecuta `SELECT version()`. Después `uv run lab
down`, comprueba con `docker volume ls --filter label=curso=ruta-sql` qué quedó, y termina con `uv run
lab down -v`.

**Objetivo:** ver con tus propios ojos que `down` conserva el volumen de Postgres y `down -v` lo
borra.

[Solución](soluciones/a01-laboratorio-contenerizado.md#ejercicio-2)

### 🟢 Ejercicio 3 — Conectarse antes de tiempo

Levanta el perfil `oracle` **sin** `--wait` (con `docker compose --profile oracle up -d` desde
`src/lab/`) y, en cuanto devuelva, conéctate con `sqlplus`. Repite hasta que conecte.

**Objetivo:** reproducir `ORA-12154` o `ORA-12541`, y medir cuántos segundos tarda Oracle en tu
máquina en pasar de `health: starting` a `healthy`.

[Solución](soluciones/a01-laboratorio-contenerizado.md#ejercicio-3)

## 🟡 Intermedio — lo que falla (4–6)

### 🟡 Ejercicio 4 — Puerto ocupado

Levanta cualquier contenedor publicado en `127.0.0.1:25432` y después `uv run lab up`.

**Objetivo:** reproducir `port is already allocated`, encontrar al dueño con `docker ps --filter
publish=25432`, y salir con `POSTGRES_PORT` sin editar el `compose.yaml`.

[Solución](soluciones/a01-laboratorio-contenerizado.md#ejercicio-4)

### 🟡 Ejercicio 5 — Oracle sin memoria

Con `ORACLE_MEMORY=512m` y el volumen de Oracle borrado, levanta el perfil `oracle` tres veces,
borrando el volumen entre una y otra.

**Objetivo:** anotar en cada intento el estado, el código de salida y `OOMKilled`, encontrar en el log
la línea que lo anunciaba, y explicar por qué un contenedor *healthy* puede tener `OOMKilled=true`.
Después, buscar el límite más bajo con el que arranca en tu máquina con la VM sola.

[Solución](soluciones/a01-laboratorio-contenerizado.md#ejercicio-5)

### 🟡 Ejercicio 6 — Qué cabe en tu máquina

Con M cargado en los tres motores, recorre `ResultadoItem` entera en cada uno, espera un minuto y toma
`docker stats --no-stream`.

**Pregunta:** ¿cuánta memoria ocupa cada motor, y cuánto margen te queda en la VM? ¿Te entraría un
segundo Oracle?

[Solución](soluciones/a01-laboratorio-contenerizado.md#ejercicio-6)

## 🟠 Difícil — decidir (7–8)

### 🟠 Ejercicio 7 — Recuperar disco sin tocar lo ajeno

Ejecuta `docker system df -v` y decide qué borrarías para recuperar 5 GB **sin tocar nada que no sea de
este curso**.

**Objetivo:** escribir la lista de comandos, del más acotado al más amplio, con lo que pierde cada
uno, y justificar por qué no usas `docker volume prune`.

[Solución](soluciones/a01-laboratorio-contenerizado.md#ejercicio-7)

### 🟠 Ejercicio 8 — SQL Server y la emulación

Antes de ejecutar nada, predice qué devuelve `uname -m` dentro del contenedor de SQL Server en tu
máquina. Después levanta el perfil `sqlserver` y compruébalo.

**Pregunta:** ¿qué arquitectura ve SQL Server, cuál tiene tu máquina, y por qué eso hace que un tiempo
medido en ese contenedor no diga nada del motor?

[Solución](soluciones/a01-laboratorio-contenerizado.md#ejercicio-8)

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida: los archivos que describe los deja
> `a02` en el repositorio. Lo que salga de leerlo se commitea con el prefijo de la fase desde la que
> se llegó.
