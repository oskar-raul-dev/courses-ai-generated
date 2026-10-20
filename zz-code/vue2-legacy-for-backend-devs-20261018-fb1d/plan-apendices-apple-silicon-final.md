# 🍎 Plan de edición desechable — Node 14 en Apple Silicon y los apéndices a6/a7

> **Paquete:** vue2-legacy-for-backend-devs (Tiquetera) · **Creado:** 2026-10-18
> **Estado:** abierto. Reabre el paquete cerrado el 18/10/2026 solo para este alcance.
> **Origen:** pedido del autor: traer al Curso 01 los apéndices A12 (arm64 / M1) y A13 (Docker + Colima) de
> `angular-8-legacy-for-backend-devs`, y fijar Node 14 también en Apple Silicon.
> **Se borra** al cerrar T6, con permiso del autor. Lo que deje como regla pasa a la guía §17.4–§17.5.
> Las reglas de trabajo son las de la guía §17.5, sin excepción.

---

## 1. 🎯 Alcance

**Entra:**

1. El Curso 01 deja de recomendar **Node 16.20.2** en Apple Silicon y pasa a **Node 14.21.3 x64 bajo
   Rosetta 2**, igual que el resto del paquete y que el `.nvmrc`.
2. Dos apéndices nuevos en el Curso 01, **adaptados a la Tiquetera** y no copiados de Angular:
   `01-vue2-legacy/a6-arm64-m1.md` y `01-vue2-legacy/a7-docker-colima.md`.
3. Los enlaces e índices que esos dos cambios tocan, en los dos cursos.

**No entra:** el A14 de Angular como archivo propio (D3), las rutas Q/VU/NX más allá de citar su
dependencia nativa, otros runtimes (Podman, OrbStack, Lima), y cualquier cambio de versiones del stack.

---

## 2. ⚖️ Decisiones (todas por defecto, 18/10/2026: «decisiones por default»)

| # | Decisión | Por defecto |
|---|---|---|
| D1 | Ubicación | Los dos en el **Curso 01**: `a6-arm64-m1.md` y `a7-docker-colima.md` (un dígito, guía §13.2). El Curso 02 los cita como «Curso 01, Apéndice 6/7» |
| D2 | Formato | La **plantilla de apéndice del paquete** (🎯 Para qué sirve · secciones · ⚠️ Diagnóstico rápido · 🧪 Ejercicios — todos opcionales · 📚 Referencias), con una batería **corta de ~15 ejercicios** en vez de los ~34 de a1–a5. La excepción se declara en la guía (§17, nuevo apartado) con su porqué: son apéndices por plataforma, y la mitad de sus ejercicios exigen un Mac con chip M |
| D3 | Docker Desktop | **Sin `a8`.** `a7` cubre los dos runtimes: Colima como el camino por defecto y Docker Desktop en una sección propia, que es además el runtime con el que se validó el paquete (§17.4) |
| D4 | Validación | Todo lo que se pueda, **en contenedores** (§17.5.4). Lo que exige el host —instalar Node 14 x64 con nvm bajo Rosetta, instalar y probar Colima— **no lo corre Claude**: queda marcado «no verificado por ejecución» y como paso manual del autor (H-host) |
| D5 | Tags | Sin bloque 🏷️ en ninguno de los dos: la convención del paquete (`00-convencion-de-git-y-tags.md`, «Los apéndices») dice que los apéndices no cierran con tag. El devcontainer de a7 usa el 💡 de `apendice-a7` opcional que esa convención ya prevé |
| D6 | Diagramas | El flujo «¿hay binario? → compila» de A12 §2 pasa a `flowchart TD` (guía §17.1). La matriz 2×2 de A13 §1 pasa a **tabla** (es una comparación, no un diagrama). Árboles de archivos y salidas de terminal, en texto |
| D7 | Curso puente | Se conserva el recuadro 🧰 de A13 hacia **Docker Legacy Node** (F19, F21–F23), con las rutas relativas recalculadas: desde `01-vue2-legacy/` son `../../../cursos-contenedores-cloud-infra/docker-container-legacy/…` |

---

## 3. 🔬 Hechos ya comprobados (antes de T0)

