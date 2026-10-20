# 🧪 react-16-legacy-for-backend-devs-20261015-f769 · cómo correr estas pruebas

> **Curso:** react-16-legacy-for-backend-devs · **Tandas:** T4 (F06, F07, incidentes 13–17, A7, A11) y T5 (F08, A10, A14, incidente 18) · **Creado:** 2026-10-15
> **Propósito:** el repo de prueba vigente (`esclusa-app/`), clonado de `…-20261014-d0dc` con todas sus ramas y etiquetas,
> más F06 y F07 escritas siguiendo los documentos, las ramas de incidente 13–17, y las pruebas de canicas de A7 y A11.
> Las reglas, en `zz-code/README.md` § "El README de cada directorio". Si una sección no aplica, se dice por qué.

## 1. 🎯 Qué se prueba y para qué

| Prueba | Documento | Qué alimenta |
|---|---|---|
| `esclusa-app` en `fase-06-redux-observable-a-fondo` y `fase-07-cierre-polling-compras` | F06, F07 | que cada bloque publicado sea el archivo que corrió y que cada fase compile y pase sus pruebas |
| `trabajo/F06.marbles.test.js` (12), `trabajo/F06.integracion.test.js` (4) | F06 | cada épica con canicas; la integración contra el mock, incluido el leak del refresco de compras (§5.8) |
| `trabajo/F07.marbles.test.js` (10), `trabajo/F07.integracion.test.js` (3) | F07 | cierre a hora exacta, guarda del envío, polling; integración contra el `3001` y el `3002` |
| `trabajo/incidentes/inc13…inc17.test.js` | cuaderno 13–17 | cada bug falla en su rama y pasa en su fase (TestScheduler crudo; el 16 con `TZ=America/Panama`) |
| `trabajo/incidentes/inc13.colateral.test.js` | cuaderno 13 | que en la rama del 13 la búsqueda también muere (`combineEpics`) |
| `trabajo/incidentes/inc14.pantalla.test.jsx` | cuaderno 14, preparaciones | el 14 de punta a punta con `PurchasesPage` montada detrás de su ruta protegida: rojo en la rama, verde en la fase y verde con solo el parche del epic |
| `trabajo/publicados-13-17/` | cuaderno 13–17 | las pruebas de regresión **tal como se publican** (rutas e imports relativos reales), corridas en su ruta dentro del repo |
| `trabajo/A7.marbles.test.js` (11), `trabajo/A11.marbles.test.js` (9) | A7, A11 | cada ejemplo de prueba de los apéndices, contra los epics de F07 |
| `esclusa-app` en `fase-08-conciliacion` | F08 | que cada bloque publicado sea el archivo que corrió, que compile y pase sus pruebas |
| `trabajo/F08.test.js` (13), `F08.integracion.test.js` (1), `F08.render.test.jsx` (1) | F08 | money, prorrateo, comisión, cruce de compras, `oddsAudit` sobre la bitácora sembrada, la transición; contra los dos mocks; la pantalla entera |
| `trabajo/incidentes/inc18.test.js`, `trabajo/publicados-18/` | cuaderno 18 | el centavo de más en la rama (2.100 contra 2.099) y su prueba tal como se publica |
| `trabajo/A10.test.js` (6), `trabajo/A14.test.js` (5) | A10, A14 | cada número de los apéndices, contra el código de F08 |
| `trabajo/t5/false-alarms.js` (y `variante.js`) | A14 §5 y ejercicios 4 y 6 | la tasa de falsas alarmas de una rueda honesta, con 100.000 simulaciones |
| `trabajo/t5/centavo.js`, `centavo-sembrado.js`, `comision.js`, `comision2.js`, `explorar*.test.js` | F08, incidente 18 | las exploraciones previas: dónde aparece el centavo, la comisión con floats, la ley de grandes números y la potencia |

## 2. 🛠️ Prerrequisitos

- Docker con `node:14.21.3` (npm 6.14.18). Nada se instala en la máquina.
- El repo `esclusa-app/` tal como está: etiquetas `fase-00` … `fase-05` (las de d0dc), `fase-06-redux-observable-a-fondo`
  (`a87e1ae`) y `fase-07-cierre-polling-compras` (`f0a1268`); ramas `f06`, `f07` e `incidente/13` … `incidente/17`.
  La rama `incidente/14` tiene dos commits (el `takeUntil` sin logout y `PurchasesPage` sin su limpieza al desmontarse).
  T5 suma `fase-08-conciliacion` (`66a4b95`, sobre el commit `d6e6905` de la rama `f08`) e `incidente/18` (`820cabf`).
