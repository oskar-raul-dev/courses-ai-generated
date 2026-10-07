# 🧪 angular-16-legacy-for-backend-devs-20261006-ab79 · cómo correr estas pruebas

> **Curso:** angular-16-legacy-for-backend-devs · **Tanda:** rescate posterior al cierre · **Creado:** 2026-10-06
> **Propósito:** rescatar de las transcripciones de las sesiones el código de prueba de la producción
> del curso, con instrucciones para replicarlo.
> **Vigencia:** rescatado el 2026-10-06 con `zz-instrucciones/herramientas/rescatar-transcripcion.py`,
> sin ejecutar nada. `sondas-certcore.sh` es nuevo: replica las sondas del 09/09 con las reglas de hoy;
> se validó su sintaxis y su `docker compose config`, **no se corrió**.

> ⚠️ **Lo que no se puede rescatar.** El track base (frontend) ya estaba en el commit «Courses V1» del
> 16/08/2026, y la primera transcripción guardada de este repositorio es del 06/09. Lo que se probó al
> escribir el track base no tiene registro. Lo que sí hay es del track backend (CertCore) y de las
> revisiones posteriores.

---

## 1. 🎯 Qué se prueba y para qué

| Carpeta | Sesión | Fecha (UTC) | Qué hay |
|---|---|---|---|
| `01-apendices-babb5b75/` | `babb5b75…` | 06/09 22:20 → 07/09 01:49 | Redacción de los apéndices: la verificación de anclas del índice y el inventario final |
| `02-sondas-be-f803daaa/` | `f803daaa…` | 09/09, 03:17–13:25 | **Las únicas pruebas que ejecutaron código.** Decidían si el stack de CertCore (PHP 7.4 + Lumen + PostgreSQL moderno) era viable en arm64. Aquí están los archivos de CertCore; los de LabCore, en el rescate de angular-8 |
| `03-forense-2924cb25/` | `2924cb25…` | 11/09, 16:14–17:31 | La revisión del cuaderno de incidentes y las piezas forenses: enlaces recíprocos, convención de tags, distribución de dificultad, pie recíproco |
| `04-track-be-31a544c8/` | `31a544c8…` | 11/09 17:46 → 12/09 02:50 | Redacción del track BE: dependencias de Lumen 5.8, numeración de ejercicios, plantilla, anclas del cuaderno, enlaces; `slug.py`, `slug2.py` y `xanchor.py` calculan anclas al estilo GitHub (con y sin U+FE0F) |

### Las sondas de CertCore (`02-`)

| Prueba | Qué resolvió |
|---|---|
| Arquitecturas de `php:7.4-cli/apache/fpm` en Docker Hub | publican `linux/arm64/v8`; último push 2022-11-15, la imagen se congeló al llegar PHP 7.4 a EOL |
| `docker build` de PHP 7.4 + `pdo_pgsql` | **falló**: el `InRelease` de `bullseye-security` había caducado el día anterior; con `Check-Valid-Until=false`, 404; `archive.debian.org` no servía `bullseye-security` |
| El mismo build con las fuentes de `snapshot.debian.org/…/20221114T000000Z` | construye a la primera (`archivos/…/phpcheck/Dockerfile`) |
| PHP 7.4.33 (aarch64) → PostgreSQL 16.9 | conexión OK, `scram-sha-256` aceptado por la `libpq 13` de bullseye, escritura OK |
| El stack con Compose (`archivos/…/certcore/`) | `php -S` + `postgres:${POSTGRES_TAG}` responde el JSON con versión de PHP, arquitectura y versión de Postgres |

Esos resultados se escribieron entonces en `ideas_backend_cursos_angular.md` (raíz, sin versionar), §15, y
de ahí pasaron a `prompts/propuesta-fases-backend.md` y a la receta de imagen del track,
`bea-02-receta-de-imagen-y-compose.md`.

### Qué hay en cada carpeta

- `comandos.sh` — todos los comandos Bash de la sesión, en orden. Una bitácora: no se corre entera.
- `bitacora.md` — los comandos que ejecutaron código, con el inicio de su salida.
- `scripts/NNN-HHMM-verifica.{py,sh}` y su `.salida.txt` — las verificaciones y lo que la sesión vio. Se
  omitieron los scripts que editaban la prosa (siguen en `comandos.sh`).
- `archivos/` y `archivos.tsv` — los archivos que ya no existen, con la ruta original.

## 2. 🛠️ Prerrequisitos

- **Para reconstruir:** Python 3 y las transcripciones en
  `~/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/`.
- **Para las sondas:** Docker Desktop en arm64 (las sondas fuerzan `--platform linux/arm64`) y Compose
  2.24 o posterior (el override usa `!reset`). Imágenes: `php:7.4-cli`, `postgres:16` o
  `postgres:${POSTGRES_TAG}` (16.9 por omisión) y `composer:2`.
- **Para las verificaciones:** Python 3 y bash sobre el curso.

## 3. 🧭 Reglas antes de correr

```bash
cd zz-code/angular-16-legacy-for-backend-devs-20261006-ab79
mkdir -p salidas
docker ps -aq --no-trunc > salidas/contenedores-antes.txt
docker images -q --no-trunc | sort -u > salidas/imagenes-antes.txt
docker volume ls -q > salidas/volumenes-antes.txt
docker network ls -q > salidas/redes-antes.txt
```

