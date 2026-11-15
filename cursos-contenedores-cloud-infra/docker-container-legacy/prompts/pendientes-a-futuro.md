# 📌 Pendientes a futuro: la hoja de verificación al tomar el curso
## Docker Legacy Node

> **Qué es este documento:** la hoja de trabajo de la pasada que cierra el curso: el autor lo toma
> como lector, desde cero, en cada sistema, monta todos los contenedores y rehace todas las pruebas.
> Al final, las decisiones del autor: las tres cerradas (dos el 19/10/2026 y la matriz el 14/11/2026). No se cita desde el curso.
> **Fecha:** 05/10/2026. Ese día la redacción quedó cerrada: `verificar-corpus.py` (los dos modos) y
> `check-course.sh` salen limpios.
> **Estado:** la pasada en macOS se hizo del 14 al 15/11/2026 y está **cerrada** (hallazgos V01–V77 en la
> bitácora). Queda abierta la de Windows 11 y Linux (sección «Windows 11 y Linux»).

Antes de la pasada, la verificación de la producción fue **la del autor**, y parcial: ocho documentos (F12, F13, F14,
F15, F16, F20, F21 y F27) llevan fecha de verificación ejecutada, corridos el 03 y el 06/09/2026
sobre Docker 29.6.2 en macOS Apple Silicon, casi siempre con la imagen `linux/amd64` bajo emulación.
Los comandos `podman` de F24, F25 y F26 están contrastados con la documentación oficial, no
ejecutados. Tomar el curso entero es lo que prueba que las fases, leídas en orden por alguien que
empieza de cero, llevan a la imagen que prometen.

---

## 🧭 Las reglas de la pasada

1. **Desde cero y como lector.** La máquina arranca sin nada del curso: sin la imagen del
   laboratorio y sin la máquina de Podman (se borró el 05/10/2026). Se sigue la ruta 🎓 del programa
   (§6) y se construye la imagen fase a fase. `src/` solo se usa para compararse: si se copia de ahí,
   la prueba deja de valer.
2. **Toda diferencia se anota** en la bitácora del final de este documento, con fecha, fase, lo que
   decía el curso y lo que salió. La corrección pasa de la bitácora al documento, y la cabecera de la
   fase gana su **fecha de verificación ejecutada** solo si se corrió de verdad (guía §16).
3. **Las cifras no se pisan.** Un número propio dentro de la variación ya publicada deja la cifra
   como está; uno fuera la corrige, con la máquina declarada. Otra plataforma suma su medición al
   lado, no en lugar de la de macOS.
4. **El orden.** Primero una pasada completa en macOS; después Windows 11 y Linux, como mínimo la
   Parte I (el taller), que es donde el host pesa.

---

## 🍎 La pasada en macOS: lo que pide atención

> 🪦 **Hecha el 14–15/11/2026.** La tabla queda como el plan que fue; lo que salió de cada tramo está en
> la bitácora del final.

| Tramo | Además de lo de cada fase | Cierra |
|---|---|---|
| Parte I (F00–F11) | La imagen incremental fase a fase, con las versiones fijadas de la guía §5.1 y §5.2, y la validación de F11 con un proyecto real | — |
| F11, ejercicio 24 (🔥) | La matriz de `00-node-smoke` contra las cuatro generaciones de Node: debe dar los doce ceros de F20 §7.1 (decisión 2) | F20 §7.1, si algo cambió |
| F12–F16, F20, F21, F27 | Volver a correr lo que ya tiene fecha, con la versión de Docker del momento | las cabeceras, si algo cambió |
| F22–F23 | Apple Silicon: ARM64 nativo contra AMD64 emulado | — |
| **F24–F26** | **Los comandos `podman`, ejecutados por primera vez.** Ojo: el curso no trae una receta de instalación de Podman (el ejercicio 11 de F22 solo dice «instala Podman Desktop o Colima»); si al lector le hace falta, la pasada decide si F24 suma un bloque de instalación con `podman machine init` | la advertencia «Alcance de la verificación» de las tres cabeceras, `0-programa-del-curso.md` §9 y la guía §16.4 |
| F28–F34 | Publicar la imagen, la cadena de suministro y el proyecto final con su rúbrica | — |
| **a17** | **Escribirlo durante la pasada**: es el único documento que falta, y espera justamente esta sesión de laboratorio | ver abajo |

