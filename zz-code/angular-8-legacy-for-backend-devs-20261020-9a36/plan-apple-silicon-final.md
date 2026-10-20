# Plan de edición — Apple Silicon: Colima, devcontainer de A13 y Node 14 x64

> Desechable. Se abrió el 19/10/2026 para traer a LabCore lo que la sesión de Apple Silicon de Vue 2
> (`zz-code/vue2-legacy-for-backend-devs-20261018-fb1d/`) dejó anotado para Angular 8.
> Se borra cuando el autor lo autorice. Nada de lo que dice aquí se cita desde el curso.

## 1. Pedido

Oskar, el 19/10/2026: revisar los pendientes de `zz-code/vue2-legacy-for-backend-devs-20261018-fb1d/` y armar un
plan de acción para el curso de Angular 8. Decisiones cerradas por defecto el mismo día.

## 2. Qué está roto

Cuatro problemas. Los dos primeros los dejó anotados el README de `…-fb1d`; los dos últimos salen de los mismos
hallazgos y nadie los había anotado. El punto 2 también es el pendiente (3) del plan anterior
(`_desechable-plan-de-edicion.md`, A14), y el punto 3 cubre su pendiente (4), el camino B de `node-sass`.

1. **A13 §4 · perfil amd64 de Colima imposible.** `colima start --profile amd64 --arch x86_64 --vm-type vz --vz-rosetta`
   no existe como combinación: `rosetta` exige `vz`, y `vz` solo virtualiza la arquitectura del Mac; una VM x86_64
   va por QEMU (H-T3-1, plantilla de Colima 0.10.3; corrido en el Mac, §2.1). Lo repiten el diagrama del §1, el 💡 del §4, la fila del §9,
   «Cuándo usar qué» y el ejercicio 6.
2. **A13 §6 · el devcontainer no arranca.** `apt-get` sobre `bullseye-slim` da 404 (H-T0-6); el `postCreateCommand`
   usa `sudo`, que la imagen no trae (H-T0-7, `EXIT=127`); faltan `ca-certificates` y la reescritura de git para
   `file-saver` (trampas 2 y 3 de A14 §3). A14 §3 lo dice en su nota 🧭 («No lo corregimos aquí…»).
3. **A13 §3/§6 · `node-sass` en arm64 pide Python 2.** El perfil por defecto de A13 es arm64; ahí `node-sass`
   4.14.1 no tiene binario (`linux-arm64-83` 404) y compila con node-gyp 3.8.0, que no acepta Python 3
   (H-T0-3, H-T2-1). El Dockerfile solo instala `python3`.
4. **F0 §5.1, A03 §1.2, A12 §1/§3 · `nvm install 14.21.3` en un Mac M no da Node x64.** nvm solo fuerza x64 por
   debajo de 14.17.0 (H-T1-1); con 14.21.3 pide `darwin-arm64` (404, H-T0-11) y compila Node arm64 desde
   fuentes. El curso da por hecho el x64 bajo Rosetta y nunca dice cómo instalarlo.

### 2.1 Lo que se corrió en el Mac de Oskar el 19/10/2026 (noche), en la sesión de Vue

Hallazgos H-H-1 a H-H-3 del README de `zz-code/vue2-legacy-for-backend-devs-20261018-fb1d/` y bitácora «H-host» de la
copia del plan de Vue en esa misma carpeta (`plan-apendices-apple-silicon-final.md`). Las salidas textuales
(`salidas/h-host-*.txt`) se borraron en la limpieza del 19/10; lo que importa está citado aquí. Valen para Angular porque son las mismas versiones (Node 14.21.3, npm 6.14.18, Colima 0.10.3):

- **Punto 4 verificado en el Mac.** `arch -x86_64 zsh -c 'source ~/.nvm/nvm.sh && nvm install 14.21.3'` (nvm 0.40.3)
  baja `node-v14.21.3-darwin-x64.tar.xz`; `node -p process.arch` → `x64`; `file` → `Mach-O 64-bit executable x86_64`.
