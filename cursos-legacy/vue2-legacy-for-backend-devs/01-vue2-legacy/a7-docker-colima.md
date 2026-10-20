# 🐳 Apéndice 7 — Docker y Colima en Apple Silicon (consulta por plataforma)

## 🎯 Para qué sirve este apéndice

🔥 **Opcional por plataforma.** El curso se completa sin abrirlo. Resuelve una
situación concreta: **estás en un Mac con chip M y quieres que la Tiquetera
corra dentro de un contenedor**, sin dedicarle la mañana al runtime. Es la
continuación del [Apéndice 6](a6-arm64-m1.md): allá, la opción B para
`node-sass` dice "trabaja dentro de un contenedor"; esto es ese contenedor.

Lo primero, porque es la confusión de origen: aquí hay **dos preguntas
independientes** que todo el mundo mezcla en una. *Qué runtime* usas —Colima,
Docker Desktop u otro— y *para qué arquitectura* corren tus contenedores
—arm64 o amd64—. El runtime lo decide tu equipo o tu licencia; la arquitectura,
con qué necesitas tener paridad. Se combinan de las cuatro formas, y las
cuatro funcionan.

> 🧭 **Esta es la versión de bolsillo. El taller completo está aparte.**
> Este apéndice responde *"qué hago yo el lunes"* con un Mac de chip M. Si
> quieres entender **por qué** funciona —qué es un *image index* y cómo un tag
> contiene varias imágenes, qué hacen QEMU y Rosetta y cuánto cuesta cada uno,
> por qué `node_modules` no cruza de arquitectura—, eso vive en otro curso del
> mismo repositorio que este paquete, **Docker Legacy Node**
> (`cursos-contenedores-cloud-infra/docker-container-legacy`). Los capítulos que
> continúan lo de aquí son la **F21** (arquitecturas, OCI multi-platform y
> emulación), la **F22** (Apple Silicon y el zoológico de hosts) y la **F23**
> (estudios de caso y árbol de decisión); el devcontainer de este apéndice lo
> abre por dentro la **F19** (dev containers).

**Qué queda fuera:** la comparativa de runtimes (Podman, OrbStack y Lima se
nombran y no se comparan); `node-sass`, `node-gyp` y el Node del curso, que son
el [Apéndice 6](a6-arm64-m1.md); y lo básico de Docker —imagen, contenedor,
volumen, compose—, que es el Apéndice 1 del Curso 02,
[Docker mínimo](../02-complement-mongodb-backend/a01-docker.md).

---

## ⚖️ La decisión en una página

| Runtime | Contenedores arm64 (nativos) | Contenedores amd64 (traducidos) |
|---|---|---|
| **Colima** | Rápido, por terminal, software libre. **El camino por defecto** | En la misma VM, con `--platform linux/amd64` y Rosetta |
| **Docker Desktop** | Lo mismo, con interfaz gráfica. Licencia: pregúntala | Igual que en Colima. **Es con lo que se validó este curso** |

**El runtime lo decide tu organización, no tu gusto.** Docker Desktop trae
interfaz gráfica; Colima hace lo mismo desde la terminal y es software libre.
Lo que suele decidir no es técnico: **las condiciones de uso comercial de
Docker Desktop no son las de una herramienta libre**, y si aplican a tu empresa
lo responde tu organización, no un apéndice. Pregunta antes de instalarlo en
una máquina de trabajo.

**La arquitectura la decide con qué necesitas parecerte.** arm64 para
trabajar rápido; amd64 cuando algo no existe para arm64 o cuando necesitas
reproducir lo que corre en un servidor Intel. Y no es una decisión de todo o
nada: **se elige por contenedor**, no por máquina (sección 🧬).

> 🧭 **Si no quieres pensarlo:** Colima con arm64, Rosetta encendida para lo
> que necesite amd64, y el devcontainer de la sección 🧰.

---

## 🔁 Los dos Rosetta, que no son la misma pieza

**Rosetta 2, el de macOS.** Traduce programas de Intel para que corran en tu
Mac. Es lo que hace funcionar el **Node 14.21.3 x64** de la
[Fase 0](00-setup-hola-mundo.md). Vive en tu máquina, fuera de cualquier
contenedor.

