# docker-container-legacy-20261114-75ad

- **Curso:** docker-container-legacy
- **Tanda:** P0–P7 (plan cerrado, copiado en `plan-de-pasada-final.md`)
- **Creado:** 2026-11-14
- **Propósito:** pasada del autor como lector (P0–P7) y a17
- **Estado:** cerrado el 2026-11-15
- **Cómo regenerar lo que limpiar.py borra:** `node_modules` de los proyectos: `npm ci` dentro de la imagen `legacy-node-toolchain` (F09); las imágenes, con la fase correspondiente del curso; las VM del a17, con `experimentos/a17/corrida.sh`.

## Qué hay

- `hallazgos.md` — los 77 hallazgos crudos (V01–V77), por tanda, con su log.
- `plan-de-pasada-final.md` — el plan P0–P7 con su bitácora, borrado del curso al cerrar.
- `logs/P0/`–`logs/P6/` — inventario inicial de Docker y las salidas de cada tanda.
- `lab/` — el repositorio del lector, construido fase a fase (ignorado por git).
- `fixtures/` — los cinco fixtures de F11 sin `node_modules`.
- `proyectos/labcore/` — copia de `zz-code/angular-8-legacy-for-backend-devs-20261020-8dfa/host-labcore/` (Angular 8.2.14, `node-sass` 4.14.1): el "proyecto real" de F11 (PD1). Sin `.git` (quitado el 15/11 para versionarlo en este repo).
- `proyectos/ajeno-angular8/` — clon de `t-hnh10/angular-8-app` (commit 4443bf9) para el ej. 22 de F11. Sin `.git` ni `dist/` (quitados el 15/11; el `dist/` se regenera con `npm run build`).
- `validacion/` — los dos expedientes de F11 (LabCore nivel 6, ajeno nivel 5).
- `experimentos/` — un directorio o script por fase o apéndice probado (tabla en el README §4). `experimentos/f34/proyecto/` era un repo de prueba de F34; su `.git` se quitó el 15/11.

## Qué sirvió

- Las correcciones de V01–V77, aplicadas a F02–F34 y a01–a17 del curso, con su fila en la bitácora de `prompts/pendientes-a-futuro.md`.
- `experimentos/a17/guion.sh` → `src/a17-compilar-node-desde-fuente/compilar-node.sh` (con `JOBS`).
- Los dos expedientes de `validacion/` → el ej. 22 de F11 y el N/A de tests de LabCore que resolvió a09.