- **H-0.1 · nvm y Node 14 en arm64.** En `nvm.sh` (0.40.3 en el host del autor; la lógica es la misma de la
  0.39.7 que instala F0), nvm solo cambia a `x64` por su cuenta las versiones **menores que 14.17.0** (y
  las 15.x). Para **14.21.3** pide `darwin-arm64`, que no existe, y cae a compilar Node desde fuente. Esa es
  la «muralla de `gyp ERR!`» que describe F0, y por eso la receta nueva **tiene que forzar x64** (instalar
  desde una shell bajo Rosetta, `arch -x86_64 zsh`). A verificar en host por el autor (H-host-1).
- **H-0.2 · Dependencias nativas del paquete**, leídas de los `package-lock.json` validados
  (`zz-code/vue2-legacy-for-backend-devs-20261014-b44a/`):

  | Árbol | Nativas | Cómo llegan |
  |---|---|---|
  | Tronco F11 (`repo/tiquetera-legacy`) | `fsevents` 1.2.13 y 2.3.3 (opcionales, solo macOS) · `deasync` 0.1.32 | `fsevents` por `webpack-dev-server`/`watchpack`/`sane`; `deasync` por `vue-jest` 3.0.7 (F11) |
  | Ruta Q (`@quasar/app` 1.9.6, D13) | **`node-sass` 4.14.1** · `fsevents` | `node-sass` lo exige `@quasar/app` 1.9.6: es el caso central de A12 §3, aquí solo en la ruta Q |
  | Ruta VU | `deasync` · `fsevents`; `sass` (dart, JS puro) | `vue-cli-plugin-vuetify` |
  | Ruta NX | `deasync` · `fsevents` | — |
  | Backend del Curso 02 | `fsevents` | `bcryptjs` es JS puro; sin `bcrypt` nativo |

  Ningún árbol trae navegador propio (Jest 23 con jsdom, sin Karma). El caso «herramienta que baja su propio
  binario» de A12 §5 lo cubre **mongodb-memory-server 6.9.6** (Curso 02, F13), que no tiene `mongod` 4.4
  para Linux arm64 (guía §17.5.8).
- **H-0.3 · Puertos del paquete:** Vue CLI dev server `8080`, Stubby `8888` (F0), json-server `3000` (F3),
  socket.io `4000` (F8), Express `3000` en el Curso 02. Van al `forwardPorts` del devcontainer.
- **H-0.4 · Colima no está instalado** en el host del autor; Docker Desktop sí (`desktop-linux`, arm64).

---

## 4. 🧭 Mapa de adaptación: de Angular 8 a la Tiquetera

### a6 ← A12 (arm64 / M1)

| A12 | a6 | Qué cambia |
|---|---|---|
| §1 Dónde estás parado | igual | Remite a **F0 🍎** y **A2** en vez de A03 §1.2 |
| §2 Por qué `npm install` compila C++ | igual + inventario | La tabla de H-0.2 con los nombres reales; `find node_modules -name binding.gyp` sobre la F11 |
| §3 `node-sass` en arm64 | **Solo ruta Q** | Opciones A (Rosetta), B (contenedor, a7) y C (`sass` dart sobre `@quasar/app` 1.9.6: experimento). El tronco no tiene Sass |
| §4 `node-gyp` y build tools | igual | `deasync` y `fsevents` 1.x como los casos que compilan en Mac |
| §5 El Chromium de Karma | **reescrita** | «Las herramientas que bajan su propio binario»: mongodb-memory-server (Curso 02 F13) y Cypress, nombrado (F11 lo deja fuera) |
| §6 Diagnóstico | → ⚠️ Diagnóstico rápido | Filas de Karma fuera; entran `deasync`, `fsevents` y el `403 (MongoDB's 404)` |
| §7 Higiene | igual | Ritual `nvm use` → `rm -rf node_modules` → `npm ci`. **Nuevo:** por qué no Node 16: trae npm 8, que reescribe el lockfile v1 del curso a v2 (verificar en T0) |
| 🧭 / ⚠️ / 📚 / 📌 | adaptados | Rosetta con fecha (macOS 28) como pendiente; enlaces de Karma fuera |
| Ejercicios (6) | ~15 (D2) | 🟢🟡🟠🔴, la mitad marcados «requiere Mac con chip M» |

### a7 ← A13 (Docker + Colima)

