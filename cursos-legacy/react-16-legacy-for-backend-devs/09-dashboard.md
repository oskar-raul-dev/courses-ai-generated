# 📊 Fase 09 — Dashboard

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · Fase 9 de 11 · **6 horas**
> Depende de: Fase 8 — Conciliación · Habilita: Fase 10 — Testing mínimo

---

## 🎯 1. Propósito

Antes de contestar la reseña de *"la rueda está arreglada"*, Itzel quiere verlo en una pantalla: cuántos giros dio una rueda, de dónde salieron —gratis, pagos, mandados a mano por soporte—, cuánto dejaron, y si cada segmento cayó cerca de lo que la tabla del juego promete (`00-historia-del-sistema.md` §5 y §8). La Fase 8 hizo la cuenta una vez, para conciliar. Esta fase la pone en un tablero que se mira todos los días.

Desde la Fase 1 hay una ruta `/dashboard` que muestra un `<div className="alert alert-info">` prometiendo que "el dashboard con métricas y gráficos se construye en la Fase 9". Esta es la Fase 9.

El tablero no agrega ninguna regla de negocio: **lee** lo que el mock ya tiene —la bitácora, los envíos manuales, el reporte de la tienda— y lo presenta como cuatro indicadores y un gráfico. Ese "solo lee" es justo lo que lo hace valioso para mantenimiento: es la primera pantalla del curso cuyo trabajo entero es **derivar** información de un estado que ya existe, sin mutarlo. Y derivar mal —recalcular en cada render lo que no cambió, o memoizar algo que no memoiza— es una de las causas más comunes y peor diagnosticadas de lentitud en una app React. Por eso la pieza forense de esta fase es de **rendimiento**: vas a ver un `useMemo` que miente, y a mover el cálculo al lugar donde de verdad tiene memoria, un selector.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `DashboardPage` reemplaza el placeholder de la Fase 1 y muestra, para la rueda que elijas, cuatro indicadores: giros (gratis y pagos), giros manuales, ingresos netos y el estado de las probabilidades.
- [ ] El gráfico **observado contra configurado**: una barra por segmento y los dos bordes de su banda de ±3σ, con chart.js 2.9.4 en modo imperativo (D12), que se destruye al desmontar.
- [ ] Los agregados se calculan en **selectores memoizados** (`createSelector`): una pasada por bitácora, no una por render. Cambiar el filtro de origen no vuelve a recorrer los giros.
- [ ] `MetricCard` muestra el instante de los datos, que le llega por props, en hora de Panamá: no consulta el reloj de la máquina.
- [ ] El store guarda la bitácora del tablero **fuera de los chequeos de desarrollo** de Toolkit, que de otro modo la recorrerían en cada acción.
- [ ] Sabes reproducir y diagnosticar con el Profiler un `useMemo` mal aplicado, y corregirlo.

---

## 🚫 3. Qué queda fuera por ahora

- **Agregar en el servidor.** El tablero baja la bitácora de la rueda y cuenta en el navegador. Con una rueda de semanas alcanza; con varias ruedas de un evento, no. La consulta agregada es `be07`. 💸
- **Series temporales** ("giros por hora de la Semana del Canal") → difuminado a propósito: agrupar por hora reabre la pregunta de la Fase 7, de quién tiene autoridad sobre el reloj. Va como 🔥, con esa advertencia.
- **Drill-down** (clic en una barra → los giros de ese segmento) → ejercicio 🔥.
- **Los giros manuales en la banda.** Son compensaciones, no giros de la rueda: se cuentan aparte y no entran en la auditoría.
- **La teoría de la banda** → `A14-estadistica-para-auditar-una-rueda.md`. Acá se dibuja.

---

## 🧠 4. Conceptos mínimos

### El tablero no tiene datos propios: los deriva

Todo lo que el tablero muestra ya existe en el mock desde fases anteriores. La tabla de correspondencia es la base de esta fase:

| Indicador | De dónde sale | Fase que lo dejó |
|---|---|---|
| Giros, gratis y pagos | la bitácora de la rueda (`spinLog`, campo `origin`) | 8 |
| Giros manuales | los envíos de soporte con premio `spin:<id>` (`grants`) | 5 |
| Ingresos netos | el reporte de la tienda: cobrado menos comisión, renglón por renglón | 8 |
| Observado contra configurado | la bitácora contada por `landedSegment`, contra los pesos | 8 |

Hay un slice nuevo, `dashboardSlice`, y es deliberadamente tonto: guarda los datos crudos que trae el thunk, y nada más. Todo lo que es un número lo derivan los selectores. Todo lo que el tablero muestre en dinero sale en **centavos** y se pinta con `formatCents` (`A10-aritmetica-de-dinero.md` §3).

### Dónde vive la memoria del cálculo: selector, no componente

Éste es el concepto central de la fase, y la razón de su pieza forense.

Un componente funcional se vuelve a ejecutar entero en cada render. Si dentro escribes `const summary = summarizeSpins(spinLog, segments)`, esa pasada sobre la bitácora corre **cada vez que el componente renderiza**, aunque la bitácora no haya cambiado. La tentación inmediata es envolverla en `useMemo`. Y a veces está bien. Pero `useMemo` tiene dos problemas que la gente subestima: su caché es **local a esa instancia del componente** (si dos componentes piden el mismo cálculo, se computa dos veces) y **se pierde al desmontar** (si sales del tablero y vuelves, se recalcula desde cero). Además, es fácil poner mal las dependencias y que memoice contra un arreglo que se recrea en cada render, con lo cual no memoiza nada y solo agregaste ruido.

