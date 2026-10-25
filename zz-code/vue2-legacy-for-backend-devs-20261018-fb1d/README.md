# 🧪 vue2-legacy-for-backend-devs-20261018-fb1d · cómo correr estas pruebas

> **Curso:** vue2-legacy-for-backend-devs · **Tanda:** T0–T3 del plan de apéndices Apple Silicon · **Creado:** 2026-10-18
> **Propósito:** los hechos que sostienen el paso de F0 a Node 14.21.3 x64 en Apple Silicon y los apéndices
> nuevos `01-vue2-legacy/a6-arm64-m1.md` y `a7-docker-colima.md`.
> Se llena **mientras se prueba**: cada script nuevo entra aquí en la misma sesión. Las reglas, en
> `zz-code/README.md` § "El README de cada directorio". Si una sección no aplica, se dice por qué.

> **Estado: cerrado el 19/10/2026** (T0–T6 del plan de apéndices Apple Silicon). Lo que salió de aquí: la sección 🍎
> de F0, `01-vue2-legacy/a6-arm64-m1.md`, `01-vue2-legacy/a7-docker-colima.md` (armado con `t3-armar-a7.py` desde
> `a7-borrador.md` y `devc/tiquetera-legacy/.devcontainer/`) y las filas nuevas de la guía §17.3–§17.6.
>
> **Pendientes para el curso de Angular 8**, que este plan no tocó: su A13 §4 propone
> `colima start --profile amd64 --arch x86_64 --vm-type vz --vz-rosetta`, y según la plantilla de Colima 0.10.3
> `rosetta` exige `vz` y emula contenedores amd64 dentro de una VM arm64 (una VM x86_64 en Apple Silicon va con QEMU);
> su A13 §6 usa `sudo chown` en el `postCreateCommand`, y `node:14-bullseye-slim` no trae `sudo` (H-T0-7); y el
> `apt-get install` sobre `bullseye-slim` ya falla con 404 si no se apunta a `archive.debian.org` (H-T0-6).
> **Corrido el 19/10 en el Mac del autor (H-H-3):** el perfil `default` de Colima que dejó ese A13 §4 (`arch: x86_64`,
> `vmType: vz`, `rosetta: true`) arranca con QEMU y se cae con `guest agent binary could not be found for Linux-x86_64`
> (lima 2.2.1). La corrección para Angular: quitar `--arch x86_64` y dejar `--vm-type vz --vz-rosetta`.

## 1. 🎯 Qué se prueba y para qué

| Prueba | Script | Alimenta | Hallazgo |
|---|---|---|---|
| T0.1 `npm ci` de F11 en arm64 y amd64 | `t0-npm-ci.sh` | a6 §2, §4 | H-T0-1, H-T0-2 |
| T0.2 `npm ci` de la ruta Q (`node-sass` 4.14.1) | `t0-npm-ci.sh` | a6 §3, a7 §3 | H-T0-3 |
| T0.3 lo mismo en `bullseye-slim` sin build tools | `t0-npm-ci.sh` | a6 §4, a7 §6 | H-T0-4 |
| T0.4 Node 16.20.2 sobre el lockfile v1 | `t0-node16-lockfile.sh` | a6 §7 | H-T0-5 |
| T0.5 devcontainer: apt, volumen, `npm ci`, serve | `t0-apt-bullseye.sh`, `t0-devc-npm-ci.sh`, `t0-devc-serve.sh` | a7 §5, §6 | H-T0-6 a H-T0-9 |
| T0.6 mongodb-memory-server 6.9.6 en arm64 y amd64 | `t0-mms.sh` (y la corrida a mano de §4) | a6 §5, a7 §4 | H-T0-10 |
| Binarios publicados para macOS | `t0-binarios-macos.sh` | a6 §1, §3 | H-T0-11 |
| Regla de nvm (lectura de `~/.nvm/nvm.sh` 0.40.3, l. 2363–2371) | — | F0 🍎, a6 §1 | H-0.1 confirmado |

