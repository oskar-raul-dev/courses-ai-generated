# vue2-legacy-for-backend-devs-20261018-fb1d

- **Curso:** vue2-legacy-for-backend-devs
- **Tanda:** T0–T3 del plan de apéndices Apple Silicon
- **Creado:** 2026-10-18
- **Propósito:** Node 14 x64 en Apple Silicon y los apéndices a6 (arm64) y a7 (Docker + Colima) del Curso 01
- **Estado:** cerrado (19/10/2026)
- **Cómo regenerar lo que limpiar.py borra:** `./t0-devc-npm-ci.sh` (los demás `npm ci` corren en contenedores `--rm`)

## Qué hay

- `f11/`, `q/`, `backend/`: árboles de prueba copiados de `…-b44a`.
- `devc/`: el devcontainer candidato de a7 §6 sobre F11.
- `t0-*.sh`: las pruebas de T0; logs en `salidas/t0/`.

## Qué sirvió

- F0 🍎, `a6-arm64-m1.md` y `a7-docker-colima.md` del Curso 01 (el devcontainer de `devc/tiquetera-legacy/.devcontainer/`, byte a byte).
- Guía §17.3–§17.6 del paquete.
