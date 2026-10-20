# 🧪 angular-8-legacy-for-backend-devs-20261020-9a36 · cómo correr estas pruebas

> **Curso:** angular-8-legacy-for-backend-devs · **Tanda:** T0–T4 del plan Apple Silicon · **Creado:** 2026-10-20
> **Propósito:** los hechos que sostienen la reescritura de A13 §1–§6 y §9 (Colima y devcontainer) del plan
> `prompts/_desechable-plan-apple-silicon.md`: el devcontainer de A13 §6 en arm64 y amd64, las fallas del A13
> publicado, y Dart Sass frente a `node-sass`.
> **Estado: cerrado el 20/10/2026** (T0–T4). Lo que salió de aquí: A13 §1–§9 y sus tablas, ejercicios y pendientes;
> la 🧭 de A14 §3 y dos frases de A14; F0 §5.1 (🍎 Node x64 y el `gyp ERR!` de `fsevents`); A03 §1.2; A12 §1, §2, §3
> (opción C verificada), §6, 🧭, Advertencias y Pendientes; la nota de época de A02 §1.1.
> Se llena **mientras se prueba**: cada script nuevo entra aquí en la misma sesión. Las reglas, en
> `zz-code/README.md` § "El README de cada directorio". Si una sección no aplica, se dice por qué.

## 1. 🎯 Qué se prueba y para qué

| Prueba | Script | Alimenta | Hallazgo |
|---|---|---|---|
| El Dockerfile publicado de A13 §6, byte a byte | `extraer-bloques.py`, `t0-a13-actual.sh` | A13 §6, §9 | H-T0-1 |
| El publicado con solo el parche de apt: `sudo`, `npm ci` | `t0-a13-parche.sh` | A13 §5, §6, §9 | H-T0-2, H-T0-3 |
| Devcontainer candidato: imagen, `npm ci`, build, test (arm64 y amd64) | `t0-devc-build.sh`, `t0-devc-run.sh` | A13 §3, §6 | H-T0-4, H-T0-5 |
| `ng serve` desde el Mac, recarga con y sin `--poll`, sin `--host` | `t0-devc-serve.sh` | A13 §6, §9 | H-T0-6 |
| El candidato sin `python2` (arm64) | `t0-devc-build.sh` sobre `variantes/sin-python2` | A13 §3, §6 | H-T0-7 |
| Qué compilador de Sass elige build-angular 0.803.29 | (comando en §4) | A13 §3, A12 §3 | H-T0-8 |
| Ruta Dart Sass: `npm uninstall node-sass` en arm64 sin `python2` | `t0-dart-sass.sh`, `t0-sass-build.sh` | D4, A13 §3/§6 | H-T0-9 |
| CSS de `node-sass` frente a Dart Sass | `t0-css-compara.py` | D4 | H-T0-10 |
| `node-sass` en el manifiesto con `npm ci --ignore-scripts` | `t0-ignore-scripts.sh` | A13 §3, A12 §3 | H-T0-11 |
| `EACCES` con el volumen de `root` | `t0-devc-eacces.sh` | A13 §5 | H-T0-12 |
| Contenedor amd64 con y sin `--platform` | `t1-plataforma.sh` | A13 §4, §7, ejercicio 3 | H-T1-1 |
| §6 armado desde el borrador y los archivos probados | `t2-armar-a13.py`, `a13-s6-borrador.md` | A13 §6 | — |
| Ediciones de A13 §7–§9, tablas, ejercicios, referencias | `t2-ediciones-a13.py` | A13 | — |
| Receta a mano de A13 §6, extraída del apéndice | `t2-receta-a-mano.sh` | A13 §6 | H-T2-1 |
| Dockerfile y `devcontainer.json` publicados, byte a byte | `t2-byte-a-byte.sh` | A13 §6 | H-T2-2 |

### Hallazgos de T0 (20/10/2026)

