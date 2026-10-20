# 🧪 Fase 10 — Testing mínimo

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · Fase 10 de 11 · **6 horas**
> Depende de: Fase 9 — Dashboard · Habilita: Fase 11 — Cierre + puente a React moderno

---

## 🎯 1. Propósito

Faltan unas semanas para la próxima Semana del Canal, y Juliana pone la regla que va a ordenar todo lo que sigue: *"nada se toca sin red"* (`00-historia-del-sistema.md` §3, hoy). La última Semana del Canal entregó 1.047 Esclusas de Oro de un stock de 1.000, compensó a jugadores dos veces y dejó una reseña que todavía duele. Esta vez, antes de cambiar una línea, tiene que existir algo que diga si el cambio rompió lo que andaba.

Esta fase convierte cada pieza forense que vienes acumulando desde la Fase 4 en una **prueba automatizada que falla con el bug y pasa con el fix**. No es un curso de testing: es el mínimo que un equipo de mantenimiento necesita para tocar código legacy sin romperlo. Una función pura, un reducer, un selector, un componente de función y uno de clase, dos epics con su tiempo fijado por canicas, un smoke de punta a punta, y una cosa que casi ningún curso enseña y esta consola necesita: **probar código que usa azar sin que la prueba sea intermitente**.

La pregunta de la fase deja de ser "¿cómo reproduzco el bug a mano?" y pasa a ser "¿cómo escribo la prueba que lo atrapa para siempre?".

---

## ✅ 2. Qué queda listo al terminar

- [ ] Las pruebas viven **en el repo**, al lado del código que prueban, y la suite entera corre con `CI=true npm test`: **25 pruebas en verde**, en UTC y en la zona de Bogotá.
- [ ] Pruebas de función pura (`dashboardMath`) y de reducer (`grantSlice`), sin store, sin red, sin un mock.
- [ ] Pruebas de **memoria** de los selectores del tablero, por identidad referencial (`toBe`, no `toEqual`).
- [ ] Pruebas de componente con React Testing Library: uno de función (`MetricCard`, con el reloj congelado), el gráfico (`BandChart`, con chart.js simulado y su limpieza comprobada) y uno de **clase** (`WheelTable`).
- [ ] Pruebas de epics con `rxjs-marbles` 6.0.1: el corte del polling por el logout, el `500` que no lo mata y la búsqueda que cancela a la vieja.
- [ ] ➕ **Lo aleatorio sin intermitencia:** una prueba de `oddsAudit` con semilla (determinista) y otra con tolerancia calculada (una semilla distinta en cada corrida), que corrieron 50 veces seguidas sin fallar y que **sí** fallan con la rueda que se acomoda.
- [ ] Un smoke de Cypress 10.11.0 del camino feliz, **contra los mocks reales**.

---

## 🚫 3. Qué queda fuera por ahora

- **e2e exhaustivo** (flujos completos de varias pantallas, matriz de navegadores) → un solo camino feliz.
- **Cobertura formal y umbrales** → no es objetivo de mantenimiento mínimo; va como 🔥.
- **Accesibilidad, regresión visual, presupuestos de rendimiento** → fuera del curso.
- **Reescribir fases previas para "hacerlas probables"** → el código ya se diseñó para probarse (las dependencias de los epics de la Fase 6, el reloj de la Fase 7, las funciones puras de la Fase 8). No se refactoriza nada acá.
- **La metodología de las canicas** → `A11-marble-testing.md`. Acá se aplica sobre los epics del proyecto.
- **MSW (Mock Service Worker)** → tentador para interceptar la red en las pruebas de componente, pero no está en el stack fijado; va como 🔥.

---

## 🧠 4. Conceptos mínimos

Eres senior: sabes qué es una prueba unitaria y por qué una prueba que depende del reloj de pared va a fallar un martes cualquiera. Lo que importa acá es **qué se prueba en un stack Redux Toolkit + redux-observable, y con qué herramienta**, porque cada capa se prueba distinto y mezclarlas es el error más común.

