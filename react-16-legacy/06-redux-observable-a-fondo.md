# 🌀 Fase 06 — redux-observable a fondo

> Tutorial React 16 — Rifas y chances · Fase 6 de 11 · **12 horas** ⭐
> Depende de: Fase 5 — Venta de números · Habilita: Fase 7 — Cierre por hora y polling de resultados

---

## 🎯 1. Propósito

Fase 5 te dejó vendiendo números de verdad, con reservas que expiran solas y con la capacidad de leer una race condition en el store *después* de que ocurrió. Pero lo hizo con muletas a propósito: un `Map` de `setTimeout` a nivel de módulo (`reservationTimers.js`) que hay que cancelar a mano en tres lugares, y un `rollbackSale` que revierte a ciegas y —en una carrera perdida— puede pisar una venta legítima. Esas muletas eran deuda técnica marcada con 💸 esperando a esta fase.

Fase 6 las jubila. Acá aprendés a escribir epics de `redux-observable` que se cancelan solos: la reserva expira con un stream que se apaga cuando la venta ocurre, la venta perdedora se corta *en el origen* antes de siquiera intentar su rollback, y la validación del número tipeado cancela la petición anterior en vuelo cada vez que el usuario cambia de dígito. Esto importa para mantenimiento porque **redux-observable es la fuente de bugs más difícil de este stack**: un `takeUntil` olvidado no rompe nada visible hoy, pero deja una suscripción viva que dispara acciones fantasma después de que el componente se desmontó o el usuario cerró sesión. Vas a aprender a escribir esos epics bien y —más importante— a cazarlos cuando alguien los escribió mal.

---

## ✅ 2. Qué queda listo al terminar

- [ ] El `epicMiddleware` de redux-observable y el `rootEpic` (`combineEpics`) están montados sobre el `configureStore` existente, sin tocar los reducers de `auth`, `raffles` ni `sales`.
- [ ] `reservationTimers.js` (el `Map` de `setTimeout` de Fase 5) queda **jubilado 🪦** y reemplazado por `reservationExpirationEpic` (`timer` + `takeUntil`), que se cancela solo al vender o al desmontar.
- [ ] Un `sellNumber` perdedor se cancela **en el origen** (`switchMap`/`takeUntil`) y nunca llega a disparar `rollbackSale` sobre una venta legítima — el bug que Fase 5 solo llegó a *ver* en DevTools.
- [ ] Existe `validateNumberEpic` con `debounceTime` + `switchMap`: valida el número tipeado en tiempo real y cancela la petición en vuelo cuando el usuario cambia de número.
- [ ] `retrySellEpic` reintenta automáticamente ante `timeout`/`http` (nunca ante `conflict`), con backoff, y el estudiante puede reproducir un **memory leak por suscripción sin cancelar** y cazarlo con Redux DevTools + el patrón `takeUntil(logout$)`.

---

## 🚫 3. Qué queda fuera por ahora

- **Polling de resultados de la lotería** (`pollingEpic` contra `apiLoteria` en el puerto `3002`) → Fase 7. Acá se sientan las bases (`interval`/`timer`, `takeUntil(STOP_POLLING)`), pero el polling real de resultados y su forma de respuesta son territorio de la próxima fase.
- **Cierre de la rifa por hora dura y zona horaria** → Fase 7. Los epics de esta fase siguen mirando `status === 'open'` como precondición plana; el reloj con TZ y medianoche llega después.
- **Testing formal de epics (marble testing con `TestScheduler`)** → Fase 10. Acá se explican los diagramas de canicas como modelo mental para *leer* un epic, pero los tests automatizados se escriben en Fase 10.
- **Liquidación y cálculo monetario** → Fase 8. Ningún epic de esta fase calcula premios ni toca dinero.
- **`redux-saga` como alternativa** → apéndice comparativo / ejercicio 🔥. El curso usa redux-observable; saga aparece solo como comparación mental.

---

## 🧠 4. Conceptos mínimos

### Qué es un epic y por qué no es "un thunk más grande"

Un thunk es una función que corre una vez, hace su trabajo asíncrono y termina. Un epic es distinto: es una **función que recibe un stream de todas las acciones** que pasan por el store (`action$`) y devuelve **otro stream de acciones** que se van a despachar. No corre una vez: está siempre escuchando. La firma es `(action$, state$) => action$` y esa simetría —acciones entran, acciones salen— es toda la idea.

La ganancia sobre el thunk aparece cuando el problema es *temporal* y no solo *asíncrono*: "esperá 5 minutos pero cancelá si la venta ocurre antes", "debouncea las validaciones mientras el usuario tipea", "reintentá con backoff pero solo si el error es transitorio", "cancelá todo lo que esté en vuelo cuando el usuario haga logout". Todo eso en un thunk se resuelve con `setTimeout`, flags y `AbortController` cosidos a mano; en un epic es un operador de RxJS que ya viene resuelto y —esto es lo que de verdad importa— **se cancela solo cuando la suscripción se cierra**.

### `.pipe()` y el puñado de operadores que vas a usar todo el curso

