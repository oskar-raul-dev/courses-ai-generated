# 📊 Fase 09 — Dashboard

> Tutorial React 16 — Rifas y chances · Fase 9 de 11 · **6 horas**
> Depende de: Fase 8 — Liquidación + cálculo de premio · Habilita: Fase 10 — Testing mínimo

---

## 🎯 1. Propósito

Desde la Fase 1 hay una ruta `/dashboard` que muestra un `<div className="alert alert-info">` prometiendo que "el dashboard con métricas y gráficos se construye en la Fase 9". Esta es la Fase 9. Toca cumplir esa promesa.

El dashboard no agrega ninguna regla de negocio nueva: **lee** datos que las fases anteriores ya dejaron en el store —rifas, estado de cada número, liquidaciones— y los presenta como cuatro indicadores y un par de gráficos. Ese "solo lee" es justo lo que lo hace valioso para mantenimiento: es la primera pantalla del curso cuyo trabajo entero es **derivar** información de un estado que ya existe, sin mutarlo. Y derivar mal —recalcular en cada render lo que no cambió, o memoizar lo que no hacía falta— es una de las causas más comunes y peor diagnosticadas de lentitud en apps React reales. Por eso la pieza forense de esta fase no es un bug de dominio: es de **performance**. Vas a aprender a ver un `useMemo` que miente, y a mover el cálculo al lugar donde de verdad tiene memoria: un selector.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `DashboardPage` reemplaza el placeholder de Fase 1 y muestra 4 KPIs reales leídos del store: números más vendidos, margen por rifa, tasa de venta y participantes recurrentes.
- [ ] Los agregados se calculan con **selectores memoizados** (`createSelector`, reselect embebido en RTK 1.8), no inline en el componente; recalculan solo cuando cambian sus entradas del store.
- [ ] Al menos dos gráficos con **chart.js** (barras de números más vendidos y de margen por rifa) integrados al ciclo de vida de React 16 sin fugar la instancia del chart al desmontar.
- [ ] El estudiante puede reproducir y diagnosticar re-renders excesivos por `useMemo` mal aplicado con el Profiler de React DevTools, y corregirlos.

---

## 🚫 3. Qué queda fuera por ahora

- **BI real** (cubos, dimensiones, agregación en servidor) → nunca en este curso; el dashboard es cálculo en el cliente sobre un store chico.
- **Drill-down** (click en una barra → detalle filtrado) → fuera de alcance; se sugiere como ejercicio 🔥.
- **Series temporales "liquidaciones por día"** → difuminado a propósito: agrupar por fecha reabre el 💸 de `serverNow` (reloj cliente vs servidor, heredado de Fase 7) porque `settledAt` se compararía contra el reloj local. Si aparece, va como 🔥 con esa advertencia.
- **Export a CSV/PDF del dashboard** → fuera de alcance; ejercicio 🔥.
- **Slice propio de dashboard** → no hace falta: los KPIs son cálculo derivado sobre slices existentes (ver §4). No se agrega estado nuevo al store.

---

## 🧠 4. Conceptos mínimos

### El dashboard no tiene datos propios: los deriva

Todo lo que el dashboard muestra ya vive en el store gracias a fases anteriores. La tabla de correspondencia es la base de esta fase:

| KPI | Fuente en el store | Selector base heredado |
|---|---|---|
| Números más vendidos | `state.sales.byNumber` (los `'sold'`) | `selectStatusCounts` (Fase 5) |
| Margen por rifa | `state.settlements.byRaffleId` (`margin`, centavos) | `selectSettlement(raffleId)` (Fase 8) |
| Tasa de venta | `state.sales.byNumber` (vendidos / total) | `selectStatusCounts` (Fase 5) |
| Participantes recurrentes | `participantId` repetidos entre los `'sold'` | — (se deriva, ver 💸 abajo) |

No hay slice nuevo, no hay thunk nuevo, no hay epic. El dashboard **lee**. La única llamada de red que podría hacer es asegurarse de que las liquidaciones estén cargadas (`GET /settlements` sobre `apiClient`, puerto 3001 —nunca la lotería del 3002), pero incluso eso lo hace reutilizando lo que Fase 8 ya montó.

### Dónde vive la memoria del cálculo: selector, no componente

Éste es el concepto central de la fase, y la razón de su pieza forense.

Un componente funcional se vuelve a ejecutar entero en cada render. Si dentro escribís `const topNumbers = computeTopNumbers(byNumber)`, ese cálculo corre **cada vez que el componente renderiza**, aunque `byNumber` no haya cambiado. La tentación inmediata es envolverlo en `useMemo(() => computeTopNumbers(byNumber), [byNumber])`. Y a veces está bien. Pero `useMemo` tiene dos problemas que la gente subestima: su caché es **local a esa instancia del componente** (si dos componentes piden el mismo cálculo, se computa dos veces) y **se pierde al desmontar** (si navegás afuera del dashboard y volvés, se recalcula desde cero). Además, es fácil poner mal las dependencias y que memoice contra un array que se recrea en cada render —con lo cual no memoiza nada y solo agregaste ruido.

