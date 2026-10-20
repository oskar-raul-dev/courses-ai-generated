# 🧪 react-16-legacy-for-backend-devs-20261014-d0dc · cómo correr estas pruebas

> **Curso:** react-16-legacy-for-backend-devs · **Tanda:** T3 y la revisión de continuidad P1–T3 · **Creado:** 2026-10-14
> **Propósito:** el repo de prueba vigente (`esclusa-app/`), con la historia rehecha de F00 a F05, las ramas de
> incidente 01–12, las pruebas de cada fase y de cada incidente, la medición del tablero de F05 y los ejemplos de A5 y A6.
> Las reglas, en `zz-code/README.md` § "El README de cada directorio". Si una sección no aplica, se dice por qué.

## 1. 🎯 Qué se prueba y para qué

| Prueba | Documento | Qué alimenta |
|---|---|---|
| `esclusa-app` en `fase-00` … `fase-05`, rehechas siguiendo los documentos | F00–F05 | que cada bloque publicado sea el archivo que corrió (comparadores) y que cada fase compile y pase sus pruebas |
| `WheelCard.render.test.js`, `AppRouter.routes.test.js`, `F02.auth.test.js` (de T1, en `../…-3d3c/trabajo/`) | F00, F01, F02 | render, rutas y autenticación contra `json-server` |
| `F03.pagos.test.js` (de T2, en `../…-a728/trabajo/`) | F03 | pagos de deuda #1 y #2, y el mensaje de los 5xx |
| `trabajo/F04.test.js`, `trabajo/F04.render.test.jsx` | F04 | reglas de pesos, error legible, rutas del mock (201/422/409/404), slice contra el mock, los cuatro estados de la tabla y el formulario |
| `trabajo/F05.test.js`, `trabajo/F05.render.test.jsx` | F05 | máquina de estados, ventana de deshacer con tiempos reales, optimista, guarda de origen, rollback, ruta de envíos del mock y su chequeo no atómico |
| `trabajo/incidentes/inc03…inc12` (+ `inc11.mock.test.js`) | cuaderno 03–12 | cada bug falla en su rama y pasa en su fase; el 11, de punta a punta contra el mock |
| `trabajo/cypress-bench/` | F05 §5.7 | render del tablero de 10.000 filas, sin y con `React.memo` |
| `trabajo/apendices*.test.*` con `trabajo/extraer-ejemplos-apendices.py` | A5 §7, A6 §6 y §11 | los ejemplos tal cual están en el `.md` |
| `trabajo/revision/identificadores.py`, `identificadores_es.py` | revisión P1–T3 | identificadores fuera del diccionario y en español en el código publicado |

## 2. 🛠️ Prerrequisitos

- Docker con `node:14.21.3` (npm 6.14.18) y `cypress/included:10.11.0`. Nada se instala en la máquina.
- El repo `esclusa-app/` tal como está: etiquetas `fase-00-setup-hola-mundo-cra` (`f02812c`), `fase-01-estructura-base-router-5` (`d8a13e8`),
  `fase-02-autenticacion-minima` (`6d9c8e2`), `fase-03-mock-api-express-caos` (`67c62fe`), `fase-04-ruedas-crud` (`3af333b`) y
  `fase-05-envios-manuales` (`28d319b`); ramas `master` (F02), `f03`, `f04`, `f05` e `incidente/01` … `incidente/12` (sin 08,
  que se prepara solo con caos). `git tag` y `git branch` dan los ids vigentes.
- El historial anterior se conserva: `previo-revision/*` (lo que había antes de la revisión) y `previo-t1/historial-previo` (las etapas de T1).
- `node_modules` del árbol de trabajo es el de F05. Para correr una fase anterior basta con hacer checkout de su etiqueta: las pruebas de F00–F02 corren con ese mismo `node_modules`.

## 3. 🧭 Reglas antes de correr

```bash
mkdir -p salidas
```

- Los contenedores llevan `--label curso=react16` y ninguno publica puertos en el host: Jest y Cypress llegan al mock y al servidor de desarrollo con `--network container:<id>`.
- `trabajo/correr-pruebas.sh` copia `mock/db.json` a `mock/db.json.antes` y lo devuelve al terminar: no pisa cambios sin commitear. Antes de cambiar de rama, `git status` limpio.

## 4. ▶️ Cómo se corre

Desde este directorio:

```bash
# pruebas de una fase (copia las pruebas a src/__pruebas__/, levanta el mock si la fase lo tiene)
(cd esclusa-app && git checkout -q fase-04-ruedas-crud)
sh trabajo/correr-pruebas.sh "$PWD/esclusa-app" F04.test.js F04.render.test.jsx
(cd esclusa-app && git checkout -q fase-05-envios-manuales)
sh trabajo/correr-pruebas.sh "$PWD/esclusa-app" F04.test.js F04.render.test.jsx F05.test.js F05.render.test.jsx inc11.mock.test.js

# cada incidente en su rama (rojo) y en su fase (verde); el 07 con CHAOS_LEVEL=high y semilla 7
sh trabajo/correr-incidentes.sh "$PWD/esclusa-app"

# la medición del tablero de F05 (servidor de desarrollo + Cypress en la misma red)
(cd esclusa-app && git checkout -q fase-05-envios-manuales)
sh trabajo/cypress-bench/correr-medicion.sh "$PWD/esclusa-app"

# el giro ingenuo de F03, seis corridas con la base restaurada antes de cada una
(cd esclusa-app && git checkout -q fase-03-mock-api-express-caos)
# por corrida: git checkout -- mock/db.json; mock:api en un contenedor; traffic y measure en otro (ver salidas/f03-tres-corridas.log)

# los ejemplos de los apéndices, extraídos del .md
python3 trabajo/extraer-ejemplos-apendices.py <raiz-del-curso> trabajo/apendices/ejemplos
```