- **Punto 1 verificado en el Mac, no solo en la plantilla.** El perfil `default` que dejó A13 §4 en el Mac de Oskar
  (junio de 2025: `arch: x86_64`, `vmType: vz`, `rosetta: true`) arranca con **QEMU** aunque diga `vz` y se cae con
  `guest agent binary could not be found for Linux-x86_64` (lima 2.2.1; pista: `lima-additional-guestagents`).
  Oskar lo borró. Un perfil aparte `colima start -p … --vm-type vz --vz-rosetta --mount-type virtiofs --cpus 4
  --memory 8` arranca `aarch64`, con binfmt `rosetta` activo y `qemu-x86_64` desactivado, y corre contenedores
  `--platform linux/amd64` traducidos por Rosetta.
- **Colima 0.10.3, `--help`:** el flag es `--cpus` (`--cpu` se acepta, pero no está listado); `vz` y `virtiofs` ya son
  los valores por defecto (la plantilla todavía dice `qemu`); un perfil existente descarta los flags que no puede
  cambiar (`'volume mount type' cannot be updated after initial setup, discarded`); `colima delete` conserva el
  disco de datos (1,5 GB) y `colima delete --data` lo borra.
- **Nuevo: `fsevents` 1.x en macOS con Python ≥ 3.11.** El `gyp` de node-gyp 5.1.1 (npm 6) abre con `'rU'`, que
  Python 3.11 eliminó: `ValueError: invalid mode: 'rU' while trying to load binding.gyp`. Es opcional y npm sigue,
  pero el alumno ve un muro de `gyp ERR!`. **El lock de LabCore lo trae** (`zz-code/…-20261014-amd64/proyecto/
  clinical-lab`): `fsevents` 1.2.13 opcional ×4 (`@angular/compiler-cli`, `karma`, `watchpack-chokidar2`,
  `webpack-dev-server`) más la 2.3.3. Va en F0 §5.1 y A12. Mismo motivo: node-gyp 5.1.1 solo
  compila con Python ≤ 3.10 (Debian 11 trae 3.9; un host con 3.11+ no compila nada con él).
- **Colima ya no está instalado** en el Mac de Oskar (desinstalado con `lima` y `qemu` el 19/10). Una prueba de
  Colima para Angular exige reinstalarlo; con lo de arriba, no hace falta.
- **Docker Desktop 4.92.0 sí propaga los eventos de archivo** (en Vue, la recarga funcionó con y sin sondeo); en
  Colima, `mountInotify: false` (experimental) los corta. El `--poll` de A13 §6 sigue haciendo falta para Colima;
  en Docker Desktop es opcional. A13 lo puede decir así.
- **Imágenes borradas el 19/10** en la limpieza de Vue: `node:14.21.3-bullseye-slim` y `mongo:4.4` ya no están en
  el Mac. T0 las vuelve a bajar (la primera es la base de F13 y de A14); `node:14.21.3` sigue (la usa `r16t7-app`).

### 2.2 Una salida que Vue probó y Angular no: Dart Sass en vez de `node-sass`

En Vue, la ruta Q compiló en arm64 sin compilador ni Python cambiando `node-sass` por `sass` (Dart Sass), con el
mismo CSS salvo la forma. LabCore tiene un caso más fácil: su lock **ya trae** `sass` 1.22.9 (dependencia de
`@angular-devkit/build-angular` 0.803.29, con `sass-loader` 7.2.0), y `node-sass` 4.14.1 está en el manifiesto de
A03 §8.1 por decisión propia. A probar en T0, sin suponer: si el CLI 8 usa `node-sass` cuando está instalado y
`sass` cuando no, quitarlo del manifiesto elimina el punto 3 entero (ni Python 2 ni compilación en arm64) y el
devcontainer no necesitaría `python2`. Comparar el CSS de `ng build` con y sin `node-sass` (como
`t2-css-compara.py` de Vue). Si funciona, queda como **D4, abierta para Oskar**: quitar `node-sass` del manifiesto o
dejarlo y documentar las dos salidas.