`createSelector` (de reselect, que viene embebido en Redux Toolkit 1.8 —no instalás nada) resuelve esto poniendo la memoria **en el selector, junto al store**, no en el componente:

```javascript
import { createSelector } from '@reduxjs/toolkit';

// Selectores de entrada: baratos, solo leen una rama del store.
const selectByNumber = (state) => state.sales.byNumber;

// Selector memoizado: la función pesada solo corre si selectByNumber
// devuelve una referencia distinta a la de la vez anterior.
export const selectTopSoldNumbers = createSelector(
  [selectByNumber],
  (byNumber) => computeTopNumbers(byNumber) // corre solo cuando byNumber cambia
);
```

La diferencia con `useMemo` es de **ubicación de la caché**, y por eso importa para mantenimiento: la memoria del selector es global al store y sobrevive a que el componente se monte y desmonte. Dos componentes que llamen `useSelector(selectTopSoldNumbers)` comparten el mismo resultado memoizado. La regla que te llevás: **el agregado del dominio se memoiza en un selector; `useMemo` queda para lo que es genuinamente local al render** (derivar props para chart.js, estabilizar un handler con `useCallback`, formatear para mostrar).

> ⚠️ **La trampa de `createSelector`.** Su memoización es de un solo nivel y compara referencias. Si un selector de entrada devuelve un objeto o array **nuevo cada vez** (por ejemplo `(state) => Object.values(state.sales.byNumber)`), el selector de salida recalcula siempre y la memoización no sirve de nada. Los selectores de entrada deben devolver referencias estables del store (`state.x.y`), no valores derivados al vuelo. Este error es la contracara exacta del `useMemo` mal aplicado, y los dos aparecen en la pieza forense.

### chart.js 2.x dentro de React 16

El stack fija **chart.js** (D12; no recharts). En un proyecto React 16 con CRA 4, chart.js es una librería imperativa: le das un elemento `<canvas>` y una config, y te devuelve una instancia que dibuja. React, en cambio, es declarativo. El puente entre ambos mundos es el patrón clásico de "wrappear una librería imperativa":

- un `useRef` al `<canvas>`,
- un `useRef` que guarda **la instancia del chart** (no va en el estado: no es serializable ni provoca render),
- un `useEffect` que **crea** el chart al montar y **lo destruye** (`chart.destroy()`) en el cleanup,
- y —si los datos cambian— actualizar la instancia existente en vez de recrearla.

Olvidar el `chart.destroy()` del cleanup es una fuga real: cada vez que el componente se re-monta, queda una instancia vieja de chart.js con sus listeners colgados. Es el equivalente en esta fase a la "suscripción que no se cancela" que perseguiste en los epics de Fase 6, solo que del lado de una librería de UI.

> Nota de compatibilidad: este curso usa la API de chart.js **2.x** (constructor `new Chart(ctx, config)` con `config.data` / `config.options`). chart.js 3+ cambió imports y opciones; si instalás una versión moderna, el código de §5 no aplica tal cual. Fijá la versión en `package-lock.json` como manda D7 y no la muevas sin justificar.

### El dinero sigue siendo entero en centavos

Fase 8 dejó una frontera clara: el dinero se guarda y se suma como **enteros de centavos**, y se formatea **una sola vez, al final**, con `formatCents` (en `src/features/settlements/money.js`). El dashboard hereda esa regla sin excepción: cuando sume márgenes de varias rifas, suma enteros; cuando lo muestre, formatea el total. Formatear cada parte y después "sumar" strings es el bug de agregación que la pieza forense de la nota de continuidad anticipó. `formatCents` **lanza si recibe un float** —es una alarma deliberada, no la desactives.

---

## 💻 5. Implementación y código comentado

Distinguimos con claridad las cuatro capas, aunque esta fase casi no toca dos de ellas:

- **backend:** nada nuevo. El dashboard consume `GET /settlements` y los datos ya cargados de ventas y rifas.
- **epic:** nada. El dashboard no tiene asincronía propia que justifique un epic.
- **store:** ningún slice nuevo; solo **selectores derivados** sobre `raffleSlice`, `saleSlice` y `settlementSlice`.
- **frontend:** los componentes de página, tarjetas y gráficos.

### 5.1 Cálculos puros — `src/features/dashboard/dashboardMath.js`

Igual que Fase 8 separó la aritmética del dinero en `settlementMath.js`, acá separamos la lógica de agregación en funciones puras, sin React ni Redux. Puras = testeables solas en Fase 10.

