# ⏱️ Fase 07 — Cierre por hora dura + polling de resultado

> Tutorial React 16 — Rifas y chances · Fase 7 de 11 · **10 horas**
> Depende de: Fase 6 — redux-observable a fondo · Habilita: Fase 8 — Liquidación + dinero

---

## 🎯 1. Propósito

Hasta ahora la rifa "cerraba" con una precondición plana: los epics y la UI miraban `status === 'open'` y con eso alcanzaba. Esa mentira piadosa se termina acá. Fase 7 materializa el **cierre por hora dura**: no se vende un número después de un instante exacto (`closesAt`), y ese instante viene con **zona horaria** embebida, así que compararlo mal es la fuente de un bug clásico —vender pasada la medianoche, o bloquear la venta una hora antes— que en producción se traduce en plata mal cobrada. Sobre ese reloj real montamos el segundo protagonista: el **`pollingEpic`**, que consulta el resultado del sorteo a `apiLottery` (puerto `3002`) a intervalos, con reintentos y backoff, y —lo que de verdad importa para mantenimiento— **se apaga solo** al cerrar la rifa, desmontar el tablero o hacer logout. El `takeUntil` que dominaste en Fase 6 deja de ser un detalle elegante: es la diferencia entre un polling que termina y uno que golpea un endpoint muerto para siempre.

---

## ✅ 2. Qué queda listo al terminar

- [ ] La venta se bloquea por **hora dura**: una función pura `isPastClosing(closesAt, now)` compara el instante actual contra el `closesAt` (ISO con offset UTC) y una guarda única —usada por la UI y por el epic— rechaza toda venta posterior a esa timestamp exacta, sin depender ya del `status` plano.
- [ ] La **zona horaria** queda resuelta de forma explícita: `closesAt` se interpreta con su offset embebido (`-05:00`) comparando instantes absolutos (`Date` vs `Date`), y queda documentado por qué eso evita el bug de "cambio de día". Sin librería de fechas nueva (esa decisión queda 💸/pendiente).
- [ ] Existe `pollingEpic` montado en el `rootEpic` (una línea en `combineEpics`), que arranca con `START_POLLING`, consulta `GET /results/:raffleId` de `apiLottery` con `timer(0, POLLING_INTERVAL_MS)` y despacha `resultReceived` cuando el sorteo salió.
- [ ] El polling es **resiliente**: reintenta por tick con **backoff exponencial** (`retryWhen` + `timer` creciente con tope `POLLING_MAX_RETRIES`), y su `catchError` interno evita que un `500`/`timeout`/`malformed` mate el epic completo.
- [ ] El polling **se cancela solo**: un `takeUntil` corta ante `STOP_POLLING`, cierre de la rifa (`raffleClosed`/`resultReceived`) y `LOGOUT`, verificable en la pestaña Network (los `GET /results` paran). Se cierra además la deuda 💸 del `boardRefreshEpic` de Fase 6, que consolida su versión de producción con el mismo patrón.

---

## 🚫 3. Qué queda fuera por ahora

- **Liquidación y cálculo del premio** (dinero en centavos, sin floats, redondeo exacto) → Fase 8. Acá el resultado del sorteo llega al store como `winningNumber`, pero **nadie calcula cuánto se paga**.
- **Persistencia del resultado / auditoría del sorteo** (guardar quién consultó, cuándo, con qué `checkedAt`) más allá de dejarlo en el store → se retoma con trazabilidad en Fase 8 y en el dashboard de Fase 9.
- **Marble testing formal del `pollingEpic`** (`TestScheduler`, cancelación verificada con canicas) → Fase 10. Acá se explica el modelo mental y se prueba a mano en Network; el test automatizado se escribe después.
- **Reloj de servidor / desfase de hora cliente-servidor.** Comparamos contra el reloj del navegador (`Date.now()`). Si el cliente tiene la hora mal, el cierre se corre. Mitigarlo (sincronizar con el servidor) es un incidente de la Fase 8/forense, no de acá. 💸
- **Selección de librería de fechas** (`date-fns` / `luxon` / `Day.js`) → sigue **pendiente** (ver `DECISIONES-PENDIENTES`). Fase 7 resuelve TZ con `Date` nativo a propósito, para no comprometer una dependencia sin confirmar.

---

## 🧠 4. Conceptos mínimos

### El cierre no es un `status`, es un instante

Fases 4, 5 y 6 trataron el cierre como un enum: `status === 'open'` y listo. Eso alcanza mientras nadie mire el reloj, pero el negocio real es más duro: **no se vende después de `closesAt`, ni un segundo**. `closesAt` es un instante absoluto, no una fecha "de calendario": en el modelo de datos (congelado desde Fase 3) viene como `"2026-08-30T22:00:00-05:00"`. Ese `-05:00` no es decorativo: dice "las 22:00 en Bogotá", que es un instante distinto de "las 22:00 en UTC". La regla de oro de esta fase: **compará instantes, no strings ni componentes de fecha**. `new Date("2026-08-30T22:00:00-05:00")` produce el mismo instante absoluto sin importar en qué zona corre el navegador; compararlo con `new Date()` (ahora) es correcto y no tiene el bug de medianoche. El bug aparece cuando alguien compara *partes* —el día, la hora local— o cuando reconstruye la fecha ignorando el offset. Por eso la guarda vive en una función pura que recibe el `closesAt` crudo y el `now`, y devuelve un booleano; nada de lógica de tiempo esparcida por componentes.

> **Por qué `Date` nativo y no una librería.** La elección de `date-fns`/`luxon` sigue pendiente de confirmar contra el sistema real (`DECISIONES-PENDIENTES`, D-fechas). Para *comparar dos instantes* no hace falta ninguna: `Date` los representa como milisegundos desde epoch UTC, y `a.getTime() > b.getTime()` es exacto. La librería recién gana cuando hay que *formatear* o *hacer aritmética de calendario* con TZ (sumar "un día hábil", mostrar "cierra en 2h 15m" en la zona del usuario). Eso es material del dashboard (Fase 9) o de un 🔥. No comprometemos una dependencia por una comparación de dos números.