- rxjs-marbles **no** está en el `package.json` de F06 ni de F07 (lo instala la F10): las pruebas de canicas lo instalan
  sin guardar con `PRE="npm install --no-save rxjs-marbles@6.0.1"`. Las de incidentes usan el `TestScheduler` de
  `rxjs/testing` y no lo necesitan.

## 3. 🧭 Reglas antes de correr

```bash
mkdir -p salidas
```

- El inventario de Docker del inicio está en `salidas/inventario-inicial-docker.txt`. Había contenedores de otros cursos
  (angular-16, vue2): no se tocan.
- Los contenedores llevan `--label curso=react16` y ninguno publica puertos en el host: el mock del `3001`, el del `3002`
  y Jest comparten red con `--network container:<id>`.
- `trabajo/correr-pruebas.sh` copia `mock/db.json` a `mock/db.json.antes` y lo devuelve al terminar. Antes de cambiar de
  rama, `git status` limpio.

## 4. ▶️ Cómo se corre

Desde este directorio:

```bash
# F06: canicas e integración (el mock del 3001 al lado)
(cd esclusa-app && git checkout -q fase-06-redux-observable-a-fondo)
PRE="npm install --no-save rxjs-marbles@6.0.1" sh trabajo/correr-pruebas.sh "$PWD/esclusa-app" F06.marbles.test.js F06.integracion.test.js

# F07: canicas de F06 y F07, integración (los dos mocks); la prueba del leak de F06 falla aquí a propósito
(cd esclusa-app && git checkout -q fase-07-cierre-polling-compras)
PRE="npm install --no-save rxjs-marbles@6.0.1" sh trabajo/correr-pruebas.sh "$PWD/esclusa-app" F06.marbles.test.js F07.marbles.test.js
sh trabajo/correr-pruebas.sh "$PWD/esclusa-app" F06.integracion.test.js F07.integracion.test.js

# incidentes 03–17, cada uno en su rama (rojo) y en su fase (verde)
sh trabajo/correr-incidentes.sh "$PWD/esclusa-app"

# el 14 con la pantalla montada (la compra tiene que seguir pendiente)
(cd esclusa-app && git checkout -q incidente/14)
PLAY_PENDING_MS=600000 sh trabajo/correr-pruebas.sh "$PWD/esclusa-app" inc14.pantalla.test.jsx

# F08: unitarias y apéndices juntos; la integración y el render, cada una en su corrida
# (las dos concilian la rueda 4 contra el mismo mock: juntas, la segunda recibe el 409)
(cd esclusa-app && git checkout -q fase-08-conciliacion)
sh trabajo/correr-pruebas.sh "$PWD/esclusa-app" F08.test.js A10.test.js A14.test.js
sh trabajo/correr-pruebas.sh "$PWD/esclusa-app" F08.integracion.test.js
sh trabajo/correr-pruebas.sh "$PWD/esclusa-app" F08.render.test.jsx

# las cifras de A14 (100.000 simulaciones, unos 30 s)
docker run --rm --label curso=react16 -v "$PWD/trabajo/t5":/t node:14.21.3 node /t/false-alarms.js 100000

# A7 y A11, contra F07
(cd esclusa-app && git checkout -q fase-07-cierre-polling-compras)
PRE="npm install --no-save rxjs-marbles@6.0.1" sh trabajo/correr-pruebas.sh "$PWD/esclusa-app" A7.marbles.test.js A11.marbles.test.js

# T6 · F09: unitarias y render del tablero (los dos mocks al lado)
(cd esclusa-app && git checkout -q fase-09-dashboard)
sh trabajo/correr-pruebas.sh "$PWD/esclusa-app" F09.test.js
sh trabajo/correr-pruebas.sh "$PWD/esclusa-app" F09.render.test.jsx

# T6 · incidentes 03–20 (el 20 con su columna de zona horaria); el 19 aparte, con la Semana del Canal sembrada
sh trabajo/correr-incidentes.sh "$PWD/esclusa-app"
(cd esclusa-app && git checkout -q incidente/19 && docker run --rm --label curso=react16 -v "$PWD":/app -w /app node:14.21.3 node mock/seed-reconciliation.js --event)
sh trabajo/correr-pruebas.sh "$PWD/esclusa-app" inc19.test.js
(cd esclusa-app && git checkout -q -- mock/db.json mock/googlePlay/earnings.json)

# T6 · el 21: el script que publica el cuaderno, sobre la siembra honesta y sobre la acomodada (rueda 4)
(cd esclusa-app && git checkout -q fase-09-dashboard)
cp trabajo/publicados-21/scripts/repeated-landings.js esclusa-app/scripts/
docker run --rm --label curso=react16 -v "$PWD/esclusa-app":/app -w /app node:14.21.3 sh -c \
  'node mock/seed-reconciliation.js && node scripts/repeated-landings.js 4 avatar-comun &&
   node mock/seed-reconciliation.js --accommodating && node scripts/repeated-landings.js 4 avatar-comun'
mv esclusa-app/scripts/repeated-landings.js "$TMPDIR"   # se aparta; no es parte de la etiqueta
(cd esclusa-app && git checkout -q -- mock/db.json mock/googlePlay/earnings.json)

# T6 · F10/F11: la suite del repo (25 pruebas) en dos zonas, la prueba aleatoria 50 veces y el smoke de Cypress
(cd esclusa-app && git checkout -q fase-11-cierre-puente-react-moderno)
docker run --rm --label curso=react16 -v "$PWD/esclusa-app":/app -w /app -e CI=true -e TZ=UTC node:14.21.3 npx react-scripts test --watchAll=false
docker run --rm --label curso=react16 -v "$PWD/esclusa-app":/app -v "$PWD/trabajo":/t -w /app node:14.21.3 sh /t/t6-50-veces.sh /app
sh trabajo/t6-smoke.sh "$PWD/esclusa-app"

# T6 · el puente: las mismas 10 pruebas en el repo y en cada copia descartable de etapas/
sh trabajo/t6-puente.sh "$PWD/esclusa-app"
sh trabajo/t6-puente.sh "$PWD/esclusa-app" DISABLE_NEW_JSX_TRANSFORM=true   # el JSX clásico: la de jsx.test.jsx falla
sh trabajo/t6-puente.sh "$PWD/etapas/puente-rx7"
sh trabajo/t6-puente.sh "$PWD/etapas/puente-r17"
sh trabajo/t6-puente.sh "$PWD/etapas/puente-r18"

# T6 · A13: build, serve con y sin -s, y una línea del bundle resuelta con el source map (en etapas/a13)
docker run --rm --label curso=react16 -v "$PWD/etapas/a13":/app -v "$PWD/trabajo":/t -w /app node:14.21.3 \
  sh -c 'npm run build >/dev/null && node /t/t6-a13-mapa.js build/static/js/main.*.chunk.js "La rueda ya cerr"'   # sin tilde: Terser escribe \xf3
```