```javascript
// src/features/dashboard/dashboardMath.js

/**
 * Cuenta cuántas veces se vendió cada número y devuelve el top N.
 * @param {Record<string, string>} byNumber - mapa '0347' -> 'available' | 'reserved' | 'sold'
 * @param {number} limit - cuántos devolver
 * @returns {Array<{ number: string, count: number }>}
 *
 * Nota: en el modelo actual un número se vende UNA vez por rifa (unicidad
 * estricta de Fase 5), así que "más vendidos" sobre una sola rifa es 0 o 1.
 * Esta función queda general a propósito para cuando el dashboard agregue
 * varias rifas (ver ejercicio 🔴 26): ahí el conteo por número > 1 sí aparece.
 */
export function computeTopNumbers(byNumber, limit = 10) {
  const counts = [];
  for (const number in byNumber) {
    if (byNumber[number] === 'sold') {
      counts.push({ number, count: 1 });
    }
  }
  // orden estable: primero por count desc, después por número asc
  counts.sort((a, b) => b.count - a.count || a.number.localeCompare(b.number));
  return counts.slice(0, limit);
}

/**
 * Tasa de venta = vendidos / total de números del tablero.
 * @param {{ available: number, reserved: number, sold: number }} statusCounts
 * @returns {number} fracción entre 0 y 1 (no porcentaje; el formateo es de UI)
 */
export function computeSalesRate(statusCounts) {
  const total =
    statusCounts.available + statusCounts.reserved + statusCounts.sold;
  if (total === 0) return 0; // sin números todavía: evita dividir por cero
  return statusCounts.sold / total;
}

/**
 * Suma de márgenes de todas las liquidaciones. TODO en centavos enteros.
 * @param {Record<number, { margin: number }>} byRaffleId
 * @returns {number} margen total en centavos (puede ser negativo: la casa perdió)
 */
export function computeTotalMargin(byRaffleId) {
  let total = 0;
  for (const raffleId in byRaffleId) {
    // sumamos enteros de centavos; nunca floats, nunca formateamos acá
    total += byRaffleId[raffleId].margin;
  }
  return total;
}

/**
 * Participantes recurrentes: participantId que aparece en 2+ números vendidos.
 * @param {Array<{ participantId: number | null }>} soldEntries
 * @returns {number} cantidad de participantes con más de una compra
 */
export function computeRecurringParticipants(soldEntries) {
  const byParticipant = {};
  for (const entry of soldEntries) {
    if (entry.participantId == null) continue; // placeholder sin comprador real
    byParticipant[entry.participantId] =
      (byParticipant[entry.participantId] || 0) + 1;
  }
  let recurring = 0;
  for (const id in byParticipant) {
    if (byParticipant[id] > 1) recurring += 1;
  }
  return recurring;
}
```

> 💸 **Deuda técnica intencional — participantes recurrentes es una aproximación.** No existe un slice de participantes (Fase 5 lo dejó explícito: una venta guarda a lo sumo un `participantId` placeholder, sin formulario de comprador). Contamos recurrencia sobre esos ids embebidos en las ventas. Cuando el curso agregue participantes reales (fuera de alcance acá), este KPI debe recalcularse contra ese slice, no contra las ventas. Se marca para que nadie lo tome como definitivo.

### 5.2 Selectores memoizados — `src/features/dashboard/dashboardSelectors.js`

Acá vive la memoria de los cálculos. Cada `createSelector` toma selectores de entrada **estables** (leen una rama del store) y una función de salida que solo corre cuando alguna entrada cambia de referencia.

```javascript
// src/features/dashboard/dashboardSelectors.js
import { createSelector } from '@reduxjs/toolkit';
import {
  computeTopNumbers,
  computeSalesRate,
  computeTotalMargin,
  computeRecurringParticipants,
} from './dashboardMath';
import { selectStatusCounts } from '../sales/saleSlice';

// --- Selectores de entrada: baratos, referencia estable del store ---
// Devuelven state.x.y directamente. NO derivan valores nuevos acá dentro:
// si devolvieran un array/objeto nuevo, romperían la memoización de abajo.
const selectByNumber = (state) => state.sales.byNumber;
const selectSettlementsById = (state) => state.settlements.byRaffleId;

// --- Números más vendidos ---
export const selectTopSoldNumbers = createSelector(
  [selectByNumber],
  (byNumber) => computeTopNumbers(byNumber, 10)
);

// --- Tasa de venta ---
// selectStatusCounts YA es un selector de Fase 5. Ojo: si NO estuviera
// memoizado y devolviera un objeto nuevo cada vez, este createSelector
// recalcularía siempre. Ver la nota de la §4 y el ejercicio 🟠 22.
export const selectSalesRate = createSelector(
  [selectStatusCounts],
  (statusCounts) => computeSalesRate(statusCounts)
);

// --- Margen total (centavos enteros) ---
export const selectTotalMargin = createSelector(
  [selectSettlementsById],
  (byRaffleId) => computeTotalMargin(byRaffleId)
);

// --- Margen por rifa: lista lista para graficar ---
export const selectMarginByRaffle = createSelector(
  [selectSettlementsById],
  (byRaffleId) =>
    Object.keys(byRaffleId).map((raffleId) => ({
      raffleId: Number(raffleId),
      margin: byRaffleId[raffleId].margin, // centavos; se formatea al render
    }))
);

// --- Cantidad de liquidaciones cerradas ---
export const selectSettledCount = createSelector(
  [selectSettlementsById],
  (byRaffleId) => Object.keys(byRaffleId).length
);

// --- Participantes recurrentes (aproximación, ver 💸 en 5.1) ---
export const selectRecurringParticipants = createSelector(
  [selectByNumber],
  (byNumber) => {
    // reconstruimos las entradas vendidas; en el modelo actual byNumber
    // solo guarda el status, no el participantId, así que esta derivación
    // es la parte más floja del KPI (ver 💸). Cuando exista participantSlice
    // esto se reemplaza por una lectura directa de ese slice.
    const soldEntries = [];
    for (const number in byNumber) {
      if (byNumber[number] === 'sold') {
        soldEntries.push({ participantId: null }); // placeholder honesto
      }
    }
    return computeRecurringParticipants(soldEntries);
  }
);
```