**Rosetta para Linux.** Otra pieza, que corre **dentro de la máquina virtual**
del runtime y traduce procesos Linux de Intel. Es lo que hace que un contenedor
`linux/amd64` vaya razonablemente rápido en vez de arrastrarse bajo emulación
completa (QEMU). En Colima se enciende con `--vz-rosetta`; en Docker Desktop,
con su opción de usar Rosetta para la emulación x86_64/amd64.

Se llaman igual, hacen cosas parecidas en capas distintas, y **puedes tener una
sin la otra**: un contenedor arm64 no usa ninguna, y tu Node de la Fase 0 usa
la primera aunque nunca abras Docker.

> 📌 **Rosetta tiene fecha.** Apple anunció que Rosetta 2 deja de estar
> completa a partir de **macOS 28**. Eso toca a las dos piezas: los contenedores
> amd64 traducidos y el Node x64 de la Fase 0. Ninguna es urgente hoy; las dos
> conviene tenerlas anotadas. Verifica el anuncio vigente antes de apoyar en
> esa fecha una decisión de equipo.

---

## 🦙 Colima: un perfil arm64 con Rosetta

```bash
# Instalar (Homebrew); Colima trae la VM, el cliente docker va aparte.
# Si ya tienes Docker Desktop, ya tienes el cliente: instala solo colima
brew install colima docker

# Una VM arm64 con el framework de virtualización de Apple (vz), Rosetta
# para los contenedores amd64 y virtiofs para que los montajes no vayan lentos
colima start \
  --vm-type vz --vz-rosetta \
  --mount-type virtiofs \
  --cpus 4 --memory 8

# Comprobar que quedó como esperabas
colima status
docker info --format '{{.Name}} / {{.Architecture}} / {{.OperatingSystem}}'
```

Cuatro detalles con intención, sacados de `colima start --help` y de la
plantilla de configuración de Colima (`colima start --edit` la abre):

- **`--vm-type vz` y `--mount-type virtiofs`** ya son los valores por defecto
  en la 0.10.3, pero la plantilla de configuración todavía dice `qemu`, y las
  versiones anteriores usaban QEMU. Escríbelos igual: el comando queda
  diciendo lo que quieres, sin depender de la versión. `--vz-rosetta` sí hay
  que pedirlo, y **solo funciona con `vz`**.
- **`--mount-type virtiofs`** es el más rápido de los tres que ofrece, y solo
  existe con `vz`.
- **Los avisos de cambio de archivo no cruzan a la VM por defecto**
  (`mountInotify: false`, marcado como experimental). Por eso el devcontainer
  de la sección 🧰 le pide al dev server que pregunte por los archivos.
- **Un perfil que ya existe conserva lo suyo.** Si `colima start` encuentra
  un perfil creado antes, lo arranca con su configuración y descarta lo que no
  se puede cambiar
  (`'volume mount type' cannot be updated after initial setup, discarded`). Si
  ese perfil se creó con `--arch x86_64`, arranca con QEMU aunque diga `vz`, y
  con lima 2.x se cae con
  `guest agent binary could not be found for Linux-x86_64`. Bórralo
  (`colima delete`) o crea uno aparte con `-p tiquetera`.

Lo que debes ver al terminar:

```text
PROFILE      STATUS     ARCH       CPUS    MEMORY    DISK      RUNTIME
tiquetera    Running    aarch64    4       8GiB      100GiB    docker
colima-tiquetera / aarch64 / Ubuntu 24.04.4 LTS
```

> 📝 **Cómo se verificó.** Con Colima 0.10.3 y lima 2.2.1, en un Mac con chip
> M (macOS 26), con un perfil `-p tiquetera`: la VM arrancó `aarch64` y un
> contenedor `--platform linux/amd64` respondió `x64`. Dentro de la VM, el
> manejador `rosetta` está activo y el de QEMU (`qemu-x86_64`) desactivado: el
> proceso amd64 corre como `/mnt/lima-rosetta/rosetta /bin/sleep 20`. Los
> flags **cambian entre versiones**: compruébalos con `colima start --help`
> antes de copiarlos.

---

## 🧬 Contenedores amd64: por contenedor, no por máquina