### Polling: un `timer` repetido que se apaga solo

Un polling es conceptualmente un `setInterval` que pega a un endpoint cada N ms hasta que ya no hace falta. Escrito con `setInterval` arrastra las mismas tres trampas que el `reservationTimers.js` que jubilaste en Fase 6: hay que guardar el id, cancelarlo a mano en cada salida, y se te escapa vivo al desmontar. En RxJS el polling es `timer(0, POLLING_INTERVAL_MS)` —emite en `0`, luego cada intervalo— envuelto en el mismo esqueleto de Fase 6: *arrancar con una acción, hacer trabajo por tick, cortar con `takeUntil`*. La diferencia con `reservationExpirationEpic` es que aquel `timer(ms)` emitía **una vez** y este emite **para siempre** hasta que el `takeUntil` lo apaga. Todo lo demás —`switchMap`/`mergeMap`, `catchError` interno, backoff con `retryWhen`— es vocabulario que ya tenés de Fase 6. Fase 7 no te enseña operadores nuevos: te enseña a **componerlos bien bajo presión de red real**.

### `switchMap` vs `mergeMap`, otra vez, pero ahora para polling

La regla heredada (nota de continuidad §1.3): cuando solo importa el último, `switchMap`; cuando cada operación es independiente, `mergeMap`. Aplicada al polling: el resultado de *una* rifa es independiente del de *otra* → si algún día se pollea más de una rifa a la vez, sería `mergeMap` por `raffleId`. Pero **dentro** del polling de una sola rifa, un `START_POLLING` nuevo para la misma rifa debe cancelar el ciclo anterior (no querés dos `timer` corriendo en paralelo pegándole al mismo endpoint) → `switchMap` en el nivel externo. En esta fase pollea una rifa por vez, así que usamos `switchMap` y lo dejamos anotado: si Fase 9 pollea varias, ahí se revisa. No sobre-generalizamos hoy.

### `catchError` por tick, no por stream