Ojo con `t6-puente.sh`: la variable va como argumento aparte (`… "$PWD/esclusa-app" VAR=valor`); escrita pegada a la
ruta, el script crea un directorio con ese nombre. Los tres scripts `t6-r22.sh`, `t6-oddsaudit-vacio.sh` y
`t6-ignored-action.sh` **no se vuelven a correr**: reescribieron la historia del repo una vez (con `filter-branch`) y
quedaron como registro de qué cambió; los ids de antes y después están en `salidas/r22-ids.txt` y
`salidas/t6-ids-tras-oddsaudit.txt`.

Variables de `correr-pruebas.sh`: `CHAOS_LEVEL` (el `3001`), `PLAY_CHAOS_LEVEL` (el `3002`), `CHAOS_SEED`,
`PLAY_PENDING_MS` (3000 por defecto), `TZ_PRUEBA` (UTC por defecto) y `PRE`. Deja los logs de los mocks en
`salidas/mock-ultima-corrida.log` y `salidas/mock-3002-ultima-corrida.log`. `correr-incidentes.sh` lee una lista de
número, prueba, etiqueta, caos y zona horaria.

Las pruebas publicadas del cuaderno (`trabajo/publicados-13-17/`) usan imports relativos a su ruta real, así que no
pasan por `src/__pruebas__/`: se copian a su ruta dentro del repo, se corren con `npx react-scripts test <ruta>` en
`node:14.21.3` y se apartan después (con `mv`, no con `rm`).

Los documentos se rinden desde sus plantillas con el código de la etiqueta: `render_fase.py` (F06, F07, A7, A11;
marcadores `<<<archivo:…>>>` y `<<<fragmento:ruta|inicio|fin>>>`, el fin no puede llevar `>`). A7 y A11 se rinden con
la raíz en este directorio, para poder citar `esclusa-app/src/…` y `trabajo/A7.marbles.test.js` a la vez.
`comparar-bloques.py` confirma que cada archivo de la fase es un bloque del documento.

## 5. 📏 Cómo se mide

