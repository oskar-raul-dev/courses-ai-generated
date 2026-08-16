# 🧪 Fase 10 — Testing mínimo

> Tutorial React 16 — Rifas y chances · Fase 10 de 11 · **6 horas**
> Depende de: Fase 9 (Dashboard) · Habilita: Fase 11 (Cierre + puente a React moderno)

---

## 🎯 1. Propósito

Convertir cada pieza forense que vienes acumulando desde la Fase 4 en un **test automatizado que falla con el bug presente y pasa con el fix**. No es un curso de testing: es el mínimo que un equipo de mantenimiento necesita para tocar código legacy sin romperlo —testear una función pura, un slice, un componente (funcional y de clase) y, sobre todo, un **epic con timing determinista** usando marbles. La pregunta que responde la fase deja de ser "¿cómo reproduzco el bug a mano?" y pasa a ser "¿cómo escribo el test que lo atrapa para siempre?".

---

## ✅ 2. Qué queda listo al terminar

- [ ] Sabes correr la suite (`react-scripts test`) y escribir un test unitario de función pura (`dashboardMath`) sin ningún mock, entendiendo qué trae CRA 4 ya configurado y qué no.
- [ ] Testeas un **slice** (`saleSlice`): despachas acciones sobre el reducer y verificas las transiciones `available → reserved → sold` y el **rollback** ante `error.type: 'conflict'`, sin store real ni red.
- [ ] Testeas un **selector memoizado** (`createSelector`) por identidad referencial: mismo input → misma referencia; input cambiado → recálculo.
- [ ] Testeas un **componente** con RTL —uno funcional (`MetricCard` / `DashboardPage`) y uno de **clase** (`RaffleTable`)— seleccionando por `data-testid` en inglés, con `chart.js` mockeado.
- [ ] Escribes un **test de epic con `rxjs-marbles` + `TestScheduler`** que fija el timing de `debounceTime`/`switchMap` y prueba la **cancelación** por `takeUntil` (la pieza forense de la fase), más un smoke test de Cypress del happy path.

---

## 🚫 3. Qué queda fuera por ahora

- **e2e exhaustivo** (flujos completos multi-página, matriz de navegadores) → Fase 11 / apéndice de smoke tests. Acá solo un happy path de Cypress.
- **Cobertura formal / umbrales de coverage** → no es objetivo de mantenimiento mínimo; se menciona como 🔥.
- **Testing de accesibilidad, visual regression, performance budgets** → fuera de alcance del curso.
- **Reescribir fases previas para "hacerlas testeables"** → el código ya está diseñado para testearse; no se refactoriza nada aquí.
- **La metodología de marble testing** → `A11-marble-testing.md`. Acá se aplica sobre los epics del proyecto; la gramática, el `hot` frente a `cold` y los errores comunes viven allá.
- **MSW (Mock Service Worker)** → tentador para interceptar red en tests de componente, pero no está en el stack fijado; se menciona como 🔥, no se adopta.

---

## 🧠 4. Conceptos mínimos

Eres senior: sabes qué es un test unitario y por qué un test que depende del reloj de pared es un test que va a fallar un martes cualquiera. Lo que importa acá es **qué se testea en un stack Redux Toolkit + redux-observable y con qué herramienta**, porque cada capa se testea distinto y mezclarlas es el error más común.

**La pirámide para esta app, de abajo hacia arriba.** Las **funciones puras** (`dashboardMath.js`, `formatCents`) son la base: entra un objeto, sale un valor, cero mocks, cero timers. Son el test más barato del curso y por eso el capítulo arranca ahí. Un escalón arriba, los **reducers de un slice** son también funciones puras disfrazadas: `(state, action) => nextState`. Se testean invocando el reducer con un estado y una acción, sin store, sin `Provider`, sin red. Los **selectores** memoizados con `createSelector` agregan una dimensión: no basta con verificar *qué* devuelven, hay que verificar que **memoizan** —y eso se testea por identidad referencial (`toBe`, no `toEqual`). Los **componentes** se testean con React Testing Library preguntándole a la pantalla lo que vería un usuario (texto, roles, `data-testid`), nunca el estado interno. Y en la cima —el trabajo real de esta fase— los **epics**, que son streams temporales y por eso necesitan una herramienta que controle el tiempo.

**Por qué los epics necesitan marbles y no `setTimeout` real.** Un epic con `debounceTime(300)` que testeas con un `setTimeout` de verdad te obliga a *esperar* 300ms reales por test, hace la suite lenta y —peor— **flaky**: a veces el timer del test corre antes que el del epic y el assert falla sin que nada esté roto. Ese es exactamente el 🔴 de "bug intermitente" que arrastras desde Fase 6. La solución es un **reloj virtual**: el `TestScheduler` de RxJS avanza el tiempo en pasos discretos que tú controlas, así `debounceTime(300)` "pasa" instantáneamente y de forma **determinista**. `rxjs-marbles` (decisión D9) es un wrapper fino sobre ese scheduler que te deja escribir el flujo como un **diagrama de canicas** —`'--a--b|'`— donde cada guion es un frame de tiempo y cada letra una emisión. El diagrama de entrada y el esperado se comparan frame a frame: si `switchMap` no canceló lo anterior en el frame correcto, el marble no cuadra y el test falla con un mensaje que te muestra *dónde* divergió el timing. Es la forma de convertir "a veces se dispara una acción fantasma" en un assert exacto.