### Hallazgos

- **H-T0-1 · `deasync` 0.1.32 trae binarios dentro del tarball** (`bin/<plataforma>-node-<major>/`): hay
  `linux-x64-node-14` y `darwin-x64-node-14`, pero **no** `linux-arm64-node-14` ni `darwin-arm64-node-14`
  (de darwin-arm64 solo `node-22`, `-24`, `-26`). En amd64 imprime ``linux-x64-node-14` exists; testing`` /
  `Binary is fine; exiting`; en arm64 compila con node-gyp 5.1.1 (`CXX(target) Release/obj.target/deasync/src/deasync.o`)
  y deja `Installed in /w/node_modules/deasync/bin/linux-arm64-node-14/deasync.node`. En un Mac M con Node 14
  arm64 compilaría; con Node 14 **x64 bajo Rosetta** usa el precompilado `darwin-x64-node-14`.
- **H-T0-2 · `fsevents`** 1.2.13 (tres copias: `watchpack-chokidar2`, `webpack-dev-server`, `sane`) imprime en
  Linux `Skipping 'fsevents' build as platform linux is not supported`; 2.3.3 no corre script. En F11 hay
  4 `binding.gyp` fuera de node-gyp: `deasync` y las tres de `fsevents` 1.x.
- **H-T0-3 · `node-sass` 4.14.1 en la ruta Q.** arm64: `Downloading binary from …/v4.14.1/linux-arm64-83_binding.node`
  → `HTTP error 404 Not Found` → `node scripts/build.js` compila libsass (node-gyp 3.8.0) y deja
  `vendor/linux-arm64-83/binding.node`; `npm ci` total 1 min 42 s. amd64: `Download complete`, `vendor/linux-x64-83/binding.node`,
  `Binary is fine`; 1 min 3 s.
- **H-T0-4 · `bullseye-slim` sin build tools, arm64.** F11 falla en `deasync` con
  `gyp ERR! stack Error: Could not find any Python installation to use` (node-gyp 5.1.1 de npm) y
  `npm ERR! Failed at the deasync@0.1.32 install script.`; la ruta Q falla antes en `node-sass` con
  `gyp ERR! stack Error: Can't find Python executable "python", you can set the PYTHON env variable.` (node-gyp 3.8.0).
  En amd64, F11 pasa sin build tools (precompilado de `deasync`).
- **H-T0-5 · npm 8.19.4 (Node 16.20.2) y el lockfile v1.** `npm ci` instala y **no** toca el lockfile (sigue v1,
  `cmp` igual). `npm install` lo reescribe a **`"lockfileVersion": 2`** (+22.960 líneas, −32). El argumento de a6 §7
  es sobre `npm install`, no sobre `npm ci`.
- **H-T0-6 · Debian 11 fuera de soporte.** `apt-get install` en `node:14.21.3-bullseye-slim` con sus fuentes falla:
  `E: Failed to fetch http://deb.debian.org/debian-security/pool/updates/main/g/glibc/libc6_2.31-13%2bdeb11u14_arm64.deb  404  Not Found`
  (EXIT=100). Funciona quitando `bullseye-security` o apuntando a `archive.debian.org` (las tres fuentes). El
  Dockerfile probado usa `archive.debian.org`. Afecta también al A13 §6 de Angular 8.
- **H-T0-7 · `sudo` no existe en `bullseye-slim`.** El `postCreateCommand` de A13 §6 de Angular
  (`sudo chown -R node:node node_modules && npm ci`) falla: `bash: line 1: sudo: command not found` (EXIT=127), y el
  volumen nace `root root`. Lo resuelve crear `/workspace/node_modules` en la imagen con dueño `node`: el volumen
  vacío hereda dueño al montarse por primera vez (`drwxr-xr-x 2 node node … /workspace/node_modules`).