| A13 | a7 | Qué cambia |
|---|---|---|
| 🧰 recuadro Docker Legacy Node | igual | Rutas recalculadas (D7) |
| §1 La decisión | tabla (D6) | Docker Desktop se queda como opción con sección propia (D3) |
| §2 Los dos Rosetta | igual | Toca el Node 14 de F0, ya no el de A03 |
| §3 Perfil arm64 | adaptado | Imágenes del paquete: `node:14.21.3`, `node:14.21.3-alpine` (A01 del Curso 02), `mongo:4.4` (arm64, Ubuntu 20.04). El caso de «me metí al contenedor y me lo encontré igual» es `node-sass` de la ruta Q |
| §4 Perfil amd64 | adaptado | El caso real y medido: la suite de F13 del Curso 02 con mongodb-memory-server |
| §5 Volúmenes y `node_modules` | igual | Volumen `tiquetera-node-modules`; la trampa del enlace simbólico de §17.5.8 |
| §6 Devcontainer | **reescrito** | `node:14.21.3-bullseye-slim`; `forwardPorts` 8080/8888/3000/4000; dev server con sondeo (`devServer.watchOptions.poll` en `vue.config.js`, o `CHOKIDAR_USEPOLLING`; se decide en T0). Fuera `ng serve` y el Dockerfile de la Fase 13 de Angular |
| — | **§ nueva: Docker Desktop** | Lo que cambia respecto de Colima (contexto `desktop-linux`, Rosetta en Settings, licencia); es lo que usó la validación |
| §7 Construir para la arquitectura | adaptado | La imagen de la API del Curso 02 (A01) y el compose de F14; fuera kind, Fase 14 y A09 |
| §8 Cambiar de runtime | adaptado | Sin kind; el volumen de Mongo del Curso 02 como el dato que no vuelve solo |
| §9 Diagnóstico | → ⚠️ Diagnóstico rápido | Filas de kind y `ng serve` fuera; entran el 8080 que no abre y el `exec format error` de la API |
| Ejercicios (6) | ~15 (D2) | Todos requieren Mac con chip M, salvo los de volumen y `--platform` |

---

## 5. 📋 Tandas

Cada tanda cierra con sus pruebas en verde y su entrada en la bitácora (§7). Las pruebas van en
`zz-code/vue2-legacy-for-backend-devs-20261018-<hex>/`, con su `README.md` de corrida.

### T0 — Ambiente y hechos

- Crear el directorio de `zz-code`, inventario de Docker antes (contenedores, imágenes, volúmenes, redes).
- Desempacar la instantánea de F11 (`salidas/fases/fase-11-testing-minimo.tgz`) y la ruta Q (`rutas/q/tiquetera-q-app1`).
- **Pruebas** (`--label curso=vue2-legacy --label tanda=T0`, puertos solo en `127.0.0.1`):
  1. `npm ci` de F11 en `node:14.21.3` arm64 y en `--platform linux/amd64`: qué compila (`deasync`, `fsevents`), con el log literal.
  2. Igual con la ruta Q: `node-sass` 4.14.1 en arm64 (sin binario: compila o falla) y en amd64 (descarga). Anotar la ruta `vendor/linux-…-83`.
  3. Lo mismo en `node:14.21.3-bullseye-slim` sin build tools: el error de `node-gyp` que a6 §4 debe citar.
  4. `node:16.20.2` + `npm ci` sobre el lockfile v1 de F11: confirmar si npm 8 lo reescribe (argumento de a6 §7).
  5. Devcontainer de a7 §6 construido y corrido a mano (`docker build` + `docker run`): `npm run serve` responde
     desde fuera, el cambio de archivo recarga con sondeo, y `node_modules` en volumen con nombre frente a bind
     mount (tiempo de `npm ci` en los dos).
  6. mongodb-memory-server 6.9.6 en arm64: el `403` literal, y 6/6 en amd64 (repetición corta de §17.4).
- **H-host (autor, a mano, no lo corre Claude):** (1) `arch -x86_64 zsh -c 'source ~/.nvm/nvm.sh && nvm install 14.21.3'`
  y `file $(which node)` en x86_64; (2) instalar Colima, y que los flags de a7 §3–§4 existan en `colima start --help`.

### T1 — Node 14 en el Curso 01

- `00-setup-hola-mundo.md`: línea 24 («Qué queda listo»), tabla de la línea 99 (fila Apple Silicon → 14.21.3
  x64 bajo Rosetta), sección 🍎 reescrita con la receta x64 de H-0.1, la comprobación `node -p process.arch`
  y el enlace a a6/a7; apoyos de la fase y 🔥 de contenedor, si los hay, apuntando a a7.