**Qué trae CRA 4 y qué no.** `react-scripts` 4.0.3 ya configura **Jest 26** y **React Testing Library 11** (con `@testing-library/jest-dom` y `@testing-library/user-event`); `src/setupTests.js` ya importa los matchers. No instalas Jest ni configuras `jest.config`. Lo único que sumas para esta fase es `rxjs-marbles` (dev dependency) para los epics y `cypress` para el smoke. No toques versiones (D7): `package-lock.json` manda.

> **Nota de convivencia.** Igual que el código de la app mezcla class y hooks, los tests de esta fase testean **ambos** con la misma herramienta: RTL no distingue entre un componente de clase (`RaffleTable`) y uno funcional (`MetricCard`), porque testea la **salida renderizada**, no la implementación. Ese es justo el argumento de "testear comportamiento, no implementación" (guía §5): un test que no sabe si adentro hay una clase o un hook es un test que sobrevive a la refactorización de Fase 11.

---

## 💻 5. Implementación y código comentado

Estructura de archivos de test que vamos a crear (colocados junto al código que testean, convención de CRA):

```
src/
  features/
    dashboard/
      dashboardMath.js            (Fase 9)   → dashboardMath.test.js
      dashboardSelectors.js       (Fase 9)   → dashboardSelectors.test.js
      MetricCard.jsx              (Fase 9)   → MetricCard.test.jsx
      DashboardPage.jsx           (Fase 9)   → DashboardPage.test.jsx
      BarChart.jsx                (Fase 9)   → (mock de chart.js, ver 5.5)
    raffles/
      RaffleTable.jsx             (Fase 4)   → RaffleTable.test.jsx
    sales/
      saleSlice.js                (Fase 5)   → saleSlice.test.js
      epics/
        validateNumberEpic.js     (Fase 6)   → validateNumberEpic.test.js
        pollingEpic.js            (Fase 7)   → pollingEpic.test.js
  test/
    renderWithStore.jsx           (helper nuevo de esta fase)
cypress/
  e2e/
    smoke.cy.js                   (happy path)
```

### 5.1 Configuración: lo que ya está y lo único que sumas

CRA 4 corre los tests con `react-scripts test` (modo watch por defecto; `CI=true react-scripts test` para una pasada). No hay `jest.config.js`: la config vive dentro de `react-scripts`. Lo único que instalamos:

```bash
# rxjs-marbles para los epics (D9); cypress para el smoke.
# --save-dev: son dependencias de desarrollo, no van al bundle.
# Las versiones van PINEADAS: ver prompts/decisiones-y-versiones.md §3.
npm install --save-dev rxjs-marbles@6.0.1 cypress@10.11.0
```

> ⚠️ **El `@6.0.1` no es opcional, y esta es la trampa que se lleva la tarde.**
> `rxjs-marbles` ata su major a la de RxJS: la línea **6.x es para RxJS 6**, la
> 7.x para RxJS 7. Un `npm install --save-dev rxjs-marbles` a secas te trae la
> 7.x contra tu RxJS 6.6.7, y los tests fallan con errores de scheduler que no
> mencionan la versión por ningún lado. Media hora buscando el bug en tu
> diagrama cuando el bug estaba en el `package.json`.
>
> Lo mismo con Cypress: la 10.11.0 es la última que corre cómoda sobre Node 14
> y la que usa el layout `cypress/e2e/*.cy.js` que verás en §5.8. Una versión
> más nueva pide Node más nuevo y rompe el `engines` del proyecto (D10).

El helper que reusaremos en todos los tests de componente conectados al store:

```jsx
// src/test/renderWithStore.jsx
import React from 'react';
import { render } from '@testing-library/react';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import authReducer from '../features/auth/authSlice';
import raffleReducer from '../features/raffles/raffleSlice';
import saleReducer from '../features/sales/saleSlice';
import settlementReducer from '../features/settlements/settlementSlice';

/**
 * Monta un componente con un store REAL de Redux Toolkit pero aislado por test.
 * No montamos epicMiddleware: los tests de componente no ejercitan epics
 * (esos se testean aparte con marbles). Así el store es síncrono y predecible.
 *
 * @param {React.ReactElement} ui - el componente a montar
 * @param {{ preloadedState?: object }} [options] - estado inicial del store
 * @returns {import('@testing-library/react').RenderResult & { store: import('@reduxjs/toolkit').EnhancedStore }}
 */
export function renderWithStore(ui, { preloadedState } = {}) {
  const store = configureStore({
    // Mismas ramas que src/app/store.js (Fase 9 no agregó claves).
    reducer: {
      auth: authReducer,
      raffles: raffleReducer,
      sales: saleReducer,
      settlements: settlementReducer,
    },
    preloadedState,
  });
  // Devolvemos el store además del resultado de render por si el test
  // quiere despachar o inspeccionar estado.
  return { store, ...render(<Provider store={store}>{ui}</Provider>) };
}
```

### 5.2 Nivel 0 — Test de función pura (`dashboardMath`): el más barato, sin mocks

