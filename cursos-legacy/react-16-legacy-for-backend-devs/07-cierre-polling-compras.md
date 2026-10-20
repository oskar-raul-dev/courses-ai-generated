# ⏱️ Fase 07 — Cierre a hora exacta + polling de compras

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · Fase 7 de 11 · **10 horas**
> Depende de: Fase 6 — redux-observable a fondo · Habilita: Fase 8 — Conciliación

---

## 🎯 1. Propósito

Dos tiempos llegan juntos a soporte. Uno es un instante: la notificación de la Semana del Canal decía *"la rueda del Canal cierra hoy a las 8:00 p. m."*, y a las 8:00 p. m. en punto ya no se mandan giros de esa rueda, ni uno. El otro es una espera larga: en Colombia y en México muchos jugadores pagan en efectivo, y Google Play confirma esa compra minutos u horas después; mientras tanto, a Yariela le llega el mismo correo veinte veces al día (`00-historia-del-sistema.md` §3, era 3): *"ya pagué en Efecty y no me llegaron los giros"*.

Hasta ahora nadie en la consola miró el reloj. El cierre era, como mucho, un `status`, y una rueda `live` con su hora de cierre vencida seguía ofreciendo giros. Esta fase materializa el **cierre a hora exacta**: no se envía un giro de una rueda después de su `closesAt`, ni un segundo, y ese instante viene con **zona horaria** embebida, así que compararlo mal es la fuente de un bug clásico —seguir enviando pasada la hora, o cortar antes— que en producción se traduce en premios mal entregados. Sobre ese reloj real montamos el segundo protagonista: el **`pollingEpic`**, que pregunta por una compra pendiente al mock de Google Play (puerto `3002`) cada dos segundos y —lo que de verdad importa para mantenimiento— **se apaga solo** cuando la compra se confirma, cuando el operador sale de la pantalla y cuando cierra sesión. El `takeUntil` que dominaste en la Fase 6 deja de ser un detalle elegante: es la diferencia entre un polling que termina y el refresco con leak que cazaste allá.

---

## ✅ 2. Qué queda listo al terminar

- [ ] El cierre se decide por **instante**: la función pura `isWheelClosed(wheel, now)` compara `now` con el `closesAt` (ISO con offset) como milisegundos absolutos, con el instante exacto ya cerrado y un `closesAt` ilegible tratado como cerrado.
- [ ] Una guarda única de hora dura, usada en dos lugares: la UI (el asistente no ofrece giros de una rueda cerrada) y el borde del envío (`closedWheelRejection`, en los dos epics que envían), que rechaza un giro **en el instante en que sale**, con el reloj recibido como dependencia del epic (`now`).
- [ ] Existe `apiStore.js`, la instancia HTTP del servicio de compras (el mock de Google Play, puerto `3002`), con la misma sesión que `apiClient`.
- [ ] Existe `pollingEpic`, montado en el `rootEpic`, que arranca con `startPolling`, pregunta `GET /purchases/:token` con `timer(0, POLLING_INTERVAL_MS)` y despacha `purchaseStatusReceived` en cada tick.
- [ ] El polling es **resiliente**: su `catchError` está dentro del tick, y un `500` del servicio de compras no lo mata.
- [ ] El polling **se apaga solo**: termina en la confirmación (`takeWhile`) y se corta con `stopPolling` y con el logout (`takeUntil`), verificable en Network y en el log del mock. 💸 **Pago de deuda:** el refresco de compras con leak de la Fase 6 se va.
- [ ] La pantalla **Compras pendientes** (`/purchases`), donde soporte pega el código de la compra y ve su estado.

---

## 🚫 3. Qué queda fuera por ahora

- **Acreditar los giros de una compra confirmada** → track BE (`be07`), en una transacción e idempotente por `purchaseToken`. La consola solo observa la compra; no le da nada a nadie.
- **La notificación duplicada de Google Play** → `be07`. El mock la sabe mandar (`PLAY_DUPLICATE=1`), pero quien tiene que defenderse de ella es el backend.
- **La autoridad del reloj del servidor.** Esta fase compara contra el reloj del navegador (`Date.now()`). Si la máquina del operador tiene la hora mal, el cierre se corre. Que el servidor sea quien decide es `be06`. 💸
- **El dinero** → Fase 8. Una compra confirmada tiene un precio, y repartirlo entre los giros del paquete sin perder centavos es la conciliación.
- **Las pruebas de canicas del polling** → `A11-marble-testing.md` §8, y se aplican en la Fase 10. Acá el modelo mental y la prueba a mano en Network.
- **Una librería de fechas** (`date-fns`, `luxon`, `Day.js`) → no se adopta ninguna. Para comparar dos instantes no hace falta, y el porqué está abajo.

---

## 🧠 4. Conceptos mínimos

### El cierre no es un `status`, es un instante

Hasta ahora la consola trató el cierre como un enum: una rueda `ended` está cerrada, y punto. Eso alcanza mientras nadie mire el reloj, pero el negocio real es más duro: **no se envía un giro de una rueda después de su `closesAt`, ni un segundo**, aunque su `status` todavía diga `live` porque nadie la pasó a `ended`. `closesAt` es un instante absoluto, no una fecha de calendario: viene como `"2026-08-30T20:00:00-05:00"`. Ese `-05:00` no es decorativo: dice "las 20:00 en Panamá", que es un instante distinto de "las 20:00 en UTC" —es la 01:00 UTC del día siguiente—.

La regla de oro de esta fase: **compara instantes, no strings ni partes de una fecha**. `Date.parse("2026-08-30T20:00:00-05:00")` da el mismo número de milisegundos sin importar en qué zona corre el navegador; compararlo con `Date.now()` es correcto y no tiene el bug de la hora ni el del cambio de día. El bug aparece cuando alguien compara *partes* —la hora local, el día— o cuando reconstruye la fecha ignorando el offset. Por eso la guarda vive en una función pura que recibe la rueda y el ahora, y devuelve un booleano; nada de lógica de tiempo repartida por componentes.

