# 🎟️ Fase 05 — Venta de números

> Tutorial React 16 — Rifas y chances · Fase 5 de 11 · **12 horas** · ⭐ Fase central
> Depende de: Fase 4 — Rifas CRUD · Habilita: Fase 6 — redux-observable a fondo

---

## 🎯 1. Propósito

Hasta ahora tu app sabía administrar rifas, pero una rifa sin números vendidos es una carcasa bonita: no entra plata, no hay participantes, no hay nada que liquidar. Esta fase construye el corazón transaccional del sistema —la **venta de números**— y con él llega el problema que define a este dominio y que ninguna fase anterior tuvo que mirar a los ojos: **un número no se vende dos veces, y a veces dos personas lo intentan en el mismo segundo.**

Vas a montar el tablero `0000–9999`, la reserva temporal que le da al comprador unos minutos para confirmar, y la venta con **unicidad estricta**. En el camino aparece la **race condition**: ese instante en que dos clicks pelean por el mismo número y el store tiene que quedar consistente pase lo que pase. No es un caso de borde exótico de laboratorio; es el martes por la tarde en un kiosco de rifas con dos vendedores. Aprender a verla en el store, reproducirla y blindarla es la habilidad central de esta fase, y la razón de que sea la más larga del curso.

Lo que **no** vas a hacer acá es resolver la concurrencia con la artillería pesada de RxJS. La cancelación con epics (`takeUntil`, `switchMap`) es Fase 6, y punto. Fase 5 llega hasta donde llegan los thunks y un store bien pensado —que es sorprendentemente lejos— y te deja parado justo en el borde donde se ven sus límites. Ese borde, con sus grietas y todo, es exactamente lo que motiva la fase siguiente. Vas a llegar a los epics no con RxJS en abstracto, sino con un dolor concreto que querés curar.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Slice `saleSlice` (Redux Toolkit 1.8.x) con el estado de los números de la rifa activa: un mapa `byNumber` de `'0000'..'9999'` a `available | reserved | sold`, más `reservations`, flags de carga y un `error` legible que **reutiliza la forma `{ message, type }` de Fase 4**.
- [ ] Tablero `NumbersBoard` (funcional con hooks) que renderiza los 10 000 números con su estado visual, con `React.memo` por celda para que el render no colapse 💸.
- [ ] Reserva temporal con el thunk `reserveNumber` y expiración automática vía `setTimeout` (duración parametrizable, `RESERVATION_DURATION_MS`, default 5 min): `available → reserved → sold`, o de vuelta a `available` si expira.
- [ ] Venta con el thunk `sellNumber` sobre el endpoint `/sell`, con unicidad estricta y un **nuevo `type: 'conflict'`** sumado al esquema de error legible, para la carrera perdida (`409`).
- [ ] Optimistic update con rollback: la celda se marca `sold` al instante y **revierte** si el servidor rechaza; la race condition queda visible y reproducible en Redux DevTools (la pieza forense de la fase).

---

## 🚫 3. Qué queda fuera por ahora

- **Cancelación de venta/reserva con epics** (`takeUntil`, `switchMap`, teardown de suscripciones) → Fase 6. La nota de traspaso de Fase 4 es explícita y la respetamos al pie: acá la expiración de la reserva se resuelve con `setTimeout` + thunk + store, **sin un solo epic**. Meter redux-observable ahora sería robarle el alcance —y el momento didáctico— a la Fase 6.
- **Cierre por hora dura + zona horaria** (no vender después del `closesAt`) → Fase 7. Acá miramos `status === 'open'` como precondición mínima de venta, pero la lógica de tiempo, TZ y medianoche es de la Fase 7.
- **Aritmética de dinero** (total vendido, premio, liquidación sin floats) → Fase 8. El precio del número acá se muestra, no se suma en serio.
- **Participantes reales** (a quién se le vendió, contacto, forma de pago) → fase de participantes. Acá una venta registra a lo sumo un `participantId` placeholder; no hay formulario de comprador todavía.
- **Virtualización real del tablero** (react-window y amigos) → queda como deuda 💸 y ejercicio 🔥. Con `React.memo` por celda alcanza para sobrevivir; para ser óptimos, otro día.

---

## 🧠 4. Conceptos mínimos

### Por qué la venta es un problema distinto al CRUD

El CRUD de Fase 4 tenía una propiedad cómoda que no valorás hasta que la perdés: **las operaciones eran independientes.** Crear la rifa A no compite con crear la rifa B; cada thunk vivía en su burbuja. La venta rompe eso de raíz. El recurso en disputa —el número `0347` de la rifa 1— es **único y compartido.** Dos operaciones sobre el mismo número no son independientes: son rivales. Una tiene que ganar y la otra tiene que perder de forma limpia, y el store no puede quedar mintiendo que ambas ganaron.

Esto es, con nombre y apellido, **contención sobre un recurso escaso.** Un número es un asiento de avión, una entrada de recital, un dominio web libre: hay uno solo y lo quieren varios. La regla del dominio —"un número no se vende dos veces"— es una restricción de unicidad, y hacerla cumplir desde un frontend contra un backend que también puede fallar es, sin dramatizar, de lo más difícil que vas a mantener en este sistema.

### La máquina de estados de un número

Cada número vive una máquina de estados chica pero estricta:

```
available ──reserve──► reserved ──sell──► sold
    ▲                      │
    └──────expire──────────┘
```

- **`available`**: nadie lo tiene. Es el estado inicial de los 10 000.
- **`reserved`**: alguien lo apartó y tiene una ventana de tiempo (`RESERVATION_DURATION_MS`) para confirmar. Nadie más puede reservarlo ni venderlo mientras dure.
- **`sold`**: venta confirmada. Estado terminal; en esta fase, de acá no se vuelve.
- **Transición `expire`**: si la reserva vence sin venta, el número **vuelve a `available`** y queda libre para otro.