El punto de entrada al testing. `computeTotalMargin` (Fase 9) suma márgenes **en centavos enteros**. No toca React, ni Redux, ni la red: entra un array, sale un entero.

```javascript
// src/features/dashboard/dashboardMath.test.js
import { computeTotalMargin } from './dashboardMath';
import { formatCents } from '../settlements/settlementMath';

describe('computeTotalMargin', () => {
  // 'it' describe el COMPORTAMIENTO en español; el código adentro, en inglés.
  it('suma márgenes en centavos como enteros exactos', () => {
    const settlements = [{ marginCents: 1500 }, { marginCents: 320 }];
    expect(computeTotalMargin(settlements)).toBe(1820);
  });

  it('incluye márgenes negativos sin perder precisión', () => {
    // Un margen negativo (rifa que pagó más premio que lo recaudado)
    // debe restar, no romperse ni saltearse.
    const settlements = [{ marginCents: 1500 }, { marginCents: -2000 }];
    expect(computeTotalMargin(settlements)).toBe(-500);
  });

  it('devuelve 0 con lista vacía (sin rifas liquidadas todavía)', () => {
    expect(computeTotalMargin([])).toBe(0);
  });
});

describe('formatCents (frontera de dinero, heredada de Fase 8)', () => {
  it('formatea un entero de centavos a texto en pesos', () => {
    expect(formatCents(1820)).toBe('$18,20'); // ajusta al locale real del proyecto
  });

  it('LANZA si recibe un float — es comportamiento esperado, no un bug', () => {
    // Fase 8 decidió que el dinero NUNCA es float. formatCents defiende
    // esa frontera lanzando. NO lo "arreglamos" en el test: testeamos que
    // la defensa sigue viva. Si un día deja de lanzar, algo se rompió.
    expect(() => formatCents(18.2)).toThrow();
  });
});
```

Lo que enseña: un test de función pura no necesita andamiaje. Si tu unidad de negocio más importante (el dinero) no es una función pura, ese es el primer *smell* a anotar.

### 5.3 Test de slice: `saleSlice` — acciones, reducer, estado

Un reducer es `(state, action) => nextState`: una función pura. Se testea **invocando el reducer directamente**, sin store. Testeamos el corazón de la concurrencia de Fase 5: la transición optimista y su **rollback** ante `conflict`.

```javascript
// src/features/sales/saleSlice.test.js
import {
  saleReducer,
  reserveNumber,
  sellNumber,
  rollbackSale,
} from './saleSlice';

// Estado base: el número 0347 disponible. 'byNumber' es el índice heredado
// de Fase 5 (status por número). No reconstruimos el slice: lo importamos.
const baseState = {
  byNumber: { '0347': { status: 'available', participantId: null } },
  error: null,
};

describe('saleSlice — flujo de venta y rollback de conflicto', () => {
  it('reserva mueve el número de available a reserved (optimista)', () => {
    // pending del thunk: aplicamos el update optimista ANTES de la respuesta.
    const action = reserveNumber.pending('req-1', { number: '0347', participantId: 'p-9' });
    const next = saleReducer(baseState, action);
    expect(next.byNumber['0347'].status).toBe('reserved');
    expect(next.byNumber['0347'].participantId).toBe('p-9');
  });

  it('venta confirmada mueve de reserved a sold', () => {
    const reserved = {
      byNumber: { '0347': { status: 'reserved', participantId: 'p-9' } },
      error: null,
    };
    const action = sellNumber.fulfilled(
      { number: '0347', participantId: 'p-9' },
      'req-2',
      { number: '0347' }
    );
    const next = saleReducer(reserved, action);
    expect(next.byNumber['0347'].status).toBe('sold');
  });

  it('conflicto (409) revierte el optimismo CAMPO POR CAMPO', () => {
    // Este es el test de regresión del bug de Fase 5: un rollback que
    // deja 'participantId' pegado. Partimos del estado optimista...
    const optimistic = {
      byNumber: { '0347': { status: 'reserved', participantId: 'p-9' } },
      error: null,
    };
    // ...y llega el rejected con type 'conflict' (alguien lo ganó antes).
    const action = sellNumber.rejected(
      null,
      'req-2',
      { number: '0347' },
      { message: 'Ese número ya no está disponible', type: 'conflict' }
    );
    const next = saleReducer(optimistic, action);

    // El rollback debe deshacer TODO lo que el optimismo tocó:
    expect(next.byNumber['0347'].status).toBe('available');
    expect(next.byNumber['0347'].participantId).toBeNull(); // ← el campo que el bug olvidaba
    // Y el error legible queda disponible para la UI:
    expect(next.error).toEqual({
      message: 'Ese número ya no está disponible',
      type: 'conflict',
    });
  });
});
```

**Corrección mínima vs refactorización.** Si este test falla porque `participantId` quedó pegado, la **corrección mínima** es que el reducer del `rejected` (o `rollbackSale`) resetee *cada* campo que el `pending` tocó. La **refactorización** —tentadora pero fuera de alcance— sería guardar un snapshot del estado previo del número antes del optimismo y restaurarlo entero, eliminando la clase de bug de raíz. La fase enseña a escribir el test primero; cuál de los dos fixes aplicar es decisión de la revisión, y el test verde vale para ambos.

### 5.4 Test de selector memoizado: identidad referencial de `createSelector`