> **Por qué `Date` nativo y no una librería.** Para *comparar dos instantes* no hace falta: `Date.parse` y `Date.now()` dan milisegundos desde epoch, y comparar dos números es exacto. La librería gana cuando hay que *formatear* o *hacer aritmética de calendario* con zona ("cierra en 2 h 15 min" en la zona de quien mira). Eso es material del dashboard (Fase 9) o de un 🔥. No se compromete una dependencia por comparar dos números.

### El reloj también es una dependencia

`isWheelClosed` recibe el `now` como argumento, y los epics que envían reciben `now` en sus dependencias, al lado de `api`. Es la misma idea de la Fase 6 llevada al tiempo: un epic que llama a `Date.now()` adentro solo se prueba esperando a que llegue la hora; uno que recibe el reloj se prueba fijándolo un milisegundo antes del cierre y en el instante exacto. Es la diferencia entre una prueba que hay que correr a las 8:00 p. m. y una que corre siempre.

### Dos tiempos: un instante y una espera

El cierre es un instante: antes, sí; después, no. La compra en efectivo es una espera: el jugador paga en la tienda de la esquina, y Google Play confirma **minutos u horas después, hasta dos días en el peor caso**. Mientras tanto, la compra está `pending`. El mock de Google Play de la Fase 3 deja esa demora configurable (`PLAY_PENDING_MS`, 3 s por defecto) para que la consola pruebe el polling en segundos y no en días. Lo que no cambia con la escala es el problema: preguntar cada tanto, y dejar de preguntar a tiempo.

### Polling: un `timer` repetido que se apaga solo

Un polling es conceptualmente un `setInterval` que pega a un endpoint cada N ms hasta que ya no hace falta. Escrito con `setInterval` arrastra las mismas trampas que la ventana de deshacer de la Fase 5: hay que guardar el id, cancelarlo a mano en cada salida, y se te escapa vivo al cerrar sesión —es lo que le pasó a Renzo en 2022—. En RxJS el polling es `timer(0, POLLING_INTERVAL_MS)` —emite en `0`, luego cada intervalo— envuelto en el mismo esqueleto de la Fase 6: *arrancar con una acción, hacer trabajo por tick, cortar con `takeUntil`*. La diferencia con `undoWindowEpic` es que aquel `timer(ms)` emitía **una vez** y este emite **para siempre** hasta que algo lo apaga.

Y esta vez hay dos formas de apagarlo. Una viene de afuera —el operador para, sale de la pantalla, cierra sesión— y es `takeUntil`. La otra viene de adentro: la compra se confirmó y ya no hay nada que preguntar. Eso es `takeWhile`, con su segundo argumento en `true` para que la emisión de "confirmada" pase antes de terminar.

### `switchMap` contra `mergeMap`, otra vez, pero ahora para polling

La regla de la Fase 6: cuando solo importa el último, `switchMap`; cuando cada operación es independiente, `mergeMap`. Aplicada al polling: si soporte siguiera varias compras a la vez, cada una sería independiente → `mergeMap` por token. En esta fase la pantalla sigue una compra por vez, y consultar otra debe cancelar el ciclo anterior (no quieres dos `timer` pegándole al servicio por algo que ya no miras) → `switchMap` en el nivel externo. Se deja anotado: si la Fase 9 sigue varias, ahí se revisa.

### `catchError` por tick, no por stream

El error #1 de la Fase 6, ahora con un servicio externo: el `catchError` va **dentro** del Observable del tick, nunca envolviendo el `timer` entero. Si lo pones afuera, el primer `500` del servicio de compras completa el stream y el polling muere: dejas de preguntar para siempre y nadie se entera, porque la pantalla se queda en "Esperando confirmación" como si todo anduviera. Adentro, un `500` en el tick de las 10:00:02 se vuelve un `pollingFailed`, y el tick de las 10:00:04 sale igual.

### Convivencia de estilos en esta fase

El `pollingEpic` es un módulo aparte, sin clase ni hook. La guarda de hora dura, en cambio, toca la UI: vive como función pura reutilizable (`isWheelClosed`) que consumen el asistente (las ruedas cerradas no se ofrecen) y los epics de envío (el rechazo en el borde). La pantalla de compras es funcional con hooks, y para el polling cuando se desmonta: el `useEffect` con su función de limpieza es el `takeUntil` del lado de React.

---

## 💻 5. Implementación y código comentado

Esta fase no instala nada: `cors`, que el mock de Google Play necesita ahora, ya está desde la Fase 3.

### 5.1 La guarda de hora dura — `src/features/wheels/closing.js`

```javascript
// El cierre de una rueda es un instante, no un estado. Funciones puras: reciben el
// ahora como argumento, para que las pruebas lo fijen y nadie dependa del reloj.

/**
 * ¿Está cerrada la rueda en este instante? Cerrada si su estado ya es ended o
 * reconciled, o si el ahora alcanzó closesAt. closesAt trae su offset (-05:00):
 * Date.parse lo convierte en un instante absoluto, igual en cualquier zona.
 * Un closesAt ilegible cuenta como cerrada: ante la duda, no se manda.
 * @param {{ status: string, closesAt: string }} wheel
 * @param {number} now - milisegundos desde epoch (Date.now())
 * @returns {boolean}
 */
export function isWheelClosed(wheel, now) {
  if (wheel.status === "ended" || wheel.status === "reconciled") return true;
  const closesAt = Date.parse(wheel.closesAt);
  if (Number.isNaN(closesAt)) return true;
  return now >= closesAt; // en el instante exacto del cierre, ya está cerrada
}

/**
 * Milisegundos que faltan para el cierre (0 si ya cerró).
 * @returns {number}
 */
export function msUntilClosing(wheel, now) {
  const closesAt = Date.parse(wheel.closesAt);
  if (Number.isNaN(closesAt)) return 0;
  return Math.max(0, closesAt - now);
}

/**
 * Si el premio de un envío es un giro en una rueda, su id; si no, null.
 * Los giros se mandan como `spin:<wheelId>`.
 */
export function spinWheelId(prize) {
  const match = /^spin:(\d+)$/.exec(prize || "");
  return match ? Number(match[1]) : null;
}
```