Con Rosetta encendida en la VM, cualquier contenedor puede ser amd64 si se lo
pides. Es lo que hace falta en el curso en un solo lugar: la suite de la
**Fase 13 del Curso 02**, porque mongodb-memory-server no tiene `mongod` 4.4
para Linux arm64 ([Apéndice 6](a6-arm64-m1.md), sección 📥). Así se corrió para
este curso, con 6 pruebas en verde en 8 a 11 segundos en Docker Desktop,
contando la descarga del `mongod`, y en 7,6 segundos en Colima con `virtiofs`
y el `mongod` ya descargado (el `npm ci` tardó 27 s):

```bash
# Desde la carpeta del backend del Curso 02. El node_modules se instala
# dentro de un contenedor amd64: el de tu Mac no sirve aquí
docker run --rm --platform linux/amd64 -v "$PWD":/app -w /app node:14.21.3 npm ci
docker run --rm --platform linux/amd64 -v "$PWD":/app -w /app \
  node:14.21.3 node node_modules/.bin/jest --runInBand --ci
```

Sin `--platform`, en arm64, la misma suite muere en menos de un segundo con
`Error: Status Code is 403 (MongoDB's 404)`.

**¿Y una VM entera amd64?** Colima la permite (`--arch x86_64`), pero con QEMU:
Rosetta y `vz` solo virtualizan la arquitectura de tu Mac. Es emulación
completa de todo, incluido el kernel, y casi nunca hace falta: el `--platform`
por contenedor resuelve lo mismo más rápido. Resérvala para el día en que
necesites un Docker que **por defecto** construya y corra amd64.

---

## 🐋 Docker Desktop: lo que cambia

Todo lo de este apéndice funciona igual con Docker Desktop, y es el runtime
con el que **se validó el curso**: Docker Desktop 4.92.0 sobre un Mac de chip
M, con su configuración por defecto. Lo que cambia respecto de Colima:

- **El contexto se llama `desktop-linux`** (sección 🔀). `docker info` responde
  `docker-desktop / aarch64 / Docker Desktop`.
- **Rosetta y el sistema de archivos se configuran en Settings**, no con
  flags: el uso del framework de virtualización de Apple, Rosetta para la
  emulación amd64 y el modo de compartir archivos.
- **Los avisos de cambio de archivo sí cruzan.** En la prueba del curso, el
  dev server recompiló al tocar un archivo desde el Mac **con y sin**
  sondeo. Con Docker Desktop, `CHOKIDAR_USEPOLLING` sobra; se deja en el
  devcontainer porque no estorba y porque con Colima sí hace falta.
- **La licencia**, que es la pregunta de la sección ⚖️.

---

## 📦 Volúmenes: dónde vive `node_modules`

La sección que decide si un devcontainer se usa o se abandona el primer día.

**El problema.** Si montas la carpeta del proyecto en el contenedor y
`node_modules` vive en ella, cada archivo cruza la frontera entre macOS y la
VM, y `node_modules` son decenas de miles. En la prueba del curso, el
`npm ci` de la Fase 11 (39.330 archivos, 315 MB) dentro del devcontainer en
Docker Desktop tardó:

- con `node_modules` en un **volumen con nombre**: 24 s, 32 s y 21 s;
- con `node_modules` en la **carpeta montada**: 44 s, 1 min 30 s (borrando antes
  los archivos de la corrida anterior) y 49 s.

**El problema serio, que además rompe.** En la carpeta montada, `node_modules`
lo comparten tu Mac y el contenedor Linux, y tiene binarios atados a un
sistema y una arquitectura: el `deasync` que compila el contenedor arm64 es
`linux-arm64-node-14`, y el que pide tu Node de la Fase 0 es
`darwin-x64-node-14`. Instalas dentro, corres fuera, y revienta con un error
que no menciona ni el montaje ni la arquitectura.

**La solución es una línea:** que `node_modules` no esté en el montaje. Se
pone un volumen con nombre, que vive dentro de la VM, justo encima de esa ruta
(el `mounts` del `devcontainer.json` de la sección 🧰). Dos consecuencias: en
tu editor del Mac, `node_modules` **se ve vacío**, y `npm ci` se corre **dentro**
del contenedor. Las dos son correctas.