- **H-T0-8 · `node_modules` en volumen frente a bind mount** (Docker Desktop, arm64, `npm ci` de F11 sin caché de npm):
  volumen 24,4 s y 32,5 s; bind mount 44,1 s y 1 min 30,5 s (la segunda borra antes 39.330 archivos, 315 MB, a través del montaje).
- **H-T0-9 · Dev server en el contenedor.** `npm run serve` (Vue CLI 3) escucha en todas las interfaces sin flags;
  `-p 127.0.0.1::8080` → `curl` 200 desde el Mac. Al tocar `src/main.js` desde el Mac recompila **con y sin**
  `CHOKIDAR_USEPOLLING=true` en Docker Desktop. La variable no es un no-op: la leen las tres copias de chokidar
  del árbol (2.1.8 ×2, 3.6.0); webpack 4.47.0, watchpack 1.7.5. En Colima, no verificado (H-host-2).
- **H-T0-10 · mongodb-memory-server 6.9.6.** arm64: `Error: Status Code is 403 (MongoDB's 404)` /
  `Used Url: "https://fastdl.mongodb.org/linux/mongodb-linux-arm64-debian10-4.4.18.tgz"`, 0,7 s. amd64: 3 suites,
  6/6, Jest termina solo, 7,7 s. **Ojo:** `b44a/salidas/backend-k6.tgz` es del 16/10, anterior al `close()` del 18/10:
  con esa instantánea Jest queda colgado (`Jest did not exit one second after the test run has completed.`). Se usó el
  árbol vivo `b44a/backend/tiquetera-backend`.
- **H-T0-7b · El `EACCES` sin la carpeta en la imagen** (`t0-devc-eacces.sh`): volumen montado en `/proj/node_modules`,
  ruta que la imagen no tiene → `drwxr-xr-x 2 root root`, y `npm ci` como `node` falla con
  `npm ERR! code EACCES` / `EACCES: permission denied, mkdir '/proj/node_modules/babel-core'`.
- **H-T0-12 · El devcontainer definitivo** (con `python2`, ver H-T2-1): `npm ci` de F11 en volumen 21,1 s, en bind 49,0 s
  (tercera ronda); serve 200 y recarga con y sin sondeo; `npm run test:unit` 6 suites, 26/26, con
  `deasync/bin/linux-arm64-node-14` compilado dentro (`t0-devc-test.sh`).
- **H-T0-11 · Binarios para macOS.** `node-v14.21.3-darwin-arm64.tar.gz` 404 y `-darwin-x64` 200 en nodejs.org;
  `node-sass` 4.14.1: `darwin-arm64-83` 404, `darwin-x64-83` 200, `linux-arm64-83` 404, `linux-x64-83` 200.

### Hallazgos de T1 y T2

- **H-T1-1 · La regla de nvm, ejecutada** (`t1-nvm-slug.sh`): con el `nvm.sh` 0.39.7 de F0 y `nvm_get_os`/`nvm_get_arch`
  simulados, `darwin/arm64 v14.21.3 -> node-v14.21.3-darwin-arm64`, `darwin/x64 v14.21.3 -> node-v14.21.3-darwin-x64`,
  `darwin/arm64 v14.16.1 -> node-v14.16.1-darwin-x64`.
- **H-T2-1 · `node-sass` necesita Python 2** (`t2-devc-q.sh`): en la imagen del devcontainer con solo `python3`, la ruta Q
  falla (`gyp ERR! stack Error: Can't find Python executable "python", you can set the PYTHON env variable.`,
  node-gyp 3.8.0). Con `python2` (2.7.18 de Debian 11) compila: `Installed to …/vendor/linux-arm64-83/binding.node`, 1 min 16 s.
  `deasync` (node-gyp 5.1.1 de npm 6) compila con `python3`.
