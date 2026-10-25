# react-16-legacy-for-backend-devs-20261018-6436

- **Curso:** react-16-legacy-for-backend-devs
- **Tanda:** T7 (y R23 de T6), T8, T9 y T10
- **Creado:** 2026-10-18
- **Propósito:** el repo de prueba vigente del track BE: be00–be09 en Go, los dieciocho incidentes BE, y sus mediciones (k6 incluido)
- **Estado:** archivado (T12, 20/10/2026: la copia final del repo de prueba es la de `…20261020-768a`)
- **Cómo regenerar lo que limpiar.py borra:** `docker run --rm -v "$PWD/esclusa-app":/app -w /app node:14.21.3 npm ci`; los módulos de Go con `go mod download` dentro de `golang:1.19.13`

## Qué hay

- `copia-planes/` — `_desechable-plan-de-edicion.md` y `_desechable-plan-de-validacion.md` del curso, copiados el 20/10/2026 antes de borrarlos (T12, con permiso del autor).
- `respaldos/` — `esclusa-app-antes-de-r19.bundle` (todas las ramas y tags antes del `filter-branch` de R19, T12) y `filter-branch.txt`. Fuera de `salidas/` porque `limpiar.py` borra `salidas/` y esto no se regenera.
- `esclusa-app/` — el repo de prueba (de `f769`), con las etiquetas `pre-backend-go`, `fase-be00` … `fase-be09`, `apendice-bea-02-…` y `apendice-bea-10-…`, y las ramas `incidente/be-01` … `be-18`, `apendice/bea-02` y `apendice/bea-10`.
- `trabajo/` — scripts para levantar el laboratorio, plantillas de las fases rendidas, pruebas extra de be01 y be02, el recorrido de Cypress, las fuentes de los incidentes BE y sus regresiones.
- `salidas/` — cada medición de la tanda y el inventario inicial de Docker. Ya no está en disco (comprobado el 25/10/2026; ver README §8).
- `etapas/` — `worktree` efímeros (`go3001`).
- `verificacion-a-mano-T7.md` a `-T10.md` — lo que solo se ve en un navegador o con tres terminales.

## Qué sirvió

be00–be09, el cuaderno BE entero, bea-01 a bea-11, F09 y F10 (R23), y las preparaciones de incidentes BE del curso. `server/CONTRACT.md`, `smoke.sh` y `evidence/` quedan en el repo como parte de las fases.