- **H-T0-1 · El Dockerfile publicado no construye** (`salidas/t0/a13-actual-build-arm64.log`): el `apt-get install`
  sobre `node:14.21.3-bullseye-slim` falla con
  `E: Failed to fetch http://deb.debian.org/debian-security/pool/updates/main/p/perl/perl-base_5.32.1-4%2bdeb11u5_arm64.deb  404  Not Found`
  y `exit code: 100`. Igual que H-T0-6 de Vue y la trampa 1 de A14 §3.
- **H-T0-2 · `sudo` no existe** (`salidas/t0/a13-parche-arm64.log`): con el bind en `/workspaces/clinical-lab` (como
  `${containerWorkspaceFolder}` de VS Code) el volumen nace `drwxr-xr-x 2 root root`; el `postCreateCommand` publicado
  da `bash: line 1: sudo: command not found`, `EXIT_POSTCREATE=127`.
- **H-T0-3 · `file-saver` por ssh** (mismo log): con el volumen ya de `node` (chown a mano como root), `npm ci` falla en
  `npm ERR! /usr/bin/git ls-remote -h -t ssh://git@github.com/eligrey/FileSaver.js.git` /
  `error: cannot run ssh: No such file or directory`. Es la trampa 3 de A14 §3; antes de llegar a `node-sass`.
- **H-T0-4 · Candidato en arm64** (`salidas/t0/devc-build-arm64.log`, `devc-run-arm64.log`): build 108 s, imagen
  1,49 GB; Python 2.7.18 y 3.9.2, Chromium 120.0.6099.224; volumen nace `node node`. `npm ci` 1 min 29 s:
  `linux-arm64-83_binding.node` → `HTTP error 404 Not Found` → node-gyp 3.8.0 → `Installed to …/vendor/linux-arm64-83/binding.node`;
  `fsevents` 1.2.13 ×4 `Skipping 'fsevents' build as platform linux is not supported`; `added 1612 packages`. `ng build`
  15 s; `ng test --watch=false --browsers=ChromeHeadlessNoSandbox` `TOTAL: 3 SUCCESS` en 7 s.
- **H-T0-5 · Candidato en amd64** (`devc-build-amd64.log`, `devc-run-amd64.log`), `--platform linux/amd64` desde la VM
  arm64 de Docker Desktop: build 164 s, imagen 407 MB; `npm ci` 1 min 5 s con `Binary saved to …/vendor/linux-x64-83/binding.node`
  / `Binary is fine`; `ng build` 1 min 13 s; `ng test` 3/3 en 20 s. El mismo `Hash: dedd5908ff060b6301bb` que en arm64
  (el esqueleto solo tiene `.css`: Sass no participa).
- **H-T0-6 · `ng serve`** (`devc-serve-*.log`): con `--host 0.0.0.0` y `-p 127.0.0.1::4200`, `curl` desde el Mac 200 en
  arm64 y amd64. Tocar `src/app/app.component.html` desde el Mac recompila **con y sin** `--poll 2000` (Docker Desktop
  4.92.0). Sin `--host`: `listening on localhost:4200` y el Mac recibe `000`.
- **H-T0-7 · Sin `python2`** (`devc-sinpy2-npm-ci.log`): `gyp verb check python checking for Python executable "python2" in the PATH`,
  luego `"python"`, y `gyp ERR! stack Error: Can't find Python executable "python", you can set the PYTHON env variable.` /
  `npm ERR! Failed at the node-sass@4.14.1 postinstall script.`, `EXIT_NPM_CI=1`.
- **H-T0-8 · build-angular 0.803.29 elige el compilador** (`salidas/t0/sass-implementacion.log`,
  `src/angular-cli-files/models/webpack-configs/styles.js` l. 103–113): `try { require('node-sass') } catch { require('sass') }`.
  `npm ls node-sass sass`: `sass@1.22.9` cuelga de `@angular-devkit/build-angular`; `node-sass@4.14.1` **solo** del
  manifiesto. A12 §3 opción C dice que `node-sass` «viene arrastrado como dependencia del propio build-angular»: falso.