Las transiciones ilegales son la mitad del trabajo. No se puede `sell` un número `available` sin reservarlo antes (en nuestro flujo de kiosco), no se puede `reserve` uno que ya está `reserved` o `sold`, y `expire` solo aplica a `reserved`. Un reducer que no chequea el estado de **origen** antes de transicionar es un reducer que permite vender dos veces. Volvé a esa frase cada vez que escribas un `case`; es literalmente el bug que esta fase existe para prevenir.

### Reserva temporal sin epics: el `setTimeout` honesto

La reserva necesita **expirar sola.** El comprador aparta el `0347`, se distrae con el teléfono, y a los cinco minutos el número tiene que liberarse sin que nadie haga click en nada. Eso es una acción diferida en el tiempo, y la forma canónica de resolver acciones diferidas y cancelables en este stack es un epic de RxJS con `timer`. **No lo vamos a hacer así acá** —es Fase 6— y no por capricho: quiero que sufras primero la versión con `setTimeout`, para que cuando llegue el epic entiendas *exactamente qué problema te está resolviendo.*

La versión de esta fase: cuando `reserveNumber` sale bien, arrancás un `setTimeout` que, al vencer, despacha `reservationExpired`. Simple. Y con tres trampas que vas a pisar, porque son justo las que el epic resuelve gratis:

1. **Si el número se vende antes de expirar, hay que cancelar el timer.** Un `setTimeout` que sigue vivo después de la venta va a disparar `reservationExpired` sobre un número ya `sold`. Si el reducer no se protege, "libera" un número vendido. 💸
2. **Si el componente se desmonta, el timer sigue corriendo.** Navegás fuera del tablero y el `setTimeout` sobrevive, apuntando a un store que quizá ya cambió de rifa. Es un **memory leak de timer**, primo hermano del leak de suscripción que vas a cazar en Fase 6.
3. **Si cambiás de rifa, los timers de la anterior siguen agendados.** Sin una limpieza explícita, se acumulan como pestañas del navegador un viernes.

Guardamos los ids de timer **fuera** del store (en un `Map` a nivel de módulo, porque un id de `setTimeout` no es serializable y no va en Redux 💸) y los cancelamos en cada transición que corresponda. Cuando en Fase 6 reemplaces todo esto por un epic con `takeUntil`, vas a entender en el cuerpo por qué existe ese operador.

### Optimistic update y rollback: mentir rápido, corregir a tiempo

Un click de venta que se queda esperando la respuesta del servidor antes de pintar la celda se siente lento y roto. La técnica estándar es **optimista**: pintás `sold` de inmediato, asumiendo que va a salir bien, y despachás la petición en paralelo. Si el servidor confirma, no hacés nada más —ya estaba pintado—. Si el servidor **rechaza** (por ejemplo, porque otro vendedor ganó la carrera y devolvió `409`), tenés que **revertir**: volver la celda a su estado anterior.

El rollback es la parte que todo el mundo olvida, y por la que aparecen los bugs "fantasma": la celda queda `sold` en la UI pero el número nunca se vendió en el backend. Para revertir bien necesitás **guardar el estado previo** antes de la mutación optimista, porque el "anterior" de un número podría ser `available` o `reserved`, y adivinar mal te deja el store inconsistente igual. Por eso vas a ver el patrón `previousStatus` viajando dentro del thunk.

### La forma del error legible se hereda, con un tipo nuevo

Fase 4 fijó que el store nunca guarda el error crudo de axios (no es serializable y RTK protesta), sino un objeto `{ message, type }` que arma `toReadableError(error)`. Fase 5 **reutiliza esa misma forma** para que la UI de venta hable el mismo idioma de errores que ya habla la UI de rifas. Recordá el caso mixto de la §4 de la guía: la *key* va en inglés, el *valor* de `message` en español, porque lo lee el usuario.

Los tipos que venían de Fase 4 son `'timeout'`, `'http'`, `'malformed'` y `'unknown'`. La venta agrega uno: **`'conflict'`**, para cuando el backend responde `409 Conflict` porque el número ya estaba vendido. Ese tipo es el que le permite a la UI decir "ese número ya se vendió, elegí otro" en vez del genérico "ocurrió un error". Un tipo nuevo, mismo esquema; no inventamos otro shape.

> 📝 **Nota de época — el 401, igual que en Fase 4.** El interceptor global de `apiClient` (Fase 3) sigue tumbando la sesión ante cualquier 401. El slice de venta **no** maneja 401, igual que el de rifas no lo hacía. Tu `rejected` se ocupa de `500`, `timeout`, `malformed` y el nuevo `conflict`; del 401 se encarga la capa de transporte, en un solo lugar. Duplicarlo sería el mismo antipatrón que evitamos en Fase 4: dos verdades sobre qué significa "no autorizado".

### Convivencia class/hooks

Fase 4 dejó `RaffleTable` en clase (`connect()`) y `RaffleForm` en hooks para mostrar el código mezclado real del sistema. Fase 5 es toda **funcional con hooks**: el tablero y sus celdas se benefician de `useMemo`/`React.memo`/`useSelector` puntual de una forma que en clase sería más verbosa y menos clara. No fuerzo una clase donde no aporta —eso sería solemnidad de manual, no pedagogía—. Si querés seguir aceitando la convivencia, el ejercicio 🔥 correspondiente te pide portar un componente a clase y compararlo línea a línea. La regla del curso no es "usá clases siempre", es "sabé leer y escribir ambas". Acá tocó hooks por mérito propio.

---

## 💻 5. Implementación y código comentado