Regla de oro heredada (nota §1.4, error #1 de Fase 6): el `catchError` va **dentro** del map interno del tick, nunca envolviendo el `timer` entero. Si lo ponés afuera, el primer `500` de la lotería completa el stream y el polling muere: dejás de reintentar para siempre y nadie se entera hasta que alguien nota que el resultado nunca llegó. Adentro, un `500` en el tick de las 22:00:03 se atrapa, se convierte en un `pollingFailed` (o se reintenta con backoff), y el tick de las 22:00:05 sale igual. El polling sobrevive a los baches de un servicio externo áspero —que es justo lo que `apiLottery` simula con su caos `high`.

### Convivencia de estilos en esta fase

El `pollingEpic` es un módulo aparte, sin clase ni hook. La guarda de hora dura, en cambio, toca la UI: vive como función pura reutilizable (`isPastClosing`) que consumen tanto un componente funcional (el botón de vender, deshabilitado) como el propio epic/thunk de venta (rechazo en el borde). El thunk de venta de Fase 5 (`sellNumber`) **no** se reescribe a epic: sigue siendo un thunk, y solo le agregamos la guarda temporal. No modernizamos por modernizar (nota §1.6, deuda del helper `sellRequest$` sigue impaga y no la tocamos acá).

---

## 💻 5. Implementación y código comentado

Recordá el reparto de capas: la **guarda de tiempo** es lógica pura de frontend/store; el **polling** es un epic; el **mock de lotería** es backend (Fase 3, que extendemos acá para modelar "todavía no salió"). Los nombres heredados están congelados por la nota de continuidad Fase 6 → Fase 7 y el `DICCIONARIO-CODIGO-INGLES.md`: código en inglés, comentarios y UI en español.

### 5.1 La guarda de hora dura — `src/features/raffles/closing.js`

El corazón de la fase es más chico de lo que parece: dos funciones puras que comparan instantes. Que sean puras es lo que las hace testeables sin reloj real y reutilizables desde la UI y desde el store.

```javascript
// src/features/raffles/closing.js
// Lógica de cierre por hora dura. Puro cálculo de instantes: sin estado,
// sin React, sin Redux. Se puede testear pasándole un `now` fijo.

/**
 * ¿El instante `now` ya pasó el cierre de la rifa?
 *
 * `closesAt` viene como ISO con offset UTC embebido, p.ej.
 * "2026-08-30T22:00:00-05:00". new Date(...) lo interpreta como un
 * instante absoluto (ms desde epoch UTC), así que la comparación es
 * correcta corra el navegador en Bogotá, en Madrid o en UTC. NO
 * desarmamos la fecha en día/hora local: ahí está el bug de medianoche.
 *
 * @param {string} closesAt  ISO 8601 con offset, del raffle.closesAt
 * @param {Date}   [now]     instante a comparar; default: ahora
 * @returns {boolean} true si ya no se puede vender
 */
export function isPastClosing(closesAt, now = new Date()) {
  const closesAtMs = new Date(closesAt).getTime();
  // Si closesAt es inválido, getTime() da NaN. Una fecha corrupta NO
  // debe habilitar ventas eternas: tratamos NaN como "cerrado" (fail-safe).
  if (Number.isNaN(closesAtMs)) return true;
  return now.getTime() >= closesAtMs;
}

/**
 * Milisegundos que faltan para el cierre (negativo si ya cerró).
 * Útil para la UI (contador) y para decidir cuánto polear antes de que
 * tenga sentido esperar el resultado.
 *
 * @returns {number} ms restantes; <= 0 significa cerrado
 */
export function msUntilClosing(closesAt, now = new Date()) {
  const closesAtMs = new Date(closesAt).getTime();
  if (Number.isNaN(closesAtMs)) return 0;
  return closesAtMs - now.getTime();
}
```

> 📝 **Nota de época — el reloj es el del navegador.** `new Date()` usa la hora del cliente. Si el usuario tiene la hora mal, el cierre se corre con ella. Sincronizar contra el reloj del servidor (un `serverNow` que baje en cada respuesta) es lo correcto en producción y queda 💸 para la Fase 8. Acá lo dejamos explícito para que, si aparece un incidente de "me dejó vender pasado el cierre", el primer sospechoso sea el reloj del cliente, no el epic.

### 5.2 La guarda en la UI: botón de venta deshabilitado por hora dura

La celda del tablero (Fase 5, funcional) ahora consulta el cierre además del estado del número. La rifa activa se lee de `raffleSlice` con los selectores congelados de Fase 4.

```javascript
// Fragmento de la celda de número (Fase 5, src/features/sales/NumberCell.jsx).
// Solo mostramos lo que CAMBIA: la guarda de cierre sumada a la lógica previa.
import { useSelector } from 'react-redux';
import { selectNumberStatus } from './saleSlice';
import { selectActiveRaffle } from '../raffles/raffleSlice'; // ver 5.6
import { isPastClosing } from '../raffles/closing';

function NumberCell({ number, onSell }) {
  const status = useSelector(selectNumberStatus(number));
  const raffle = useSelector(selectActiveRaffle);

  // La rifa cerró si su status ya es 'closed'/'resolved'/'settled' O si
  // pasó la hora dura, aunque el status todavía diga 'open' (el reloj
  // manda sobre el enum: el status se actualiza async, la hora es ahora).
  const closed =
    !raffle ||
    raffle.status !== 'open' ||
    isPastClosing(raffle.closesAt);

  const canSell = status === 'available' && !closed;

  return (
    <button
      type="button"
      className="number-cell"
      data-testid={`number-${number}`}
      disabled={!canSell}
      onClick={() => onSell(number)}
    >
      {/* Texto de interfaz: en español */}
      {number}
      {closed && status === 'available' ? ' 🔒' : ''}
    </button>
  );
}
```

Fijate que la guarda **no** confía solo en `status !== 'open'`: el `status` en el store se actualiza de forma asíncrona (cuando el backend o el epic lo transicionan), pero la hora dura es *ahora mismo*. Entre el instante del cierre y el momento en que el store se entera, `isPastClosing` es la única verdad que impide una venta tardía.

### 5.3 La guarda en el borde de la venta: rechazar en el thunk

La UI deshabilitada no alcanza: un click viejo en vuelo, un test, o una llamada directa pueden intentar vender igual. La guarda tiene que estar también donde la venta *se ejecuta*. El thunk `sellNumber` de Fase 5 sigue siendo un thunk (no lo convertimos a epic); solo le agregamos el rechazo temprano.

```javascript
// src/features/sales/saleSlice.js — extracto del thunk sellNumber de Fase 5.
// Solo se AGREGA la guarda de cierre al inicio; el resto queda igual.
import { isPastClosing } from '../raffles/closing';

export const sellNumber = createAsyncThunk(
  'sales/sellNumber',
  async ({ raffleId, number, participantId }, { getState, rejectWithValue }) => {
    // Guarda de hora dura ANTES de tocar la red. La rifa activa vive en
    // el slice de raffles; leemos su closesAt del store.
    const raffle = getState().raffles.items.find((r) => r.id === raffleId);
    if (!raffle || isPastClosing(raffle.closesAt)) {
      // Mismo shape de error legible { message, type } de siempre.
      // 'closed' es un tipo nuevo de esta fase para "venta tras el cierre".
      return rejectWithValue({
        message: 'La rifa ya cerró: no se pueden vender más números.',
        type: 'closed',
      });
    }

    // ...resto del thunk de Fase 5, sin cambios (optimista + POST /sell)...
    const previousStatus = getState().sales.byNumber[number];
    try {
      await apiClient.post('/sell', { raffleId, number, participantId });
      return { raffleId, number, participantId, previousStatus };
    } catch (error) {
      return rejectWithValue(toReadableError(error));
    }
  }
);
```

> 💸 **Deuda intencional — doble fuente de verdad del cierre.** Ahora el cierre se chequea en dos lugares (UI y thunk) y, más abajo, el epic lo mira una tercera vez para detener el polling. Lo correcto sería un único selector derivado `selectIsRaffleClosed(raffleId)` que todos consuman. Lo dejamos explícito acá (cada capa con su chequeo) para que se *vea* que la guarda debe estar en cada borde; el selector unificado se introduce en 5.6 y el ejercicio 24 pide colapsar las tres a una. La regla de mantenimiento: **una guarda de negocio se valida en el borde que ejecuta, no solo donde se dibuja.**

### 5.4 Extender el mock de lotería: modelar "todavía no salió el sorteo"

El mock de Fase 3 (`lottery/server.js`, puerto `3002`) devolvía **siempre** `200` con un `winningNumber` hardcodeado (`"0347"`). La propia Fase 3 marcó eso 💸 y dijo textual: *"Se paga en la Fase 7"*. Lo pagamos: antes del cierre de la rifa, el sorteo **no salió**, y el servicio responde `204 No Content`; recién pasada la `closesAt`, devuelve el ganador. Así el polling tiene algo real que esperar, y encadena con la hora dura de esta misma fase.

```javascript
// lottery/server.js — versión Fase 7. Se AGREGA la noción de "pending".
// El resto (chaos middleware, puerto 3002, sin 401) queda igual que Fase 3.
const express = require('express');
const { createChaosMiddleware } = require('../chaosMiddleware');
require('dotenv').config();

const app = express();
const level = process.env.CHAOS_LOTTERY_LEVEL || 'high';
app.use(createChaosMiddleware(level));

// Fuente de la hora de cierre por rifa. En un mock honesto la leemos del
// mismo db.json que usa json-server (Fase 3), para que el sorteo "salga"
// justo cuando la rifa cierra. Acá simplificado a un lookup en memoria.
const CLOSES_AT = {
  1: '2026-08-30T22:00:00-05:00',
};
const WINNERS = {
  1: '0347',
};

app.get('/results/:raffleId', (req, res) => {
  const raffleId = Number(req.params.raffleId);
  const closesAt = CLOSES_AT[raffleId];
  const closed = closesAt ? Date.now() >= new Date(closesAt).getTime() : false;

  // Antes del cierre: el sorteo no salió. 204 = "sin contenido todavía".
  // El epic trata 204 como "seguir poleando", no como error.
  if (!closed) {
    return res.status(204).end();
  }

  // Pasado el cierre: el ganador está disponible.
  res.json({
    raffleId,
    lotteryId: 'boyaca',
    winningNumber: WINNERS[raffleId] || '0000',
    checkedAt: new Date().toISOString(),
    source: 'lottery-api-mock',
  });
});

app.listen(3002, () => {
  console.log('mock de lotería escuchando en http://localhost:3002');
});
```

Con el caos `high` encima, este endpoint hace las tres cosas que el `pollingEpic` debe tolerar: responder `204` (aún no hay resultado), responder `200` con el ganador (ya salió), o fallar con `500`/`timeout`/malformado (el bache transitorio del servicio externo). Ninguna de las tres debe matar el polling.

### 5.5 El `pollingEpic` — `src/features/raffles/epics/pollingEpic.js`

El epic vive en `raffles` (el resultado es del dominio de la rifa, no de la venta). Toma prestado el esqueleto de `reservationExpirationEpic` y lo lleva a su forma exigente: `timer` repetido, backoff por tick, y `takeUntil` con tres notifiers.

```javascript
// src/features/raffles/epics/pollingEpic.js
import { ofType } from 'redux-observable';
import { of, timer, EMPTY } from 'rxjs';
import {
  map,
  switchMap,
  mergeMap,
  catchError,
  retryWhen,
  takeUntil,
  filter,
} from 'rxjs/operators';
import { from } from 'rxjs';
import apiLottery from '../../../app/apiLottery'; // instancia axios nueva, ver 5.8
import { resultReceived, pollingFailed } from '../raffleSlice';
import {
  POLLING_INTERVAL_MS,
  POLLING_MAX_RETRIES,
  POLLING_BACKOFF_BASE_MS,
} from '../constants';

// Action types clásicos (anunciados en Fase 6, uso pleno acá).
export const START_POLLING = 'START_POLLING';
export const STOP_POLLING = 'STOP_POLLING';

/**
 * Polling del resultado de la lotería para una rifa.
 *
 * Arranca con START_POLLING { raffleId }. timer(0, INTERVAL) emite ya y
 * luego cada intervalo. Por cada tick pegamos a GET /results/:raffleId:
 *  - 204 -> el sorteo no salió: no emitimos acción, seguimos poleando.
 *  - 200 -> llegó el ganador: emitimos resultReceived y el takeUntil
 *           de resultReceived detiene el propio polling (ver abajo).
 *  - error transitorio -> retryWhen con backoff exponencial por tick.
 *
 * switchMap externo: un START_POLLING nuevo para otra rifa cancela el
 * ciclo anterior (no queremos dos timers pegándole al 3002 a la vez).
 * En esta fase se pollea UNA rifa por vez; si Fase 9 pollea varias,
 * revisar switchMap -> mergeMap por raffleId.
 */
export const pollingEpic = (action$) =>
  action$.pipe(
    ofType(START_POLLING),
    switchMap((action) => {
      const { raffleId } = action.payload;

      return timer(0, POLLING_INTERVAL_MS).pipe(
        // Por cada tick, una petición independiente. mergeMap y no switchMap
        // ACÁ ADENTRO: si un tick tarda más que el intervalo, no queremos
        // cancelar la respuesta en vuelo del tick anterior a ciegas; cada
        // consulta es un intento válido. (Con INTERVAL >> latencia media
        // rara vez se solapan, pero lo dejamos correcto por diseño.)
        mergeMap(() =>
          from(apiLottery.get(`/results/${raffleId}`)).pipe(
            // 204 llega como respuesta con status 204 y data vacío.
            // No es un resultado: lo filtramos para no emitir nada.
            filter((response) => response.status === 200 && response.data),
            map((response) =>
              resultReceived({
                raffleId,
                winningNumber: response.data.winningNumber,
                checkedAt: response.data.checkedAt,
              })
            ),
            // Backoff exponencial POR TICK: reintenta el mismo tick ante
            // error transitorio, hasta POLLING_MAX_RETRIES. Un conflict no
            // aplica acá (la lotería no devuelve 409). Los fallos son
            // 500/timeout/malformed, todos transitorios -> reintentables.
            retryWhen((errors$) =>
              errors$.pipe(
                mergeMap((error, index) => {
                  if (index >= POLLING_MAX_RETRIES) {
                    // Nos rendimos con ESTE tick: lo re-lanzamos para que
                    // el catchError de abajo lo convierta en pollingFailed,
                    // SIN matar el timer (catchError está dentro del tick).
                    throw error;
                  }
                  // 500ms, 1000ms, 2000ms... (base * 2^index)
                  return timer(POLLING_BACKOFF_BASE_MS * 2 ** index);
                })
              )
            ),
            // catchError POR TICK (dentro del mergeMap del tick, no fuera
            // del timer): un tick fallido emite pollingFailed y el timer
            // sigue vivo para el próximo intervalo. Regla de oro de Fase 6.
            catchError((error) =>
              of(
                pollingFailed({
                  raffleId,
                  error: {
                    message: 'No se pudo consultar el resultado del sorteo.',
                    type: 'http',
                  },
                })
              )
            )
          )
        ),
        // CANCELACIÓN: el polling se apaga ante cualquiera de estas señales.
        // - STOP_POLLING explícito (el componente al desmontarse lo despacha).
        // - resultReceived: ya salió el ganador, no hay nada más que polear.
        // - raffleClosed: la rifa se cerró por hora dura (transición de status).
        // - LOGOUT: el usuario cerró sesión; nada debe seguir en vuelo.
        takeUntil(
          action$.pipe(
            ofType(
              STOP_POLLING,
              resultReceived.type,
              'RAFFLE_CLOSED',
              'LOGOUT'
            )
          )
        )
      );
    })
  );
```

> ⚠️ **El `filter` que evita el resultado fantasma.** El `204` no trae body, pero un tick que llega **tarde** —tras un `STOP_POLLING`, por un `takeUntil` que aún no cortó la petición en vuelo— podría intentar emitir. El `filter(status === 200 && data)` es la primera línea de defensa; el `takeUntil` es la segunda. Si aun así un resultado llega tarde y ya no corresponde, el `raffleSlice` lo descarta con su guarda de estado (5.7) y, si quisieras marcarlo, existe el tipo de error `'stale'` reservado en la nota de continuidad §0.2.

### 5.6 Extender `raffleSlice`: resultado, cierre y selectores derivados

Agregamos reducers síncronos al `raffleSlice` de Fase 4 **sin reescribir** los existentes, respetando la máquina de estados `draft → open → closed → resolved → settled`.

```javascript
// src/features/raffles/raffleSlice.js — fragmentos a AGREGAR.
// Los reducers, thunks y selectores de Fase 4 quedan intactos.

// Dentro de reducers: { ...los de Fase 4... }
reducers: {
  // ...createRaffle/updateRaffle/selectRaffleToEdit/etc de Fase 4...

  // La rifa cierra por hora dura: open -> closed. Guardado por estado de
  // origen para no re-cerrar ni saltar etapas de la máquina.
  raffleClosed(state, action) {
    const raffle = state.items.find((r) => r.id === action.payload.raffleId);
    if (raffle && raffle.status === 'open') {
      raffle.status = 'closed';
    }
  },

  // Llegó el ganador del sorteo: closed -> resolved. Guarda el número y
  // el checkedAt para trazabilidad (la liquidación de Fase 8 lo usa).
  resultReceived(state, action) {
    const { raffleId, winningNumber, checkedAt } = action.payload;
    const raffle = state.items.find((r) => r.id === raffleId);
    // Solo transiciona si estaba 'closed'. Un resultado que llega mientras
    // la rifa sigue 'open' (no debería, pero la red miente) se ignora.
    if (raffle && raffle.status === 'closed') {
      raffle.status = 'resolved';
      raffle.result = { winningNumber, checkedAt };
    }
  },

  // Un tick de polling falló definitivamente (tras los reintentos).
  // No corta el polling: solo deja el error legible para la UI.
  pollingFailed(state, action) {
    state.error = action.payload.error; // { message, type: 'http' }
  },
},
```

Exportá los nuevos creators junto a los de Fase 4:

```javascript
export const {
  selectRaffleToEdit, cancelEdit, clearError,          // Fase 4
  raffleClosed, resultReceived, pollingFailed,         // Fase 7
} = raffleSlice.actions;
```

Y los selectores derivados que unifican la lectura del cierre (paga parte de la deuda 💸 de 5.3: un solo lugar para "¿está cerrada?"):

```javascript
// La rifa activa. En esta fase asumimos una rifa "en foco" por su id.
// Simplificación honesta: si hubiera varias, esto sería un selectById.
export const selectActiveRaffle = (state) =>
  state.raffles.items.find((r) => r.id === state.raffles.activeId) || null;

export const selectRaffleResult = (raffleId) => (state) => {
  const raffle = state.raffles.items.find((r) => r.id === raffleId);
  return raffle ? raffle.result || null : null;
};

// Selector de cierre: mira el status del enum. La hora dura (isPastClosing)
// se compone en el componente/thunk con este selector, porque un selector
// no debe llamar a new Date() (dejaría de ser puro respecto del store).
export const selectIsRaffleClosedByStatus = (raffleId) => (state) => {
  const raffle = state.raffles.items.find((r) => r.id === raffleId);
  return !raffle || raffle.status !== 'open';
};
```

> 📝 **Por qué el selector no llama a `isPastClosing`.** Un selector de Redux debe ser función pura del *store*: meterle `new Date()` lo vuelve no-determinista (dos llamadas con el mismo store dan resultados distintos al pasar el tiempo), y rompe la memoización. Por eso `selectIsRaffleClosedByStatus` mira solo el enum, y la hora dura se combina afuera: `closed = selectIsRaffleClosedByStatus(id)(state) || isPastClosing(raffle.closesAt)`. La distinción "qué es del store y qué es del reloj" es exactamente la que evita bugs de memoización silenciosos.

### 5.7 Constantes de configuración — `src/features/raffles/constants.js`

```javascript
// src/features/raffles/constants.js
// Intervalo del polling de resultados. Configurable: subilo para bajar
// la presión sobre la lotería, bajalo para ver el resultado antes.
export const POLLING_INTERVAL_MS = 3000;

// Reintentos por tick ante error transitorio antes de rendirse con ese tick.
export const POLLING_MAX_RETRIES = 3;

// Base del backoff exponencial: 500, 1000, 2000 ms (base * 2^index).
export const POLLING_BACKOFF_BASE_MS = 500;
```

### 5.8 La instancia HTTP de la lotería — `src/features/... app/apiLottery.js`

`apiClient` (puerto `3001`) es el backend propio. La lotería es un tercero con su propio `baseURL` y perfil de fallo: instancia axios aparte, misma filosofía que `apiClient` pero **sin** el interceptor de 401 (la lotería no es ruta protegida; sus fallos son `500`/`timeout`/malformado, nunca `401`).

```javascript
// src/app/apiLottery.js
import axios from 'axios';

// Instancia dedicada a la API de lotería (puerto 3002). NO comparte los
// interceptores de auth de apiClient: la lotería no maneja sesión.
const apiLottery = axios.create({
  baseURL: 'http://localhost:3002',
  timeout: 5000,
});

export default apiLottery;
```

### 5.9 Montar el `pollingEpic` en el `rootEpic` (una línea)

Tal como anticipó Fase 6 (5.1, deuda 💸 del import manual): se agrega una línea.

```javascript
// src/app/rootEpic.js — se AGREGA pollingEpic al combineEpics existente.
import { combineEpics } from 'redux-observable';
import { reservationExpirationEpic } from '../features/sales/epics/reservationExpirationEpic';
import { sellNumberEpic } from '../features/sales/epics/sellNumberEpic';
import { validateNumberEpic } from '../features/sales/epics/validateNumberEpic';
import { retrySellEpic } from '../features/sales/epics/retrySellEpic';
import { cancelOnLogoutEpic } from '../features/sales/epics/cancelOnLogoutEpic';
import { pollingEpic } from '../features/raffles/epics/pollingEpic'; // Fase 7

export const rootEpic = combineEpics(
  reservationExpirationEpic,
  sellNumberEpic,
  validateNumberEpic,
  retrySellEpic,
  cancelOnLogoutEpic,
  pollingEpic // <-- Fase 7: sin tocar reducers ni el montaje del middleware
);
```

### 5.10 Consolidar el `boardRefreshEpic` (pagar la deuda 💸 de Fase 6)

Fase 6 dejó `boardRefreshEpic` roto a propósito (5.8): un `interval` sin `takeUntil`, cazado en su ejercicio 18. Su versión de producción es el mismo patrón del polling, así que la consolidamos acá.

```javascript
// src/features/sales/epics/boardRefreshEpic.js — VERSIÓN CORREGIDA (Fase 7).
import { ofType } from 'redux-observable';
import { timer } from 'rxjs';
import { map, switchMap, takeUntil } from 'rxjs/operators';
import { fetchNumbers } from '../saleSlice';

// Ahora SÍ se cancela: takeUntil sobre STOP_BOARD_REFRESH y LOGOUT.
// timer(0, INTERVAL) en vez de interval(INTERVAL) para refrescar ya al
// arrancar, sin esperar el primer intervalo. Mismo esqueleto que pollingEpic.
export const boardRefreshEpic = (action$) =>
  action$.pipe(
    ofType('START_BOARD_REFRESH'),
    switchMap(({ payload }) =>
      timer(0, 5000).pipe(
        map(() => fetchNumbers(payload.raffleId)),
        takeUntil(
          action$.pipe(ofType('STOP_BOARD_REFRESH', 'LOGOUT'))
        )
      )
    )
  );
```

> Con esto la deuda de Fase 6 queda cerrada: el refresco del tablero ya no es un leak. Si lo montás en el `rootEpic`, es otra línea en el `combineEpics`, igual que `pollingEpic`.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Comparar componentes de fecha en vez de instantes.** Síntoma: la rifa deja vender pasada la medianoche, o cierra una hora antes, según dónde esté el usuario. Causa: alguien hizo `new Date(closesAt).getHours()` o comparó strings, ignorando el offset `-05:00`. Fix mínimo: comparar `getTime()` contra `getTime()` como en `isPastClosing`; nunca desarmar la fecha para la guarda. Corrección vs refactor: el fix es una línea; el refactor sería centralizar toda comparación de tiempo en `closing.js` y prohibir `getHours()` en el resto del código (regla de lint).

**2. `catchError` afuera del `timer`.** Síntoma: el polling muere al primer `500` de la lotería y el resultado nunca llega, sin ningún error visible. Causa: el `catchError` envuelve el `timer(0, INTERVAL)` entero en vez del tick. Fix: moverlo adentro del `mergeMap` del tick (5.5). Es el error #1 de Fase 6 aplicado al polling.

**3. Polling que no se apaga.** Síntoma: en Network, los `GET /results` siguen saliendo después de cerrar la rifa, desmontar el tablero o hacer logout. Causa: falta un notifier en el `takeUntil` (típico: se puso `LOGOUT` pero no `resultReceived`, así que sigue poleando tras encontrar el ganador). Fix: completar el `takeUntil` con las cuatro señales. Este es el mismo leak del `boardRefreshEpic`, ahora con consecuencia de red real.

**4. Tratar el `204` como error.** Síntoma: el store se llena de `pollingFailed` mientras el sorteo simplemente no salió todavía; la UI muestra "error" cuando debería mostrar "esperando resultado". Causa: no distinguir `204` (aún no hay, seguir) de un fallo real (`5xx`). Fix: el `filter(status === 200 && data)` deja pasar solo resultados reales; el `204` no emite nada y el `catchError` solo se dispara ante error de verdad.

### Pieza forense de esta fase — Polling que no para al desmontar componente

El foco forense es **correlacionar el intervalo de peticiones con el ciclo de vida del epic** en la pestaña Network. Abrí Network, filtrá por `results`, y verificá tres cosas: (a) los `GET /results/:id` empiezan al `START_POLLING` y salen cada `POLLING_INTERVAL_MS`; (b) ante un `500` inyectado por el caos, ves los reintentos con los gaps del backoff (500ms, 1s, 2s) y luego el tick vuelve al ritmo normal; (c) —lo crítico— al despachar `STOP_POLLING`, al pasar la hora de cierre, o al hacer logout, **los `GET` paran**. Un polling sano deja de aparecer en Network; un polling con leak sigue golpeando el `3002` para siempre.

**Ejercicio "rompe a propósito y observá":** quitá `resultReceived.type` del `takeUntil` del `pollingEpic` y dejá el resto igual. Corré el mock con la rifa ya cerrada (para que `/results` devuelva `200` con ganador). Observá en Network que, tras recibir el resultado, el polling **sigue** pidiendo `/results` cada 3s aunque ya no hay nada nuevo que traer: es un leak silencioso que drena servidor y batería. Volvé a poner el notifier y confirmá que ahora para en el primer `200`. Escribí el post-mortem (plantilla Guía de Estilo §12) de por qué un `takeUntil` incompleto es indistinguible de uno correcto hasta que mirás la red.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–7)**
1. Escribí una prueba unitaria de `isPastClosing` con un `now` fijo antes y después de `closesAt`, incluyendo el caso exacto de la igualdad (`now === closesAt`). ¿Cuál es el comportamiento en el borde y por qué elegimos `>=`?
2. Verificá con `node` que `new Date("2026-08-30T22:00:00-05:00").getTime()` da el mismo número corriendo el proceso con `TZ=America/Bogota` y con `TZ=Europe/Madrid`. Explicá por qué.
3. Pasale a `isPastClosing` un `closesAt` corrupto (`"no-soy-fecha"`) y confirmá que devuelve `true` (fail-safe). Justificá por qué "cerrado" es el default seguro y no "abierto".
4. En `NumberCell`, mostrá un 🔒 junto a los números disponibles cuando la rifa cerró por hora dura. Confirmá que el botón queda `disabled`.
5. Agregá `POLLING_INTERVAL_MS` como constante configurable y cambialo a 1000ms; observá en Network que el ritmo de `GET /results` se acelera.
6. Levantá el mock de lotería de Fase 7 y confirmá con `curl` que `GET /results/1` devuelve `204` antes del cierre y `200` con `winningNumber` después (podés adelantar `CLOSES_AT[1]` a una hora pasada para probar).
7. Escribí `msUntilClosing` en un componente que muestre "Cierra en Xs" y confirmá que llega a cero en el instante correcto.