`.pipe()` encadena operadores. No hay magia: cada operador toma un Observable y devuelve otro transformado. Los que importan para mantener esta app:

- **`map`** — transforma cada valor. `map(res => sellSucceeded(res.data))`. Uno entra, uno sale.
- **`mergeMap`** — por cada acción entrante arranca un Observable interno y **deja correr todos en paralelo**. Sirve cuando las operaciones son independientes (reservar el `0347` no debe cancelar la expiración del `0912`).
- **`switchMap`** — por cada acción entrante arranca un Observable interno pero **cancela el anterior si todavía no terminó**. Es la herramienta de "solo me importa el último": validación mientras se tipea, o la venta que gana la carrera. El anterior se aborta, incluida su petición HTTP en vuelo.
- **`debounceTime(ms)`** — espera a que pare de llegar valores por `ms` antes de dejar pasar el último. Clásico de búsqueda/validación en formularios.
- **`throttleTime(ms)`** — deja pasar el primero e ignora los siguientes por `ms`. Lo opuesto útil del debounce: para clicks repetidos de "Vender" que no querés multiplicar.
- **`retry` / `retryWhen`** — reintenta la fuente si emite error. `retryWhen` te deja meter backoff y decidir *qué* errores reintentar.
- **`catchError`** — atrapa el error del stream y lo reemplaza por otro Observable (típicamente `of(sellFailed(...))`). **Sin `catchError`, un error mata el epic entero y deja de escuchar para siempre** — este es el error #1 de la sección 6.
- **`takeUntil(notifier$)`** — deja pasar valores hasta que `notifier$` emite; ahí completa y **cancela la suscripción interna**. Es el operador de cancelación de todo el curso: cancelar al vender, al desmontar, al hacer logout.

### `ofType`: pattern matching sobre el stream de acciones

`action$` recibe *todas* las acciones. `ofType(...)` es el filtro que deja pasar solo las que te interesan, comparando por `action.type`. Como los thunks de RTK exponen su tipo (`sellNumber.pending.type`, `reserveNumber.fulfilled.type`), un epic puede reaccionar a cualquier momento del ciclo de vida de un thunk. `ofType(reserveNumber.fulfilled.type)` significa "cada vez que una reserva se confirmó, hacé algo" — que es exactamente donde arranca la expiración.

### Por qué un stream se cancela solo y un `setTimeout` no

Un `setTimeout` es fuego y olvido: una vez agendado, corre pase lo que pase, y para evitar que dispare tenés que guardar su `id` y llamar `clearTimeout` a mano, en cada camino posible de salida. Fase 5 hizo justo eso en `reservationTimers.js` y lo pagó con tres puntos de cancelación manual (`cancelExpiration`, `cancelAllExpirations`, idempotencia). Un Observable, en cambio, tiene *teardown*: cuando la suscripción se cierra —porque `takeUntil` emitió, o porque el epic se desuscribió— todos sus recursos internos (incluido el `timer`) se limpian solos. No hay `id` que guardar ni `clear` que llamar. Esa es, en una frase, la razón de existir de esta fase.

### Convivencia de estilos en esta fase

Los epics son módulos aparte, no viven en componentes; no hay clase ni hook que forzar acá. El punto de convivencia relevante es otro: los epics **conviven con los thunks de Fase 4/5, no los reemplazan**. El thunk sigue siendo la herramienta correcta para un pedido asíncrono simple de una sola pasada (traer el tablero, crear una rifa). El epic entra solo cuando hay una dimensión temporal o de cancelación que el thunk no puede expresar limpio. No modernices por modernizar: `fetchNumbers` sigue siendo un thunk en Fase 6.

---

## 💻 5. Implementación y código comentado

### 5.1 Montar redux-observable sobre el store existente

Fase 5 dejó `configureStore` con tres reducers. Fase 6 le suma el middleware de epics **sin tocar esos reducers**. Lo único nuevo es el `epicMiddleware` y el `rootEpic`.

```javascript
// src/app/store.js
import { configureStore } from '@reduxjs/toolkit';
import { createEpicMiddleware } from 'redux-observable';
import authReducer from '../features/auth/authSlice';
import raffleReducer from '../features/raffles/raffleSlice';
import saleReducer from '../features/sales/saleSlice';
import { rootEpic } from './rootEpic';

// El middleware de epics: es el puente entre el stream de acciones
// de Redux y nuestros epics. Se crea una sola vez.
const epicMiddleware = createEpicMiddleware();

export const store = configureStore({
  reducer: {
    auth: authReducer,
    raffles: raffleReducer,
    sales: saleReducer, // el saleSlice de Fase 5, congelado, sin tocar
  },
  // getDefaultMiddleware trae thunk, immutable-check y serializable-check.
  // Concatenamos el de epics; NO reemplazamos el default (romperíamos los thunks de Fase 4/5).
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(epicMiddleware),
});

// El rootEpic se ejecuta DESPUÉS de crear el store, nunca antes:
// si lo corrés antes, action$ todavía no existe y explota.
epicMiddleware.run(rootEpic);
```