- `0-plan-del-curso.md:148`, `a2-node.md:43` y `:148`, `forense-fase-00.md:59` (el ⚠️ desaparece: el `.nvmrc` dice 14.21.3 en todas partes).
- **Prueba:** `grep -rn "16\.20" .` en cero en todo el paquete (salvo esta bitácora); los comandos nuevos de F0 que corren en Linux, ejecutados en contenedor.

### T2 — `a6-arm64-m1.md`

- Redactar según §4 y D2, con las salidas literales de T0.
- **Prueba:** cada bloque de comandos ejecutable en Linux, corrido en contenedor; los de macOS, marcados «verificado por el autor» o «no verificado por ejecución».

### T3 — `a7-docker-colima.md`

- Redactar según §4, D3 y D7, con el devcontainer probado en T0.5.
- **Prueba:** el `Dockerfile` y el `devcontainer.json` publicados son byte a byte los que corrieron (§17.5.6); `colima …` queda «no verificado» salvo H-host-2.

### T4 — Enlaces e índices

- `01-vue2-legacy/README.md` (tabla de apéndices, «5 apéndices»), `README.md` del paquete («5 apéndices»),
  `0-ESTRUCTURA-CURSO.md` («Apéndices (A1–A5)», «a1 … a5», la casilla «los 5 apéndices — sin tocar»),
  `0-plan-del-curso.md` (si lista apéndices), guía §13.2 (`a1` … `a7`) y el nuevo apartado de la excepción D2.
- `forense-master.md` §3 (filas de arquitectura → a6/a7), `a2-node.md` (tabla de diagnóstico → a6).
- Curso 02: `00-preliminares.md:186` (⚠️ Apple Silicon), `13-testing-de-api.md:114` (⚠️ mms), `a01-docker.md`
  (un 🧭 hacia a7) y su `README.md:319`.
- `prompts/README.md` si inventaría apéndices.

### T5 — Verificación

- `prompts/verificar-corpus.py` y `--publicacion` en 0 errores.
- Mermaid nuevo exportado con `zz-instrucciones/herramientas/exportar-diagramas.py --motor docker`.
- Enlaces nuevos: URL externas comprobadas; rutas relativas (incluidas las de D7) resueltas con un script.
- `grep -rl "Ã\|â"` en cero; tuteo (guía §4.6) y código en inglés (§5) en los dos apéndices.

### T6 — Cierre

- Guía §17.4: fila nueva con lo que corrió en T0–T3 y lo que quedó «no verificado»; §17.5 si sale una trampa nueva.
- `01-vue2-legacy/README.md` «Cómo se validó»: una línea para a6/a7.
- README de `zz-code` cerrado; contenedores, volúmenes y redes de `tanda=T0` borrados uno a uno (nunca `prune`);
  imágenes nuevas listadas para el autor.
- Borrar este plan **con permiso del autor**.

---

## 6. 📌 Abierto para el autor

- **H-host-1, H-host-1b y H-host-2** (T0): Node 14 x64 con nvm, `npm ci` de F11 en el Mac y los flags de Colima.
  Al correrlos, cambiar «no verificado por ejecución» por «verificado por el autor» en F0 🍎, a6 y a7.
- **Rosetta con fecha** (macOS 28): queda como 📌 en a6 y a7, igual que en Angular 8; sin urgencia.
- Siguen abiertas las del cierre del 18/10 (guía §17.4): D13, incidente 05, H-V3-4, testid de NX0, el nombre Tiquetera.
- Commits: el autor (guía §17.5.7).
- **El total de ejercicios del README del Curso 01**: 915 publicados frente a 911 contados antes de a6/a7 (T4).
- **Angular 8, A13 §4 y §6** (fuera de este plan): el perfil `--arch x86_64 --vm-type vz --vz-rosetta` no cuadra con
  la plantilla de Colima (`rosetta` exige `vz` y una VM arm64); el `postCreateCommand` usa `sudo`, que no existe en
  `bullseye-slim`; y el `apt` de `bullseye-slim` ya falla con 404 (H-T0-6, H-T0-7, H-T3-1).

---

## 7. 🧾 Bitácora

- **2026-10-18** — Plan creado. D1–D7 por defecto. H-0.1 a H-0.4 comprobados sin ejecutar nada (lectura de
  `nvm.sh` y de los lockfiles de `zz-code/…-b44a`). Sigue T0.