Los documentos se rinden desde sus plantillas con el código de la etiqueta: `render_f03.py` (F03) y `render_fase.py`
(F04, F05; marcadores `<<<archivo:…>>>` y `<<<fragmento:ruta|inicio|fin>>>`). `comparar-bloques.py` confirma que cada
archivo de la fase es un bloque del documento ("todo idéntico: True"). F00–F02 se comparan con el comparador de T1
(`../…-3d3c/trabajo/comparar-bloques.py`).

## 5. 📏 Cómo se mide

**El tablero de F05.** `GrantBoard` con `?n=10000` y `?memo=0|1`; `useLayoutEffect` escribe en `window.__lastRender` los ms
desde el clic hasta el DOM listo. La especificación (`cypress-bench/e2e/board.cy.js`) hace cinco cambios por variante y
calcula la media (`meanMs`). Electron (Chromium) headless de `cypress/included:10.11.0`, contra `npm start` en `node:14.21.3`.
Corrida del 14/10/2026: sin memo 256, 247, 221, 222, 229 ms (media 235); con memo 68, 54, 56, 51, 59 ms (media 58).

**El giro ingenuo de F03.** 50 usuarios virtuales, 1.500 claves enviadas dos veces, `STEP_DELAY_MS=2`. Seis corridas del
14/10/2026: 1.014, 1.031, 1.047, 1.000, 1.034 y 1.029 premios; claves con dos premios entre 500 y 523; stock excedido entre 0 y 47.

## 6. 🧮 Los intermedios que amasan la salida

- La media del tablero la calcula la especificación de Cypress (`meanMs`, redondeo a entero); no hay paso aparte.
- Las cifras del giro son las líneas JSON de `measure` (`prizesLogged`, `keysWithTwoPrizes`, `stockRemaining`, `stockExceeded`), tal cual.
- La historia del repo se rehízo así: F00–F02 desde los documentos (`etapas/f00b`, worktree huérfano), F03 aplicando el
  cambio corregido sobre F02 y repitiendo sus `npm install`, F04 y F05 escritas de nuevo; después, `git filter-branch`
  con `trabajo/esclusa-de-oro-avatar.py` cambió el `prizeType` del segmento `esclusa-de-oro` a `avatar` en todas las
  etiquetas y ramas (historia §3: es un avatar).

## 7. ✅ Qué se espera ver

- F00 1/1, F01 5/5, F02 5/5, F03 5/5 (con el mock), F04 23/23, F05 35/35 (incluye las 23 de F04 y la del 11 contra el mock).
- Incidentes 03–12: `1 failed` en la rama y `1 passed` en la fase (`salidas/incidentes-03-12-final.log`). En la corrida
  por lotes, la línea del 05 en su rama sale vacía; corrido aparte da `1 failed` (`salidas/inc05-rama.log`). No se
  encontró la causa.
- Los ejemplos de A5 y A6: 3/3 (`salidas/apendices-a5-a6.log`).
- Medición y giro: las cifras de la sección 5.

## 8. 📂 Salidas

| Archivo | Qué es |
|---|---|
| `salidas/render-memo0.json`, `render-memo1.json` | la medición del tablero (copia de `cypress-bench/resultados/`) |
| `salidas/f03-tres-corridas.log` | las seis corridas del giro ingenuo |
| `salidas/incidentes-03-12*.log`, `salidas/inc05-rama.log` | las regresiones de los incidentes |
| `salidas/f04-pruebas-*.log`, `salidas/f05-pruebas-1.log` | las suites de F04 y F05 |
| `salidas/r16-*`, `salidas/r17-*`, `salidas/r4-*`, `salidas/r5-*` | instalaciones, builds y pruebas de cada etapa rehecha |
| `salidas/apendices-a5-a6.log` | los ejemplos de los apéndices |

## 9. 🧹 Limpieza

```bash
# contenedores de las corridas (solo los de este curso)
docker ps -a --filter label=curso=react16 -q | xargs -r docker rm -f -v
# los dos worktrees de la reconstrucción (etapas/), cuando ya no hagan falta
git -C esclusa-app worktree remove --force ../etapas/f00
git -C esclusa-app worktree remove --force ../etapas/f00b
```

`etapas/snap01/` es una extracción de la etapa F01 de T1, solo de consulta. No se borra nada del curso ni recursos de
Docker ajenos al curso. La imagen `curlimages/curl:8.10.1`, que se bajó una vez por error, ya se borró.

## 10. 🚫 Qué se dejó fuera

- `node_modules/` de `esclusa-app` y de `etapas/f00b`: se regeneran con `npm ci` en `node:14.21.3`.
- Las imágenes de Docker: `docker pull node:14.21.3` y `docker pull cypress/included:10.11.0`.
- Los vídeos y capturas de Cypress (desactivados en `cypress.config.js`).
- La verificación a mano de T1–T3: `verificacion-a-mano-T1-T3.md`, que necesita navegador y DevTools.
- `trabajo/previo-revision/`: las plantillas, pruebas y listas de T3 antes de la revisión, como registro.