**El detalle que falta en casi todos los ejemplos copiados por ahí:** un
volumen nuevo, montado en una ruta que la imagen no tiene, nace con dueño
`root`. Si el contenedor trabaja con el usuario `node`, el primer `npm ci` falla:

```text
npm ERR! code EACCES
npm ERR! syscall mkdir
npm ERR! path /proj/node_modules/babel-core
npm ERR! Error: EACCES: permission denied, mkdir '/proj/node_modules/babel-core'
```

El arreglo habitual, `sudo chown` en el `postCreateCommand`, no sirve aquí:
`node:14.21.3-bullseye-slim` no trae `sudo` (`bash: line 1: sudo: command not found`).
El del Dockerfile de la sección 🧰 es otro: crear la carpeta en la imagen, con
dueño `node`. Un volumen vacío copia el dueño de la carpeta sobre la que se
monta la primera vez.

> ⚠️ **Elige un lado y quédate ahí.** Si corres `npm ci` en el Mac *y* dentro
> del contenedor sobre la misma carpeta, acabas con binarios de dos plataformas
> mezclados. Si tienes que cambiar de lado, el ritual del
> [Apéndice 6](a6-arm64-m1.md) (sección 🧹): borrar `node_modules` y `npm ci`.

---

## 🧰 Un devcontainer para la Tiquetera

> ⚠️ **Esto no es el Dockerfile de la API del Curso 02.** Aquel
> ([Docker mínimo](../02-complement-mongodb-backend/a01-docker.md)) empaqueta el
> backend para correrlo. Este es un ambiente **de desarrollo**, con compilador
> y Python, donde trabajas tú. Viven en carpetas distintas y no se mezclan.

Dos archivos en `.devcontainer/`, en la raíz de tu repositorio:

```dockerfile
# .devcontainer/Dockerfile
# Imagen de DESARROLLO, no de producción. Debian y no Alpine: deasync y
# node-sass compilan contra glibc.
FROM node:14.21.3-bullseye-slim

# Debian 11 salió de soporte en agosto de 2026 y sus paquetes de seguridad
# ya no están en deb.debian.org: apt tiene que ir al archivo histórico.
RUN printf '%s\n' \
      'deb http://archive.debian.org/debian bullseye main' \
      'deb http://archive.debian.org/debian bullseye-updates main' \
      'deb http://archive.debian.org/debian-security bullseye-security main' \
      > /etc/apt/sources.list

# Lo que node-gyp necesita para compilar dependencias nativas en arm64
# (Apéndice 6): python3 para deasync, del tronco; python2 para node-sass,
# de la ruta Q, que trae un node-gyp 3 que no acepta Python 3.
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 \
      python2 \
      make \
      g++ \
      git \
    && rm -rf /var/lib/apt/lists/*

# El volumen de node_modules se monta aquí. Si la carpeta ya existe en la
# imagen y es de 'node', el volumen nace con ese dueño; si no, nace de root
# y el primer npm ci falla con EACCES.
RUN mkdir -p /workspace/node_modules && chown -R node:node /workspace

# 'node' ya existe en la imagen y no es root: lo que crees en la carpeta
# montada queda a tu nombre en el Mac.
USER node
WORKDIR /workspace
```

```jsonc
// .devcontainer/devcontainer.json
{
  "name": "tiquetera-legacy (Vue 2)",
  "build": { "dockerfile": "Dockerfile" },

  // El repositorio se monta en /workspace, la carpeta que prepara el Dockerfile.
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind",
  "workspaceFolder": "/workspace",

  // node_modules fuera del bind mount: vive en un volumen dentro de la VM,
  // y sus binarios de Linux no se mezclan con los de tu Mac.
  "mounts": [
    "source=tiquetera-node-modules,target=/workspace/node_modules,type=volume"
  ],

  // 8080 Vue CLI, 8888 Stubby (F0), 3000 json-server (F3), 4000 socket.io (F8).
  "forwardPorts": [8080, 8888, 3000, 4000],

  // Los avisos de cambio de archivo no siempre cruzan del Mac a la VM
  // (en Colima, no por defecto): que el dev server pregunte por los archivos.
  "containerEnv": { "CHOKIDAR_USEPOLLING": "true" },

  "postCreateCommand": "npm ci",
  "remoteUser": "node"
}
```