- **2026-10-18/19** — **T0 cerrada** en `zz-code/vue2-legacy-for-backend-devs-20261018-fb1d/` (hallazgos H-T0-1 a
  H-T0-11 en su `README.md`). Confirmadas D1–D7; nuevas por el autor: `CHOKIDAR_USEPOLLING` y `archive.debian.org`;
  el A13 §6 de Angular 8 solo se anota. Lo que cambia respecto de §3 y §4:
  - `deasync` 0.1.32 trae precompilados `darwin-x64-node-14` y `linux-x64-node-14`, no `*-arm64-node-14`: en arm64
    compila, en x64 no (H-T0-1). Es el argumento central de F0 🍎 y de a6 §2.
  - Node 16 / npm 8: `npm ci` no toca el lockfile v1; `npm install` sí lo pasa a v2 (H-T0-5). a6 §7 lo dice así.
  - `bullseye-slim`: sin build tools, `deasync` falla en arm64 (H-T0-4); `apt` falla con 404 en `bullseye-security`
    (Debian 11 fuera de LTS, H-T0-6); no hay `sudo` (H-T0-7). El devcontainer usa `archive.debian.org` y crea
    `/workspace/node_modules` en la imagen con dueño `node`.
  - Docker Desktop: recarga con y sin sondeo (H-T0-9); volumen 24–32 s frente a bind 44–90 s en `npm ci` (H-T0-8).
  - La instantánea `backend-k6.tgz` es anterior al `close()` del 18/10: la suite cuelga con ella (H-T0-10).
  - **H-host por defecto (autor, 19/10: «cierra T0 con decisiones default»):** H-host-1, 1b y 2 quedan en §6; la
    receta x64 se publica como «no verificado por ejecución» en macOS. Sí se comprobó en el host, sin instalar
    nada, que `arch -x86_64 zsh -c 'uname -m'` da `x86_64` (lo que lee `nvm_get_arch`) y que Rosetta está instalada.
- **2026-10-19** — **T1 cerrada.** F0 (líneas 24, 99, sección 🍎 reescrita con la receta `arch -x86_64`, salvedad en
  «`.nvmrc`»), `0-plan-del-curso.md`, `a2-node.md` (dos sitios, el de diagnóstico ya apunta a a6) y `forense-fase-00.md`
  (el ⚠️ ahora pide `node -p process.arch`). `16.20` en cero en el paquete. Prueba `t1-nvm-slug.sh`: el `nvm.sh` 0.39.7
  de F0, con `nvm_get_os`/`nvm_get_arch` simulados, pide `node-v14.21.3-darwin-arm64` en `darwin/arm64` y
  `node-v14.21.3-darwin-x64` en `darwin/x64`; `v14.16.1` pasa sola a x64. El ⚠️ «No verificado por ejecución en macOS»
  de F0 dice exactamente eso.
- **2026-10-19** — **T2 cerrada.** `01-vue2-legacy/a6-arm64-m1.md` escrito (🎯 · 📍 · 🧬 con el `flowchart TD` de D6 ·
  🎨 tres salidas · 🔧 · 📥 · 🧹 · 🧭 · ⚠️ · 🧪 15 · 📚). Lo que cambió respecto de §4:
  - **La opción C de §3 dejó de ser experimento**: Dart Sass sobre `@quasar/app` 1.9.6 probado en arm64 sin build tools
    (`npm ci --ignore-scripts`, `sass@1.32.13`, `implementation` en `scssLoaderOptions` **y** `sassLoaderOptions`, y
    `outputStyle: "expanded"` porque Dart rechaza el `"nested"` de Quasar). CSS comparado con el de `node-sass`
    (H-T2-2). Se publica como «funciona y está medida, pero es un cambio al proyecto».
  - **`node-sass` trae `node-gyp` 3.8.0, que solo acepta Python 2** (H-T2-1): el Dockerfile de a7 lleva `python2`
    además de `python3`. Rehechas con la imagen nueva las pruebas de T0.5: `npm ci` en volumen 21,1 s frente a 49,0 s
    en bind, serve y recarga, suite de F11 26/26 dentro del devcontainer, y el `EACCES` sin la carpeta en la imagen.
  - mms 6.9.6 por plataforma (H-T2-3): con Node x64 en macOS pide el `mongod` de Intel, que existe; con arm64, 403.
  - Corrección encontrada al correr los bloques: en un contenedor arm64 `uname -m` dice `aarch64`, no `arm64`.
  - El verificador marca `ROTO` hacia `a7-docker-colima.md` (se resuelve en T3) y `BANDA` 15 (se resuelve en T4).