Trabajamos en `src/features/sales/`. El modelo de datos heredado (`db.json` de Fase 3) guarda los números con campos en español (`rifaId`, `numero`, `estado`), porque así nació el mock antes del cambio de convención; en el frontend trabajamos con el shape en inglés y traducimos en el borde —en el thunk, al leer y escribir—. Esa costura entre "cómo lo guarda el backend viejo" y "cómo lo nombra el código nuevo" es de lo más realista que vas a encontrar en mantenimiento, y la marcamos donde aparece.

> Endpoints que asumimos existentes (heredados de Fase 3/4; no los definimos acá): `GET /raffles/:id/numbers` para el tablero de una rifa, `POST /reserve` y `POST /sell`. Si el mock necesita un matiz —por ejemplo, responder `409` ante venta duplicada— se anota como supuesto del mock, no como endpoint nuevo de esta fase.

### 5.1 Constantes y helpers — `src/features/sales/constants.js`

```javascript
// src/features/sales/constants.js

// Duración de la reserva antes de expirar. Parametrizable: el default es 5
// minutos, pero los ejercicios piden bajarlo a segundos para ver la
// expiración sin quedarte mirando la pantalla. Vive en un solo lugar para
// que tablero, thunk y tests usen exactamente el mismo valor.
export const RESERVATION_DURATION_MS = 5 * 60 * 1000;

// El tablero completo: '0000', '0001', ..., '9999'. Diez mil strings de
// cuatro dígitos con padding. Se genera una sola vez (ver useMemo en el board).
export function buildAllNumbers() {
  const numbers = [];
  for (let i = 0; i <= 9999; i++) {
    // padStart mantiene el formato de cuatro dígitos: 7 -> '0007'.
    numbers.push(String(i).padStart(4, '0'));
  }
  return numbers;
}
```

### 5.2 El slice — `src/features/sales/saleSlice.js`

