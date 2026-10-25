# lab-docker-kubernetes-20261021-e349

- **Curso:** lab-docker-kubernetes
- **Tanda:** C2
- **Creado:** 2026-10-21
- **Propósito:** la pasada en macOS como lector, A3 de la F08 en adelante
- **Estado:** vigente
- **Cómo regenerar lo que limpiar.py borra:** desde `mi-lab/src/lab/`, `task build:all` reconstruye
  las cinco imágenes; `services/pricing` necesita `go mod download` (lo hace el Dockerfile) y
  `services/replenish` y `services/storefront`, `npm ci`. El repositorio de la pasada se recupera del
  bundle: `git clone mi-lab.bundle mi-lab`.

## Qué hay

- `mi-lab/` — el repositorio de la pasada, **como lector**, que viene de C1 (venía con los tags
  `fase-00` a `fase-07`) y crece aquí fase a fase. No se versiona: va como `mi-lab.bundle`.
- `logs/` — la salida de cada comando que alimenta un hallazgo, un archivo por tramo de fase.
- `salidas/` — el inventario de la máquina al abrir la tanda (`*-antes.txt`).
- `a06/` a `a15/` — los scripts y manifiestos de cada apéndice 🔥 (los Dockerfiles cruzados de a06, los constructores de
  a07, la medición de a08, el SSR de a09, el mesh de a10, Argo de a11, el bucle de a12, el respaldo de a13, el token de
  a14 y NATS de tres miembros de a15).
- Los scripts de las fases, en la raíz (`f2x-*.py|sh`, `pq.py`, `lq.py`…), y `k6/`.
- `hallazgos-candidatos.md` — los hallazgos antes de pasarlos a
  `prompts/verificacion-de-laboratorio/hallazgos.md`.

## Qué sirvió

Lo que corrigió el curso está en `hallazgos-candidatos.md`, con el documento que cambia en cada uno.
