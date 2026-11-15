# 🧪 Plan de la pasada (desechable)
## Docker Legacy Node

> **Qué es:** el plan de trabajo de la pasada que pide [`pendientes-a-futuro.md`](pendientes-a-futuro.md):
> tomar el curso como lector, desde cero, en macOS, montar todos los contenedores, rehacer todas las
> pruebas y escribir el a17. Desechable: se borra, con permiso de Oskar, al cerrar P7, con copia en
> el directorio de zz-code de la pasada. No se cita desde el curso.
> **Abierto:** 14/11/2026.

## 🧭 Reglas

1. **En secuencia, por tandas**, y se para al cerrar cada una para que Oskar la revise.
2. **Desde cero y como lector.** La imagen se construye fase a fase con el texto; `src/` solo se usa
   para compararse al cerrar un tramo. Copiar de `src/` invalida la prueba.
3. **Toda diferencia** va a la bitácora de `pendientes-a-futuro.md` (fecha, fase, qué decía, qué
   salió) y de ahí al documento. Una cabecera gana **fecha de verificación ejecutada** solo si se
   corrió de verdad. Las cifras no se pisan si caen dentro de la variación publicada.
4. **Pruebas en contenedor, sin puertos por defecto.** Inventario de Docker al abrir; al cerrar se
   borra solo lo que creó la pasada, comparando por ID. Nunca recursos ajenos.
5. **Pruebas en zz-code**, en el directorio de la pasada. Los logs de cada tanda en `logs/<tanda>/`.
6. **Git lo maneja Oskar**: nada de commits ni índice; borrar con `rm`.

## 🗳️ Decisiones (por defecto, 14/11/2026)

| ID | Decisión | Valor |
|---|---|---|
| PD1 | El "proyecto real" de F11 (ejercicios 7–9 y 21) | **LabCore** (Angular 8), copia de `zz-code/angular-8-legacy-for-backend-devs-20261020-8dfa/host-labcore/` con su `package-lock.json` |
| PD2 | El proyecto ajeno del ejercicio 22 de F11 | un proyecto público archivado de GitHub (Vue 2, Angular 8 o React 16), solo clonado; se anota cuál en la bitácora |
| PD3 | El registro de F28 y los apéndices de registros | `registry:2` local en un puerto no estándar. Nada se publica en GHCR, GitLab ni Docker Hub, ni se firma sin llave (OIDC): eso queda "no verificado" |
| PD4 | El a17 | solo las corridas 1 y 3 (macOS arm64, Lima); las corridas 2 y 4 (Windows amd64) quedan "no verificado". **Ajustada en P6:** la corrida 1 (Debian 11) fue con `qemu` porque la plantilla no arranca con `vz` (Oskar instaló QEMU); la 3 fue en Debian 13 trixie, no bookworm (Node 26 pide GCC ≥ 13.2), y con `-j5` tras un OOM con `-j8` |
| PD5 | Podman (F24–F25) | con Docker Desktop cerrado, en la máquina `podman-machine-default`; F26 al final, con los dos motores |
| PD6 | Instalación de Podman en F24 | se decide en P4 con lo que pida la máquina desde cero → **máquina aparte `p4-legacy`** (Oskar, 14/11: la `podman-machine-default` no se toca), todo con `CONTAINER_CONNECTION=p4-legacy` |

## 🗺️ Tandas

| Tanda | Qué | Necesita | Estado |
|---|---|---|---|
| **P0** | zz-code, inventario de Docker, este plan; comprobar que las versiones de la guía §5.2 siguen disponibles (`debian/eol:buster`, tarballs y checksums de Node 10/12/14/16) | nada | ☑ 14/11 |
| **P1** | Parte I (F00–F11): imagen fase a fase, comparar con `src/all-dockerfiles`; F11 con fixtures, LabCore (PD1) y el proyecto ajeno (PD2); matriz del ej. 24 contra F20 §7.1 | Docker Desktop | ☑ 14/11 (salvo ej. 22) |
| **P2** | F12–F21 y F27: volver a correr las ocho con fecha sobre la versión de Docker actual; F17–F19 por primera vez | Docker Desktop | ☑ 14/11 |
| **P3** | F22–F23: arm64 nativo contra amd64 emulado en el M1 Pro | Docker Desktop | ☑ 14/11 |
| **P4** | F24–F26: los comandos `podman` por primera vez (PD5, PD6) | Docker Desktop cerrado (lo cierra Oskar) | ☑ 14/11 |
| **P5** | F28–F34 y los apéndices a01–a16 en su tramo (PD3) | Docker Desktop | ☑ 14/11 (a07 cerrado en P6) |
| **P6** | a17: corridas 1 y 3 con Lima (PD4), escribir el apéndice | Lima instalado por Oskar (`brew install lima`) | ☑ 14/11 |
| **P7** | Cierre: verificadores 0/0, check-course, bitácora, limpieza contra el inventario, `limactl delete`, vaciar la máquina de Podman, reporte y memoria | confirmación de Oskar para borrar | ☑ 15/11 |

