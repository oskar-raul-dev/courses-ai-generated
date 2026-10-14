# 📎 Apéndice A14 — 🐳 Docker Desktop, amd64 y VS Code

> Tutorial Angular 8 — Laboratorio clínico · Receta · **2h**
> Usado por: Fases 0, 13 y 14 · Versión cubierta: Docker Desktop 29.8.0 en macOS con chip M, Node 14.21.3, Angular CLI 8.3.29, devcontainer CLI 0.89.0 · Probado el 14/10/2026
> Estado: 🔥 **Opcional por plataforma.** El curso se completa sin abrir este apéndice.

Esto es una receta, no una lección. Sigues los pasos en orden, copias los bloques y compruebas cada paso con la salida que se describe. **Lo que resuelve:** un contenedor `linux/amd64` dentro de Docker Desktop, con **Node 14.21.3** (la misma base que la Fase 13), donde levantas la base de LabCore y la pruebas, y desde el que trabajas con VS Code.

Es la ruta de **Docker Desktop**. La ruta de **Colima** —arm64 por defecto, amd64 como perfil aparte— está en el **Apéndice A13**, y el criterio para elegir entre las dos está en su §1. Las dos pueden convivir en el mismo repositorio, cada una con su devcontainer (§5).

> 🧰 **Esto es la receta. El porqué está en el curso de contenedores.** Si quieres entender por qué `platform` va en el servicio y no en `runArgs`, o qué hace Rosetta frente a QEMU, eso vive en [Docker Legacy Node](../../cursos-contenedores-cloud-infra/docker-container-legacy/README.md): el devcontainer se abre por dentro en el capítulo [19 · Dev containers](../../cursos-contenedores-cloud-infra/docker-container-legacy/19-dev-containers.md), la depuración en el [10 · VS Code y debugging](../../cursos-contenedores-cloud-infra/docker-container-legacy/10-vscode-y-debugging.md), y la emulación y la arquitectura en el [21 · Arquitecturas y emulación](../../cursos-contenedores-cloud-infra/docker-container-legacy/21-arquitecturas-y-emulacion.md).

Alcance: **solo macOS con chip M y Docker Desktop**, que es lo que se probó. Windows y Linux quedan fuera: allí Node 14 se instala con `nvm` y no hace falta emulación.

> 📝 **Este apéndice no tiene ejercicios.** Es una receta: la verificación es correr los pasos, y cada sección cierra con sus comprobaciones en *Cómo saber que funcionó* (§8). La excepción está declarada en la guía de estilo, con su porqué.

Lo que **no** cubre: la depuración paso a paso desde VS Code (**[Apéndice A15](a15-depurar-en-el-contenedor.md)**); el `Dockerfile` de producción de dos etapas (**Fase 13 §5.6**); kind (**Fase 14**); y una comparación de rendimiento contra arm64 nativo, que no se midió.

---

## Índice