## 3. Decisiones (cerradas por defecto, Oskar, 19/10/2026)

- **D1 · Alcance:** los cuatro puntos de §2. Se levanta para Angular el «solo se anota» de la sesión de Vue.
- **D2 · Devcontainer de A13:** patrón de Vue a7, sin `sudo`: `node_modules` creado en la imagen con dueño `node`,
  `workspaceMount` y `workspaceFolder` en `/workspace`. A14 queda como está, salvo su nota 🧭 de §3.
- **D4 · `node-sass` o Dart Sass (abierta por T0; cerrada por defecto, «decisiones por default» de Oskar, 20/10/2026):** T0 confirmó
  que build-angular 0.803.29 hace `try { require('node-sass') } catch { require('sass') }` y que el lock ya trae
  `sass` 1.22.9; sin `node-sass` en el manifiesto, arm64 instala sin `python2` ni compilación y el CSS cambia poco
  (§9, H-T0-9/10). **Default aplicado en T2:** `node-sass` se queda en el manifiesto de A03 §8.1 (A02 entero está
  escrito sobre él) y el devcontainer trae `python2`; Dart Sass queda documentado como salida verificada, que T3 lleva
  a A12 §3 opción C. La alternativa —quitarlo del manifiesto— toca A03 §8.1, A02, A12 y la línea `python2` de A13 §6.
- **D3 · Bitácora:** este archivo. El plan anterior (`_desechable-plan-de-edicion.md`) sigue esperando el permiso
  del autor para borrarse; sus cinco pendientes ya están absorbidos aquí (§8) y no tiene trabajo abierto.

## 4. Reglas de prueba

Todo en contenedores, con `--label curso=angular-8-legacy --label tanda=AS`; puertos solo `127.0.0.1::PUERTO`;
nunca `prune`; se borra solo lo que esta sesión creó; inventario de Docker al empezar y al terminar. Directorio
nuevo con `python3 zz-code/nuevo.py angular-8-legacy-for-backend-devs --tanda T0 --proposito "…"`; árbol de partida:
`zz-code/angular-8-legacy-for-backend-devs-20261014-amd64/proyecto/clinical-lab` (manifiesto y lock de A03 §8.1).
Lo publicado se corre byte a byte (como Vue: SHA-256 del Dockerfile y del `devcontainer.json` en `salidas/`).
Lo que solo se prueba en el Mac ya se corrió para Vue (§2.1) y se cita desde allí; el único H-host que queda es
opcional: `npm ci` de LabCore en el Mac con Node x64 (`node-sass` con su binario `darwin-x64-83`, `fsevents`).
Sin commits (git lo maneja Oskar).

## 5. Tandas

- **T0 · Pruebas en contenedor.** Inventario inicial. Devcontainer candidato de A13 §6 (archive.debian.org,
  `ca-certificates`, `python2` + `python3`, `make`/`g++`, `git` con `insteadOf` a https, Chromium,
  `/workspace/node_modules` de `node`): build y `npm ci` en **arm64** (con `node-sass` compilado, tiempo) y en
  **amd64**; `ng build`; `ng test` con `ChromeHeadlessNoSandbox`; `ng serve --host 0.0.0.0` con `curl` 200 desde
  el host; recarga con `--poll`. Reproducir las fallas del A13 §6 actual (404, `sudo`, Python 2) para citarlas
  textuales. Imagen amd64 con `--platform linux/amd64` desde la VM arm64 de Docker Desktop. La prueba de Dart
  Sass de §2.2 (arm64 sin `python2`, CSS comparado). La regla de nvm ya no hace falta simularla: la instalación
  x64 se corrió en el Mac (§2.1); solo si el F0 de Angular fija otra versión de nvm, `t1-nvm-slug.sh` de Vue.