Fase 9 introdujo `createSelector`. Un selector memoizado no solo debe devolver **el valor correcto**, sino **la misma referencia** cuando la entrada no cambió —esa es toda la razón de existir de reselect. Se testea con `toBe` (identidad), no `toEqual` (igualdad estructural).

```javascript
// src/features/dashboard/dashboardSelectors.test.js
import { selectTotalMargin } from './dashboardSelectors';

// Construimos estados mínimos que el selector sabe leer. La clave del test
// de memoización: la MISMA referencia de entrada debe dar la MISMA de salida.
const settlements = { byRaffleId: { r1: { marginCents: 1500 } } };

describe('selectTotalMargin — memoización de createSelector', () => {
  it('con el MISMO input devuelve la MISMA referencia (memoiza)', () => {
    const state = { settlements };
    const a = selectTotalMargin(state);
    const b = selectTotalMargin(state); // mismo state, misma referencia de settlements
    expect(b).toBe(a); // toBe: identidad referencial, no igualdad de valor
  });

  it('cuando el input CAMBIA, recalcula (nueva referencia)', () => {
    const first = selectTotalMargin({ settlements });
    const changed = { byRaffleId: { r1: { marginCents: 9999 } } };
    const second = selectTotalMargin({ settlements: changed });
    expect(second).not.toBe(first);
    expect(second).not.toEqual(first); // y además el valor cambió
  });

  it('TEST NEGATIVO: un input que crea objeto nuevo cada vez ROMPE la caché', () => {
    // Si el selector de entrada devolviera un objeto nuevo en cada llamada
    // (p. ej. un .map() sin memoizar aguas arriba), createSelector recalcula
    // siempre. Este test documenta por qué las referencias del store deben
    // ser estables. Reproducimos el anti-patrón a propósito:
    const s1 = selectTotalMargin({ settlements: { byRaffleId: { r1: { marginCents: 1500 } } } });
    const s2 = selectTotalMargin({ settlements: { byRaffleId: { r1: { marginCents: 1500 } } } });
    // Mismo VALOR de entrada, pero DISTINTA referencia de objeto:
    // la memoización por referencia no aplica, se recalcula.
    expect(s2).not.toBe(s1); // ← esto es lo que enseña: memoiza por referencia, no por valor
  });
});
```

### 5.5 Test de componente funcional con RTL

`MetricCard` (Fase 9) recibe strings ya formateados y está envuelto en `React.memo`. `DashboardPage` monta cuatro `MetricCard` y dos `BarChart`. Como jsdom no tiene canvas, **mockeamos `chart.js`** con un doble que registra construcción y destrucción —lo que además nos deja testear el cleanup.

```jsx
// src/features/dashboard/BarChart.test.jsx  (mock de chart.js)
import React from 'react';
import { render, cleanup } from '@testing-library/react';
import BarChart from './BarChart';

// chart.js 2.x: el default export es el constructor Chart.
// Lo reemplazamos por un doble que anota que fue construido y destruido.
const destroySpy = jest.fn();
const chartCtor = jest.fn(() => ({ destroy: destroySpy, update: jest.fn() }));
jest.mock('chart.js', () => ({
  __esModule: true,
  default: jest.fn((...args) => chartCtor(...args)),
}));

describe('BarChart — ciclo de vida de la instancia chart.js', () => {
  afterEach(() => {
    chartCtor.mockClear();
    destroySpy.mockClear();
  });

  it('construye la instancia al montar', () => {
    render(<BarChart labels={['0347', '0912']} values={[3, 5]} />);
    expect(chartCtor).toHaveBeenCalledTimes(1);
  });

  it('destruye la instancia al desmontar (sin fuga)', () => {
    const { unmount } = render(<BarChart labels={['0347']} values={[3]} />);
    unmount();
    // El cleanup del useEffect [] debe llamar a destroy(). Este es el
    // test de regresión de la fuga de chart.js (error común #2 de Fase 9).
    expect(destroySpy).toHaveBeenCalledTimes(1);
  });
});
```

```jsx
// src/features/dashboard/DashboardPage.test.jsx
import React from 'react';
import { screen } from '@testing-library/react';
import { renderWithStore } from '../../test/renderWithStore';
import DashboardPage from './DashboardPage';

// Reusamos el mock de chart.js: jsdom no dibuja canvas real.
jest.mock('chart.js', () => ({
  __esModule: true,
  default: jest.fn(() => ({ destroy: jest.fn(), update: jest.fn() })),
}));

// Estado de prueba: dos rifas, algunas ventas, una liquidación.
const preloadedState = {
  raffles: { items: [{ id: 'r1', name: 'Rifa Enero', status: 'settled' }], loadingList: false, error: null },
  sales: { byNumber: { '0347': { status: 'sold', participantId: 'p1' } }, error: null },
  settlements: { byRaffleId: { r1: { marginCents: 1500 } }, loading: false },
  auth: { user: { name: 'Ana' }, token: 'tok_ana_9f2c', loading: false, error: null },
};

describe('DashboardPage — render de solo lectura', () => {
  it('muestra las cuatro tarjetas de indicador', () => {
    renderWithStore(<DashboardPage />, { preloadedState });
    // Seleccionamos por data-testid en inglés (kebab-case), congelado en Fase 9.
    expect(screen.getAllByTestId('metric-card')).toHaveLength(4);
  });

  it('renderiza los gráficos de barras', () => {
    renderWithStore(<DashboardPage />, { preloadedState });
    expect(screen.getAllByTestId('bar-chart').length).toBeGreaterThanOrEqual(1);
  });
});
```