- **H-T0-9 · Ruta Dart Sass, arm64 sin `python2`** (`salidas/t0/dart-sass-arm64.log`, proyecto `devc/clinical-lab-dart`):
  `npm uninstall node-sass` 27 s, quita la línea del manifiesto y 571 líneas del lock; `npm ci` limpio 17 s,
  `added 1553 packages` (59 menos), sin `gyp`; `COMPILADOR=sass dart-sass 1.22.9`; `ng build` 15 s; `ng test` 3/3.
- **H-T0-10 · El CSS** (`salidas/t0/css-node-sass-vs-dart.txt`, con el Sass de A02 §5.1–§5.2 en `styles.scss` y el de
  §6.3 en el componente): `node-sass` arm64 compilado y amd64 descargado dan `styles.css` **byte a byte igual**
  (257.619 bytes). Frente a Dart Sass: las mismas 2.691 reglas; el CSS del componente idéntico; en `styles.css`
  difieren 30 reglas, de cuatro tipos: redondeo de color en los `darken()` del gris `norange` #757575 (`#5c5b5b` y
  `#242323` en `node-sass`, `#5c5c5c` y `#242424` en Dart; 7 reglas), precisión (`33.33333333%` frente a
  `33.3333333333%`; 13 reglas), orden de los selectores agrupados por `@extend` (`.container…`, 7 reglas; mismo
  conjunto y mismas declaraciones) y `@charset "UTF-8"` con el `— ` literal en `.blockquote-footer::before`. Lo demás
  es forma (`50% / 100%`, `n + 3`, comillas de atributo). No se miró en navegador.
- **H-T0-11 · Caída silenciosa** (`salidas/t0/ignore-scripts-arm64.log`): con `node-sass` en el manifiesto y
  `npm ci --ignore-scripts` en arm64, no hay `vendor/`; `require('node-sass')` lanza
  `Node Sass does not yet support your current environment: Linux Unsupported architecture (arm64) with Node.js 14.x`,
  build-angular lo atrapa y compila con Dart Sass sin avisar: `styles.css` byte a byte igual al de H-T0-9.
- **H-T0-12 · El `EACCES`** (`salidas/t0/devc-eacces.log`): volumen montado en `/proj/node_modules`, ruta que la imagen no
  tiene → `drwxr-xr-x 2 root root`, y `npm ci` como `node`: `npm ERR! code EACCES` / `syscall mkdir` /
  `Error: EACCES: permission denied, mkdir '/proj/node_modules/express'`.
- **Regla de nvm:** F0 no fija versión de nvm, así que no se simuló (`t1-nvm-slug.sh` de Vue); H-H-1 de Vue ya corrió
  nvm 0.40.3 bajo `arch -x86_64` en el Mac.

### Hallazgos de T1 y T2 (20/10/2026)

- **H-T1-1 · amd64 por contenedor** (`salidas/t0/t1-plataforma.log`): `docker info` → `docker-desktop / aarch64 / Docker Desktop`;
  `--platform linux/amd64 node:14.21.3-bullseye-slim` → `x64`. La imagen solo-amd64 `a8-t0-devc:amd64` corrida **sin**
  `--platform`: `WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested`
  y responde `x64`, `EXIT=0`. El ejercicio 3 de A13 (que esperaba un error) se reescribió.
- **H-T2-1 · Receta a mano** (`salidas/t2/receta-a-mano.log`): el bloque de A13 §6 extraído y corrido con cuatro
  sustituciones de prueba (diff en el log): imagen igual a la de T0 (todas las capas en caché), volumen `node node`,
  `npm ci` 1 min 15 s, `ng serve --host 0.0.0.0 --poll 2000` y un Express en el 3000: **200** desde el Mac en los dos.