**Detalles con intención.**

- **Debian 11 y `archive.debian.org`.** La imagen `node:14.21.3-bullseye-slim`
  viene con las fuentes de `deb.debian.org`, y desde que Debian 11 salió de
  soporte el `apt-get install` falla así:

  ```text
  E: Failed to fetch http://deb.debian.org/debian-security/pool/updates/main/g/glibc/libc6_2.31-13%2bdeb11u14_arm64.deb  404  Not Found
  ```

  El archivo histórico tiene los paquetes y no se va a mover. Sin
  actualizaciones de seguridad, sí: es una imagen de desarrollo para un stack
  de 2020, no algo que se expone.
- **`python2` además de `python3`.** Sin `python2`, el tronco instala y la
  ruta Q falla en `node-sass` (`Can't find Python executable "python"`). Con
  los dos, el `npm ci` de la ruta Q compila `node-sass` dentro del contenedor
  en 1 min 16 s ([Apéndice 6](a6-arm64-m1.md), sección 🎨).
- **Los cuatro puertos** son los del curso: el dev server de Vue CLI, Stubby
  de la Fase 0, json-server desde la Fase 3 y el servidor de sockets de la
  Fase 8. El dev server de Vue CLI 3 ya escucha en todas las interfaces; no
  hace falta `--host`.
- **El formato `devcontainer.json` es de VS Code**, aunque otras herramientas
  lo lean. Con la extensión *Dev Containers*, "Reopen in Container" construye la
  imagen, crea el volumen y corre `npm ci`.

> ⚠️ **No verificado por ejecución con VS Code.** Lo que se probó es la receta
> a mano de abajo, que es lo mismo que hace VS Code con esos dos archivos: la
> imagen, el volumen, `npm ci`, la suite de la Fase 11 (26 de 26 en verde dentro
> del contenedor) y los puertos.

### Sin VS Code: la receta a mano

```bash
# Desde la raíz del repositorio, una sola vez
docker build -t tiquetera-dev .devcontainer
docker volume create tiquetera-node-modules

# Cada día: un shell dentro del contenedor, con los puertos publicados
# solo en tu Mac (127.0.0.1), no en la red de la oficina
docker run -it --rm \
  -v "$PWD":/workspace \
  -v tiquetera-node-modules:/workspace/node_modules \
  -e CHOKIDAR_USEPOLLING=true \
  -p 127.0.0.1:8080:8080 -p 127.0.0.1:3000:3000 -p 127.0.0.1:4000:4000 -p 127.0.0.1:8888:8888 \
  tiquetera-dev bash
```

Ya dentro, `npm ci` la primera vez, y luego lo de cada fase. Con una salvedad
que muerde desde la Fase 3: **json-server escucha solo en `localhost`**, y
dentro de un contenedor eso es el propio contenedor. En la prueba del curso,
`npm run dev` levantó los tres servicios y desde el Mac respondieron el 8080 y
el 4000, y el 3000 no. La salida es correr el mock con `--host`, cada servicio
en su terminal (`docker exec -it <contenedor> bash` abre otra):

```bash
npm run mock -- --host 0.0.0.0
npm run sockets
npm run serve
```

Stubby (Fase 0) y el servidor de sockets (Fase 8) ya escuchan en todas las
interfaces.

> 💡 **Si versionas `.devcontainer/`**, es un cambio real en el repositorio, y
> la convención del curso deja abierto `apendice-a7` como tag opcional para
> poder volver a ese punto
> ([convención de git y tags](../00-convencion-de-git-y-tags.md)). Ningún paso
> del curso te lo pide.

---

## 🏗️ Construir para la arquitectura correcta

Hasta aquí, el contenedor era para trabajar. Cuando es para **desplegar** —la
imagen de la API del Curso 02—, la regla es otra: **la imagen tiene que ser de
la arquitectura de la máquina que la va a correr**, y esa máquina casi nunca
es tu Mac.