- **H-T2-2 · Dart Sass en la ruta Q, arm64 sin build tools** (`t2-q-dart-sass.sh`): con `npm ci --ignore-scripts`, el build
  tal cual falla con `Error: Node Sass does not yet support your current environment: Linux Unsupported architecture (arm64)
  with Node.js 14.x`. Con `sass@1.32.13` (`--save-exact`) e `implementation: require("sass")` en **`scssLoaderOptions` y
  `sassLoaderOptions`** (el `quasar/dist/quasar.sass` usa la segunda), falla con
  `SassError: Invalid argument(s): Unsupported output style "nested".` (el default de Quasar 1, «required for RTL»).
  Con `sassOptions: { outputStyle: "expanded" }` en las dos: `quasar build` en verde, 4,7 s. CSS frente a `node-sass` en
  amd64 (`t2-q-node-sass-amd64.sh`, `t2-css-compara.py`): 204.616 frente a 203.465 bytes, 2.833 reglas en los dos; tras
  normalizar comentarios y ceros, difieren 15 frente a 2: `@charset "UTF-8"`, un espacio duro literal en vez de `"\00a0"`
  (`.q-skeleton:before`) y 15 bloques `@media (-ms-high-contrast…)` de IE11 que `node-sass` agrupa. No se miró en navegador.
  `--ignore-scripts` en la ruta Q solo se salta, además de `node-sass`, los banners de `core-js`/`core-js-pure`/`ejs` y
  `fsevents` 1.x.
- **H-T2-3 · URL de mms 6.9.6 por plataforma** (`t2-mms-urls.sh`, la clase `MongoBinaryDownloadUrl` del paquete):
  `darwin/x64` → `osx/mongodb-macos-x86_64-4.4.18.tgz` **200**; `darwin/arm64` → `osx/mongodb-macos-arm64-4.4.18.tgz` **403**;
  `linux/arm64` → `linux/mongodb-linux-arm64-debian10-4.4.18.tgz` **403**; `linux/x64` → `…-x86_64-debian10-4.4.18.tgz` **200**.

### Hallazgos de T3

- **H-T3-1 · Colima 0.10.3** (`salidas/t3-colima-docs/`, README, FAQ y `embedded/defaults/colima.yaml` del tag): `vmType`
  por defecto `qemu`; `rosetta` «requires m1 mac and vmType `vz`»; `mountType` `virtiofs` solo con `vz`;
  `mountInotify: false`, experimental. No instalado en el Mac (H-host-2).
- **H-T3-2 · Puertos desde el Mac** (`t3-devc-dev.sh`, `t3-stubby.sh`): con `npm run dev`, 8080 y 4000 responden y 3000
  no (json-server en `127.0.0.1`); con `npm run mock -- --host 0.0.0.0`, los tres. Stubby de F0 escucha en `0.0.0.0`
  (8888, 8889, 7443) y responde 200 a `POST /api/hello`.
- **H-T3-3 · La receta a mano de a7** (`t3-devc-manual.sh`): build desde la raíz, volumen creado antes (nace `node node`),
  `npm ci`, los tres servicios en `docker exec` separados: 8080, 3000 y 4000 con 200.
- **H-T3-4 · API del Curso 02** (`t3-api-arquitecturas.sh`): ver la bitácora del plan. Los tiempos de build no se
  publican (el nativo salió de caché).
- **H-T3-5 · Suite de F13 con los comandos de a7** (`t3-mms-amd64.sh`): `npm ci` amd64 y Jest, 6/6 en 11,0 s.
- **H-T3-6 · a7 armado** con `t3-armar-a7.py` desde `a7-borrador.md`; `t3-byte-a-byte.py`: Dockerfile y `devcontainer.json`
  IGUAL; `t3-jsonc.py`: el `devcontainer.json` parsea. SHA-256 en `salidas/t3-devcontainer-sha256.txt`.

### Hallazgos de los H-host (19/10/2026, en el Mac del autor)