```javascript
// src/app/rootEpic.js
import { combineEpics } from 'redux-observable';
import { reservationExpirationEpic } from '../features/sales/epics/reservationExpirationEpic';
import { sellNumberEpic } from '../features/sales/epics/sellNumberEpic';
import { validateNumberEpic } from '../features/sales/epics/validateNumberEpic';
import { retrySellEpic } from '../features/sales/epics/retrySellEpic';
import { cancelOnLogoutEpic } from '../features/sales/epics/cancelOnLogoutEpic';

/**
 * combineEpics fusiona todos los epics en uno solo. El orden no importa
 * para la ejecución (todos escuchan action$ en paralelo), pero mantenelo
 * estable para que el diff en code review sea legible.
 */
export const rootEpic = combineEpics(
  reservationExpirationEpic,
  sellNumberEpic,
  validateNumberEpic,
  retrySellEpic,
  cancelOnLogoutEpic
);
```

> 💸 **Deuda intencional.** Importar cada epic a mano en `rootEpic.js` no escala si el curso creciera a decenas de epics; lo correcto sería un barrel o un registro automático. No lo resolvemos acá porque con cinco epics el costo es cero y el explícito se lee mejor para aprender. Si Fase 7 suma `pollingEpic`, se agrega una línea más y punto.

### 5.2 `reservationExpirationEpic`: jubilando 🪦 el `reservationTimers.js`

Este es el reemplazo directo de la deuda estrella de Fase 5. En Fase 5, cuando `reserveNumber` se confirmaba, se agendaba un `setTimeout` en `reservationTimers.js` y había que cancelarlo a mano al vender. Acá, el mismo comportamiento es un stream que se apaga solo.

```javascript
// src/features/sales/epics/reservationExpirationEpic.js
import { ofType } from 'redux-observable';
import { timer } from 'rxjs';
import { map, mergeMap, takeUntil, filter } from 'rxjs/operators';
import {
  reserveNumber,
  sellNumber,
  reservationExpired,
} from '../saleSlice';
import { RESERVATION_DURATION_MS } from '../constants';

/**
 * Cuando una reserva se confirma (reserveNumber.fulfilled), esperamos
 * RESERVATION_DURATION_MS y despachamos reservationExpired para ese número.
 *
 * La cancelación clave: takeUntil corta la espera si, para ESE MISMO número,
 * llega una venta confirmada (sellNumber.fulfilled) antes de que expire.
 * Cuando eso pasa, el timer interno se limpia solo: no hay clearTimeout,
 * no hay Map de ids, no hay reservationTimers.js. Esa es la jubilación 🪦.
 */
export const reservationExpirationEpic = (action$) =>
  action$.pipe(
    ofType(reserveNumber.fulfilled.type),
    // mergeMap y no switchMap: dos reservas de números distintos deben
    // correr en paralelo. switchMap cancelaría la expiración anterior
    // apenas se reserva otro número — bug clásico (ejercicio de Fase 5).
    mergeMap((action) => {
      const { raffleId, number } = action.payload;
      return timer(RESERVATION_DURATION_MS).pipe(
        map(() => reservationExpired({ raffleId, number })),
        // Cortá la espera si ESTE número se vende antes de expirar.
        takeUntil(
          action$.pipe(
            ofType(sellNumber.fulfilled.type),
            filter((sold) => sold.payload.number === number)
          )
        )
      );
    })
  );
```

Notá lo que *no* está: ni `scheduleExpiration`, ni `cancelExpiration`, ni `cancelAllExpirations`, ni idempotencia manual. Todo eso lo reemplaza el teardown del `takeUntil`. El reducer `reservationExpired` de Fase 5 no cambia una línea: sigue chequeando `if (state.byNumber[number] === 'reserved')` antes de transicionar. El epic despacha, el reducer decide si aplica.

### 5.3 `sellNumberEpic`: cancelar al perdedor *en el origen*

Este resuelve la pieza forense central de Fase 5: el `rollbackSale` que revierte a ciegas y puede pisar una venta legítima cuando dos actores corren por el mismo número. La idea de Fase 6 es que el perdedor **ni siquiera llegue a hacer rollback**: se cancela antes.

