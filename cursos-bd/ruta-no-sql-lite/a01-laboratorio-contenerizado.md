# 📎 Apéndice a01 — Laboratorio contenerizado en tres plataformas

> **Curso:** Ruta NoSQL Lite · Consulta rápida · **3 h**
> **Usado por:** todas las fases · **Versiones cubiertas:** Docker Desktop 29.8.0 (kernel de
> la VM `7.0.12-linuxkit`) y Docker Compose v5.5.1 en macOS arm64
> **Fecha de verificación ejecutada:** 29/09/2026, **solo en macOS arm64**. Linux y Windows 11
> (WSL2) están escritos desde la documentación y marcados donde aplica: **no ejecutado todavía
> en esta plataforma**.

**Esto no se lee de corrido.** Se entra por el índice buscando algo concreto y se sale. Resuelve
una sola cosa: que tengas los diez motores del curso levantables en tu máquina en menos de media
hora, sin aprender de contenedores nada que no necesites.

**Qué queda fuera:** qué es una imagen o una capa, el copy-on-write, las redes de contenedores,
el `Dockerfile`, los registries, las arquitecturas y la emulación. Todo eso está escrito, y bien,
en el curso *Docker Legacy Node*;
aquí no se repite. El `compose.yaml` de la ruta —perfiles, digests, healthchecks— es de
[`a02`](a02-compose-de-la-ruta.md).

---

## Índice