- **H-T2-2 · Byte a byte** (`salidas/t2/byte-a-byte.log`): Dockerfile y `devcontainer.json` de A13 §6 publicado IGUAL a
  `devc/clinical-lab/.devcontainer/`, mismos SHA-256 que `salidas/t0/devcontainer-sha256.txt`; el JSONC parsea.
- **Verificadores** de `…-20261007-defa` tras T2: `85 documentos · 0 errores` y `0 referencias rotas`.
- **Abierto, sin verificar:** con Rosetta registrada como binfmt en la VM, una imagen amd64 en un pod de kind podría
  arrancar traducida en vez de morir con `exec format error` como dice la ⚠️ de F14 §5.1. No se probó (fuera de alcance).

## 2. 🛠️ Prerrequisitos

Docker Desktop 4.92.0 (contexto `desktop-linux`, motor 29.8.0, `aarch64`) con Rosetta para amd64. Imagen base
`node:14.21.3-bullseye-slim`, bajada en esta sesión para arm64 y amd64 (se había borrado el 19/10). Árbol de partida:
`../angular-8-legacy-for-backend-devs-20261014-amd64/proyecto/clinical-lab` (manifiesto y lock de A03 §8.1, karma con
`ChromeHeadlessNoSandbox` de A14 §7.1), copiado sin `node_modules`, `dist` ni `.devcontainer/amd64`:

- `devc/clinical-lab`: el proyecto más `.devcontainer/` candidato (Dockerfile y `devcontainer.json`).
- `devc/clinical-lab-parche`: el proyecto sin `.devcontainer/`, para `t0-a13-parche.sh`.
- `devc/clinical-lab-sass`: `devc/clinical-lab` con `src/styles.scss` (A02 §5.1–§5.2 más una regla `.lab-banner` con
  aritmética y funciones de color) y `app.component.scss` (A02 §6.3); `angular.json` con el tema `indigo-pink.css` y
  `src/styles.scss` en build y test.
- `devc/clinical-lab-dart`: copia de `-sass` donde `t0-dart-sass.sh` corre `npm uninstall node-sass`.
- `a13-actual/.devcontainer/`: los dos bloques de A13 §6 extraídos del apéndice publicado.
- `a13-parche-apt/Dockerfile`: el publicado con solo las fuentes de `archive.debian.org`.
- `variantes/sin-python2/Dockerfile`: el candidato sin la línea de `python2`.

## 3. 🧭 Reglas antes de correr

Inventario en `salidas/t0/inventario-docker-antes.txt`. Todo lleva `--label curso=angular-8-legacy --label tanda=AS`;
contenedores `--rm` o `docker rm -f -v` por nombre; puertos solo `-p 127.0.0.1::4200`. Nunca `prune`. Nada cambia en el
Mac salvo el `.html` que `t0-devc-serve.sh` toca y restaura (`sed -i '' '$d'`).

## 4. ▶️ Cómo se corre

Desde este directorio, en este orden:

