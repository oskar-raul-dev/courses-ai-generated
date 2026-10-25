# 🧪 lab-docker-kubernetes-20261020-1691 · cómo correr estas pruebas

> **Curso:** lab-docker-kubernetes · **Tanda:** C1 · **Creado:** 2026-10-20
> **Propósito:** pasada en macOS: A2 (B-00 de Docker) y A3 de F00 a F07

## 1. 🎯 Qué se prueba y para qué

| Prueba | Fase o apéndice | Alimenta |
|---|---|---|
| B-00 de Docker, perfiles `minimo`, `lab` y `legacy` | `a01` § La memoria que ocupa cada perfil | A2; cierra H155 |
| Checklist de versiones de herramientas | F00 § 7 | C1-a (`openssl`) |
| La pasada de F00 a F07 como lector | F00–F07, `a01`, `a16`, `a03` | hallazgos desde H271 |

Lo de Podman (B-04, B-05, la máquina de 4 GiB, `engine:use -- podman`) **no** está aquí: es A4, la
tanda C3, que necesita Docker Desktop cerrado.

## 2. 🛠️ Prerrequisitos

- macOS 26.7.1 arm64, MacBook Pro M1 Pro, 32 GB.
- Docker Desktop 4.92.0 (Engine 29.8.0), **máquina virtual de 4 GiB** (`MemoryMiB: 4096` en
  `~/Library/Group Containers/group.com.docker/settings-store.json`), **dedicado**: sin contenedores
  ajenos al curso corriendo, y con el **Kubernetes de Docker Desktop apagado**
  (`docker desktop kubernetes status` → `disabled`).
- kind 0.33.0, kubectl 1.36.1, Helm 4.3.0 con helm-diff 3.15.15, Task 3.54.0, k9s 0.51.0,
  Hurl 8.0.1, k6 2.3.0, hyperfine 1.20.0, dive 0.13.1, Python 3.13.4.
- Red: los charts de Envoy Gateway, cert-manager y trust-manager se bajan por OCI en cada corrida.

## 3. 🧭 Reglas antes de correr

El inventario previo está en `salidas/*-antes.txt` (2 contenedores, 66 imágenes, 10 volúmenes,
11 redes). Nada ajeno al curso se detiene, se borra ni se poda: el contenedor `gfapp-dev-db-1` lo
detuvo el autor y lo vuelve a levantar él.

```bash
docker ps -aq --no-trunc > salidas/contenedores-antes.txt
docker images -q --no-trunc | sort -u > salidas/imagenes-antes.txt
docker volume ls -q > salidas/volumenes-antes.txt
docker network ls -q > salidas/redes-antes.txt
```

Cambios temporales en la máquina, con su reverso:

| Cambio | Reverso |
|---|---|
| `gfapp-dev-db-1` detenido | `docker start gfapp-dev-db-1` (lo hace el autor) |
| VM a 4 GiB (`MemoryMiB: 4096`) | quitar la clave o ponerla en 8192, y reiniciar |

## 4. ▶️ Cómo se corre

Dos árboles, a propósito:

- **`b00/lab/`** — copia de `src/lab/` del curso, solo para medir. Así los builds, los `.venv` y los
  datos de la medición no ensucian el árbol del curso.
- **`mi-lab/`** — el repositorio de la pasada, **como lector**: arranca con lo que trae la copia
  inicial de §4.7 (Taskfile, `kind/`, `scripts/`, `legacy/`) y crece fase a fase. No se copia código
  de `src/lab/` del curso: si se copia, la prueba deja de valer. Lo que sí se copia es lo que un
  apéndice entrega (`a03`: `contracts/`; `a16`: el perfil `legacy` de `compose.yaml`).

```bash
# A2, desde b00/lab/
task measure -- B-00 --profile minimo --runs 3
task measure -- B-00 --profile lab --runs 3
task legacy:up && task legacy:down       # las imágenes del patrimonio, una vez
task measure -- B-00 --profile legacy --runs 3
```

## 5. 📏 Cómo se mide