- **2026-10-19** — **T3 cerrada.** `01-vue2-legacy/a7-docker-colima.md` escrito (🎯 con el recuadro 🧭 · ⚖️ tabla de D6 ·
  🔁 · 🦙 · 🧬 · 🐋 · 📦 · 🧰 · 🏗️ · 🔀 · 🧭 · ⚠️ · 🧪 15 · 📚), armado con `t3-armar-a7.py` desde los archivos que corrieron.
  Verificador del Curso 01: 0 errores. Lo que cambió respecto de §4:
  - **D7 sin enlaces** (autor): el paquete es autocontenido y el verificador da `FUERA`; el recuadro nombra el curso y
    las fases F19, F21–F23 como texto.
  - **Colima, de su plantilla 0.10.3** (`salidas/t3-colima-docs/`): `vmType` por defecto es `qemu`; `rosetta` exige
    `vz` y significa contenedores amd64 dentro de una VM arm64; `virtiofs` solo con `vz`; `mountInotify: false` y
    experimental (por eso `CHOKIDAR_USEPOLLING`). a7 recomienda **un** perfil arm64 con `--vz-rosetta` y
    `--platform linux/amd64` por contenedor; la VM `--arch x86_64` es QEMU. **El A13 §4 de Angular 8**
    (`--arch x86_64 --vm-type vz --vz-rosetta`) no cuadra con eso: pendiente para Angular, junto con su §6.
  - **json-server escucha en `localhost`** (`0100007F:0BB8`): con `docker run -p`, el 3000 no responde desde el Mac;
    `npm run mock -- --host 0.0.0.0` lo arregla. Stubby (F0) y sockets (F8) escuchan en todas las interfaces.
  - **La receta a mano** (`t3-devc-manual.sh`): `docker build` desde la raíz, `docker volume create` antes, mock con
    `--host`, sockets y serve: los tres puertos 200 desde el Mac.
  - **API del Curso 02** (`t3-api-arquitecturas.sh`): `arm64` sin `--platform`, `amd64` con él, `x64` al correrla; sin
    `--platform`, Docker Desktop da `WARNING: The requested image's platform (linux/amd64) does not match…` y la corre.
    El `exec format error` no se reproduce en un Mac con Rosetta: queda descrito, no mostrado. `buildx --push`, no
    verificado (no hay registry).
  - Los datos de Mongo de F14 viven en `./mongo-data` (bind mount): sobreviven a un cambio de runtime.
- **2026-10-19** — **T4 cerrada.** Índices: README del Curso 01 (tabla, «7 apéndices», 945 ejercicios, estado), README
  del paquete, `0-ESTRUCTURA-CURSO.md` (A1–A7, árbol y la casilla), `0-plan-del-curso.md` (6 y 7), `forense-master.md`
  §3 (dos filas). Curso 02: `00-preliminares.md`, `13-testing-de-api.md`, `a01-docker.md` (🧭 nuevo) y su README. Guía:
  §13.2, dos filas de la tabla de §17 y **§17.6 nuevo** (la excepción D2, el ⚠️ «no verificado» y D7 sin enlaces).
  `verificar-corpus.py`: banda (12, 18) para `a6` y `a7`. Verificador, los dos modos: 0 errores; avisos EMOJI 254,
  SIN-SOL 54 (52 + a6 + a7), ORDEN 3.
  - **Cifra heredada:** el README decía 915 ejercicios y el conteo del verificador sobre el Curso 01 da 911 (antes de
    a6/a7). Se publicó 945 = 915 + 30, sin tocar la diferencia, que es anterior a este plan → §6.

- **2026-10-19** — **T5 y T6 cerradas.** T5: verificador en 0 errores en los dos modos; el `flowchart` de a6 exportado
  sin error; 23 URL nuevas con 200 (la de `sass-loader` cambiada por su destino, `github.com/webpack/sass-loader`); la
  página de Apple 102527 confirma macOS 28 como el límite de Rosetta; sin mojibake ni voseo. T6: guía §17.3, §17.4 y
  §17.5 (regla 9); «Cómo se validó» del Curso 01; README y MANIFIESTO de `zz-code/…-fb1d` cerrados; volúmenes
  borrados. **Queda solo borrar este plan, con permiso del autor**, y lo de §6.

---

## 8. ✅ Checklist

Pruebas en `zz-code/vue2-legacy-for-backend-devs-20261018-fb1d/` (hallazgos H-T0-n en su `README.md`).

### Decisiones

