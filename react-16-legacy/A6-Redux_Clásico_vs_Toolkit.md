# 🧰 Apéndice A6 — Redux Clásico vs Toolkit
## Tutorial React 16 — Rifas y chances

> **Material de consulta rápida.** No se lee de corrido: saltás a la
> sección que te hace falta cuando una fase te tira un `createSlice` o un
> `connect()` y necesitás ubicarte. Lo usan la Fase 3 en adelante.

Este apéndice existe porque en esta base **conviven los dos estilos de
Redux**. El código heredado usa Redux clásico —`createStore`, action types
a mano, reducers con `switch`, `connect()`—. Los módulos nuevos usan Redux
Toolkit (`createSlice`, `configureStore`) porque así lo fija la decisión D4
(Toolkit 1.8.x en código nuevo). No estás migrando: estás aprendiendo a
**leer los dos** y a saber cuál te toca tocar en cada hotfix.

Todo el código va con identificadores en inglés y comentarios/UI en
español, según la convención del proyecto. Los nombres (`raffleSlice`,
`sellNumber`, `SELL_NUMBER`, `authSlice`) son los mismos que ya usan las
fases 2 a 8, así que lo que veas acá es lo que vas a encontrar allá.

---

## 🧭 Índice de salto rápido

1. [El mapa mental en 30 segundos](#1-el-mapa-mental-en-30-segundos) · **tabla de equivalencias**
2. [El store: `createStore` vs `configureStore`](#2-el-store-createstore-vs-configurestore)
3. [Actions: manuales vs `createAction`](#3-actions-manuales-vs-createaction)
4. [Reducers: `switch` manual vs `createReducer`](#4-reducers-switch-manual-vs-createreducer)
5. [Immer: por qué en Toolkit "mutás" y está bien](#5-immer-por-qué-en-toolkit-mutás-y-está-bien)
6. [`createSlice`: actions + reducer en un archivo](#6-createslice-actions--reducer-en-un-archivo)
7. [Async: thunk manual vs `createAsyncThunk`](#7-async-thunk-manual-vs-createasyncthunk)
8. [`createEntityAdapter`: normalización sin boilerplate](#8-createentityadapter-normalización-sin-boilerplate)
9. [Conectar el componente: `connect()` vs `useSelector`/`useDispatch`](#9-conectar-el-componente-connect-vs-useselectoruse dispatch)
10. [Leer código mezclado sin marearse](#10-leer-código-mezclado-sin-marearse)
11. [Receta: convertir un slice manual a `createSlice`](#11-receta-convertir-un-slice-manual-a-createslice)
12. [🧪 Ejercicios](#12--ejercicios-8)
13. [📚 Referencias](#13--referencias)

---

## 1. El mapa mental en 30 segundos

Redux —clásico o Toolkit— es siempre lo mismo: un **store** guarda estado,
despachás **actions**, un **reducer** calcula el estado nuevo, y el
componente **lee** del store y **despacha**. Toolkit no cambia el modelo;
cambia cuánto código escribís para lograrlo. Donde el clásico te pide tres
archivos (types, action creators, reducer) y que cuides la inmutabilidad a
mano, Toolkit junta todo en un `createSlice` y te pone Immer debajo para
que "mutar" sea seguro.

Esta tabla es el corazón del apéndice. Si tenés enfrente código clásico y
querés su equivalente moderno (o al revés), es acá:

| Concepto | Redux clásico | Redux Toolkit (1.8.x) | Nota de lectura |
|---|---|---|---|
| Crear el store | `createStore(rootReducer, applyMiddleware(...))` | `configureStore({ reducer, middleware })` | Toolkit ya trae thunk + DevTools + checks de inmutabilidad |
| Combinar reducers | `combineReducers({ ... })` | `configureStore({ reducer: { ... } })` | El objeto `reducer` combina solo |
| Definir action type | `const SELL_NUMBER = 'SELL_NUMBER'` | lo genera `createSlice`/`createAction` | En Toolkit el type queda `'sale/sellNumber'` |
| Action creator | `(p) => ({ type: SELL_NUMBER, payload: p })` | `createAction('sale/sellNumber')` o `slice.actions.sellNumber` | Ambos devuelven `{ type, payload }` |
| Chequear el type | `action.type === SELL_NUMBER` | `sellNumber.match(action)` | `.match` evita strings sueltos mal escritos |
| Reducer | `function reducer(state, action){ switch(action.type){...} }` | campo `reducers` de `createSlice` o `createReducer` | En clásico devolvés estado nuevo; en Toolkit "mutás" |
| Inmutabilidad | manual (`{ ...state, items: [...] }`) | automática vía **Immer** | En Toolkit `state.items.push(x)` es seguro |
| Slice completo | archivo de types + creators + reducer | `createSlice({ name, initialState, reducers })` | Un archivo en lugar de tres |
| Async | thunk a mano + 3 action types | `createAsyncThunk` (genera pending/fulfilled/rejected) | Reaccionás en `extraReducers` |
| Normalización | armar `{ byId, allIds }` a mano | `createEntityAdapter` | Da selectores y CRUD listos |
| Leer del store | `mapStateToProps` + `connect()` | `useSelector(selector)` | `useSelector` recalcula en cada acción; cuidá la igualdad |
| Despachar | `mapDispatchToProps` + `connect()` | `useDispatch()` | `const dispatch = useDispatch()` una vez |
| Envolver el componente | `connect(msp, mdp)(Component)` | nada: hooks en el cuerpo | HOC vs hook |

> 💡 Regla práctica para el equipo: **si el archivo importa de
> `@reduxjs/toolkit`, es código nuevo; si define `const FOO = 'FOO'` a mano
> y usa `connect`, es heredado.** Con eso ya sabés qué convenciones esperar
> antes de leer una línea de lógica.

---

## 2. El store: `createStore` vs `configureStore`

**Cuándo lo tocás.** Casi nunca en un hotfix, pero necesitás leerlo para
saber qué middleware corre (thunk, epics) y si DevTools está activo. En
esta base el store real ya está en Toolkit; el `createStore` aparece en
código de ejemplo heredado y en libs viejas.

**Ejemplo mínimo, lado a lado.**

```javascript
// ── Clásico ──────────────────────────────────────────────
import { createStore, combineReducers, applyMiddleware } from 'redux';
import { composeWithDevTools } from 'redux-devtools-extension';
import thunk from 'redux-thunk';

const rootReducer = combineReducers({ raffles: raffleReducer, auth: authReducer });

// tenés que enchufar a mano thunk y DevTools
const store = createStore(rootReducer, composeWithDevTools(applyMiddleware(thunk)));
```

```javascript
// ── Toolkit (lo que usa el proyecto) ─────────────────────
import { configureStore } from '@reduxjs/toolkit';
import raffleReducer from '../features/raffles/raffleSlice';
import authReducer from '../features/auth/authSlice';

// thunk, DevTools y checks de inmutabilidad vienen de fábrica
const store = configureStore({
  reducer: { raffles: raffleReducer, auth: authReducer },
});
```

Cuando entren los epics (Fase 6), el `epicMiddleware` se agrega al array
`middleware` de `configureStore`; el detalle vive en A7, no acá.

> ⚠️ **Error común.** En `createStore` es fácil olvidar
> `composeWithDevTools` y después perder media hora preguntándote por qué
> Redux DevTools no muestra nada. En `configureStore` ya viene resuelto: si
> DevTools no aparece, el problema es la extensión del navegador, no el
> store.

---

## 3. Actions: manuales vs `createAction`

**Cuándo lo tocás.** Cada vez que seguís el rastro de un `dispatch` hasta
el reducer. En clásico buscás la constante; en Toolkit, el `createAction` o
el `slice.actions`.

**Ejemplo mínimo.**

```javascript
// ── Clásico: tres piezas separadas ───────────────────────
export const SELL_NUMBER = 'SELL_NUMBER';                 // el type
export const sellNumber = (payload) => ({                 // el creator
  type: SELL_NUMBER,
  payload,
});
// uso: dispatch(sellNumber({ raffleId, number: '0347' }))
```

```javascript
// ── Toolkit: una línea ───────────────────────────────────
import { createAction } from '@reduxjs/toolkit';

// el type se arma solo con el string que le pasás
export const sellNumber = createAction('sale/sellNumber');
// uso idéntico: dispatch(sellNumber({ raffleId, number: '0347' }))
// además: sellNumber.type === 'sale/sellNumber'
//         sellNumber.match(action) === true si action vino de acá
```

Los dos producen el mismo objeto `{ type, payload }`. La diferencia es que
`createAction` te da gratis `.type` y `.match(action)`, y te ahorra la
constante suelta que en clásico se puede escribir mal sin que nadie avise.

> ⚠️ **Error común (clásico).** Un typo en el string del type
> (`'SELL_NUMBR'`) no rompe nada de forma visible: la action se despacha, el
> reducer no la reconoce, y el estado simplemente no cambia. Es un bug
> mudo. Con `createAction` no hay string suelto que escribir dos veces, así
> que esa clase de typo desaparece.

---

## 4. Reducers: `switch` manual vs `createReducer`

**Cuándo lo tocás.** Siempre que un bug sea "el estado no quedó como
esperaba". El reducer es donde el estado se calcula.

**Ejemplo mínimo.**

```javascript
// ── Clásico: switch + copia inmutable a mano ─────────────
const initialState = { items: [], loadingList: false };

function raffleReducer(state = initialState, action) {
  switch (action.type) {
    case FETCH_RAFFLES_PENDING:
      // devolvés un objeto NUEVO, sin tocar el anterior
      return { ...state, loadingList: true };
    case FETCH_RAFFLES_FULFILLED:
      return { ...state, loadingList: false, items: action.payload };
    default:
      return state; // clave: si no reconocés el type, devolvés el estado tal cual
  }
}
```

```javascript
// ── Toolkit: createReducer con builder ───────────────────
import { createReducer } from '@reduxjs/toolkit';

const raffleReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(fetchRaffles.pending, (state) => {
      state.loadingList = true;        // "mutás": Immer lo hace inmutable por vos
    })
    .addCase(fetchRaffles.fulfilled, (state, action) => {
      state.loadingList = false;
      state.items = action.payload;
    });
  // el default (devolver el estado sin cambios) es implícito
});
```

En la práctica casi nunca vas a escribir `createReducer` suelto: te lo
comés dentro de `createSlice` (sección 6). Pero lo vas a **leer** cuando un
slice maneje async con `extraReducers`.

> ⚠️ **Error común (clásico).** Mutar el estado creyendo que lo estás
> copiando: `state.items.push(x); return state;`. Redux compara por
> referencia; como devolviste el **mismo** objeto, muchos componentes no
> re-renderizan y el bug parece "a veces se actualiza, a veces no". En
> Toolkit ese `push` sí es legal porque Immer produce la copia; en clásico
> es una trampa clásica. Ver sección 5.

---

## 5. Immer: por qué en Toolkit "mutás" y está bien

Este es **el** punto que más marea al leer código mezclado. En un reducer
clásico, mutar el estado es pecado. En un reducer de Toolkit, mutarlo es lo
normal. No es que Toolkit rompió las reglas: usa [Immer](https://immerjs.github.io/immer/)
por debajo. Vos escribís código que *parece* mutación sobre un borrador
(`draft`), e Immer produce una copia inmutable real detrás de escena.

```javascript
// Dentro de un createSlice / createReducer, esto es correcto:
reserveNumber(state, action) {
  // parece mutación, Immer la convierte en copia inmutable
  const cell = state.numbers.find((n) => n.number === action.payload);
  cell.status = 'reserved';        // ✅ seguro
  state.reservedCount += 1;        // ✅ seguro
}
```

> ⚠️ **Error común (la trampa del `return`).** Con Immer elegís **una** de
> dos formas: o mutás el `draft` y **no** devolvés nada, o construís un
> objeto nuevo y lo devolvés. Si hacés las dos —mutás el `draft` *y* además
> `return algo`— Immer se confunde y tirás resultados raros. Regla simple:
> si tocaste `state.loquesea = ...`, no pongas `return`.

```javascript
// ❌ mezcla las dos formas: mutación + return
addRaffle(state, action) {
  state.items.push(action.payload);
  return { ...state, dirty: true }; // 💥 no hagas esto
}

// ✅ elegí una: solo mutación
addRaffle(state, action) {
  state.items.push(action.payload);
  state.dirty = true;
}
```

> 📝 **Nota de época.** El estilo `{ ...state, items: [...state.items, x] }`
> que ves en el código heredado no está "mal": era **la** forma correcta
> antes de Toolkit. No lo reescribas a Immer en un hotfix; convive perfecto
> con los slices nuevos.

---

## 6. `createSlice`: actions + reducer en un archivo

**Cuándo lo tocás.** Es el caballo de batalla del código nuevo (D4). Cada
feature nueva del proyecto —`raffleSlice`, `saleSlice`, `authSlice`,
`settlementSlice`— es un `createSlice`. Si tocás lógica de estado moderna,
tocás esto.

`createSlice` junta en un solo archivo lo que el clásico esparce en tres:
genera los action types (a partir de `name` + la key del reducer), los
action creators, y el reducer. Vos escribís solo el `initialState` y las
funciones que transforman estado.

```javascript
// src/features/sale/saleSlice.js
import { createSlice } from '@reduxjs/toolkit';

const saleSlice = createSlice({
  name: 'sale',
  initialState: { numbers: [], reservedCount: 0, error: null },
  reducers: {
    // cada key genera un action creator y un action type:
    //   saleSlice.actions.reserveNumber  →  type 'sale/reserveNumber'
    reserveNumber(state, action) {
      const cell = state.numbers.find((n) => n.number === action.payload);
      if (cell && cell.status === 'available') {
        cell.status = 'reserved';    // Immer: mutación segura
        state.reservedCount += 1;
      }
    },
    // ejemplo de acción con payload preparado
    sellNumber(state, action) {
      const cell = state.numbers.find((n) => n.number === action.payload.number);
      if (cell) cell.status = 'sold';
    },
  },
});

// esto es lo que exportás: los creators y el reducer
export const { reserveNumber, sellNumber } = saleSlice.actions;
export default saleSlice.reducer;
```

**Anatomía en una frase:** `name` prefija los types, cada key de `reducers`
es a la vez un action creator (`saleSlice.actions.reserveNumber`) y un caso
del reducer, y `saleSlice.reducer` es lo que enchufás en `configureStore`.

> ⚠️ **Error común.** Olvidar exportar `saleSlice.reducer` como
> `export default` (o exportar el slice entero por error). Si al store le
> pasás el objeto slice en vez de su `.reducer`, el estado nunca se arma y
> `useSelector` te devuelve `undefined`. Revisá siempre que el
> `export default` sea `slice.reducer`.

---

## 7. Async: thunk manual vs `createAsyncThunk`

**Cuándo lo tocás.** Cada vez que el estado depende de una llamada a la API
(`/raffles`, `/sell`, `/results`). El async no vive en el reducer —los
reducers son puros—; vive en un thunk o en un epic.

En clásico, un thunk es una función que recibe `dispatch` y despacha a mano
tres actions (pedido, éxito, error). En Toolkit, `createAsyncThunk` genera
esas tres actions por vos (`pending`, `fulfilled`, `rejected`) y las
enganchás en `extraReducers`.

```javascript
// ── Clásico: thunk a mano, tres action types ─────────────
export const fetchRaffles = () => async (dispatch) => {
  dispatch({ type: FETCH_RAFFLES_PENDING });
  try {
    const response = await apiClient.get('/raffles');
    dispatch({ type: FETCH_RAFFLES_FULFILLED, payload: response.data });
  } catch (error) {
    dispatch({ type: FETCH_RAFFLES_REJECTED, error: toReadableError(error) });
  }
};
```

```javascript
// ── Toolkit: createAsyncThunk genera los tres estados ────
import { createAsyncThunk } from '@reduxjs/toolkit';

export const fetchRaffles = createAsyncThunk('raffles/fetch', async () => {
  const response = await apiClient.get('/raffles');
  return response.data; // esto llega como action.payload en el .fulfilled
});

// y en el slice reaccionás a los tres estados:
extraReducers: (builder) => {
  builder
    .addCase(fetchRaffles.pending, (state) => { state.loadingList = true; })
    .addCase(fetchRaffles.fulfilled, (state, action) => {
      state.loadingList = false;
      state.items = action.payload;
    })
    .addCase(fetchRaffles.rejected, (state, action) => {
      state.loadingList = false;
      state.error = action.error;
    });
},
```

**`reducers` vs `extraReducers` —la duda clásica.** Las acciones *propias*
del slice van en `reducers` (y generan creators). Las que vienen de
*afuera* —un `createAsyncThunk`, o una action de otro slice— van en
`extraReducers` con `builder.addCase`, y **no** generan creators nuevos.

> 💡 **¿Thunk o epic?** Si es un pedido puntual (traer rifas, vender un
> número), un thunk alcanza y es más simple de leer. El epic (RxJS) se
> justifica cuando hay **cancelación, debounce, polling o carreras** que un
> thunk no maneja bien: el polling del resultado de la lotería (Fase 7) es
> el caso de manual. No metas RxJS donde un thunk resuelve. El detalle de
> epics vive en **A7**.

> ⚠️ **Error común.** Poner el `createAsyncThunk` en `reducers` en vez de
> `extraReducers`. No compila como esperás: `reducers` es para acciones que
> el slice *define*, no para las que *escucha*. Los tres estados del thunk
> siempre van en `extraReducers`.

---

## 8. `createEntityAdapter`: normalización sin boilerplate

**Cuándo lo tocás.** Cuando un slice guarda una **lista de entidades por
id** y hacés mucho "buscá la rifa X, actualizala, borrala". En vez de
mantener `{ byId, allIds }` a mano, `createEntityAdapter` te da esa
estructura normalizada más los métodos CRUD y los selectores.

```javascript
// ── A mano (clásico): normalización artesanal ────────────
// state.raffles = { byId: { 'r1': {...} }, allIds: ['r1', 'r2'] }
// y escribís addOne / updateOne / removeOne vos mismo...
```

```javascript
// ── Toolkit: el adapter te lo da hecho ───────────────────
import { createEntityAdapter, createSlice } from '@reduxjs/toolkit';

const rafflesAdapter = createEntityAdapter();

const raffleSlice = createSlice({
  name: 'raffles',
  // getInitialState() arma { ids: [], entities: {} }
  initialState: rafflesAdapter.getInitialState({ loadingList: false }),
  reducers: {
    raffleAdded: rafflesAdapter.addOne,       // CRUD listo para usar
    raffleUpdated: rafflesAdapter.updateOne,
    raffleRemoved: rafflesAdapter.removeOne,
  },
});

// selectores gratis (selectAll, selectById, ...):
export const { selectAll: selectAllRaffles, selectById: selectRaffleById } =
  rafflesAdapter.getSelectors((state) => state.raffles);
```

> ⚠️ **Error común.** Pasarle al `getSelectors` el state equivocado. El
> argumento es la función que ubica *el slice* dentro del state global
> (`(state) => state.raffles`), no el state entero. Si le errás, los
> selectores devuelven vacío y jurás que el fetch falló cuando el problema
> es el puntero al slice.

> 🔥 En esta base no todos los slices usan adapter; varios guardan un array
> plano en `items` (como `raffleSlice` de la Fase 4). Migrar uno de esos a
> `createEntityAdapter` es un buen ejercicio opcional, no algo que se haga
> en un hotfix.

---

## 9. Conectar el componente: `connect()` vs `useSelector`/`useDispatch`

**Cuándo lo tocás.** En cada componente que lee o despacha. Los class
components heredados usan `connect()`; los funcionales nuevos usan los
hooks. Vas a ver los dos.

**Leer del store.**

```javascript
// ── Clásico: mapStateToProps + connect ───────────────────
class RaffleTable extends React.Component {
  render() {
    if (this.props.loadingList) return <Spinner />;
    return <table>{/* usa this.props.raffles */}</table>;
  }
}
const mapStateToProps = (state) => ({
  raffles: state.raffles.items,
  loadingList: state.raffles.loadingList,
});
export default connect(mapStateToProps)(RaffleTable);
```

```javascript
// ── Toolkit + hooks: useSelector ─────────────────────────
function RaffleTable() {
  const raffles = useSelector((state) => state.raffles.items);
  const loadingList = useSelector((state) => state.raffles.loadingList);
  if (loadingList) return <Spinner />;
  return <table>{/* usa raffles */}</table>;
}
```

**Despachar.**

```javascript
// ── Clásico: mapDispatchToProps ──────────────────────────
const mapDispatchToProps = { sellNumber, reserveNumber };
export default connect(mapStateToProps, mapDispatchToProps)(NumbersBoard);
// dentro: this.props.sellNumber({ raffleId, number })
```

```javascript
// ── Hooks: useDispatch ───────────────────────────────────
function NumbersBoard() {
  const dispatch = useDispatch();
  // ...
  return <NumberCell onSell={() => dispatch(sellNumber({ raffleId, number }))} />;
}
```

> ⚠️ **Error común (igualdad referencial).** `useSelector` recalcula tras
> **cada** acción y re-renderiza si el valor devuelto cambió por
> referencia. Si el selector construye un objeto o array nuevo cada vez
> —`useSelector((s) => ({ a: s.x, b: s.y }))` o `.filter(...)` inline—
> siempre es "distinto" y el componente re-renderiza de más. Solución:
> seleccioná primitivos por separado, o usá un selector memoizado
> (`createSelector`), o pasá `shallowEqual` como segundo argumento. Con
> `mapStateToProps` el problema existía pero `connect` lo amortiguaba
> distinto; en hooks es más fácil de disparar sin darte cuenta.

---

## 10. Leer código mezclado sin marearse

En un mismo feature podés encontrar un class component con `connect()` que
despacha una action de un `createSlice`. No es contradictorio: `connect` y
`createSlice` viven en capas distintas. La action creator que genera
`createSlice` devuelve un `{ type, payload }` común y corriente, así que
`connect` la despacha igual que a una hecha a mano.

Guía rápida para ubicarte apenas abrís un archivo:

| Señal que ves | Qué estás mirando | Qué esperar |
|---|---|---|
| `import { createSlice } from '@reduxjs/toolkit'` | Slice nuevo | Immer activo: "mutar" el state es correcto |
| `const FOO = 'FOO'` + `switch (action.type)` | Reducer heredado | Inmutabilidad a mano: nunca mutar el state |
| `connect(mapStateToProps)(Comp)` | Componente heredado (suele ser clase) | Lee del store por props |
| `useSelector` / `useDispatch` | Componente nuevo (función) | Lee del store por hooks |
| `createAsyncThunk` | Async moderno | Reacciona en `extraReducers` (pending/fulfilled/rejected) |
| `dispatch => { dispatch(...) }` | Thunk heredado | Los tres estados se despachan a mano |

> 💡 Lo que **nunca** cambia entre estilos: el objeto action siempre es
> `{ type, payload }`, el reducer siempre es `(state, action) => nuevoEstado`,
> y el store siempre es una única fuente de verdad. Si te perdés, volvé a
> ese modelo y preguntá "¿qué action se despacha y qué reducer la escucha?".

---

## 11. Receta: convertir un slice manual a `createSlice`

Esto **no** es algo de hotfix: es refactor, va con su tanda de pruebas y en
un momento tranquilo. Pero es la conversión más común cuando el equipo
moderniza un módulo, así que conviene tener la receta.

**Punto de partida (clásico):**

```javascript
// types
export const RAFFLE_ADDED = 'RAFFLE_ADDED';
// creator
export const raffleAdded = (raffle) => ({ type: RAFFLE_ADDED, payload: raffle });
// reducer
function raffleReducer(state = { items: [] }, action) {
  switch (action.type) {
    case RAFFLE_ADDED:
      return { ...state, items: [...state.items, action.payload] };
    default:
      return state;
  }
}
```

**Paso a paso.**

1. Creá el `createSlice` con `name` y el `initialState` que ya tenías.
2. Por cada `case`, escribí una key en `reducers` con el cuerpo traducido a
   estilo Immer (`state.items.push(action.payload)` en vez de la copia).
3. Borrá las constantes de type y los creators a mano: ahora los da el
   slice.
4. Exportá `slice.actions` y `slice.reducer`.

**Resultado (Toolkit):**

```javascript
import { createSlice } from '@reduxjs/toolkit';

const raffleSlice = createSlice({
  name: 'raffles',
  initialState: { items: [] },
  reducers: {
    raffleAdded(state, action) {
      state.items.push(action.payload); // Immer: seguro
    },
  },
});

export const { raffleAdded } = raffleSlice.actions;
export default raffleSlice.reducer;
```

> ⚠️ **Lo que NO debés cambiar a la ligera.** Si otras partes del código
> —o un epic— dependen del string del type (`'RAFFLE_ADDED'`), tené en
> cuenta que ahora pasa a ser `'raffles/raffleAdded'`. Cualquier
> `ofType(RAFFLE_ADDED)` en un epic o cualquier comparación por string hay
> que actualizarla. Por eso es refactor con pruebas, no parche: cambiar el
> nombre público de una action tiene alcance más allá del slice.

> 💡 **Corrección mínima vs refactor.** Si el bug es "no se agrega la
> rifa", el hotfix arregla el reducer que ya existe. Convertir el slice a
> Toolkit es una mejora aparte: no la metas en el mismo commit que el
> hotfix o mezclás dos riesgos distintos en una sola prueba.

---

## 12. 🧪 Ejercicios (8)

Cortos, de consulta: confirman que sabés leer y traducir entre estilos. No
hace falta levantar la app para la mayoría; con lápiz y la tabla de la
sección 1 alcanza.

**🟢 Fácil (1–3)**

1. Dado el reducer clásico de `raffleReducer` de la sección 4, decí qué
   línea es la que garantiza la inmutabilidad y qué pasaría si la
   cambiaras por `state.items = action.payload; return state;`.
2. Traducí a `createAction` este par clásico:
   `const LOGOUT = 'LOGOUT'; const logout = () => ({ type: LOGOUT });`.
   Escribí también cómo quedaría `logout.type`.
3. Mirá un `createSlice` con `name: 'auth'` y una key `sessionExpired` en
   `reducers`. ¿Cuál es el action type que se genera y cómo se llama el
   action creator exportado?

**🟡 Intermedio (4–6)**

4. Tenés un componente con `mapStateToProps = (state) => ({ raffles:
   state.raffles.items, count: state.raffles.items.length })` y
   `connect()`. Reescribilo con `useSelector`. ¿Por qué conviene dos
   `useSelector` separados en vez de uno que devuelva el objeto entero?
5. Este thunk clásico despacha tres actions a mano
   (`FETCH_RAFFLES_PENDING/FULFILLED/REJECTED`). Convertilo a
   `createAsyncThunk` y escribí los tres `addCase` de `extraReducers`.
6. En un `createSlice` alguien escribió:
   `addRaffle(state, action) { state.items.push(action.payload); return state; }`.
   Explicá por qué está mal y dá la versión correcta.

**🟠 Difícil (7)**

7. Un module heredado tiene un epic con `ofType(RAFFLE_ADDED)` que escucha
   la action del slice clásico. El equipo migra ese slice a `createSlice`
   siguiendo la receta de la sección 11. Enumerá qué se rompe en el epic y
   cuál es el cambio mínimo para que vuelva a escuchar la action correcta.

**🔴 Muy difícil (8)**

8. Un `useSelector` que hace
   `useSelector((state) => state.raffles.items.filter((r) => r.status === 'open'))`
   dispara re-renders en cada acción, aunque las rifas abiertas no cambien.
   Diagnosticá la causa (pensá en igualdad referencial) y proponé **dos**
   soluciones distintas —una con `createSelector`, otra sin él— explicando
   el trade-off de cada una.

> 🔥 **Opcional.** Tomá el `raffleSlice` de la Fase 4 (array plano en
> `items`) y reescribilo con `createEntityAdapter`, dejando los selectores
> `selectAllRaffles` y `selectRaffleById` funcionando. Compará el before/after
> en líneas de código y en qué queda más simple de mantener.

---

## 13. 📚 Referencias

**Documentación oficial** (fijar mentalmente en Redux Toolkit 1.x; la doc
online suele mostrar la última, avisá de diferencias menores en imports).

- Redux — conceptos base (store, actions, reducers): https://redux.js.org/introduction/core-concepts
- Redux Toolkit — `createSlice`: https://redux-toolkit.js.org/api/createSlice
- Redux Toolkit — `configureStore`: https://redux-toolkit.js.org/api/configureStore
- Redux Toolkit — `createAsyncThunk`: https://redux-toolkit.js.org/api/createAsyncThunk
- Redux Toolkit — `createEntityAdapter`: https://redux-toolkit.js.org/api/createEntityAdapter
- Redux Toolkit — `createAction` / `createReducer`: https://redux-toolkit.js.org/api/createAction
- React-Redux — `useSelector` / `useDispatch` (hooks): https://react-redux.js.org/api/hooks
- React-Redux — `connect()` (heredado): https://react-redux.js.org/api/connect
- Immer — modelo de borrador/`draft`: https://immerjs.github.io/immer/

> ⚠️ Las URLs y títulos pueden cambiar entre versiones; verificá que la
> página que abrís corresponde a Redux Toolkit 1.x y no a una mayor. Las
> APIs de RTK "moderno" (listener middleware, RTK Query como default) no se
> usan en el código principal de este curso.

**Orden de lectura sugerido.** Core concepts de Redux → `createSlice` →
`createAsyncThunk` → hooks de React-Redux → volver acá a la tabla de
equivalencias cuando leas código heredado.

**Dónde sigue.** Los epics (`redux-observable`, RxJS) y su relación con los
thunks se tratan en **A7 — redux-observable épica por épica**. La
comparación con hooks puros y RTK Query moderno queda para **A8 — Puente a
React moderno** y la Fase 11.