- **T1 · A13 §1, §2, §4, §9, «Cuándo usar qué», ejercicio 6.** Modelo «VM arm64 con `--vz-rosetta` +
  `--platform linux/amd64` por contenedor»; la VM `--arch x86_64` queda como último recurso, con QEMU. Flags con
  `--cpus` y el 📝 «Cómo se verificó» de Vue a7 (§2.1), no la ⚠️ de «no verificado»; la falla del perfil x86_64
  (QEMU + `guest agent … Linux-x86_64`) va al diagnóstico de A13, con el arreglo (`colima delete` o `-p` aparte).
  `colima delete` frente a `--data` donde A13 hable de borrar el perfil.
- **T2 · A13 §5–§6.** Dockerfile y `devcontainer.json` probados en T0, byte a byte; detalles con intención (por qué
  `python2` —o por qué no, si D4 quita `node-sass`—, por qué la carpeta en la imagen); receta a mano sin VS Code
  si cabe. `--poll`: necesario en Colima, opcional en Docker Desktop (§2.1). Nota 🧭 de A14 §3 y la ⚠️ de A13
  §3 sobre `node-sass` en arm64 ajustadas.
- **T3 · Node x64 en un Mac M.** `arch -x86_64 zsh -c 'source ~/.nvm/nvm.sh && nvm install 14.21.3'` y la
  comprobación `node -p process.arch` → `x64` en F0 §5.1; A03 §1.2 y A12 §1/§3 (opción A) y su diagnóstico.
  Verificado en el Mac (§2.1): se publica con 📝, no con ⚠️. Más el aviso del `gyp ERR!` de `fsevents` 1.2.13
  (§2.1: el lock de LabCore lo trae).
- **T4 · Cierre.** Referencias cruzadas a A13 §2/§4/§6 (A12, A14, F0, F13, README); «Pendientes sugeridos» de A13;
  `verificar-curso.py` y `verificar-secciones.py` de `zz-code/…-20261007-defa`; README del directorio de zz-code;
  limpieza e inventario final; memoria.

## 6. Criterios de cierre

- Cada bloque nuevo o tocado de A13 se corrió en T0 y su salida está en `salidas/` del directorio de zz-code.
- `npm ci`, `ng build`, `ng test` y `ng serve` pasan en el devcontainer, en arm64 y en amd64.
- Ningún texto del curso combina `--arch x86_64` con `--vz-rosetta`.
- Verificadores en 0 errores y 0 referencias rotas.
- El H-host opcional de §4 listado para Oskar; D4 decidida si T0 la abre.

## 7. Fuera de alcance

- A14 y A15, salvo la nota 🧭 de A14 §3.
- El curso de contenedores (`cursos-contenedores-cloud-infra/`).
- El track BE.

## 8. Estado

- [x] D1–D3 cerradas por defecto (19/10/2026).
- [x] T0 · Pruebas en contenedor (20/10/2026). Directorio `zz-code/angular-8-legacy-for-backend-devs-20261020-9a36/`
  (vigente), hallazgos H-T0-1 a H-T0-12 en su README.
- [x] T1 · A13 Colima (20/10/2026).
- [x] T2 · A13 devcontainer (20/10/2026). Byte a byte IGUAL; verificadores 0 errores y 0 referencias rotas.
- [x] T3 · Node x64 (20/10/2026).
- [x] T4 · Cierre (20/10/2026). Verificadores 0 errores y 0 referencias rotas; limpieza hecha; zz-code …9a36 archivado.
- [x] D4 cerrada por defecto (20/10/2026).

**Plan cerrado el 20/10/2026.** Queda para el autor: borrar este plan y el anterior (`_desechable-plan-de-edicion.md`),
el H-host opcional de §4 (`npm ci` de LabCore en el Mac con Node x64: confirma el mensaje de `fsevents` con el
`node-gyp` 3.8.0 que trae `node-sass`), el pendiente de kind con Rosetta (A13 §📌), y los pendientes (1), (2) y (5)
de abajo.

**Pendientes absorbidos del plan anterior** (`_desechable-plan-de-edicion.md`, A14/A15, cerrado el 14/10/2026;
se borra con permiso del autor):