**🟡 Intermedio (8–16)**
8. Componé la guarda completa de cierre en `NumberCell`: `selectIsRaffleClosedByStatus(id)(state) || isPastClosing(raffle.closesAt)`. Explicá por qué hacen falta las dos condiciones y no una sola.
9. Agregá el rechazo por `type: 'closed'` en el thunk `sellNumber` y mostrá en la UI el mensaje en español cuando alguien intenta vender pasado el cierre (por ejemplo, con un click viejo en vuelo).
10. Despachá `START_POLLING` al montar el tablero y `STOP_POLLING` al desmontarlo (con `useEffect` cleanup). Confirmá en Network que el polling arranca y para con el ciclo de vida del componente.
11. Provocá un `500` en `/results` con el caos `high` y verificá en Network los gaps del backoff (500ms, 1s, 2s) antes de que el tick emita `pollingFailed`.
12. Explicá por qué el `catchError` del `pollingEpic` está dentro del `mergeMap` del tick y no envolviendo el `timer`. Movelo afuera a propósito y describí qué se rompe.
13. Agregá `raffleClosed` disparado por un epic o efecto cuando `isPastClosing` se vuelve verdadero, y confirmá que la transición `open → closed` ocurre una sola vez (guarda de estado de origen).
14. Confirmá que `resultReceived` solo transiciona `closed → resolved` y que un resultado que llega con la rifa aún en `open` se ignora. Forzá el caso enviando la acción a mano desde Redux DevTools.
15. Distinguí en Network un `204` de un `500`: mostrá que el `204` no genera `pollingFailed` y el `500` sí (tras agotar reintentos).
16. Usá `selectRaffleResult(raffleId)` para mostrar el número ganador en la UI cuando la rifa pasa a `resolved`.