`createSelector` (de reselect, que viene dentro de Redux Toolkit 1.8: no instalas nada) pone la memoria **en el selector, junto al store**:

```javascript
// --- Selectores de entrada: devuelven ramas del store tal cual (referencias estables).
// Si derivaran algo nuevo acá (un filter, un Object.values), romperían la memoria de abajo.
const selectSpinLog = (state) => state.dashboard.spinLog;
const selectSegments = (state) => state.dashboard.segments;
const selectGrantsLog = (state) => state.dashboard.grants;
const selectEarnings = (state) => state.dashboard.earnings;
const selectWheelId = (state) => state.dashboard.wheelId;

// La pasada sobre la bitácora: corre UNA vez por bitácora, no una vez por render.
export const selectSpinSummary = createSelector([selectSpinLog, selectSegments], (spinLog, segments) =>
  summarizeSpins(spinLog, segments)
);
```

La diferencia con `useMemo` es de **ubicación de la caché**, y por eso importa para mantenimiento: la memoria del selector es global al store y sobrevive a que el componente se monte y se desmonte. La regla que te llevas: **el agregado del dominio se memoiza en un selector; `useMemo` queda para lo que es genuinamente local al render** (dar forma a las props de chart.js, estabilizar un handler).

> ⚠️ **La trampa de `createSelector`.** Su memoria es de un solo nivel y compara referencias. Si un selector de entrada devuelve un objeto o un arreglo **nuevo cada vez** —por ejemplo `(state) => Object.values(state.dashboard.spinLog)`—, el selector de salida recalcula siempre y la memoización no sirve de nada. Los selectores de entrada devuelven ramas del store tal cual. Este error es la contracara exacta del `useMemo` mal aplicado, y los dos aparecen en la pieza forense.

### Una rama grande del store y los chequeos de desarrollo

En desarrollo, `configureStore` monta dos middlewares que cuidan al equipo: uno avisa si alguien muta el estado y otro si mete algo no serializable. Los dos **recorren el estado entero en cada acción**. Con el estado de las fases anteriores, eso son microsegundos. Con la bitácora de un evento en el store —180.000 filas— son cientos de milisegundos por acción, en **todas** las pantallas, y la consola entera se arrastra. Las dos opciones aceptan `ignoredPaths`: la bitácora del tablero nadie la muta, así que se excluye de los dos, solo esa rama. En producción esos middlewares no existen; el problema es de desarrollo, y es el incidente 19.

### chart.js 2.x dentro de React 16

El stack fija **chart.js 2.9.4** (D12), sin wrapper de React. chart.js es una librería imperativa: le das un `<canvas>` y una configuración, y te devuelve una instancia que dibuja. React es declarativo. El puente entre los dos mundos es el patrón clásico:

- un `useRef` al `<canvas>`;
- un `useRef` que guarda **la instancia del gráfico** (no va en el estado: no es serializable ni debe provocar render);
- un `useEffect` que **crea** el gráfico al montar y **lo destruye** (`chart.destroy()`) en la limpieza;
- y, cuando cambian los datos, **actualizar** la instancia existente en vez de recrearla.

Olvidar el `chart.destroy()` es una fuga real: cada visita al tablero deja una instancia vieja con sus listeners colgados. Es, del lado de una librería de interfaz, la misma "suscripción que no se cancela" que perseguiste en los epics de la Fase 6.

> 📖 Las clases de Bootstrap de las tarjetas (`card`, `card-body`, `text-muted`, la grilla) están en `A1-bootstrap-4-y-sass.md` §2 y §3; los colores de estado, en `A2-mini-design-system.md` §4.

> ⚠️ **Nota de versión.** Este código usa la API de chart.js **2.x**: el constructor `new Chart(ctx, config)`, ejes en `scales.yAxes`. chart.js 3 cambió imports y opciones; un ejemplo de 3 o 4 no corre sobre 2.9.4.

### El reloj no se consulta: llega por props

`MetricCard` muestra cuándo se cargaron los datos ("Actualizado: …"). Ese instante lo pone el thunk en el store (`loadedAt`) y le llega a la tarjeta por props; la tarjeta solo lo formatea, y lo formatea **en hora de Panamá** de forma explícita, porque la hora de Panamá es solo de presentación (historia §9). Una tarjeta que llamara a `new Date()` adentro y formateara en la zona de la máquina mostraría cosas distintas en dos computadoras, y su prueba pasaría en una y fallaría en la otra. Es el incidente 20, y por eso la tarjeta no lo hace.

---

## 💻 5. Implementación y código comentado

Las cuatro capas, aunque esta fase casi no toca dos:

- **backend (mock):** nada nuevo en las rutas. La siembra de la Fase 8 suma una bandera, `--event`, para tener el volumen de un evento.
- **epic:** nada. El tablero no tiene asincronía propia que justifique un epic.
- **store:** `dashboardSlice` (datos crudos) y `dashboardSelectors` (todo lo derivado).
- **frontend:** la página, la tarjeta y el gráfico.

Primero, la dependencia de la fase, fijada:

```bash
npm install --save-exact chart.js@2.9.4
```

### 5.1 Cálculos puros — `src/features/dashboard/dashboardMath.js`

Igual que la Fase 8 separó la aritmética en `reconciliationMath.js`, acá la agregación vive en funciones puras, sin React ni Redux. Puras quiere decir que la Fase 10 las prueba solas.