**La pirámide de esta consola, de abajo hacia arriba.** Las **funciones puras** (`dashboardMath`, `money.js`, `oddsAudit`) son la base: entra un valor, sale un valor, cero mocks, cero timers. Un escalón arriba, los **reducers** son funciones puras disfrazadas: `(state, action) => nextState`, y se prueban así, sin store y sin `Provider`. Los **selectores** memoizados agregan una dimensión: no alcanza con verificar *qué* devuelven, hay que verificar que **memoizan**, y eso se prueba por identidad (`toBe`). Los **componentes** se prueban preguntándole a la pantalla lo que vería un operador (texto, roles, `data-testid`), nunca su estado interno. Y en la cima, los **epics**, que son streams en el tiempo y necesitan una herramienta que controle el tiempo.

**Por qué los epics necesitan canicas y no `setTimeout`.** Un epic con `debounceTime(300)` probado con un `setTimeout` de verdad espera 300 ms reales por prueba y es **intermitente**: a veces el timer de la prueba corre antes que el del epic. El polling de la Fase 7 es peor: diez segundos sin consultas no se comprueban esperando diez segundos. La solución es un **reloj virtual**: el `TestScheduler` de RxJS avanza el tiempo en pasos que tú controlas, y `rxjs-marbles` (D9) es un envoltorio fino que te deja escribir el flujo como un diagrama. Todo eso está en A11.

**Qué trae CRA 4 y qué no.** `react-scripts` 4.0.3 ya configura **Jest 26** y **React Testing Library 11**, y `src/setupTests.js` ya importa los matchers de jest-dom. No instalas Jest ni escribes un `jest.config`. Lo único que sumas es `rxjs-marbles` para los epics y `cypress` para el smoke. Y una cosa que trae y conviene saber: CRA 4 corre Jest con **`resetMocks: true`**, que borra la implementación de cada `jest.fn()` antes de cada prueba. Por eso los dobles de esta fase son clases y funciones comunes, no `jest.fn().mockImplementation(...)`.

### Probar algo aleatorio sin que la prueba sea intermitente

`oddsAudit` decide sobre bitácoras que salen del azar. Probarla con giros "de verdad" aleatorios da una prueba que falla de vez en cuando aunque el código esté bien: una rueda honesta da alguna alarma en más o menos uno de cada dieciocho casos (A14 §5). Una prueba que falla uno de cada dieciocho días entrena al equipo a ignorar el rojo, que es peor que no tener prueba. Hay dos técnicas, y esta fase usa las dos:

- **La semilla.** Si el azar se puede sembrar, se siembra: el generador de la Fase 8 con la semilla 42 da siempre la misma bitácora, y la prueba es tan determinista como una suma. Es la técnica por defecto.
- **La tolerancia calculada.** Si el azar no se puede sembrar —o quieres probar con bitácoras distintas en cada corrida—, la aserción no es "da exactamente esto" sino "cae dentro de un margen que el azar casi nunca cruza". La estadística dice cuánto es "casi nunca": con ±5σ por segmento, una rueda honesta falla menos de una vez cada 200.000 corridas. Y la otra mitad del trabajo es comprobar que el margen **no es tan ancho que deje pasar el bug**: la misma prueba tiene que fallar con la rueda que se acomoda.

> 🧭 **La regla.** Una prueba de algo aleatorio que falla "a veces" no es una prueba intermitente: es una prueba con un margen mal calculado, o sin semilla. Las dos cosas se arreglan con números, no con un `retry`.

> **Nota de convivencia.** Igual que el código de la consola mezcla clases y hooks, las pruebas de esta fase prueban **los dos** con la misma herramienta: React Testing Library no distingue entre `WheelTable` (clase con `connect()`) y `MetricCard` (función), porque prueba la **salida**, no la implementación. Una prueba que no sabe si adentro hay una clase o un hook sobrevive a la migración de la Fase 11.

---

## 💻 5. Implementación y código comentado

Las pruebas van junto al código que prueban, que es la convención de CRA:

```text
src/
  test/renderWithStore.jsx                         (ayudante nuevo)
  features/
    dashboard/   dashboardMath.test.js · dashboardSelectors.test.js · MetricCard.test.jsx · BandChart.test.jsx
    grants/      grantSlice.test.js · epics/searchPlayerEpic.test.js
    purchases/   epics/pollingEpic.test.js
    reconciliation/ oddsAudit.test.js
    wheels/      WheelTable.test.jsx
cypress.config.js
cypress/e2e/smoke.cy.js
```

### 5.1 Configuración: lo que ya está y lo único que sumas

CRA 4 corre las pruebas con `react-scripts test` (en modo watch por defecto; `CI=true npm test` para una pasada). Lo único que se instala, fijado y como dependencia de desarrollo:

```bash
npm install --save-dev --save-exact rxjs-marbles@6.0.1 cypress@10.11.0
```

> ⚠️ **El `@6.0.1` no es opcional.** `rxjs-marbles` ata su major a la de RxJS: la **6.x es para RxJS 6**, la 7.x para RxJS 7. Un `npm install --save-dev rxjs-marbles` a secas trae la 7 contra tu RxJS 6.6.7, y las pruebas fallan con errores de scheduler que no mencionan la versión. Y Cypress 10.11.0 es el que fija D6 para Node 14, con el diseño `cypress/e2e/*.cy.js` de §5.9.

El ayudante que montan las pruebas de componente conectadas al store:

<<<archivo:src/test/renderWithStore.jsx>>>

### 5.2 Nivel 0 — Función pura: `dashboardMath`

<<<archivo:src/features/dashboard/dashboardMath.test.js>>>

El punto de entrada al testing: entra un arreglo, sale un objeto. La segunda prueba cubre el caso que más se olvida —sin giros— y la cuarta comprueba lo que la Fase 8 pide de cualquier dinero: entero.

### 5.3 Reducer: `grantSlice`

<<<archivo:src/features/grants/grantSlice.test.js>>>

Las cinco pruebas recorren la máquina de estados de la Fase 5 tal como quedó en la Fase 6: el camino feliz, el rollback, lo confirmado que no se revierte (el incidente 12), la transición no permitida y el logout. Ninguna toca la red: el reducer no la conoce.

### 5.4 Selectores: la memoria se prueba por identidad

<<<archivo:src/features/dashboard/dashboardSelectors.test.js>>>

La segunda prueba es la que enseña: dos bitácoras con el mismo contenido y distinta referencia dan resultados **iguales** (`toEqual`) y **distintos** (`not.toBe`). `createSelector` memoiza por referencia, no por valor; por eso los selectores de entrada devuelven ramas del store tal cual (Fase 9).

### 5.5 Componentes de función: `MetricCard` y `BandChart`

<<<archivo:src/features/dashboard/MetricCard.test.jsx>>>

La prueba congela el reloj de la máquina con `jest.useFakeTimers("modern")` y `jest.setSystemTime`, en un instante elegido a propósito: las 21:00 del 20 de diciembre en Panamá, que en UTC ya son las 02:00 del 21. La tarjeta no consulta el reloj ni la zona de la máquina, así que pasa en cualquiera. Si algún día alguien la cambia para que lo haga, esta prueba lo descubre, y es el incidente 20. El segundo instante, las 00:18, cuida otra cosa: con `hour12: false`, el Node 14 de Jest y Chromium escriben la medianoche como `24:18` (medido); `hourCycle: "h23"` la fija en `00:18`, y la prueba lo comprueba con el reloj congelado en ese mismo instante.

<<<archivo:src/features/dashboard/BandChart.test.jsx>>>

jsdom no pinta `canvas`, así que chart.js se reemplaza por un doble que **cuenta instancias vivas**. Eso permite probar lo que en la Fase 9 se dijo en prosa: al desmontar no queda ninguna, y un cambio de datos actualiza la instancia en vez de crear otra.

### 5.6 Componente de clase: `WheelTable`

<<<archivo:src/features/wheels/WheelTable.test.jsx>>>