- [Lo que necesitas antes de empezar](#-lo-que-necesitas-antes-de-empezar)
- [macOS arm64](#-macos-arm64)
- [Linux](#-linux)
- [Windows 11 con WSL2](#-windows-11-con-wsl2)
- [El ciclo en seis comandos](#-el-ciclo-en-seis-comandos)
- [Puerto ocupado](#-puerto-ocupado)
- [Memoria: lo que decide qué cabe a la vez](#-memoria-lo-que-decide-qué-cabe-a-la-vez)
- [Podman al lado](#-podman-al-lado)
- [Limpiar y recuperar disco](#-limpiar-y-recuperar-disco)
- [Cuándo usar qué](#-cuándo-usar-qué)
- [Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-8)

---

## 🧰 Lo que necesitas antes de empezar

**16 GB de RAM en la máquina**, de los cuales la VM de contenedores debería tener al menos 8.
**Unos 10 GB de disco solo para imágenes**: las diez del curso suman 8,8 GB, medido el
29/09/2026, y los volúmenes de datos van aparte. Y el repositorio del curso clonado, porque el
laboratorio vive en `src/lab/`, con su `compose.yaml`.

La prueba de que todo está en su sitio es la misma en las tres plataformas:

```bash
docker info --format '{{.OperatingSystem}} · kernel {{.KernelVersion}} · {{.NCPU}} CPU · {{.MemTotal}} bytes'
docker compose version
```

```text
Docker Desktop · kernel 7.0.12-linuxkit · 8 CPU · 8319770624 bytes
Docker Compose version v5.5.1
```

Mira los dos primeros campos. **El kernel no es el de tu sistema operativo**, salvo en Linux, y
en este curso eso tiene consecuencias (ver macOS).

---

## 🍎 macOS arm64

Verificado el 29/09/2026 con Docker Desktop 29.8.0.

**Instalar:** Docker Desktop desde su web oficial, o `brew install --cask docker`. Ábrelo una vez
para que cree la VM.

**Dale memoria a la VM.** En *Settings → Resources*, **8 GB como mínimo**. Con menos, las tres
familias sobre JVM —búsqueda, grafos y columnar— no caben ni de a una con holgura (ver Memoria).

**Arquitectura: aquí no hay nada que hacer.** Las diez imágenes del curso tienen build nativo
`arm64`, comprobado una por una el 29/09/2026. Si algún día una no lo tiene, el síntoma y la
salida están en las fases 21 (arquitecturas y emulación) y 22 (Apple Silicon) del curso
*Docker Legacy Node*.

> ⚠️ **El kernel lo pone Docker Desktop, no tu Mac.** Los contenedores corren sobre el kernel
> de la VM, y ese kernel cambia cuando actualizas Docker Desktop. Con la 29.8.0 es
> `7.0.12-linuxkit`, y **MongoDB 8.0.21 o posterior se niega a arrancar sobre él**:
>
> ```text
> MongoDB cannot start: Linux kernel versions 6.19 and newer has a known incompatibility with this version of MongoDB. See https://jira.mongodb.org/browse/SERVER-121912 for more information.
> ```
>
> Por eso el laboratorio fija `mongo:8.0.20`. La causa, la tabla de versiones y la prueba de
> carga que la respalda están en [`a02`](a02-compose-de-la-ruta.md) y en
> [`a09`](a09-catalogo-de-errores.md). Cuando actualices Docker Desktop, vuelve a ejecutar
> `docker info --format '{{.KernelVersion}}'`.

**Docker Desktop o Colima.** Colima es la alternativa de código abierto. **Colima no está
verificado en este curso**, y la tabla entera sale de la documentación de los dos, incluida
la fila de licencias: confírmala antes de decidir por ella en una empresa.

| | Docker Desktop | Colima |
|---|---|---|
| Licencia | gratis para uso personal y empresas pequeñas; de pago por encima | MIT |
| Interfaz | aplicación con ajustes gráficos | solo CLI: `colima start --cpu 4 --memory 8` |
| Kernel de la VM | el de linuxkit, verificado arriba | el de la imagen de Lima: **compruébalo** con `docker info` antes de levantar Mongo |

El detalle de Colima y Lima está en el apéndice a07 del curso *Docker Legacy Node*.

---

## 🐧 Linux

> ⚠️ **No ejecutado todavía en esta plataforma.** Receta de la documentación oficial; se
> verifica en la sesión de laboratorio de Linux.

El caso fácil, porque no hay VM: los contenedores usan **el kernel de tu host**. Consecuencia
directa: el problema de MongoDB de la sección de macOS depende aquí de tu kernel. Si
`uname -r` devuelve algo entre 6.19 y 7.0.13, aplica lo mismo.

**Instalar:** Docker Engine y el plugin de Compose desde el repositorio oficial de Docker para
tu distribución, no el paquete `docker.io` de la distribución, que suele ir atrasado.

**Sin `sudo`:** añade tu usuario al grupo `docker` y abre una sesión nueva.

```bash
sudo usermod -aG docker "$USER"
```

> ⚠️ Pertenecer al grupo `docker` equivale a ser root en esa máquina. En un portátil personal es
> el trato habitual; en una máquina compartida, usa el modo rootless. Qué cambia y por qué está
> en la fase 25 (rootless y user namespaces) del curso *Docker Legacy Node*.

**Memoria:** no hay VM que configurar. El límite es la RAM de tu máquina, y por eso los límites
por servicio de la sección de memoria importan todavía más aquí.

---

## 🪟 Windows 11 con WSL2

> ⚠️ **No ejecutado todavía en esta plataforma.** Receta de la documentación oficial; se
> verifica cuando se trabaje el curso en Windows 11.

**Instalar:** `wsl --install` en una terminal de administrador, reiniciar, y después Docker
Desktop con el backend WSL2 activado. Comprueba desde **dentro** de la distribución Linux, no
desde PowerShell:

```bash
docker info --format '{{.OperatingSystem}} · kernel {{.KernelVersion}}'
```

**Dónde vive el repositorio: esto es lo que más muerde.** Clónalo en el sistema de archivos de
Linux (`~/cursos/…`), **nunca en `/mnt/c/…`**. Desde `/mnt/c`, cada lectura de archivo cruza
la frontera entre Windows y Linux, y todo lo que toca muchos archivos se vuelve lento: `npm
install`, el generador de datos, los montajes de volúmenes. VS Code abre la carpeta de Linux sin
problema con la extensión WSL.

**Memoria:** WSL2 toma por defecto una parte de la RAM de Windows. Para fijarla, crea
`%UserProfile%\.wslconfig`:

```text
[wsl2]
memory=8GB
```

y reinicia WSL con `wsl --shutdown`.

**Kernel:** el de WSL2 lo actualiza Windows (`wsl --update`), no Docker Desktop. Comprueba la
versión antes de levantar MongoDB, igual que en las otras dos plataformas. El detalle de Windows
y PowerShell está en el apéndice a08 del curso *Docker Legacy Node*.

---

## 🔁 El ciclo en seis comandos

Todo se ejecuta desde `src/lab/` y siempre con el perfil de la familia (los perfiles están en
[`a02`](a02-compose-de-la-ruta.md)). Una línea por comando, y ni una más.

| Comando | Qué hace |
|---|---|
| `docker compose --profile base up -d --wait` | levanta el perfil y **no devuelve hasta que el healthcheck está verde** |
| `docker compose ps` | qué está arriba, su estado de salud y sus puertos |
| `docker compose logs --tail 50 base` | las últimas líneas del log de un servicio |
| `docker compose exec base psql -U postgres` | abre un proceso **dentro** del contenedor ya arrancado |
| `docker compose --profile base down` | apaga y borra contenedores y red; **los datos se quedan** |
| `docker compose --profile base down -v` | lo mismo, **y borra los volúmenes: los datos se pierden** |

Así se ve de verdad, en macOS el 29/09/2026:

```text
$ docker compose ps
NAME                IMAGE                          COMMAND                  SERVICE   CREATED         STATUS                   PORTS
condor-lab-base-1   pgvector/pgvector:0.8.6-pg18   "docker-entrypoint.s…"   base      3 seconds ago   Up 2 seconds (healthy)   0.0.0.0:15432->5432/tcp, [::]:15432->5432/tcp

$ docker compose exec base psql -U postgres -tAc "select version()"
PostgreSQL 18.6 (Debian 18.6-1.pgdg12+2) on aarch64-unknown-linux-gnu, compiled by gcc (Debian 12.2.0-14+deb12u1) 12.2.0, 64-bit
```

La diferencia entre `down` y `down -v`, que es la que cuesta datos:

```text
$ docker compose down
 Container condor-lab-base-1 Removed
 Network condor-lab_default Removed
$ docker volume ls --filter name=condor-lab
DRIVER    VOLUME NAME
local     condor-lab_base-data
$ docker compose down -v
 Volume condor-lab_base-data Removed
```

> 💡 **`--wait` no es opcional en este curso.** Sin él, `up -d` devuelve en cuanto el contenedor
> arranca, no cuando el motor acepta conexiones. Cassandra tarda unos 60 s en aceptar CQL, y
> el primer error de la mitad de los lectores es conectarse antes de tiempo.

> 💡 **`pull` antes de `up` la primera vez.** Con `docker compose --profile busqueda pull`, un
> fallo de red se ve como fallo de red. Dentro de `up`, una descarga colgada parece un motor
> que no arranca: en la sesión de laboratorio, el CDN de Docker Hub devolvió
> `net/http: timeout awaiting response headers` y `up` se quedó esperando sin decir nada más.

> 💡 **`--profile "*"` activa todos los perfiles a la vez.** Es la forma cómoda de apagar
> todo el laboratorio: `docker compose --profile "*" down`.

---

## 🚪 Puerto ocupado

Es el error más común del primer día, porque casi todo el mundo tiene ya un Postgres o un
Mongo corriendo. En la máquina donde se verificó este apéndice había otro laboratorio con el
5432 tomado:

```text
Error response from daemon: failed to set up container networking: driver failed programming external connectivity on endpoint condor-lab-base-1 (566dd80ea4f4…): Bind for 0.0.0.0:5432 failed: port is already allocated
```

🩺 **Quién lo tiene.** Primero, entre los contenedores:

```bash
docker ps --filter publish=5432 --format 'table {{.Names}}\t{{.Ports}}'
```

```text
NAMES             PORTS
bd-lab-postgres   0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp
```

Si no sale nada, lo tiene un proceso del sistema: `lsof -nP -iTCP:5432 -sTCP:LISTEN` en macOS
y Linux. En macOS, un puerto publicado por Docker aparece a nombre de `com.docker…`, no del
contenedor, y por eso conviene preguntar primero a `docker ps`.

**Cómo se sale:** o apagas lo que lo ocupa, o cambias **el lado del host** del mapeo, que es el
número de la izquierda en `"15432:5432"`. El puerto de dentro del contenedor no se toca: los
servicios del laboratorio se hablan entre ellos por la red interna y no se enteran del cambio.
Cómo lo expone el `compose.yaml` de la ruta está en [`a02`](a02-compose-de-la-ruta.md).

> 🩻 Tras el error, el contenedor queda en estado `Created`, no `Up`. `docker compose ps -a` lo
> muestra, y el siguiente `up` lo recrea solo.

---

## 🧠 Memoria: lo que decide qué cabe a la vez

**RAM en reposo de cada familia**, medida en macOS arm64 el 29/09/2026 con la configuración de
[`a02`](a02-compose-de-la-ruta.md), un minuto después de estar healthy:

| Familia | En reposo | Nota |
|---|---|---|
| columnar (Cassandra) | 1,16 GiB | heap limitado a 512 MB; **sin límite, 4,63 GiB** |
| búsqueda (OpenSearch) | 1020 MiB | heap de 512 MB |
| grafos (Neo4j) | 529 MiB | heap de 512 MB |
| NewSQL (CockroachDB, un nodo) | 318 MiB | el modo de nueve nodos de F22 ocupa 1,71 GiB |
| documental, offline, series, vectorial, base, clave-valor | entre 12 y 115 MiB cada una | |

Dos lecturas. **Las tres familias sobre JVM suman unos 2,7 GiB aun con el heap limitado.** Las otras
seis de la tabla juntas ocupan unos 405 MiB, y con CockroachDB, unos 725 MiB. Y **en reposo no es bajo carga**: las fases B
cargan los motores a propósito, así que estos números son el piso, no el techo.

**El límite por servicio no es un detalle.** Un heap que no cabe en el límite del contenedor no
da un error de Java: el kernel mata el proceso. OpenSearch con heap de 512 MB y un límite de
600 MB, en macOS:

```text
$ docker compose ps -a
NAME                    STATUS
condor-lab-busqueda-1   Exited (137) 1 second ago
```

🩺 `docker inspect condor-lab-busqueda-1 --format 'oom={{.State.OOMKilled}}'` devuelve
`oom=true`. **El código 137 más `OOMKilled` es la firma.** La JVM usa memoria fuera del heap, y
el mismo servicio con 1200 MB sí arranca, aunque justo:

```text
NAME                    MEM USAGE / LIMIT     MEM %
condor-lab-busqueda-1   1.029GiB / 1.172GiB   87.78%
```

Los límites que usa el curso, y qué combinaciones de perfiles caben en 8 y en 16 GB, son de
[`a02`](a02-compose-de-la-ruta.md). La regla práctica: **Postgres más una familia, siempre;
dos familias JVM a la vez, solo con la VM en 8 GB o más y nada más arriba.**

---

## 🦭 Podman al lado

> ⚠️ **No ejecutado en este curso.** La tabla sale de la documentación de Podman; el curso se
> verificó con Docker.

En lo que usa este curso, los comandos son los mismos con `podman` en lugar de `docker`.
`podman compose` delega en un proveedor de Compose, que puede ser `docker-compose` o
`podman-compose`, y **no se comportan igual en todo**. Si algo del laboratorio falla solo con
Podman, lo primero es saber cuál estás usando.

| Docker | Podman |
|---|---|
| `docker compose --profile base up -d --wait` | `podman compose --profile base up -d` (el soporte de `--wait` depende del proveedor) |
| `docker compose ps` / `logs` / `exec` / `down -v` | iguales, con `podman compose` |
| `docker info` | `podman info` |
| `docker system df` | `podman system df` |

**Las tres diferencias que muerden:**

- **Rootless por defecto.** Los contenedores corren con tu usuario, sin daemon de root. Es
  más seguro, y es la causa de las otras dos.
- **Puertos por debajo de 1024.** Un usuario sin privilegios no puede publicarlos. Al
  laboratorio no le afecta —todos sus puertos están por encima—, pero si mapeas algo al 80,
  falla.
- **Permisos de volumen.** Los UID de dentro del contenedor se traducen a un rango de UID de tu
  usuario, así que un volumen montado desde tu disco puede aparecer con un dueño que no
  esperas. El mecanismo está en
  las fases 17 (usuarios, permisos y volúmenes) y 24 (Docker y Podman) del curso *Docker Legacy
  Node*.

---

## 🧹 Limpiar y recuperar disco

Diez motores, tres volúmenes de datos y las imágenes llenan el disco antes de lo que nadie
espera. **Mira antes de borrar:**

```text
$ docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          43        17        20.43GB   14.81GB (72%)
Containers      23        7         479.2kB   319.5kB (66%)
Local Volumes   23        12        8.404GB   1.863GB (22%)
Build Cache     306       0         33.62GB   29.85GB
```

Esa es la máquina donde se verificó el apéndice, con otros cursos al lado. Tu reparto será otro,
pero la columna que importa es `RECLAIMABLE`.

**Del más acotado al más amplio:**

| Qué quieres borrar | Comando | Qué pierdes |
|---|---|---|
| los datos de una familia | `docker compose --profile columnar down -v` | los volúmenes de ese perfil, y nada más |
| todo el laboratorio | `docker compose --profile "*" down -v` | todos los datos del curso; las imágenes se quedan |
| una imagen que ya no usas | `docker image rm cassandra:5.0` | la imagen; se vuelve a descargar con `pull` |
| todo lo que Docker considere sin uso | `docker system prune` | **también lo de otros proyectos**: léelo antes de confirmar |

> ⚠️ **`docker system prune --volumes` y `docker volume prune` no saben qué es de este curso.**
> Borran los volúmenes sin uso de cualquier proyecto de la máquina. Para el laboratorio,
> `down -v` con el perfil es suficiente y no toca nada ajeno.

---

## 🧭 Cuándo usar qué

| Situación | Haz esto | Por qué |
|---|---|---|
| Empiezas una fase | `pull` y después `up -d --wait` con el perfil de la familia | la red falla aparte y `up` devuelve cuando el motor está listo |
| Un servicio no llega a healthy | `logs --tail 50` y después `ps -a` | el log dice por qué; `ps -a` dice si salió y con qué código |
| Sale con `Exited (137)` | `docker inspect … --format '{{.State.OOMKilled}}'` | 137 más `OOMKilled` es memoria, no un fallo del motor |
| `port is already allocated` | `docker ps --filter publish=PUERTO` | casi siempre es otro contenedor tuyo |
| Terminas la fase y la siguiente usa otra familia | `down` con el perfil | libera RAM y conserva los datos |
| Quieres empezar de cero | `down -v` con el perfil | volúmenes vacíos, datos regenerables con `a05` |
| Te quedas sin disco | `docker system df`, y después el comando más acotado de la tabla | no borrar lo de otros proyectos |
| Actualizaste Docker Desktop o el kernel | `docker info --format '{{.KernelVersion}}'` | MongoDB depende de esa versión |

---

## ⚠️ Advertencias

- **`down -v` no pide confirmación.** Los datos del curso se regeneran con el generador de
  [`a05`](a05-el-dominio-de-flota.md), así que no es grave, pero regenerar 1 M de filas lleva
  su rato.
- **Las mediciones de tiempo dependen de lo demás que tengas arriba.** En la sesión de
  laboratorio, con el daemon congestionado, Cassandra tardó 1190 s en estar healthy; sola,
  62 s. Antes de medir, `docker compose --profile "*" down` y solo el perfil que toca.
- **Un contenedor sano no es una base cargada.** `healthy` significa que el motor acepta
  conexiones, no que tenga datos: eso lo hace [`a05`](a05-el-dominio-de-flota.md).

---

## 📚 Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación de estas herramientas suele cubrir
> solo la última versión. Este apéndice se verificó con Docker Desktop 29.8.0 y Compose v5.5.1.

- **Docker Desktop para Mac** — https://docs.docker.com/desktop/setup/install/mac-install/ —
  instalación y ajustes de recursos.
- **Docker Engine en Linux** — https://docs.docker.com/engine/install/ — los repositorios
  oficiales por distribución.
- **Pasos posteriores en Linux** — https://docs.docker.com/engine/install/linux-postinstall/ —
  el grupo `docker` y lo que implica.
- **Docker Desktop con WSL2** — https://docs.docker.com/desktop/features/wsl/ — backend WSL2 y
  buenas prácticas de sistema de archivos.
- **Configuración de WSL** — https://learn.microsoft.com/windows/wsl/wsl-config — el archivo
  `.wslconfig`.
- **Referencia de `docker compose`** — https://docs.docker.com/reference/cli/docker/compose/ —
  `up --wait`, perfiles y `down -v`.
- **Podman Compose** — https://docs.podman.io/en/latest/markdown/podman-compose.1.html — qué
  proveedor usa y cómo se elige.
- **Colima** — https://github.com/abiosoft/colima — la alternativa a Docker Desktop en macOS.
- **SERVER-121912** — https://jira.mongodb.org/browse/SERVER-121912 — el fallo de MongoDB con
  los kernels 6.19 a 7.0.13.
- **El curso *Docker Legacy Node***, del mismo autor, como lectura sugerida y no como requisito:
  en particular su apéndice a10 (Docker Compose) y su fase 30 (troubleshooting).

**Orden sugerido:** tu plataforma antes de instalar nada; el ciclo en seis comandos la primera
vez que levantes un perfil; memoria antes de levantar dos familias a la vez; y limpiar cuando
`docker system df` empiece a preocuparte.

---

## 🧪 Ejercicios (8)

### 🟢 Ejercicio 1 — La prueba de que todo está en su sitio

Ejecuta los dos comandos de la sección *Lo que necesitas antes de empezar* y anota la versión del
kernel y la memoria total.

**Pregunta:** ¿ese kernel es el de tu sistema operativo o el de una VM? ¿Qué cambia, en tu
plataforma, cuando actualizas Docker?

### 🟢 Ejercicio 2 — El ciclo completo

Levanta el perfil `base` con `--wait`, entra con `exec` a `psql` y ejecuta `select version()`.
Después `down`, comprueba con `docker volume ls` que el volumen sigue ahí, y termina con `down -v`.

**Objetivo:** ver con tus propios ojos qué borra `down` y qué borra `down -v`.

### 🟢 Ejercicio 3 — `--wait` contra sin `--wait`

Levanta el perfil `columnar` **sin** `--wait` y, en cuanto `up` devuelva, ejecuta
`docker compose exec columnar cqlsh`.
Anota el error. Repite con `--wait`.

**Objetivo:** reconocer el error de conectarse a un motor que todavía no está listo, y
cuántos segundos tarda Cassandra en tu máquina.

### 🟡 Ejercicio 4 — Puerto ocupado

Levanta cualquier Postgres fuera del laboratorio en el 5432 —otro proyecto o un
`docker run -p 5432:5432`— y después el perfil `base`.

**Objetivo:** reproducir `port is already allocated`, encontrar al dueño con
`docker ps --filter publish=5432`, y salir cambiando **solo** el lado del host del mapeo.

### 🟡 Ejercicio 5 — La firma del OOM

Baja el límite de memoria del servicio `busqueda` por debajo de su heap —por ejemplo, 600 MB con
el heap de 512 MB— y levántalo.

**Objetivo:** llegar a `Exited (137)` y confirmar con `docker inspect` que `OOMKilled` es `true`.
Después, encontrar en tu máquina el límite más bajo con el que arranca.

### 🟡 Ejercicio 6 — Qué cabe en tu máquina

Levanta `base`, `busqueda` y `grafos` a la vez, espera un minuto y toma `docker stats
--no-stream`. Añade `columnar`.

**Pregunta:** ¿con cuántas familias JVM a la vez sigue tu máquina utilizable? Compara tus
números con la tabla de Memoria y explica la diferencia, si la hay.

### 🟠 Ejercicio 7 — Recuperar disco sin tocar lo ajeno

Ejecuta `docker system df` y decide qué borrarías para recuperar 5 GB **sin tocar nada que no sea
de este curso**.

**Objetivo:** escribir la lista de comandos, del más acotado al más amplio, y justificar por qué
no usas `docker volume prune`.

### 🟠 Ejercicio 8 — El kernel y MongoDB

Consulta la versión del kernel de tu entorno de contenedores y ubícala en la tabla de versiones de
[`a02`](a02-compose-de-la-ruta.md).

**Pregunta:** ¿qué versiones de MongoDB 8.0 arrancan en tu máquina hoy, y cuál sería la primera
que podrías usar si actualizaras a un kernel 7.0.14 o posterior?

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida: los archivos que describe los
> deja `a02` en el repositorio. Lo que salga de leerlo se commitea con el prefijo de la fase
> desde la que se llegó.