- **H-H-1 · Node x64** (`salidas/h-host-1.txt`): nvm 0.40.3 bajo `arch -x86_64` baja `darwin-x64`; `x64`, Mach-O x86_64.
- **H-H-2 · `npm ci` de F11 en macOS** (`salidas/h-host-1b.txt`, `h-host-1b-fsevents1.txt`): `deasync` sin `build/`,
  26/26. Las tres `fsevents` 1.2.13 fallan con `ValueError: invalid mode: 'rU'`: el `gyp` de node-gyp 5.1.1 usa
  `open(…, 'rU')`, que Python 3.11 eliminó (el Mac tiene 3.13.4). Opcional: npm sigue (`added 1976 packages`).
  Consecuencia: node-gyp 5.1.1 solo compila con Python ≤ 3.10 (Debian 11 trae 3.9, por eso el devcontainer compila).
- **H-H-3 · Colima** (`salidas/h-host-2.txt`): 0.10.3 lista `--cpus` y da `vz` y `virtiofs` por defecto (H-T3-1 venía
  de la plantilla, que sigue diciendo `qemu`). Perfil aparte `-p tiquetera`: `aarch64`, Ubuntu 24.04.4, binfmt
  `rosetta` activo y `qemu-x86_64` desactivado; F13 6/6 amd64 sobre virtiofs (`npm ci` 27,1 s, Jest 7,6 s).
  `colima delete` deja 1,5 GB en `_disks/`; `--data` los borra. Perfil, contexto y disco limpios; queda
  `~/Library/Caches/colima` (321 MB) y la imagen `node:14.21.3-alpine` ya no existe (estaba dentro de la VM).

## 2. 🛠️ Prerrequisitos

Docker Desktop (contexto `desktop-linux`, arm64) con Rosetta para amd64. Imágenes ya presentes antes de la sesión:
`node:14.21.3` (arm64 y amd64), `node:14.21.3-bullseye-slim`, `node:16.20.2`. Árboles de prueba:

- `f11/tiquetera-legacy`: `b44a/salidas/fases/fase-11-testing-minimo.tgz` desempacado.
- `q/tiquetera-q-app1`: copia de `b44a/rutas/q/tiquetera-q-app1` sin `node_modules`, `.quasar` ni `dist`.
- `backend/tiquetera-backend`: copia de `b44a/backend/tiquetera-backend` sin `node_modules`.
- `devc/tiquetera-legacy`: F11 más `.devcontainer/` (el candidato de a7 §6); `devc/bind-copy`: F11 para la medición de bind mount.

## 3. 🧭 Reglas antes de correr

Inventario en `salidas/t0/inventario-docker-antes.txt`. Todo con `--label curso=vue2-legacy --label tanda=T0`,
contenedores `--rm` o borrados con `docker rm -f -v`; puertos solo `-p 127.0.0.1::8080`. Nada cambia en el Mac.

## 4. ▶️ Cómo se corre

Desde este directorio:

```bash
./t0-npm-ci.sh f11-arm64 node:14.21.3 linux/arm64 f11/tiquetera-legacy
./t0-npm-ci.sh f11-amd64 node:14.21.3 linux/amd64 f11/tiquetera-legacy
./t0-npm-ci.sh q-arm64 node:14.21.3 linux/arm64 q/tiquetera-q-app1
./t0-npm-ci.sh q-amd64 node:14.21.3 linux/amd64 q/tiquetera-q-app1
./t0-npm-ci.sh f11-slim-arm64 node:14.21.3-bullseye-slim linux/arm64 f11/tiquetera-legacy
./t0-npm-ci.sh f11-slim-amd64 node:14.21.3-bullseye-slim linux/amd64 f11/tiquetera-legacy
./t0-npm-ci.sh q-slim-arm64 node:14.21.3-bullseye-slim linux/arm64 q/tiquetera-q-app1
./t0-node16-lockfile.sh > salidas/t0/node16-lockfile.log 2>&1
./t0-mms.sh linux/arm64 > salidas/t0/mms-arm64.log 2>&1
./t0-apt-bullseye.sh > salidas/t0/apt-bullseye.log 2>&1
./t0-binarios-macos.sh
docker build --label curso=vue2-legacy --label tanda=T0 -t vue2-t0-devc:arm64 devc/tiquetera-legacy/.devcontainer
docker volume create --label curso=vue2-legacy --label tanda=T0 tiquetera-node-modules
./t0-devc-npm-ci.sh                       # se corrió dos veces; logs -1 y -2
./t0-devc-serve.sh con > salidas/t0/devc-serve-con.log 2>&1
./t0-devc-serve.sh sin > salidas/t0/devc-serve-sin.log 2>&1
```