**🟠 Difícil (17–24)**
17. **Diagnóstico:** te dan un `pollingEpic` con `catchError` afuera del tick. Reproducí el síntoma (el polling muere al primer `500`), localizá la línea y aplicá el fix mínimo.
18. **Diagnóstico:** un `pollingEpic` tiene el `takeUntil` sin `resultReceived.type`. Mostrá en Network que sigue poleando tras recibir el ganador y corregilo. Escribí el post-mortem.
19. **Diagnóstico:** la guarda de cierre usa `new Date(closesAt).getHours() >= 22` en vez de comparar instantes. Reproducí el bug de medianoche cambiando la TZ del sistema y corregí a comparación de `getTime()`.
20. Consolidá el `boardRefreshEpic` corregido (5.10) en el `rootEpic` y confirmá con Network que su `interval` ya no se escapa al logout. Compará el diff con la versión rota de Fase 6.
21. Reproducí un tick que llega **tarde** tras `STOP_POLLING` (subí la latencia del caos y despachá `STOP_POLLING` justo tras un tick). Mostrá que el `filter` + `takeUntil` evitan que emita, y discutí cuándo harías falta el tipo de error `'stale'`.
22. Medí (Performance de DevTools) cuántas peticiones a `/results` genera el polling en 30s con `POLLING_INTERVAL_MS` de 3000 vs 1000, y razoná el trade-off presión-de-red / latencia-al-resultado.
23. Escribí una prueba de integración (a mano, sin marble aún) que despache `START_POLLING`, simule un `200` con ganador y verifique que llegan en orden `resultReceived` y que el polling se detiene.
24. **Refactor:** colapsá las tres guardas de cierre (UI, thunk, epic) a un único selector derivado `selectIsRaffleClosed(raffleId)` que combine status + hora dura, resolviendo dónde vive el `new Date()` sin romper la memoización. Justificá la ubicación.