```javascript
// Cálculos puros del tablero: sin React, sin Redux, sin red. Entra la bitácora (u otra
// colección del mock), sale un número o una lista. La Fase 10 los prueba solos.
import { TOTAL_BP } from "../wheels/weightRules";

/**
 * Cuántos giros de cada origen, y los de cada segmento por origen, en una sola pasada.
 * @param {{ landedSegment: string, origin: string }[]} spinLog
 * @param {{ segmentId: string }[]} segments
 * @returns {{ total: number, free: number, paid: number, countsByOrigin: { all: number[], free: number[], paid: number[] } }}
 */
export function summarizeSpins(spinLog, segments) {
  const index = new Map(segments.map((s, i) => [s.segmentId, i]));
  const countsByOrigin = { all: segments.map(() => 0), free: segments.map(() => 0), paid: segments.map(() => 0) };
  let free = 0;
  let paid = 0;
  for (const row of spinLog) {
    const i = index.get(row.landedSegment);
    if (i === undefined) continue;
    countsByOrigin.all[i] += 1;
    if (row.origin === "paid") {
      paid += 1;
      countsByOrigin.paid[i] += 1;
    } else {
      free += 1;
      countsByOrigin.free[i] += 1;
    }
  }
  return { total: free + paid, free, paid, countsByOrigin };
}

/**
 * Giros mandados a mano desde la consola en esta rueda: los envíos con premio spin:<id>.
 * No están en la bitácora de la rueda: son compensaciones, y se cuentan aparte.
 * @param {{ prize: string }[]} grants
 * @param {number} wheelId
 * @returns {number}
 */
export function countManualSpins(grants, wheelId) {
  return grants.filter((grant) => grant.prize === `spin:${wheelId}`).length;
}

/**
 * Ingresos netos de los giros pagos: lo cobrado menos la comisión, renglón por renglón,
 * como lo informa la tienda. Centavos enteros.
 * @param {{ chargedCents: number, feeCents: number }[]} earnings
 * @returns {number}
 */
export function netRevenueCents(earnings) {
  return earnings.reduce((sum, row) => sum + row.chargedCents - row.feeCents, 0);
}

/**
 * Lo que el gráfico de la banda necesita por segmento: esperado y bordes de ±3σ.
 * Tiene decimales y está bien: es para mostrar. La alarma la decide oddsAudit, con enteros.
 * @param {number[]} counts
 * @param {number[]} weightsBp
 * @returns {{ expected: number, low: number, high: number, observed: number }[]}
 */
export function bandRows(counts, weightsBp) {
  const n = counts.reduce((sum, c) => sum + c, 0);
  return weightsBp.map((w, i) => {
    const p = w / TOTAL_BP;
    const sigma = Math.sqrt(n * p * (1 - p));
    const expected = n * p;
    return { expected, low: Math.max(0, expected - 3 * sigma), high: expected + 3 * sigma, observed: counts[i] };
  });
}
```

`summarizeSpins` hace **una sola pasada** y devuelve todo lo que el tablero necesita de la bitácora: los totales por origen y los conteos por segmento de cada origen. Con eso, cambiar el filtro de origen en la pantalla es elegir una de tres listas ya calculadas.

### 5.2 El slice y los selectores

```javascript
import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import apiClient from "../../api/apiClient";
import apiStore from "../../api/apiStore";
import { toReadableError } from "../../api/readableError";

/**
 * Trae lo que el tablero de una rueda necesita. El slice guarda los datos crudos;
 * los números los derivan los selectores (dashboardSelectors.js), con memoria.
 */
export const fetchDashboard = createAsyncThunk("dashboard/fetch", async (wheelId, { rejectWithValue }) => {
  try {
    const [segmentsRes, logRes, grantsRes, earningsRes] = await Promise.all([
      apiClient.get("/segments", { params: { wheelId } }),
      apiClient.get("/spinLog", { params: { wheelId } }),
      apiClient.get("/grants"),
      apiStore.get("/earnings"),
    ]);
    return {
      wheelId,
      segments: segmentsRes.data,
      spinLog: logRes.data,
      grants: grantsRes.data,
      earnings: earningsRes.data,
      loadedAt: Date.now(), // el instante de los datos: la tarjeta lo muestra, no consulta el reloj
    };
  } catch (error) {
    return rejectWithValue(toReadableError(error));
  }
});

const dashboardSlice = createSlice({
  name: "dashboard",
  initialState: {
    wheelId: null,
    segments: [],
    spinLog: [], // la bitácora entera: el store la registra fuera de los chequeos de desarrollo (store.js)
    grants: [],
    earnings: [],
    loadedAt: null,
    loading: false,
    error: null,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchDashboard.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchDashboard.fulfilled, (state, action) => {
        state.loading = false;
        Object.assign(state, action.payload);
      })
      .addCase(fetchDashboard.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  },
});

export default dashboardSlice.reducer;
```