> **Comportamiento, no implementación.** No preguntamos "¿el estado interno de `MetricCard` es X?". Preguntamos "¿hay cuatro tarjetas en pantalla?". Si Fase 11 reescribe `MetricCard` de función a otra cosa, estos tests siguen pasando mientras la pantalla no cambie.

### 5.6 Test de componente de **clase** con RTL

`RaffleTable` (Fase 4) es un **class component** con cuatro ramas: `loading`, `error`, `empty` y la tabla con filas. RTL lo testea **igual** que a un funcional —esa es la prueba viva de que testeamos salida, no implementación.

```jsx
// src/features/raffles/RaffleTable.test.jsx
import React from 'react';
import { render, screen } from '@testing-library/react';
import RaffleTable from './RaffleTable';

// RaffleTable es un componente de CLASE (Fase 4). RTL no lo sabe ni le importa:
// recibe props y verificamos lo que pinta. Le pasamos props directas (no store)
// porque en Fase 4 recibía por props vía connect(); acá lo montamos "pelado".
describe('RaffleTable — un class component se testea por su render', () => {
  it('muestra el spinner mientras carga', () => {
    render(<RaffleTable loadingList raffles={[]} error={null} />);
    expect(screen.getByTestId('raffles-loading')).toBeInTheDocument();
  });

  it('muestra el error legible cuando falla la carga', () => {
    render(
      <RaffleTable
        loadingList={false}
        raffles={[]}
        error={{ message: 'No se pudo cargar la rifa', type: 'http' }}
      />
    );
    // El TEXTO que ve el usuario está en español (no se traduce):
    expect(screen.getByText('No se pudo cargar la rifa')).toBeInTheDocument();
  });

  it('muestra el mensaje de lista vacía sin rifas', () => {
    render(<RaffleTable loadingList={false} raffles={[]} error={null} />);
    expect(screen.getByText(/no hay rifas/i)).toBeInTheDocument();
  });

  it('renderiza una fila por rifa con su etiqueta de estado en español', () => {
    const raffles = [
      { id: 'r1', name: 'Rifa Enero', status: 'open' },
      { id: 'r2', name: 'Rifa Febrero', status: 'closed' },
    ];
    render(<RaffleTable loadingList={false} raffles={raffles} error={null} />);
    expect(screen.getByText('Rifa Enero')).toBeInTheDocument();
    // statusLabel('open') → 'Abierta': el case en inglés, la etiqueta en español.
    expect(screen.getByText('Abierta')).toBeInTheDocument();
    expect(screen.getByText('Cerrada')).toBeInTheDocument();
  });
});
```

### 5.7 💻 PIEZA FORENSE — Test de epic con `rxjs-marbles` → **A11**

El corazón de la fase, y el único bloque de testing que no cabe acá. Un epic es
un stream temporal: testearlo con timers reales es lento, flaky y —lo
determinante— **incapaz de probar lo que más importa**, que no es qué emite sino
qué *deja* de emitir tras un corte.

Toda la metodología vive en **`A11-marble-testing.md`**: la gramática del
diagrama, `hot` frente a `cold`, el molde base, y un test trabajado para cada
uno de los tres operadores que hay que fijar —`debounceTime`, `switchMap` y
`takeUntil`— sobre `validateNumberEpic` y `pollingEpic`, que son epics que ya
escribiste en las Fases 6 y 7.

**Ve al A11 ahora y vuelve.** Son unos cuarenta minutos y es el contenido más
denso del curso; no tiene sentido resumirlo acá y que tengas que leerlo dos
veces. Lo que sigue en esta fase (§5.8, el smoke) asume que ya lo hiciste.

Lo que sí conviene fijar antes de que te vayas, porque es la razón de ser de
todo el aparato:

> 🧠 **El assert más valioso del curso vive en lo que *falta* del diagrama.**
> Un marble test de `takeUntil` no verifica una emisión: verifica que **no hay
> ninguna** después del corte, y que el stream completó. Si alguien borra el
> `takeUntil` de un epic, ese diagrama deja de cuadrar y el test falla
> exactamente donde vive el memory leak. Ninguna otra herramienta del curso
> puede afirmar eso: manualmente, "no pasó nada" solo se comprueba esperando, y
> nunca sabes si esperaste lo suficiente.

Es, literalmente, la diferencia entre creer que tus epics se cancelan y poder
demostrarlo.

### 5.8 Smoke test con Cypress: happy path

Un único flujo de extremo a extremo: login → dashboard. No es e2e exhaustivo (eso es Fase 11); es la red de seguridad que detecta que "la app arranca y el camino feliz responde".

