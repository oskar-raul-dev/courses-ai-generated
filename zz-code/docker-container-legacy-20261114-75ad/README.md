# 🧪 docker-container-legacy-20261114-75ad · cómo correr estas pruebas

> **Curso:** docker-container-legacy · **Tanda:** P0–P7 · **Creado:** 2026-11-14 · **Cerrado:** 2026-11-15
> **Propósito:** la pasada del autor como lector (el curso entero desde cero en macOS) y el apéndice a17.
> El plan, ya cerrado, está copiado en [`plan-de-pasada-final.md`](plan-de-pasada-final.md); los
> hallazgos crudos (V01–V77) en [`hallazgos.md`](hallazgos.md), y su bitácora pública en
> `cursos-contenedores-cloud-infra/docker-container-legacy/prompts/pendientes-a-futuro.md`.

## 1. 🎯 Qué se prueba y para qué

Cada tanda alimenta las fases y los hallazgos de la tabla. El detalle por hallazgo (qué decía el
curso, qué salió, el log) está en `hallazgos.md`, agrupado por tanda.

| Tanda | Documentos del curso | Hallazgos | Logs |
|---|---|---|---|
| P0 | inventario y versiones (guía §5.2) | — | `logs/P0/` |
| P1 | F00–F11, LabCore (PD1), proyecto ajeno (ej. 22) | V01–V14 | `logs/P1/`, `validacion/` |
| P2 | F12–F21, F27 | V15–V25 | `logs/P2/` |
| P3 | F22–F23 (y F21 §6.2) | V26–V29 | `logs/P3/` |
| P4 | F24–F26 con Podman y Docker | V30–V41 | `logs/P4/` |
| P5 | F28–F34, a01–a16 | V42–V68 | `logs/P5/` |
| P6 | a17 (compilar Node en Lima), a07 | V69–V77 | `logs/P6/` |

## 2. 🛠️ Prerrequisitos

MacBook Pro M1 Pro (8 núcleos: 6 de rendimiento y 2 de eficiencia, 32 GB), macOS 26.7.2.
Docker Desktop 29.9.3 (store de containerd, Rosetta, VM de 8 CPU y 8 GiB). Podman 6.1.3 cliente /
6.1.4 servidor, en una máquina aparte `p4-legacy` (libkrun). Lima 2.3.0 y QEMU 11.1.3 (Homebrew) para
el a17. Base del laboratorio: `debian/eol:buster` (digest `sha256:3207f48c…`, multiarquitectura) y los
tarballs oficiales de Node 10.24.1, 12.22.12, 14.21.3 y 16.20.2. Las herramientas de F28–F29 corren
desde sus imágenes: Syft v1.18.1, Trivy 0.58.1, Cosign v2.4.1, actionlint 1.7.4, Buildah 1.37.

## 3. 🧭 Reglas antes de correr

El inventario inicial de Docker está en `logs/P0/00-docker-inventario-inicial.log` (imágenes,
contenedores, volúmenes, redes, builders y `df`). Las pruebas corren en contenedores, sin los puertos
de uso común: el registry de F28 en `127.0.0.1:15000` (el 5000 lo toma AirPlay en macOS), Compose de
a10 en 18300/18929/14444. Los recursos de cada tanda llevan prefijo `p1-`…`p5-`, y los de P6 son las
VM de Lima `p6-node14` y `p6-node26`. La `podman-machine-default` del autor no se toca.

## 4. ▶️ Cómo se corre

La imagen del laboratorio se construye fase a fase con el texto del curso en `lab/` (repositorio
anidado, ignorado por git: se regenera siguiendo F02–F11). Los scripts sueltos:

| Archivo | Para | Qué hace |
|---|---|---|
| `experimentos/ajeno.sh` | F11 ej. 22 | `npm ci`, build, start y `curl` del proyecto ajeno en Node 12 |
| `experimentos/a09.sh` | a09 | Chromium 90 de Debian y los tests de LabCore con Karma |
| `experimentos/f26/bench.sh`, `bucle-8*.sh` | F26 §5.3 y §8 | benchmark cold/warm con los dos motores; el bucle original y el arreglado |
| `experimentos/f24-run-dev/run-dev-podman.sh` | F24 | `run-dev.sh` portado a Podman |
| `experimentos/f31/errores.sh` | F31 | provoca los mensajes del catálogo uno a uno |
| `experimentos/f34/autocheck.sh` | F34 | la autoevaluación del proyecto final |
| `experimentos/a17/corrida.sh NOMBRE PLANTILLA NODE_VERSION VMTYPE` | a17 | crea la VM de Lima, corre `guion.sh` y trae los logs a `logs/P6/<NOMBRE>/` |
| `experimentos/a17/guion.sh` | a17 §4 | el guion de compilación (en el curso: `src/a17-…/compilar-node.sh`) |
| `experimentos/a17/fix-bullseye.sh` | a17 §3 | `sources.list` de seguridad a `archive.debian.org` |
| `experimentos/a17/corrida1-bis.sh` | a17 | segundo intento de Node 14 con el arreglo |
| `experimentos/a17/node26-j5.sh` | a17 §6–§7 | Node 26 con `-j5`: frío sin ccache, caliente, install |
| `experimentos/a17/post.sh VERSION [JOBS]` | a17 §7–§8 | caliente real, `file`/`readelf`/glibc, `process.versions`, `strip`, el oficial al lado |
| `experimentos/a17/sonda.sh` | a17 §5 | el mismo Node oficial con un bucle de CPU, 1 hilo y 8 en paralelo |
| `experimentos/p7-limpieza.sh` | P7 | la limpieza (ver §9) |