```javascript
// src/features/sales/saleSlice.js
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import apiClient from '../../app/apiClient';
import { RESERVATION_DURATION_MS } from './constants';

// ── Error legible: MISMA forma que Fase 4 { message, type }, con un tipo
// nuevo 'conflict' para el 409 de número ya vendido. No inventamos otro
// shape: la UI de venta reusa el idioma de errores de la UI de rifas.
// La key va en inglés; el valor de message, en español (lo lee el usuario).
function toReadableError(error) {
  if (error.code === 'ECONNABORTED') {
    return { message: 'El servidor no respondió a tiempo', type: 'timeout' };
  }
  if (error.response && error.response.status === 409) {
    // El backend nos ganó de mano: alguien vendió ese número primero.
    return { message: 'Ese número ya fue vendido. Elegí otro.', type: 'conflict' };
  }
  if (error.response) {
    return { message: 'El servidor devolvió un error', type: 'http' };
  }
  return { message: 'Ocurrió un error inesperado', type: 'unknown' };
}

// ── Guarda de forma: el backend viejo devuelve los números con campos en
// español. Validamos y traducimos al shape en inglés en el borde. Si la
// forma no es la esperada, lo tratamos como 'malformed' (igual que Fase 4:
// el 200-con-basura es el fallo más silencioso de los cuatro).
function toBoardMap(rawNumbers) {
  if (!Array.isArray(rawNumbers)) {
    throw { isMalformed: true };
  }
  const byNumber = {};
  for (const raw of rawNumbers) {
    // raw.numero / raw.estado son los nombres heredados del db.json.
    if (typeof raw.numero !== 'string' || typeof raw.estado !== 'string') {
      throw { isMalformed: true };
    }
    byNumber[raw.numero] = raw.estado; // 'available' | 'reserved' | 'sold'
  }
  return byNumber;
}

// ── THUNK: traer el tablero de la rifa activa ────────────────────────────
export const fetchNumbers = createAsyncThunk(
  'sales/fetchNumbers',
  async (raffleId, { rejectWithValue }) => {
    try {
      const response = await apiClient.get(`/raffles/${raffleId}/numbers`);
      return toBoardMap(response.data); // valida forma antes de confiar
    } catch (error) {
      if (error.isMalformed) {
        return rejectWithValue({ message: 'La respuesta vino con una forma inesperada', type: 'malformed' });
      }
      return rejectWithValue(toReadableError(error));
    }
  }
);

// ── THUNK: reservar un número ────────────────────────────────────────────
// Al resolverse con éxito, el componente que despachó agenda el setTimeout
// de expiración (ver 5.3). El thunk solo habla con el backend y devuelve el
// número reservado; la máquina de timers vive fuera del store, no acá.
export const reserveNumber = createAsyncThunk(
  'sales/reserveNumber',
  async ({ raffleId, number }, { getState, rejectWithValue }) => {
    // Precondición de negocio del lado del cliente: solo se reserva si está
    // available. Es una defensa temprana, NO la fuente de verdad: la fuente
    // de verdad es el backend (por eso además manejamos el rechazo).
    const status = getState().sales.byNumber[number];
    if (status !== 'available') {
      return rejectWithValue({ message: 'Ese número ya no está disponible', type: 'conflict' });
    }
    try {
      await apiClient.post('/reserve', { raffleId, number });
      return { number, expiresAt: Date.now() + RESERVATION_DURATION_MS };
    } catch (error) {
      return rejectWithValue(toReadableError(error));
    }
  }
);

// ── THUNK: vender un número (OPTIMISTA con rollback) ─────────────────────
export const sellNumber = createAsyncThunk(
  'sales/sellNumber',
  async ({ raffleId, number, participantId }, { dispatch, getState, rejectWithValue }) => {
    // Guardamos el estado PREVIO para poder revertir con precisión. El
    // anterior puede ser 'reserved' (flujo normal) u otra cosa; no adivinamos.
    const previousStatus = getState().sales.byNumber[number];

    // Mutación optimista: pintamos sold YA, antes de que el server responda.
    dispatch(numberSoldOptimistic({ number }));

    try {
      await apiClient.post('/sell', { raffleId, number, participantId });
      // Éxito: la celda ya está sold, no hay que hacer nada más acá.
      return { number };
    } catch (error) {
      // Rechazo: ROLLBACK al estado previo exacto. Sin esto, la celda queda
      // sold en la UI aunque el backend nunca la vendió (el bug fantasma).
      dispatch(rollbackSale({ number, previousStatus }));
      return rejectWithValue(toReadableError(error));
    }
  }
);

const saleSlice = createSlice({
  name: 'sales',
  initialState: {
    byNumber: {},          // '0347' -> 'available' | 'reserved' | 'sold'
    reservations: {},      // '0347' -> { expiresAt }
    loadingBoard: false,
    loadingSale: false,
    error: null,
  },
  reducers: {
    // Mutación optimista de venta: transición defensiva, solo si NO está
    // ya sold. Chequear el origen es lo que impide vender dos veces.
    numberSoldOptimistic(state, action) {
      const { number } = action.payload;
      if (state.byNumber[number] !== 'sold') {
        state.byNumber[number] = 'sold';
        delete state.reservations[number];
      }
    },
    // Rollback: vuelve al estado previo EXACTO que guardó el thunk.
    rollbackSale(state, action) {
      const { number, previousStatus } = action.payload;
      state.byNumber[number] = previousStatus;
    },
    // Reserva confirmada por el backend: marca reserved y registra expiresAt
    // (el timer lo arranca el componente; acá solo guardamos el vencimiento).
    numberReserved(state, action) {
      const { number, expiresAt } = action.payload;
      if (state.byNumber[number] === 'available') {
        state.byNumber[number] = 'reserved';
        state.reservations[number] = { expiresAt };
      }
    },
    // Expiración de reserva: SOLO libera si sigue reserved. Si mientras tanto
    // se vendió, el timer viejo no debe "resucitar" el número. 💸 Esta guarda
    // es la que te salva del bug del timer que libera un número vendido.
    reservationExpired(state, action) {
      const { number } = action.payload;
      if (state.byNumber[number] === 'reserved') {
        state.byNumber[number] = 'available';
        delete state.reservations[number];
      }
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchNumbers.pending, (state) => {
        state.loadingBoard = true;
        state.error = null;
      })
      .addCase(fetchNumbers.fulfilled, (state, action) => {
        state.loadingBoard = false;
        state.byNumber = action.payload;
        state.reservations = {};
      })
      .addCase(fetchNumbers.rejected, (state, action) => {
        state.loadingBoard = false;
        state.error = action.payload;
      })
      .addCase(reserveNumber.pending, (state) => {
        state.error = null;
      })
      .addCase(reserveNumber.fulfilled, (state, action) => {
        // Reusa el reducer síncrono para no duplicar la transición.
        saleSlice.caseReducers.numberReserved(state, { payload: action.payload });
      })
      .addCase(reserveNumber.rejected, (state, action) => {
        state.error = action.payload;
      })
      .addCase(sellNumber.pending, (state) => {
        state.loadingSale = true;
        state.error = null;
      })
      .addCase(sellNumber.fulfilled, (state) => {
        state.loadingSale = false;
        // La celda ya está sold por la mutación optimista.
      })
      .addCase(sellNumber.rejected, (state, action) => {
        state.loadingSale = false;
        state.error = action.payload;
        // El rollback ya se despachó dentro del thunk.
      });
  },
});

export const {
  numberSoldOptimistic,
  rollbackSale,
  numberReserved,
  reservationExpired,
} = saleSlice.actions;

// ── Selectores ───────────────────────────────────────────────────────────
export const selectNumberStatus = (number) => (state) =>
  state.sales.byNumber[number] || 'available';
export const selectSaleError = (state) => state.sales.error;
export const selectLoadingSale = (state) => state.sales.loadingSale;
export const selectLoadingBoard = (state) => state.sales.loadingBoard;

// Conteos derivados. Recorren el mapa; para 10 000 es barato, pero acordate
// de memorizarlos en el componente si los leés en cada render.
export const selectStatusCounts = (state) => {
  const counts = { available: 0, reserved: 0, sold: 0 };
  for (const number in state.sales.byNumber) {
    counts[state.sales.byNumber[number]] += 1;
  }
  return counts;
};

export default saleSlice.reducer;
```

El store suma la clave `sales` sin tocar `auth` ni `raffles`:

```javascript
// src/app/store.js
import { configureStore } from '@reduxjs/toolkit';
import authReducer from '../features/auth/authSlice';
import raffleReducer from '../features/raffles/raffleSlice';
import saleReducer from '../features/sales/saleSlice';

export const store = configureStore({
  reducer: {
    auth: authReducer,
    raffles: raffleReducer,
    sales: saleReducer, // ← nuevo en Fase 5
  },
});
```

> **Detalles con intención.** Un par de decisiones deliberadas de este slice: (1) `byNumber` es un mapa `string → status`, no un array de objetos, porque la operación que más hacés es "dame/cambiá el estado de ESTE número" y un mapa lo resuelve en O(1) sin recorrer 10 000 items. (2) Las `reservations` viven en su propia rama del state, separadas de `byNumber`, porque su ciclo de vida es distinto: un número siempre tiene estado, pero solo a veces tiene reserva. (3) Los ids de `setTimeout` **no** están en el store: no son serializables y RTK te lo va a gritar con su check de serialización. Van en el `Map` de la 5.3.

### 5.3 La máquina de timers — `src/features/sales/reservationTimers.js`