```javascript
import { createSelector } from "@reduxjs/toolkit";
import { summarizeSpins, countManualSpins, netRevenueCents, bandRows } from "./dashboardMath";
import { oddsAudit } from "../reconciliation/oddsAudit";

// --- Selectores de entrada: devuelven ramas del store tal cual (referencias estables).
// Si derivaran algo nuevo acá (un filter, un Object.values), romperían la memoria de abajo.
const selectSpinLog = (state) => state.dashboard.spinLog;
const selectSegments = (state) => state.dashboard.segments;
const selectGrantsLog = (state) => state.dashboard.grants;
const selectEarnings = (state) => state.dashboard.earnings;
const selectWheelId = (state) => state.dashboard.wheelId;

// La pasada sobre la bitácora: corre UNA vez por bitácora, no una vez por render.
export const selectSpinSummary = createSelector([selectSpinLog, selectSegments], (spinLog, segments) =>
  summarizeSpins(spinLog, segments)
);

export const selectManualSpins = createSelector([selectGrantsLog, selectWheelId], (grants, wheelId) =>
  countManualSpins(grants, wheelId)
);

export const selectNetRevenueCents = createSelector([selectEarnings], (earnings) => netRevenueCents(earnings));

/**
 * La banda de cada origen, ya calculada: cambiar el filtro de la pantalla no recalcula nada.
 * Cada entrada trae las filas del gráfico y la auditoría de esos conteos.
 */
export const selectBands = createSelector([selectSpinSummary, selectSegments], (summary, segments) => {
  const weights = segments.map((s) => s.weightBp);
  const bands = {};
  for (const origin of ["all", "free", "paid"]) {
    const counts = summary.countsByOrigin[origin];
    bands[origin] = { rows: bandRows(counts, weights), audit: oddsAudit(counts, weights) };
  }
  return bands;
});
```

`selectBands` calcula las tres bandas (todos, gratis, pagos) de una vez, con su auditoría. La auditoría es la misma `oddsAudit` de la Fase 8, con enteros: el tablero no inventa otra regla para decidir qué es una alarma.

### 5.3 El registro en el store, y la rama que no se chequea

```javascript
    dashboard: dashboardReducer, // Fase 9
  },
  // getDefaultMiddleware trae thunk, immutable-check y serializable-check.
  // Se concatena el de epics; NO se reemplaza el default (se romperían los thunks de F04).
  // F09: los chequeos de desarrollo recorren el estado entero en cada acción. La bitácora del
  // tablero tiene miles de filas que nadie muta: se excluye de los dos, solo esa rama.
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      immutableCheck: { ignoredPaths: ["dashboard.spinLog"] },
      serializableCheck: {
        ignoredPaths: ["dashboard.spinLog"],
        // y la acción que la trae: este chequeo también mira el payload de cada acción.
        ignoredActionPaths: ["meta.arg", "meta.baseQueryMeta", "payload.spinLog"],
      },
    }).concat(epicMiddleware),
```

### 5.4 El gráfico de la banda — `src/features/dashboard/BandChart.jsx`

```jsx
import React, { useEffect, useRef } from "react";
import Chart from "chart.js"; // chart.js 2.x: el export por defecto es el constructor

/**
 * Observado contra configurado: una barra por segmento (lo que dio la rueda) y dos
 * líneas, los bordes de la banda de ±3σ. chart.js 2.9.4, imperativo, sin wrapper de React.
 * @param {{ labels: string[], observed: number[], low: number[], high: number[] }} props
 */
function BandChart({ labels, observed, low, high }) {
  const canvasRef = useRef(null);
  // La instancia va en un ref, no en el estado: no es serializable y no debe provocar render.
  const chartRef = useRef(null);

  // Crear una vez al montar; destruir al desmontar. Sin el destroy, cada visita al
  // tablero deja una instancia de chart.js viva, con sus listeners: el leak de esta fase.
  useEffect(() => {
    chartRef.current = new Chart(canvasRef.current.getContext("2d"), {
      type: "bar",
      data: {
        labels: [],
        datasets: [
          { label: "Observado", data: [], backgroundColor: "rgba(0, 123, 255, 0.6)" },
          { label: "Banda (−3σ)", type: "line", data: [], fill: false, borderColor: "#dc3545", pointRadius: 0 },
          { label: "Banda (+3σ)", type: "line", data: [], fill: false, borderColor: "#dc3545", pointRadius: 0 },
        ],
      },
      options: { responsive: true, maintainAspectRatio: false, scales: { yAxes: [{ ticks: { beginAtZero: true } }] } },
    });
    return () => {
      chartRef.current.destroy();
      chartRef.current = null;
    };
  }, []);

  // Cuando cambian los datos, se ACTUALIZA la instancia; recrearla es la fuga lenta.
  useEffect(() => {
    const chart = chartRef.current;
    chart.data.labels = labels;
    chart.data.datasets[0].data = observed;
    chart.data.datasets[1].data = low;
    chart.data.datasets[2].data = high;
    chart.update();
  }, [labels, observed, low, high]);

  return (
    <div style={{ position: "relative", height: 320 }}>
      <canvas ref={canvasRef} data-testid="band-chart" />
    </div>
  );
}

export default BandChart;
```

Un gráfico mixto de chart.js 2: la barra es el observado, y las dos líneas son los bordes de la banda. Una barra que se sale de entre sus líneas es un segmento fuera de su banda, y es lo primero que Itzel va a mirar.

> 💸 **Deuda reconocida: un gráfico específico, no una librería de gráficos.** `BandChart` hace una sola cosa. Un wrapper genérico (que acepte `type`, ejes configurables) es más prolijo y es sobreingeniería para un gráfico. Si el tablero llega a tres tipos de gráfico, se extrae el genérico entonces, no antes.

### 5.5 La tarjeta — `src/features/dashboard/MetricCard.jsx`

