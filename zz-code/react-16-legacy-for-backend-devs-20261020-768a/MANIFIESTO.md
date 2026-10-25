# react-16-legacy-for-backend-devs-20261020-768a

- **Curso:** react-16-legacy-for-backend-devs
- **Tanda:** T12 (cierre de la reescritura)
- **Creado:** 2026-10-20
- **Propósito:** regresión completa de §5.1 desde un clon limpio del repo de prueba, tras R19 y measure.js
- **Estado:** archivado
- **Cómo regenerar lo que limpiar.py borra:** `trabajo/regresion.sh` (hace `npm ci` en cada worktree de `etapas/`, en `node:14.21.3`); los módulos de Go viven en un volumen que se borró al cerrar y se bajan solos

## Qué hay

- `esclusa-app.bundle` — **lo que se versiona** del repo de prueba final: todas las ramas y los 32 tags en un archivo (git no versiona un repo dentro de otro). Se restaura con `git clone esclusa-app.bundle esclusa-app && cd esclusa-app && for b in $(git branch -r | grep -v HEAD | sed 's|origin/||'); do git branch -q "$b" "origin/$b" 2>/dev/null; done`. La historia previa a R19 está en `…6436/respaldos/esclusa-app-antes-de-r19.bundle`.
- `esclusa-app/` — clon con `--no-local` de `…6436/esclusa-app` después del `filter-branch` de R19, con todas las ramas como locales (58) y los 32 tags. Es la copia final del repo de prueba del curso.
- `etapas/<tag>/` — un worktree por tag de cierre, con su `node_modules`.
- `trabajo/` — `regresion.sh`, `f03-medir.sh`, `incidentes.sh` (y `incidentes/` con las pruebas extraídas del cuaderno y `conteo21.js`), `be05-k6.sh`, `be08-carga.sh`, `k6-todo.sh`, `k6-be05.sh`, `e2e.sh` (y `e2e/spin-log.cy.js`).
- `salidas/` — cada corrida, con los intentos fallidos por el arnés conservados con sufijo `-intento1-…`. Ya no está en disco (comprobado el 25/10/2026).

## Qué sirvió

- La medición de F03 del 20/10 → `03-mock-api-express-caos.md` §5.4 (rango de las doce corridas).
- La corrida de k6 de be05 del 20/10 → `be05-giro-concurrente.md` §8 (nota bajo la tabla).
- El resultado de toda la regresión → guía §17.5 del curso.