```bash
A13=../../cursos-legacy/angular-8-legacy-for-backend-devs/a13-docker-colima.md
python3 extraer-bloques.py $A13 '# .devcontainer/Dockerfile' a13-actual/.devcontainer/Dockerfile
python3 extraer-bloques.py $A13 '// .devcontainer/devcontainer.json' a13-actual/.devcontainer/devcontainer.json
docker pull -q --platform linux/arm64 node:14.21.3-bullseye-slim
./t0-a13-actual.sh linux/arm64 > salidas/t0/a13-actual-build-arm64.log 2>&1
./t0-a13-parche.sh linux/arm64 > salidas/t0/a13-parche-arm64.log 2>&1
./t0-devc-build.sh linux/arm64 > salidas/t0/devc-build-arm64.log 2>&1
./t0-devc-run.sh linux/arm64 > salidas/t0/devc-run-arm64.log 2>&1
./t0-devc-serve.sh linux/arm64 con > salidas/t0/devc-serve-arm64-con.log 2>&1
./t0-devc-serve.sh linux/arm64 sin > salidas/t0/devc-serve-arm64-sin.log 2>&1
./t0-devc-serve.sh linux/arm64 sinhost > salidas/t0/devc-serve-arm64-sinhost.log 2>&1
docker pull -q --platform linux/amd64 node:14.21.3-bullseye-slim
./t0-devc-build.sh linux/amd64 > salidas/t0/devc-build-amd64.log 2>&1
./t0-devc-run.sh linux/amd64 > salidas/t0/devc-run-amd64.log 2>&1
./t0-devc-serve.sh linux/amd64 con > salidas/t0/devc-serve-amd64-con.log 2>&1
grep -v '^      python2 \\$' devc/clinical-lab/.devcontainer/Dockerfile > variantes/sin-python2/Dockerfile
./t0-devc-build.sh linux/arm64 variantes/sin-python2 a8-t0-devc-sinpy2:arm64 > salidas/t0/devc-build-sinpy2-arm64.log 2>&1
docker volume create --label curso=angular-8-legacy --label tanda=AS a8-t0-nm-sinpy2
docker run --rm --name a8-t0-sinpy2 --label curso=angular-8-legacy --label tanda=AS -u node \
  -v "$PWD/devc/clinical-lab:/workspace" -v a8-t0-nm-sinpy2:/workspace/node_modules a8-t0-devc-sinpy2:arm64 \
  bash -c 'time npm ci > /tmp/ci.log 2>&1; echo EXIT_NPM_CI=$?; grep -E "gyp (ERR|info) (find|stack|node -v|node-gyp -v)|Python|Failed at|code ELIFECYCLE" /tmp/ci.log | head -15' \
  > salidas/t0/devc-sinpy2-npm-ci.log 2>&1
docker volume rm a8-t0-nm-sinpy2
# H-T0-8: qué compilador elige build-angular (con el volumen arm64 que dejó t0-devc-run.sh)
docker run --rm --label curso=angular-8-legacy --label tanda=AS -u node -v a8-t0-lab-node-modules-arm64:/w/node_modules -w /w \
  a8-t0-devc:arm64 bash -c 'grep -rn -B2 -A8 "node-sass" node_modules/@angular-devkit/build-angular/src/angular-cli-files/models/webpack-configs/styles.js | head -40; npm ls node-sass sass' \
  > salidas/t0/sass-implementacion.log
./t0-sass-build.sh linux/amd64 a8-t0-devc:amd64 a8-t0-lab-node-modules-amd64 node-sass-amd64 > salidas/t0/sass-node-sass-amd64.log 2>&1
./t0-sass-build.sh linux/arm64 a8-t0-devc:arm64 a8-t0-lab-node-modules-arm64 node-sass-arm64 > salidas/t0/sass-node-sass-arm64.log 2>&1
./t0-dart-sass.sh > salidas/t0/dart-sass-arm64.log 2>&1
python3 -I t0-css-compara.py devc/clinical-lab-sass/dist/node-sass-amd64 devc/clinical-lab-sass/dist/node-sass-arm64 > salidas/t0/css-node-sass-amd64-vs-arm64.txt
python3 -I t0-css-compara.py devc/clinical-lab-sass/dist/node-sass-amd64 devc/clinical-lab-dart/dist/dart-arm64 > salidas/t0/css-node-sass-vs-dart.txt
./t0-ignore-scripts.sh > salidas/t0/ignore-scripts-arm64.log 2>&1
shasum -a 256 devc/clinical-lab/.devcontainer/Dockerfile devc/clinical-lab/.devcontainer/devcontainer.json > salidas/t0/devcontainer-sha256.txt
./t0-devc-eacces.sh > salidas/t0/devc-eacces.log 2>&1
./t1-plataforma.sh > salidas/t0/t1-plataforma.log 2>&1
# T2: armar A13 (una sola vez, sobre el A13 de antes de T2) y verificar lo publicado
python3 -I t2-armar-a13.py ../../cursos-legacy/angular-8-legacy-for-backend-devs/a13-docker-colima.md
python3 -I t2-ediciones-a13.py ../../cursos-legacy/angular-8-legacy-for-backend-devs/a13-docker-colima.md
mkdir -p salidas/t2
./t2-receta-a-mano.sh > salidas/t2/receta-a-mano.log 2>&1
./t2-byte-a-byte.sh > salidas/t2/byte-a-byte.log
(cd ../angular-8-legacy-for-backend-devs-20261007-defa && CURSO=$PWD/../../cursos-legacy/angular-8-legacy-for-backend-devs python3 -I verificar-curso.py | grep -v '^aviso'; CURSO=$PWD/../../cursos-legacy/angular-8-legacy-for-backend-devs python3 -I verificar-secciones.py | tail -1)
```

