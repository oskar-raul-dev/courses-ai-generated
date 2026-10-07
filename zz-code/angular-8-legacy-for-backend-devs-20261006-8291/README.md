# 🧪 angular-8-legacy-for-backend-devs-20261006-8291 · cómo correr estas pruebas

> **Curso:** angular-8-legacy-for-backend-devs · **Tanda:** rescate posterior al cierre · **Creado:** 2026-10-06
> **Propósito:** rescatar de las transcripciones de las sesiones el código de prueba de la producción
> del curso, con instrucciones para replicarlo.
> **Vigencia:** rescatado el 2026-10-06 con `zz-instrucciones/herramientas/rescatar-transcripcion.py`,
> sin ejecutar nada. `sondas-labcore.sh` es nuevo: replica las sondas del 09/09 con las reglas de hoy;
> se validó su sintaxis y su `docker compose config`, **no se corrió**.

> ⚠️ **Lo que no se puede rescatar.** El track base (frontend) ya estaba en el commit «Courses V1» del
> 16/08/2026, y la primera transcripción guardada de este repositorio es del 06/09. Lo que se probó al
> escribir el track base no tiene registro. Lo que sí hay es del track backend (LabCore), de las piezas
> forenses y de las revisiones.

---

## 1. 🎯 Qué se prueba y para qué

| Carpeta | Sesión | Fecha (UTC) | Qué hay |
|---|---|---|---|
| `01-forense-6edc206c/` | `6edc206c…` | 08/09 00:57 → 09/09 02:33 | Las primeras piezas forenses: integridad de enlaces y enlaces bidireccionales fase ↔ pieza |
| `02-sondas-be-f803daaa/` | `f803daaa…` | 09/09, 03:17–13:25 | **Las únicas pruebas que ejecutaron código.** Decidían si el stack de LabCore (Mongo 4.0 standalone, Java 8, driver de 2019) era viable en arm64. Aquí están los archivos de LabCore; los de CertCore, en el rescate de angular-16 |
| `03-revision-9890285f/` | `9890285f…` | 10/09, 16:06–22:13 | Revisión total de apéndices y piezas forenses: enlaces, citas de sección entre documentos, anclas; `anchors.py`, `asec.py`, `fsec.py`, `links.py`, `secs.py` son los auditores que escribió en el scratchpad |
| `04-autocontenido-70a2da9f/` | `70a2da9f…` | 10/09, 19:23–22:14 | Que no quede ninguna referencia a angular-16 («uno no debe saber del otro») y que no haya enlaces colgando |
| `05-forense-fd43dd61/` | `fd43dd61…` | 10/09, 22:17–22:28 | Los bloques obligatorios en cada pieza forense |
| `06-track-be-13793b0f/` | `13793b0f…` | 10/09 22:31 → 11/09 04:15 | Redacción del track BE (LabCore): tags exactos de Mongo y Cassandra, versiones y bytecode de Testcontainers, coherencia numérica de los volcados, estructura forense, cláusula de descarte, referencias cruzadas; 71 verificaciones |
| `07-revision-ba539b99/` | `ba539b99…` | 11/09, 03:37–16:14 | Revisión del cuaderno de incidentes BE: enlaces rotos, menciones a archivos inexistentes, anclas con las reglas de emoji de GitHub, enlaces entre tracks; 66 verificaciones |

### Las sondas de LabCore (`02-`)

| Prueba | Qué resolvió |
|---|---|
| Arquitecturas de `mongo`, `eclipse-temurin:8` y `maven:3.8-eclipse-temurin-8` en Docker Hub | todas con arm64 activo |
| `mongo:4.0` y `eclipse-temurin:8-jdk` en arm64 | corren nativos: Mongo 4.0 standalone, OpenJDK 1.8.0_502 |
| Una transacción en Mongo 4.0 standalone | **rechazada**: código 20, «Transaction numbers are only allowed on a replica set member or mongos». Es el pecado del track: la cadena de custodia sin transacción |
| El driver Java 3.8.2 (el de 2019) contra `mongo` 4.0, 4.2, 4.4, 5.0, 6.0, 7.0 y 8.0, con el proyecto Compose rescatado (`archivos/…/labcore/`) | conecta con todas |
| El shell de cada imagen | `mongo:4.0` trae `mongo` y no `mongosh`; 6.0 y 7.0, al revés |

### Qué hay en cada carpeta

- `comandos.sh` — todos los comandos Bash de la sesión, en orden. Una bitácora: no se corre entera.
- `bitacora.md` — los comandos que ejecutaron código, con el inicio de su salida.
- `scripts/NNN-HHMM-verifica.{py,sh}` y su `.salida.txt` — las verificaciones y lo que la sesión vio. Se
  omitieron los scripts que editaban la prosa (siguen en `comandos.sh`).
- `archivos/` y `archivos.tsv` — los archivos que ya no existen, con la ruta original.

## 2. 🛠️ Prerrequisitos

- **Para reconstruir:** Python 3 y las transcripciones en
  `~/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/`.
- **Para las sondas:** Docker Desktop en arm64 y Compose 2.24 o posterior (el override usa `!reset`).
  Imágenes: `mongo:4.0` … `mongo:8.0`, `eclipse-temurin:8-jdk` y `maven:3.8-eclipse-temurin-8`. La
  matriz baja las dependencias de Maven (el driver 3.8.2 y `exec-maven-plugin` 3.1.0) a un volumen.
- **Para las verificaciones:** Python 3 y bash sobre el curso.