- [x] D1–D7 confirmadas por el autor (18/10/2026)
- [x] H-host sin correr: se publica «no verificado por ejecución» (autor, 19/10, «decisiones default»)
- [x] Recarga del dev server en a7 §6: `CHOKIDAR_USEPOLLING` en `containerEnv`, no `watchOptions.poll` (autor, 18/10)
- [x] apt en `bullseye-slim`: fuentes en `archive.debian.org` (autor, 19/10; H-T0-6)
- [x] A13 §6 de Angular 8 (`sudo` inexistente y 404 de apt): solo se anota, no se toca en este plan (autor, 19/10)

### T0 — Ambiente y hechos

- [x] Directorio de `zz-code` creado e inventario de Docker antes (`salidas/t0/inventario-docker-antes.txt`)
- [x] Instantánea de F11 y ruta Q desempacadas (más el backend vivo de `…-b44a` para T0.6)
- [x] T0.1 `npm ci` de F11 en arm64 y amd64 (H-T0-1, H-T0-2: `deasync` compila en arm64, precompilado en amd64)
- [x] T0.2 ruta Q: `node-sass` 4.14.1 compila en arm64 (404 de `linux-arm64-83`), descarga en amd64 (H-T0-3)
- [x] T0.3 `bullseye-slim` sin build tools: los dos `gyp ERR!` literales (H-T0-4)
- [x] T0.4 Node 16.20.2: `npm ci` no toca el lockfile v1; `npm install` lo pasa a v2 (H-T0-5)
- [x] T0.5 devcontainer: build, volumen con dueño `node` sin `sudo`, `npm ci` volumen vs bind, serve con y sin sondeo (H-T0-6 a H-T0-9)
- [x] T0.6 mongodb-memory-server: `403` literal en arm64, 6/6 en amd64 en 7,7 s (H-T0-10)
- [x] Binarios publicados para macOS: Node 14.21.3 y `node-sass` 4.14.1 sin `darwin-arm64` (H-T0-11)
- [x] H-0.1 confirmado en `nvm.sh` 0.40.3 (l. 2363–2371)
- [x] `README.md` y `MANIFIESTO.md` de `zz-code` escritos
- [x] H-host por defecto (19/10): pasan a §6 y lo publicado queda «no verificado por ejecución»; comprobados sin instalar `uname -m` bajo `arch -x86_64` y Rosetta
- [x] H-host-1 (autor, §6, 19/10: `darwin-x64.tar.xz`, `x64`, Mach-O x86_64; nvm 0.40.3): `nvm install 14.21.3` bajo `arch -x86_64`, `file` y `process.arch` en x64
- [x] H-host-1b (autor, §6, 19/10: `deasync` sin `build/`, 26/26; hallazgo: `fsevents` 1.2.13 falla con `invalid mode: 'rU'` por Python 3.13, opcional): `npm ci` de F11 en el Mac (`zz-code/…-fb1d/host-f11`): `deasync` usa `darwin-x64-node-14`
- [x] H-host-2 (autor + Claude, §6, 19/10: 0.10.3; perfil viejo x86_64 borrado; `-p tiquetera` aarch64 con Rosetta, F13 6/6; a7 corregido: `--cpus`, `vz`/`virtiofs` por defecto, `delete --data`): instalar Colima y comprobar los flags de a7 §3–§4 en `colima start --help`
- [x] Entrada de T0 en la bitácora

### T1 — Node 14 en el Curso 01

- [x] `00-setup-hola-mundo.md`: «Qué queda listo», tabla de versiones, sección 🍎 con la receta x64 y enlaces a a6/a7 (y la salvedad en `.nvmrc`)
- [x] `0-plan-del-curso.md:148`, `a2-node.md:43` y `:148`, `forense-fase-00.md:59`
- [x] `grep -rn "16\.20" .` en cero (salvo este plan)
- [x] Comandos nuevos de F0 que corren en Linux, ejecutados en contenedor (`t1-nvm-slug.sh`)
- [x] Entrada de T1 en la bitácora

### T2 — `a6-arm64-m1.md`

- [x] Redactado según §4 y D2, con las salidas literales de T0 (15 ejercicios)
- [x] Bloques ejecutables en Linux corridos en contenedor (`t2-bloques-a6.sh`, `t2-q-dart-sass.sh`)
- [x] Bloques de macOS marcados «no verificado por ejecución» (los de diagnóstico de 📍 sí se corrieron en el Mac: solo lectura)
- [x] Entrada de T2 en la bitácora

### T3 — `a7-docker-colima.md`