Los dos `t2-armar`/`t2-ediciones` no son idempotentes: fallan si sus marcas ya no están (así se evita aplicarlos dos
veces). Además de ellos, en T1–T2 se editaron a mano en A13 el diagrama y la 🧭 de §1, §2, §3, §4, la 🧭 de §6, el
fragmento de §5 y tres líneas sueltas (la ⚠️ de §2 y los ejercicios 1 y 2), y la 🧭 de A14 §3.

Qué hace cada script:

- `extraer-bloques.py <md> <primera línea> <salida>`: copia tal cual el bloque de código del apéndice que empieza
  con ese comentario.
- `t0-a13-actual.sh <plataforma>`: `docker build --no-cache` del Dockerfile publicado; imprime las últimas 60 líneas.
- `t0-a13-parche.sh <plataforma>`: construye `a13-parche-apt`, monta el proyecto como VS Code, corre el
  `postCreateCommand` publicado y luego `npm ci` como `node` tras un `chown` a mano.
- `t0-devc-build.sh <plataforma> [contexto] [tag]`: construye y muestra arquitectura, tamaño, Pythons, Chromium, la
  configuración de git y el dueño de `/workspace/node_modules`.
- `t0-devc-run.sh <plataforma> [proyecto] [tag]`: volumen `a8-t0-lab-node-modules-<arq>` nuevo, `npm ci`,
  `ng build`, `ng test`. Deja el volumen para los dos scripts siguientes.
- `t0-devc-serve.sh <plataforma> <con|sin|sinhost>`: `ng serve` con o sin `--poll 2000` (o sin `--host`), `curl` desde
  el Mac y un `echo >>` al `.html` desde el Mac.
- `t0-sass-build.sh <plataforma> <tag> <volumen> <salida> [proyecto]`: imprime qué compilador resuelve y corre
  `ng build --extract-css --output-path dist/<salida>`.
- `t0-dart-sass.sh`: `npm uninstall node-sass`, diff de manifiesto y lock, `npm ci` limpio, build y test.
- `t0-css-compara.py <dist A> <dist B>`: reglas distintas tras normalizar la forma, emparejadas por selector, y el CSS
  del componente.
- `t0-ignore-scripts.sh`: `npm ci --ignore-scripts` con `node-sass` en el manifiesto, y el build.
- `t0-devc-eacces.sh`: volumen en `/proj/node_modules` y `npm ci` como `node`.
- `t1-plataforma.sh`: `docker info`, un contenedor `--platform linux/amd64` y la imagen amd64 sin `--platform`.
- `t2-receta-a-mano.sh`: extrae la receta de A13 §6, aplica las sustituciones de prueba y la corre.
- `t2-byte-a-byte.sh`: extrae los dos archivos de A13 §6 y los compara con los probados.

## 5. 📏 Cómo se mide