- (1) Decidir si el lockfile de LabCore se versiona y de dónde sale (hoy se genera en A14 §6.4). Decisión del autor.
- (2) El breakpoint en la interfaz de VS Code (A15 §5, manual) y los breakpoints de specs en Chromium (A15 §4, sin
  probar). Paso manual del autor.
- (3) y (4) ya eran los puntos 2 y 3 de §2.
- (5) Los commits los hace Oskar.

## 9. Bitácora

**T0 (20/10/2026).** Todo en Docker Desktop 4.92.0, arm64 y `--platform linux/amd64`, sobre la copia de
`…-20261014-amd64/proyecto/clinical-lab`. Lo publicado de A13 §6 falla en cadena: apt 404 (H-T0-1), `sudo` 127 con el
volumen `root root` (H-T0-2) y `npm ci` en `ssh://git@github.com/eligrey/FileSaver.js.git` (H-T0-3); sin `python2`,
`Can't find Python executable "python"` en `node-sass@4.14.1 postinstall` (H-T0-7). El candidato pasa en arm64
(`npm ci` 1 min 29 s compilando `node-sass`, `ng build` 15 s, `ng test` 3/3 en 7 s) y en amd64 (1 min 5 s, 1 min 13 s,
20 s); `ng serve` 200 desde el Mac y recarga con y sin `--poll`; sin `--host`, `000`. Dart Sass (§2.2): build-angular
cae en `sass` si `node-sass` no carga, también **en silencio** con `npm ci --ignore-scripts` (H-T0-11); con
`npm uninstall node-sass`, 59 paquetes menos y sin `gyp`; el CSS frente a `node-sass` difiere en 30 de 2.691 reglas
(redondeo de `darken()` en el gris `norange`, precisión, orden de `@extend`, `@charset`), el del componente igual.
Abre D4. **`node-sass` no viene de build-angular** (`npm ls`): A12 §3 opción C dice lo contrario → T3.
F0 no fija versión de nvm: no se simuló la regla.

**T1–T2 (20/10/2026).** A13: diagrama y 🧭 de §1 (VM arm64 + Rosetta, amd64 por contenedor); §2 (Rosetta solo en una
VM de la arquitectura del Mac, y Docker Desktop); §3 con `brew install`, `--vz-rosetta`, `--cpus`, cuatro detalles y el
📝 «Cómo se verificó» (Colima de la sesión de Vue, devcontainer en Docker Desktop); §4 reescrito («amd64: por
contenedor, no por máquina», tabla de tiempos de T0, VM `--arch x86_64` como último recurso con QEMU y la ⚠️ del perfil
viejo con `guest agent … Linux-x86_64`); §5 con el destino `/workspace/node_modules` y el `EACCES`/`sudo`; §6 con los
dos archivos byte a byte, nueve detalles con intención, 📝 «Cómo se probó» y la receta a mano (probada: 200 en 4200 y
3000); §7 con el `WARNING` de plataforma; §8 con `colima delete` frente a `--data`; §9 con ocho filas nuevas;
«Cuándo usar qué», Advertencias, Referencias (FAQ de Colima, Dev Containers, archive.debian.org), ejercicios 1, 2, **3**
(esperaba un error que con Rosetta no sale: H-T1-1) y 6, y el pendiente de tiempos. A14 §3: la nota 🧭.
Queda para T4: los `prompts/` que dicen «perfiles arm64 y amd64+vz-rosetta» (propuesta-fases-y-alcance, prompts-de-
redacción, prompts-extendidos-apendices) y, sin verificar, si un pod de kind con Rosetta en la VM muere de verdad con
`exec format error` (⚠️ de F14 §5.1).

