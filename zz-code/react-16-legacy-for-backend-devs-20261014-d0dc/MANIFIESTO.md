# react-16-legacy-for-backend-devs-20261014-d0dc

- **Curso:** react-16-legacy-for-backend-devs
- **Tanda:** T3 (F04, F05, incidentes 09–12, A6) y la revisión de continuidad P1–T3
- **Creado:** 2026-10-14
- **Propósito:** el repo de prueba vigente, rehecho de F00 a F05 siguiendo los documentos, con sus pruebas, sus
  incidentes y la medición del tablero de F05.
- **Estado:** extraído (el 15/10/2026 T4 clonó `esclusa-app` con todas sus ramas y etiquetas en `…-20261015-f769`, que es el vigente)
- **Cómo regenerar lo que limpiar.py borra:** `npm ci` en `node:14.21.3` dentro de `esclusa-app/` (y de `etapas/f00b/`).

## Qué hay

- `esclusa-app/` — el repo de prueba: etiquetas `fase-00` … `fase-05`, ramas `incidente/01` … `incidente/12`, y el historial anterior en `previo-revision/*` y `previo-t1/historial-previo`.
- `etapas/f00`, `etapas/f00b` — worktrees de la reconstrucción (el primero, la etapa F00 de T1; el segundo, la historia nueva). `etapas/snap01/` — la etapa F01 de T1, extraída.
- `trabajo/` — pruebas de F04 y F05, `incidentes/`, plantillas de F03, F04 y F05 con sus renderizadores, comparador, `correr-pruebas.sh`, `correr-incidentes.sh`, `cypress-bench/`, ejemplos de los apéndices, `revision/` (los escáneres de la revisión) y `previo-revision/`.
- `salidas/` — logs y resultados (ver README §8).
- `verificacion-a-mano-T1-T3.md` — lo que el autor verifica con navegador.

## Qué sirvió

- `03-mock-api-express-caos.md`, `04-ruedas-crud.md` y `05-envios-manuales.md`, rendidos desde `trabajo/F0N-plantilla.md` con el código de su etiqueta.
- Las pruebas de regresión del cuaderno (09–12 y el bloque del 07), copiadas de `trabajo/incidentes/` con los imports de su ubicación.
- La tabla de la medición de F05 y el rango del giro ingenuo de F03.
- Los ejemplos de A5 §7 y A6 §6 y §11, comprobados tal como están en el `.md`.