> 💸 **Segunda cara del mismo 💸.** `selectRecurringParticipants` no puede hacer más que Fase 5 le permite: `byNumber` no lleva `participantId`. El selector queda escrito para el día en que sí lo lleve (o exista un slice de participantes); hoy devuelve 0 con honestidad en vez de inventar un número. Es preferible un KPI que dice "0 recurrentes" y un 💸 visible, que uno que miente con datos que no tiene.

### 5.3 El wrapper de chart.js — `src/features/dashboard/BarChart.jsx`

Un único wrapper de barras, reutilizable para los dos gráficos. Encapsula todo el ciclo de vida imperativo de chart.js para que el resto del dashboard no lo vea.

```javascript
// src/features/dashboard/BarChart.jsx
import React, { useRef, useEffect } from 'react';
import Chart from 'chart.js'; // chart.js 2.x: default export es el constructor

/**
 * Wrapper declarativo sobre chart.js 2.x para un gráfico de barras.
 * @param {{ labels: string[], values: number[], label: string }} props
 */
export default function BarChart({ labels, values, label }) {
  const canvasRef = useRef(null);
  // La instancia del chart va en un ref, NO en estado: no es serializable
  // y no queremos que provoque re-render. Mismo criterio que los ids de
  // setTimeout de Fase 5, que tampoco viven en el store.
  const chartRef = useRef(null);

  // Efecto 1: crear una vez al montar, destruir al desmontar.
  useEffect(() => {
    const ctx = canvasRef.current.getContext('2d');
    chartRef.current = new Chart(ctx, {
      type: 'bar',
      data: { labels, datasets: [{ label, data: values }] },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: { yAxes: [{ ticks: { beginAtZero: true } }] }, // API 2.x
      },
    });

    // Cleanup: sin esto, cada re-montaje deja una instancia colgada con
    // sus listeners. Es la "suscripción sin cancelar" de esta fase.
    return () => {
      chartRef.current.destroy();
      chartRef.current = null;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []); // se crea una sola vez; los datos se actualizan en el efecto 2

  // Efecto 2: cuando cambian los datos, ACTUALIZAR la instancia existente
  // en vez de recrearla (recrear en cada cambio es la fuga lenta clásica).
  useEffect(() => {
    const chart = chartRef.current;
    if (!chart) return;
    chart.data.labels = labels;
    chart.data.datasets[0].data = values;
    chart.update();
  }, [labels, values]);

  return (
    <div style={{ position: 'relative', height: 280 }}>
      <canvas ref={canvasRef} data-testid="bar-chart" />
    </div>
  );
}
```

> 💸 **Deuda reconocida — un wrapper específico, no una librería de charting.** `BarChart` cubre lo que esta fase necesita (barras) y nada más. Un wrapper genérico (`Chart` que acepte `type`, ejes configurables, tooltips custom) es más prolijo pero es sobre-ingeniería para dos gráficos. Si el dashboard crece a cinco tipos de gráfico, extraé el genérico entonces —no antes. Marcado para que la decisión sea consciente.

### 5.4 La tarjeta de KPI — `src/features/dashboard/MetricCard.jsx`

Un componente de presentación puro. Recibe título y valor **ya formateados** y los muestra. No calcula nada: esa es justamente la línea que separa "presentación" de "derivación".

```javascript
// src/features/dashboard/MetricCard.jsx
import React from 'react';

/**
 * Tarjeta de un indicador. Puramente presentacional.
 * @param {{ title: string, value: string, hint?: string }} props
 */
function MetricCard({ title, value, hint }) {
  return (
    <div className="card h-100" data-testid="metric-card">
      <div className="card-body">
        <h6 className="card-subtitle mb-2 text-muted">{title}</h6>
        <p className="card-text h3 mb-0">{value}</p>
        {hint && <small className="text-muted">{hint}</small>}
      </div>
    </div>
  );
}

// React.memo: la tarjeta solo re-renderiza si sus props cambian.
// Como recibe strings ya formateados, la comparación superficial basta.
export default React.memo(MetricCard);
```

### 5.5 La página — `src/features/dashboard/DashboardPage.jsx`