Windows 11 y Linux quedan fuera de este plan.

## 📓 Bitácora del plan

| Fecha | Tanda | Qué |
|---|---|---|
| 14/11/2026 | — | Plan abierto con PD1–PD6 por defecto (Oskar: "sigue con todo lo que recomiendas por default"). |
| 14/11/2026 | P0 | **Cerrada.** zz-code `docker-container-legacy-20261114-75ad`. Inventario inicial en `logs/P0/00-docker-inventario-inicial.log` (Docker Desktop 29.9.3, VM de 8 CPU y 8 GiB, aarch64). `debian/eol:buster` sigue publicada (lista multiarquitectura, digest `sha256:3207f48c…`, con amd64 y arm64/v8); los ocho tarballs de Node (10.24.1, 12.22.12, 14.21.3, 16.20.2 × x64 y arm64) responden 200 y están en su `SHASUMS256.txt`. LabCore copiado a `proyectos/labcore/` (lock `5db55ff8…`); trae `node-sass` 4.14.1, así que F11 lo valida con un addon nativo de verdad. Ninguna diferencia con el curso todavía. Sigue P1. |
| 14/11/2026 | P1 | **Cerrada, salvo F11 ej. 22.** F00–F11 corridas en orden; Dockerfiles, scripts y `.vscode` del texto idénticos a `src/` (el de F08 solo difiere en la cabecera de "archivo compuesto"). Hallazgos V01–V14 aplicados al curso y volcados a la bitácora de `pendientes-a-futuro.md`; los de más peso: V06 (F09 no crea `phase09`), V12 (`PIPESTATUS` vacío en zsh), V13 (`npm test` sin script sale 0), V04 (npm 8 sobre Node 10). F02–F11 ganan fecha de verificación ejecutada. LabCore: nivel 6 (expediente en `validacion/20261114-labcore/`). Ej. 24: 12 ceros de 12, igual que F20 §7.1. Ej. 22: clon de `t-hnh10/angular-8-app` hecho; su `npm ci` lo bloqueó el clasificador de permisos (código de terceros), espera autorización. Docker Desktop está en 8 GiB (lo subió otra sesión). Verificadores 0/0, check-course 13/13. |
| 14/11/2026 | P2 | **Cerrada.** F12–F21 y F27 corridas. Reproducen al byte o dentro de la variación: caché, A/B/C (+471 bytes), `canvas` (5.387 bytes), los 41 zombies, la matriz de F20, los digests de F27. Hallazgos V15–V25 aplicados; el de más peso, V20 (`docker stop` sin `-t` espera 3 s en Docker Desktop 29.9.3, no 10). F19, solo por equivalencia (sin extensión de VS Code). Fechas de verificación: reverificadas F12–F16, F20, F21 y F27; nuevas F17–F19. Imágenes bajadas en P2 (borrar en P7): `node:16.20.2`, `debian:bookworm-slim`, `quay.io/skopeo/stable:v1.16.1`, las `p2-f12`/`p2-f13-*`. Verificadores 0/0, check-course 13/13. |
| 14/11/2026 | P3 | **Cerrada.** F22–F23 corridas (y los builds de F21 §6.2). Imágenes nuevas del laboratorio: `:phase21` (index con amd64 y arm64, `--load` funciona con containerd) y `:arm64`. Hallazgos V26–V29 aplicados; los de más peso: V26 (el build arm64 de F21 sin `--file` falla) y V28 (la matriz de F23 pedía `phase15` en arm64). Dragones en arm64 medidos: `node-sass` compila, `canvas` compila, `sqlite3` necesita `--sqlite=/usr`. Podman y Colima de F22 §6 quedan para P4 / sin instalar. Fechas nuevas: F22, F23; F21 amplía su reverificación. Verificadores 0/0, check-course 13/13. Sigue P4, que necesita a Docker Desktop **cerrado** (lo cierra Oskar). |
| 14/11/2026 | P4 (1/2) | Docker Desktop cerrado por Oskar y verificado (sin socket). Podman 6.1.3 ya instalado; máquina nueva `p4-legacy` (`init` 1 min 12 s; 4 CPU, 2 GiB, libkrun, rootless, sin Rosetta → amd64 por qemu). F24 y F25 corridas, canónico construido con Podman (4 min 9 s), `run-dev.sh` portado, bucle de F26 §8 en Podman (✅/✅). Hallazgos V30–V38 en `zz-code/…75ad/hallazgos.md`, **sin aplicar todavía**. `p4-legacy` igualada a 8 CPU / 8 GiB para F26. Falta: F26 con Docker Desktop abierto (comparación, save/load, ej. 4/6/7/8/19/21 de F24), y aplicar V30–V38. |
| 14/11/2026 | P4 | **Cerrada.** Oskar reabrió Docker Desktop (vuelve a tomar `/var/run/docker.sock`); F26 con los dos motores a 8 CPU / 8 GiB: benchmark de §5.3 sin `prune` (cold 137 / 238 s, warm 2,2 / 2,2 s), bucle de §8 con Vue 2 y React 16 (4 ✅/✅), ej. 9 (volumen y bind casi empatan), `save \| load` (misma imagen, IDs distintos), las cuatro combinaciones de nombre de host. Hallazgos V30–V41 aplicados (F22, F24, F25, F26) y volcados a la bitácora de `pendientes-a-futuro.md`. F24–F26 sustituyen el "⚠️ Alcance de la verificación" por fecha de verificación ejecutada; F22 la amplía. Abiertos nuevos: F26 ej. 11 (Dev Container) y `buildah`. Recursos de P4 para P7: máquina `p4-legacy`, imágenes `p4-bench:*`, `p4-desde-docker:phase15` (en los dos), volúmenes `p4-*` en los dos motores. Sigue P5. |
| 14/11/2026 | P5 | **Cerrada, salvo a07.** Oskar respondió las cuatro preguntas: ej. 22 autorizado, Lima lo instala él, VS Code declarado no verificado, buildah con su imagen. F11 ej. 22: nivel 5 (`t-hnh10/angular-8-app`, Node 12). F28–F34 y a01–a16 corridos donde había algo que correr (registry local en un puerto alto, Syft/Trivy/Cosign desde sus imágenes, CA de prueba, Chromium 90 de Debian, Compose con los dos motores, actionlint). Hallazgos V42–V67 aplicados; los de más peso: el 5000 de AirPlay (V42), el pull sin `--platform` (V43), `strace` con Rosetta (V52), seis mensajes de F31 desfasados (V53), el GPG de a04 (V61), el GID 20 del Mac en a05 (V62), los CLI globales fuera del `PATH` (V59) y el `file:` que faltaba en a14 (V66). a09 resolvió el N/A de tests de LabCore (3/3). F28–F34, a01–a05, a09, a10, a13 y a14 ganan fecha de verificación ejecutada. buildah (F24 §11) corrido después en su imagen oficial (V68). Falta a07 y la P6, que esperan a Lima. |
| 14/11/2026 | P6 | **Cerrada.** Lima 2.3.0 (lo instaló Oskar) y QEMU 11.1.3 (también él, cuando `debian-11` no arrancó con `vz`). Corrida 3, Node 26.13.1 en trixie/`vz`: `-j8` muere por OOM a los 14:35 (el kernel mata antes a containerd y buildkitd de la VM); `-j5` compila en 1:12:48; caliente real 43 s. Corrida 1, Node 14.21.3 en bullseye/`qemu`: el primer intento chocó con el 404 de `bullseye-security` (fin de LTS; arreglo a `archive.debian.org`); el segundo, `-j8` en 10:37 y caliente en 23 s, sin Python 2. Disección: los compilados exigen glibc 2.29/2.38 (oficiales 2.17/2.28), son `small-icu` y el de 26 va sin Temporal; el Node 14 de bullseye no arranca en Buster. Sonda con el mismo binario: `qemu` y `vz` empatan en paralelo. a17 escrito (6 ejercicios, guion en `src/`), registrado en programa, README y guía §16.4; a07 verificado en su capa Lima, Colima no; enlaces desde F06 §3 y a02 §3; las cabeceras de a06, a08, a11 y a12 declaran que no se ejecutaron; README y programa §9 cuentan 44 documentos con fecha. Hallazgos V69–V77. Verificadores 0/0, check-course 13/13. |
| 14/11/2026 | P7 (1/2) | Verificadores 0/0 y 0/0 (`--publicacion`), check-course 13/13; bitácora de `pendientes-a-futuro.md` al día; reporte y memoria actualizados. **Falta, con el sí de Oskar:** correr `zz-code/…75ad/experimentos/p7-limpieza.sh` (contenedor del registry, imágenes y volúmenes de la pasada, máquina `p4-legacy`, VM `p6-node14` y `p6-node26` —7,6 GB en `~/.lima`—, los `.tar` de 1,2 GB y las llaves de prueba), decidir si se borra la caché de Lima (2,6 GB en `~/Library/Caches/lima`) y borrar este plan con copia en zz-code. |
| 15/11/2026 | P7 | **Cerrada.** Oskar corrió `p7-limpieza.sh` tras revisar la lista contra el inventario de P0: contenedor `p5-registry-local`, 87 imágenes y 35 volúmenes de la pasada, máquina `p4-legacy` (la `podman-machine-default` intacta), VM `p6-node14` y `p6-node26` (7,6 GB), los `.tar` y las llaves de prueba; además borró los volcados OCI de F33 (~500 MB; zz-code …75ad queda en 117 MB) y la caché de Lima (2,6 GB). Quedan en Docker solo los recursos previos a la pasada. Plan copiado a zz-code y borrado del curso. **Pasada cerrada.** |