- Las sondas originales **publicaban el puerto 3000** y corrían contenedores sin etiqueta (`pgcheck`,
  `certcore-*`). `sondas-certcore.sh` no publica puertos (la petición HTTP se hace desde dentro del
  contenedor `api`), lo etiqueta todo con `curso=angular-16-legacy-for-backend-devs`, usa la red
  `a16-sonda-red` y el proyecto Compose `a16-certcore`.
- ⚠️ **Queda un volumen de aquella sesión, `certcore_pgdata`** (del 09/09). No lo creó este rescate y no
  se toca; si ya no sirve, lo decide Oskar.
- Las verificaciones se corren desde la raíz del curso (`cursos-legacy/angular-16-legacy-for-backend-devs`),
  que es donde corrieron (entonces el curso vivía en la raíz del repositorio: las rutas absolutas de los
  scripts apuntan allí).

## 4. ▶️ Cómo se corre

```bash
cd zz-code/angular-16-legacy-for-backend-devs-20261006-ab79
./rescatar.sh               # rehace desde cero las carpetas generadas (lee ../rescates.tsv); no ejecuta nada
./rescatar.sh --comprobar   # las regenera aparte y compara, sin tocar nada
./sondas-certcore.sh php       # PHP 7.4 + pdo_pgsql contra postgres:16.9, en red propia
./sondas-certcore.sh compose   # el stack rescatado, consultado desde dentro del contenedor api
./sondas-certcore.sh limpiar   # borra lo creado, por etiqueta y por proyecto, y salidas/sondas
```

`sondas-certcore.sh` copia los archivos rescatados a `salidas/sondas/`, recrea el `.env` (que no se
rescató por la regla 6: su única línea era `POSTGRES_TAG=16.9`) y agrega un `compose.override.yaml` con
`ports: !reset []` y la etiqueta en servicios, build y volumen. `POSTGRES_TAG=17 ./sondas-certcore.sh php`
prueba otra versión. Los comandos originales, tal como corrieron, están en `02-sondas-be-f803daaa/comandos.sh`
y en los scripts `001`–`010`.

Una verificación, contra el curso de hoy:

```bash
AQUI="$PWD/zz-code/angular-16-legacy-for-backend-devs-20261006-ab79"
cd cursos-legacy/angular-16-legacy-for-backend-devs
python3 "$AQUI/04-track-be-31a544c8/scripts/012-0213-verifica.py"    # enlaces internos y anclas
```

La verificación vigente del curso es `python3 prompts/verificar-forenses.py` (desde su raíz); los scripts
de aquí son lo que se revisó el 11 y 12/09.

## 5. 📏 Cómo se mide

No aplica: las sondas responden sí o no (construye, conecta, acepta SCRAM), no miden tiempos.

## 6. 🧮 Los intermedios que amasan la salida

Ninguno: la salida de cada sonda es el texto que imprime el `php -r` o el JSON del `index.php`; las de
Docker Hub pasan por un `python3 -c` que filtra la API (está en los scripts `001` y `004`).

## 7. ✅ Qué se espera ver

Del 09/09/2026, en Docker Desktop 29.6.2 sobre `aarch64` (`02-…/bitacora.md`):

```text
conexion:       OK
servidor:       PostgreSQL 16.9 (Debian 16.9-1.pgdg120+1)
password_encr:  scram-sha-256
hash del user:  SCRAM-SHA-256...
php:            7.4.33 (aarch64)
escritura:      hola
```

y del stack: `{"service": "certcore-api (Lumen ira aqui)", "php": "7.4.33", "arch": "aarch64",
"postgres": "16.9 (…)"}`. Si `snapshot.debian.org` dejara de servir esa fecha, el build fallaría como el
primero: la nota de mantenimiento de entonces proponía usar solo `bullseye main` desde
`archive.debian.org`. Las verificaciones: su `.salida.txt`.

## 8. 📂 Salidas

`salidas/sondas/` (la copia de trabajo de las sondas) y los inventarios de §3. Se regeneran corriendo
otra vez. Nada se copió al curso desde este rescate.

## 9. 🧹 Limpieza

```bash
./sondas-certcore.sh limpiar
docker images -q --no-trunc | sort -u > salidas/imagenes-despues.txt
comm -13 salidas/imagenes-antes.txt salidas/imagenes-despues.txt   # php:7.4-cli, postgres, composer: borrar por ID si no los usa otro curso
```

## 10. 🚫 Qué se dejó fuera

- **Los `.env`** de las sondas (regla 6): solo traían la etiqueta de la base; `sondas-certcore.sh` los recrea.
- **Las rutas `/usr/…`:** son heredocs citados dentro de la prosa de un apéndice (el `config.json` del
  A09), no archivos que la sesión escribiera.
- **Los borradores de prosa** que las sesiones escribieron en el scratchpad (`sec8.md` y similares): ya
  están en el curso.
- **Los scripts que editaban la prosa:** en `comandos.sh`.
- **Sesiones sin código de prueba:** `afcb18cd` y `0d9d49e5` (06/09, fases 09 y 10), `0b50e5e9` (10/09,
  decisiones del backend), `19e2cb34`, `89a806b3`, `cf3d8032`, `84c19d96` (consultas cortas).