## 3. 🧭 Reglas antes de correr

```bash
cd zz-code/angular-8-legacy-for-backend-devs-20261006-8291
mkdir -p salidas
docker ps -aq --no-trunc > salidas/contenedores-antes.txt
docker images -q --no-trunc | sort -u > salidas/imagenes-antes.txt
docker volume ls -q > salidas/volumenes-antes.txt
docker network ls -q > salidas/redes-antes.txt
```

- Las sondas originales **publicaban el puerto 3000** y corrían contenedores sin etiqueta (`m40`,
  `labcore-*`). `sondas-labcore.sh` no publica puertos, lo etiqueta todo con
  `curso=angular-8-legacy-for-backend-devs` y usa el proyecto Compose `a8-labcore`.
- Los scripts de `03-` traen escrita la ruta vieja del curso (`courses-ia-generated/angular-8-legacy-for-backend-devs`,
  antes de que pasara a `cursos-legacy/`) en su `os.chdir`: se corrige antes de correrlos.

## 4. ▶️ Cómo se corre

```bash
cd zz-code/angular-8-legacy-for-backend-devs-20261006-8291
./rescatar.sh               # rehace desde cero las carpetas generadas (lee ../rescates.tsv); no ejecuta nada
./rescatar.sh --comprobar   # las regenera aparte y compara, sin tocar nada
./sondas-labcore.sh transaccion     # mongo:4.0 standalone rechaza la transacción
./sondas-labcore.sh temurin         # Java 8 nativo en arm64
./sondas-labcore.sh matriz          # driver 3.8.2 contra mongo 4.0 … 8.0 (TAGS="4.0 8.0" para acotar)
./sondas-labcore.sh shells          # mongo contra mongosh por versión
./sondas-labcore.sh limpiar         # borra lo creado, por etiqueta y por proyecto, y salidas/sondas
```

`sondas-labcore.sh` copia los archivos rescatados a `salidas/sondas/`, recrea el `.env` (no se rescató
por la regla 6: su única línea era `MONGO_TAG=4.0`) y agrega un `compose.override.yaml` con
`ports: !reset []` y la etiqueta. Una diferencia con el original: entre versiones solo recrea el servicio
`db` y su volumen, y conserva el de Maven (`m2`), en vez de `down -v` completo. Los comandos de entonces,
tal como corrieron, están en `02-sondas-be-f803daaa/comandos.sh` y en los scripts `004`–`010`.

Una verificación, contra el curso de hoy:

```bash
AQUI="$PWD/zz-code/angular-8-legacy-for-backend-devs-20261006-8291"
cd cursos-legacy/angular-8-legacy-for-backend-devs
python3 "$AQUI/07-revision-ba539b99/scripts/001-0338-verifica.py"    # enlaces relativos rotos
```

## 5. 📏 Cómo se mide

No aplica: las sondas responden sí o no (corre, conecta, rechaza), no miden tiempos.

## 6. 🧮 Los intermedios que amasan la salida

La matriz filtra la salida de Maven con `grep -E "OK |FALLA "`; `Probe.java` imprime una línea por
versión. Las consultas a Docker Hub pasan por un `python3 -c` (script `004`).

## 7. ✅ Qué se espera ver

Del 09/09/2026, en Docker Desktop 29.6.2 sobre `aarch64` (`02-…/bitacora.md`):

```text
RESULTADO: RECHAZADA
codigo:  20 (undefined)
mensaje: Transaction numbers are only allowed on a replica set member or mongos

mongo:4.0    OK  driver 3.8.2 -> servidor 4.0.28
mongo:4.2    OK  driver 3.8.2 -> servidor 4.2.24
mongo:4.4    OK  driver 3.8.2 -> servidor 4.4.30
mongo:5.0    OK  driver 3.8.2 -> servidor 5.0.33
mongo:6.0    OK  driver 3.8.2 -> servidor 6.0.28
mongo:7.0    OK  driver 3.8.2 -> servidor 7.0.41
mongo:8.0    OK  driver 3.8.2 -> servidor 8.0.30

mongo:4.0   shell "mongo": si   |   "mongosh": NO
mongo:6.0   shell "mongo": NO   |   "mongosh": si
```

Los parches cambian con las imágenes (`4.0.28`, `8.0.30`…); lo que tiene que conservarse es el `OK` en
todas y el rechazo de la transacción. Las verificaciones: su `.salida.txt`.

## 8. 📂 Salidas

`salidas/sondas/` (la copia de trabajo) y los inventarios de §3. Se regeneran corriendo otra vez. Nada
se copió al curso desde este rescate.

## 9. 🧹 Limpieza

```bash
./sondas-labcore.sh limpiar
docker images -q --no-trunc | sort -u > salidas/imagenes-despues.txt
comm -13 salidas/imagenes-antes.txt salidas/imagenes-despues.txt   # mongo, temurin, maven: borrar por ID si no los usa otro curso
```

## 10. 🚫 Qué se dejó fuera

- **Los `.env`** de las sondas (regla 6): solo traían la etiqueta de la base; `sondas-labcore.sh` los recrea.
- **Los borradores de prosa** del scratchpad (`inc/01.md` … `inc/21.md` de `ba539b99`, los incidentes antes
  de pasar al cuaderno): ya están en el curso.
- **Los scripts que editaban la prosa:** en `comandos.sh`.
- **Sesiones sin código de prueba:** `0b50e5e9` (decisiones del backend), `7db78a4d`, `3a741265`,
  `0f081255` y otras consultas cortas.