```javascript
// src/features/sales/epics/sellNumberEpic.js
import { ofType } from 'redux-observable';
import { from, of } from 'rxjs';
import { map, switchMap, catchError, takeUntil, filter } from 'rxjs/operators';
import apiClient from '../../../api/apiClient'; // MISMA instancia de Fase 3/4/5
import {
  numberSoldOptimistic,
  rollbackSale,
  sellCancelled,
} from '../saleSlice';
import { toReadableError } from '../../raffles/raffleSlice';

// Action type de Redux clásico para el intento de venta que dispara el epic.
// El componente despacha { type: SELL_NUMBER, payload: { raffleId, number, participant } }.
export const SELL_NUMBER = 'SELL_NUMBER';

/**
 * Vende un número reaccionando a SELL_NUMBER. Envolvemos la promesa de
 * axios con from(...) para tener un Observable cancelable.
 *
 * switchMap sobre el número: si el usuario dispara otra venta del MISMO
 * número mientras la anterior está en vuelo, la anterior se cancela
 * (su petición se aborta) y NUNCA emite su rollback. El perdedor muere
 * en el origen, no en el reducer. Ese es el arreglo que Fase 5 no podía dar.
 */
export const sellNumberEpic = (action$) =>
  action$.pipe(
    ofType(SELL_NUMBER),
    switchMap((action) => {
      const { raffleId, number, participant } = action.payload;
      return from(
        apiClient.post(`/raffles/${raffleId}/numbers/${number}/sell`, { participant })
      ).pipe(
        map((response) =>
          // Éxito: confirmamos. El optimista ya se despachó en el componente.
          numberSoldOptimistic({
            raffleId,
            number,
            participantId: response.data.participantId,
          })
        ),
        catchError((error) => {
          const readable = toReadableError(error); // reusa 'conflict' de Fase 5
          // Solo el rollback llega si de verdad fallamos por conflicto/http/timeout.
          return of(rollbackSale({ raffleId, number, error: readable }));
        }),
        // Si llega un logout mientras la venta está en vuelo, cancelamos
        // y despachamos sellCancelled (type: 'cancelled', ver saleSlice).
        takeUntil(
          action$.pipe(ofType('LOGOUT'), map(() => sellCancelled({ number })))
        )
      );
    })
  );
```

> ⚠️ **Sutileza de `takeUntil` + `sellCancelled`.** `takeUntil` corta el stream cuando el notifier emite, pero **no emite el valor del notifier hacia afuera**: solo lo usa como señal. Si querés que `sellCancelled` llegue al store, no lo pongas dentro del `takeUntil`; separalo en `cancelOnLogoutEpic` (5.6). Este comentario del código está simplificado a propósito; el ejercicio 22 te hace corregir exactamente esta confusión.

`sellCancelled` es una acción nueva de Fase 6 que usa el mismo shape de error `{ message, type }` con el `type: 'cancelled'` que la nota de continuidad anticipó. No inventamos otro shape.

### 5.4 `validateNumberEpic`: validación en tiempo real con `debounceTime` + `switchMap`

El caso de uso motivador de `debounce`: un campo donde el operador tipea el número que quiere vender (`0347`) y queremos verificar contra el servidor si sigue disponible, sin disparar una petición por tecla y sin condiciones de carrera entre respuestas.

```javascript
// src/features/sales/epics/validateNumberEpic.js
import { ofType } from 'redux-observable';
import { from, of } from 'rxjs';
import { map, debounceTime, switchMap, catchError } from 'rxjs/operators';
import apiClient from '../../../api/apiClient';
import {
  numberValidationRequested,
  numberValidationSucceeded,
  numberValidationFailed,
} from '../saleSlice';
import { toReadableError } from '../../raffles/raffleSlice';

/**
 * El componente despacha numberValidationRequested({ raffleId, number })
 * en cada cambio del input. El epic:
 *  - debounceTime(300): espera a que el usuario pare de tipear 300ms.
 *  - switchMap: cada nuevo número CANCELA la validación anterior en vuelo.
 *    Sin switchMap, la respuesta del '034' podría llegar después de la
 *    del '0347' y pintar un estado viejo (race condition de respuestas).
 */
export const validateNumberEpic = (action$) =>
  action$.pipe(
    ofType(numberValidationRequested.type),
    debounceTime(300),
    switchMap((action) => {
      const { raffleId, number } = action.payload;
      return from(
        apiClient.get(`/raffles/${raffleId}/numbers/${number}`)
      ).pipe(
        map((response) =>
          numberValidationSucceeded({
            number,
            status: response.data.status, // 'available' | 'reserved' | 'sold'
          })
        ),
        catchError((error) =>
          of(numberValidationFailed({ number, error: toReadableError(error) }))
        )
      );
    })
  );
```

Este epic **no** maneja 401: si el `get` devuelve 401, el interceptor global de `apiClient` (Fase 4/5) tumba la sesión. El `catchError` de acá se ocupa de `http`, `timeout`, `malformed`; del 401 se encarga el transporte, igual que siempre.

### 5.5 `retrySellEpic`: reintento automático solo para errores transitorios

Reintentar tiene una trampa: **nunca reintentes un `conflict`**. Si el número ya se vendió, reintentar diez veces devuelve diez `409`. Solo tienen sentido los errores transitorios (`timeout`, `http` 5xx).