```javascript
// src/features/sales/reservationTimers.js
import { reservationExpired } from './saleSlice';

// 💸 Los ids de setTimeout NO son serializables: no van en el store. Viven
// en un Map a nivel de módulo. Es deuda técnica intencional: en Fase 6 esto
// se reemplaza por un epic con timer + takeUntil, que hace innecesario este
// Map y cancela solo. Por ahora, un Map honesto y disciplina para limpiarlo.
const timers = new Map();

// Agenda la expiración de una reserva. Si ya había un timer para ese número
// (no debería, pero por las dudas), lo pisa limpiamente.
export function scheduleExpiration(dispatch, number, durationMs) {
  cancelExpiration(number); // idempotente: evita timers duplicados
  const id = setTimeout(() => {
    timers.delete(number);
    dispatch(reservationExpired({ number }));
  }, durationMs);
  timers.set(number, id);
}

// Cancela el timer de un número (al venderlo, al liberarlo a mano).
export function cancelExpiration(number) {
  const id = timers.get(number);
  if (id !== undefined) {
    clearTimeout(id);
    timers.delete(number);
  }
}

// Cancela TODOS los timers. Se llama al desmontar el tablero o al cambiar de
// rifa. Sin esto, los timers de la rifa anterior siguen vivos: memory leak.
export function cancelAllExpirations() {
  for (const id of timers.values()) {
    clearTimeout(id);
  }
  timers.clear();
}
```

### 5.4 El tablero — `src/features/sales/NumbersBoard.jsx`

```jsx
// src/features/sales/NumbersBoard.jsx
import React, { useEffect, useMemo, useCallback } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
  fetchNumbers,
  reserveNumber,
  sellNumber,
  selectLoadingBoard,
} from './saleSlice';
import {
  scheduleExpiration,
  cancelExpiration,
  cancelAllExpirations,
} from './reservationTimers';
import { RESERVATION_DURATION_MS, buildAllNumbers } from './constants';
import NumberCell from './NumberCell';

// El tablero recibe la rifa activa por prop (viene del selector de rifas de
// Fase 4, selectEditingRaffle / la lista; NO duplicamos rifas en este slice).
export default function NumbersBoard({ raffle }) {
  const dispatch = useDispatch();
  const loadingBoard = useSelector(selectLoadingBoard);

  // Los 10 000 strings se generan una sola vez, no en cada render.
  const allNumbers = useMemo(() => buildAllNumbers(), []);

  useEffect(() => {
    dispatch(fetchNumbers(raffle.id));
    // Al desmontar o cambiar de rifa: cancelar TODOS los timers pendientes.
    // Esta línea es la que evita el memory leak de timers. Sin ella, salir
    // del tablero deja setTimeouts vivos apuntando al store viejo.
    return () => {
      cancelAllExpirations();
    };
  }, [dispatch, raffle.id]);

  const handleReserve = useCallback(
    async (number) => {
      const result = await dispatch(reserveNumber({ raffleId: raffle.id, number }));
      // Solo si la reserva salió bien agendamos su expiración.
      if (reserveNumber.fulfilled.match(result)) {
        scheduleExpiration(dispatch, number, RESERVATION_DURATION_MS);
      }
    },
    [dispatch, raffle.id]
  );

  const handleSell = useCallback(
    (number) => {
      // Vender cancela el timer de expiración: el número deja de ser
      // reservado, ya no debe expirar. Olvidar esto dispara reservationExpired
      // sobre un número sold (la guarda del reducer lo frena, pero igual
      // cancelamos por prolijidad y para no dejar timers colgando).
      cancelExpiration(number);
      dispatch(sellNumber({ raffleId: raffle.id, number, participantId: null }));
    },
    [dispatch, raffle.id]
  );

  if (loadingBoard) return <p>Cargando tablero…</p>;
  if (raffle.status !== 'open') {
    // Precondición mínima de venta. El cierre por hora dura es Fase 7; acá
    // solo miramos el estado de la rifa.
    return <p>Esta rifa no está abierta a la venta.</p>;
  }

  return (
    <div className="numbers-board" data-testid="numbers-board">
      {allNumbers.map((number) => (
        <NumberCell
          key={number}
          number={number}
          onReserve={handleReserve}
          onSell={handleSell}
        />
      ))}
    </div>
  );
}
```

> 💸 **Deuda declarada — el render de 10 000 nodos.** Renderizar las 10 000 celdas de una, aun con `React.memo`, es pesado en el montaje inicial. Lo dejamos así a propósito: `React.memo` evita los re-renders (que es el 90% del dolor en uso normal), pero el primer pintado sigue siendo caro. El pago de esta deuda es virtualización con `react-window` (ejercicio 🔥 y, eventualmente, otra fase): renderizar solo las celdas visibles. Por ahora, honesto y funcional.

### 5.5 La celda — `src/features/sales/NumberCell.jsx`

```jsx
// src/features/sales/NumberCell.jsx
import React from 'react';
import { useSelector } from 'react-redux';
import { selectNumberStatus } from './saleSlice';

// React.memo: sin esto, cambiar UN número re-renderiza los 10 000. Con memo,
// la celda solo se re-renderiza si cambia SU propio estado (el useSelector lee
// un slice puntual del store). Es la optimización que hace usable el tablero.
function NumberCell({ number, onReserve, onSell }) {
  const status = useSelector(selectNumberStatus(number));

  // El click actúa según el estado: available -> reservar, reserved -> vender.
  // sold no hace nada. Esto es el frontend interpretando la máquina de estados;
  // la fuente de verdad de la transición sigue siendo el store/backend.
  const handleClick = () => {
    if (status === 'available') onReserve(number);
    else if (status === 'reserved') onSell(number);
  };

  return (
    <button
      type="button"
      className={`number-cell number-cell--${status}`}
      data-testid={`number-${status}`}
      onClick={handleClick}
      disabled={status === 'sold'}
      title={number}
    >
      {number}
    </button>
  );
}

// La comparación por defecto de memo alcanza: number/onReserve/onSell son
// estables (useCallback en el padre). El status lo trae el useSelector.
export default React.memo(NumberCell);
```