`WheelTable` es una clase con `connect()` que pide las ruedas al montarse. React Testing Library la prueba **igual** que a una función —esa es la prueba viva de que se prueba la salida—, y el cliente HTTP se reemplaza por una respuesta que cada prueba elige. Las cuatro pruebas son los cuatro estados que la Fase 4 escribió: cargando, lista, vacía, error.

### 5.7 💻 PIEZA FORENSE — Epics con `rxjs-marbles` → **A11**

El corazón de la fase, y el único bloque que no cabe entero acá. Un epic es un stream en el tiempo, y probarlo con timers reales es lento, intermitente y —lo determinante— **incapaz de probar lo que más importa**, que no es qué emite sino qué *deja* de emitir después de un corte. La metodología completa está en **`A11-marble-testing.md`**: si no lo leíste, ve ahora y vuelve.

<<<archivo:src/features/purchases/epics/pollingEpic.test.js>>>

<<<archivo:src/features/grants/epics/searchPlayerEpic.test.js>>>

> 🧠 **La aserción más valiosa del curso vive en lo que *falta* del diagrama.** La primera prueba no verifica una emisión: verifica que **no hay ninguna** en los diez segundos que siguen al logout. Si alguien borra el logout del `takeUntil`, el diagrama deja de cuadrar y la prueba falla exactamente donde vive el leak (el incidente 14).

### 5.8 Lo aleatorio, sin intermitencia: `oddsAudit`

<<<archivo:src/features/reconciliation/oddsAudit.test.js>>>

Tres pruebas, una por idea de §4. La primera fija la semilla y compara contra el χ² exacto de la Fase 8. La segunda usa una semilla distinta en cada corrida (`Date.now()`) y aserta una tolerancia calculada, en enteros, con la misma forma que la banda de `oddsAudit`. La tercera es la que hace honesta a la segunda: con la regla vieja, la tolerancia **falla**.

¿Cuánto vale esa promesa de "casi nunca"? Se puede medir: la prueba corrió **50 veces seguidas** el 18/10/2026, cada una con su semilla, y dio 50 verdes y 0 rojos. Cincuenta corridas no prueban la cota de uno en 200.000 —para eso está la cuenta de A14—, pero sí descartan el error grosero de un margen mal calculado, que fallaría en las primeras.

### 5.9 Smoke con Cypress: el camino feliz, sin red falsa

<<<archivo:cypress.config.js>>>

<<<archivo:cypress/e2e/smoke.cy.js>>>

Esta vez el smoke va **contra los mocks reales**: la consola habla con el `3001` y el `3002` de verdad, con su interceptor y su `Authorization`, y el tablero muestra los números de la bitácora sembrada. Con los dos mocks y el servidor de desarrollo arriba (`npm run mock:all` y `npm start`):

```bash
npx cypress run --browser electron
```

Si prefieres no instalar el binario de Cypress en tu máquina, la imagen oficial lo trae, y es como corrió para escribir esta fase (con los tres procesos en la misma red de contenedores):

```bash
docker run --rm --network container:<el contenedor del mock> -v "$PWD":/e2e -w /e2e cypress/included:10.11.0 --browser electron
# Passing: 1 · Failing: 0 · All specs passed! (00:05)
```

### 5.10 La suite entera

```bash
CI=true npm test
# Test Suites: 9 passed, 9 total
# Tests:       25 passed, 25 total
```

Corrida el 18/10/2026 con `TZ=UTC` y con `TZ=America/Bogota`: 25 de 25 en las dos. Esa doble corrida es parte de la suite y no un detalle: una prueba que solo corre en una zona horaria no prueba nada sobre el tiempo.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Probar implementación en vez de comportamiento.** Síntoma: la prueba se rompe cada vez que refactorizas, aunque la consola funcione igual. Causa: aserciones sobre estado interno o nombres de métodos en lugar de lo que ve el operador. Fix mínimo: preguntar a la pantalla (`getByText`, `getByRole`, `getByTestId`). Es la diferencia entre una prueba que sobrevive a la Fase 11 y una que hay que reescribir.