```javascript
// src/features/sales/epics/retrySellEpic.js
import { ofType } from 'redux-observable';
import { from, of, throwError, timer } from 'rxjs';
import { map, switchMap, catchError, retryWhen, mergeMap, filter } from 'rxjs/operators';
import apiClient from '../../../api/apiClient';
import { numberSoldOptimistic, rollbackSale } from '../saleSlice';
import { toReadableError } from '../../raffles/raffleSlice';

export const SELL_NUMBER_WITH_RETRY = 'SELL_NUMBER_WITH_RETRY';
const MAX_RETRIES = 3;

/**
 * Igual que sellNumberEpic pero con reintento de errores transitorios.
 * retryWhen recibe el stream de errores y decide, por cada uno, si
 * reintentar (emitiendo un timer de backoff) o rendirse (re-lanzando
 * el error para que catchError lo convierta en rollback).
 */
export const retrySellEpic = (action$) =>
  action$.pipe(
    ofType(SELL_NUMBER_WITH_RETRY),
    switchMap((action) => {
      const { raffleId, number, participant } = action.payload;
      return from(
        apiClient.post(`/raffles/${raffleId}/numbers/${number}/sell`, { participant })
      ).pipe(
        map((response) =>
          numberSoldOptimistic({
            raffleId,
            number,
            participantId: response.data.participantId,
          })
        ),
        retryWhen((errors$) =>
          errors$.pipe(
            mergeMap((error, index) => {
              const readable = toReadableError(error);
              // NUNCA reintentar un conflict: el número ya no es nuestro.
              const isTransient = readable.type === 'timeout' || readable.type === 'http';
              if (!isTransient || index >= MAX_RETRIES) {
                return throwError(error); // rendirse -> lo atrapa catchError abajo
              }
              // Backoff exponencial simple: 500ms, 1000ms, 2000ms.
              return timer(500 * 2 ** index);
            })
          )
        ),
        catchError((error) =>
          of(rollbackSale({ raffleId, number, error: toReadableError(error) }))
        )
      );
    })
  );
```

> 💸 **Deuda intencional.** `retrySellEpic` y `sellNumberEpic` comparten casi todo el cuerpo. Lo correcto sería extraer un helper `sellRequest$(payload)` reutilizable. No lo hacemos acá para que veas los dos flujos completos lado a lado; el ejercicio 27 te pide justamente refactorizarlos a un helper común sin cambiar el comportamiento.

### 5.6 `cancelOnLogoutEpic`: apagar todo lo que esté en vuelo al cerrar sesión

El patrón `takeUntil(logout$)` merece su propio epic explícito para lo que Fase 7 va a necesitar (cancelar polling). Acá lo introducimos con un caso simple: al `LOGOUT`, emitimos una acción que le dice a los reducers que limpien el estado transitorio de venta.

```javascript
// src/features/sales/epics/cancelOnLogoutEpic.js
import { ofType } from 'redux-observable';
import { map } from 'rxjs/operators';
import { salesReset } from '../saleSlice';

// LOGOUT es un action type clásico en SCREAMING_SNAKE_CASE (diccionario §4).
// Su origen real (authSlice de Fase 2) está pendiente de confirmar contra
// el .md de Fase 2; acá dependemos solo de su type string, no de su creator.
export const cancelOnLogoutEpic = (action$) =>
  action$.pipe(
    ofType('LOGOUT'),
    map(() => salesReset())
  );
```

> 💸 **Pendiente heredado.** Los nombres de auth de Fase 2 (`login`, `logout`, `LOGOUT`) siguen sin verificar contra su `.md` aprobado. Este epic depende solo del *string* `'LOGOUT'`, no del action creator, para no acoplarse a algo no confirmado. Si Fase 7 necesita reaccionar al logout de forma más rica, confirmá esos nombres primero (ver §4 de la nota de continuidad).

### 5.7 Acciones nuevas en `saleSlice` (extensión, no reescritura)

Fase 6 agrega reducers síncronos al `saleSlice` congelado de Fase 5, sin tocar los existentes. Todos respetan la máquina de estados con su guarda de origen.

```javascript
// Fragmento a AGREGAR dentro de reducers: {} del saleSlice de Fase 5.
// NO se reescribe nada de lo que ya existía (numberSoldOptimistic,
// rollbackSale, numberReserved, reservationExpired siguen igual).

reducers: {
  // ...los reducers de Fase 5, intactos...

  // Venta cancelada por logout/switchMap: shape de error con type 'cancelled'.
  sellCancelled(state, action) {
    const { number } = action.payload;
    state.loadingSale = false;
    // No revierte estado de dominio: la venta nunca llegó a aplicarse.
    // Solo deja rastro del motivo para la UI/trazabilidad.
    state.error = { message: 'La venta se canceló.', type: 'cancelled' };
    void number; // referencia explícita para trazas; ver ejercicio 12
  },

  // --- Validación en tiempo real ---
  numberValidationRequested(state) {
    state.validating = true;
    state.validationResult = null;
  },
  numberValidationSucceeded(state, action) {
    state.validating = false;
    state.validationResult = action.payload.status; // 'available' | ...
  },
  numberValidationFailed(state, action) {
    state.validating = false;
    state.error = action.payload.error;
  },

  // Limpieza al logout: resetea SOLO lo transitorio, no el tablero.
  salesReset(state) {
    state.loadingSale = false;
    state.loadingBoard = false;
    state.validating = false;
    state.validationResult = null;
    state.error = null;
  },
},
```

Recordá exportar los nuevos creators junto a los de Fase 5:

```javascript
export const {
  numberSoldOptimistic, rollbackSale, numberReserved, reservationExpired, // Fase 5
  sellCancelled, numberValidationRequested, numberValidationSucceeded,     // Fase 6
  numberValidationFailed, salesReset,
} = saleSlice.actions;
```

### 5.8 El memory leak que vas a provocar a propósito

Un epic mal escrito no falla ruidosamente: sigue vivo emitiendo acciones fantasma. El caso canónico es un epic de "polling embrionario" sin `takeUntil`. Lo introducimos acá roto, para cazarlo en la sección 6 y arreglarlo en Fase 7.

```javascript
// src/features/sales/epics/boardRefreshEpic.js  💸 VERSIÓN CON LEAK A PROPÓSITO
import { ofType } from 'redux-observable';
import { interval } from 'rxjs';
import { map, switchMap } from 'rxjs/operators';
import { fetchNumbers } from '../saleSlice';

// ❌ BUG DELIBERADO: este interval nunca se cancela. Si el usuario navega
// fuera del tablero o hace logout, sigue disparando fetchNumbers para siempre.
// Falta un takeUntil(action$.pipe(ofType('STOP_BOARD_REFRESH' | 'LOGOUT'))).
export const boardRefreshEpic = (action$) =>
  action$.pipe(
    ofType('START_BOARD_REFRESH'),
    switchMap(({ payload }) =>
      interval(5000).pipe(map(() => fetchNumbers(payload.raffleId)))
    ) // <-- acá falta el takeUntil. Ese es el leak.
  );
```

La corrección (que aplicás en el ejercicio de "rompe a propósito" y consolidás en Fase 7) es un `takeUntil` sobre `STOP_BOARD_REFRESH` o `LOGOUT`, exactamente el mismo patrón de `reservationExpirationEpic`.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Olvidar `catchError` y matar el epic entero.** Síntoma: la primera venta que falla deja de disparar *todas* las ventas futuras, sin error visible. Causa: un error no atrapado se propaga hasta el epic raíz y completa el Observable — el epic deja de escuchar `action$` para siempre. Fix mínimo: `catchError` **dentro** del `mergeMap`/`switchMap` (en el Observable interno), no afuera. Si lo ponés afuera, atrapás el error pero igual perdés el stream externo.

**2. `mergeMap` donde iba `switchMap` (y viceversa).** Síntoma con `mergeMap` en validación: respuestas viejas pisan a las nuevas (tipeás `0347`, ves el estado de `034`). Síntoma con `switchMap` en expiración: reservar un segundo número cancela la expiración del primero, que ya nunca se libera. Fix: `switchMap` cuando solo importa el último; `mergeMap` cuando cada operación es independiente. No es cosmético — es corrección vs. bug.

**3. `takeUntil` mal ubicado en el `.pipe()`.** Síntoma: la cancelación no ocurre o cancela de más. Causa: `takeUntil` corta *todo lo que está antes* de él en el pipe. Si lo ponés antes del `map` de éxito, cancelás también la emisión buena. Regla práctica: `takeUntil` casi siempre va **último** en el pipe interno. Distinción mínima vs. refactor: mover una línea es el fix mínimo; rediseñar qué stream es el notifier es refactor.

**4. Correr `epicMiddleware.run(rootEpic)` antes de crear el store.** Síntoma: `Cannot read property 'pipe' of undefined` al arrancar. Causa: el middleware necesita el store montado para tener `action$`. Fix: `run` siempre después de `configureStore`.

### Pieza forense de esta fase — Debug de epics: memory leak por no `takeUntil`, switchMap vs mergeMap

Fase 5 te enseñó a leer el store en el tiempo (Redux DevTools, time-travel). Fase 6 suma **leer el flujo de un Observable en el tiempo**: poner un breakpoint dentro del `.pipe()`, ver qué acciones entran y salen, y —lo más difícil— detectar una suscripción que sigue viva después de que debió morir.

El ejercicio de **"rompe a propósito y observá"** de esta fase usa el `boardRefreshEpic` con leak de 5.8:

1. Despachá `START_BOARD_REFRESH` con una rifa y andá al tablero.
2. En Redux DevTools, observá los `fetchNumbers/pending` cada 5 segundos: normal.
3. Navegá fuera del tablero (o simulá logout despachando `LOGOUT`).
4. **Síntoma forense:** los `fetchNumbers/pending` **siguen apareciendo** cada 5s aunque no haya tablero montado. Esa es la suscripción zombi.
5. Correlacioná: en la pestaña Network de DevTools, los `GET /raffles/:id/numbers` siguen saliendo. En un sistema real esto es carga de servidor invisible y batería del cliente drenada.
6. Fix: agregá `takeUntil(action$.pipe(ofType('LOGOUT', 'STOP_BOARD_REFRESH')))` al final del pipe interno. Repetí desde el paso 1 y confirmá que los pending **paran** al salir.