> **Detalles con intención.**
> - `>=` y no `>`: en el instante exacto del cierre, la rueda ya está cerrada. "Cierra a las 8:00 p. m." quiere decir que a las 8:00:00.000 ya no se envía.
> - Un `closesAt` ilegible cuenta como cerrada. Ante la duda, el default seguro es **no** enviar: un giro que no salió se manda mañana; uno que salió de más no se recupera.
> - `spinWheelId` lee el premio: los giros se mandan como `spin:<id de la rueda>`, y los demás premios (vidas, avatares, gemas) no tienen hora de cierre.

### 5.2 La guarda en la UI: el asistente no ofrece una rueda cerrada

El asistente de la Fase 6 suma los giros como premio, uno por rueda, y trae las ruedas al abrirse:

```jsx
  useEffect(() => {
    dispatch(playerSearchRequested("")); // al abrir: todos los jugadores
    dispatch(fetchWheels()); // F07: los giros se mandan en una rueda, y la rueda tiene hora de cierre
  }, [dispatch]);
```

```jsx
{/* La guarda de la UI: una rueda cerrada no se ofrece. La que manda es la del epic. */}
            {wheels.map((wheel) => {
              const closed = isWheelClosed(wheel, Date.now());
              return (
                <option key={wheel.id} value={`spin:${wheel.id}`} disabled={closed}>
                  Giro en {wheel.name}{closed ? " (cerrada)" : ""}
                </option>
              );
            })}
```

Es una guarda de cortesía: muestra la rueda como "(cerrada)" para que el operador no la elija. Pero el asistente se pinta en un instante y el envío sale **diez segundos después** —la ventana de deshacer—, y en esos diez segundos la rueda puede cerrar. La guarda que manda es la del borde.

### 5.3 La guarda en el borde del envío

La guarda se evalúa en el instante en que el envío sale, con el reloj de las dependencias:

```javascript
import { of } from "rxjs";
import { isWheelClosed, spinWheelId } from "../../wheels/closing";
import { grantSending, rollbackGrant } from "../grantSlice";

/**
 * La guarda de hora dura del envío (F07). Si el envío es un giro en una rueda que
 * ya cerró —o que la consola no tiene cargada: ante la duda, no se manda—, devuelve
 * el rechazo como acciones, sin crear la petición. Si no, null.
 * Se evalúa en el INSTANTE del envío, no al encolar: la ventana de deshacer puede
 * cruzar la hora de cierre.
 */
export function closedWheelRejection(grant, state, now) {
  // now es una función (la dependencia del epic): solo se consulta si el envío es un giro.
  const wheelId = spinWheelId(grant.prize);
  if (wheelId === null) return null;
  const wheel = state.wheels.items.find((w) => w.id === wheelId);
  if (wheel && !isWheelClosed(wheel, now())) return null;
  return of(
    grantSending(grant.id),
    rollbackGrant({
      grantId: grant.id,
      caseId: grant.caseId,
      playerId: grant.playerId,
      error: { message: "La rueda ya cerró: no se envían giros de ella.", type: "closed" },
    })
  );
}
```

Los dos epics que envían la consultan antes de crear la petición; en `sendGrantEpic`, justo después de la guarda de origen:

```javascript
          if (!canSend(grant)) return EMPTY;
          // F07: un giro de una rueda que ya cerró se rechaza acá, en el instante del envío.
          const closed = closedWheelRejection(grant, state$.value, now);
          if (closed) return closed;
```

El rechazo pasa por `grantSending` y `rollbackGrant`, con `type: 'closed'`: el envío queda "Falló" con el motivo, sin que salga ninguna petición. Y el reloj llega al epic por sus dependencias, junto al servicio de compras de la §5.5:

```javascript
import { configureStore } from "@reduxjs/toolkit";
import { createEpicMiddleware } from "redux-observable";
import authReducer, { logout } from "../features/auth/authSlice";
import wheelReducer from "../features/wheels/wheelSlice";
import grantReducer from "../features/grants/grantSlice";
import purchaseReducer from "../features/purchases/purchaseSlice";
import apiClient, { setupInterceptors } from "../api/apiClient";
import apiStore, { attachSession } from "../api/apiStore";
import { history } from "./history";
import { rootEpic } from "./rootEpic";

// El middleware de epics: el puente entre el stream de acciones de Redux y los epics.
// Las dependencias llegan a cada epic como tercer argumento: los epics no importan
// el cliente HTTP, lo reciben, y las pruebas de canicas les pasan uno falso.
// F07 suma el servicio de compras (store) y el reloj (now): las pruebas los reemplazan.
const epicMiddleware = createEpicMiddleware({ dependencies: { api: apiClient, store: apiStore, now: () => Date.now() } });

export const store = configureStore({
  reducer: {
    auth: authReducer,
    wheels: wheelReducer, // Fase 4
    grants: grantReducer, // Fase 5
    purchases: purchaseReducer, // Fase 7
  },
  // getDefaultMiddleware trae thunk, immutable-check y serializable-check.
  // Se concatena el de epics; NO se reemplaza el default (se romperían los thunks de F04).
  middleware: (getDefaultMiddleware) => getDefaultMiddleware().concat(epicMiddleware),
});

// Cerramos el lazo del interceptor: le damos su getToken leyendo del store
// ya construido. El interceptor pregunta al store por el token en cada request.
setupInterceptors(
  () => store.getState().auth.token,
  // Pago de deuda #2: un 401 cierra la sesión y manda a /login.
  () => {
    store.dispatch(logout());
    history.push("/login");
  }
);

// El servicio de compras recibe la misma sesión (F07).
attachSession(() => store.getState().auth.token);

// El rootEpic corre DESPUÉS de crear el store, nunca antes:
// antes, action$ todavía no existe.
epicMiddleware.run(rootEpic);
```

### 5.4 El mock de Google Play: CORS, caos y su contador

El servicio de compras de la Fase 3 se usaba desde la terminal. Ahora lo consulta la consola, desde el navegador: necesita **CORS**. Y como es un servicio externo áspero, recibe el mismo caos del `3001` —con su propio `CHAOS_LEVEL`, porque es otro proceso— y el contador de peticiones sin sesión de la Fase 6:

```javascript
// Mock de Google Play (puerto 3002): verificación de compras, pagos en efectivo pendientes
// y notificaciones que pueden llegar dos veces. Es el servicio externo: nunca lo consume apiClient.
const express = require("express");
const cors = require("cors");
const chaosMiddleware = require("../chaosMiddleware");
const sessionlessCounter = require("../sessionlessCounter");

const PORT = Number(process.env.PORT || 3002);
const PENDING_MS = Number(process.env.PLAY_PENDING_MS || 3000); // demora del pago en efectivo
const DUPLICATE = process.env.PLAY_DUPLICATE === "1";          // notificación repetida

const app = express();
// F07: la consola le habla directo desde el navegador (apiStore), así que hace falta CORS.
app.use(cors());
app.use(sessionlessCounter("3002")); // las consultas que llegan sin sesión, contadas
app.use(chaosMiddleware()); // el mismo caos del 3001, con su propio CHAOS_LEVEL
app.use(express.json());
const purchases = new Map();     // purchaseToken -> { method, createdAt }
const notifications = new Map(); // purchaseToken -> [eventos]

app.post("/purchases", (req, res) => {
  const { purchaseToken, method = "card" } = req.body || {};
  if (!purchaseToken) return res.status(400).json({ error: "falta purchaseToken" });
  purchases.set(purchaseToken, { method, createdAt: Date.now() });
  res.status(201).json({ purchaseToken, method });
});

app.get("/purchases/:token", (req, res) => {
  const p = purchases.get(req.params.token);
  if (!p) return res.status(404).json({ error: "compra desconocida" });
  const pending = p.method === "cash" && Date.now() - p.createdAt < PENDING_MS;
  res.json({ purchaseToken: req.params.token, state: pending ? "pending" : "confirmed" });
});

// Notificación de compra: con PLAY_DUPLICATE=1 el mismo evento llega dos veces.
app.post("/notifications", (req, res) => {
  const { purchaseToken } = req.body || {};
  const event = { purchaseToken, type: "ONE_TIME_PRODUCT_PURCHASED" };
  const events = notifications.get(purchaseToken) || [];
  events.push(event);
  if (DUPLICATE) events.push({ ...event });
  notifications.set(purchaseToken, events);
  res.status(202).json({ received: events.length });
});

app.get("/notifications/:token", (req, res) => {
  res.json(notifications.get(req.params.token) || []);
});

app.listen(PORT, () => {
  console.log(`mock Google Play en ${PORT} · demora=${PENDING_MS} ms · duplicados=${DUPLICATE}`);
});
```

Para probar a mano, una compra en efectivo se crea como la crearía el juego, y queda `pending` durante `PLAY_PENDING_MS`:

```bash
curl -s -X POST localhost:3002/purchases -H 'Content-Type: application/json' \
  -d '{"purchaseToken":"tok-efecty-1","method":"cash"}'
curl -s localhost:3002/purchases/tok-efecty-1     # {"purchaseToken":"tok-efecty-1","state":"pending"}
```

### 5.5 La instancia HTTP del servicio de compras — `src/api/apiStore.js`

```javascript
import axios from "axios";

// La segunda instancia HTTP de la consola: el servicio de compras (el mock de
// Google Play, puerto 3002). Nunca se usa apiClient para esto (D36): son otro
// servicio, con otros fallos, y otro dueño.
const apiStore = axios.create({
  baseURL: "http://localhost:3002",
  timeout: 5000,
});

/**
 * La consola se identifica ante el servicio de compras con la misma sesión.
 * Como en apiClient, el token se lee del store en cada petición: tras un logout,
 * la petición sale sin Authorization.
 * @param {() => (string|null)} getToken
 */
export function attachSession(getToken) {
  apiStore.interceptors.request.use((config) => {
    const token = getToken();
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
  });
}

export default apiStore;
```

Dos instancias y no una (D36): son dos servicios, con dos `baseURL`, dos dueños y fallos de otra clase. Si mañana el servicio de compras pasa a ser el backend propio, se toca esta instancia y ningún epic se entera.

### 5.6 El slice de las compras — `src/features/purchases/purchaseSlice.js`

```javascript
import { createSlice } from "@reduxjs/toolkit";

// Las compras que soporte está siguiendo: una por token, con su último estado conocido.
const purchaseSlice = createSlice({
  name: "purchases",
  initialState: { byToken: {}, pollingToken: null },
  reducers: {
    startPolling(state, action) {
      const token = action.payload;
      state.pollingToken = token;
      state.byToken[token] = state.byToken[token] || { token, state: "unknown", checkedAt: null, error: null };
    },
    stopPolling(state) {
      state.pollingToken = null;
    },
    purchaseStatusReceived(state, action) {
      const { token, state: purchaseState, checkedAt } = action.payload;
      const purchase = state.byToken[token];
      if (!purchase) return;
      purchase.state = purchaseState; // 'pending' | 'confirmed'
      purchase.checkedAt = checkedAt;
      purchase.error = null;
      if (purchaseState === "confirmed" && state.pollingToken === token) state.pollingToken = null;
    },
    pollingFailed(state, action) {
      const { token, error } = action.payload;
      if (state.byToken[token]) state.byToken[token].error = error;
    },
  },
});

export const { startPolling, stopPolling, purchaseStatusReceived, pollingFailed } = purchaseSlice.actions;
export const selectPurchases = (state) => Object.values(state.purchases.byToken);
export const selectPollingToken = (state) => state.purchases.pollingToken;
export default purchaseSlice.reducer;
```

### 5.7 El `pollingEpic` — `src/features/purchases/epics/pollingEpic.js`