- [x] Redactado según §4, D3 y D7, con el devcontainer de T0.5 (D7 sin enlaces: nombrado como texto, autor 19/10)
- [x] `Dockerfile` y `devcontainer.json` publicados byte a byte iguales a los de `zz-code/…-fb1d/devc/` (`t3-byte-a-byte.py`)
- [x] `colima …` marcado «no verificado» salvo H-host-2
- [x] Entrada de T3 en la bitácora

### T4 — Enlaces e índices

- [x] READMEs del Curso 01 y del paquete, `0-ESTRUCTURA-CURSO.md`, `0-plan-del-curso.md`, guía §13.2 y la excepción D2 (guía §17.6, tabla de §17 y banda del verificador)
- [x] `forense-master.md` §3 (dos filas) y `a2-node.md` (diagnóstico → a6, hecho en T1)
- [x] Curso 02: `00-preliminares.md:186`, `13-testing-de-api.md:114`, `a01-docker.md` (🧭), `README.md:319`
- [x] `prompts/README.md`: no inventaría apéndices, sin cambios
- [x] Entrada de T4 en la bitácora

### T5 — Verificación

- [x] `verificar-corpus.py` y `--publicacion` en 0 errores
- [x] Mermaid nuevo exportado con `exportar-diagramas.py --motor docker` (1 diagrama, 0 errores; `salidas/t5-diagramas/`)
- [x] URL externas (23, todas 200; `sass-loader` pasado a su destino final) y rutas relativas (verificador, `ROTO` en 0; D7 ya sin enlaces)
- [x] `grep -rl "Ã\|â"` en cero (salvo el texto de la propia regla); tuteo y código en inglés en a6 y a7

### T6 — Cierre

- [x] Guía §17.3 (línea base: SIN-SOL 54), §17.4 (fila nueva y lo no verificado) y §17.5 (regla 9: las trampas nuevas)
- [x] «Cómo se validó» del Curso 01 con a6/a7
- [x] README de `zz-code` cerrado; volúmenes `tiquetera-node-modules` y `vue2-t0-nm-angular` borrados uno a uno, sin contenedores ni redes; imágenes (`tiquetera-api`, `vue2-t0-devc:arm64`, `vue2-t3-tiquetera-dev`) listadas para el autor
- [x] Pendiente anotado para Angular 8 (A13 §4 y §6), en el README de `zz-code/…-fb1d` (sobrevive al borrado del plan)
- [x] Plan borrado con permiso del autor (19/10, «default»; copia en zz-code)

### Bitácora — H-host (19/10/2026, noche)

- **H-host-1:** `nvm install 14.21.3` bajo `arch -x86_64` (nvm 0.40.3) baja `darwin-x64`; `x64` y Mach-O x86_64. F0 🍎: el ⚠️ pasa a 📝 «Cómo se verificó».
- **H-host-1b:** `deasync` usa `darwin-x64-node-14` (sin `build/`), F11 26/26. Hallazgo: las tres `fsevents` 1.2.13 fallan con `ValueError: invalid mode: 'rU'` (node-gyp 5.1.1 + Python 3.13); opcional, npm sigue. a6 🧬, 🔧 («hasta la 3.10») y diagnóstico corregidos; aviso en F0 🍎.
- **H-host-2:** Colima 0.10.3: `--cpus` (no `--cpu`), `vz` y `virtiofs` ya por defecto. El perfil `default` del autor (junio 2025, `arch: x86_64`, el A13 §4 de Angular) no arrancó: QEMU y `guest agent … Linux-x86_64`; el autor lo borró. Perfil `-p tiquetera`: `aarch64`, Rosetta activo (QEMU desactivado), F13 6/6 en amd64 sobre virtiofs. `colima delete` conserva el disco de datos; `--data` lo borra. a7 🦙, 🧬, 🔀 y diagnóstico corregidos; README §«Cómo se validó» y guía §17.4/§17.6 al día. Verificador 0 errores en los dos modos.

### Bitácora — cierre (19/10/2026)

- **Decisiones por defecto del autor («default»):** (1) el plan se borra, con esta copia en `zz-code/…-fb1d/salidas/plan-apendices-apple-silicon-final.md`; (4) la cifra de 945 ejercicios queda: es la suma de los «(NN)» declarados en los 34 capítulos del Curso 01, y el 911 salió de otro conteo; (5) Angular 8 solo se anota (README de `zz-code/…-fb1d`, con la corrección del A13 §4 ya corrida).
