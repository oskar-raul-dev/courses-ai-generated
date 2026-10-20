# 📎 Apéndice A13 — 🔥 Docker + Colima en Apple Silicon

> Tutorial Angular 8 — Laboratorio clínico · Consulta rápida · **2h**
> Usado por: Fases 0, 13 y 14 · Versión cubierta: la CLI de Docker y el formato de imagen, que son lo estable. **Las versiones de Colima y Docker Desktop no se fijan a propósito** (§⚠️)
> Estado: 🔥 **Opcional por plataforma.** El curso se completa sin abrir este apéndice

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve una situación muy concreta: **estás en un Mac con chip M y necesitas que el proyecto corra sin dedicarle la mañana al runtime de contenedores.**

Es la continuación natural del **Apéndice A12**: allá, la opción B de su §3 dice *"deja de pelear con tu máquina y métete en un contenedor"*. Esto es ese contenedor.

Y lo primero, porque es la confusión de origen: **aquí hay dos preguntas independientes que todo el mundo mezcla en una.** *Qué runtime* usas —Docker Desktop, Colima u otro— y *para qué arquitectura* corren tus contenedores —arm64 o amd64—. Son ejes distintos, con dueños distintos: el runtime lo decide tu equipo o tu licencia, la arquitectura la decide con qué necesitas tener paridad. Se pueden combinar de las cuatro formas y las cuatro funcionan.

> 🧰 **Esto es la versión de bolsillo. El taller completo está aparte.**
> Este apéndice responde *"qué hago yo el lunes"* en un Mac con chip M, y con eso te
> desbloquea. Si lo que quieres es entender **por qué** funciona —qué es un image index y
> cómo un tag contiene varias imágenes, qué hace exactamente QEMU frente a Rosetta y cuánto
> cuesta cada uno medido, o por qué `node_modules` no puede cruzar de arquitectura—, eso vive
> en un curso propio de este repositorio: **[Docker Legacy Node](../../cursos-contenedores-cloud-infra/docker-container-legacy/README.md)**.
>
> Los tres capítulos que continúan lo de aquí son
> **[F21 — Arquitecturas, OCI multi-platform y emulación](../../cursos-contenedores-cloud-infra/docker-container-legacy/21-arquitecturas-y-emulacion.md)**,
> **[F22 — Apple Silicon y el zoológico de hosts](../../cursos-contenedores-cloud-infra/docker-container-legacy/22-apple-silicon-y-hosts.md)** y
> **[F23 — Estudios de caso y árbol de decisión](../../cursos-contenedores-cloud-infra/docker-container-legacy/23-estudios-de-caso-multiplataforma.md)**;
> el devcontainer de §6 lo abre por dentro **[F19](../../cursos-contenedores-cloud-infra/docker-container-legacy/19-dev-containers.md)**.
> Y si nunca has usado Docker, su **Parte I** lo enseña desde `docker --version` sin dar nada
> por sabido: **[índice del curso](../../cursos-contenedores-cloud-infra/docker-container-legacy/0-programa-del-curso.md)**.

**Qué queda fuera:** la **comparativa exhaustiva de runtimes** —Podman, OrbStack, Lima y compañía se nombran en una línea y no se comparan: este apéndice responde "qué hago yo el lunes", no "cuál es mejor"—; el `Dockerfile` de dos etapas, el `nginx.conf` y el `entrypoint.sh` del proyecto, que son de la **Fase 13 §5.6-5.8** y **no son los de acá** (§6); `node-sass`, `node-gyp` y el Node del curso, que son el **Apéndice A12**; kind y el cluster local, que son la **Fase 14**; y por qué se compila sobre Debian y no sobre Alpine, que es del **A03 §9**.

---

## Índice