> **El patrón a memorizar.** `useSelector` puntual por celda + `React.memo` = cada celda se suscribe solo a *su* pedacito del store y se re-renderiza solo cuando *ese* pedacito cambia. Vender el `0347` re-renderiza una celda, no diez mil. Este es el mismo patrón que salva a cualquier lista larga conectada a Redux.

### 5.6 Corrección mínima vs refactorización

Un ejemplo concreto de la distinción que el curso repite hasta el cansancio. Supongamos que en PROD aparece el bug del timer que libera un número vendido (la trampa 1 de la §4).

**Corrección mínima (hotfix):** la guarda `if (state.byNumber[number] === 'reserved')` dentro de `reservationExpired`. Una línea. Impide que la expiración toque un número que ya no está reservado. Va a PROD hoy, es segura, y no toca la arquitectura.

**Refactorización (con tiempo y tests):** mover toda la expiración a un epic de redux-observable con `timer` + `takeUntil(sellNumber.pending)`, que cancela la expiración *en el origen* cuando el número se vende, en vez de dispararla y frenarla con una guarda río abajo. Es más correcto —el timer ni siquiera llega a ejecutarse— pero toca la arquitectura, necesita RxJS y pruebas con marbles, y es exactamente lo que hace la Fase 6. La guarda es el hotfix 💸 que sostiene el sistema hasta ese refactor.

Saber cuál aplicar según el contexto —30 minutos con PROD caído vs un sprint con tests— es la habilidad de mantenimiento que esta fase entrena. No hay una respuesta "correcta" universal; hay la correcta para el martes que te toca.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. El reducer que no chequea el estado de origen.**
*Síntoma:* un número aparece `sold` dos veces, o un número vendido "vuelve" a disponible solo. *Causa:* una transición (`numberSoldOptimistic`, `reservationExpired`) que asigna el nuevo estado sin verificar el actual. *Fix mínimo:* la guarda `if (state.byNumber[number] === <estadoEsperado>)` antes de cada transición. Es baratísimo y es la diferencia entre una máquina de estados y un `=` suelto.

**2. El rollback que revierte al estado equivocado.**
*Síntoma:* tras un fallo de venta, la celda vuelve a `available` cuando debería quedar `reserved` (o al revés), y el número se puede re-reservar cuando no debía. *Causa:* el rollback asume un estado previo fijo en vez de leer el real. *Fix:* guardar `previousStatus` **antes** de la mutación optimista y revertir a ese valor exacto, como hace `sellNumber`.

**3. El timer que sobrevive al desmontaje (memory leak).**
*Síntoma:* navegás fuera del tablero y minutos después ves en DevTools un `reservationExpired` que nadie pidió, a veces sobre otra rifa. *Causa:* el `setTimeout` de la reserva no se canceló al desmontar. *Fix mínimo:* el `return () => cancelAllExpirations()` en el `useEffect`. *Refactor:* el epic de Fase 6, que se limpia solo con `takeUntil`.

**4. El optimistic update sin rollback.**
*Síntoma:* la celda queda `sold` en la UI pero el backend nunca registró la venta; al recargar, el número está disponible otra vez y aparece un duplicado más tarde. *Causa:* se pinta `sold` optimista pero el `rejected` no revierte. *Fix:* despachar `rollbackSale` en el `catch` del thunk.

### Pieza forense de esta fase — Race condition de venta en el store

Esta es **la** pieza forense de la Fase 5 (ver `FORENSE-FASE-05`): cómo se manifiesta una race condition de venta **en el store**, y cómo cazarla con las herramientas que ya sabés usar desde Fase 4 —Redux DevTools, time-travel, replay—. No reintroducimos DevTools; lo llevamos a su terreno natural.

La race condition canónica: dos ventas del mismo número casi simultáneas. En términos de acciones Redux, la secuencia problemática se ve así en el panel de DevTools:

```
sales/sellNumber/pending
numberSoldOptimistic   { number: '0347' }   ← click A pinta sold
sales/sellNumber/pending
numberSoldOptimistic   { number: '0347' }   ← click B: ya estaba sold, la guarda no repinta
sales/sellNumber/fulfilled                   ← A ganó en el backend
sales/sellNumber/rejected  { type: 'conflict' } ← B perdió: 409
rollbackSale  { number: '0347', previousStatus: 'reserved' }  ← ⚠️ el rollback de B
```

El bug sutil está en la última línea: el rollback de **B** revierte el `0347` a `reserved`, ¡pisando la venta legítima de **A**! El número terminó vendido en el backend pero `reserved` en la UI. Esto se **ve** en el Diff de DevTools: la acción `rollbackSale` muestra `sold → reserved` sobre un número que otra acción ya había vendido de verdad. El time-travel te deja pararte justo antes del rollback y confirmar que en ese punto el número ya era una venta confirmada de A. No es magia: es leer el Diff con atención.