```javascript
import { ofType } from "redux-observable";
import { from, of, timer } from "rxjs";
import { catchError, filter, map, mergeMap, switchMap, takeUntil, takeWhile } from "rxjs/operators";
import { toReadableError } from "../../../api/readableError";
import { logout } from "../../auth/authSlice";
import { startPolling, stopPolling, purchaseStatusReceived, pollingFailed } from "../purchaseSlice";

// Cada cuánto se pregunta por una compra pendiente. En Google Play la confirmación
// de un pago en efectivo tarda de minutos a 48 h; el mock la deja en segundos.
export const POLLING_INTERVAL_MS = 2000;

/**
 * El polling de una compra pendiente: pregunta cada POLLING_INTERVAL_MS hasta que
 * la compra se confirma, el operador lo para, o se cierra la sesión.
 *
 *  - switchMap afuera: una compra por vez; consultar otra cancela la anterior.
 *  - catchError POR TICK (adentro del mergeMap): un 500 de un tick no mata el polling.
 *  - takeWhile(…, true): la emisión de "confirmed" pasa, y ahí termina.
 *  - takeUntil: el stop y el logout, que paga la deuda del refresco de la Fase 6.
 */
export const pollingEpic = (action$, state$, { store }) =>
  action$.pipe(
    ofType(startPolling.type),
    switchMap((action) => {
      const token = action.payload;
      return timer(0, POLLING_INTERVAL_MS).pipe(
        mergeMap(() =>
          from(store.get(`/purchases/${token}`)).pipe(
            map((response) =>
              purchaseStatusReceived({ token, state: response.data.state, checkedAt: new Date().toISOString() })
            ),
            catchError((error) => of(pollingFailed({ token, error: toReadableError(error) })))
          )
        ),
        takeWhile((result) => !(purchaseStatusReceived.match(result) && result.payload.state === "confirmed"), true),
        takeUntil(action$.pipe(filter((other) => stopPolling.match(other) || logout.match(other))))
      );
    })
  );
```

Léelo de afuera hacia adentro. `switchMap` sobre `startPolling`: una compra por vez. `timer(0, POLLING_INTERVAL_MS)`: un tick ahora y uno cada dos segundos. Por tick, un `mergeMap` con la consulta y **su** `catchError`. Después, las dos salidas: `takeWhile(…, true)` termina cuando llega la confirmación, dejándola pasar; `takeUntil` termina con el stop del operador o con el logout. Con `PLAY_PENDING_MS=3000`, una compra que empiezas a consultar apenas se crea da `pending` en el tick de 0 s y en el de 2 s, y `confirmed` en el de 4 s.

### 5.8 La pantalla, la ruta y el navbar

```jsx
import React, { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { startPolling, stopPolling, selectPurchases, selectPollingToken } from "./purchaseSlice";

// Compras pendientes: el jugador pagó en efectivo (Efecty, OXXO) y escribe a soporte.
// Soporte pega el código de la compra y la consola pregunta hasta que se confirma.
function PurchasesPage() {
  const dispatch = useDispatch();
  const purchases = useSelector(selectPurchases);
  const pollingToken = useSelector(selectPollingToken);
  const [token, setToken] = useState("");

  // Al salir de la pantalla, el polling se para: no queda nada preguntando en segundo plano.
  useEffect(() => () => dispatch(stopPolling()), [dispatch]);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (token.trim()) dispatch(startPolling(token.trim()));
  };

  return (
    <div className="container mt-4">
      <h2 className="mb-4">Compras pendientes</h2>
      <form onSubmit={handleSubmit} className="form-inline mb-3">
        <label htmlFor="purchaseToken" className="mr-2">Código de la compra</label>
        <input id="purchaseToken" className="form-control mr-2" value={token} onChange={(e) => setToken(e.target.value)} />
        <button type="submit" className="btn btn-primary mr-2">Consultar</button>
        {pollingToken && (
          <button type="button" className="btn btn-link" onClick={() => dispatch(stopPolling())}>
            Dejar de consultar
          </button>
        )}
      </form>
      <table className="table table-sm">
        <thead>
          <tr><th>Código</th><th>Estado</th><th>Última consulta</th></tr>
        </thead>
        <tbody>
          {purchases.map((p) => (
            <tr key={p.token}>
              <td>{p.token}</td>
              <td>
                {p.state === "confirmed" ? "Confirmada" : p.state === "pending" ? "Esperando confirmación" : "Sin consultar"}
                {pollingToken === p.token && " · consultando…"}
                {p.error && <div className="small text-danger">{p.error.message}</div>}
              </td>
              <td>{p.checkedAt || "—"}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default PurchasesPage;
```

En `src/AppRouter.jsx` se suma `/purchases`, y en el navbar, "Compras":

```jsx
import React from "react";
import { Router, Switch, Route, Redirect } from "react-router-dom";
import { history } from "./app/history";
import AppLayout from "./components/AppLayout";
import PrivateRoute from "./components/PrivateRoute";
import LoginPage from "./pages/LoginPage";
import WheelsPage from "./features/wheels/WheelsPage";
import GrantsPage from "./features/grants/GrantsPage";
import GrantBoard from "./features/grants/GrantBoard";
import PurchasesPage from "./features/purchases/PurchasesPage";
import WheelDetailPage from "./pages/WheelDetailPage";
import PlayersPage from "./pages/PlayersPage";
import SpinLogPage from "./pages/SpinLogPage";
import DashboardPage from "./pages/DashboardPage";
import NotFoundPage from "./pages/NotFoundPage";

function AppRouter() {
  return (
    <Router history={history}>
      <AppLayout>
        <Switch>
          {/* pública: sin esto, loop de redirección infinito */}
          <Route path="/login" component={LoginPage} />

          {/* protegidas: eran <Route> en Fase 1, ahora <PrivateRoute> */}
          <PrivateRoute exact path="/wheels" component={WheelsPage} />
          <PrivateRoute path="/wheels/:id" component={WheelDetailPage} />
          <PrivateRoute exact path="/grants/board" component={GrantBoard} />
          <PrivateRoute path="/grants" component={GrantsPage} />
          <PrivateRoute path="/purchases" component={PurchasesPage} />
          <PrivateRoute path="/players" component={PlayersPage} />
          <PrivateRoute path="/spin-log" component={SpinLogPage} />
          <PrivateRoute path="/dashboard" component={DashboardPage} />

          <Route exact path="/">
            <Redirect to="/wheels" />
          </Route>
          <Route component={NotFoundPage} />
        </Switch>
      </AppLayout>
    </Router>
  );
}

export default AppRouter;
```