**🔴 Muy difícil (25–30)**
25. **Diagnóstico + regresión:** repo con bug intermitente — a veces, tras cerrar la rifa, un último `GET /results` con un resultado válido llega y pinta `resolved`, pero *otras veces* un tick tardío tras `STOP_POLLING` intenta re-emitir. Encontrá la carrera entre el `takeUntil` y la petición en vuelo, proponé el fix y la prueba de regresión.
26. Diseñá el polling de **dos rifas simultáneas** (Fase 9 lo necesitará): cambiá el `switchMap` externo a `mergeMap` por `raffleId` y explicá qué se rompería si dejaras `switchMap` (un `START_POLLING` de la rifa 2 mataría el de la rifa 1). Verificá en Network que ambos corren en paralelo y se cancelan independientes.
27. Reproducí el bug del **reloj del cliente**: adelantá la hora del navegador 3 horas y mostrá que `isPastClosing` cierra la rifa antes de tiempo. Diseñá (sin implementar del todo) cómo un `serverNow` bajado en cada respuesta mitigaría esto, y qué fase debería pagarlo.
28. Escribí un mini marble diagram (en comentario) de `timer(0, 3000)` con `takeUntil` cortando en el tercer tick, como anticipo del marble testing de Fase 10. Marcá dónde se limpia la suscripción.
29. **Post-mortem completo** (plantilla Guía de Estilo §12) de un incidente real simulado: "el polling de resultados siguió golpeando la lotería toda la noche tras el logout de todos los operadores, y el proveedor nos bloqueó por abuso". Síntoma, reproducción, evidencia (Network), causa raíz (`takeUntil` sin `LOGOUT`), corrección, prueba de regresión, prevención, sin culpabilización.
30. **🔥 avanzado:** hacé el backoff del `pollingEpic` con *jitter* (aleatorizado) para evitar que, si mil clientes empiezan a polear al mismo cierre, todos reintenten en sincronía (thundering herd) y tumben la lotería. Explicá el problema y mostrá el cambio en el `retryWhen`.