Los ejercicios de "rompé a propósito y observá" (25 y 26) te hacen reproducir exactamente esta secuencia con `CHAOS_LEVEL` alto y dos clicks rápidos, leerla en DevTools, y proponer el blindaje: el rollback no debe revertir a ciegas si entre medio hubo una venta confirmada de otro actor. La solución robusta —cancelar la operación perdedora en el origen— es, de nuevo, territorio de epics (Fase 6). Acá el objetivo es **verla y nombrarla**, que es el 80% de resolver un incidente de concurrencia. Un bug que sabés describir es un bug medio muerto.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Levantá el mock con `CHAOS_LEVEL=off`, entrá al tablero de una rifa en `open` y confirmá que se renderizan los 10 000 números en estado `available`.
2. Hacé click en un número disponible y verificá en Redux DevTools que se despacha `reserveNumber` y la celda pasa a `reserved` (cambia de color).
3. Reservá un número y vendelo (segundo click). Confirmá en el store que quedó `sold` y que su entrada en `reservations` desapareció.
4. Bajá `RESERVATION_DURATION_MS` a `5000` (5 s), reservá un número y esperá sin tocar nada. Confirmá que a los 5 s se despacha `reservationExpired` y vuelve a `available`.
5. Identificá en el código dónde vive el estado de cada número (`byNumber`) y explicá en una frase por qué los ids de `setTimeout` **no** están en el store.
6. Cambiá el texto "Esta rifa no está abierta a la venta." y forzá una rifa en `closed` para verlo aparecer.
7. En `NumberCell`, agregá un `data-testid` que incluya el número además del estado (ej. `number-0347-reserved`) y verificalo en el DOM.
8. Usando `selectStatusCounts`, contá cuántos números hay en cada estado y mostralo en un encabezado sobre el tablero.

**🟡 Intermedio (9–17)**

9. Agregá un componente `NumberLegend` (funcional) que muestre la leyenda de colores disponible/reservado/vendido, leyendo los conteos de `selectStatusCounts`.
10. Agregá un `SalePanel` que muestre el número seleccionado y una cuenta regresiva (mm:ss) hasta que expire su reserva, leyendo `reservations[number].expiresAt`.
11. Hacé que al vender un número se cancele explícitamente su timer con `cancelExpiration` y comprobá (con un log temporal) que el `setTimeout` no llega a dispararse.
12. Escribí un JSDoc completo para `sellNumber` documentando el shape de su argumento (`raffleId`, `number`, `participantId`) y qué despacha en éxito y en fallo.
13. Agregá un valor de estado visual `expired` (distinto de `available`) solo en la UI, para que una celda recién expirada parpadee un instante antes de volver a disponible. ¿Va en el store o en el componente? Justificá.
14. Con `CHAOS_LEVEL=high`, forzá un timeout en `fetchNumbers` y confirmá en DevTools que el `error.type` guardado es `'timeout'` y el tablero muestra el mensaje, sin quedar colgado en "Cargando…".
15. Configurá el mock para que `/sell` devuelva `409` siempre. Vendé un número y confirmá que el error legible es `type: 'conflict'` con el mensaje "Ese número ya fue vendido…".
16. Reforzá `reserveNumber` para que si el backend devuelve `409` en la reserva (no solo en la venta), también se mapee a `type: 'conflict'`.
17. Agregá un botón "Liberar" en el `SalePanel` que cancele una reserva a mano antes de que expire (despachá `reservationExpired` y `cancelExpiration`). ¿Qué reusás y qué agregás?

**🟠 Difícil (18–24)**

18. Reproducí el bug del timer zombi: comentá el `return () => cancelAllExpirations()` del `useEffect`, reservá un número, navegá fuera del tablero, y documentá el `reservationExpired` que aparece en DevTools sin que nadie esté en el tablero. Después restaurá el fix.
19. Reproducí el rollback equivocado: modificá `rollbackSale` para que revierta siempre a `'available'` (ignorando `previousStatus`). Vendé un número reservado con `/sell` devolviendo `409` y explicá qué inconsistencia queda en el store.
20. Diagnóstico sin correr: te pasan un `reservationExpired` sin la guarda `=== 'reserved'`. Explicá con qué secuencia de acciones ese reducer "libera" un número que ya estaba `sold`, y dibujá la secuencia.
21. Optimista al reservar: hacé que `reserveNumber` también sea optimista (pinta `reserved` antes de la respuesta del backend) con su propio rollback. ¿Qué nuevo problema de concurrencia introduce respecto a la reserva no optimista?
22. Con el caos en `high`, provocá un `401` en `/sell` (token vencido) y confirmá por comportamiento que la sesión se cae y te manda a login **sin que `saleSlice` maneje el 401**. Explicá qué capa lo hizo.
23. Agregá un contador de "ventas rechazadas por conflicto": cada `sellNumber.rejected` con `type: 'conflict'` incrementa un número. ¿Va en `saleSlice` o en un slice de métricas aparte? Justificá.
24. Time-travel: reservá tres números, vendé uno, dejá expirar otro. En Redux DevTools viajá a la acción anterior a la expiración y describí qué muestra el tablero. Explicá por qué el time-travel puede "resucitar" visualmente una reserva ya expirada.

**🔴 Muy difícil (25–30)**

25. **La race condition, reproducida.** Con `CHAOS_LEVEL=high` y latencia en `/sell`, dispará dos ventas casi simultáneas del mismo número reservado (podés simular dos `dispatch(sellNumber(...))` seguidos). Capturá en DevTools la secuencia completa `numberSoldOptimistic → pending → fulfilled → rejected → rollbackSale` y confirmá el estado final inconsistente (`sold` en backend, `reserved` en UI).
26. Partiendo del incidente del 25, diseñá el blindaje **posible con las herramientas de esta fase** (sin epics): hacé que `rollbackSale` no revierta si, entre la mutación optimista y el rechazo, otra venta del mismo número se confirmó. ¿Qué información necesitás guardar para detectarlo? ¿Qué limitación queda que solo un epic resolvería limpio?
27. Escribí una prueba de regresión (Jest 26 + RTL 11, o pseudo-test razonado) que falle si alguien quita la guarda `=== 'reserved'` de `reservationExpired`. ¿Qué secuencia de `dispatch` y qué `expect` la hacen fallar exactamente?
28. Diagnóstico esquivo: un compañero reporta que "a veces, al vender el último número reservado justo cuando expira, queda disponible pero cobrado". Reproducilo (pista: la venta y la expiración compiten) y explicá el orden de acciones que lo produce. Proponé el fix mínimo.
29. Performance: medí con React DevTools Profiler cuántas celdas se re-renderizan al reservar un número **con** y **sin** `React.memo` en `NumberCell`. Documentá la diferencia y explicá por qué el `useSelector` puntual por celda es clave.
30. Refactor vs hotfix, escenario PROD: reportan el bug del rollback que pisa una venta legítima (§6). Tenés 30 minutos y PROD comprometido. Escribí el hotfix mínimo y, aparte, describí el refactor "correcto" con epics que harías en Fase 6. Marcá cuál es 💸.