```jsx
import React from "react";
import { NavLink, useHistory } from "react-router-dom";
import { useSelector, useDispatch } from "react-redux";
import { selectCurrentUser, logout } from "../features/auth/authSlice";

// Funcional: lee la sesión del store y despacha logout. No habla con axios.
// Los textos visibles van en español; las rutas (URLs) en inglés.
function Navbar() {
  const user = useSelector(selectCurrentUser);
  const dispatch = useDispatch();
  const history = useHistory();

  function handleLogout() {
    dispatch(logout()); // limpia el store → la próxima request sale sin token
    history.push("/login");
  }

  return (
    <nav className="navbar navbar-expand navbar-dark bg-dark">
      <NavLink className="navbar-brand" to="/wheels">
        🎡 Esclusa
      </NavLink>
      <div className="navbar-nav">
        <NavLink className="nav-item nav-link" to="/wheels">
          Ruedas
        </NavLink>
        <NavLink className="nav-item nav-link" to="/grants">
          Envíos
        </NavLink>
        <NavLink className="nav-item nav-link" to="/purchases">
          Compras
        </NavLink>
        <NavLink className="nav-item nav-link" to="/players">
          Jugadores
        </NavLink>
        <NavLink className="nav-item nav-link" to="/spin-log">
          Bitácora
        </NavLink>
        <NavLink className="nav-item nav-link" to="/dashboard">
          Dashboard
        </NavLink>
      </div>

      {/* Bloque de sesión: solo aparece con usuario logueado */}
      {user && (
        <div className="navbar-nav ml-auto">
          <span className="navbar-text mr-3">{user.name}</span>
          <button className="btn btn-outline-light btn-sm" onClick={handleLogout}>
            Cerrar sesión
          </button>
        </div>
      )}
    </nav>
  );
}

export default Navbar;
```

### 5.9 Pagar la deuda 💸 del refresco de la Fase 6

El refresco de compras con leak (`purchasesRefreshEpic`) se borra: su trabajo —preguntar por compras pendientes— lo hace ahora `pollingEpic`, que se apaga solo. En `rootEpic.js`, una línea reemplaza a otra:

```javascript
import { combineEpics } from "redux-observable";
import { undoWindowEpic } from "../features/grants/epics/undoWindowEpic";
import { sendGrantEpic } from "../features/grants/epics/sendGrantEpic";
import { searchPlayerEpic } from "../features/grants/epics/searchPlayerEpic";
import { retryGrantEpic } from "../features/grants/epics/retryGrantEpic";
import { pollingEpic } from "../features/purchases/epics/pollingEpic";
import { cancelOnLogoutEpic } from "./cancelOnLogoutEpic";

/**
 * combineEpics fusiona todos los epics en uno solo. El orden no importa para la
 * ejecución (todos escuchan action$ en paralelo), pero se mantiene estable para
 * que el diff en revisión se lea fácil.
 */
export const rootEpic = combineEpics(
  undoWindowEpic,
  sendGrantEpic,
  searchPlayerEpic,
  retryGrantEpic,
  pollingEpic, // F07: reemplaza al refresco con leak de la F06
  cancelOnLogoutEpic
);
```

Y en `mock/db.json` llega una cuarta rueda, la **Rueda de fin de mes**: `live`, con `closesAt` en `2026-08-30T20:00:00-05:00`. Su `status` dice que está viva; su instante de cierre ya pasó. Es el caso que esta fase existe para resolver, y el asistente la muestra como "(cerrada)".

> **Prueba de fuego.** Con `npm run mock:all` arriba y la consola abierta: en `/grants`, la Rueda de fin de mes aparece "(cerrada)" en los premios; la Esclusa de Oro, no. Crea con `curl` una compra en efectivo (§5.4), pégala en `/purchases` y mira Network: un `GET /purchases/tok-…` cada dos segundos, "Esperando confirmación", y a los pocos segundos "Confirmada" — y ahí el polling para solo. Crea otra, empieza a consultarla y cierra sesión: los `GET` paran, y el log del mock de Google Play no anota ninguna consulta "sin sesión".

### 💸 Deuda técnica declarada en esta fase

1. **El reloj es el del navegador.** Un operador con la hora corrida decide mal el cierre. Lo paga `be06`, con el servidor como autoridad del tiempo.
2. **Un código de compra equivocado polea para siempre.** El servicio responde `404` en cada tick, el `catchError` lo vuelve un `pollingFailed`, y el `timer` sigue. Lo correcto es tratar el `404` como final; queda como ejercicio (el 21).
3. **Las compras que soporte sigue viven en el store.** Un F5 las pierde.
4. **El intervalo es fijo.** Un backoff cuando la compra tarda horas ahorraría consultas; es ejercicio 🔥.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Comparar partes de una fecha en vez de instantes.** Síntoma: la consola deja enviar giros de una rueda que ya cerró, o corta una hora antes, según la zona de la máquina que la mira. Causa: alguien hizo `new Date(closesAt).getHours()` y comparó la hora del día, ignorando la fecha y el offset `-05:00`. Fix mínimo: comparar milisegundos (`Date.parse`) como en `isWheelClosed`; nunca desarmar la fecha para la guarda. Corrección contra refactor: el fix es una línea; el refactor es que toda comparación de tiempo viva en `closing.js` y una regla de lint prohíba `getHours()` en el resto del código.

**2. `catchError` afuera del tick.** Síntoma: el polling muere al primer `500` del servicio de compras y la compra se queda "Esperando confirmación · consultando…" para siempre, con el aviso del `500` fijo debajo y la pantalla prometiendo que sigue consultando. Causa: el `catchError` envuelve el `timer` entero en vez de la consulta del tick. Fix: moverlo adentro del `mergeMap` (§5.7). Es el error #1 de la Fase 6 aplicado al polling.

**3. Un polling que no se apaga.** Síntoma: en Network, los `GET /purchases/…` siguen saliendo después de cerrar sesión o de salir de la pantalla. Causa: falta una señal en el `takeUntil` (típico: está el stop pero no el logout), o la pantalla no despacha `stopPolling` al desmontarse. Fix: las dos salidas completas, y el `useEffect` con su limpieza. Es el mismo leak del refresco de la Fase 6, ahora contra un servicio de terceros.

**4. Guardar la guarda de cierre en un solo lugar… el equivocado.** Síntoma: el asistente muestra la rueda "(cerrada)" y aun así sale un giro de ella. Causa: la única guarda está en la UI, y el envío sale diez segundos después del clic, ya pasada la hora. Fix: la guarda que manda es la del epic, en el instante del envío; la de la UI es cortesía.

### Pieza forense de esta fase — Polling que no para