```jsx
import React from "react";

// La hora de Panamá es solo de presentación (historia §9), y se dice explícita:
// la tarjeta muestra lo mismo en cualquier máquina, en cualquier zona.
const UPDATED_FORMAT = new Intl.DateTimeFormat("es-PA", {
  timeZone: "America/Panama",
  day: "2-digit",
  month: "2-digit",
  hour: "2-digit",
  minute: "2-digit",
  hourCycle: "h23", // 00:18 y no 24:18: con hour12: false, algunos motores cuentan la medianoche como 24
});

/**
 * Tarjeta de un indicador. Presentacional: no calcula ni consulta el reloj.
 * @param {{ title: string, value: string, hint?: string, updatedAt?: number }} props
 *   updatedAt: el instante de los datos (milisegundos), que llega por props.
 */
function MetricCard({ title, value, hint, updatedAt }) {
  return (
    <div className="card h-100" data-testid="metric-card">
      <div className="card-body">
        <h6 className="card-subtitle mb-2 text-muted">{title}</h6>
        <p className="card-text h3 mb-0">{value}</p>
        {hint && <small className="text-muted d-block">{hint}</small>}
        {updatedAt && <small className="text-muted d-block">Actualizado: {UPDATED_FORMAT.format(updatedAt)}</small>}
      </div>
    </div>
  );
}

// React.memo: solo vuelve a renderizar si cambian sus props (todas primitivas).
export default React.memo(MetricCard);
```

Presentacional pura: recibe título, valor y pista **ya formateados**, y el instante de los datos. No calcula ni consulta nada; esa es la línea que separa presentación de derivación.

### 5.6 La página — `src/features/dashboard/DashboardPage.jsx`

```jsx
import React, { useEffect, useMemo, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { fetchWheels, selectWheels } from "../wheels/wheelSlice";
import { fetchDashboard } from "./dashboardSlice";
import { selectSpinSummary, selectManualSpins, selectNetRevenueCents, selectBands } from "./dashboardSelectors";
import { formatCents } from "../reconciliation/money";
import MetricCard from "./MetricCard";
import BandChart from "./BandChart";

const ORIGINS = [
  { value: "all", label: "Todos" },
  { value: "free", label: "Gratis" },
  { value: "paid", label: "Pagos" },
];

// El tablero de una rueda: cuántos giros, de qué origen, cuánto dejaron, y si la rueda
// da lo que publica. No calcula: lee selectores que ya tienen la cuenta hecha.
function DashboardPage() {
  const dispatch = useDispatch();
  const wheels = useSelector(selectWheels);
  const { wheelId, segments, loadedAt, loading, error } = useSelector((state) => state.dashboard);
  const summary = useSelector(selectSpinSummary);
  const manual = useSelector(selectManualSpins);
  const net = useSelector(selectNetRevenueCents);
  const bands = useSelector(selectBands);
  const [origin, setOrigin] = useState("all");

  useEffect(() => {
    dispatch(fetchWheels());
  }, [dispatch]);

  // useMemo SÍ va acá: dar forma a las props del gráfico es local al render.
  // El agregado del dominio (los conteos, la banda) ya viene memoizado del selector.
  const chart = useMemo(() => {
    const rows = bands[origin].rows;
    return {
      labels: segments.map((s) => s.segmentId),
      observed: rows.map((r) => r.observed),
      low: rows.map((r) => Math.round(r.low)),
      high: rows.map((r) => Math.round(r.high)),
    };
  }, [bands, origin, segments]);

  const audit = bands[origin].audit;
  const alarm = audit.chi2Alarm || audit.bandAlarms.length > 0;

  return (
    <div className="container mt-4">
      <h2 className="mb-4">Dashboard</h2>
      <div className="form-row mb-3">
        <div className="col-md-6">
          <label htmlFor="dashboardWheel">Rueda</label>
          <select id="dashboardWheel" className="form-control" value={wheelId || ""}
            onChange={(e) => dispatch(fetchDashboard(Number(e.target.value)))}>
            <option value="">Elige una rueda</option>
            {wheels.map((w) => (
              <option key={w.id} value={w.id}>{w.name}</option>
            ))}
          </select>
        </div>
        <div className="col-md-6">
          <label htmlFor="dashboardOrigin">Origen de los giros</label>
          <select id="dashboardOrigin" className="form-control" value={origin} onChange={(e) => setOrigin(e.target.value)}>
            {ORIGINS.map((o) => (
              <option key={o.value} value={o.value}>{o.label}</option>
            ))}
          </select>
        </div>
      </div>
      {loading && <p className="text-muted">Cargando…</p>}
      {error && <p className="text-danger">{error.message}</p>}

      {wheelId && !loading && (
        <>
          <div className="row mb-4">
            <div className="col-md-3 mb-3">
              <MetricCard title="Giros" value={String(summary.total)} hint={`${summary.free} gratis · ${summary.paid} pagos`} updatedAt={loadedAt} />
            </div>
            <div className="col-md-3 mb-3">
              <MetricCard title="Giros manuales" value={String(manual)} hint="Compensaciones desde la consola" updatedAt={loadedAt} />
            </div>
            <div className="col-md-3 mb-3">
              <MetricCard title="Ingresos netos" value={formatCents(net)} hint="Cobrado menos la comisión de la tienda" updatedAt={loadedAt} />
            </div>
            <div className="col-md-3 mb-3">
              <MetricCard title="Probabilidades" value={alarm ? "Con alarma" : "Sin alarma"} hint={`χ² = ${audit.chi2.toFixed(2)}`} updatedAt={loadedAt} />
            </div>
          </div>
          <div className="card">
            <div className="card-header">Observado contra configurado, con la banda de ±3σ</div>
            <div className="card-body">
              <BandChart labels={chart.labels} observed={chart.observed} low={chart.low} high={chart.high} />
            </div>
          </div>
        </>
      )}
    </div>
  );
}

export default DashboardPage;
```