**🔥 Opcionales**

- 🔥 Portá `NumberLegend` (o el `SalePanel`) a **class component con `connect()`** y compará línea a línea con la versión de hooks, anotando las equivalencias `useSelector` ↔ `mapStateToProps`. Mantiene viva la práctica de convivencia class/hooks del curso.
- 🔥 Reemplazá el render ingenuo por **virtualización real** con `react-window`: renderizá solo las celdas visibles. Medí el impacto en el tiempo de montaje inicial del tablero y pagá la deuda 💸 declarada en la §5.4.
- 🔥 Adelanto a Fase 6: bosquejá (sin integrarlo del todo) cómo se vería un `saleEpic` de expiración con `timer` + `takeUntil(sellNumber.pending)`. No lo conectes al store todavía; solo escribí el `.pipe()` y explicá qué reemplazaría de `reservationTimers.js`.

---

## 📚 8. Referencias

**Documentación oficial**

- https://redux-toolkit.js.org/api/createAsyncThunk — patrón `pending/fulfilled/rejected` y `rejectWithValue`, usado en `sellNumber` y `reserveNumber`. El proyecto usa RTK **1.8.x**; la doc actual puede mostrar APIs más nuevas.
- https://redux-toolkit.js.org/api/createSlice — `reducers` (síncronos, como `rollbackSale`) vs `extraReducers` con `builder`. Fijate en cómo se reusa un case reducer desde `extraReducers` (`reserveNumber.fulfilled` → `numberReserved`).
- https://react-redux.js.org/api/hooks — `useSelector` puntual por celda y `useDispatch`; la base de la optimización de render del tablero.
- https://legacy.reactjs.org/docs/hooks-effect.html — `useEffect` con función de limpieza (`return () => …`), que es lo que evita el memory leak de timers al desmontar. React 16.14.
- https://react.dev/reference/react/memo — `React.memo` para evitar los re-renders de las 10 000 celdas. (La página es de React moderno, pero el comportamiento aplica igual en 16.14.)
- https://developer.mozilla.org/es/docs/Web/API/setTimeout y https://developer.mozilla.org/es/docs/Web/API/clearTimeout — la base de la reserva temporal; ojo con que `clearTimeout` necesita el id exacto que devolvió `setTimeout`.

**Video / apoyo**

- Redux Toolkit — "Async Logic and Data Fetching" (Redux Essentials, Part 5, en https://redux.js.org). Cubre `createAsyncThunk` con el mismo patrón de esta fase, incluido el manejo optimista.

**Orden de lectura sugerido:** `createAsyncThunk` (para `sellNumber` optimista con rollback) → `createSlice` y el reuso de case reducers (para ver cómo `reserveNumber.fulfilled` llama a `numberReserved`) → `useEffect` con cleanup (para el `cancelAllExpirations`) → `React.memo` + `useSelector` (para entender por qué el tablero no colapsa) → volver al `saleSlice.js` de la §5.

> ⚠️ Las URLs, títulos y secciones pueden haber cambiado o apuntar a versiones más nuevas que las fijadas (RTK 1.8, react-redux 7.2, React 16.14). Verificá siempre que lo que leés aplique a estas versiones. Cuando la doc muestre una API que no existe en ellas, es señal de que estás leyendo material más nuevo de la cuenta.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Construiste el corazón transaccional del sistema: un tablero de 10 000 números que se reservan, se venden y se liberan solos, con un store que hace cumplir la unicidad y una máquina de estados que no permite —si escribiste bien las guardas— vender un número dos veces. Aprendiste a mentir rápido con el optimistic update y a corregir a tiempo con el rollback, y viste en Redux DevTools cómo se manifiesta una race condition de venta: no como un crash ruidoso, sino como un Diff discreto donde un `rollbackSale` pisa una venta legítima. Cazar eso con time-travel es la habilidad forense central de la fase.

También te chocaste, a propósito, contra los límites de resolver concurrencia con `setTimeout` y thunks: el timer que hay que cancelar a mano, el rollback que no se entera de que otro actor ganó la carrera, el leak si te olvidás de limpiar al desmontar. Cada una de esas trampas 💸 tiene el mismo esqueleto: **una operación asíncrona que hay que poder cancelar en el origen, no frenar con guardas río abajo.** Ese es, palabra por palabra, el problema que resuelve **redux-observable**.

La Fase 6 toma todo lo que dejaste marcado como deuda acá —la expiración, la cancelación de la venta perdedora, la limpieza al desmontar— y lo reescribe con epics: `timer`, `takeUntil`, `switchMap`, y el teardown automático de suscripciones. El `reservationTimers.js` con su `Map` a mano desaparece, jubilado por un epic que se cancela solo. Vas a llegar a esa fase no con RxJS en abstracto, sino con un problema concreto que ya te dolió y que querés resolver bien de una vez.

> **La señal de que quedó bien:** si dos vendedores se pelean por el `0347` con el caos en `high`, uno gana, el otro ve "ese número ya fue vendido", y el store nunca queda diciendo que el número está libre cuando en el backend está vendido —entonces la unicidad no es un adorno, aguanta la pelea real de un martes cualquiera.