El foco forense es **correlacionar el ritmo de las peticiones con el ciclo de vida del epic**, en dos testigos a la vez: la pestaña Network del navegador y el log del mock de Google Play. Abre Network, filtra por `purchases`, y verifica tres cosas: (a) los `GET /purchases/:token` empiezan con «Consultar» y salen cada `POLLING_INTERVAL_MS`; (b) con `CHAOS_LEVEL=high` en el mock del `3002`, un `500` en un tick aparece en rojo y el tick siguiente sale igual; (c) —lo crítico— al confirmarse la compra, al salir de la pantalla o al cerrar sesión, **los `GET` paran**. Un polling sano deja de aparecer en Network; uno con leak sigue golpeando el `3002`, y el log del mock lo cuenta: `[3002] sin sesión #1: GET /purchases/tok-…`.

**Ejercicio "rompe a propósito y observa":** quita el `logout` del `takeUntil` del `pollingEpic` y deja el resto igual. Levanta el mock de Google Play con `PLAY_PENDING_MS=600000` (diez minutos de compra pendiente), crea una compra, empieza a consultarla y cierra sesión. Observa en Network que el polling **sigue**, ya sin `Authorization`, y en el log del mock que el contador de consultas sin sesión sube cada dos segundos. Vuelve a poner el logout y confirma que el contador no se mueve. Escribe el post-mortem (con los ocho puntos del post-mortem de `cuaderno-incidentes.md`) de por qué un `takeUntil` incompleto es indistinguible de uno correcto hasta que miras la red.

> 📓 De esta fase salen los incidentes **16** y **17** de `cuaderno-incidentes.md`, y la rama del **14** ⭐. El 16 no se reproduce si no declaras la zona horaria del navegador, y el 17 deja la compra esperando para siempre mientras la pantalla jura que sigue consultando.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–7)**
1. Escribe una prueba unitaria de `isWheelClosed` con un `now` fijo un milisegundo antes, en el instante exacto y un milisegundo después de `closesAt`. ¿Cuál es el comportamiento en el borde y por qué se eligió `>=`?
2. Verifica con `node` que `Date.parse("2026-08-30T20:00:00-05:00")` da el mismo número corriendo el proceso con `TZ=America/Panama` y con `TZ=Europe/Madrid`. Explica por qué.
3. Pásale a `isWheelClosed` un `closesAt` corrupto (`"no-soy-fecha"`) y confirma que devuelve `true`. Justifica por qué "cerrada" es el default seguro.
4. En el asistente, muestra junto a cada giro "cierra en X min" usando `msUntilClosing`.
5. Cambia `POLLING_INTERVAL_MS` a 1000 y observa en Network que el ritmo de `GET /purchases` se acelera.
6. Crea con `curl` una compra en efectivo y consulta su estado antes y después de `PLAY_PENDING_MS`. Después crea una con `method: "card"` y explica por qué nace confirmada.
7. Agrega a la pantalla de compras la hora de la última consulta en formato legible (`toLocaleTimeString`), y explica por qué esa hora se formatea pero no se compara.

**🟡 Intermedio (8–16)**
8. Muestra en la lista de envíos el motivo `'closed'` con un mensaje propio, distinto del de un error de red.
9. Encola un giro de la Esclusa de Oro con un `closesAt` que venza en cinco segundos (edítalo en `mock/db.json`) y no lo deshagas: confirma que, al vencer la ventana, el envío se rechaza por cierre.
10. Despacha `startPolling` desde la pantalla y comprueba que, al salir de ella, el `useEffect` despacha `stopPolling` y Network deja de mostrar consultas.
11. Con `CHAOS_LEVEL=high` en el mock de Google Play (y no en el del `3001`), provoca un `500` en un tick y verifica en Network que el tick siguiente sale igual.
12. Explica por qué el `catchError` del `pollingEpic` está dentro del `mergeMap` del tick. Muévelo afuera a propósito y describe qué se rompe.
13. Haz que la consola pase a `ended` una rueda `live` cuyo cierre ya pasó, con un epic que lo detecte, y confirma que la transición ocurre una sola vez.
14. Consulta una compra, y antes de que se confirme consulta otra: confirma en Network que la primera deja de consultarse (`switchMap`).
15. Distingue en Network un `404` (código equivocado) de un `500` (falla del servicio) y muestra qué hace la pantalla con cada uno.
16. Muestra en la pantalla de compras cuántas consultas lleva cada compra pendiente.

**🟠 Difícil (17–24)**
17. **Diagnóstico:** te dan un `pollingEpic` con el `catchError` afuera del tick. Reproduce el síntoma (el polling muere al primer `500`), localiza la línea y aplica el fix mínimo.
18. **Diagnóstico:** un `pollingEpic` tiene el `takeUntil` sin el logout. Muestra en Network y en el log del mock que sigue consultando tras cerrar sesión, y corrígelo. Escribe el post-mortem.
19. **Diagnóstico:** la guarda de cierre usa `new Date().getHours() >= new Date(closesAt).getHours()`. Reproduce el bug con `TZ=America/Santiago npm start` frente a `TZ=America/Panama npm start` y corrige a comparación de instantes.
20. Mide en Network cuántas consultas genera el polling en un minuto con `POLLING_INTERVAL_MS` de 2000 y de 500, y razona el trade-off entre presión sobre el servicio y demora en enterarse.
21. Haz que un `404` termine el polling (el código no existe: no hay nada que esperar), sin que un `500` lo termine. Pista: el `takeWhile` puede mirar también los `pollingFailed`.
22. Reproduce un tick que llega **tarde** tras `stopPolling` (sube la latencia del caos y despacha `stopPolling` justo después de un tick). Muestra que la respuesta vieja no llega al store, y explica qué operador lo garantiza.
23. Escribe una prueba de integración, sin canicas todavía, que cree una compra en el mock, despache `startPolling` y verifique que llegan `pending` y después `confirmed`, y que el polling se detiene.
24. **Refactor:** las dos guardas de cierre (UI y epic) leen la rueda de lugares distintos. Escribe un selector `selectIsWheelClosed(wheelId, now)` y úsalo en las dos, resolviendo dónde vive el `now` sin romper la memoización.

