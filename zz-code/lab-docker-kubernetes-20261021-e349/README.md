# 🧪 lab-docker-kubernetes-20261021-e349 · cómo correr estas pruebas

> **Curso:** lab-docker-kubernetes · **Tanda:** C2 · **Creado:** 2026-10-21
> **Propósito:** la pasada en macOS con Docker, A3 desde la F08: fases, incidentes y mediciones

## 1. 🎯 Qué se prueba y para qué

| Prueba | Fase o apéndice | Alimenta |
|---|---|---|
| La pasada como lector, F08 en adelante | F08–F27 y los apéndices 🔥 | hallazgos desde H289 |
| B-12 · pruebas contra SQLite y contra Postgres | F12 §7 | `BENCHMARKS.md` § B-12 |
| B-16 · réplicas por runtime | F16 | `BENCHMARKS.md` § B-16 |
| Incidentes 05 a 26, con `task inc:break\|fix` | F08–F21 | el cuaderno |

Lo de Podman (B-04, B-05, la máquina de 4 GiB) **no** está aquí: es A4, la tanda C3.

## 2. 🛠️ Prerrequisitos

- macOS 26.7.1 arm64, MacBook Pro M1 Pro, 32 GB.
- Docker Desktop 4.92.0 (Engine 29.8.0), **máquina virtual de 4 GiB**, con el Kubernetes de Docker
  Desktop apagado.
- kind 0.33.0, kubectl 1.36.1, Helm 4.3.0 con helm-diff 3.15.15, Task 3.54.0, k9s 0.51.0,
  Hurl 8.0.1, k6 2.3.0, hyperfine 1.20.0, dive 0.13.1, Python 3.13.4, Google Chrome (sin interfaz,
  para las páginas del `storefront`).
- Red: los charts de Envoy Gateway y las imágenes base se bajan en cada corrida.

## 3. 🧭 Reglas antes de correr

El inventario previo está en `salidas/*-antes.txt` (2 contenedores, 89 imágenes, 13 volúmenes,
11 redes). Nada ajeno al curso se detiene, se borra ni se poda.

```bash
docker ps -aq --no-trunc > salidas/contenedores-antes.txt
docker images -q --no-trunc | sort -u > salidas/imagenes-antes.txt
docker volume ls -q > salidas/volumenes-antes.txt
docker network ls -q > salidas/redes-antes.txt
```

Cambios temporales en la máquina, con su reverso:

| Cambio | Reverso |
|---|---|
| Cluster `minimo` de kind | `task cluster:down -- minimo` |
| Contenedor `cloud-provider-kind` (F10 §4) | `docker rm -f cloud-provider-kind` (hecho) |
| `GatewayClass cloud-provider-kind` | `kubectl delete gatewayclass cloud-provider-kind` (hecho) |
| Volúmenes `lab-gomod` y `lab-gocache` (B-12) | `docker volume rm lab-gomod lab-gocache` |

## 4. ▶️ Cómo se corre

Todo desde `mi-lab/src/lab/`, que es **el repositorio de la pasada**: arranca con lo que trae la copia
inicial de la F00 §4.7 y crece fase a fase. No se copia código del `src/lab/` del curso; lo que sí se
copia es lo que un apéndice entrega (`a03`: `contracts/`; `a16`: el perfil `legacy` de `compose.yaml` y
`deploy/legacy/`; la copia inicial: `scripts/`, `kind/`, el Taskfile y `deploy/incidents/`).

```bash
cd mi-lab/src/lab
task cluster:up -- minimo          # el cluster de la Parte II
task build:all && task images:load -- minimo
task platform:gateway -- minimo    # F10
task platform:postgres -- minimo   # F12
task deploy -- minimo              # el sistema; desde la F13 es el chart, y las migraciones
                                   # y el seed son hooks (antes: task migrate y task seed:job)
kubectl apply -f deploy/qa/qa.yaml # el ambiente de QA de la F11, que no es del chart
task conformance TARGET=cluster -- G1
task conformance TARGET=cluster -- G4
```

La segunda cadena de la F14, cuando se la quiere ver:

```bash
task platform:postgres TENANT=tenant-b -- minimo
task deploy TENANT=tenant-b -- minimo
# y al terminar
helm -n apps-b uninstall tenant-b --wait && kubectl delete namespace apps-b
```

## 5. 📏 Cómo se mide

B-12 con el arnés del curso: `task measure -- B-12 --runs 5`, que corre las siete pruebas de
`pricing` contra los dos motores dentro de un contenedor `golang:1.27.1`, con las cachés calientes, y
publica la mediana y el rango de cinco corridas. Las apuestas de cada fase se miden con el comando que
la fase publica; cuando el arnés no es el mismo que el del autor (la de la F08 §7, con un sondeo de
`kubectl get`), queda dicho en el hallazgo.

## 6. 🧮 Los intermedios que amasan la salida

No hay: cada medición sale de su log en `logs/`, con el comando delante.

## 7. 🧾 Qué quedó en la máquina

Al cerrar la tanda se compara con `salidas/*-antes.txt` y se anota en `hallazgos.md`.

## 8. 🗒️ Los hallazgos

En `hallazgos-candidatos.md`, numerados desde H289, y de ahí pasan a
`prompts/verificacion-de-laboratorio/hallazgos.md`.

## 9. 🧰 Los scripts de esta corrida

Los de las fases viven en la raíz (`f22-medir.sh`, `f24-apuestas.sh`, `f25-perdida.py`, `f25-pendientes.py`,
`f26-rafaga.py`, `f26-defensas.py`, `f26-lluvia.sh`, `f27-rollout.py`, `f27-papel.py`, `f27-incidente.py`, `pq.py`,
`lq.py`, `loan-show.py`…); los de cada apéndice, en su carpeta (`a06/` a `a15/`, con sus manifiestos). Los de un solo
uso de las primeras fases vivieron en `/tmp` y su contenido quedó en el log que produjeron. `a-hallazgos.py` convierte
`hallazgos-candidatos.md` al formato del archivo de hallazgos del curso.

Una nota sobre el repositorio de la pasada: el commit de `fase-17` ya incluye el código de G7 de los servicios, escrito
antes de cerrar esa fase; el tag `fase-18` no lo agrega.

## 10. ♻️ Qué se puede borrar

`mi-lab/` (está en `mi-lab.bundle`, con todos los tags). Los volúmenes `lab-gomod` y `lab-gocache` ya se borraron al
cerrar C2. En Docker quedan, del curso: el cluster `lab` y `lab-registry` (arriba para O1) y las imágenes `lab/*`.

## 11. 🔁 Cómo seguir

C2 está **cerrada** el 24/10/2026: F08–F27, los incidentes de esas fases, el proyecto final y los apéndices `a06`–`a15`
(`a08` sin la compilación nativa). Hallazgos H289–H371, ya trasladados a `prompts/verificacion-de-laboratorio/hallazgos.md`.
Falta la revisión del autor, y después C3 (Podman) y C4 (O1, con el cluster `lab` que quedó arriba).