- [1. La decisión en una página](#1-la-decisión-en-una-página)
- [2. Los dos Rosetta, que no son la misma pieza](#2-los-dos-rosetta-que-no-son-la-misma-pieza)
- [3. Perfil arm64 nativo](#3-perfil-arm64-nativo)
- [4. amd64: por contenedor, no por máquina](#4-amd64-por-contenedor-no-por-máquina)
- [5. Volúmenes: dónde vive `node_modules`](#5-volúmenes-dónde-vive-node_modules)
- [6. Un devcontainer para este proyecto](#6-un-devcontainer-para-este-proyecto)
- [7. Construir para la arquitectura correcta](#7-construir-para-la-arquitectura-correcta)
- [8. Cambiar de runtime sin romper nada](#8-cambiar-de-runtime-sin-romper-nada)
- [9. 🩺 Diagnóstico por síntoma](#9--diagnóstico-por-síntoma)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios (6)](#-ejercicios-6)

---

## 1. La decisión en una página

Dos ejes, cuatro casillas, y ninguna es "la correcta" en abstracto:

```
                     ARQUITECTURA DE LOS CONTENEDORES
                  arm64 (nativo)          amd64 (traducido)
              ┌────────────────────────┬────────────────────────┐
   Docker     │ Rapido, sin sorpresas  │ Paridad con PROD.      │
   Desktop    │ de rendimiento.        │ Mas lento. Y con       │
              │ Interfaz grafica.      │ fecha de caducidad     │
              │ Licencia: preguntala   │ (§2, §4)               │
              ├────────────────────────┼────────────────────────┤
   Colima     │ Lo mismo, por CLI      │ Lo mismo, en la misma  │
              │ y sin licencia         │ VM arm64: Rosetta y    │
              │ comercial. El default  │ --platform linux/amd64 │
              │ razonable hoy          │ por contenedor (§4)    │
              └────────────────────────┴────────────────────────┘
```

**El eje del runtime lo decide tu organización, no tu gusto.** Docker Desktop trae interfaz gráfica y una experiencia más pulida; Colima hace lo mismo desde la terminal, es software libre y arranca más rápido. La diferencia que suele decidir no es técnica: **las condiciones de uso comercial de Docker Desktop no son las de una herramienta libre**, y qué aplica a tu empresa lo responde tu organización —no un apéndice, y menos uno escrito hace meses—. Pregunta antes de instalarlo en una máquina de trabajo.

**El eje de la arquitectura lo decide con qué necesitas parecerte.** arm64 si lo que quieres es trabajar rápido (§3); amd64 si necesitas reproducir exactamente lo que corre en producción (§4). Y no es una elección de todo o nada: con Rosetta encendida en la máquina virtual, **la arquitectura se elige por contenedor, no por máquina**.

> 🧭 **La regla por defecto, si no quieres pensarlo:** **Colima con una VM arm64 y Rosetta encendida.** Es rápido, no arrastra licencia y cubre el 90% del trabajo del curso. El día que algo necesite amd64 —una imagen sin variante arm64, una diferencia con producción—, se lo pides a ese contenedor con `--platform` (§4), sin tocar la VM ni tirar lo que ya tienes.

Y una tercera cosa que **no** es una decisión, aunque lo parezca: si vas a meterte en un contenedor *para desarrollar* (§6) o solo para *construir la imagen* de la **Fase 13**. Son usos distintos del mismo runtime y no compiten: puedes hacer las dos, y la mayoría de la gente empieza por la segunda porque es la que ya pide el curso.

---

## 2. Los dos Rosetta, que no son la misma pieza

Sección corta y necesaria, porque el nombre se repite y confunde a todo el mundo.

**Rosetta 2, el de macOS.** Traduce binarios de Intel para que corran en tu Mac con chip M. Es lo que hace funcionar el **Node 14.21.3 del curso**, que es un binario x64 (**A03 §1.2**, **A12 §1**). Vive en tu máquina, fuera de cualquier contenedor.

**Rosetta para Linux.** Es otra pieza, que corre **dentro de la máquina virtual** del runtime de contenedores y traduce procesos x86 de Linux. Es lo que hace que una imagen `amd64` vaya razonablemente rápida en vez de arrastrarse bajo emulación completa (QEMU). En Colima se enciende con `--vm-type vz --vz-rosetta`; en Docker Desktop, con la opción de Settings que usa Rosetta para la emulación x86_64/amd64. Y solo existe en una VM **de la arquitectura de tu Mac**: Rosetta traduce procesos x86 *dentro* de una VM arm64, no convierte la VM en x86 (§4).

Se llaman igual, hacen cosas parecidas en capas distintas, y **puedes tener una sin la otra**: un contenedor arm64 nativo no usa ninguna de las dos, y tu Node del curso usa la primera aunque nunca abras Docker.

> ⚠️ **Rosetta tiene fecha, y es reciente.** Apple mantiene Rosetta 2 completo en **macOS 27** y **lo retira en gran parte a partir de macOS 28**, conservando solo un subconjunto pensado para juegos antiguos; desde macOS 26.4 el sistema ya avisa al abrir una aplicación que lo necesita. **Verifica el anuncio vigente antes de apoyar una decisión de equipo en esta fecha** — es un dato que se mueve y que este apéndice no puede garantizar en el tiempo.
>
> Lo que importa no es la fecha exacta sino la forma del problema, y esa no cambia: **el camino de la traducción tiene vencimiento y el nativo no.** Eso afecta a las dos piezas de arriba, así que toca dos decisiones de este curso: los contenedores amd64 (§4) y, más de fondo, el Node 14 bajo Rosetta que el curso fija para Apple Silicon (**A03 §1.2**). Ninguna de las dos es urgente hoy; las dos conviene tenerlas anotadas.

---

## 3. Perfil arm64 nativo

Es el default razonable y el que deberías intentar primero.

```bash
# Instalar (Homebrew). Colima trae la VM; el cliente docker va aparte. Si ya
# tienes Docker Desktop, ya tienes el cliente: instala solo colima.
brew install colima docker

# Una VM arm64 con recursos suficientes para compilar Angular sin sufrir.
# --vz-rosetta deja lista la traducción para los contenedores amd64 (§4).
# --mount-type virtiofs es lo que hace que los archivos montados no vayan
# lentos: es la parte que más se nota en el día a día (§5).
colima start \
  --arch aarch64 \
  --vm-type vz --vz-rosetta \
  --cpus 4 --memory 8 --disk 60 \
  --mount-type virtiofs

# Comprobar que quedó como esperabas: aarch64.
colima status
docker info --format '{{.Name}} / {{.Architecture}} / {{.OperatingSystem}}'
```

Cuatro detalles con intención, sacados de `colima start --help` y de la plantilla de configuración de Colima (`colima start --edit` la abre):

- **`--vm-type vz` y `--mount-type virtiofs`** ya son los valores por defecto en Colima 0.10.3, pero la plantilla de configuración todavía dice `qemu`, y las versiones anteriores usaban QEMU. Escríbelos igual: el comando queda diciendo lo que quieres, sin depender de la versión. `--vz-rosetta` sí hay que pedirlo, y **solo funciona con `vz`**.
- **`--cpus`**, en plural, es el nombre que lista `--help`. `--cpu` todavía se acepta, pero no aparece.
- **Los avisos de cambio de archivo no cruzan a la VM por defecto** (`mountInotify: false`, marcado como experimental). Por eso el `ng serve` de §6 lleva `--poll`.
- **Un perfil que ya existe conserva lo suyo.** Si `colima start` encuentra un perfil creado antes, lo arranca con su configuración y descarta lo que no se puede cambiar (`'volume mount type' cannot be updated after initial setup, discarded`). Para empezar limpio, bórralo (§8) o crea uno aparte con `-p clinical-lab`.

> ⚠️ Los nombres exactos de los flags de Colima cambian entre versiones. **Comprueba los tuyos con `colima start --help`** en vez de copiar de memoria: es la única fuente que no envejece, y es el mismo criterio que este curso aplica con `kubectl` (**A09**) y con `ng update` (**A10**).

> 📝 **Cómo se verificó.** Con Colima 0.10.3 y lima 2.2.1, en un Mac con chip M (macOS 26), con un perfil aparte creado con estos flags (`--arch` y `--disk` en sus valores por defecto): la VM arrancó `aarch64` (Ubuntu 24.04.4) y un contenedor `--platform linux/amd64` con Node 14.21.3 respondió `x64`. Dentro de la VM, el manejador `rosetta` está activo y el de QEMU (`qemu-x86_64`) desactivado. El devcontainer de §6 y los tiempos de §4 se midieron con Docker Desktop 4.92.0 en el mismo Mac, que corre la misma VM arm64 con Rosetta.

**Qué ganas.** Velocidad real, sin capa de traducción, y un consumo de batería civilizado. Para el trabajo del curso —compilar Angular, levantar json-server, construir la imagen de la Fase 13 y probarla— es la opción cómoda.

**Qué rompe, y son dos cosas concretas:**

**Una imagen sin variante arm64.** Todavía existen, sobre todo entre las viejas y las de nicho. El síntoma es que la imagen ni siquiera se descarga porque no hay manifiesto para tu plataforma, o que corre con el `WARNING` de plataforma de §7, traducida por Rosetta. La salida rápida es forzar la otra arquitectura solo para esa imagen (§7); la salida buena es buscar si hay una variante nativa. Las imágenes del curso —`node:14-bullseye-slim` y `nginx:stable-alpine` de la **Fase 13 §5.6**— sí tienen arm64.

**Las dependencias nativas de Node.** Dentro de un contenedor arm64, tu Node es **arm64 de verdad**, no x64 bajo Rosetta. Y ahí `node-sass` vuelve a no tener binario precompilado, que es exactamente el problema de **A12 §2**: el `npm ci` pide `linux-arm64-83_binding.node`, recibe un `404` y se pone a compilar. Es el detalle que sorprende: *"me metí al contenedor para escapar de `node-sass` y me lo encontré igual"*. Hay tres salidas. La que trae el curso es el devcontainer de §6, que ya tiene `python2` y el compilador, y lo compila solo: en la prueba del curso, el `npm ci` completo tardó 1 min 29 s. Las otras dos son un contenedor amd64, que descarga el binario de Intel (§4), y Dart Sass, que no compila nada (**A12 §3**).

> 🧠 **La regla que resume las dos:** **meterte en un contenedor no cambia el problema de arquitectura, cambia dónde ocurre.** Lo que gana el contenedor es que ese "dónde" es reproducible, desechable e idéntico para todo el equipo — no que el problema desaparezca.

---

## 4. amd64: por contenedor, no por máquina

Con Rosetta encendida en la VM arm64 de §3, cualquier contenedor puede ser amd64 si se lo pides. No hace falta otra VM ni otro perfil:

```bash
# Un contenedor amd64 dentro de la VM arm64. Responde x64: es un Node de
# Intel, traducido por Rosetta para Linux (§2).
docker run --rm --platform linux/amd64 node:14.21.3-bullseye-slim node -p process.arch

# Y una imagen entera, para construir y correr como en producción (§7).
docker build --platform linux/amd64 -t clinical-lab-dev:amd64 .devcontainer
```

**Cuándo lo necesitas de verdad.** Solo por una razón: **paridad**. Si producción corre en `linux/amd64` —que es lo normal— y estás persiguiendo un bug que solo aparece allá, tu contenedor tiene que dejar de ser especial. También cuando una dependencia nativa no tiene binario arm64 y no quieres compilarla (§3): en amd64, `node-sass` descarga su `linux-x64-83` y no compila nada. Si lo que quieres es el devcontainer entero en amd64 con VS Code, la receta está escrita y probada en el **Apéndice A14**; funciona igual sobre Colima.

**Cuándo no.** Para el trabajo diario. La traducción se paga en todo lo que hace la CPU. En la prueba del curso, con el devcontainer de §6 sobre el mismo Mac y una sola corrida de cada cosa:

| Paso | arm64 nativo | amd64 traducido |
|---|---|---|
| `npm ci` | 1 min 29 s (compilando `node-sass`) | 1 min 5 s (binario descargado) |
| `ng build` | 15 s | 1 min 13 s |
| `ng test` (3 pruebas) | 7 s | 20 s |

El `npm ci` es la excepción que confirma la regla: amd64 gana porque se ahorra la compilación, no porque corra más rápido. En lo que repites cien veces al día —build y test—, la traducción cuesta entre tres y cinco veces más.

**Y el costo que no se ve:** el amd64 depende de la traducción, y la traducción tiene vencimiento (§2). Montar el flujo de trabajo del equipo entero encima de ella es construir sobre algo con fecha. Como herramienta de diagnóstico puntual es perfecta; como ambiente por defecto, conviene saber lo que se está eligiendo.

**¿Y una VM entera amd64?** Colima la permite (`--arch x86_64`), pero **con QEMU**: `vz` y Rosetta solo virtualizan la arquitectura de tu Mac. Es emulación completa de todo, kernel incluido, y casi nunca hace falta: el `--platform` por contenedor resuelve lo mismo más rápido. Resérvala para el día en que necesites un Docker que **por defecto** construya y corra amd64, en un perfil aparte (`-p`) y sin `--vm-type vz` ni `--vz-rosetta`.

> ⚠️ **`--arch x86_64` con `--vm-type vz --vz-rosetta` no existe como combinación**, aunque Colima la acepte al crear el perfil. Un perfil creado así arranca con QEMU aunque su configuración diga `vz`, y con lima 2.x se cae con `guest agent binary could not be found for Linux-x86_64`. Si lo tienes —versiones anteriores de este apéndice lo proponían como perfil `amd64`—, bórralo con `colima delete -p amd64` (§8) y usa el `--platform` de arriba.

---

## 5. Volúmenes: dónde vive `node_modules`

Esta es la sección que decide si un devcontainer se usa o se abandona el primer día.

**El problema.** Cuando montas la carpeta del proyecto dentro del contenedor, cada lectura de archivo cruza la frontera entre macOS y la máquina virtual. Con miles de archivos pequeños —y `node_modules` son decenas de miles— eso se nota muchísimo: instalaciones eternas y builds que tardan el doble. `virtiofs` mejora bastante la situación frente a las opciones anteriores y **no la elimina**.

**El problema serio, que además rompe.** Si `node_modules` vive en la carpeta montada, esa carpeta la comparten **tu Mac y el contenedor Linux**. Y ahí aplica sin matices la advertencia central de **A03 §9**: `node_modules` contiene binarios atados a un sistema, una arquitectura y una versión de Node. Instalas desde el contenedor, corres `npm start` en el Mac, y revienta. O al revés. Y el error no menciona ni el volumen ni la arquitectura.

**La solución, que es una línea de configuración:** que `node_modules` **no** esté en el bind mount. Se monta un volumen con nombre —gestionado por Docker, que vive dentro de la VM— justo encima de esa ruta:

```jsonc
// Fragmento de .devcontainer/devcontainer.json (el archivo completo está en §6)
"mounts": [
  // node_modules vive DENTRO de la VM, no en el disco del Mac. Dos efectos:
  // el npm install va mucho más rápido, y los binarios nativos de Linux dejan
  // de mezclarse con los de macOS. Es la aplicación directa de A03 §9.
  "source=lab-node-modules,target=/workspace/node_modules,type=volume"
]
```

**La consecuencia que hay que tener presente:** con ese montaje, `node_modules` **desaparece de la vista de tu editor en el Mac** —está dentro de la VM— y el `npm install` hay que correrlo **dentro** del contenedor. Eso es lo correcto y a la vez es lo que confunde el primer día: el proyecto se ve sin dependencias desde fuera y funciona perfectamente desde dentro.

**El detalle que falta en casi todos los ejemplos copiados por ahí:** un volumen nuevo, montado en una ruta que la imagen no tiene, nace con dueño `root`. Si el contenedor trabaja con el usuario `node`, el primer `npm ci` falla:

```text
npm ERR! code EACCES
npm ERR! syscall mkdir
npm ERR! path /proj/node_modules/express
npm ERR! Error: EACCES: permission denied, mkdir '/proj/node_modules/express'
```

El arreglo habitual, `sudo chown` en el `postCreateCommand`, no sirve aquí: `node:14.21.3-bullseye-slim` no trae `sudo` (`bash: line 1: sudo: command not found`). El del Dockerfile de §6 es otro: crear la carpeta en la imagen, con dueño `node`. Un volumen vacío copia el dueño de la carpeta sobre la que se monta la primera vez.

> ⚠️ **Y el reverso, que es la trampa real:** si en algún momento corres `npm install` en el Mac *y también* dentro del contenedor sobre la misma carpeta montada, acabas con binarios de dos plataformas mezclados y errores que no se parecen a su causa. **Elige un lado y quédate ahí.** Si tienes que cambiar, el ritual es el de **A12 §7**: borrar `node_modules` y reinstalar desde el lockfile.

---

## 6. Un devcontainer para este proyecto

> 🧭 **Este devcontainer es arm64 y funciona igual en Colima y en Docker Desktop.** Si lo que necesitas es el ambiente entero en amd64, con VS Code, la receta es el **Apéndice A14**, con su devcontainer en `.devcontainer/amd64/`. Los dos conviven en el mismo repositorio.

> ⚠️ **Esto NO es el `Dockerfile` de la Fase 13.** Aquel compila la aplicación y la sirve con nginx: es el artefacto que va a producción, y no lleva Node en su etapa final (**Fase 13 §5.6**). Este es un ambiente **de desarrollo**, con Node, Python y las build tools, donde tú trabajas. Viven en carpetas distintas, se construyen por separado y confundirlos produce imágenes de producción con medio compilador dentro.

Dos archivos en `.devcontainer/`, en la raíz del repositorio:

```dockerfile
# .devcontainer/Dockerfile
# Imagen de DESARROLLO. Debian y no Alpine: el tooling nativo de esta época
# necesita glibc, y el porqué está en el Apéndice A03 §9.
FROM node:14.21.3-bullseye-slim

# Debian 11 salió de soporte y deb.debian.org ya no sirve los paquetes de
# seguridad que su índice anuncia (404): apt va al archivo congelado.
RUN printf '%s\n' \
      'deb [check-valid-until=no] http://archive.debian.org/debian bullseye main' \
      'deb [check-valid-until=no] http://archive.debian.org/debian-security bullseye-security main' \
      > /etc/apt/sources.list

# ca-certificates: sin él, git no verifica ningún certificado HTTPS.
# python2, make y g++: node-sass 4.14.1 no tiene binario para Linux arm64 y se
# compila con un node-gyp 3 que no acepta Python 3. python3 es para el
# node-gyp de npm. chromium es el navegador de ng test (Fase 12).
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      python3 \
      python2 \
      make \
      g++ \
      git \
      chromium \
    && rm -rf /var/lib/apt/lists/*
ENV CHROME_BIN=/usr/bin/chromium

# El volumen de node_modules se monta aquí. Si la carpeta ya existe en la
# imagen y es de 'node', el volumen nace con ese dueño; si no, nace de root
# y el primer npm ci falla con EACCES.
RUN mkdir -p /workspace/node_modules && chown -R node:node /workspace

# 'node' ya existe en la imagen y no es root: lo que crees en la carpeta
# montada queda a tu nombre en el Mac.
USER node
WORKDIR /workspace

# jspdf 1.5.3 trae file-saver desde GitHub, y npm 6 lo pide por ssh:// y
# git://, que el contenedor no tiene. Que git lo pida por https://.
RUN git config --global url."https://github.com/".insteadOf "ssh://git@github.com/" \
    && git config --global --add url."https://github.com/".insteadOf "git://github.com/"
```

```jsonc
// .devcontainer/devcontainer.json
{
  "name": "clinical-lab (Angular 8)",
  "build": { "dockerfile": "Dockerfile" },

  // El repositorio se monta en /workspace, la carpeta que prepara el Dockerfile.
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind",
  "workspaceFolder": "/workspace",

  // node_modules fuera del bind mount: es la §5 y no es opcional.
  "mounts": [
    "source=lab-node-modules,target=/workspace/node_modules,type=volume"
  ],

  // 4200 es ng serve; 3000 es json-server (Fase 4). Se publican para poder
  // abrirlos desde el navegador del Mac, que es donde corre la aplicación.
  "forwardPorts": [4200, 3000],

  "postCreateCommand": "npm ci",
  "remoteUser": "node"
}
```

Y el detalle que hace que se pueda usar de verdad:

```bash
# Dentro del contenedor, ng serve tiene que escuchar en todas las interfaces.
# Con el default (localhost) el servidor solo se ve DESDE DENTRO, y desde el
# navegador del Mac no carga nada: es el "no me abre en el 4200" clásico.
npx ng serve --host 0.0.0.0 --poll 2000
```

**Detalles con intención.**

- **Debian 11 y `archive.debian.org`.** La imagen viene con las fuentes de `deb.debian.org`, y desde que Debian 11 salió de soporte el `apt-get install` falla así:

  ```text
  E: Failed to fetch http://deb.debian.org/debian-security/pool/updates/main/p/perl/perl-base_5.32.1-4%2bdeb11u5_arm64.deb  404  Not Found
  ```

  El archivo histórico tiene los paquetes y no se va a mover. Sin actualizaciones de seguridad, sí: es una imagen de desarrollo para un stack de 2019, no algo que se expone. Es la trampa 1 de **A14 §3**.
- **`ca-certificates` y la reescritura de git.** `jspdf` 1.5.3 trae `file-saver` desde GitHub, y npm 6 lo pide por SSH. Sin la reescritura, el `npm ci` muere así:

  ```text
  npm ERR! /usr/bin/git ls-remote -h -t ssh://git@github.com/eligrey/FileSaver.js.git
  npm ERR! error: cannot run ssh: No such file or directory
  ```

  Y por HTTPS, sin `ca-certificates`, git no puede verificar el certificado de GitHub. Son las trampas 2 y 3 de **A14 §3**, con su explicación completa.
- **`python2` además de `python3`.** En arm64, `node-sass` 4.14.1 compila con un `node-gyp` 3.8.0 que busca `python2`, después `python`, y no acepta Python 3. Sin `python2`, el `npm ci` falla en `node-sass@4.14.1 postinstall` con `Can't find Python executable "python", you can set the PYTHON env variable.` Con él, compila y deja `vendor/linux-arm64-83/binding.node`. En amd64 sobra, porque el binario se descarga, pero no estorba. Si tu equipo pasa a Dart Sass (**A12 §3**), esa línea se puede ir.
- **`chromium` y `CHROME_BIN`** son el navegador de `ng test`. Dentro del contenedor, Chromium corre como `node` y necesita el lanzador sin sandbox de **A14 §7.1** en `karma.conf.js`: `npx ng test --watch=false --browsers=ChromeHeadlessNoSandbox`.
- **La carpeta `/workspace/node_modules` creada en la imagen**, con dueño `node`, es lo que hace que el volumen nazca con ese dueño y que el `postCreateCommand` sea un `npm ci` a secas (§5).
- **`--host 0.0.0.0`** es obligatorio dentro de un contenedor. Sin él, `ng serve` anuncia `listening on localhost:4200` y desde el Mac el puerto publicado no responde. El mock de la **Fase 4** no lo necesita: Express escucha en todas las interfaces por defecto.
- **`--poll`** hace que el detector de cambios pregunte por los archivos en vez de esperar a que el sistema le avise. En Colima hace falta: los avisos de cambio no cruzan a la VM por defecto (§3). En Docker Desktop sobra —en la prueba del curso, `ng serve` recompiló al tocar un archivo desde el Mac con y sin `--poll`—, pero no estorba. Cuesta algo de CPU y evita la pregunta *"¿por qué tengo que reiniciar `ng serve` cada vez?"*.
- **El formato `devcontainer.json` es de VS Code**, aunque otras herramientas lo lean. Con la extensión *Dev Containers*, "Reopen in Container" construye la imagen, crea el volumen y corre `npm ci`. Si tu editor no lo soporta, la receta a mano de abajo hace lo mismo.
- **Este contenedor es la "ruta corta"** del ejercicio 🔥 de la **Fase 0** que propone armar el ambiente en Debian slim a mano. Si quieres la lección completa, hazlo a mano primero; si quieres trabajar, esto es lo que hay.

> 📝 **Cómo se probó.** Los dos archivos de arriba, tal cual, sobre la base del proyecto de **A14 §6** (el manifiesto y el lockfile de **A03 §8.1**), con Docker Desktop 4.92.0 en un Mac con chip M, en arm64 y en amd64: `npm ci`, `ng build`, `ng test` (3 de 3) y `ng serve` respondiendo 200 en el Mac. Lo que no se probó es VS Code abriéndolos: se probó la receta a mano de abajo, que hace lo mismo con esos dos archivos.

### Sin VS Code: la receta a mano

```bash
# Desde la raíz del repositorio, una sola vez.
docker build -t clinical-lab-dev .devcontainer
docker volume create lab-node-modules

# Cada día: un shell dentro del contenedor, con los puertos publicados
# solo en tu Mac (127.0.0.1), no en la red de la oficina.
docker run -it --rm --name clinical-lab-dev \
  -v "$PWD":/workspace \
  -v lab-node-modules:/workspace/node_modules \
  -p 127.0.0.1:4200:4200 -p 127.0.0.1:3000:3000 \
  clinical-lab-dev bash
```

Ya dentro, `npm ci` la primera vez, y después lo de cada fase. Cada servicio va en su terminal, y `docker exec -it clinical-lab-dev bash` abre otra: `npm run mock` en una y `npx ng serve --host 0.0.0.0 --poll 2000` en la otra.

---

## 7. Construir para la arquitectura correcta

La **Fase 14 §5.1** y el **A09 §7** te enseñan a *diagnosticar* el `exec format error`: la imagen es de otra arquitectura que la máquina que la corre. Esta sección es la otra mitad, la que nadie escribió todavía: **cómo evitarlo al construir.**

```bash
# 1. De qué arquitectura es esta imagen, realmente. Es la comprobación que
#    resuelve la discusión antes de que empiece.
docker image inspect lab-frontend:1.0.0 --format '{{.Architecture}}'

# 2. Construir para una arquitectura concreta, sin importar en que Mac estes.
docker build --platform linux/amd64 -t lab-frontend:1.0.0 .

# 3. Correr una imagen de otra arquitectura, puntualmente.
docker run --platform linux/amd64 --rm -p 8080:80 lab-frontend:1.0.0
```

**La regla, en una línea:** la imagen tiene que ser de la arquitectura **de la máquina que la va a correr**, y esa máquina no siempre es la tuya. Para el kind de la **Fase 14**, el nodo hereda la arquitectura de tu VM, así que en un Mac con chip M y la VM arm64 de §3 conviene construir **arm64**: una imagen amd64 también arranca en kind, traducida por Rosetta y más lenta, y eso esconde la diferencia con el servidor (**Fase 14 §5.1**). Para un servidor de la empresa, casi siempre `linux/amd64`.

**Lo que ves en tu Mac no es lo que ve el servidor.** Con Rosetta encendida en la VM, si corres una imagen amd64 sin `--platform`, Docker avisa y la corre igual, traducida:

```text
WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested
```

Un servidor amd64 sin emulación que recibe tu imagen arm64 no avisa: no arranca, con `exec format error`. Esa segunda mitad no se reproduce en un Mac con Rosetta, que corre las dos arquitecturas —tampoco en kind: en la prueba del curso, un pod con una imagen solo-amd64 quedó `Running` en un nodo arm64—; en el servidor, la comprobación es el `docker image inspect` de arriba.

Y cuando la misma imagen tiene que servir para las dos:

```bash
# Una imagen multi-arquitectura: un solo tag que contiene las dos variantes, y
# cada máquina descarga la suya. Necesita un builder con soporte multiplataforma.
docker buildx build --platform linux/amd64,linux/arm64 \
  -t registry.interno/lab/frontend:1.4.0 --push .
```

> ⚠️ **`--push` no es opcional en el comando de arriba, y es lo que más sorprende.** Una imagen multi-arquitectura es un manifiesto que apunta a varias variantes, y el almacén local de imágenes de tu Docker guarda una sola: por eso `--load` solo funciona con **una** plataforma a la vez. Multi-arquitectura significa, en la práctica, **publicar en un registry** — que es justo la diferencia con el `kind load` de la **Fase 14 §4**, y otro recordatorio de que el atajo de kind no existe en la empresa (**A09 §3**).

---

## 8. Cambiar de runtime sin romper nada

Docker Desktop y cada perfil de Colima son **máquinas virtuales independientes**. Eso tiene una consecuencia que se descubre en el peor momento: **las imágenes, los volúmenes y la caché de build viven dentro de una VM y no se ven desde la otra.** Cambiar de runtime no borra nada, pero lo esconde, y el síntoma es *"mi imagen desapareció"*.

Quién está atendiendo tus comandos lo dice el **contexto**:

```bash
# 👁️ Que contextos hay y cual esta activo (la estrella).
docker context ls

# ✍️ Cambiar. El nombre exacto depende de lo que tengas instalado; sale en
#    la lista de arriba.
docker context use colima
docker context use desktop-linux

# 👁️ Y la confirmación que de verdad importa: a qué VM le estoy hablando y
#    de que arquitectura es.
docker info --format '{{.Name}} / {{.Architecture}} / {{.OperatingSystem}}'
```

**El ritual para cambiar sin perder la mañana:**

1. **Comprueba dónde estás** (`docker context ls`). Si algo "desapareció", empieza por aquí: en el 90% de los casos no se borró, está en la otra VM.
2. **Levanta el destino antes de apagar el origen.** Los perfiles de Colima conviven; no hay que elegir uno para siempre.
3. **Reconstruye la imagen en el runtime nuevo.** Es más rápido que buscar cómo exportarla, y además te confirma que el `Dockerfile` de la **Fase 13** sigue construyendo en ese entorno.
4. **Si usas el devcontainer de §6, recrea el contenedor.** El volumen con nombre de `node_modules` vive en la VM vieja: en la nueva nace vacío y el `postCreateCommand` lo vuelve a llenar. Eso es correcto, no un fallo.
5. **Si tenías un cluster de kind** (**Fase 14**), ese cluster vivía en la VM anterior. Se recrea con los mismos manifiestos en minutos; no intentes moverlo.

```bash
# Los perfiles de Colima, y cuál está corriendo.
colima list

# Apagar sin destruir (conserva imágenes y volúmenes). Sin -p es el perfil
# 'default'; con -p <nombre>, el que creaste aparte (§3).
colima stop

# Borrar la VM y su configuración. En la 0.10.3, el disco con las imágenes
# y los volúmenes se conserva para el próximo start con ese nombre.
colima delete

# Borrar también ese disco. Esto SÍ borra todo.
colima delete --data
```

En la prueba del curso, después de un `colima delete` quedaron 1,5 GB en `~/.colima/_lima/_disks/`, y se fueron con `colima delete --data`.

> 💡 **Antes de destruir un perfil, anota qué había dentro.** Las imágenes se reconstruyen y los clusters de kind se recrean, pero un volumen con datos —el `db.json` del mock de la **Fase 4** montado dentro, por ejemplo— no vuelve solo. `docker volume ls` con el contexto correcto, y dos minutos antes de escribir `delete`.

---

## 9. 🩺 Diagnóstico por síntoma

> 🕵️ Si el síntoma no está acá, el índice de síntomas **transversal** del curso está en [`forense-master.md`](forense-master.md) §3, y el pod que no arranca en [`forense-fase-14.md`](forense-fase-14.md).

| Lo que ves | Qué es | Dónde vas |
|---|---|---|
| `exec format error` al correr un contenedor | La imagen es de otra arquitectura que la máquina, y nadie la traduce | §7, y **Fase 14 §5.1** |
| `no matching manifest for linux/arm64` al descargar | Esa imagen no tiene variante arm64 | §3, o `--platform` (§7) |
| Un pod del cluster de la empresa muere con `exec format error` | Le llegó una imagen arm64 construida en un Mac; en tu kind corría, traducida | §7, **Fase 14 §5.1** |
| `E: Failed to fetch http://deb.debian.org/debian-security/… 404  Not Found` al construir | Debian 11 fuera de soporte: fuentes en `archive.debian.org` | §6 |
| `bash: line 1: sudo: command not found` | La imagen slim no trae `sudo`: no lo uses en el `postCreateCommand` | §5 |
| `npm ERR! code EACCES` … `mkdir '…/node_modules/…'` | El volumen nació de `root`: la carpeta tiene que existir en la imagen | §5, §6 |
| `cannot run ssh` … `FileSaver.js.git` | `file-saver` por SSH: falta la reescritura de git a `https://` | §6, **A14 §3** |
| `node-sass` falla **dentro** del contenedor | Tu Node ahí es arm64 de verdad, sin binario: compila, y le falta algo | §3, §6, y **A12 §3** |
| `Can't find Python executable "python"` en `node-sass` | Falta `python2` para el `node-gyp` 3 de `node-sass` | §6 |
| `WARNING: The requested image's platform (linux/amd64) does not match…` | Corres una imagen amd64 sin pedirlo; funciona traducida | §4, §7 |
| `npm install` tarda una eternidad | `node_modules` está en el bind mount | §5 |
| Instalé fuera y no funciona dentro (o al revés) | Binarios de dos plataformas mezclados | §5, ritual de **A12 §7** |
| Guardo un archivo y `ng serve` no recarga | Los eventos de archivo no cruzan a la VM (en Colima, por defecto) | §3, §6, `--poll` |
| El 4200 no abre desde el navegador del Mac | Falta `--host 0.0.0.0` (`listening on localhost:4200`), o el puerto no está publicado | §6 |
| "Mi imagen desapareció" | Estás en otro contexto: vive en la otra VM | §8 |
| `docker` no responde | El perfil no está levantado (`colima status`) | §8 |
| `'volume mount type' cannot be updated after initial setup, discarded` | Colima arrancó un perfil viejo con su configuración | §3 |
| `guest agent binary could not be found for Linux-x86_64` | Perfil de Colima con `--arch x86_64` y `vz`: esa combinación no existe | §4, §8 |
| Todo va lento, sin errores | ¿Contenedores amd64 sin necesitarlos? ¿Sin `virtiofs`? | §3, §4 |
| Archivos de `root` en tu carpeta del Mac | El contenedor corre como root | §6, `remoteUser` |

---

## 🧭 Cuándo usar qué

| Situación | Qué haces | Por qué |
|---|---|---|
| Empiezas en un Mac con chip M | Colima con una VM arm64 y Rosetta (§1, §3) | Rápido, sin licencia, cubre el 90% del curso |
| Tu empresa ya tiene licencia y la quieres gráfica | Docker Desktop, arm64 | El eje del runtime es independiente del de la arquitectura |
| Persigues un bug que solo pasa en producción | `--platform linux/amd64` en ese contenedor (§4), o el devcontainer amd64 de **A14** | Paridad; y no lo dejes como ambiente por defecto |
| Una imagen no tiene variante arm64 | `--platform linux/amd64` solo para esa (§4, §7) | Es más barato que cambiar la VM |
| `node-sass` te persigue dentro del contenedor | El devcontainer de §6, que lo compila; o amd64 (§4), o Dart Sass (**A12 §3**) | El contenedor mueve el problema, no lo borra |
| Necesitas un Docker que por defecto sea amd64 | Una VM `--arch x86_64`, con QEMU, en un perfil aparte (§4) | Emulación completa: lenta, y casi nunca hace falta |
| Vas a construir la imagen de la Fase 13 para un servidor | `--platform linux/amd64` (§7) | La máquina que la corre no es la tuya |
| La imagen tiene que servir para las dos | `buildx --platform ... --push` (§7) | Multi-arquitectura implica registry |
| Solo quieres desarrollar cómodo | El devcontainer de §6, con el volumen de §5 | Sin ese volumen, se abandona el primer día |
| Cambiaste de runtime y falta algo | `docker context ls` (§8) | Casi nunca se borró: está en la otra VM |
| Alguien propone Podman, OrbStack o Lima | Fuera del alcance de este apéndice | Existen y funcionan; comparar no es el trabajo de hoy |

---

## ⚠️ Advertencias

**El curso se completa sin abrir este apéndice.** Windows 11 es el entorno por defecto y Linux amd64 funciona sin sorpresas. Esto existe para que quien llegue con un Mac de chip M no se quede fuera.

**Aquí no se fija ninguna versión de herramienta, y es a propósito.** Colima, Docker Desktop y macOS se mueven rápido, y los flags cambian entre versiones. Lo que sí es estable es la CLI de Docker y el formato de las imágenes. **Comprueba los flags con `colima start --help` y `docker --help`**, no con la memoria de un apéndice.

**Rosetta tiene vencimiento.** Se mantiene completo en macOS 27 y se retira en gran parte a partir de macOS 28, con un subconjunto reservado para juegos antiguos. Verifica el anuncio vigente antes de apoyar una decisión de equipo en esa fecha. Toca dos cosas de este curso: los contenedores amd64 (§4) y el Node 14 bajo Rosetta que se fija para Apple Silicon (**A03 §1.2**). Ninguna es urgente; las dos conviene tenerlas anotadas.

**El contenedor no borra el problema de arquitectura, lo reubica.** Dentro de un contenedor arm64, tu Node es arm64 de verdad y `node-sass` vuelve a no tener binario: el devcontainer de §6 lo compila, y para eso trae `python2` (**A12 §3**). Lo que ganas es que ese entorno es reproducible, desechable e idéntico para todo el equipo.

**`node_modules` en el bind mount rompe, no solo va lento.** Binarios de macOS y de Linux en la misma carpeta producen errores que no mencionan ni el volumen ni la plataforma (§5, **A03 §9**). Elige un lado —dentro o fuera— y quédate ahí.

**El contenedor de desarrollo no es el de la Fase 13.** Aquel va a producción y no lleva Node en su etapa final. Este trae compilador, Python y build tools. Mezclarlos produce imágenes de producción con medio toolchain dentro (§6).

**Y antes de `colima delete --data`, mira qué hay dentro.** Las imágenes se reconstruyen y los clusters de kind se recrean; un volumen con datos, no (§8).

---

## 📚 Referencias

- https://github.com/abiosoft/colima — Colima: instalación, perfiles y los flags de `--arch`, `--vm-type` y Rosetta. ⚠️ Es la fuente de §3 y §4, y la que hay que consultar en vez de fiarse de los flags de este apéndice.
- https://github.com/abiosoft/colima/blob/main/docs/FAQ.md — las preguntas frecuentes de Colima, incluidas Rosetta y los perfiles.
- https://lima-vm.io — Lima, la máquina virtual sobre la que Colima está construido. Útil solo cuando algo falla por debajo de Colima.
- https://docs.docker.com/desktop/setup/install/mac-install — Docker Desktop en macOS, con sus requisitos. Las **condiciones de uso comercial** están en la web de Docker y las confirma tu organización, no un apéndice (§1).
- https://docs.docker.com/build/building/multi-platform — `buildx` y las imágenes multi-arquitectura, incluida la razón por la que `--load` no sirve con varias plataformas (§7).
- https://docs.docker.com/engine/manage-resources/contexts — los contextos de Docker, que son el mecanismo del §8.
- https://docs.docker.com/engine/storage/volumes — volúmenes con nombre frente a bind mounts, que es la decisión del §5.
- https://containers.dev/implementors/json_reference — la referencia del formato `devcontainer.json` (§6). Es una especificación abierta, aunque la implementación más común sea la de VS Code.
- https://code.visualstudio.com/docs/devcontainers/containers — la extensión *Dev Containers* de VS Code, la que entiende el `devcontainer.json` de §6.
- https://archive.debian.org/debian/ — el archivo de versiones viejas de Debian, de donde el Dockerfile de §6 instala los paquetes de Debian 11.
- https://developer.apple.com/documentation/virtualization — el framework de virtualización de Apple, que es lo que hay detrás de `--vm-type vz` y de Rosetta para Linux (§2).
- https://support.apple.com/en-us/HT211861 — Rosetta 2 en macOS: qué es y cómo se instala. La misma referencia del **A12**.
- https://v8.angular.io/cli/serve — las opciones de `ng serve`, incluidas `--host` y `--poll` del §6, en la versión del curso.

> ⚠️ Los enlaces y contenidos pueden haber cambiado o desaparecido; verifícalos. En este tema hay un riesgo específico: **casi todo lo que encuentres sobre "Docker en M1" es de 2021-2022**, cuando el ecosistema se estaba adaptando y muchas imágenes no tenían variante arm64. Buena parte de esos trucos hoy sobran. Fíjate en la fecha antes de copiar nada.

**Orden de lectura sugerido:** si estás empezando, §1 y §3, y nada más. Si vas a desarrollar dentro del contenedor, §5 **antes** que §6 — el orden importa, porque §6 sin §5 se abandona. Si te llegó un `exec format error`, §7. Si algo desapareció, §8.

---

## 🧪 Ejercicios (6)

Cortos y de consulta. **Todos necesitan un Mac con Apple Silicon**; si estás en Windows o Linux, este apéndice no te toca y el curso sigue completo sin él.

1. Levanta la VM arm64 de §3 y confirma con `docker info` que la arquitectura es la que esperas. Después corre `docker run --rm alpine uname -m` y compara la respuesta con la de tu `uname -m` en el Mac. Anota las dos y explica en una línea por qué coinciden.
2. Construye la imagen de la **Fase 13** en tu VM arm64 y comprueba su arquitectura con `docker image inspect`. Después reconstruye con `--platform linux/amd64` e inspecciona otra vez. Anota cuánto tardó cada una: esa diferencia es el costo de la traducción, medido por ti (§7).
3. Corre la imagen `amd64` del ejercicio anterior **sin** `--platform` en tu VM arm64 con Rosetta y anota qué pasa: el aviso exacto y si arranca. Confírmalo contra la fila del §9 y explica en dos líneas por qué un servidor amd64 sin emulación no te daría ese aviso, sino un `exec format error` con la imagen arm64 (§7).
4. Monta el devcontainer del §6 **sin** el volumen de `node_modules`, corre `npm ci` dentro y cronométralo. Después añade el volumen, recrea el contenedor y repite la medida. Anota los dos tiempos; con eso ya no necesitas que nadie te convenza de la §5.
5. **Rompe a propósito.** Con el devcontainer sin volumen —el del ejercicio anterior—, corre `npm ci` **dentro** del contenedor y después `npm start` **fuera**, en el Mac. Anota el error y explica por qué no menciona ni el contenedor ni la arquitectura. Después aplica el ritual de **A12 §7** y confirma que se arregla.
6. Ten dos runtimes a la vez —Colima y Docker Desktop— o dos perfiles de Colima (`-p`, §3), y cambia entre ellos con `docker context use`. Comprueba que las imágenes que construiste en uno **no aparecen** en el otro, y escribe en tres líneas qué le contestarías a un compañero que dice *"se me borraron todas las imágenes"* (§8).


> 🏷️ **Este es el único apéndice que puede llevar tag propio.** El §6 escribe
> archivos de verdad —`.devcontainer/devcontainer.json` y su `Dockerfile`— y
> versionarlos o no es una decisión de proyecto todavía abierta (📌 de abajo).
> Si decides versionarlos, ese commit se etiqueta y queda dicho cuándo entró el
> devcontainer y por qué:
>
> ```bash
> git tag -a apendice-a13-docker-colima -m "A13: devcontainer versionado, con el volumen con nombre para node_modules."
> ```
>
> Todo lo demás de este apéndice cambia tu máquina y no el repositorio, así que
> no se etiqueta. La convención completa está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

- **El Node 14 bajo Rosetta también tiene fecha.** La decisión de **A03 §1.2** —Node 14.21.3 x64 traducido— es correcta hoy y depende de una pieza que Apple retira (§2). Cuando esa fecha se acerque, en Apple Silicon quedarán dos caminos: un Node arm64 nativo, que reabre el problema de `node-sass` salvo que el proyecto pase a Dart Sass (**A12 §3**, opción C), o trabajar dentro del contenedor de §6. **No es urgente y conviene decidirlo antes de que lo decida el calendario** → decisión de proyecto, con nota en **A03** y en **A12**.
- **Los tiempos reales, completos.** El §4 publica una sola corrida del devcontainer, en Docker Desktop y sobre la base del proyecto. Faltan los que piden los ejercicios 2 y 4 —la imagen de la **Fase 13** en las dos arquitecturas y el volumen frente al bind mount— y todos sobre Colima; no se publican hasta medirlos, por la misma política de A08, A10 y A12: no se inventan cifras.
- **El devcontainer no está en el repositorio del curso.** El §6 lo escribe, pero nadie ha decidido si `.devcontainer/` se versiona junto al proyecto. Versionarlo ayuda a quien llegue con un Mac; también añade dos archivos que el 90% del equipo nunca abrirá → decisión de proyecto.
- **Multi-arquitectura implica registry**, y el curso no tiene ninguno: la **Fase 14** usa `kind load` y el **A09 §3** explica que ese atajo no existe en la empresa. Montar el registry local que kind documenta cerraría ese hueco y daría sentido al `buildx --push` del §7 → **ejercicio 🔥** de la Fase 14, ya anotado allá.
