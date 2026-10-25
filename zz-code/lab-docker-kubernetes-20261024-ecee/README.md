# 🧪 lab-docker-kubernetes-20261024-ecee · cómo correr estas pruebas

> **Curso:** lab-docker-kubernetes · **Tanda:** C3 del plan de cierre (el perfil de Podman) · **Creado:** 2026-10-24
> **Propósito:** la pasada como lector con Podman y Docker Desktop cerrado: F00 (la máquina), F03 y F05 (las notas
> 🦭 y B-05), F07 (B-07 con kind, k3d y minikube) y B-00 de Podman; al final, B-12 con Podman.
> Se llena **mientras se prueba**: cada script nuevo entra aquí en la misma sesión.

## 1. 🎯 Qué se prueba y para qué

| Prueba | Documento | Alimenta |
|---|---|---|
| `podman machine init --memory 4096` y `task engine:use -- podman` | F00 §4.3 y §4.6, `a01` | H379 |
| Las notas 🦭 del volumen sin root y `podman top` | F03 | H383 |
| §4, §5.1–§5.3 y §5.5 (`task images:load`) | F05 | H380, H381 |
| `task measure -- B-05 --runs 5` | F05 §8, `BENCHMARKS.md` | B-05, H382 |
| `task measure -- B-07 --tool kind\|k3d\|minikube --runs 3`, y minikube de tres nodos a mano | F07 §6 y §8 | B-07, H384 |
| `task measure -- B-00 --profile minimo\|lab\|legacy --runs 3` | `a01` § La memoria de cada perfil | B-00 |
| `task measure -- B-12` con Podman | F12, `BENCHMARKS.md` | B-12 |

Los hallazgos van primero a `hallazgos-candidatos.md` y, al cerrar la tanda, a
`prompts/verificacion-de-laboratorio/hallazgos.md` del curso.

## 2. 🛠️ Prerrequisitos

- Podman 6.1.3 y Podman Desktop 1.29.3 con el instalador oficial (los instaló el autor); **Docker Desktop cerrado**.
- La máquina `podman-machine-default` (libkrun, 4 GiB, 4 CPU), creada en esta tanda; adentro corre Podman 6.1.4.
- kind 0.33.0, k3d 5.9.0, minikube 1.39.0, kubectl, Task, Python 3.
- `mi-lab/`: clon del repositorio de la pasada de C2 (`../lab-docker-kubernetes-20261021-e349/mi-lab`), con tres
  worktrees por tag: `f03/` (`fase-03-…`), `f05/` (`fase-05-…`) y `f07/` (`fase-07-…`). En `f05/` y `f07/`,
  `STEP_TAGS` va en `g0`, como manda la F02 §4.3 (los tags son de C1, anteriores a H289).

## 3. 🧭 Reglas antes de correr

El inventario de Podman al abrir está en `salidas/*-antes.txt` (máquina nueva: vacío). Todo lo que se crea es del
curso: los clusters (`minimo`, `lab`, `b07`), las imágenes `docker.io/lab/*` y `docker.io/lab-f03/*`, la red `kind`.
Docker Desktop no se toca: está cerrado durante toda la tanda.

## 4. ▶️ Cómo se corre

Desde `f05/src/lab/` (F05 y B-05) o `f07/src/lab/` (F07 y B-00), con `task engine:use -- podman`:

```bash
task build:all && task cluster:up -- minimo && task images:load -- minimo   # F05 §5.5
task cluster:down -- minimo && task measure -- B-05 --runs 5                 # B-05
for t in kind k3d minikube; do task measure -- B-07 --tool $t --runs 3; done # B-07
minikube start -p b07 --driver=podman --nodes=3; minikube delete -p b07      # el error de los workers
podman network rm b07                                                        # la red que deja minikube
task legacy:up && task legacy:down                                           # imágenes del patrimonio
for p in minimo lab legacy; do task measure -- B-00 --profile $p --runs 3; done
```

Las notas de la F03 se corren desde `f03/src/lab/` con imágenes `docker.io/lab-f03/*` (el `pricing` de G0, de una
etapa), para no pisar las de la F05; los comandos exactos están en `logs/f03-podman.log`.

## 5. 📄 Qué deja

`logs/` (una corrida por archivo) y `resultados/`, la copia de los JSON del arnés (los originales quedan en los
worktrees y en `b00/lab/`, que no se versionan: ver `MANIFIESTO.md`).

## 6. 🐳 El tramo con los dos motores

Con Docker Desktop abierto por el autor (pide contraseña para recuperar el socket, H390), desde `f07/src/lab/`, `f05/src/lab/`,
`f03/src/lab/` y `b00/lab/`:

```bash
podman machine start                                  # F00 §4.6, el aviso del socket
task engine:use -- podman && task engine:status       # y de vuelta a docker
task engine:use -- docker && task cluster:up -- minimo
task engine:use -- podman && task cluster:up -- minimo   # F05 §9: el 8080, y el contexto que kind borra
KIND_EXPERIMENTAL_PROVIDER=docker kind export kubeconfig --name minimo
docker build -t lab/pricing services/pricing && docker save … && podman load …   # F03 §5.5
task engine:use -- docker && task test:pricing DB=postgres                         # main_test.go con Ryuk
```

Los comandos exactos están en `logs/c3-dos-motores-*.log`; la limpieza, en `logs/c3-limpieza-podman.log` y
`salidas/docker-*-dos-motores.txt`.