Fíjate qué **poco** cálculo hay acá: todo vino resuelto y memoizado de los selectores. El único `useMemo` da forma a las props del gráfico, que es local al render.

### 5.7 Conectar la ruta

La Fase 1 registró `/dashboard` apuntando al placeholder `src/pages/DashboardPage.jsx`. El cambio es de una línea:

```jsx
// El placeholder de la Fase 1 ahora reexporta el tablero real: el router no se toca
// y el diff queda en una línea. (La alternativa —cambiar el import del router y
// borrar este archivo— también es válida; lo que no vale es dejarlo ambiguo.)
export { default } from "../features/dashboard/DashboardPage";
```

> Es un buen momento para practicar el reflejo de mantenimiento: entre "cambio el import del router" y "dejo un reexport", elige el diff más chico que no confunda al próximo que lea el código. Un reexport de una línea con su comentario es defendible; un placeholder que sigue "pareciendo" el tablero real, no.

### 5.8 El volumen de un evento

La siembra de la Fase 8 suma una bandera: con `--event`, la Semana del Canal (rueda 2) queda terminada con **180.000 giros** de un día, el último día de un evento según la historia §8.

```javascript
// F09: el volumen de un evento. La Semana del Canal (rueda 2) cerró el 15/08, y su último
// día tuvo unos 180.000 giros (historia §8). Sus compras no se siembran: el tablero no las cruza.
if (process.argv.includes("--event")) {
  const EVENT_ID = 2;
  const eventSegments = db.segments.filter((s) => s.wheelId === EVENT_ID);
  const eventLog = generateSpinLog({
    seed: 2025,
    spins: 180000,
    wheelId: EVENT_ID,
    segments: eventSegments,
    players: 40000,
    startsAt: "2026-08-15T00:00:00-05:00",
    intervalMs: 480, // un día entero de giros
  });
  db.spinLog = db.spinLog.filter((row) => row.wheelId !== EVENT_ID).concat(eventLog);
  db.spinLog.forEach((row, i) => { row.id = i + 1; });
  db.wheels.find((w) => w.id === EVENT_ID).status = "ended";
}
```

```bash
node mock/seed-reconciliation.js --event   # con los mocks parados; el db.json pasa a unos 50 MB
```

No se commitea así: el `db.json` del repo sigue con la siembra de la Fase 8, y el volumen se genera cuando hace falta (la pieza forense y el incidente 19). Para volver, `git checkout -- mock/db.json`.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. `useMemo` con dependencias que se recrean → memoización fantasma.**
*Síntoma:* metiste `useMemo` "para optimizar" y el Profiler muestra que el cálculo corre igual en cada render. *Causa:* la dependencia es un arreglo o un objeto nuevo en cada render (por ejemplo `[Object.values(spinLog)]`), así que `useMemo` invalida su caché siempre. *Fix mínimo:* mover el agregado a un `createSelector`, o memoizar también la dependencia intermedia. La refactorización correcta es la primera: el cálculo del dominio no debería estar en el componente.

**2. Una rama grande del store bajo los chequeos de desarrollo.**
*Síntoma:* después de cargar el tablero de un evento, toda la consola se arrastra en desarrollo, y la consola del navegador repite *"SerializableStateInvariantMiddleware took … ms"*. *Causa:* los middlewares de desarrollo recorren las 180.000 filas en cada acción. *Fix mínimo:* `ignoredPaths` para esa rama, como en §5.3. Es el incidente 19.

**3. Olvidar `chart.destroy()` en la limpieza.**
*Síntoma:* entras y sales del tablero varias veces, la pestaña se pone lenta y la memoria sube. *Causa:* cada montaje crea una instancia de chart.js y ninguna se destruye. *Fix mínimo:* el `return () => chartRef.current.destroy()` del `useEffect`.

**4. Formatear antes de sumar.**
*Síntoma:* los ingresos muestran algo absurdo o `NaN`. *Causa:* se formateó cada renglón a texto y después se intentó sumar, o se mezclaron dólares con centavos. *Fix mínimo:* sumar enteros de centavos en la función pura (`netRevenueCents`) y llamar a `formatCents` **una sola vez**, sobre el total.

**5. Recrear el gráfico en cada cambio de datos en vez de actualizarlo.**
*Síntoma:* el gráfico parpadea al cambiar el filtro. *Causa:* la creación del gráfico está en un `useEffect` con los datos en las dependencias, así que se destruye y se recrea entero cada vez. *Fix:* separar creación (una vez, `[]`) de actualización (`chart.update()`), como en §5.4.

### Pieza forense de esta fase — rendimiento del tablero: `useMemo` mal aplicado

La habilidad que entrena esta fase no es "poner `useMemo` en todos lados" —así es como se **crea** el problema— sino **leer el Profiler y decidir si un cálculo se repite sin necesidad, y dónde debería vivir su caché**. Para que se vea, hace falta volumen: siembra la Semana del Canal con `--event`.

1. Abre **React DevTools → Profiler**, activa "Record", abre el tablero de la Semana del Canal, cambia el filtro de origen varias veces y frena la grabación.
2. Mira qué componentes renderizaron y **por qué** (el Profiler dice si fue por props, estado o el padre), y cuánto tardó cada commit.
3. Pon un `console.count('summarizeSpins')` dentro de la función pura, temporalmente, y confirma cuántas veces corre por interacción. Con el selector memoizado, corre **una vez por bitácora cargada**, no una por cambio de filtro.