**🔴 Muy difícil (25–30)**
25. **Diagnóstico + regresión:** a veces, tras la confirmación, sale una consulta más. Encuentra la carrera entre el `takeWhile` y una petición en vuelo cuando la confirmación y el tick siguiente caen casi juntos, y propón el fix y la prueba de regresión.
26. Diseña el polling de **varias compras a la vez**: cambia el `switchMap` externo a `mergeMap` por token y explica qué se rompería con `switchMap`. Verifica en Network que corren en paralelo y se cancelan por separado.
27. Reproduce el bug del **reloj del cliente**: adelanta la hora de tu máquina una hora y muestra que la consola cierra la rueda antes de tiempo. Diseña (sin implementar del todo) cómo una hora del servidor enviada en cada respuesta lo mitigaría, y qué fase debería pagarlo.
28. Escribe un diagrama de canicas (en comentario) de `timer(0, 2000)` con `takeWhile` cortando en la confirmación del tercer tick, como anticipo del marble testing de la Fase 10. Marca dónde se limpia la suscripción.
29. **Post-mortem completo** (con los ocho puntos de `cuaderno-incidentes.md`) de un incidente simulado: "la consola siguió consultando compras toda la noche tras el logout de todos los operadores, y el proveedor de pagos nos limitó por abuso". Síntoma, reproducción, evidencia (Network y el log del mock), causa raíz, corrección, prueba de regresión, prevención, sin culpabilización.
30. Agrega backoff con *jitter* al polling cuando una compra lleva más de un minuto pendiente, para que mil consolas que empiezan a consultar a la misma hora no le peguen al servicio en sincronía. Explica el problema y muestra el cambio.

**🔥 Opcionales**
- 🔥 Formatea "cierra en 2 h 15 min" en la zona de quien mira con `Intl.DateTimeFormat` o una librería, dejando la comparación de instantes en `Date.parse`. Justifica por qué la librería suma en el formato y no en la guarda.
- 🔥 Agrega al mock de Google Play un `POST /_chaos` para cambiar su `CHAOS_LEVEL` en caliente, y úsalo para provocar rachas de `500` durante el polling sin reiniciar el proceso.
- 🔥 Haz que la lista de compras sobreviva a un F5 (guárdala en `localStorage`) y explica qué pasa con un polling que estaba en curso.

---

## 📚 8. Referencias

**Documentación oficial**
- https://developer.android.com/google/play/billing/integrate#pending — compras pendientes en Google Play Billing: qué es una compra en estado pendiente y por qué no se acredita hasta que se confirma.
- https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Date/parse — `Date.parse` y el formato ISO 8601 con offset.
- https://rxjs.dev/api/index/function/timer — `timer(0, intervalo)`.
- https://rxjs.dev/api/operators/takeWhile — y su segundo argumento, `inclusive`.
- https://rxjs.dev/api/operators/takeUntil y https://rxjs.dev/api/operators/catchError — las dos de la Fase 6, ahora contra un servicio externo.
- https://expressjs.com/en/resources/middleware/cors.html — el middleware `cors` que suma el mock de Google Play.

**Lectura de apoyo**
- *Falsehoods programmers believe about time* (Noah Sussman, 2012) — una lista corta y dolorosa de supuestos sobre fechas y zonas que esta fase evita.

**Orden de lectura sugerido:** la §4 sobre el instante → `closing.js` → `Date.parse` en MDN → `timer` y `takeWhile` → el `pollingEpic` de la §5.7, con Network abierto.

> ⚠️ URLs, títulos y contenidos pueden estar desactualizados; verifícalos antes de compartir. La doc de RxJS enlazada es la de **6.x**.

---

## 🚀 9. Cierre y conexión con la Fase 8

Saliste de esta fase con un reloj que manda. Un giro de una rueda que cerró no sale, ni aunque el operador lo haya encolado un segundo antes, porque la guarda se evalúa en el instante del envío y compara instantes, no horas del día. Y con un polling que se porta como un servicio bien educado: pregunta cada dos segundos, aguanta los `500` del servicio de compras sin morir, termina solo cuando la compra se confirma y se corta con el logout —la deuda del refresco de la Fase 6, pagada—.

La **Fase 8 — Conciliación** toma esas compras confirmadas y les pone el número que falta: cuánto se cobró, cuánto se lleva la tienda, y cuánto vale cada giro de un paquete de 500 por US$20,99 sin perder un centavo en el reparto. Y suma la otra conciliación, la que la reseña de *"la rueda está arreglada"* pide a gritos: las frecuencias observadas de cada segmento contra los pesos publicados.

> **La señal de que quedó bien:** si cierras sesión con una compra consultándose y el log del mock de Google Play no anota ni una consulta sin sesión, y si la Rueda de fin de mes no deja salir un giro aunque su `status` diga `live` — la fase cumplió su propósito.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-07-cierre-polling-compras -m "F7 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f07: …`) y los de ejercicio su
> número (`f07 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f07/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura. Va acá abajo, fuera de la plantilla de nueve
> secciones, porque es lo que apareció al escribir la fase y no cabía adentro — y
> porque no debe competir con el cierre.

- **El `404` que polea para siempre** está declarado como deuda y como ejercicio, sin fecha. → Decidir si la Fase 9 lo paga cuando el dashboard muestre las compras.
- **La guarda de cierre en dos lugares** (UI y epic) lee la rueda de dos maneras. → Ejercicio 24; si se repite en la Fase 9, pasa a selector.

### Reservas para el cuaderno de incidentes

Los IDs quedan reservados en `cuaderno-incidentes.md`, donde el enunciado ya está redactado con sus pistas y su solución de referencia. El ID nunca se reasigna.

- **16** — *Seguimos enviando giros de una rueda que ya cerró* · Tiempo · 🟠. Sale del error común #1: la hora del día en vez del instante. Solo se ve con dos zonas horarias, y el desacuerdo entre dos máquinas frente al mismo dato es la firma.
- **17** — *La compra pendiente nunca se confirma, y la consola dice que sigue consultando* · RxJS / epics · 🟠. Sale del error común #2: el `catchError` afuera del tick. El primer `500` del servicio de compras apaga el polling, y la pantalla se queda esperando.
- La rama del **14** ⭐ sale de esta fase: el `pollingEpic` sin el logout en su `takeUntil`.