**T5.** La bitácora de F08 la genera `mock/seed-reconciliation.js` con la semilla 42 (10.000 giros); las alarmas de
`oddsAudit` sobre 300 semillas (1001–1300) salen de `trabajo/t5/explorar.test.js`, y la tasa de falsas alarmas de A14,
de 100.000 bitácoras simuladas con la semilla 20261016 en `trabajo/t5/false-alarms.js` (32 s en `node:14.21.3`). La
comisión de Google Play (15 %) se verificó en su página de ayuda el 16/10/2026.

No hay mediciones de rendimiento en T4. Lo que se cuenta son peticiones: el contador `sessionlessCounter` de cada mock
escribe `[3001] sin sesión #N` o `[3002] sin sesión #N` por cada petición sin `Authorization`, y esa línea es la
evidencia del leak de F06 y del incidente 14.

**T6.** El costo de los chequeos de desarrollo (incidente 19) sale de `inc19.test.js` con la Semana del Canal (180.000
giros): el tiempo por acción con y sin `ignoredPaths` (`salidas/t6-chequeos-con.log`, `-sin.log`). El `useMemo` roto
se midió con `performance.now()` alrededor del cambio de filtro, en la rama `previo-t6/incidente-19-usememo`. Las
cifras del puente (renders por `setTimeout`, efectos bajo StrictMode) las cuentan las propias pruebas de
`trabajo/puente/`. El build de A13 se midió con `ls -l` sobre `build/static/js/`.

## 6. 🧮 Los intermedios que amasan la salida

- Los conteos de "sin sesión" son `grep -c "sin sesión"` sobre el log del mock de la corrida. El `#1` del `3002` es
  siempre el `POST /purchases` que crea la compra de la prueba, que no lleva sesión.
- La tabla de horas del incidente 16 sale de un script de `node` corrido con `TZ=America/Panama`, `America/Santiago` y
  `UTC` (`getHours()` del cierre y del instante, y el resultado de la comparación con el bug).

## 7. ✅ Qué se espera ver

- F06: canicas 12/12 (`salidas/f06-marbles-2.log`), integración 4/4 (`salidas/f06-integracion-1.log`), build compila.
- F07: canicas de F06 y F07 22/22 (`salidas/f07-marbles-4.log`); integración 6/7, y la que falla es la del leak de F06,
  que la F07 paga (`salidas/f07-integracion-1.log`); build compila.
- Incidentes 03–17: `1 failed` en la rama y `1 passed` en la fase (`salidas/incidentes-03-17.log`), con la misma
  salvedad de d0dc: en el lote, la línea del 05 en su rama sale vacía; corrido aparte da `1 failed`.
- Incidente 14 con pantalla: rama `1 failed` con 3 consultas sin sesión después del logout (4 en el log, contando el
  `POST`); fase `1 passed` con solo el `POST` (`salidas/inc14-pantalla-*.log`). Con el `takeUntil` corregido y la
  pantalla todavía sin limpieza, también pasa.
- Pruebas publicadas 13–17: las cinco fallan en su rama y pasan en su fase.
- F08: unitarias, A10 y A14 24/24 (`salidas/t5-F08.test.js.log`), integración 1/1, render 1/1; build compila
  (`salidas/f08-build.log`). La regresión de F04–F07 sobre F08 da 67/73: las 6 que fallan son de F05 y prueban
  `queueGrant`, que F06 retira (`salidas/f08-regresion.log`).
- Incidente 18: `1 failed` en la rama (2.100 contra 2.099) y `1 passed` en la fase (`salidas/incidentes-03-18.log`).
- A14: banda 1,99 %, chi-cuadrado 5,04 %, cualquiera 5,54 % (`salidas/a14-falsas-alarmas.log`); con α = 0,01, 1,02 %;
  con 200 giros, banda 3,99 % y chi-cuadrado 5,40 % (`salidas/a14-variantes.log`).
- A7 y A11: 20/20 (`salidas/a7-a11-marbles.log`). En `incidente/14` y `incidente/17` cae exactamente la prueba de A7
  de su operador; en las ramas 13 y 15 (de F06) la suite no carga, porque `pollingEpic` todavía no existe.

- F09: unitarias y render en verde (`salidas/f09-pruebas-2.log`), build compila (`salidas/f09-build.log`).
- Incidentes 03–20: rojo en la rama y verde en la fase (`salidas/incidentes-03-20.log`, 32 líneas); el 20 pasa en
  Bogotá y falla en UTC (`salidas/inc20.log`, `inc20-utc-detalle.log`). El 19: 213 ms por acción con los chequeos y
  0,1 ms sin ellos.
- El 21: `substitute` deja 448 jugadores con el avatar común repetido; `accommodating`, 0 (`salidas/inc21-evidencia.log`);
  el tablero con la regla vieja marca seis filas y χ² = 808,35 (`salidas/inc21-tablero.log`).