> 🧪 **Ejercicio de "rompe a propósito y observa".** En `DashboardPage`, reemplaza `useSelector(selectSpinSummary)` por el cálculo en el componente: `useMemo(() => summarizeSpins(spinLog, segments), [Object.values(spinLog), segments])`, y calcula también ahí las bandas. Graba el Profiler y mira con el `console.count` cómo `summarizeSpins` corre ahora en **cada** cambio de filtro. Medido el 18/10/2026 con la Semana del Canal (180.000 giros), en Jest con jsdom, la mediana de diez cambios de filtro: **12,5 ms** con el `useMemo` roto contra **2,2 ms** con el selector; con la Rueda de fin de mes (10.000 giros), 2,5 contra 2,3 ms. Después revierte al selector y confirma que vuelve a correr solo cuando toca. Ese contraste —el mismo cálculo, memoizado bien y memoizado mal, que crece con el volumen— es la lección de la fase.

> 📓 De esta fase salen los incidentes **19**, **20** y **21** de `cuaderno-incidentes.md`.

---

## 🧪 7. Ejercicios (28)

**🟢 Fácil (1–8)**
1. Entra a `/dashboard`, elige la Rueda de fin de mes y confirma que el placeholder de la Fase 1 fue reemplazado. **Criterio:** cuatro `data-testid="metric-card"` en el DOM, y "10000" en la primera.
2. Cambia el filtro de origen a "Pagos" y confirma que el gráfico cambia y las tarjetas no. **Criterio:** 2434 giros pagos en la pista de la primera tarjeta, antes y después.
3. Agrega una quinta `MetricCard` con el total de giros pagos usando `selectSpinSummary`. No agregues un selector si uno existente ya te da el dato.
4. Cambia el color de las barras del `BandChart` y confirma que cambia solo el observado.
5. Explica en una frase por qué la instancia del gráfico vive en un `useRef` y no en `useState`.
6. Provoca el estado "sin datos": elige una rueda sin giros (la Esclusa de Oro) y confirma que el tablero no muestra `NaN`. **Criterio:** localizas la línea que lo evita.
7. Agrega un JSDoc completo a `DashboardPage` con los selectores que consume y lo que NO calcula.
8. Con React DevTools, confirma que `MetricCard` aparece como "Memo" en el árbol.

**🟡 Intermedio (9–18)**
9. Escribe un selector `selectFreeShare` (fracción de giros gratis) con `createSelector` sobre `selectSpinSummary` y úsalo en una tarjeta. Explica por qué acá el `createSelector` casi no aporta (la entrada ya está memoizada) y por qué igual conviene.
10. Entra y sal del tablero diez veces con un `console.count` en la creación y otro en la limpieza del gráfico. **Criterio:** los dos contadores van parejos.
11. Pinta de rojo las barras de los segmentos con alarma de banda (`audit.bandAlarms`).
12. Haz que las líneas de la banda sean rectas entre segmentos (`lineTension: 0` en chart.js 2) y explica por qué una curva entre categorías es engañosa.
13. Agrega un `useCallback` a un handler de clic en una barra (`console.log` del segmento) y explica por qué acá sí aporta.
14. Reproduce el error común #4: formatea cada renglón del reporte con `formatCents` y concatena. Explica por qué `formatCents` no te salvó.
15. Muestra un estado de carga distinto para la primera carga y para el cambio de rueda.
16. Escribe, en un comentario, cómo verificarías que `selectBands` solo recalcula cuando cambia la bitácora o los segmentos (la prueba la escribes en la Fase 10).
17. Agrega `data-testid` descriptivos a los dos selects del tablero, en kebab-case, para que la Fase 10 los use.
18. Explica con tus palabras la diferencia entre dónde cachea `useMemo` y dónde cachea `createSelector`, con un caso donde se nota.

**🟠 Difícil (19–24)**
19. **Diagnóstico:** un tablero donde `summarizeSpins` corre en cada render. Con el Profiler y un `console.count`, decide si la causa es un `useMemo` con dependencia inestable o un selector de entrada que devuelve un arreglo nuevo. Aplica el fix mínimo y mide la mejora con la Semana del Canal.
20. **Diagnóstico:** el gráfico parpadea al cambiar el filtro. Identifica la creación con los datos en las dependencias y sepárala en creación y actualización.
21. **Diagnóstico:** una `MetricCard` renderiza en cada cambio de filtro aunque su valor no cambia. Descubre qué prop nueva le llega y corrígelo.
22. Rompe a propósito un selector de entrada (`(state) => [...state.dashboard.spinLog]`) y muestra con `selectSpinSummary.recomputations()` que ahora recalcula siempre.
23. Mide con el Profiler el commit del tablero con 10.000 y con 180.000 giros. **Criterio:** una tabla con las dos medidas, y una frase sobre si el cuello es el cálculo o el gráfico.
24. Quita las `ignoredPaths` del store, carga la Semana del Canal y escribe una letra en el buscador del asistente. **Criterio:** el aviso de Toolkit en la consola, con su número de milisegundos, y la explicación de por qué en producción no pasa.