`time` de bash dentro del contenedor, **una corrida por caso**, sin caché de npm compartida (cada contenedor nuevo
descarga todo). Mac Apple Silicon del autor, Docker Desktop 4.92.0 con su configuración por defecto. Los tiempos son
órdenes de magnitud para la prosa, no benchmarks; el `npm ci` de H-T0-9 (17 s) y el de H-T0-4 (1 min 29 s) no se
comparan entre sí como costo de compilar `node-sass`, porque no se aisló la red.

## 6. 🧮 Los intermedios que amasan la salida

`grep` sobre los logs de cada script (los patrones están en los propios scripts): `EXIT_*`, `^real`, las líneas de
`node-sass@4.14.1 install/postinstall`, `gyp ERR!`, `added N packages`, `TOTAL:`, `HTTP desde el Mac`. El diff de CSS lo
amasa `t0-css-compara.py`.

## 7. ✅ Qué se espera ver

Lo de §1, del 20/10/2026.

## 8. 📂 Salidas

`salidas/t0/`, un archivo por prueba con el nombre que da el bloque de §4. Los `dist/` de cada build en
`devc/clinical-lab-sass/dist/` y `devc/clinical-lab-dart/dist/`.

## 9. 🧹 Limpieza

**Hecha el 20/10/2026 (T4)**, en `salidas/t4/limpieza.log`, borrando uno a uno por nombre: los tres volúmenes y las
cinco imágenes de abajo, más `node:14.21.3-bullseye-slim` (no estaba en el inventario inicial). Ningún contenedor
quedó. Inventario final en `salidas/t4/inventario-docker-despues.txt`: frente al inicial solo aparecen
`r16t10-api`, `r16t10-esclusa-api:puro`, `r16t10-migrate` y un volumen anónimo, de la sesión de React 16 que corría en
paralelo; no se tocaron. La caché de build de estas imágenes queda (no se borra sin filtro de etiqueta). Los `dist/`
de `devc/` también se borraron (85 MB, regenerables con §4). Inventario de la sesión antes de borrar: Lo de la sesión, todo con `curso=angular-8-legacy` y `tanda=AS`: imágenes `a8-t0-a13-parche:arm64`,
`a8-t0-devc:arm64`, `a8-t0-devc:amd64`, `a8-t0-devc-sinpy2:arm64`, `a8-t2-clinical-lab-dev`; volúmenes `a8-t0-lab-node-modules-arm64`,
`a8-t0-lab-node-modules-amd64`, `a8-t0-nm-dart-arm64`; las dos variantes de `node:14.21.3-bullseye-slim`. Se borran uno a
uno por nombre.

## 10. 🚫 Qué se dejó fuera

- El devcontainer abierto desde VS Code: se probó lo mismo que hace VS Code (imagen, bind, volumen, usuario,
  `postCreateCommand`) a mano. Colima: no está instalado; lo de Colima viene de la sesión de Vue (H-H-3).
- Dart Sass en amd64 (no aporta: el compilador es JavaScript) y el CSS en navegador.
- T3 sin pruebas nuevas, por decisión del autor («decisiones por default»): la receta de nvm x64 y el `gyp ERR!` de
  `fsevents` vienen de los H-host de Vue (mismas versiones). Quedó **sin comprobar** qué `node-gyp` usa `fsevents`
  1.2.13 en LabCore, que tiene `node-gyp` 3.8.0 en la raíz de `node_modules` (de `node-sass`): por eso F0 y A12 no
  citan el mensaje exacto. Es el H-host opcional del plan: `npm ci` de LabCore en el Mac con Node x64.

**Limpieza final (20/10/2026, cierre del curso):** regenerables borrados con `limpiar.py` y a mano; se conservan `salidas/` (evidencia citada en este README) y las copias de los dos planes borrados del curso: `plan-apple-silicon-final.md` y `plan-de-edicion-a14-a15-final.md`.