Para el a17: `bash experimentos/a17/corrida.sh p6-node26 debian-13 26.13.1 vz` y
`… p6-node14 debian-11 14.21.3 qemu`, desde la raíz de este directorio.

## 5. 📏 Cómo se mide

Docker Desktop con Rosetta para `linux/amd64`; Podman sin Rosetta (amd64 por qemu-user). F26 iguala
las dos VM a 8 CPU / 8 GiB. Los tiempos son de una corrida salvo donde el log muestra varias (F26 ×5
en el arranque, la sonda ×3). El a17 mide con `/usr/bin/time -v` (tiempo real, `%` de CPU y
`Maximum resident set size`), VM de 8 CPU y 12 GiB sin swap; se rehízo la corrida de Node 26 con
`-j5` tras el OOM de `-j8`, y la pasada "caliente" una vez más porque la primera medía una caché a
medio llenar (`CCACHE_DISABLE`, V74). La sonda con `sha256sum` se descartó porque comparaba coreutils
de versiones distintas; vale la del mismo binario de Node (V77).

## 6. 🧮 Los intermedios que amasan la salida

El tiempo de CPU del a17 §5 sale de `Elapsed` × `Percent of CPU` de cada `make-*.log`
(10:37 × 7,71 ≈ 82 min; 1:12:48 × 4,95 ≈ 360 min). Los kB de `time -v` son KiB (2.702.696 → 2,6 GiB).
Las víctimas del OOM: `grep "Killed process" logs/P6/p6-node26-dmesg.log`. La glibc máxima:
`readelf -V node | grep -oE "GLIBC_[0-9.]+" | sort -uV | tail -1`. El resto de las cifras publicadas
se copian tal cual del log que cita cada hallazgo.

## 7. ✅ Qué se espera ver

Las cifras de referencia, con su log, están en `hallazgos.md` (todas del 14/11/2026). Las más citadas:
la matriz de F11 ej. 24 con 12 ceros de 12; F26 cold 137 / 238 s y warm 2,2 / 2,2 s; LabCore en nivel 6
y el proyecto ajeno en nivel 5 (`validacion/`); Node 14 en 10:37 y Node 26 en 1:12:48 (`-j5`).

## 8. 📂 Salidas

No hay `salidas/`: cada tanda escribe en `logs/<tanda>/`, y los expedientes de F11 en `validacion/`.
Al curso se copiaron las salidas literales que cita cada hallazgo, y el guion del a17 a
`src/a17-compilar-node-desde-fuente/`.

## 9. 🧹 Limpieza

Hecha el 15/11/2026 con `experimentos/p7-limpieza.sh`, revisada antes contra el inventario de P0:
contenedor `p5-registry-local`, imágenes y volúmenes de la pasada, `podman machine rm -f p4-legacy`,
`limactl delete -f p6-node14 p6-node26`, los `.tar` y las llaves de prueba. Además se borraron los
volcados OCI de F33 y `~/Library/Caches/lima`. Después: 0 imágenes y 0 volúmenes de la pasada, Lima
sin instancias, `podman-machine-default` intacta.

## 10. 🚫 Qué se dejó fuera

Los `node_modules` (quedan los directorios vacíos que se usaron como punto de montaje): `npm ci`
dentro de la imagen del laboratorio. Los `.tar` de F29 y a13: `docker save` de la imagen. Los
volcados OCI de F33: `skopeo copy` como dice F33. Las llaves de Cosign y la CA de a13: se generan
con los comandos de F29 y a13. Los binarios de Node compilados: `experimentos/a17/corrida.sh`.
El `dist/` del proyecto ajeno: `npm run build` (F11). Los `.git` de `proyectos/labcore`,
`proyectos/ajeno-angular8` (su origen: `https://github.com/t-hnh10/angular-8-app`, commit 4443bf9) y
`experimentos/f34/proyecto` se quitaron el 15/11 para que este repo guarde su contenido y no un
enlace vacío.