Reemplaza el placeholder `Dashboard.jsx` que Fase 1 dejó en `src/pages/`. Orquesta: lee del store vía los selectores memoizados, formatea para mostrar, y reparte a las tarjetas y gráficos. Fijate qué **poco** cálculo hay acá dentro: casi todo ya vino resuelto y memoizado desde los selectores.

```javascript
// src/features/dashboard/DashboardPage.jsx
import React, { useMemo } from 'react';
import { useSelector } from 'react-redux';
import { formatCents } from '../settlements/money';
import MetricCard from './MetricCard';
import BarChart from './BarChart';
import {
  selectTopSoldNumbers,
  selectSalesRate,
  selectTotalMargin,
  selectMarginByRaffle,
  selectSettledCount,
  selectRecurringParticipants,
} from './dashboardSelectors';

export default function DashboardPage() {
  // Cada useSelector consume un selector YA memoizado: el cálculo pesado
  // no corre en este render salvo que su rama del store haya cambiado.
  const topNumbers = useSelector(selectTopSoldNumbers);
  const salesRate = useSelector(selectSalesRate);
  const totalMargin = useSelector(selectTotalMargin);
  const marginByRaffle = useSelector(selectMarginByRaffle);
  const settledCount = useSelector(selectSettledCount);
  const recurring = useSelector(selectRecurringParticipants);

  // useMemo AQUÍ sí corresponde: derivamos props para chart.js a partir
  // de datos ya memoizados. Es transformación LOCAL de render (dar forma a
  // labels/values), no el agregado del dominio —ese ya vive en el selector.
  const topNumbersChart = useMemo(
    () => ({
      labels: topNumbers.map((n) => n.number),
      values: topNumbers.map((n) => n.count),
    }),
    [topNumbers]
  );

  const marginChart = useMemo(
    () => ({
      labels: marginByRaffle.map((m) => `Rifa #${m.raffleId}`),
      // chart.js grafica números; pasamos centavos a pesos SOLO para el eje.
      // El formateo "bonito" con separadores va en el tooltip/tarjeta, no acá.
      values: marginByRaffle.map((m) => m.margin / 100),
    }),
    [marginByRaffle]
  );

  return (
    <div>
      <h1 className="mb-4">Dashboard</h1>

      <div className="row mb-4">
        <div className="col-md-3 mb-3">
          <MetricCard
            title="Tasa de venta"
            value={`${(salesRate * 100).toFixed(1)}%`}
            hint="Vendidos sobre el total del tablero"
          />
        </div>
        <div className="col-md-3 mb-3">
          <MetricCard
            title="Margen total"
            // sumamos enteros en el selector; formateamos UNA vez, acá
            value={formatCents(totalMargin)}
            hint="Suma de márgenes liquidados"
          />
        </div>
        <div className="col-md-3 mb-3">
          <MetricCard
            title="Rifas liquidadas"
            value={String(settledCount)}
          />
        </div>
        <div className="col-md-3 mb-3">
          <MetricCard
            title="Participantes recurrentes"
            value={String(recurring)}
            hint="2+ compras (aproximado)"
          />
        </div>
      </div>

      <div className="row">
        <div className="col-md-6 mb-4">
          <div className="card">
            <div className="card-header">Números más vendidos</div>
            <div className="card-body">
              <BarChart
                labels={topNumbersChart.labels}
                values={topNumbersChart.values}
                label="Veces vendido"
              />
            </div>
          </div>
        </div>
        <div className="col-md-6 mb-4">
          <div className="card">
            <div className="card-header">Margen por rifa</div>
            <div className="card-body">
              <BarChart
                labels={marginChart.labels}
                values={marginChart.values}
                label="Margen (pesos)"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
```

### 5.6 Conectar la ruta

Fase 1 registró `/dashboard` apuntando al placeholder `src/pages/Dashboard.jsx`. El cambio es de una línea: apuntar la ruta al componente real. No se toca el router ni el resto de la navegación.

```javascript
// src/pages/Dashboard.jsx
// El placeholder de Fase 1 ahora solo reexporta el dashboard real.
// (Alternativa: cambiar el import en el router directamente a
//  features/dashboard/DashboardPage y borrar este archivo. Se deja el
//  reexport para no tocar el router y mantener el diff mínimo —criterio
//  de hotfix: cambiar lo menos posible.)
export { default } from '../features/dashboard/DashboardPage';
```

> Éste es un buen momento para practicar el reflejo de mantenimiento: entre "cambio el import del router" y "dejo un reexport", elegí el diff más chico que no confunda al próximo que lea el código. Un reexport de una línea con comentario es defendible; un archivo placeholder que sigue "pareciendo" el dashboard real, no. Marcalo o borralo, no lo dejes ambiguo.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. `useMemo` con dependencias que se recrean → memoización fantasma.**
*Síntoma:* metiste `useMemo` "para optimizar" y el Profiler muestra que el cálculo corre igual en cada render. *Causa:* la dependencia es un array/objeto que se crea nuevo en cada render (por ejemplo `useMemo(() => f(list), [list])` donde `list = data.filter(...)` se calcula arriba, sin memoizar). Cada render `list` es una referencia nueva, así que `useMemo` invalida su caché siempre. *Fix mínimo:* mové el agregado a un `createSelector` (referencia estable garantizada por el store) o memoizá también la dependencia intermedia. La refactorización correcta es la primera: el cálculo del dominio no debería estar en el componente.

**2. Olvidar `chart.destroy()` en el cleanup.**
*Síntoma:* navegás a `/dashboard`, salís, volvés, repetís; la pestaña se pone lenta y la memoria sube. *Causa:* cada montaje crea una instancia de chart.js y ninguna se destruye. *Fix mínimo:* el `return () => chartRef.current.destroy()` del `useEffect`. Es la misma disciplina de cancelación que los epics de Fase 6, aplicada a una librería de UI.

**3. Formatear antes de sumar (bug de agregación de dinero).**
*Síntoma:* el "margen total" muestra algo absurdo o `NaN`. *Causa:* formateaste cada margen a string y después intentaste sumarlos, o mezclaste pesos con centavos. *Fix mínimo:* sumá enteros de centavos con el selector (`computeTotalMargin`) y llamá `formatCents` **una sola vez** sobre el total. Regla heredada de Fase 8, sin excepciones.

**4. Recrear el chart en cada cambio de datos en vez de actualizarlo.**
*Síntoma:* el gráfico "parpadea" al cambiar datos y el rendimiento cae con actualizaciones frecuentes. *Causa:* pusiste la creación del chart en un `useEffect` con `[labels, values]` en las dependencias, así que se destruye y recrea entero cada vez. *Fix:* separá creación (una vez, `[]`) de actualización (`chart.update()` con `[labels, values]`), como en §5.3.

### Pieza forense de esta fase — performance del dashboard: `useMemo` mal aplicado

Ver **Forense — Fase 09** y los incidentes 🟠 de performance / re-renders excesivos del cuaderno.

La habilidad que entrena esta fase no es "poner `useMemo` en todos lados" —eso es cómo se **crea** el problema— sino **leer el Profiler y decidir si un cálculo se está repitiendo sin necesidad, y dónde debería vivir su caché**. Flujo de diagnóstico:

1. Abrí **React DevTools → Profiler**, activá "Record", interactuá con el dashboard (cambiá de rifa, vendé un número en otra pestaña, volvé) y frená la grabación.
2. Mirá qué componentes re-renderizaron y **por qué** (el Profiler te dice si fue por props, estado o el padre). Un `DashboardPage` que re-renderiza cuando cambió una rama del store que no usa es una señal.
3. Poné un `console.count('computeTopNumbers')` dentro de la función pura (temporalmente) y confirmá cuántas veces corre por interacción. Con el selector memoizado, debería correr **solo** cuando `byNumber` cambia.

> 🧪 **Ejercicio de "rompe a propósito y observa".** Reemplazá el `useSelector(selectTopSoldNumbers)` de `DashboardPage` por el cálculo inline: `const topNumbers = computeTopNumbers(useSelector((s) => s.sales.byNumber))` envuelto en un `useMemo` con una dependencia mal puesta —por ejemplo `useMemo(() => computeTopNumbers(byNumber), [Object.values(byNumber)])` (un array nuevo en cada render). Grabá el Profiler y mirá con el `console.count` cómo `computeTopNumbers` ahora corre en **cada** render, aunque nada haya cambiado. Después revertí al selector y confirmá que vuelve a correr solo cuando toca. Ese contraste —el mismo cálculo, memoizado bien y memoizado mal— es la lección entera de la fase.

---

## 🧪 7. Ejercicios (28)

**🟢 Fácil (1–8)**
1. Levantá la app, entrá a `/dashboard` y confirmá que el placeholder de Fase 1 fue reemplazado por las cuatro tarjetas y los dos gráficos. Verificá en el DOM que existe `data-testid="metric-card"` cuatro veces.
2. Cambiá el `limit` de `selectTopSoldNumbers` de 10 a 5 y confirmá que el gráfico de números más vendidos muestra a lo sumo cinco barras.
3. Agregá una quinta `MetricCard` que muestre el total de números vendidos usando `selectStatusCounts`. No agregues un selector nuevo si uno existente ya te da el dato.
4. Cambiá el color de las barras del `BarChart` pasando `backgroundColor` en el `dataset`. Confirmá que ambos gráficos cambian (comparten wrapper) y decidí si eso es lo que querés.
5. Identificá en el código por qué la instancia del chart vive en un `useRef` y no en `useState`. Escribilo en una frase.
6. Provocá el estado "sin datos": arrancá con `byNumber` vacío y confirmá que `computeSalesRate` devuelve 0 y no `NaN`. Localizá la guarda que lo evita.
7. Agregá un JSDoc completo a `DashboardPage` describiendo qué selectores consume y qué NO calcula por sí mismo.
8. Con la app corriendo, abrí React DevTools y confirmá que `MetricCard` está envuelto en `React.memo` (aparece como "Memo" en el árbol).

**🟡 Intermedio (9–18)**
9. Escribí un selector `selectAvailableCount` con `createSelector` sobre `selectStatusCounts` y usalo en una tarjeta. Explicá por qué usar `createSelector` acá es casi cosmético (la entrada ya está memoizada) pero mantiene consistencia.
10. Movete a `/dashboard` y a otra ruta varias veces con el Profiler grabando. Confirmá que no se acumulan instancias de chart.js (agregá un `console.count` en el `useEffect` de creación y otro en el cleanup: deben ir parejos).
11. Hacé que el gráfico de margen por rifa muestre en rojo las barras con margen negativo y en verde las positivas. El margen negativo es dato válido (Fase 8), no lo escondas.
12. Formateá el eje del gráfico de margen con separador de miles usando `formatCents` en un callback de tick de chart.js. Cuidado: `formatCents` espera centavos enteros, el eje ya está en pesos —resolvé la conversión sin reintroducir floats en la suma.
13. Agregá un `useCallback` para un handler de click en una barra (por ahora solo `console.log` del número) y explicá por qué `useCallback` acá sí aporta (estabilidad de referencia hacia un hijo memoizado).
14. Reproducí el error común #3 a propósito: formateá cada margen con `formatCents` y después concatená los strings. Observá el resultado y explicá por qué `formatCents` no te "salvó".
15. Agregá un estado de carga: si `state.settlements.loading` es true, mostrá un spinner en lugar de las tarjetas de dinero. Reutilizá `selectSettlementLoading` de Fase 8.
16. Escribí un test manual documentado (en comentario, no Jest todavía —eso es Fase 10) que describa cómo verificar que `selectTotalMargin` solo recalcula cuando cambia `state.settlements.byRaffleId`.
17. Agregá `data-testid` descriptivos a los dos gráficos (`top-numbers-chart`, `margin-by-raffle-chart`) para que Fase 10 pueda seleccionarlos. Respetá kebab-case.
18. Explicá con tus palabras la diferencia entre dónde cachea `useMemo` y dónde cachea `createSelector`, y da un caso donde la diferencia se nota (pista: dos componentes pidiendo el mismo agregado).

**🟠 Difícil (19–24)**
19. **Diagnóstico:** te entregan un `DashboardPage` donde `computeTopNumbers` corre en cada render. Con el Profiler y un `console.count`, localizá si la causa es un `useMemo` con dependencia inestable o un selector de entrada que devuelve un array nuevo. Aplicá el fix mínimo y confirmá la mejora.
20. **Diagnóstico:** en un repo modificado, el gráfico de margen "parpadea" y la memoria sube al cambiar de rifa. Identificá que el `useEffect` de creación tiene `[labels, values]` en dependencias (recrea el chart siempre) y separalo en creación + actualización.
21. **Diagnóstico:** una `MetricCard` re-renderiza en cada tick aunque su valor no cambia. Descubrí que el padre le pasa un objeto nuevo como prop (rompe `React.memo`) y corregilo pasando primitivos ya formateados.
22. Rompé a propósito la memoización de `selectSalesRate` haciendo que `selectStatusCounts` devuelva un objeto nuevo cada vez (por ejemplo agregando `{ ...counts }`). Con el Profiler mostrá que `computeSalesRate` ahora corre siempre, y explicá por qué la culpa es del selector de entrada, no de `createSelector`.
23. Medí con el Profiler el costo de renderizar el dashboard con 50 rifas liquidadas mockeadas vs 1. Identificá si el cuello es el cálculo (selectores) o el render (chart.js) y justificá con datos del Profiler.
24. El `raffleSlice` guarda las rifas en un array `items` (sin normalizar, 💸 heredado de Fase 8). Si el dashboard cruza margen por rifa **con el nombre** de la rifa, cada lookup es un `find` O(n). Implementá el cruce y medí si a 50 rifas el `find` importa. ¿Vale normalizar acá o es prematuro?

**🔴 Muy difícil (25–28)**
25. **Diagnóstico end-to-end:** te reportan "el dashboard se pone lento después de usar la app un rato". Reproducí (navegá dentro/fuera de `/dashboard` 20 veces), diagnosticá con Profiler + pestaña Memory de Chrome DevTools que son instancias de chart.js sin destruir, corregí el cleanup, y escribí el post-mortem (síntoma → reproducción → evidencia → causa raíz → corrección → regresión → prevención) sin culpabilizar.
26. Extendé el dashboard para agregar **varias rifas a la vez** (no solo la activa): números más vendidos globales sumando el `byNumber` de todas. Vas a necesitar que las ventas de varias rifas convivan en el store —diseñá el cambio mínimo de shape sin romper Fase 5, o justificá por qué es un refactor mayor y proponé el plan.
27. Construí un selector `createSelector` **parametrizado** por `raffleId` (margen de UNA rifa) y explicá por qué la memoización ingenua de reselect falla cuando lo llamás con ids distintos en el mismo render (caché de tamaño 1). Proponé la solución (factory de selectores o `createSelector` por instancia) sin traer una librería nueva sin justificar.
28. **Race sutil de datos:** el dashboard puede montar antes de que `GET /settlements` haya resuelto, mostrando "margen total: $0" que después salta al valor real. Diagnosticá si es un bug o un estado de carga legítimo, y resolvelo mostrando carga en vez de un cero engañoso. Distinguí en tu respuesta qué parte es de frontend (mostrar spinner), de store (flag `loading`) y de backend (cuándo responde la liquidación).

**🔥 Opcionales**
- 🔥 Drill-down: click en una barra de "números más vendidos" filtra una tabla debajo con los participantes de ese número. (Requiere resolver el 💸 de participantes primero.)
- 🔥 Serie temporal "liquidaciones por día" agrupando por `settledAt`. Antes de empezar, explicá por qué esto reabre el 💸 de `serverNow` (reloj cliente vs servidor) heredado de Fase 7.
- 🔥 Export del dashboard a CSV (los KPIs) sin librería nueva, generando el CSV a mano desde los selectores.
- 🔥 Reemplazá `BarChart` específico por un wrapper genérico configurable por `type`. Documentá qué ganaste y qué complejidad agregaste —y si a dos gráficos valía la pena.

---

## 📚 8. Referencias

**Documentación oficial**
- https://reactjs.org/docs/hooks-reference.html#usememo — `useMemo` y `useCallback` (docs de React 16; la API no cambió en 16.8+).
- https://reactjs.org/docs/react-api.html#reactmemo — `React.memo` (React 16.6+).
- https://redux-toolkit.js.org/api/createSelector — `createSelector` reexportado por RTK (envuelve reselect; RTK 1.8.x).
- https://github.com/reduxjs/reselect#readme — reselect: cómo funciona la memoización de un nivel y la caché de tamaño 1 (clave para el ejercicio 🔴 27).
- https://www.chartjs.org/docs/2.9.4/ — chart.js **2.x** (API del constructor, `data`/`options`, ejes `yAxes`). ⚠️ chart.js 3+ tiene otra API.
- https://reactjs.org/blog/2018/09/10/introducing-the-react-profiler.html — React Profiler, base de la pieza forense.

**Video / apoyo**
- Buscá en YouTube "React DevTools Profiler tutorial" y "reselect createSelector explained" — hay crash courses cortos y buenos. Verificá que usen React 16 / reselect clásico, no APIs nuevas.

**Orden de lectura sugerido:** `useMemo`/`React.memo` (para entender qué memoiza el componente) → `createSelector` + README de reselect (para entender dónde vive la otra caché y por qué es distinta) → docs de chart.js 2.x (solo la sección de bar chart y lifecycle) → volver al `dashboardSelectors.js` de la §5.2, que es el corazón de la fase.

> ⚠️ URLs, versiones y contenidos pueden estar desactualizados o haber cambiado de lugar; verificá cada enlace y confirmá que la versión que muestra coincide con el stack fijado. En particular, la doc de chart.js suele mostrar por defecto la versión más nueva (3/4): asegurate de estar leyendo la **2.x**. No tengo acceso a una base de datos de enlaces en vivo y podría equivocarme en una URL: comprobalas antes de fiarte.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Cerraste el flujo de la aplicación: de crear una rifa (Fase 4) a venderla (Fase 5), orquestarla con epics (Fase 6), cerrarla por hora y traer su resultado (Fase 7), liquidarla sin un centavo de más (Fase 8) y ahora **verla entera de un vistazo** (Fase 9). Y lo hiciste sin agregar una regla de negocio: solo derivando, con la memoria del cálculo puesta en el lugar correcto —el selector— y `useMemo` reservado para lo que de verdad es local al render.

Eso te deja perfectamente parado para la **Fase 10 — Testing mínimo**. No es casualidad que el testing venga después del dashboard: los selectores puros (`dashboardMath.js`, `dashboardSelectors.js`) son lo más fácil y agradecido de testear en todo el curso —entra un objeto, sale un número, sin red ni tiempo ni React. Son el mejor primer test unitario que vas a escribir, y el contraste con testear un epic (que sí tiene tiempo, y necesita marbles) va a hacer que entiendas de una por qué cada cosa se testea distinto. El dashboard es, además, una superficie ideal para un test de componente con React Testing Library: renderizás con un store mockeado y verificás que las cuatro tarjetas muestran los valores esperados.

> **La señal de que quedó bien:** cuando abrís el Profiler, interactuás con el dashboard, y los cálculos pesados **no corren** salvo cuando su dato de origen cambió —ni una vez de más. Cuando podés señalar, para cada número en pantalla, exactamente de qué rama del store salió y qué selector lo derivó. Cuando el dashboard se siente instantáneo no porque optimizaste todo, sino porque no hiciste trabajo que no hacía falta.