**2. Una prueba de epic intermitente por usar timers reales.** Síntoma: la prueba del epic pasa nueve de cada diez veces. Causa: se probó con `setTimeout` o con `jest.useFakeTimers()` mal sincronizado en vez del `TestScheduler`. Fix: canicas; el reloj virtual elimina la carrera. El problema no es el epic: es la prueba.

**3. `toEqual` donde va `toBe` en la prueba de memoria.** Síntoma: la prueba del selector pasa y no prueba nada. Causa: `toEqual` compara valores, y dos recálculos dan el mismo valor aunque la memoria esté rota. Fix: `toBe`.

**4. Un doble que se vacía solo.** Síntoma: el mock de chart.js "deja de funcionar" y la prueba explota con `Cannot set property 'labels' of undefined`. Causa: el doble era `jest.fn().mockImplementation(...)` y CRA 4 corre con `resetMocks: true`, que borra la implementación antes de cada prueba. Fix: una clase o una función común en la fábrica de `jest.mock`. Y si la fábrica usa una variable de afuera, su nombre empieza con `mock`, o Jest se niega a cargarla.

**5. Lo aleatorio "a veces rojo".** Síntoma: una prueba de algo con azar falla uno de cada tantos días. Causa: sin semilla y sin margen calculado, o con un margen "a ojo". Fix: §5.8. Y nunca un `retry`: reintentar una prueba aleatoria hasta que pase es elegir el resultado.

### Pieza forense de esta fase — una prueba de epic que fija el tiempo

La pieza forense de esta fase es meta-forense: **convertir la reproducción manual de un bug de tiempo en una prueba que lo fija**. El flujo: (1) reproduces a mano el leak de la Fase 6 (consultas que siguen después del logout); (2) lo traduces a un diagrama donde el logout llega antes de que el polling termine; (3) escribes el esperado como "nada después del logout"; (4) confirmas que la prueba **falla con el bug** y **pasa con el fix**.

**🔧 Rompe a propósito y observa.** En `pollingEpic`, quita `logout.match(other)` del `takeUntil`. Corre la primera prueba de §5.7. Tiene que **fallar**: el esperado dice que no hay consultas después del logout, y el epic sigue preguntando cada dos segundos. Mira el diff que imprime `rxjs-marbles`: te muestra el frame exacto en que el stream real se aparta del esperado. Restaura el logout: verde. Ese diff es la forma más limpia de *ver* un memory leak de suscripción.

> 📓 De esta fase sale, sin estar en ella, el incidente **20** de `cuaderno-incidentes.md`: el único que no se reproduce en la aplicación sino en la suite, y que no termina en un parche sino en una decisión escrita. Se abre acá y se cierra en la Fase 11.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Corre `CI=true npm test` y confirma las 25 pruebas. **Criterio:** la misma salida con `TZ=UTC` delante.
2. Agrega a `dashboardMath.test.js` una prueba de `countManualSpins` con una lista vacía.
3. Escribe una prueba de `netRevenueCents` con un solo renglón del paquete de 500 giros. **Criterio:** 1.784 centavos (2.099 − 315).
4. Prueba que `formatCents(0)` devuelve `"US$0,00"`.
5. Prueba el reducer de `grantSlice` para `discardGrant` sobre un envío fallido: queda deshecho.
6. Prueba que `grantsReset` no toca un envío que ya estaba enviado.
7. Escribe una prueba de `WheelTable` con una sola rueda: exactamente dos filas (cabecera y rueda).
8. Prueba que `MetricCard` sin `updatedAt` no muestra la línea "Actualizado".

**🟡 Intermedio (9–17)**