```bash
# De qué arquitectura es una imagen, de verdad
docker image inspect tiquetera-api --format '{{.Architecture}}'

# Construir para una arquitectura concreta, sin importar en qué Mac estés
docker build --platform linux/amd64 -t tiquetera-api .

# Correr puntualmente una imagen de otra arquitectura
docker run --rm --platform linux/amd64 tiquetera-api node -p process.arch
```

Desde la carpeta del backend, el primer `docker build` sin `--platform` da una
imagen `arm64`; con `--platform linux/amd64`, una `amd64`, y el último comando
responde `x64`. Como el backend del Curso 02 es JavaScript puro (`bcryptjs`, no
`bcrypt`), las dos construyen sin compilar nada.

**Lo que ves en tu Mac no es lo que ve el servidor.** Si corres la imagen
amd64 sin `--platform`, Docker te avisa y la corre igual, traducida:

```text
WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested
```

Un servidor amd64 sin emulación que recibe tu imagen `arm64` no avisa: no
arranca, con `exec format error`. Esa segunda mitad no se puede reproducir en
un Mac con Rosetta, que corre las dos arquitecturas; en el servidor, la
comprobación es el `docker image inspect` de arriba.

Y cuando la misma imagen tiene que servir para las dos arquitecturas:

```bash
# Una imagen multiarquitectura: un tag, dos variantes, y cada máquina
# descarga la suya. Necesita un registry: el almacén local guarda una sola
docker buildx build --platform linux/amd64,linux/arm64 \
  -t registry.interno/tiquetera/api:1.0.0 --push .
```

> ⚠️ **No verificado por ejecución.** El `buildx --push` necesita un registry,
> y el curso no tiene ninguno. El resto de esta sección se corrió tal cual
> sobre la imagen de la API.

---

## 🔀 Cambiar de runtime sin romper nada

Docker Desktop y cada perfil de Colima son **máquinas virtuales
independientes**: las imágenes, los volúmenes con nombre y la caché de build
viven dentro de una y no se ven desde la otra. Cambiar de runtime no borra
nada, pero lo esconde, y el síntoma es *"mi imagen desapareció"*.

```bash
# Qué contextos hay y cuál está activo (el del asterisco)
docker context ls

# Cambiar; los nombres salen de la lista de arriba
docker context use colima
docker context use desktop-linux

# La confirmación que importa: a qué VM le hablas y de qué arquitectura es
docker info --format '{{.Name}} / {{.Architecture}} / {{.OperatingSystem}}'
```

**Qué se queda atrás al cambiar, en la Tiquetera:**

- **Las imágenes** (`tiquetera-dev`, la de la API): se reconstruyen en
  minutos.
- **El volumen `tiquetera-node-modules`**: en la VM nueva nace vacío, y un
  `npm ci` lo vuelve a llenar. Es lo correcto.
- **Los datos de Mongo del Curso 02 no**, y conviene saber por qué: el compose
  de la Fase 14 los guarda en `./mongo-data`, una carpeta **de tu disco**
  montada en el contenedor, no un volumen. Sobreviven al cambio de runtime,
  y también a un `colima delete`. Si alguna vez los pasas a un volumen con
  nombre, eso cambia.

```bash
# Los perfiles de Colima, y cuál está corriendo
colima list

# Apagar sin destruir (conserva imágenes y volúmenes)
colima stop

# Borrar la VM y su configuración. En la 0.10.3, el disco con las imágenes
# y los volúmenes se conserva para el próximo start con ese nombre
colima delete

# Borrar también ese disco. Esto SÍ borra todo
colima delete --data
```

En la prueba del curso, después de un `colima delete` quedaron 1,5 GB en
`~/.colima/_lima/_disks/`, y se fueron con `colima delete --data`.

> 💡 **Antes de `colima delete`, mira qué volúmenes hay** (`docker volume ls`,
> con el contexto correcto). Las imágenes se reconstruyen; un volumen con datos,
> no.

---

## 🧭 Cuándo usar qué

