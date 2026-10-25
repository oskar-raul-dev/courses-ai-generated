# react-16-legacy-for-backend-devs-20261015-f769

- **Curso:** react-16-legacy-for-backend-devs
- **Tanda:** T4 (F06, F07, incidentes 13–17, A7, A11), T5 (F08, A10, A14, incidente 18) y T6 (F09–F11, A8, A12,
  A13, A5, incidentes 19–21)
- **Creado:** 2026-10-15
- **Propósito:** el repo de prueba vigente, clonado de `…-20261014-d0dc` con todas sus ramas y etiquetas, con F06 y F07
  escritas siguiendo los documentos, las ramas de incidente 13–17 y las pruebas de A7 y A11.
- **Estado:** extraído (T12, 20/10/2026)
- **Cómo regenerar lo que limpiar.py borra:** `npm ci` en `node:14.21.3` dentro de `esclusa-app/` (rxjs-marbles se
  instala aparte, sin guardar, en cada corrida de canicas).

## Qué hay

- `esclusa-app.bundle` — **lo que se versiona** del repo de prueba: todas las ramas y tags en un archivo (git no versiona un repo dentro de otro), hecho el 24/10/2026. Los HEAD sueltos de los worktrees de `etapas/` van como `refs/etapas/<nombre>`. Se restaura con `git clone esclusa-app.bundle esclusa-app && cd esclusa-app && for b in $(git branch -r | grep -v HEAD | sed 's|origin/||'); do git branch -q "$b" "origin/$b" 2>/dev/null; done`.
- `esclusa-app/` — el repo de prueba: etiquetas `fase-00` … `fase-11` y `pre-modernizacion`, ramas `f03` … `f11`,
  `incidente/01` … `incidente/20` (sin 08 ni 21, que no tiene rama), y el historial anterior en `previo-revision/*` y `previo-t1/historial-previo`; la pieza forense del `useMemo` en
  `previo-t6/incidente-19-usememo`. La historia se reescribió tres veces en T6 (`t6-r22.sh`, `t6-oddsaudit-vacio.sh`,
  `t6-ignored-action.sh`).
- `etapas/` — cuatro `git worktree` descartables: `puente-rx7`, `puente-r17`, `puente-r18` (el puente de F11 y A8) y
  `a13` (el build medido de A13).
- `trabajo/` — plantillas de F06, F07, A7 y A11; `inc13-17.md` (el texto de los cinco incidentes antes de empalmarlo);
  pruebas de F04–F07, de A7 y A11; `incidentes/` (03–17, con `inc13.colateral` e `inc14.pantalla`); `publicados-13-17/`
  (las pruebas de regresión tal como se publican); `render_fase.py`, `comparar-bloques.py`, `correr-pruebas.sh` y
  `correr-incidentes.sh`.
- `salidas/` — logs y resultados (ver README §8). No se versiona; se limpió el 25/10/2026 y se regenera corriendo
  las pruebas, salvo los ids de las reescrituras de T6 y el inventario inicial de Docker, que se perdieron.
- `verificacion-a-mano-T4.md`, `-T5.md` y `-T6.md` — lo que el autor verifica con navegador.

## Qué sirvió

- `06-redux-observable-a-fondo.md` y `07-cierre-polling-compras.md`, rendidos desde `trabajo/F0N-plantilla.md` con el
  código de su etiqueta.
- Los incidentes 13–17 de `cuaderno-incidentes.md` (de `trabajo/inc13-17.md`), con las pruebas de `publicados-13-17/`.
- `A7-redux-observable-epica-por-epica.md` y `A11-marble-testing.md`, rendidos desde sus plantillas con los epics de F07
  y las pruebas de `trabajo/A7.marbles.test.js` y `trabajo/A11.marbles.test.js`.
- Las recetas 13–17 y los datos §4.4–§4.5 de `prompts/preparaciones-de-incidentes.md`, y el §2.10 del diccionario.
- T5: `08-conciliacion.md`, `A10-aritmetica-de-dinero.md` y `A14-estadistica-para-auditar-una-rueda.md`, rendidos
  desde `trabajo/F08-plantilla.md`, `A10-plantilla.md` y `A14-plantilla.md`; el incidente 18 (de `trabajo/inc18.md`,
  con la prueba de `publicados-18/`); la receta 18 y §4.6 de las preparaciones; el §2.11 del diccionario; la comisión
  de Google Play en la historia §8.
- T6: `09-dashboard.md`, `10-testing-minimo.md` y `11-cierre-puente-react-moderno.md`, rendidos desde
  `trabajo/F09-plantilla.md`, `F10-plantilla.md` y `F11-plantilla.md`; los incidentes 19–21 (de `trabajo/inc19-21.md`,
  con `publicados-19/` y `publicados-21/`) y las secciones generales del cuaderno; A8, A12, A13 y A5 corregidos con lo
  medido en `trabajo/puente/` y `salidas/a13/`; las recetas 19–21 y §4.7–§4.8 de las preparaciones, el §2.12 del
  diccionario.