```javascript
// cypress/e2e/smoke.cy.js
describe('Smoke — el camino feliz responde', () => {
  it('un usuario inicia sesión y ve el dashboard', () => {
    // Interceptamos el login contra json-server (puerto 3001) para no
    // depender del backend real en el smoke. El token hardcodeado es
    // el de Fase 2.
    cy.intercept('GET', '**/users*', {
      statusCode: 200,
      body: [{ id: 1, email: 'ana@rifas.test', token: 'tok_ana_9f2c', name: 'Ana' }],
    }).as('login');

    cy.visit('/login');
    // Textos de UI en español (no se traducen); selección por rol/label.
    cy.get('input[name="email"]').type('ana@rifas.test');
    cy.get('input[name="password"]').type('rifas123');
    cy.contains('button', 'Iniciar sesión').click();

    cy.wait('@login');
    // PrivateRoute nos dejó pasar: el dashboard renderiza sus tarjetas.
    cy.get('[data-testid="metric-card"]').should('have.length', 4);
  });
});
```

> 💸 **Deuda técnica intencional.** El smoke stubbea la red con `cy.intercept` en vez de correr contra el mock real levantado. Lo correcto para un smoke "de verdad" es apuntar a un json-server efímero con `db.json` sembrado, para que el test también valide el interceptor de `apiClient` y el header `Authorization`. Se deja stubbeado porque el objetivo de la fase es *un* happy path reproducible sin orquestar servicios; el smoke contra servicios reales vive en Fase 11.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Testear implementación en vez de comportamiento.** Síntoma: el test se rompe cada vez que refactorizas aunque la app funcione igual. Causa: asserts sobre estado interno, nombres de métodos o estructura del árbol en lugar de lo que ve el usuario. Fix mínimo: preguntar a la pantalla (`getByText`, `getByRole`, `getByTestId`), no al componente. Es la diferencia entre un test que sobrevive a Fase 11 y uno que hay que reescribir.

**2. Marble test flaky por usar timers reales.** Síntoma: el test del epic pasa 9 de 10 veces. Causa: se testeó con `setTimeout`/`jest.useFakeTimers()` mal sincronizados en vez del `TestScheduler`. Fix mínimo: mover el epic a `rxjs-marbles`; el reloj virtual elimina la carrera. **Refactorización** (no hace falta): rediseñar el epic —el problema no es el epic, es el test.

**3. `toEqual` donde va `toBe` en el test de memoización.** Síntoma: el test de `createSelector` "pasa" pero no prueba nada. Causa: `toEqual` compara valores, y dos recálculos dan el mismo valor aunque la memoización esté rota. Fix: usar `toBe` (identidad referencial) para afirmar que *no* recalculó.