**🔥 Opcionales**
- 🔥 Reemplazá `Date` nativo por `date-fns` (o `luxon`) **solo** para *formatear* el contador "Cierra en 2h 15m" en la zona del usuario, dejando la comparación de instantes en `Date`. Justificá por qué la librería suma en formateo pero no en la guarda.
- 🔥 Agregá un `POST /_chaos` al mock de lotería para cambiar el `CHAOS_LOTTERY_LEVEL` en caliente (la deuda 💸 que Fase 3 dejó anotada) y usalo para provocar rachas de `500` durante el polling sin reiniciar el proceso.
- 🔥 Materializá el tipo de error `'stale'`: cuando un resultado llega tras `STOP_POLLING`, en vez de descartarlo en silencio, dejá rastro con `type: 'stale'` para trazabilidad, y decidí si la UI debe mostrarlo.

---

## 📚 8. Referencias

**Documentación oficial**
- https://rxjs.dev/api/index/function/timer — `timer(initialDelay, period)`, la base del polling repetido. Versión **RxJS 6.6.7** del curso.
- https://rxjs.dev/api/operators/takeUntil — el operador de cancelación de todo el curso; acá con múltiples notifiers.
- https://rxjs.dev/api/operators/retryWhen — reintento con backoff. ⚠️ deprecado en RxJS 7 a favor de `retry({ delay })`, pero acá usamos **RxJS 6.6.7**.
- https://rxjs.dev/api/operators/switchMap y https://rxjs.dev/api/operators/mergeMap — releelas para decidir el nivel externo vs interno del polling.
- https://redux-observable.js.org/docs/basics/Epics.html — anatomía del epic, `combineEpics`. Versión **1.2.0**.
- https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Date/getTime — `getTime()` como ms desde epoch UTC; el fundamento de comparar instantes sin bug de TZ.
- https://developer.mozilla.org/es/docs/Web/HTTP/Status/204 — semántica de `204 No Content`, que usamos para "el sorteo no salió todavía".