Este es uno de los ≥4 incidentes de RxJS/epics del curso. Su post-mortem (sin culpabilización) es material del ejercicio 30.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–7)**
1. Montá `epicMiddleware` en tu store local y confirmá con un epic vacío (`(action$) => action$.pipe(ofType('NADA'))`) que la app arranca sin errores.
2. Escribí un epic mínimo que, ante `PING`, despache `PONG`. Verificalo en Redux DevTools.
3. Cambiá `debounceTime(300)` a `debounceTime(1500)` en `validateNumberEpic` y describí, tipeando en el input, la diferencia perceptible.
4. Explicá en un comentario por qué `reservationExpirationEpic` usa `mergeMap` y no `switchMap`, con un ejemplo de dos números.
5. Agregá un `console.log` dentro del `map` de `sellNumberEpic` y observá cuándo se imprime respecto del optimistic update del componente.
6. Listá, mirando `rootEpic.js`, todos los `action.type` a los que reacciona la app hoy vía `ofType`.
7. Dado el shape `{ message, type }`, enumerá los valores de `type` vigentes tras Fase 6 (incluí `'cancelled'`) y de qué fase vino cada uno.

**🟡 Intermedio (8–15)**
8. Reescribí `reservationExpirationEpic` para que, además de expirar, despache una acción de log `numberExpirationLogged` con timestamp, sin agregar otro epic (extendé el pipe).
9. Hacé que `validateNumberEpic` ignore números malformados (longitud ≠ 4) *antes* del `debounceTime`, con un `filter`.
10. Agregá `throttleTime(1000)` al disparo de `SELL_NUMBER` para que clicks repetidos de "Vender" no generen ventas duplicadas. Explicá por qué `throttle` y no `debounce` acá.
11. Convertí `cancelOnLogoutEpic` para que además cancele cualquier validación en vuelo, no solo resetee el estado.
12. En `sellCancelled`, el `void number` está por trazabilidad. Reemplazalo por un log estructurado `{ number, at }` y explicá qué agregarías para correlacionar con un request ID.
13. Escribí un epic que ante `reserveNumber.rejected` con `type: 'conflict'` despache una acción de UI que marque el número como "lo perdiste".
14. Simulá con el middleware de caos (Fase 3) un `timeout` en `/sell` y confirmá que `retrySellEpic` reintenta 3 veces con el backoff esperado (mirá los timestamps en Network).
15. Explicá por qué `retrySellEpic` re-lanza el error (`throwError`) para un `conflict` en vez de reintentarlo, con la consecuencia concreta si no lo hiciera.

**🟠 Difícil (16–23)**
16. **Diagnóstico:** te dan `sellNumberEpic` con `catchError` puesto *fuera* del `switchMap`. Reproducí el síntoma (una venta fallida mata todas las futuras), localizá la línea y aplicá el fix mínimo.
17. **Diagnóstico:** en un repo, `validateNumberEpic` usa `mergeMap` en lugar de `switchMap`. Provocá la carrera de respuestas (tipeá rápido `034` → `0347`) y mostrá en Network cómo una respuesta vieja pinta el estado.
18. Reproducí el leak del `boardRefreshEpic` (5.8) siguiendo la pieza forense, y aplicá el `takeUntil`. Confirmá con Network que los `GET` paran al logout.
19. **Diagnóstico:** un epic tiene `takeUntil` puesto *antes* del `map` de éxito. Explicá por qué la venta legítima nunca llega al store y corregí la posición.
20. Implementá que `reservationExpirationEpic` cancele la expiración también si llega `reservationExpired` manual del mismo número (doble fuente de cancelación en el `takeUntil`).
21. Medí (Performance de DevTools) la diferencia de peticiones entre `validateNumberEpic` con y sin `debounceTime` tipeando un número completo dígito a dígito.
22. **Diagnóstico:** corregí la confusión señalada en 5.3 — `sellCancelled` dentro del `takeUntil` no llega al store. Moné la emisión de `sellCancelled` al `cancelOnLogoutEpic` y confirmá que ahora sí aparece.
23. Escribí un epic que, ante `LOGOUT`, cancele **todas** las reservas activas en vuelo, y explicá por qué el `takeUntil` de `reservationExpirationEpic` no alcanzaba (pista: ese `takeUntil` solo escucha ventas, no logout).

**🔴 Muy difícil (24–30)**
24. **Diagnóstico + regresión:** repo con bug intermitente — a veces `reservationExpired` dispara sobre un número ya vendido. Encontrá la condición de carrera entre el `timer` y el `takeUntil` cuando venta y expiración ocurren casi en el mismo ms, y proponé el fix (pista: orden de emisión).
25. Diseñá un experimento con tres inputs de validación simultáneos (tres números distintos) y documentá, con `switchMap` vs `mergeMap`, cuál config es correcta y por qué. ¿Cambia la respuesta si es el *mismo* número en tres campos?
26. Reproducí un leak de suscripción que **no** sea de `interval`: un epic con `takeUntil` cuyo notifier nunca emite (typo en el `ofType`). Cazalo mostrando que la suscripción sigue viva en un breakpoint.
27. Refactorizá `sellNumberEpic` y `retrySellEpic` a un helper común `sellRequest$(payload)` sin cambiar el comportamiento observable de ninguno. Justificá qué quedó en el helper y qué en cada epic.
28. Explicá, en prosa, cómo debuggearías un epic que dispara una acción *después* de que el componente se desmontó: qué mirás en Redux DevTools, qué en React DevTools, y cómo correlacionás ambos con un request ID.
29. Compará (sin implementar) cómo se vería la cancelación de la venta perdedora en `redux-saga` (con `takeLatest`/`cancel`) frente al `switchMap` de esta fase. ¿Qué se gana y qué se pierde en legibilidad de mantenimiento?
30. Escribí el post-mortem completo (plantilla de la Guía de Estilo §12: síntoma, reproducción, evidencia, causa raíz, corrección, prueba de regresión, prevención, sin culpabilización) del leak del `boardRefreshEpic` cazado en la pieza forense.