- [1. Antes de empezar: la decisión en una línea](#1-antes-de-empezar-la-decisión-en-una-línea)
- [2. Confirmar que la emulación está activa](#2-confirmar-que-la-emulación-está-activa)
- [3. Tres trampas de la base Debian que hoy rompen la receta](#3-tres-trampas-de-la-base-debian-que-hoy-rompen-la-receta)
- [4. La imagen de desarrollo](#4-la-imagen-de-desarrollo)
- [5. Abrir el proyecto dentro del contenedor](#5-abrir-el-proyecto-dentro-del-contenedor)
- [6. La base de Angular 8, paso a paso](#6-la-base-de-angular-8-paso-a-paso)
- [7. Build, test y serve](#7-build-test-y-serve)
- [8. Cómo saber que funcionó](#8-cómo-saber-que-funcionó)
- [9. 🩺 Diagnóstico por síntoma](#9--diagnóstico-por-síntoma)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)

---

## 1. Antes de empezar: la decisión en una línea

Necesitas `linux/amd64` cuando producción corre en amd64 y tu máquina tiene que parecerse a ella (**A13 §4**). Para el trabajo diario, la regla de **A13 §1** sigue en pie: arm64 nativo.

Docker Desktop frente a Colima es un eje de **licencia y de interfaz**, no técnico. Docker Desktop tiene interfaz gráfica; sus condiciones de uso comercial dependen de tu organización. **Pregunta antes de instalarlo en una máquina de trabajo.** Si tu equipo ya usa Colima, sigue en **A13** y no necesitas esta receta.

Hay una consecuencia de repositorio que conviene tener clara desde ya: VS Code lee **todas** las configuraciones de devcontainer del proyecto. La de A13 vive en `.devcontainer/devcontainer.json` y la de esta receta en `.devcontainer/amd64/`. VS Code te pregunta cuál usar al reabrir el proyecto, y eso evita que una pise a la otra.

---

## 2. Confirmar que la emulación está activa

El amd64 corre traducido. En Apple Silicon, Docker Desktop puede traducirlo con **Rosetta** (la del VM de Linux, distinta de la de macOS: **A13 §2**) o con **QEMU**. La receta se probó con **Rosetta**, que es la opción que recomendamos. Con QEMU la receta debería funcionar igual, pero no la probamos y no tenemos cifras.

Revisa en Docker Desktop, en **Settings → General**, que la virtualización esté activa (*Use Virtualization framework*) y que la opción de Rosetta para x86_64/amd64 esté encendida. El nombre exacto de esa opción cambia entre versiones: busca la que mencione Rosetta y x86_64.

Dos comprobaciones desde la terminal del Mac:

```bash
# La máquina de Docker: debe decir aarch64 (Apple Silicon) y el sistema Docker Desktop.
docker info --format '{{.Architecture}} / {{.OperatingSystem}}'

# La prueba de verdad: un contenedor amd64 con la base del curso.
docker run --rm --platform linux/amd64 node:14.21.3-bullseye-slim sh -c 'uname -m && node -v'
```

Salida esperada: `aarch64 / Docker Desktop` y después `x86_64` y `v14.21.3`. La primera vez descarga la imagen; no te preocupes por las líneas de *Pulling*.

> ⚠️ **Rosetta tiene fecha.** Apple la retira por partes en las próximas versiones de macOS (**A13 §2**). Si el equipo apoya una decisión en este perfil, verifica el anuncio vigente antes. Esta receta sirve hoy; no garantiza nada dentro de dos años.

---

## 3. Tres trampas de la base Debian que hoy rompen la receta

La imagen `node:14.21.3-bullseye-slim` es la base de la Fase 13, y la receta de Docker de **A13 §6** le instala herramientas con `apt`. Al probarla el 14/10/2026 aparecieron tres problemas. Ninguno es de arquitectura: los tres afectan igual a amd64 y a arm64. Cada uno tiene su comprobación y su arreglo, y el arreglo ya está en el `Dockerfile` de §4.

**Trampa 1 · `apt` no instala nada.** Debian 11 (bullseye) ya no recibe soporte normal y su mirror está a medio mover. El índice de `deb.debian.org` anuncia versiones de seguridad de paquetes (por ejemplo `libc6 2.31-13+deb11u14`) cuyos archivos ya no están en el servidor. Compruébalo sin tocar tu proyecto:

```bash
docker run --rm --platform linux/amd64 node:14.21.3-bullseye-slim \
  sh -c 'apt-get update && apt-get install -y curl'
```

Hoy la salida trae `E: Failed to fetch … 404 Not Found`. El arreglo es apuntar `apt` al archivo congelado de bullseye, `archive.debian.org`, con `check-valid-until=no`. Con eso instalas Python 3.9, git, las build tools y Chromium 120, que es lo que necesitan las fases.

**Trampa 2 · la imagen no sabe verificar certificados.** `node:14.21.3-bullseye-slim` no trae `ca-certificates`: no existe `/etc/ssl/certs`. Cualquier `git` o `curl` por HTTPS falla con `server certificate verification failed. CAfile: none`, aunque la red esté bien. Se arregla instalando `ca-certificates`.

**Trampa 3 · una dependencia de GitHub que se resuelve por SSH.** `jspdf@1.5.3` (**A03 §8.1**) depende de `file-saver` con la forma `github:eligrey/FileSaver.js#1.3.8`. Esa forma hace que npm 6 clone el repositorio con `git`. Npm prueba primero `ssh://git@github.com/…`, que falla porque el contenedor no tiene claves SSH, y después `git://github.com/…`, que se queda colgado porque el puerto 9418 no está abierto. El arreglo es decirle a git que reescriba esas direcciones a `https://github.com/`.

Después de la instalación, el lockfile fija `file-saver` a un **commit de GitHub**. Eso tiene consecuencia: cualquier `npm ci` futuro en un equipo necesita acceso a GitHub (§8 y **Advertencias**).

> 🧭 **El Dockerfile de A13 §6 tiene las mismas trampas 1 y 2**, y además su `postCreateCommand` usa `sudo` sin que esa imagen lo instale. No lo corregimos aquí para no tocar su contenido; la receta de §4 es la versión que pasó todas las pruebas. Si usas Colima, el arreglo es el mismo.

---

## 4. La imagen de desarrollo

Tres archivos en `.devcontainer/amd64/`. Son la receta, así que se copian tal cual.

```dockerfile
# .devcontainer/amd64/Dockerfile
FROM node:14.21.3-bullseye-slim

# Dos cosas que la imagen base no trae, en este orden (A14 §3):
# 1. Los repos de bullseye: deb.debian.org ya no sirve los paquetes de seguridad
#    que su índice anuncia (404). Se apunta apt al archivo congelado de bullseye.
# 2. ca-certificates: sin él, git y curl no verifican ningún certificado HTTPS
#    (la imagen no trae /etc/ssl/certs). Lo necesita la dependencia de jspdf que
#    se descarga desde GitHub.
RUN printf 'deb [check-valid-until=no] http://archive.debian.org/debian bullseye main\ndeb [check-valid-until=no] http://archive.debian.org/debian-security bullseye-security main\n' > /etc/apt/sources.list \
    && printf 'Acquire::Check-Valid-Until "false";\nAcquire::Retries "5";\n' > /etc/apt/apt.conf.d/99archive \
    && apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates python3 build-essential git curl sudo chromium \
    && apt-get clean \
    && echo "node ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/node
ENV CHROME_BIN=/usr/bin/chromium
USER node
WORKDIR /workspace

# 3. Las dependencias de GitHub (jspdf 1.5.3 trae file-saver desde github:) se
#    resuelven por git. npm 6 intenta git:// y ssh://, que la red del contenedor
#    no abre. Se reescriben a https:// en la configuración de git del usuario node.
RUN git config --global url."https://github.com/".insteadOf "git://github.com/" \
    && git config --global --add url."https://github.com/".insteadOf "ssh://git@github.com/" \
    && git config --global --add url."https://github.com/".insteadOf "git@github.com:"
```

Dos decisiones que el texto de arriba no cuenta. **`sudo` sin contraseña** para `node`: el volumen de `node_modules` nace con dueño `root` y necesitamos cambiárselo a `node` (§5). Es aceptable en un contenedor de desarrollo local, y no es aceptable en una imagen que se publique: por eso esta imagen **no** es la de la Fase 13. **`apt-get clean` en vez de borrar las listas:** la caché de paquetes se va, y la imagen pesa un poco más.

```jsonc
// .devcontainer/amd64/devcontainer.json
{
  "name": "clinical-lab (Angular 8, amd64)",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspace",
  "remoteUser": "node",

  // 4200 es ng serve; 9229 es el inspector de ng serve y 9230 el de ng test (A15).
  // VS Code los reenvía al Mac. El CLI de devcontainer no los publica por sí solo.
  "forwardPorts": [4200, 9229, 9230],

  // El volumen de node_modules nace vacío y pertenece a root: se lo damos a 'node'.
  // npm ci se corre a mano después, para poder medirlo (§6).
  "postCreateCommand": "sudo chown -R node:node node_modules"
}
```

```yaml
# .devcontainer/amd64/docker-compose.yml
name: clinical-lab-amd64
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    # Va en el servicio, no en runArgs: así el build y el contenedor salen amd64.
    platform: linux/amd64
    labels:
      curso: angular-8-legacy
    volumes:
      - ../..:/workspace:cached
      - lab-node-modules-amd64:/workspace/node_modules
    command: sleep infinity
volumes:
  lab-node-modules-amd64:
```

¿Por qué `docker-compose` y no `runArgs`? Porque lo probamos con las dos y el resultado no deja dudas. Con `"build": {"dockerfile": …}` más `"runArgs": ["--platform=linux/amd64"]`, **el build sale `arm64`**: `runArgs` solo afecta a `docker run`, y el `run` luego falla con `pull access denied`, porque la imagen local es arm64 y Docker busca una amd64 que no existe. Con `platform` en el servicio de Compose, el build y el contenedor salen `amd64` (`docker image inspect … --format '{{.Architecture}}'` lo confirma).

El volumen `lab-node-modules-amd64` es el de **A13 §5**: `node_modules` vive dentro de la VM, no en la carpeta de tu Mac. Usa un nombre distinto del de A13 para que los dos perfiles no compartan volumen.

---

## 5. Abrir el proyecto dentro del contenedor

El proyecto queda así:

```
clinical-lab/
├── .devcontainer/
│   ├── devcontainer.json      ← A13 (Colima, arm64)
│   └── amd64/                 ← A14 (Docker Desktop, amd64)
│       ├── Dockerfile
│       ├── devcontainer.json
│       └── docker-compose.yml
├── angular.json
├── package.json
└── src/
```

Con Docker Desktop encendido, abre la carpeta en VS Code (extensión *Dev Containers*). Cuando te pregunte, elige **clinical-lab (Angular 8, amd64)**. VS Code construye la imagen (la primera vez tarda) y abre una terminal **dentro** del contenedor. Compruébalo en esa terminal:

```bash
uname -m     # x86_64
node -v      # v14.21.3
whoami       # node
```

Si prefieres la terminal sin VS Code, el CLI oficial hace lo mismo. Fíjalo a la versión de la prueba:

```bash
npx @devcontainers/cli@0.89.0 up --workspace-folder . --config .devcontainer/amd64/devcontainer.json
```

> ⚠️ **El CLI no publica los puertos.** `forwardPorts` lo interpreta VS Code. Si trabajas sin VS Code y quieres abrir `localhost:4200` desde el Mac, usa el truco de §8 con un archivo de puertos aparte.

Una consecuencia que confunde el primer día: en tu Mac, la carpeta `node_modules` aparece **vacía**. Es el punto de montaje del volumen (**A13 §5**). Todo lo que instales va dentro del contenedor, y el editor del Mac ve el código sin dependencias. No instales nada en el Mac: si lo haces, mezclas binarios de dos plataformas.

---

## 6. La base de Angular 8, paso a paso

Todo lo de esta sección se corre **dentro del contenedor**, en la terminal de VS Code.

### 6.1 CLI 8.3.29

```bash
sudo npm install -g @angular/cli@8.3.29
ng version | grep -E "Angular CLI|Node"
```

Salida esperada: `Angular CLI: 8.3.29` y `Node: 14.21.3`. Se instala con `sudo` porque el prefijo global de la imagen es de root.

### 6.2 Generar el proyecto fuera de la carpeta montada

El `ng new` se corre en un directorio del contenedor, no en `/workspace`. `/workspace` es la carpeta de tu Mac montada: cada escritura cruza la frontera de la VM y se nota (**A13 §5**). Generar en el sistema de archivos del contenedor es más rápido y, además, deja la carpeta limpia si algo falla.

```bash
mkdir -p /home/node/base && cd /home/node/base
ng new clinical-lab --skip-install --skip-git --routing=false --style=css --defaults
```

Tarda unos segundos porque no instala nada. Quedan `karma.conf.js` (que ajustamos en §7.1), `tsconfig.spec.json`, `src/` y un `package.json` que **vamos a reemplazar**.

### 6.3 El manifiesto de A03 §8.1

En la carpeta de tu proyecto en el Mac (la que está montada como `/workspace`), crea `package.json` con el bloque de **A03 §8.1** **sin los comentarios** (JSON no admite `//`). Desde la versión actual de A03, ese bloque ya trae `@types/jasmine` y `@types/node` fijado. Lo que sí agregas es el bloque `"scripts"` que genera `ng new`, para que `npm run` funcione como en la base generada.

Sin `@types/node` fijado, una instalación en frío sin lockfile resuelve la 26.x (varias dependencias transitivas piden `"*"`), que usa la sintaxis `asserts` de TypeScript 3.7 y no compila con el TypeScript 3.5 del curso: `ng build` pasa, pero `ng test` falla con `TS1144`. Por eso el manifiesto lo fija.

`package-lock.json` **no** existe todavía: lo genera §6.4.

### 6.4 Copiar la base y generar el lockfile

Con el `package.json` de §6.3 en `/workspace`, la base se arma así. El orden importa: el `package.json` de A03 se copia **al** directorio generado por `ng new` antes de volcarlo sobre `/workspace`, porque el del CLI lo sobrescribiría.

```bash
cp /workspace/package.json /home/node/base/clinical-lab/package.json
cp -a /home/node/base/clinical-lab/. /workspace/
cd /workspace
npm install
```

`npm install` tarda alrededor de un minuto y medio y produce `package-lock.json` con `lockfileVersion: 1` (el formato de npm 6, **A03 §3**). **Ese es el lockfile que se versiona.** `npm` puede dejar `^3.4.6` en `package.json` para `@types/jasmine`: es la versión que resuelve, y es normal.

> ⚠️ `cp -a` **sobrescribe** lo que ya tengas en `/workspace` con el mismo nombre (`README.md`, `.gitignore`, `tsconfig.json`). Si tu carpeta ya tiene alguno, revísalo con `git diff` antes de seguir.

Las instalaciones siguientes, de cualquier compañero o del propio CI, son con `npm ci`:

```bash
cd /workspace
npm ci
```

Lo que importa de `npm ci` (**A03 §4**): obedece al lockfile, nunca lo reescribe y falla si el manifiesto y el lock no coinciden. Por eso es la forma de instalar dentro del Dockerfile y en cualquier máquina que quiera reproducir el árbol.

### 6.5 Tiempos medidos

Estos números son de la máquina de la prueba: Docker Desktop 29.8.0 con 8 CPU y 8 GB asignados, Rosetta activo, Mac con chip M. **No son una comparación con arm64 nativo** (no se midió); sirven para saber qué esperar en esta configuración.

| Paso | Qué hace | Tiempo medido |
|---|---|---|
| `sudo npm i -g @angular/cli@8.3.29` | CLI global | ~50 s, incluido arranque |
| `ng new … --skip-install` | Genera el esqueleto | ~4 s |
| `npm install` (genera el lock) | Árbol completo desde el manifiesto | 82 s |
| `npm ci` (desde el lock) | Árbol completo desde el lock | 87 s |
| `ng build` | Build de desarrollo | 80–96 s |
| `ng test --watch=false` | Karma + ChromeHeadless | 22 s |
| `ng serve` (primer arranque) | Compilación inicial | ~23 s |

---

## 7. Build, test y serve

### 7.1 Karma sin sandbox

El `karma.conf.js` que genera `ng new` 8 no sirve tal cual con el manifiesto de A03, por dos razones. Declara el reporter `karma-jasmine-html-reporter`, que el manifiesto no trae, así que Karma falla al cargar la configuración. Y no tiene lanzador sin sandbox, y Chromium corre como `node` dentro del contenedor, donde no puede crear su sandbox.

Sustituye su contenido por la forma de la **Fase 12 §5.1** y agrega el lanzador. Las tres ediciones son:

1. En `plugins`, borra la línea `require('karma-jasmine-html-reporter'),`.
2. En `reporters`, deja `reporters: ['progress'],`.
3. Dentro de `config.set({…})`, después de `browsers: ['Chrome'],`, agrega:

```javascript
    browsers: ['Chrome'],
    // Dentro del contenedor, Chromium corre como usuario 'node' sin sandbox.
    customLaunchers: {
      ChromeHeadlessNoSandbox: {
        base: 'ChromeHeadless',
        flags: ['--no-sandbox']
      }
    },
```

`browsers: ['Chrome']` se queda: sigue sirviendo para la Fase 12 en tu máquina. El lanzador sin sandbox es para este contenedor, y se elige con `--browsers` en la línea de comandos.

> 📝 Lo que se probó es ese archivo con las tres ediciones. El bloque `coverageIstanbulReporter` queda como lo genera `ng new` (`lcovonly` incluido): no afecta a las pruebas, y la Fase 12 §5.1 lo deja en `html` y `text-summary`. Si el `karma.conf.js` de `ng new` te llega sin tocar, `ng test` falla con `Cannot find module 'karma-jasmine-html-reporter'`.

### 7.2 Build, test y serve

```bash
cd /workspace
npx ng build
npx ng test --watch=false --browsers=ChromeHeadlessNoSandbox
npx ng serve --host 0.0.0.0 --poll 2000
```

- **`--host 0.0.0.0`** es obligatorio dentro del contenedor (**A13 §6**).
- **`--poll 2000`** evita que los cambios no crucen la frontera de la VM (**A13 §6**).
- `ng serve` **no termina**: déjalo corriendo en una terminal y usa otra para el resto.

### 7.3 node-sass: el binario sale de GitHub

La base de LabCore incluye `node-sass` 4.14.1 (**A03 §8.1**) y **A12 §3** explica por qué suele fallar. Aquí no falla: `node-sass` descarga el binario precompilado `linux-x64-83` desde GitHub durante `npm install`, y lo carga. Lo comprobamos con `require('node-sass')` dentro del contenedor.

Eso depende de tener acceso a GitHub. Si tu red lo bloquea, `node-sass` cae a compilar con `node-gyp`, que necesita Python y las build tools de esta imagen. **Ese camino no lo probamos**: si te toca, el síntoma está en §9 y el procedimiento general en **A12 §3** y **§4**.

---

## 8. Cómo saber que funcionó

Esta sección reemplaza a los ejercicios. Cada punto es una comprobación que puedes repetir.

1. **La arquitectura es la correcta.** `uname -m` dentro del contenedor da `x86_64` y `node -v` da `v14.21.3`.
2. **El lock es el que se versiona.** `grep lockfileVersion package-lock.json` da `1`, y `npm ci` termina sin error.
3. **`file-saver` necesita GitHub.** `grep -A2 '"file-saver"' package-lock.json` muestra `github:eligrey/FileSaver.js#…`. Si `npm ci` falla con `ls-remote`, revisa la trampa 3 de §3.
4. **El build pasa.** `npx ng build` termina con código 0 y lista los *chunks*.
5. **Las pruebas pasan.** La última línea de `ng test` dice `TOTAL: 3 SUCCESS` (el spec de la base de `ng new`).
6. **La app responde dentro.** Con `ng serve` corriendo, `curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:4200/` devuelve `200`.
7. **La app responde desde el Mac.** Con VS Code, abre la pestaña *Ports* y entra en el 4200 reenviado; la página carga. Sin VS Code, levanta el contenedor con el archivo de puertos de prueba:

```yaml
# puertos.yml, fuera del repositorio: solo para comprobar desde el Mac sin VS Code.
# 4200 es ng serve; 9229 el inspector de ng serve y 9230 el de ng test (A15).
services:
  app:
    ports:
      - "127.0.0.1::4200"
      - "127.0.0.1::9229"
      - "127.0.0.1::9230"
```

```bash
docker compose -f .devcontainer/amd64/docker-compose.yml -f puertos.yml -p clinical-lab-amd64 up -d
docker compose -f .devcontainer/amd64/docker-compose.yml -f puertos.yml -p clinical-lab-amd64 port app 4200
# Usa el puerto que te devuelva el último comando:
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:<PUERTO>/
```

Dos notas sobre esa receta. El puerto del host es **aleatorio** y solo escucha en `127.0.0.1`, así que no choca con nada. Y `up -d` con el archivo de puertos recrea el contenedor, pero el volumen de `node_modules` se conserva. Los servidores que lances (`ng serve`, `ng test`) se pierden al recrear: vuelve a lanzarlos.

Cuando termines, detén el stack sin borrar el volumen:

```bash
docker compose -f .devcontainer/amd64/docker-compose.yml -p clinical-lab-amd64 down
```

---

## 9. 🩺 Diagnóstico por síntoma

| Lo que ves | Qué es | Dónde vas |
|---|---|---|
| `E: Failed to fetch … 404` en `apt-get` | Repos de bullseye ya no sirven los paquetes anunciados | §3, trampa 1 |
| `server certificate verification failed. CAfile: none` | Falta `ca-certificates` en la imagen | §3, trampa 2 |
| `Error while executing: /usr/bin/git ls-remote … ssh://git@github.com/…` | Dependencia de GitHub por SSH, sin clave en el contenedor | §3, trampa 3 |
| `npm install` se queda quieto sin error | `git://` a un puerto que la red no abre | §3, trampa 3 |
| `pull access denied for …` al correr con `--platform` | La imagen local es de otra arquitectura; usa `platform` en el servicio | §4 |
| `exec format error` | Imagen de otra arquitectura que la VM | **A13 §7** |
| `Cannot find module 'karma'` al correr `ng test` | El `npm install` o el `npm ci` no terminó bien | §6.4 |
| `TS2688: Cannot find type definition file for 'jasmine'` | Falta `@types/jasmine` | §6.3 |
| `No binary for Chrome browser on your platform` | Karma no encuentra Chromium: revisa `CHROME_BIN` | §4 (`ENV`) |
| `EACCES` al instalar en `node_modules` | El volumen nació con dueño `root` | §5 (`postCreateCommand`) |
| El 4200 responde dentro y no en el Mac | Falta `--host 0.0.0.0`, o el puerto no está publicado | §7.2 y §8 |
| Guardas un archivo y `ng serve` no recarga | Los eventos de archivo no cruzan a la VM | §7.2, `--poll` |
| `ng test` no arranca Chrome en el contenedor | Chromium necesita `--no-sandbox` como usuario `node` | §7.1 |
| Depuras y el inspector muestra `/usr/local/bin/npx` | `npx` tomó el puerto y `ng` no pudo | **A15** |
| Carpeta `node_modules` vacía en el Mac | Es el punto de montaje del volumen | §5 |
| `docker` no responde o el contenedor no existe | Docker Desktop apagado o el contexto es otro | **A13 §8** |

---

## 🧭 Cuándo usar qué

| Situación | Qué haces | Por qué |
|---|---|---|
| Tu equipo ya usa Colima | Sigue en A13 | Mismo resultado, sin licencia de Docker Desktop |
| Tu organización tiene licencia de Docker Desktop y lo necesitas | Esta receta | Paridad amd64 con interfaz gráfica |
| Trabajo diario en tu Mac | arm64 nativo (**A13 §3**) | Más rápido; amd64 es para paridad |
| Un bug que solo aparece en producción | Esta receta (amd64) | Paridad; no la dejes como ambiente por defecto |
| Necesitas depurar dentro del contenedor | **A15** | Inspector, `launch.json` y pasos manuales |
| Vas a publicar la imagen | El `Dockerfile` de la **Fase 13** | Este tiene `sudo` y herramientas de desarrollo |

---

## ⚠️ Advertencias

**Esta receta no es reproducible sin GitHub.** `file-saver` se resuelve a un commit de GitHub en el lockfile. Un `npm ci` en una red que bloquee GitHub falla, y no hay un "sin GitHub" que funcione con el manifiesto actual de **A03 §8.1**. Si el equipo necesita un árbol que se instale sin red externa, el camino es cambiar la dependencia de `jspdf`: decisión del curso, no de este apéndice.

**`@types/jasmine` y `@types/node` van en el manifiesto de A03 §8.1.** Si copias un manifiesto anterior, esas dos líneas faltan y `ng test` falla (`TS2688` o `TS1144`). El lockfile de `file-saver` sigue apuntando a GitHub (ver arriba).

**La imagen tiene `sudo` sin contraseña.** Está bien para tu contenedor de desarrollo, y no para una imagen publicada. Es la razón de que la imagen de desarrollo y la de la Fase 13 sean distintas.

**Las trampas de Debian no son permanentes.** El archivo `archive.debian.org` congela bullseye; cuando el índice de `deb.debian.org` vuelva a ser consistente, el arreglo de §3 seguirá funcionando, pero ya no será necesario. Verifica antes de borrarlo.

**Rosetta tiene vencimiento** (**A13 §2**). La receta depende de la emulación del VM, y el Node 14 del curso también (**A03 §1.2**). Ninguna de las dos es urgente hoy; las dos conviene tenerlas anotadas.

---

## 📚 Referencias

- https://containers.dev/implementors/json_reference/ — La referencia de `devcontainer.json`: `dockerComposeFile`, `forwardPorts`, `postCreateCommand`. Es la fuente de §4 y §5.
- https://github.com/devcontainers/cli — El CLI usado en §5 (fijado a la versión 0.89.0 en esta receta). Comprueba sus flags con `--help`.
- https://docs.docker.com/desktop/setup/install/mac-install — Docker Desktop en macOS. Las condiciones de uso comercial están en la web de Docker y las confirma tu organización (**A13 §1**).
- https://archive.debian.org/debian/ — El archivo de Debian que usa §3.
- https://github.com/sass/node-sass/releases — Los binarios precompilados de `node-sass` que descarga §7.3.