**🔴 Muy difícil (25–28)**
25. **Diagnóstico de punta a punta:** "el tablero se pone lento después de usarlo un rato". Reproduce (entra y sal del tablero veinte veces), diagnostica con el Profiler y la pestaña Memory que son instancias de chart.js sin destruir, corrige la limpieza y escribe el post-mortem sin culpables.
26. Haz que el tablero muestre **varias ruedas a la vez**. Diseña el cambio mínimo del slice y de los selectores, o justifica por qué es un refactor y propón el plan.
27. Construye un selector parametrizado por rueda y explica por qué la memoria de reselect (caché de tamaño 1) falla cuando lo llamas con dos ruedas en el mismo render. Propón la solución sin traer una librería nueva.
28. **El estado de carga engañoso:** el tablero puede pintar "Ingresos netos: US$0,00" antes de que llegue el reporte de la tienda. Decide si es un bug o un estado de carga legítimo y resuélvelo, distinguiendo qué parte es de pantalla, de store y de servicio.

**🔥 Opcionales**
- 🔥 Drill-down: clic en una barra muestra debajo los últimos giros que cayeron en ese segmento.
- 🔥 Serie temporal "giros por hora" de la Semana del Canal. Antes de empezar, explica por qué agrupar por hora reabre la pregunta del reloj de la Fase 7.
- 🔥 Exporta los indicadores a CSV a mano, desde los selectores.

---

## 📚 8. Referencias

**Documentación oficial**
- https://reactjs.org/docs/hooks-reference.html#usememo — `useMemo` y `useCallback` (React 16.8+).
- https://reactjs.org/docs/react-api.html#reactmemo — `React.memo`.
- https://redux-toolkit.js.org/api/createSelector — `createSelector` reexportado por Toolkit (RTK 1.8.x).
- https://redux-toolkit.js.org/api/getDefaultMiddleware — los dos middlewares de desarrollo y sus `ignoredPaths`.
- https://github.com/reduxjs/reselect#readme — la memoria de un nivel y la caché de tamaño 1 (el ejercicio 27).
- https://www.chartjs.org/docs/2.9.4/ — chart.js **2.x**: el constructor, `data` y `options`, gráficos mixtos.
- https://reactjs.org/blog/2018/09/10/introducing-the-react-profiler.html — el Profiler de React, base de la pieza forense.

**Orden de lectura sugerido:** `useMemo` y `React.memo` → `createSelector` y el README de reselect → `getDefaultMiddleware` → la documentación de chart.js 2.x (gráficos de barras y mixtos, y el ciclo de vida) → `dashboardSelectors.js`, que es el corazón de la fase.

> ⚠️ Las URL pueden haber cambiado; verifícalas. La documentación de chart.js muestra por defecto la versión más nueva (3 o 4): asegúrate de estar leyendo la **2.x**.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Cerraste el recorrido de la aplicación: de crear una rueda (Fase 4) a compensar a mano (Fase 5), orquestar con epics (Fase 6), cerrar a hora exacta y seguir compras (Fase 7), conciliar sin perder un centavo (Fase 8) y ahora **verla entera de un vistazo** (Fase 9). Y sin agregar una regla de negocio: solo derivando, con la memoria del cálculo en el lugar correcto —el selector— y `useMemo` reservado para lo que es local al render.

Eso te deja parado para la **Fase 10 — Testing mínimo**. Los cálculos puros (`dashboardMath.js`) y los selectores son lo más agradecido de probar en todo el curso: entra un objeto, sale un número, sin red, sin tiempo, sin React. Y la tarjeta, que no consulta el reloj, es la que va a tener la prueba más interesante: la que pasa en cualquier zona horaria porque el componente no depende de ella.

> **La señal de que quedó bien:** cuando abres el Profiler, cambias el filtro diez veces con la Semana del Canal cargada, y `summarizeSpins` no corre ni una vez de más. Cuando puedes señalar, para cada número en pantalla, de qué colección del mock salió y qué selector lo derivó.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-09-dashboard -m "F9 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f09: …`) y los de ejercicio su número (`f09 ej17: …`). Si un ejercicio merece su propio marcador va en `ej/f09/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` / `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura. Va acá abajo, fuera de la plantilla de nueve secciones, porque es lo que apareció al escribir la fase y no cabía adentro — y porque no debe competir con el cierre.

- **El formato de la hora depende del motor.** El mismo `Intl.DateTimeFormat("es-PA", …)` da "20/12 21:00" en el Node 14 de Jest y "18/10, 20:16" (con coma) en Electron. La prueba de la Fase 10 está escrita contra el de Jest. → Si la suite corre algún día en un navegador real, la aserción tiene que tolerar el separador.
- **Las líneas de la banda son curvas** (la tensión por defecto de chart.js 2) entre categorías que no tienen orden. → Es el ejercicio 12; podría ir en el código base.
- **La agregación en el servidor 💸** no tiene disparador cuantificado. → Proponer uno: "cuando el tablero tarde más de un segundo en cargar una rueda".

### Reservas para el cuaderno de incidentes

Los IDs quedan reservados en `cuaderno-incidentes.md`, donde el enunciado ya está redactado con sus pistas y su solución de referencia. El ID nunca se reasigna.

- **19** — *El dashboard se arrastra al final de la Semana del Canal* · Rendimiento · 🟠. Sale del error común #2: la bitácora del evento bajo los chequeos de desarrollo, cientos de milisegundos por acción en todas las pantallas.
- **20** — *El test pasa en mi máquina y falla en la de al lado* · Testing · 🔴. Sale de la tarjeta que consulta el reloj; se abre en la Fase 10 y se cierra en la 11.
- **21** ➕ — *La rueda que dice 15 % y el tablero muestra 5 %* · Dominio · 🟠. La regla vieja de la rueda que se acomoda, vista en el tablero. Termina en diagnóstico y decisión, no en un commit.