- F10/F11: 25/25 en UTC y en `America/Bogota` (`salidas/f10-suite-*.log`, `t6-suite-final.log`); la aleatoria 50 de 50
  (`salidas/f10-50-veces.log`); el smoke, *All specs passed!* (`salidas/t6-smoke-final.log`); la línea base de
  `WheelTable` antes del refactor (`salidas/f11-linea-base.log`).
- Puente: 10/10 en el repo, en `puente-rx7`, `puente-r17` y `puente-r18` (`salidas/puente-final.log`); con
  `DISABLE_NEW_JSX_TRANSFORM=true`, la prueba del JSX sin `import React` da *"React is not defined"*.
- A13: `main.2be97eaf.chunk.js` de 47.928 bytes, `serve -s` 200 y sin `-s` 404, la posición `1:12330` resuelta a
  `closedWheelGuard.js:24:24` (`salidas/a13/`).

## 8. 📂 Salidas

| Archivo | Qué es |
|---|---|
| `salidas/f06-*.log`, `salidas/f07-*.log` | builds, canicas e integración de cada fase (los números bajos son corridas de depuración) |
| `salidas/f06-mock-leak.log`, `salidas/f07-mock-3002.log` | logs de los mocks con el contador sin sesión |
| `salidas/incidentes-13-17.log`, `salidas/incidentes-03-17.log` | las regresiones de los incidentes |
| `salidas/inc14-3002-*.log`, `salidas/inc14-pantalla-*.log` | el 14 de punta a punta, por la integración y por la pantalla |
| `salidas/a7-a11-marbles.log` | las pruebas de los apéndices |
| `salidas/f08-*.log`, `salidas/t5-*.log` | siembra, pruebas, render, regresión y build de F08 |
| `salidas/inc18-centavo.log`, `salidas/f08-comision.log` | el centavo de los cuatro paquetes y la comisión con floats |
| `salidas/a10.log`, `salidas/a14*.log` | los apéndices de T5 y la simulación de falsas alarmas |
| `salidas/incidentes-03-18.log` | las regresiones de los incidentes, con el 18 |
| `salidas/f09-*.log`, `salidas/t6-chequeos-*.log` | pruebas, build y el costo de los chequeos de F09 |
| `salidas/incidentes-03-20.log`, `salidas/inc20*.log`, `salidas/inc21-*.log` | las regresiones con el 19 y el 20, y la evidencia del 21 |
| `salidas/f10-*.log`, `salidas/f11-*.log`, `salidas/t6-suite-final.log`, `salidas/t6-smoke-final.log` | la suite, las 50 corridas, el smoke y la línea base |
| `salidas/puente-*.log`, `salidas/puente-apartado-*` | las corridas del puente y las pruebas que se apartaron de cada copia |
| `salidas/a13/` | los dos bundles comparados, el `serve` y la resolución con el source map |
| `salidas/r22-*`, `salidas/t6-*-filter.log`, `salidas/t6-ids-tras-oddsaudit.txt` | las tres reescrituras de historia y sus ids |
| `salidas/inventario-inicial-docker.txt` | el inventario de Docker antes de empezar |

## 9. 🧹 Limpieza

```bash
# contenedores de las corridas (solo los de este curso)
docker ps -a --filter label=curso=react16 -q | xargs -r docker rm -f -v
```

Las cuatro copias de `etapas/` son `git worktree` del repo de prueba, con su `node_modules` cada una (unos 450 MB por
copia). Se quitan con `git worktree remove`, desde `esclusa-app/`, cuando ya no hagan falta:

```bash
(cd esclusa-app && git worktree remove --force ../etapas/puente-rx7)   # y lo mismo con puente-r17, puente-r18 y a13
```

No se borra nada del curso ni recursos de Docker ajenos al curso. Las pruebas publicadas que se apartaron al correrlas
quedaron en el scratchpad de la sesión, no aquí.

## 10. 🚫 Qué se dejó fuera

- `node_modules/` de `esclusa-app`: se regenera con `npm ci` en `node:14.21.3`. Lleva rxjs-marbles 6.0.1 instalado sin
  guardar por las corridas de canicas.
- La imagen de Docker: `docker pull node:14.21.3`.
- La verificación a mano de T4, T5 y T6: `verificacion-a-mano-T4.md`, `-T5.md` y `-T6.md`, que necesitan navegador y
  DevTools.
- Las versiones del puente no se guardan en ningún `package.json` de las etiquetas: viven solo en las copias de
  `etapas/`.