9. Completa la prueba de memoria de `selectBands` con el caso "segmentos nuevos → bandas nuevas".
10. Escribe `renderWithStore` de memoria y monta `DashboardPage` con un estado precargado propio. **Criterio:** cuatro tarjetas, sin tocar la red.
11. Prueba que `React.memo` en `MetricCard` no vuelve a renderizar con las mismas props (cuenta renders con un componente envoltorio).
12. Prueba que `BandChart` llama a `update` y no al constructor cuando cambian `low` y `high`.
13. Prueba `WheelTable` con una rueda `reconciled` y confirma su etiqueta en español.
14. Prueba que un `rollbackGrant` sobre un envío que no existe no rompe nada.
15. Rompe a propósito el smoke (cambia el texto "Sin alarma") y lee el mensaje de Cypress. **Criterio:** el mensaje nombra el texto que no encontró.
16. Escribe un ayudante `queuedGrant(overrides)` para las pruebas del slice y reescribe dos pruebas con él.
17. Corre la prueba de la tolerancia de §5.8 con k = 3 en vez de 5, en un bucle de 200 corridas. **Criterio:** cuentas las que fallan y lo comparas con lo que predice A14 §5 para la banda (alrededor de una de cada cincuenta); explica por qué con 5σ no viste ninguna.

**🟠 Difícil (18–25)**

18. Escribe la prueba de canicas de `searchPlayerEpic` para el debounce: tres teclas dentro de la ventana, una sola búsqueda.
19. Escribe la prueba de `undoWindowEpic`: dos envíos encolados vencen cada uno a su hora (A7, patrón 3).
20. Escribe la prueba de `sendGrantEpic` para el doble clic: una sola petición.
21. Diagnóstico: te dan una prueba de canicas **verde** que deja pasar un bug (compara payloads con `toEqual` y no verifica el frame). Encuentra por qué no prueba el tiempo y arréglala.
22. Escribe la prueba de `pollingEpic` que confirma que con `stopPolling` no hay más consultas, y hazla fallar borrando `stopPolling.match` del `takeUntil`.
23. Diagnóstico: una prueba de componente pasa en tu máquina y falla en integración. La causa está en una tarjeta que depende del reloj y de la zona de quien corre la prueba. Reprodúcela y propón el fix (es el incidente 20).
24. Prueba que el rollback de un envío no deja pegado ningún campo del optimista (estado, error, confirmado), campo por campo.
25. Escribe una prueba que atrape un render de más en `DashboardPage` sin abrir el Profiler, con `selectSpinSummary.recomputations()`.

**🔴 Muy difícil (26–30)**

26. Reproduce a mano el leak del refresco de la Fase 6 con Redux DevTools y el log del mock, y después escribe la prueba de canicas que lo fija. Entrega las dos cosas.
27. Escribe tres pruebas de `retryGrantEpic`, una por clase de error (`timeout`, `503`, `409`), que confirmen que el `409` no se reintenta.
28. Escribe una prueba de tolerancia calculada para el generador de bitácoras con la regla nueva: la proporción de premios entregados como sustituto, con su margen. **Criterio:** 50 corridas verdes con semillas distintas, y la prueba falla si el generador deja de entregar sustitutos.
29. Escribe la prueba que distingue `mergeMap` de `switchMap` en la búsqueda (con `mergeMap` aparecen las dos respuestas) y documenta cuál es el correcto.
30. Meta-prueba: escribe una prueba que falle si alguien corre dos veces `epicMiddleware.run(rootEpic)` en `store.js` (cada acción se procesaría dos veces). Pista: cuenta cuántas veces se emite una acción por un solo disparo.

**🔥 Opcionales**

- 🔥 Configura un umbral de cobertura con `npm test -- --coverage` y discute por qué un número alto no garantiza pruebas útiles.
- 🔥 Reescribe una prueba de componente con MSW en vez del doble de `apiClient`, y compara la ergonomía. (No se adopta en el stack.)
- 🔥 Agrega al smoke el camino de un envío manual: encolar, deshacer, volver a encolar y enviar. Anota qué lo hace más frágil que el camino mínimo.

---

## 📚 8. Referencias

