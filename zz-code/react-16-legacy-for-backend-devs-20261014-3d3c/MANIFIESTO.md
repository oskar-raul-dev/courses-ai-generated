# react-16-legacy-for-backend-devs-20261014-3d3c

- **Curso:** react-16-legacy-for-backend-devs
- **Tanda:** T1 (F00–F02, incidentes 01–06, apéndices A1–A5), cerrada con la verificación a mano entregada
- **Creado:** 2026-10-14
- **Propósito:** repo de prueba `esclusa-app` (tags `fase-00` a `fase-02`), ramas `incidente/01` a `incidente/06`, y las pruebas de render, rutas y auth
- **Estado:** extraído (T12, 20/10/2026)
- **Cómo regenerar lo que limpiar.py borra:** `npm ci` en `esclusa-app/` (node:14.21.3); `npm install` para `node_modules`; `docker pull node:20` y `ghcr.io/mermaid-js/mermaid-cli/mermaid-cli:11.4.2` (imágenes)

## Qué hay

- `esclusa-app.bundle` — **lo que se versiona** del repo de prueba: todas las ramas y tags en un archivo (git no versiona un repo dentro de otro), hecho el 24/10/2026. Se restaura con `git clone esclusa-app.bundle esclusa-app && cd esclusa-app && for b in $(git branch -r | grep -v HEAD | sed 's|origin/||'); do git branch -q "$b" "origin/$b" 2>/dev/null; done`.
- `esclusa-app/`: el repo del alumno, con historial lineal F00→F02 (rama `master`), las ramas `incidente/01`…`06` (cada una en su estado roto) y la rama `historial-previo` (el historial anterior, antes de rehacer F01 y F02).
- `trabajo/`: pruebas y comparadores de la sesión (`inc03.test.jsx`, `inc04.test.jsx`, `inc05.test.js`, `inc06.test.jsx`, `correr.sh`, `comparar-bloques.py`, `comparar-f00.py`, `editar_cuaderno_01_06.py`, `editar_apendices_a3_a4.py`, `F02.auth.test.js`, `AppRouter.routes.test.js`, `WheelCard.render.test.js`).
- `verificacion-a-mano-T1.md`: las comprobaciones en navegador que quedan para el autor.
- `salidas/`: registros de cada comprobación, inventarios de Docker, y la lista de etiquetas previa al rehacer el historial.

## Qué sirvió

- Los bloques de código de F00, F01 y F02 del curso coinciden con los archivos del repo de prueba (salidas de `comparar-bloques.py`).
- El cuaderno de los incidentes 01–06 recibió los textos del dominio nuevo y sus pruebas de regresión (`editar_cuaderno_01_06.py`).