La suite amd64 de mms se corrió a mano (el `tail` de `t0-mms.sh` escondía el cuelgue de la instantánea vieja):

```bash
docker run --rm --name vue2-t0-mms-amd64c --label curso=vue2-legacy --label tanda=T0 --platform linux/amd64 \
  -v "$PWD/backend/tiquetera-backend:/src:ro" node:14.21.3 bash -c '
  cp -r /src /w && cd /w && npm ci --silent >/dev/null 2>&1; echo EXIT_CI=$?
  time timeout 300 node node_modules/.bin/jest --runInBand --ci 2>&1; echo EXIT_JEST=$?' > salidas/t0/mms-amd64.log 2>&1
```

El patrón de Angular (H-T0-7), a mano: `salidas/t0/devc-patron-angular.log`.

## 5. 📏 Cómo se mide

Tiempos con `time` de bash dentro del contenedor, una corrida por caso salvo H-T0-8 (dos por lado, alternadas
volumen → bind). Sin caché de npm compartida: cada contenedor descarga de nuevo. Mac Apple Silicon del autor,
Docker Desktop con su configuración por defecto. Son órdenes de magnitud para la prosa, no benchmarks.

## 6. 🧮 Los intermedios que amasan la salida

`grep` sobre los logs: `"> deasync@0.1.32 install"`, `"> node-sass@4.14.1 install"`, `gyp ERR!`, `^real`,
`EXIT=`. La lista de binarios sale del `find node_modules -name "*.node"` al final de cada log de `t0-npm-ci.sh`.

## 7. ✅ Qué se espera ver

Lo de §1, del 18–19/10/2026.

## 8. 📂 Salidas

Todo en `salidas/t0/`, un log por prueba con el nombre del primer argumento del script. La carpeta ya no está en disco (comprobado el 25/10/2026): no se versiona y `limpiar.py` la libera como regenerable.
Las cifras de §1 son el registro y los logs de T0 se rehacen con §4. No se rehacen los H-host (`h-host-*.txt`),
que corrió el autor en su Mac, ni el inventario de Docker ni `t6-limpieza.log`, que eran de una sola vez.

## 9. 🧹 Limpieza

**Hecha el 19/10/2026 (T6)**, en `salidas/t6-limpieza.log`: ningún contenedor con `curso=vue2-legacy`; volúmenes
`tiquetera-node-modules` y `vue2-t0-nm-angular` borrados uno a uno con `docker volume rm` (los de T3 se borraron en
su propio script); ninguna red. Nunca `prune`.

**Imágenes que quedan, para el autor** (todas creadas en la sesión, con la etiqueta `curso=vue2-legacy`):
`tiquetera-api:latest` (221 MB), `vue2-t0-devc:arm64` (749 MB), `vue2-t3-tiquetera-dev:latest` (749 MB). Se borran con
`docker rmi tiquetera-api:latest vue2-t0-devc:arm64 vue2-t3-tiquetera-dev:latest`. La caché de build de esas imágenes
también es de la sesión. Las demás imágenes nuevas frente al inventario inicial (`ev-lab/*`, `motoserver/moto`,
`google-cloud-cli`) son de otra sesión y no se tocan.

**En disco**, `node_modules` regenerables en `devc/bind-copy`, `devc/eacces`, `devc/manual` y `backend-t3`
(`limpiar.py` los borra).

## 10. 🚫 Qué se dejó fuera

`node_modules` de `devc/` (se regeneran con `./t0-devc-npm-ci.sh`). Los contenedores de `t0-npm-ci.sh` son `--rm`
y no dejan `node_modules` en el host.