| Situación | Qué haces |
|---|---|
| Empiezas en un Mac con chip M y quieres contenedor | Colima con `vz` y Rosetta (🦙), y el devcontainer (🧰) |
| Tu empresa ya tiene Docker Desktop | Úsalo: todo lo de aquí funciona igual (🐋) |
| La suite del Curso 02 da `403 (MongoDB's 404)` | `--platform linux/amd64` para esa suite (🧬) |
| Haces la ruta Q dentro del contenedor | El devcontainer ya trae `python2` para `node-sass` (🧰) |
| `npm ci` dentro del contenedor tarda una eternidad | `node_modules` está en el montaje: volumen con nombre (📦) |
| Construyes la imagen de la API para un servidor | `--platform linux/amd64` y `docker image inspect` (🏗️) |
| Cambiaste de runtime y falta algo | `docker context ls`: está en la otra VM (🔀) |
| Alguien propone Podman, OrbStack o Lima | Fuera del alcance: existen y funcionan |

---

## ⚠️ Diagnóstico rápido

| Lo que ves | Qué es |
|---|---|
| `E: Failed to fetch http://deb.debian.org/debian-security/… 404  Not Found` al construir | Debian 11 fuera de soporte: fuentes en `archive.debian.org` (🧰) |
| `npm ERR! code EACCES` … `mkdir '…/node_modules/…'` | El volumen nació de `root`: la carpeta tiene que existir en la imagen (📦) |
| `bash: line 1: sudo: command not found` | La imagen slim no trae `sudo`: no lo uses en el `postCreateCommand` (📦) |
| `Can't find Python executable "python"` dentro del contenedor | Falta `python2` para `node-sass` (🧰) |
| `Status Code is 403 (MongoDB's 404)` | Contenedor arm64 sin `mongod` 4.4: `--platform linux/amd64` (🧬) |
| El 8080 abre y el 3000 no | json-server escucha en `localhost`: `npm run mock -- --host 0.0.0.0` (🧰) |
| Guardas un archivo y la página no recarga | Los avisos de cambio no cruzan a la VM: `CHOKIDAR_USEPOLLING=true` (🦙, 🧰) |
| `WARNING: The requested image's platform (linux/amd64) does not match…` | Corres una imagen amd64 sin pedirlo; funciona traducida (🏗️) |
| `exec format error` en el servidor | Le mandaste una imagen de otra arquitectura (🏗️) |
| "Mi imagen desapareció" | Estás en otro contexto (🔀) |
| `'volume mount type' cannot be updated after initial setup, discarded` | Colima arrancó un perfil viejo con su configuración (🦙) |
| `guest agent binary could not be found for Linux-x86_64` | Perfil de Colima con `--arch x86_64`: bórralo o usa otro perfil (🦙) |
| `node_modules` vacío en tu editor | Es el volumen con nombre, y es correcto (📦) |

---

## 🧪 Ejercicios (15) — todos opcionales

> Los apéndices son material de consulta y práctica libre. Haz los que te
> sirvan, cuando te sirvan. Los marcados 🍎 necesitan un Mac con chip M; los
> demás funcionan con Docker en cualquier máquina.

**🟢 Fácil (1–4)**

1. Corre `docker info --format '{{.Name}} / {{.Architecture}} / {{.OperatingSystem}}'`
   y `docker run --rm node:14.21.3 uname -m`. Explica en una línea por qué el
   segundo dice `aarch64` en un Mac con chip M y `x86_64` en un PC.
2. Repite el segundo comando con `--platform linux/amd64`. Anota la respuesta y
   explica qué pieza hizo posible que corriera.
3. Construye la imagen del devcontainer (`docker build -t tiquetera-dev .devcontainer`)
   y confirma su arquitectura con `docker image inspect`.
4. 🍎 Con Colima, abre la configuración (`colima start --edit`) y encuentra
   `vmType`, `rosetta`, `mountType` y `mountInotify`. Anota sus valores y si
   coinciden con los que pide la sección 🦙.

**🟡 Intermedio (5–9)**

5. Crea un volumen nuevo, móntalo en una ruta que la imagen no tenga y corre
   `npm ci` como `node`. Copia el error. Después móntalo en
   `/workspace/node_modules` y explica por qué ahí sí funciona.
6. Cronometra el `npm ci` de la Fase 11 dentro del devcontainer, con
   `node_modules` en el volumen y en la carpeta montada. Compara tus cifras con
   las de la sección 📦 y anota tu runtime y tu Mac.