Las condiciones son las de `a01`, idénticas a las publicadas el 03/10/2026, que es la única forma de
comparar: perfiles `minimo`, `lab` y `legacy`; **3 corridas por celda, cada una con el cluster creado
desde cero**; la memoria usada de la máquina virtual (`MemTotal − MemAvailable`, leída desde el nodo,
que comparte su `/proc/meminfo`), en MiB, 60 s después de que todo está listo; mediana con mínimo y
máximo. La máquina virtual, en 4 GiB.

Lo que cambió respecto del 03/10: **el Kubernetes de Docker Desktop está apagado y verificado como
apagado**, que es lo que pedía H155.

## 6. 🧮 Los intermedios que amasan la salida

De la salida cruda a la cifra publicada, en orden:

- **B-00, B-04 y B-07** los amasa `scripts/measure/measure.py`: deja el crudo en `bench/<id>/results/`
  y saca por pantalla la mediana con mínimo y máximo. Lo que va al curso es ese resumen, sin más
  cuentas a mano.
- **La tabla de `stop` de la F03** se mide con `/usr/bin/time -p docker stop -t 10 <contenedor>`, tres
  corridas por servicio, leyendo `real`. **Con `docker compose stop` no vale:** el CLI de compose suma
  unos 0,2 s a cada fila, que sobre los 0,12 s de `pricing` es el triple.
- **Las dos pruebas de caché de la F04** (orden de instrucciones y `.dockerignore`) se miden igual,
  con `/usr/bin/time -p docker build`, tocando el archivo que corresponde antes de cada corrida.

## 7. ✅ Qué se espera ver

Lo publicado por el curso, con estas excepciones medidas el 20/10/2026 y ya resueltas en el texto:

| Qué | Publicado | Medido | Qué se hizo |
|---|---|---|---|
| B-00 `minimo` y `lab` | ver `a01` | dentro del 1 % | se deja; se anota la reconfirmación |
| B-00 `legacy` | 754 / 1.531 / **804** / 684 / 43 s | 647 / 1.394 / **743** / 666 / 37 s | corregido en `a01` con las dos fechas (H272) |
| B-04, tamaños | 270,7 MB en total | **270,8 MB** | se deja: reproduce |
| B-04, build en frío | 88,8 s Java · 7,5 s PHP | 214,6 s · 136,8 s | no comparable: otros Dockerfile y otra red (H283) |

## 8. 📂 Salidas

- `logs/` — los crudos de cada medición, copiados a
  `prompts/verificacion-de-laboratorio/logs/c1/` del curso.
- `salidas/*-antes.txt` — el inventario de Docker previo a la tanda.
- `b00/lab/bench/b00/results/` — los JSON de B-00 del 20/10/2026, al lado de los del 03/10.
- `mi-lab/` — el repositorio de la pasada, con sus commits `fNN:` y sus tags `fase-NN-<slug>`.

## 9. 🧹 Limpieza

```bash
# Desde mi-lab/src/lab/
task compose:down && task legacy:down && task cluster:down -- minimo && task cluster:down -- lab
# Las imágenes del curso, por nombre (nunca un prune: hay trabajo ajeno en esta máquina)
docker images --filter reference='lab/*' -q | sort -u | xargs -r docker image rm -f
```

Lo del autor: `docker start gfapp-dev-db-1` y la memoria de la VM donde la quiera.

## 10. 🚫 Qué se dejó fuera

- `node_modules/`, `vendor/`, `dist/` y `target/` de los cinco servicios: los regenera el build de su
  imagen, y el `.gitignore` de `mi-lab/` los excluye.
- Las imágenes y los clusters: se rehacen con `task build:all`, `task cluster:up` y `task images:load`.

## 11. 🗃️ El repositorio de la pasada

`mi-lab/` es un repositorio propio (es parte de lo que se valida: la convención de git del curso).
Para que sus 8 commits y sus 8 tags `fase-NN-<slug>` entren al repositorio de cursos se guarda como
**bundle**, igual que se hizo con `esclusa-app.bundle` en react-16:

```bash
git bundle create mi-lab.bundle --all     # desde mi-lab/
git bundle verify mi-lab.bundle           # «records a complete history»
git clone mi-lab.bundle mi-lab            # para volver a abrirlo
```

El directorio `mi-lab/` en sí **no se versiona**: `.gitignore` de la tanda lo excluye para que git no
guarde un puntero vacío.