### El apéndice a17, compilar Node desde fuente

**Escrito el 14/11/2026** con las corridas 1 y 3 del protocolo
(`propuestas-cursos/propuesta-complemento-docker/complemento-docker-legacy.md` §9): Node 14.21.3 en
Debian 11 (Lima, `qemu`, porque la plantilla `debian-11` no arranca con `vz`) y Node 26.13.1 en
Debian 13 (Lima, `vz`), en el M1 Pro. Bookworm se saltó: su GCC 12 no llega al 13.2 que pide el
`BUILDING.md` de Node 26. Quedan sin correr las corridas 2 y 4 (Windows `amd64`, WSL2), y la
cabecera lo declara. Registrado en `0-programa-del-curso.md`, el README y la guía §16.4; guion en
`src/a17-compilar-node-desde-fuente/`; hallazgos V69–V77.

---

## 🪟🐧 Windows 11 y Linux

- **Windows 11:** la Parte I con `a08` (Windows y PowerShell) y WSL2; las corridas de Windows del a17
  salen de aquí.
- **Linux:** la Parte I nativa, sin máquina virtual de por medio. Es la plataforma donde rootless
  (F25) y los user namespaces se ven sin capas extra.
- **Al cerrar:** lo que se corrió gana su fecha en la cabecera, con la plataforma; los problemas
  nuevos van al catálogo de fallos (F31–F32) o al apéndice de la plataforma.

---

## 🧭 Decisiones del autor

### 1. El solucionario de los ejercicios — 🪦 cerrada el 19/10/2026

**Decisión, no pendiente** (valor por defecto, tomado al revisar el curso para publicar): manda la
guía §16, que es la primera autoridad. El programa §9 se reescribió para decirle al lector por qué no
hay solucionario —la línea `Objetivo:` o `Pregunta:` es la verificación, y la máquina responde—, y
dejó de decir que es "un pendiente común a todos los cursos" (ya no lo era: la Ruta SQL trae el suyo).

### 2. La matriz de compatibilidad completa — 🪦 cerrada el 14/11/2026

**Basta con la de F20** (decisión del autor). F20 §7.1 publica la matriz completa de `00-node-smoke`
contra las cuatro generaciones, corrida sobre `linux/amd64`, que es la arquitectura base de la guía
(§5): doce ceros de doce. El ejercicio 24 de F11 dejó de llamarla "un pendiente declarado del curso" y
ahora manda a compararse con esa tabla. La corrida en ARM64 nativo no es un pendiente de la matriz:
entra en la fila F22–F23 de la pasada, como cualquier otra comparación de arquitecturas.

### 3. Publicar antes de la pasada — 🪦 cerrada el 19/10/2026

**Se publica sin esperar la pasada** (valor por defecto, tomado al revisar el curso para publicar). Lo
no ejecutado ya está declarado al lector en el README («Qué está verificado, y qué no»), el programa
§9 y las cabeceras de F24–F26, así que publicar no promete nada que el curso no diga. La pasada queda
como trabajo posterior a la publicación, con estas mismas reglas; lo que corrija entra como edición
del curso publicado, y a17 se escribe en ella.

---

## 📓 Bitácora de la pasada

Cada fila es una diferencia entre lo que decía el curso y lo que salió. El detalle y los logs viven en
`zz-code/docker-container-legacy-20261114-75ad/` (`hallazgos.md` y `logs/`).