7. **Diagnóstico.** Levanta `npm run dev` dentro del contenedor y prueba los
   tres puertos desde tu navegador. Encuentra el que no responde y demuestra
   desde dentro (`curl` o `node`) que el servicio está vivo.
8. Arregla el ejercicio 7 con `--host 0.0.0.0` y confirma con
   `cat /proc/net/tcp` dentro del contenedor que cambió la dirección en la que
   escucha el puerto `0BB8` (3000 en hexadecimal).
9. Construye la imagen de la API del Curso 02 sin `--platform` y con
   `--platform linux/amd64`, e inspecciona su arquitectura después de cada una.

**🟠 Difícil (10–13)**

10. **Diagnóstico.** Quita `python2` del Dockerfile, reconstruye y corre
    `npm ci` de la ruta Q dentro. Copia el error y encuentra la línea que te
    dice qué `node-gyp` lo pidió.
11. Corre la suite de la Fase 13 del Curso 02 en un contenedor arm64 y en uno
    amd64. Anota los dos resultados y el tiempo de cada uno.
12. **Rompe a propósito.** Instala `node_modules` dentro del contenedor **en la
    carpeta montada** y corre `npm run test:unit` en tu Mac. Anota el error y
    aplica el ritual del [Apéndice 6](a6-arm64-m1.md) para arreglarlo.
13. 🍎 Toca un archivo de `src/` con el dev server corriendo dentro del
    contenedor, primero sin `CHOKIDAR_USEPOLLING` y después con él. Anota en qué
    caso recarga, con tu runtime. ¿Coincide con lo que dice la sección 🐋?

**🔴 Muy difícil (14–15)**

14. 🍎 Ten Colima y Docker Desktop instalados a la vez. Construye
    `tiquetera-dev` en uno, cambia de contexto y demuestra que no está en el
    otro. Escribe en tres líneas qué le contestas a un compañero que dice "se me
    borraron las imágenes".
15. 🍎 Cronometra `npm ci` y `npm run build` de la Fase 11 en tres ambientes:
    tu Mac con el Node x64 de la Fase 0, el devcontainer arm64 y un contenedor
    `--platform linux/amd64`. Publica tus seis cifras con las condiciones: este
    apéndice no trae el costo de cada camino porque solo midió `npm ci` en uno.

---

## 📚 Referencias

**Documentación oficial**

- Colima, instalación, perfiles y Rosetta: https://github.com/abiosoft/colima —
  ⚠️ los flags cambian entre versiones; la fuente que no envejece es
  `colima start --help`.
- Colima, preguntas frecuentes: https://github.com/abiosoft/colima/blob/main/docs/FAQ.md
- Docker Desktop en macOS: https://docs.docker.com/desktop/setup/install/mac-install/
- Imágenes multiarquitectura con `buildx`: https://docs.docker.com/build/building/multi-platform/
- Contextos de Docker: https://docs.docker.com/engine/manage-resources/contexts/
- Volúmenes con nombre y montajes: https://docs.docker.com/engine/storage/volumes/
- Referencia de `devcontainer.json`: https://containers.dev/implementors/json_reference/
- Dev Containers en VS Code: https://code.visualstudio.com/docs/devcontainers/containers
- json-server 0.16, la opción `--host`: https://github.com/typicode/json-server/tree/v0.16.3
- Debian, el archivo de versiones viejas: https://archive.debian.org/debian/
- Rosetta 2 en macOS: https://support.apple.com/en-us/102527

> ⚠️ Los enlaces y contenidos pueden haber cambiado; verifícalos. Casi todo lo
> que encuentres sobre "Docker en M1" es de 2021–2022, cuando muchas imágenes no
> tenían variante arm64. Fíjate en la fecha antes de copiar nada.

**Orden de lectura sugerido:** si estás empezando, ⚖️ y 🦙 (o 🐋). Si vas a
trabajar dentro del contenedor, 📦 **antes** que 🧰: el devcontainer sin el
volumen se abandona el primer día. Si te llegó un `403` o un `exec format error`,
🧬 y 🏗️. Si algo desapareció, 🔀.