**Documentación oficial**
- https://testing-library.com/docs/react-testing-library/intro/ — React Testing Library; verifica que los ejemplos sean de la línea 11.x.
- https://archive.jestjs.io/docs/en/26.x/jest-object — Jest **26**: `jest.mock`, `jest.useFakeTimers("modern")` y `jest.setSystemTime`.
- https://create-react-app.dev/docs/running-tests/ — cómo corre las pruebas CRA, `CI=true` y su configuración de Jest (incluido `resetMocks`).
- https://redux.js.org/usage/writing-tests — la guía oficial para probar reducers y selectores.
- https://github.com/cartant/rxjs-marbles — `rxjs-marbles`; para RxJS 6.6.7 va la 6.x.
- https://docs.cypress.io/guides/getting-started/opening-the-app — Cypress; verifica que la página sea de la 10.x.

**Libros**
- *Testing JavaScript Applications*, de Lucas da Costa — el modelo de la pirámide y de probar comportamiento; agnóstico de framework.

**Orden de lectura sugerido:** la guía de Redux (reducers y selectores) → React Testing Library → `A11-marble-testing.md` → A14 §3 y §5, para la tolerancia de §5.8 → el código de §5.7 y §5.8.

> ⚠️ Las URL y los contenidos pueden haber cambiado; verifica siempre la versión. Varios de estos sitios muestran por defecto la última major (Jest 29, RTL 14, RxJS 7, Cypress 13), que difiere de las fijadas en el curso.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Terminaste con una red mínima pero real: funciones puras y reducers probados sin andamiaje, selectores cuya memoria se verifica por identidad, componentes de clase y de función probados por su salida, epics con el tiempo fijado, lo aleatorio sin intermitencia y un smoke que confirma que el camino feliz responde contra los servicios de verdad. Más importante que la cantidad de pruebas: el hábito **prueba primero, fix después**.

Eso es lo que habilita la **Fase 11 — Cierre + puente a React moderno**. Con pruebas que verifican *comportamiento* y no *implementación*, ya puedes discutir con red qué significaría modernizar esta consola —hooks en todos lados, RxJS 7, React 18— sin romper nada: las pruebas de esta fase son justamente las que dirían si una migración preservó el comportamiento. Y es la que cierra la otra pregunta, la de Abdiel: si la Esclusa se apaga o se migra en dos años.

> **La señal de que quedó bien:** cuando borras un `takeUntil` a propósito y la prueba de canicas falla en el frame exacto donde nace el leak —y lo restauras y vuelve a verde— sin haber abierto Redux DevTools. Y cuando corres la prueba de lo aleatorio cincuenta veces y no te pone nervioso.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-10-testing-minimo -m "F10 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f10: …`) y los de ejercicio su número (`f10 ej17: …`). Si un ejercicio merece su propio marcador va en `ej/f10/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` / `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura. Va acá abajo, fuera de la plantilla de nueve secciones, porque es lo que apareció al escribir la fase y no cabía adentro — y porque no debe competir con el cierre.

- **El smoke necesita los dos mocks y el servidor de desarrollo arriba**, y no hay un script que los levante juntos para Cypress. → Un `npm run smoke` con `concurrently` y `wait-on` sería el paso siguiente; no está en el stack fijado.
- **La aserción de fecha de `MetricCard` depende del ICU del motor**: "20/12 21:00" en el Node 14 de Jest, "20/12, 21:00" en Chromium. → Si la suite corre algún día en un navegador real, la aserción tiene que tolerar el separador.
- **No hay prueba de que la sesión sobreviva al F5** (el pago de deuda de la Fase 3). → Sumarlo al smoke.

### Reservas para el cuaderno de incidentes

Los IDs quedan reservados en `cuaderno-incidentes.md`, donde el enunciado ya está redactado con sus pistas y su solución de referencia. El ID nunca se reasigna.

- **20** — *El test pasa en mi máquina y falla en la de al lado* · Testing · 🔴. Sale de la prueba de §5.5: una `MetricCard` que alguien cambió para que consulte el reloj y la zona horaria de quien corre la prueba. Es el único incidente del curso que no se reproduce en la aplicación sino en la suite, y por eso cierra el arco: la prueba también es código que se mantiene. Se abre acá y se cierra en la Fase 11.