**🔥 Opcionales**
- 🔥 Prototipá el `pollingEpic` de resultados (Fase 7) usando `timer(0, 3000)` + `takeUntil('STOP_POLLING')`, pegándole a un endpoint fake — sin integrarlo al store real todavía.
- 🔥 Introducí `retryWhen` con jitter (backoff aleatorizado) en `retrySellEpic` y explicá qué problema de "thundering herd" mitiga en un backend real.
- 🔥 Escribí un mini marble diagram (en comentario) de `switchMap` cancelando una petición en vuelo, como anticipo del marble testing de Fase 10.

---

## 📚 8. Referencias

**Documentación oficial**
- https://redux-observable.js.org/docs/basics/Epics.html — anatomía de un epic, `ofType`, `combineEpics`. Versión 1.2.0 del curso.
- https://redux-observable.js.org/docs/basics/SettingUpTheMiddleware.html — `createEpicMiddleware` y `epicMiddleware.run`.
- https://rxjs.dev/api/operators/switchMap y https://rxjs.dev/api/operators/mergeMap — leelas juntas; la diferencia es la base de los errores comunes #2.
- https://rxjs.dev/api/operators/takeUntil — el operador de cancelación de todo el curso.
- https://rxjs.dev/api/operators/debounceTime y https://rxjs.dev/api/operators/throttleTime — para validación y anti-doble-click.
- https://rxjs.dev/api/operators/retryWhen — reintento con backoff; ojo que en RxJS 7 está deprecado en favor de `retry({ delay })`, pero acá usamos **RxJS 6.6.7**.
- https://rxjs.dev/api/operators/catchError — por qué va dentro del map interno, no afuera.

**Libros**
- No hay un libro de redux-observable ampliamente adoptado a julio 2026; la documentación oficial y la de RxJS 6.x son la fuente más confiable para estas versiones.

**Video / apoyo**
- Buscá en YouTube "redux-observable epics tutorial" y "RxJS switchMap vs mergeMap marble diagram". Preferí contenido 2020–2022 para que las versiones coincidan con las del curso.

**Orden de lectura sugerido:** anatomía del epic → `SettingUpTheMiddleware` → `takeUntil` → volver a `reservationExpirationEpic` (5.2) y releerlo → recién ahí `switchMap` vs `mergeMap` comparando ambas páginas → `retryWhen` al final.

> ⚠️ URLs, títulos y contenidos pueden estar desactualizados; verificalos antes de compartir. La doc enlazada de RxJS es la de **6.x** — confirmá que no estás leyendo la de RxJS 7, que cambia imports (`rxjs/operators` sigue válido en 6.x) y deprecó `retryWhen`.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Saliste de esta fase con epics que se cancelan solos. Jubilaste 🪦 el `reservationTimers.js` de `setTimeout` y su cancelación manual triplicada, reemplazándolo por un `timer` + `takeUntil` que se limpia solo. Resolviste *en el origen* la venta perdedora que Fase 5 solo llegó a ver en DevTools: ahora el perdedor se corta con `switchMap` antes de tocar el rollback. Y —lo más valioso para mantenimiento— aprendiste a cazar una suscripción zombi: ese bug silencioso que no rompe nada hoy pero drena servidor y batería mañana.

Fase 7 —**cierre por hora y polling de resultados**— toma el patrón `timer` + `takeUntil` que dominaste acá y lo lleva a su forma más exigente: un `pollingEpic` que consulta el resultado de la lotería (`apiLoteria`, puerto `3002`) a intervalos, que **debe** detenerse al cerrar la rifa, al desmontar o al hacer logout, y que se cruza con el reloj real —hora dura, zona horaria, cambios de día— que hasta ahora eludimos con un `status === 'open'` plano. El `takeUntil` deja de ser un detalle: es la diferencia entre un polling que se apaga y uno que sigue golpeando un endpoint muerto.

> **La señal de que quedó bien:** si podés provocar el leak del `boardRefreshEpic`, verlo en Network como peticiones que no paran tras el logout, y arreglarlo agregando una sola línea de `takeUntil` mientras le explicás a un compañero *por qué* esa línea apaga la suscripción entera — esta fase cumplió su propósito.