**Libros** (si aplican)
- No hay libro de referencia de redux-observable a julio 2026; la doc oficial de RxJS 6.x y redux-observable 1.2 son la fuente confiable para estas versiones.

**Video / apoyo**
- Buscá en YouTube "RxJS polling with timer takeUntil" y "RxJS exponential backoff retryWhen". Preferí contenido 2020–2022 para que las versiones de RxJS coincidan con las del curso.

**Orden de lectura sugerido:** `getTime()` y `204` (el modelo de tiempo y la respuesta del mock) → releer `reservationExpirationEpic` de Fase 6 con `timer` fresco → `timer(initialDelay, period)` → `takeUntil` con múltiples notifiers → volver al `pollingEpic` de 5.5 → `retryWhen` al final para el backoff.

> ⚠️ URLs, títulos y contenidos pueden estar desactualizados; verificalos antes de compartir. La doc de RxJS enlazada es la de **6.x**: confirmá que no estás leyendo la de RxJS 7, que deprecó `retryWhen` y cambia algunas firmas. La página de `Date` de MDN es estable, pero el comportamiento depende de la implementación del motor: probá siempre con `TZ` distintos.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Saliste de esta fase con el reloj real por fin adentro de la app. El cierre dejó de ser un `status === 'open'` plano: ahora hay una hora dura con zona horaria, validada en cada borde que ejecuta una venta —UI, thunk y epic— mediante una función pura que compara instantes y no cae en el bug de medianoche. Y montaste el `pollingEpic`, que consulta el resultado de la lotería a `apiLottery` con `timer` repetido, backoff por tick, y —lo que de verdad importa para mantenimiento— un `takeUntil` que lo apaga al cerrar, desmontar o hacer logout. De paso cerraste la deuda 💸 del `boardRefreshEpic` de Fase 6: el refresco del tablero ya no se escapa. La rifa ahora recorre de verdad `open → closed → resolved`.

Fase 8 —**liquidación + dinero**— toma ese `resolved` con su `winningNumber` y responde la pregunta que Fase 7 dejó abierta a propósito: *¿cuánto se paga, y a quién?* Ahí entra la regla más traicionera del dominio: **el dinero no se calcula con floats**. Todo en centavos, enteros, redondeo determinista; un `0.1 + 0.2` mal puesto en una liquidación no es un bug cosmético, es plata que no cuadra. El `result` que guardaste en el store es exactamente el insumo de ese cálculo.

> **La señal de que quedó bien:** si podés abrir Network, ver el polling arrancar al montar el tablero, respetar el intervalo, reintentar con backoff ante un `500`, y —al hacer logout— **dejar de aparecer por completo**, mientras le explicás a un compañero por qué esa desaparición en la red es la diferencia entre un polling sano y uno que nos bloquea el proveedor de lotería —esta fase cumplió su propósito.