**T3 (20/10/2026), sin pruebas nuevas por «decisiones por default».** F0 §5.1: bloque 🍎 con `softwareupdate
--install-rosetta`, `arch -x86_64 zsh -c 'source ~/.nvm/nvm.sh && nvm install 14.21.3'`, `node -p process.arch` → `x64`,
qué hacer si dice `arm64`, 📝 «Cómo se verificó» (H-H-1 de Vue, nvm 0.40.3) y ⚠️ del `gyp ERR!` de `fsevents` (genérico:
no se cita el mensaje, porque en LabCore el `node-gyp` hoisted es el 3.8.0 de `node-sass` y no se comprobó cuál usa
`fsevents`). A03 §1.2: «14.21.3, en x64», con el porqué y la remisión a F0. A12: ⚠️ en §1 (nvm compila arm64), párrafo de
`fsevents` en §2 (cuatro copias de la 1.2.13, opcional), opción A remite a F0, opción B al devcontainer con `python2`,
**opción C reescrita** con lo de T0 (build-angular cae en `sass` 1.22.9; `node-sass` solo viene del manifiesto;
`npm uninstall node-sass`; 30 de 2.691 reglas; caída silenciosa con ⚠️), dos filas en §6, la fila del 🧭, la
Advertencia y el Pendiente. A02 §1.1: la nota de época ya no dice «experimento sin verificar».

**T4 (20/10/2026).** A14: la ruta de Colima en la intro y el árbol de §5 (`Dockerfile` de A13 en `.devcontainer/`).
`prompts/` (propuesta-fases-y-alcance, prompts-de-redaccion, prompts-extendidos-apendices): «VM arm64 con Rosetta y
amd64 por contenedor». A13 §📌: el Node 14 con Dart Sass como salida, y el pendiente nuevo de kind con Rosetta (⚠️ de
F14 §5.1, sin verificar). README, F13 y forense-master no necesitaban cambios. Ningún texto combina `--arch x86_64`
con `--vz-rosetta` salvo la ⚠️ de A13 §4 que lo prohíbe. Verificadores de `…-20261007-defa`: 85 documentos, 0 errores;
0 referencias rotas. Limpieza: 3 volúmenes, 5 imágenes de la sesión y `node:14.21.3-bullseye-slim`, por nombre; lo
nuevo del inventario final (`r16t10-*`, un volumen anónimo) es de la sesión de React 16 y no se tocó; la caché de
build queda. `dist/` de zz-code borrados.

**Anexo kind con Rosetta (20/10/2026, después del cierre).** Pedido de Oskar. Directorio
`zz-code/angular-8-legacy-for-backend-devs-20261020-8dfa/`. Con kind v0.33.0, `kindest/node:v1.27.3` y Docker Desktop
4.92.0, un pod con imagen solo-amd64 corre (`Running`, `x86_64`, proceso `/run/rosetta/rosetta …`); Node 14.21.3 amd64
en un pod responde `x64`. La VM tiene registrados Rosetta **y** `qemu-x86_64`. La ⚠️ de F14 §5.1 era falsa: corregida
junto con A09 §7, A12 §6, A13 §3/§7/§9 (pendiente de kind quitado), forense-fase-14 y forense-master. Verificadores 0/0.
Observación sin publicar: el `rosetta-wrapper` agrega `--no-opt` a `node`. El H-host de `npm ci` quedó preparado en
`host-npm-ci.sh` de ese directorio. Limpieza hecha (cluster, 3 imágenes de prueba y `kindest/node:v1.27.3`).

**H-host corrido por Oskar (20/10/2026, 09:39).** `host-npm-ci.sh` de …8dfa: Node 14.21.3 x64, `npm ci` 243 s y 0 errores,
`node-sass` con `darwin-x64-83` descargado, `fsevents` 1.2.13 ×4 con el `node-gyp` 5.1.1 de npm y `ValueError: invalid mode: 'rU'`,
`ng build` 26 s. F0 §5.1 y A12 §2 citan ya el mensaje exacto; F0 suma un 📝 por una espera de más de 3 min sin CPU antes del
clon de `file-saver` (causa probable: `git://`, sin probar). Verificadores 0/0. No queda trabajo de pruebas en este plan.