| Fecha | ID | Fase | Qué decía | Qué salió | Corrección |
|---|---|---|---|---|---|
| 14/11/2026 | V01 | F02 §9 | sin `--platform` en el `run` sale `aarch64` | con imagen solo amd64 corre amd64 y avisa con `WARNING` | párrafo con los dos casos |
| 14/11/2026 | V02 | F03 §7 y §11 | `readlink -f /proc/$$/exe` devuelve bash | bajo Rosetta apunta a `/run/rosetta/rosetta` | checklist con `printenv SHELL` y ⚠️ |
| 14/11/2026 | V03 | F04 §4 | `pkg-config --cflags --libs zlib`, sin salida | `No package 'zlib' found` (falta `zlib1g-dev`) | se dice qué sale y por qué |
| 14/11/2026 | V04 | F06 §9 | la 16 responde `npm 8.19.4` | el npm 8 corre sobre Node 10 y falla | `PATH=` en el bucle y ⚠️ |
| 14/11/2026 | V05 | F08 §6 y §9 | ejemplos sin `--platform` | `WARNING` de plataforma que la salida no muestra | `--platform` en los tres |
| 14/11/2026 | V06 | F09 §7.1 | `run-dev.sh` usa `phase09` | ningún paso crea el tag: `pull access denied` | `docker tag … phase08 … phase09` |
| 14/11/2026 | V07 | F05, F09, F10 | `src/10-validar-tu-proyecto/` | el directorio es `src/11-…` | cuatro rutas |
| 14/11/2026 | V08 | F09 §8 | `./scripts/run-dev.sh` | monta el laboratorio, no el proyecto | correrlo desde el proyecto |
| 14/11/2026 | V09 | F11 ej. 13 | `/usr/bin/time -f` | en macOS: `illegal option -- f` | `/usr/bin/time -p` |
| 14/11/2026 | V10 | F08 → F09–F11 | (nada) | `npm WARN lifecycle …` en cada script de npm 6 | 📝 en F08 §6 |
| 14/11/2026 | V11 | F09 §10 | `node_modules` no aparece en el host | aparece vacío: el punto de montaje | 📝 en §5 y checklist |
| 14/11/2026 | V12 | F11, F20, F34, a15 | `${PIPESTATUS[0]}` en el host | en zsh (macOS) sale vacío | ⚠️ con `pipefail` y `pipestatus` |
| 14/11/2026 | V13 | F11 y fixtures | `npm test` en vue2 y angular8 | sin script `test`, npm sale con 0 | scripts `test` y ⚠️ en §6 |
| 14/11/2026 | V14 | F11 §6 paso 8 | el watch "no siempre" ve los cambios | Angular 8 recompiló sin sondeo; Angular usa `--poll` | dato fechado y la bandera |
| 14/11/2026 | V15 | F12 §4.3 | "verás" el `COPY` antes que el `RUN` | con 29.9.3 salen en orden | "puede que veas", con las dos fechas |
| 14/11/2026 | V16 | F13 §10 | `docker diff` de 4 líneas | 7: Rosetta escribe `/root/.cache/rosetta` | 📝 con el porqué |
| 14/11/2026 | V17 | F15 §5.4 | el PNG prueba que funciona | el texto se corta y el 👋 no sale (Liberation Mono, sin emoji) | línea en la 🔥 |
| 14/11/2026 | V18 | F15 §8 | "todo lo del canónico" y luego el `RUN` | `src/` lo pone tras el APT de F03 | el comentario dice dónde |
| 14/11/2026 | V19 | `src/` compuestos | cabecera antes de `# syntax=` | la directiva queda como comentario | cabecera después de la directiva (seis archivos) |
| 14/11/2026 | V20 | F16 §7 | `docker stop` sin handler: 10 s | 3,1 s con Docker Desktop 29.9.3; 10 s con `-t 10` | ⚠️ fechado y `-t 10` en el laboratorio |
| 14/11/2026 | V21 | F17 | `EACCES` "del volumen sin preparar" | con `00-node-smoke` no sale; GID 20 = `dialout` | checklist y 📝 |
| 14/11/2026 | V22 | F18 §8 | el driver por defecto es `json-file` | Docker Desktop: `local` | depende del motor |
| 14/11/2026 | V23 | F21 §7.4 | I/O "dos mil archivos de 4 KB", sin script | no reproducible por el lector | `io.js`, `node:16.20.2` y segunda medición |
| 14/11/2026 | V24 | F27 §7 | (nada) | entradas `unknown/unknown` en el index | 📝 sobre atestaciones |
| 14/11/2026 | V25 | F27 §8 | Skopeo instalado | sin receta; en Mac `inspect` da arm64 | instalación y `--override-arch amd64` |
| 14/11/2026 | V26 | F21 §6.2 | arm64 "de una en una" con `.`; `--load` no admite dos plataformas | sin `--file` usa el Dockerfile x64 y cae con `rosetta error`; con containerd, `--load` multiplataforma funciona | `--file` y ⚠️ por tipo de almacén |
| 14/11/2026 | V27 | `src/` F21 | el compuesto multiarch | parte de F08, sin las librerías de F15 | compuesto sobre F15 y cabecera §6.1 |
| 14/11/2026 | V28 | F23 §6 | matriz con `phase15` en arm64 | `pull access denied`: `phase15` es solo amd64 | `phase21`; diez ✅ de diez |
| 14/11/2026 | V29 | F23 §4 | los dragones en arm64, sin medir | `node-sass` compila (2 min 22 s), `canvas` compila, `sqlite3` sin prebuild y `python: not found` | resultados fechados en §4.1 y §4.3 |
| 14/11/2026 | V30 | F24 §5 | usaba `podman` sin decir cómo instalarlo | macOS: instalador o `brew`, `machine init` (1 min 12 s), `start`; 4 CPU, 2 GiB, sin Rosetta | §5.0 con los tres pasos y el ⚠️ de los valores por defecto |
| 14/11/2026 | V31 | F24 §5.1, §5.5 | Podman sin daemon, `ps -ef` en el host | en macOS `podman` es cliente remoto del `podman.socket` de la VM; la máquina toma `/var/run/docker.sock` | 📝 en §5.1, `podman machine ssh` en §5.5 y en los ejercicios |
| 14/11/2026 | V32 | F24 §5.1, §6, ej. 14 | el contenedor "desciende de tu proceso" | `systemd(1)───conmon───sleep` también en Linux; `kill -9` al cliente no lo mata | §5.1 con el árbol real, 🧭 de §6 y ej. 14 reescritos |
| 14/11/2026 | V33 | F24 §8, §10, §13 | `host.docker.internal` no resuelve en Podman; `ping` de ejemplo | Podman resuelve los dos nombres; Docker no conoce `host.containers.internal`; `ping` falla en rootless | tabla, las cuatro combinaciones con `wget`, ⚠️ del `ping`, error de §13 |
| 14/11/2026 | V34 | F25 §5 | `/etc/subuid` de tu usuario | en macOS no existe: `core:100000:1000000` dentro de la VM, `uid_map` `0 501 1` | 📝 de Podman Machine |
| 14/11/2026 | V35 | F25 §10 | `keepid.txt` y `rootless.txt` con dueños distintos | los dos `501:1000`; `--user 1234` → `101233`; en el Mac todo `501:20`; sin `:Z`, `Permission denied` | experimento con tres archivos, salida real, ⚠️ de macOS |
| 14/11/2026 | V36 | F26 §8 | el bucle salta motores ausentes | con Docker parado aborta entero (`set -e` heredado) | guarda `"$eng" info … \|\| continue` y 📝 |
| 14/11/2026 | V37 | F26 §6, §7 | `systemctl --user` y `XDG_RUNTIME_DIR` | en macOS no existen; el socket ya está publicado; `docker info` responde contra Podman | §7 con la variante macOS, ⚠️ en §6 con el `docker version` que lo delata |
| 14/11/2026 | V38 | F26 §5.3 | `docker builder prune -af` y `podman rmi -a -f` | borran caché e imágenes ajenas | quitados; ⚠️ con `--no-cache` |
| 14/11/2026 | V39 | F24 ej. 21 | comparar los digests tras `save \| load` | los `IMAGE ID` difieren (index contra config) y es la misma imagen | ⚠️ con qué comparar |
| 14/11/2026 | V40 | F22 §6.2 | Podman con `applehv` y Rosetta | `libkrun`, `Rosetta: false`, amd64 por qemu | proveedor, salida real y ⚠️ |
| 14/11/2026 | V41 | F26 §4.2, §5.3, §10 | el bind mount es el cuello de botella | volumen 27,8 s / bind 29,1 s (Docker); ≈2,5× es Rosetta contra qemu | tabla fechada en §5.3, §4.2 y §10 matizados |
| 14/11/2026 | V42 | F28 §5 | registry en `localhost:5000`; `curl -s … && echo vivo` | el 5000 es de AirPlay en macOS; el chequeo da falso positivo con su 403 | puerto 5001, `curl -sf`, ⚠️ |
| 14/11/2026 | V43 | F28 §5.4 | `docker pull` del registry local | en Apple Silicon: `no matching manifest for linux/arm64/v8` | `--platform linux/amd64` en pull y run |
| 14/11/2026 | V44 | F28 §6 | `config.json` con `auth` en Base64 | Docker Desktop: `credsStore: osxkeychain`, ningún `auth` | 📝 |
| 14/11/2026 | V45 | F28 §7.1, §14; F21 ej. 24 | `buildx create --use`; `--push` sí, `--load` no | el builder queda por defecto y no llega a `localhost`; con containerd no hace falta | 📝, resumen y ej. 24 corregidos |
| 14/11/2026 | V46 | F28 §10 | `{{index .RepoDigests 0}}` | devuelve cualquier nombre local | filtrar por repositorio, ⚠️ |
| 14/11/2026 | V47 | F29 §4.3 | `grep -oP` | el grep de macOS no tiene `-P` | `grep -oE`, salida real |
| 14/11/2026 | V48 | F29 §4.4 | diff de SBOM por arquitectura sobre la imagen local | necesita la imagen publicada; 1.934 / 1.932, 4 líneas | referencia y resultado |
| 14/11/2026 | V49 | F29 §5 | `trivy sbom` como alternativa | 111 CVE contra 519 de la imagen | recuento fechado, ⚠️ |
| 14/11/2026 | V50 | F29 §6 | provenance sin formato | SLSA v1 (`buildDefinition`/`runDetails`) | párrafo |
| 14/11/2026 | V51 | F29 §7 | `verify` con regexp `.*` | acepta cualquier firmante | identidad concreta, ⚠️, ciclo con llave probado |
| 14/11/2026 | V52 | F30 §9.1 | `strace -p 1` | con Rosetta, `x32 mode` y llamadas ilegibles | ⚠️ con la salida y la vía arm64 |
| 14/11/2026 | V53 | F31 | seis mensajes literales | Docker 29.9.3 los dice de otra forma | 📝 bajo cada título |
| 14/11/2026 | V54 | F32 §5.3 | un solo texto del error de `npm ci` | npm 6 `cipm…`, npm 8 `` `npm ci`… ``; `Missing:`; el caso transitivo pasa | las dos firmas y 📝 |
| 14/11/2026 | V55 | F33 §4.3–§4.4, §5.3 | `docker cp` de `/etc/os-release`; listado del save | copia el enlace roto; layout OCI | `-L`, listado real, `--platform` |
| 14/11/2026 | V56 | a01 §2 | una línea `main contrib non-free` | tres suites, solo `main`, snapshots comentados | salida real |
| 14/11/2026 | V57 | a01 §4 | `ca-certificates` Recommends de `curl`; `grep -c Depends` = paquetes | es de `libcurl4`; 120 aristas, 49 paquetes | atribución, diagrama, conteo |
| 14/11/2026 | V58 | a01 §6.7 | `man` en el contenedor | `command not found`, falta `man-db` | nota |
| 14/11/2026 | V59 | a02 §6, §8 | `npm install -g` de un CLI | el binario no queda en el `PATH` | `ln -s` a `/usr/local/bin`, ⚠️ |
| 14/11/2026 | V60 | a03 §3.1 | `file` dice `shared object` | el de Buster dice `pie executable` | salida real y 📝 |
| 14/11/2026 | V61 | a04 §2 | `gpg --verify SHASUMS256.txt.asc SHASUMS256.txt` | `not a detached signature`; 12 llaves sin UID en keys.openpgp.org | `.sig`, keyserver de Ubuntu, `gnupg` |
| 14/11/2026 | V62 | a05 §4.1–§4.2 | `groupadd --gid $(id -g)`; imagen `nonroot-build` | en Mac el GID 20 existe (exit 4); la imagen no existe y `dev` no puede `chown` | `getent`, `--user 0` |
| 14/11/2026 | V63 | a09 §1, §4 | Chromium headless sin probar; `/dev/shm` 1 GB | 3/3 tests de LabCore con Chromium 90; el default es 64 MB | resultado fechado, 64 MB |
| 14/11/2026 | V64 | a10 §4 | Compose con Podman solo en Linux | funciona en macOS por el socket de la máquina | variante macOS |
| 14/11/2026 | V65 | a13 §1, §2, §4 | `gzip` del save; `Id` igual en destino | ahorra <1 % con containerd; el `Id` cambia entre motores; los dos almacenes medidos | 📝, ⚠️, tabla |
| 14/11/2026 | V66 | a14 | workflow sin probar | `publish` sin `file:` (V26); `cosign` sin instalar; SC2086 | `file:`, `cosign-installer`, comillas |
| 14/11/2026 | V67 | a11 §2 | buildx multiplataforma sin `--file` | V26 | `--file` |
| 14/11/2026 | V68 | F24 §11 | `buildah from debian/eol:buster`, sin ejecutar | sin TTY, el nombre corto falla; con `docker.io/` funciona (Buildah 1.37.5 en su imagen) | nombre completo y receta verificada |
| 14/11/2026 | V69 | a17 §2, a07 | — | `debian-11` con `vz` no arranca (`did not receive an event with the running status`); con `qemu` sí, aunque `limactl start` sale con 1 en dos de tres arranques | `--vm-type=qemu`; dos errores comunes en a07 |
| 14/11/2026 | V70 | a17 §3 | — | bullseye-security: índice vivo, paquetes en 404; `No acceptable C compiler found!` | `sed` a `archive.debian.org` |
| 14/11/2026 | V71 | a17 §3 | — | la imagen cloud de Debian no trae `/usr/bin/time` | el guion instala `time` |
| 14/11/2026 | V72 | a17 §1 | "Node 14 necesita Python 2" (hipótesis del protocolo) | `Found Python 3.9.2`, sin avisos | 🧠 que lo desmiente |
| 14/11/2026 | V73 | a17 §6 | — | Node 26 `-j8` en 12 GiB: OOM a los 14:35; el kernel mata antes a containerd y buildkitd | `-j5` (1:12:48) y la regla de 2,5 GB por trabajo |
| 14/11/2026 | V74 | a17 §7 | — | `CCACHE_DISABLE` tampoco escribe: 76 % de aciertos y 59:51 | la trampa contada; caché llena: 43 s |
| 14/11/2026 | V75 | a17 §8 | — | compilado ≠ oficial: glibc 2.29/2.38 contra 2.17/2.28, small-icu, sin Temporal; el Node 14 de bullseye no arranca en Buster | tabla y salida literal |
| 14/11/2026 | V76 | a02 §3 | "entre veinte minutos y más de una hora" | 10:37 y 1:12:48 | 📝 con los números |
| 14/11/2026 | V77 | a17 §5 | — | mismo binario en las dos VM: 8 en paralelo empatan (~10,4 s) | 📝: el hipervisor no explica el 4,4× |

**Abiertos:** F19 no se corrió con la extensión de VS Code (solo el `docker run` equivalente), y por lo mismo F26 ej. 11 (Dev Container con Podman); a06 (WebStorm), a08 (Windows), a11/a12 (registros externos, PD3), Cosign keyless, el workflow de a14 en GitHub Actions, Colima (a07, no instalado) y las corridas Windows/`amd64` del a17 no se ejecutaron. **Cerrado:** F11 ejercicio 22, con permiso del autor el 14/11/2026: `t-hnh10/angular-8-app` llegó al nivel 5 con Node 12.22.12 (expediente en zz-code); a17 escrito y a07 verificado en su capa Lima (P6, 14/11/2026). La pasada se cerró el 15/11/2026 con la limpieza de todo lo que creó.
permiso del autor el 14/11/2026: `t-hnh10/angular-8-app` llegó al nivel 5 con Node 12.22.12
(expediente en zz-code).