**4. Olvidar mockear `chart.js` y pelear con jsdom.** Síntoma: `TypeError: canvas.getContext is not a function`. Causa: jsdom no implementa canvas; chart.js intenta dibujar. Fix mínimo: `jest.mock('chart.js', ...)` con un doble que exponga `destroy`/`update`. Bonus: ese mismo doble te deja testear el cleanup (error #2 de Fase 9).

### Pieza forense de esta fase — Test de epic con marbles: cómo asegurar timing

La forense de esta fase es meta-forense: **convertir la reproducción manual de un bug intermitente en un test que lo fija**. El flujo: (1) reproduces el 🔴 de Fase 6 a mano (una acción fantasma que se dispara después del logout porque falta un `takeUntil`); (2) lo traduces a un diagrama de marbles donde el logout llega *antes* de que el epic complete; (3) escribes el `expected` como "el stream completa sin emitir"; (4) confirmas que el test **falla con el bug** (el epic sí emite) y **pasa con el fix** (el `takeUntil` restaurado corta el flujo). El marble es la evidencia observable convertida en assert.

**🔧 Rompe a propósito y observa.** Toma `validateNumberEpic` y bórrale el `takeUntil(logout$)`. Corre el tercer test de 5.7 (el de logout). Debe **fallar**: el `expected` dice "completa en el frame del logout sin emitir", pero el epic sin `takeUntil` sigue vivo y emite la validación después. Mira el diff que imprime `rxjs-marbles`: te muestra el frame exacto donde el stream real diverge del esperado. Restaura el `takeUntil`: verde. Ese diff es la forma más limpia de *ver* un memory leak de suscripción.

> 📓 De esta fase sale el incidente **20** de `cuaderno-incidentes.md`, el único que no se reproduce en la aplicación sino en la suite — y el único que no termina en un parche, sino en una decisión que se escribe. Se abre acá y se cierra en la Fase 11.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Corre la suite con `CI=true react-scripts test` y confirma que los tests de `dashboardMath` pasan sin ningún mock.
2. Agrega un test a `computeTotalMargin` que verifique que un solo settlement devuelve su propio `marginCents`.
3. Escribe un test de `computeSalesRate` (Fase 9) con una rifa de 100 números y 25 vendidos → 0.25.
4. Testea que `formatCents(0)` devuelve el texto de cero pesos correcto para el locale del proyecto.
5. Agrega un test que confirme que `computeTotalMargin` ignora (o incluye, según lo que decidió Fase 9) settlements sin `marginCents` —documenta cuál es el comportamiento real.
6. Testea el reducer de `saleSlice` para el caso `reserveNumber.rejected`: el número vuelve a `available`.
7. Escribe un test de `RaffleTable` que verifique que con una sola rifa hay exactamente una fila.
8. Testea que `MetricCard` renderiza el título y el valor que recibe por props.

**🟡 Intermedio (9–17)**

9. Completa el test de memoización de `selectTotalMargin` agregando el caso "input cambiado → valor distinto Y referencia distinta".
10. Escribe `renderWithStore` desde cero sin mirar el ejemplo y monta `DashboardPage` con un `preloadedState` propio.
11. Testea que `React.memo` en `MetricCard` **no** re-renderiza cuando recibe el mismo string dos veces (usa un contador de renders).
12. Agrega al mock de `chart.js` un `update` spy y testea que `BarChart` llama `update` (no reconstruye) cuando cambian `values`.
13. Testea `RaffleTable` con `status: 'settled'` y confirma que `statusLabel` muestra "Liquidada".
14. Escribe un test de slice para `sellNumber.fulfilled` que confirme que `error` queda en `null` tras una venta exitosa.
15. Testea que el smoke de Cypress falla de forma clara si el `data-testid="metric-card"` no aparece (rómpelo a propósito y lee el mensaje).
16. Escribe un helper `makeSaleState(overrides)` que genere estados de `saleSlice` para los tests, y reescribe dos tests usándolo.
17. Testea que `computeRecurringParticipants` devuelve `0` con las ventas actuales (que no tienen `participantId` real) —**sin** "congelar" la aproximación como correcta: el test documenta el comportamiento honesto de hoy.

**🟠 Difícil (18–25)**

18. Escribe el marble test de `validateNumberEpic` para el caso debounce y ajusta los frames al `debounceTime` real del epic hasta que cuadre.
19. Escribe el marble de `switchMap`: dos números tipeados, confirma que solo el segundo produce validación y el primero **no aparece** en el diagrama esperado.
20. Marble de `takeUntil(logout$)`: confirma que el stream completa sin emitir cuando el logout llega antes del debounce.
21. Diagnóstico: te doy un marble test **verde** que igual deja pasar un bug (usa `toEqual` de payloads y no verifica el frame). Encuentra por qué no prueba el timing y arréglalo.
22. Escribe el marble de `pollingEpic` que confirme que tras `stopPolling` no hay más emisiones, y hazlo fallar borrando el `takeUntil`.
23. Diagnóstico: un test de componente pasa en local y falla en CI. La causa está en una dependencia del reloj/zona horaria de un `MetricCard` de fechas. Reproduce y propón el fix (pista: 💸 `serverNow` sin pagar).
24. Testea el rollback de `saleSlice` verificando **campo por campo** que ningún atributo del optimismo quedó pegado (status, participantId, y cualquier otro que el pending toque).
25. Escribe un test de render-count que atrape un re-render excesivo de `DashboardPage` sin abrir el Profiler (puente forense de Fase 9).

**🔴 Muy difícil (26–30)**

26. Reproduce el 🔴 intermitente de Fase 6 (acción fantasma post-logout) **primero a mano** con Redux DevTools, después escribe el marble que lo fija. Entrega ambos: la repro manual y el test.
27. Marble avanzado: `retrySellEpic` reintenta ante `timeout`/`http` pero **nunca** ante `conflict`. Escribe tres diagramas (uno por tipo de error) que prueben el comportamiento de reintento y confirmen que `conflict` no reintenta.
28. Escribe un test que demuestre que quitar el `takeUntil` de `reservationExpirationEpic` produce una suscripción viva: el marble debe mostrar una emisión de expiración *después* de que la venta ya ocurrió.
29. Diagnóstico end-to-end: te entrego un epic con `mergeMap` donde debería ir `switchMap`. Escribe el marble que revela la diferencia (con `mergeMap` aparecen ambas emisiones; con `switchMap`, solo la última) y documenta cuál es correcto para validación.
30. 🔴 Meta-test: escribe un test que falle si alguien agrega un `epicMiddleware.run` duplicado en `store.js` (doble suscripción → acciones duplicadas). Pista: cuenta cuántas veces se emite una acción por un solo trigger.

**🔥 Opcionales**

- 🔥 Configura un umbral de coverage en `react-scripts test --coverage` y discute por qué un número alto de cobertura no garantiza tests útiles.
- 🔥 Reescribe un test de componente usando MSW en vez de `cy.intercept`/mock manual, y compara la ergonomía. (No se adopta en el stack; es exploración.)
- 🔥 Migra un marble test de `rxjs-marbles` a `TestScheduler` "pelado" (sin el wrapper) y compara legibilidad —el mismo timing, otra sintaxis.
- 🔥 Agrega un segundo smoke de Cypress: login → abrir una rifa → reservar un número, y anota qué lo hace más frágil que el happy path mínimo.

---

## 📚 8. Referencias

**Documentación oficial**
- https://testing-library.com/docs/react-testing-library/intro/ — RTL; verifica que los ejemplos sean de la línea 11.x (la API `render`/`screen`/`getBy*` es estable, pero `user-event` cambió mucho entre majors).
- https://jestjs.io/docs/26.x/getting-started — Jest **26** (fija la versión en la URL; la doc actual es de una major posterior con matchers y timers distintos).
- https://redux.js.org/usage/writing-tests — guía oficial de testing de Redux; la parte de reducers y selectores aplica directo a RTK 1.8.
- https://redux-observable.js.org/docs/recipes/WritingTests.html — testing de epics con redux-observable (base conceptual del marble test).
- https://rxjs.dev/guide/testing/marble-testing — marble testing y `TestScheduler` de RxJS; la sintaxis de diagramas es la misma que usa `rxjs-marbles`.
- https://github.com/cartant/rxjs-marbles — `rxjs-marbles`; **atención a la compatibilidad de versiones**: para RxJS 6.6.7 va rxjs-marbles 6.x, no 7.x.
- https://docs.cypress.io/app/end-to-end-testing/writing-your-first-end-to-end-test — Cypress; la sintaxis de `cy.intercept` es la moderna (evita tutoriales con `cy.route`, deprecado).

**Libros** (si aplican)
- *Testing JavaScript Applications* (Lucas da Costa) — modelo mental de la pirámide y del testing por comportamiento; agnóstico de framework.

**Video / apoyo**
- Busca "RxJS marble testing tutorial" y "Redux Toolkit testing slices" en YouTube; prioriza material que muestre RxJS 6 y Jest 26, no las majors nuevas.

**Orden de lectura sugerido:** empieza por la guía de Redux (reducers/selectores) → después RTL para componentes → después la doc de marble testing de RxJS *y* el README de rxjs-marbles en paralelo → vuelve al código de 5.7 y ajusta los frames de tus diagramas hasta que cuadren.

> ⚠️ Las URLs, títulos de sección y contenidos pueden haber cambiado desde la escritura de esta fase; verifica siempre la versión. Varios de estos sitios muestran por defecto la documentación de la **última** major (Jest 27+, RTL 14+, RxJS 7+, Cypress reciente), que difiere de las versiones fijadas del curso. Cuando un ejemplo use `jest.useFakeTimers('modern')`, `user-event` con `await`, `firstValueFrom` o `cy.intercept` con sintaxis nueva, confirma que aplique a tu versión antes de copiarlo. Como no tengo acceso a una base de datos de enlaces, es posible que alguna URL haya cambiado: si una no responde, busca el título en el sitio oficial correspondiente.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Terminaste con una red de seguridad mínima pero real: funciones puras y reducers testeados sin andamiaje, selectores cuya memoización se verifica por identidad, componentes de clase y de función testeados por su salida, epics con timing determinista vía marbles, y un smoke que confirma que el camino feliz arranca. Más importante que la cantidad de tests: internalizaste el principio **test primero, fix después**, y convertiste cada pieza forense de las fases anteriores en un assert que no se olvida.

Eso es exactamente lo que habilita la **Fase 11 — Cierre + puente a React moderno**. Con tests que verifican *comportamiento* y no *implementación*, ahora puedes discutir con red lo que significaría migrar este código legacy hacia React moderno (hooks en todos lados, React Router 6, RTK Query, RxJS 7) **sin romper nada**: los tests de esta fase son precisamente los que te dirían si una migración preservó el comportamiento. La Fase 11 cierra el recorrido y traza ese puente —qué se moderniza, qué se deja, y cómo los tests de la Fase 10 son la condición previa para atreverse a tocarlo.

> **La señal de que quedó bien:** cuando borras un `takeUntil` a propósito y el marble test falla en el frame exacto donde nace el leak —y lo restauras y vuelve a verde— sin haber abierto el Profiler ni Redux DevTools una sola vez. El bug intermitente dejó de ser intermitente: ahora es un assert.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-10-testing-minimo -m "F10 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f10: …`) y los de ejercicio su
> número (`f10 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f10/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura. Va acá abajo, fuera de la plantilla de nueve
> secciones, porque es lo que apareció al escribir la fase y no cabía adentro — y
> porque no debe competir con el cierre.

- **`rxjs-marbles` y `cypress` entran sin versión pineada a mano 💸**, lo que
  contradice §9 del `00-alcance-del-proyecto.md` ("versiones no negociables sin
  justificar"). El `package-lock.json` las resuelve, pero la contradicción está
  escrita. → O se pinean, o se justifica por qué estas dos son la excepción.
- **El smoke stubbea la red con `cy.intercept` en vez de levantar un json-server
  efímero 💸** y no tiene disparador. → Proponer uno: "cuando el smoke empiece a
  pasar con un backend roto".
- **El ejercicio 🟠 23 (el test que falla en CI por zona horaria) es el enunciado
  del incidente 20.** → Que la fase lo reserve y el cuaderno lo desarrolle, sin
  duplicar el diagnóstico en los dos lugares.
- **No hay test que cubra el pago de deuda de persistencia de Fase 3.** Que la
  sesión sobreviva al F5 sigue verificándose a mano. → Sumarlo al smoke.

### Reservas para el cuaderno de incidentes

Los IDs quedan reservados en `cuaderno-incidentes.md`, donde el enunciado ya
está redactado con sus pistas y su solución de referencia. El ID nunca se reasigna.

- **20** — *El test pasa en mi máquina y falla en la de al lado* · Testing · 🔴.
  Sale del ejercicio 🟠 23: un `MetricCard` de fechas que depende del reloj y de
  la zona horaria de quien corre el test. Es el único incidente del curso que no
  se reproduce en la aplicación sino en la suite, y por eso cierra el arco: el
  test también es código que se mantiene. Se abre acá y se cierra en Fase 11.
