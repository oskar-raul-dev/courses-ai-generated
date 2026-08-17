# 🧪 Fase 03 — Mock API + Express caos

> Tutorial React 16 — Rifas y chances · Fase 3 de 11 · **6 horas**
> Depende de: Fase 2 — Autenticación mínima · Habilita: Fase 4 — Rifas CRUD

---

## 🎯 1. Propósito

Hasta ahora la app vivía de mentiras piadosas: un login mock que siempre
respondía bien y ningún dato real detrás. Esta fase le pone un backend de
mentira, pero uno que **falla como falla un backend real** — con latencia
variable, 500 al azar, timeouts, respuestas rotas y, ahora sí, **401 de
verdad**. No es capricho: el sistema que vas a mantener tiene un backend
real con sus propios malos días, y el equipo de Maintenance necesita
practicar en un entorno que se comporta igual de mal, pero de forma
controlada y reproducible.

Esta fase también es donde el andamiaje de auth que montamos en la Fase 2
por fin se enfrenta a un backend áspero. Fase 2 construyó la estructura
en el frontend (login, slice, `PrivateRoute`, interceptor) sobre un mundo
ideal donde nada fallaba. Acá se cobran dos deudas que quedaron
declaradas allá y que solo tienen sentido pagar ahora que el backend
puede portarse mal: **la persistencia de sesión** y **el manejo global de
401**. La frontera de diseño es clara: Fase 2 = andamiaje de auth en el
frontend; Fase 3 = ese andamiaje enfrentado a un backend real.

Además separamos algo importante desde ya: el **mock de lotería** vive en
su propio servidor, en su propio puerto, con su propio caos. Es el mock
que vas a necesitar intacto (y ya inestable) cuando lleguemos al polling
de resultados en la Fase 7.

> 📝 **Nota de convención (2026-07-15).** A partir de esta fase el código
> del curso va en **inglés** (identificadores, endpoints, enums), y la
> narrativa, los comentarios y los textos de interfaz siguen en
> **español**. Por eso vas a ver `raffles`, `createChaosMiddleware` y
> `status: 'open'` en el código, pero `"Token inválido o expirado"` como
> mensaje al usuario. El detalle está en `DICCIONARIO-CODIGO-INGLES.md`.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `json-server` corriendo en el puerto `3001`, sirviendo `db.json`
      (`raffles`, `numbers`, `participants`, `settlements`) con CRUD
      funcional desde la app en `3000`.
- [ ] Middleware caos genérico (`chaosMiddleware.js`) montado sobre el
      servidor de `3001`: latencia configurable, error 5xx aleatorio,
      timeout, respuesta malformada y **401 sobre rutas protegidas**.
      Activable con `CHAOS_LEVEL`.
- [ ] Mock de lotería corriendo como servidor Express **separado** en el
      puerto `3002`, con el mismo caos aplicado desde ya (latencia
      100-3000ms, ~10% de fallos intermitentes).
- [ ] **💸 Pago de deuda de Fase 2 (persistencia de sesión):** `token` y
      `user` se rehidratan desde `localStorage` al arrancar y se
      sincronizan en cada cambio, con las trampas de `localStorage`
      explicadas.
- [ ] **💸 Pago de deuda de Fase 2 (manejo global de 401):** el
      interceptor de response de `apiClient` detecta un 401 real, despacha
      `logout` y redirige a `/login`, correlacionando por `request-id`.
- [ ] Capacidad de reproducir bugs a demanda: "se cayó el mock", "tardó 3
      segundos", "devolvió basura", "me sacó la sesión" — y observar cómo
      reacciona la SPA.

---

## 🚫 3. Qué queda fuera por ahora

- **Paginación server-side** en `json-server` → se difiere; con el
  volumen de datos de este curso no hace falta, y forzarla ahora
  distraería del objetivo de la fase.
- **El epic que consuma el mock de lotería** (polling, debounce,
  cancelación) → Fase 6 y Fase 7. Acá solo dejamos el mock funcionando y
  fallando; nadie lo consume todavía desde Redux.
- **Refresh token / renovación silenciosa de sesión** → fuera de alcance.
  El 401 acá termina en logout, no en un intento de renovar el token.
- **Persistencia real entre reinicios del mock** → `db.json` se resetea a
  mano; no hay seed automatizado. No es el objetivo.

---

## 🧠 4. Conceptos mínimos

**¿Por qué dos servidores mock y no uno solo?** Porque el CRUD de rifas y
la consulta de resultados de lotería tienen perfiles de fallo distintos
en el sistema real: el CRUD es relativamente estable (es tu propio
backend), pero la lotería es un servicio externo con su propio SLA, su
propia latencia y sus propios apagones. Si mezclás el caos de ambos en el
mismo servidor, cuando algo falle no vas a saber si el problema es "tu
backend" o "el proveedor de lotería" — que es exactamente la ambigüedad
que un dev de Maintenance necesita aprender a distinguir rápido.

**`json-server`** te da un CRUD completo (GET/POST/PUT/PATCH/DELETE)
leyendo y escribiendo directamente sobre un archivo `db.json`, sin que
escribas una sola ruta. Es ideal para las Fases 3-5.

**El middleware caos** es un middleware de Express que se mete *antes* de
que la petición llegue a su handler normal, y decide —con una
probabilidad configurable— si la deja pasar, la retrasa, la revienta con
un 500, la cuelga (timeout), le devuelve un JSON roto, o —sobre rutas
protegidas— responde `401`. No hay magia: es `Math.random()` y
`setTimeout()` con buen criterio.

**¿Por qué el 401 aparece recién ahora?** Porque en la Fase 2 lo dejamos
como ejercicio 🟠, deliberadamente fuera del código base: `json-server` no
emite 401 por sí solo, así que un interceptor que lo manejara habría sido
**código muerto** — imposible de probar de verdad. Ahora que el caos puede
inyectar un 401 real sobre una ruta protegida, ese manejo deja de ser
teoría y se sube al código base. Es el momento correcto, ni antes ni
después.

**`CHAOS_LEVEL`** es la variable de entorno que decide qué tan agresivo es
el caos. Definimos tres niveles:

| Nivel | Latencia | Prob. de fallo | Uso típico |
|---|---|---|---|
| `off` | 0-50ms (red normal) | 0% | Desarrollar features nuevas sin ruido. |
| `low` | 100-800ms | ~5% | Trabajo normal del día a día, algo de fricción real. |
| `high` | 300-3000ms | ~15-20% | Practicar resiliencia, reproducir incidentes, la pieza forense de esta fase. |

> 📝 **Nota de época.** En el sistema real este "modo caos" no existía como
> tal — el caos venía gratis, sin avisar, un martes a las 4pm. Acá lo
> hacemos explícito y controlable porque el objetivo es *entrenar el ojo*,
> no sufrir al azar. Un buen entorno de práctica hace reproducible lo que
> en producción es intermitente.

> 📝 **Nota de convivencia.** El interceptor de `apiClient` viene de la
> Fase 2 y ahí se escribió como código de request (agregar token y
> `request-id`). Acá le sumamos un interceptor de **response** para el
> 401. Ambos conviven en la misma instancia; no reescribimos el de
> request, lo extendemos.

---

## 💻 5. Implementación y código comentado

### Estructura de carpetas del mock

```
mock/
├── db.json                  # datos para json-server (raffles, numbers, participants, settlements)
├── server.js                # json-server + middleware caos, puerto 3001
├── chaosMiddleware.js        # middleware caos genérico, reutilizado por ambos servidores
├── lottery/
│   └── server.js            # servidor Express propio para el mock de lotería, puerto 3002
├── package.json
└── .env                      # CHAOS_LEVEL=low (por defecto)
```

### `db.json` — datos base para json-server

```json
{
  "raffles": [
    {
      "id": 1,
      "name": "Rifa fin de mes",
      "lotteryId": "boyaca",
      "closesAt": "2026-08-30T22:00:00-05:00",
      "numberPrice": 5000,
      "basePrize": 500000,
      "status": "open"
    }
  ],
  "numbers": [
    { "raffleId": 1, "number": "0347", "status": "available" },
    { "raffleId": 1, "number": "1500", "status": "available" }
  ],
  "participants": [],
  "settlements": []
}
```

Fijate que las **claves** (`raffles`, `numbers`, `status`) van en inglés,
pero el **valor** `"Rifa fin de mes"` es un dato de dominio que un humano
escribió y ve — se queda en español. `json-server` usa las claves de este
archivo como recursos REST completos: `GET /raffles`, `POST /numbers`,
`PATCH /raffles/1`, y así.

### `chaosMiddleware.js` — el inyector de fallos

```javascript
// chaosMiddleware.js
// Middleware caos genérico. Se monta antes de las rutas reales de
// json-server o de un servidor Express propio (como el de lotería).
// No sabe nada del dominio: solo decide si la petición pasa, se retrasa,
// falla o vuelve corrupta.

/**
 * Configuración de cada nivel de caos.
 * minMs/maxMs: rango de latencia inyectada en cada petición.
 * failRate: probabilidad (0-1) de que la petición termine en error
 *           en vez de pasar al handler real.
 */
const CHAOS_LEVELS = {
  off:  { minMs: 0,   maxMs: 50,   failRate: 0 },
  low:  { minMs: 100, maxMs: 800,  failRate: 0.05 },
  high: { minMs: 300, maxMs: 3000, failRate: 0.18 },
};

// Rutas consideradas "protegidas": un 401 acá simula un token vencido
// o inválido. Sobre rutas públicas no tiene sentido inyectar 401.
const PROTECTED_ROUTES = ["/raffles", "/numbers", "/participants", "/settlements"];

function randomBetween(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function isProtectedRoute(path) {
  return PROTECTED_ROUTES.some((base) => path.startsWith(base));
}

/**
 * Elige qué tipo de fallo inyectar cuando toca fallar.
 * Si la ruta es protegida, el 401 entra en la baraja (simula sesión
 * caída). Si es pública, el 401 se excluye.
 * @param {boolean} isProtected
 */
function pickFailureType(isProtected) {
  const roll = Math.random();
  if (isProtected) {
    if (roll < 0.25) return "unauthorized"; // sesión caída (401)
    if (roll < 0.55) return "serverError";  // 500
    if (roll < 0.82) return "timeout";
    return "malformed";
  }
  if (roll < 0.5) return "serverError";
  if (roll < 0.85) return "timeout";
  return "malformed";
}

/**
 * Factory: crea el middleware ya configurado según CHAOS_LEVEL.
 * @param {string} level - 'off' | 'low' | 'high'
 * @returns {import('express').RequestHandler}
 */
function createChaosMiddleware(level = "off") {
  const config = CHAOS_LEVELS[level] || CHAOS_LEVELS.off;

  return function chaosMiddleware(req, res, next) {
    const latency = randomBetween(config.minMs, config.maxMs);

    setTimeout(() => {
      const shouldFail = Math.random() < config.failRate;
      if (!shouldFail) return next(); // caso feliz: solo latencia

      const isProtected = isProtectedRoute(req.path);
      const type = pickFailureType(isProtected);

      if (type === "unauthorized") {
        // 401 real sobre ruta protegida: esto es lo que dispara el
        // manejo global de sesión en el interceptor de apiClient.
        // El valor del mensaje va en español: lo puede leer un humano.
        return res.status(401).json({ message: "Token inválido o expirado" });
      }

      if (type === "serverError") {
        // 💸 mensaje genérico a propósito: en el sistema real vas a ver
        // errores igual de poco útiles. Practicá con esto.
        return res.status(500).json({ message: "Error interno del servidor" });
      }

      if (type === "timeout") {
        // no responde nada: la petición cuelga. El cliente axios debe
        // tener su propio timeout — si no lo tiene, este es el bug.
        return;
      }

      if (type === "malformed") {
        // 200 con cuerpo que no es el JSON esperado.
        res.status(200);
        return res.send("<html>esto no es JSON, alguien mezcló ambientes</html>");
      }
    }, latency);
  };
}

module.exports = { createChaosMiddleware, CHAOS_LEVELS };
```

**Detalles con intención:**
- El 401 (`unauthorized`) solo se inyecta sobre rutas protegidas: no tiene
  sentido que un endpoint público te "eche" la sesión. Esa asimetría es la
  que hace realista el ejercicio.
- El timeout no responde nada a propósito. Si tu cliente axios no tiene
  `timeout` configurado, la petición cuelga indefinidamente.
- Los cuatro tipos de fallo no son igual de fáciles de detectar: el 500 y
  el 401 se ven enseguida en Network; el timeout se siente como "la app se
  congeló"; el malformado a veces ni rompe nada visible hasta que alguien
  confía en `response.data.algo`.

### `server.js` — json-server + caos, puerto 3001

```javascript
// server.js
const jsonServer = require("json-server");
const { createChaosMiddleware } = require("./chaosMiddleware");
require("dotenv").config();

const server = jsonServer.create();
const router = jsonServer.router("db.json");
const middlewares = jsonServer.defaults();

const level = process.env.CHAOS_LEVEL || "off";
console.log(`[mock-api] CHAOS_LEVEL=${level} (puerto 3001)`);

server.use(middlewares);
server.use(createChaosMiddleware(level)); // el caos va ANTES del router
server.use(router);

server.listen(3001, () => {
  console.log("json-server + caos escuchando en http://localhost:3001");
});
```

> ⚠️ El orden importa: el middleware caos se monta **antes** que `router`.
> Si lo montás después, el caos nunca se ejecuta porque `json-server` ya
> respondió.

### `lottery/server.js` — mock de lotería, puerto 3002

```javascript
// lottery/server.js
// Mock de la API de lotería. Servidor propio, separado del CRUD de
// rifas, porque su perfil de fallo es distinto: es "un tercero" al que
// le consultamos el resultado, no nuestro propio backend.
//
// 📝 Nota de diseño (Fase 3): el caos completo se activa acá desde ya,
// aunque nadie lo consuma todavía desde un epic — eso llega en la Fase 6
// y Fase 7. La decisión se tomó explícitamente en el chat de esta fase
// para que Fase 6-7 hereden un mock ya inestable y se concentren en el
// epic (polling, cancelación, retry), no en armar el caos del mock.

const express = require("express");
const { createChaosMiddleware } = require("../chaosMiddleware");
require("dotenv").config();

const app = express();

// El mock de lotería corre con caos "high" por defecto: 100-3000ms de
// latencia y ~10-18% de fallos, para que el polling que se construya
// después tenga algo real que reintentar. Ojo: la lotería no es una
// ruta "protegida", así que no inyecta 401 — sus fallos son 500,
// timeout y malformado.
const level = process.env.CHAOS_LOTTERY_LEVEL || "high";
console.log(`[mock-lottery] CHAOS_LEVEL=${level} (puerto 3002)`);

app.use(createChaosMiddleware(level));

app.get("/results/:raffleId", (req, res) => {
  res.json({
    raffleId: Number(req.params.raffleId),
    lotteryId: "boyaca",
    winningNumber: "0347",
    checkedAt: new Date().toISOString(),
    source: "lottery-api-mock",
  });
});

app.listen(3002, () => {
  console.log("mock de lotería escuchando en http://localhost:3002");
});
```

### `.env` — nivel de caos por defecto

```bash
CHAOS_LEVEL=low
CHAOS_LOTTERY_LEVEL=high
```

### `package.json` (scripts relevantes)

```json
{
  "scripts": {
    "mock:api": "node server.js",
    "mock:lottery": "node lottery/server.js",
    "mock:all": "concurrently \"npm run mock:api\" \"npm run mock:lottery\""
  }
}
```

---

### 💸 Pago de deuda #1 — Persistencia de sesión

En la Fase 2 el `authSlice` arrancaba siempre vacío: recargá la página y
la sesión se perdía. Se marcó 💸 con la promesa de pagarlo acá. Lo
pagamos rehidratando `token` y `user` desde `localStorage` al arrancar y
sincronizando en cada cambio.

```javascript
// src/features/auth/authStorage.js
// Punto único de contacto con localStorage para la sesión. Aislarlo acá
// (y no esparcir localStorage por todo el slice) es lo que permite, el
// día de mañana, cambiar de localStorage a otra cosa tocando un archivo.

const STORAGE_KEY = "rifas.auth";

/**
 * Lee la sesión persistida. Devuelve null si no hay o si está corrupta.
 * @returns {{ token: string, user: object } | null}
 */
export function readSession() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    return JSON.parse(raw);
  } catch {
    // Si alguien manoseó el storage y quedó basura, no reventamos el
    // arranque de la app: tratamos como "sin sesión".
    return null;
  }
}

/** Persiste la sesión. */
export function saveSession(token, user) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify({ token, user }));
}

/** Borra la sesión (logout). */
export function clearSession() {
  localStorage.removeItem(STORAGE_KEY);
}
```

El `authSlice` (nombre congelado en Fase 2) usa `readSession()` para su
estado inicial y sincroniza en los reducers de login/logout:

```javascript
// src/features/auth/authSlice.js  (extracto — se respeta lo definido en Fase 2)
import { createSlice } from "@reduxjs/toolkit";
import { readSession, saveSession, clearSession } from "./authStorage";

const persisted = readSession();

const initialState = {
  token: persisted?.token || null,
  user: persisted?.user || null,
};

const authSlice = createSlice({
  name: "auth",
  initialState,
  reducers: {
    loginSucceeded(state, action) {
      state.token = action.payload.token;
      state.user = action.payload.user;
      // sincronizamos el storage con el estado en el mismo lugar donde
      // el estado cambia: así nunca quedan desalineados.
      saveSession(action.payload.token, action.payload.user);
    },
    logout(state) {
      state.token = null;
      state.user = null;
      clearSession();
    },
  },
});

export const { loginSucceeded, logout } = authSlice.actions;

// Selectores congelados en Fase 2 — no se renombran.
export const selectAuth = (state) => state.auth;
export const selectCurrentUser = (state) => state.auth.user;
export const selectIsAuthenticated = (state) => Boolean(state.auth.token);

export default authSlice.reducer;
```

> ⚠️ **Las trampas de `localStorage`** (prometidas en el cierre de Fase 2):
> es **legible por cualquier script** de la página (si te comés un XSS, se
> comen el token) — por eso nunca guardes ahí nada más sensible que un
> token de sesión de vida corta; es **compartido entre pestañas** del
> mismo origen, así que un logout en una pestaña **no** limpia el estado
> en memoria de las otras (el `localStorage` sí se actualiza, pero el
> store de Redux de la otra pestaña no se entera solo — hay un ejercicio
> 🔴 sobre esto); y **no se limpia solo**: si no llamás `clearSession()`,
> el token sobrevive al cierre del navegador.

**Trade-off (por qué `localStorage` y no otra cosa):** elegí
`localStorage` porque es lo que el sistema real usa y lo que Fase 2
prometió mostrar, trampas incluidas. Las alternativas: `sessionStorage`
se limpia al cerrar la pestaña (más seguro ante "me dejé la sesión
abierta en una compu ajena", pero pierde la sesión en cada cierre, lo que
molesta en uso normal); mantener el token **solo en memoria** (nada
persistido) es lo más seguro contra robo por XSS, pero obliga a
re-loguear en cada recarga — inviable para el flujo de trabajo diario del
operador de rifas. `localStorage` es el punto medio pragmático que
predomina en apps de esta época, con el costo de seguridad que se explica
arriba. Saber *por qué* se eligió (y qué se sacrificó) es justamente lo
que distingue mantener de copiar.

### 💸 Pago de deuda #2 — Manejo global de 401

En la Fase 2 esto era el ejercicio 🟠 #19, fuera del código base porque
`json-server` no emitía 401 y habría sido código muerto. Ahora que el caos
inyecta 401 reales sobre rutas protegidas, lo subimos al interceptor de
**response** de `apiClient` (nombre congelado en Fase 2) como código base.

```javascript
// src/api/apiClient.js  (extracto — el interceptor de request viene de Fase 2)
import axios from "axios";
import { store } from "../app/store";
import { logout } from "../features/auth/authSlice";
import { history } from "../app/history"; // history compartido para redirigir fuera de componentes

export const apiClient = axios.create({
  baseURL: "http://localhost:3001",
  timeout: 5000, // clave: sin esto, un timeout del mock cuelga la UI
});

// --- Interceptor de REQUEST: viene de Fase 2, NO se reescribe ---
// (agrega Authorization y X-Request-Id; se deja tal cual quedó en Fase 2)

// --- Interceptor de RESPONSE: NUEVO en Fase 3 (pago del ex-ejercicio #19) ---
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      // Correlación: el request-id lo puso el interceptor de request de
      // Fase 2. Lo recuperamos del config para poder cruzar esta caída
      // con el log del servidor mock.
      const requestId = error.config?.headers?.["X-Request-Id"];
      console.warn(`[auth] 401 recibido (request-id=${requestId}). Cerrando sesión.`);

      // Sesión inválida: limpiamos estado + storage y mandamos a login.
      store.dispatch(logout());
      history.push("/login");
    }
    // Cualquier otro error sigue su curso normal hacia el .catch() del caller.
    return Promise.reject(error);
  }
);
```

**Detalles con intención:**
- El `dispatch(logout())` reusa el reducer del pago #1, así que limpiar la
  sesión y borrar el `localStorage` es una sola cosa, no dos que se pueden
  desincronizar.
- Correlacionamos por `request-id`: cuando un 401 tumba la sesión de un
  usuario en PROD, poder cruzar el `request-id` del log del navegador con
  el del backend es la diferencia entre "no sé qué pasó" y "esta petición
  exacta, a esta hora, devolvió 401".

**Corrección mínima vs. refactorización:** subir el manejo de 401 al
interceptor es la corrección mínima correcta para "sesión caída = logout".
Lo que **no** hacemos hoy (sería refactor, con más pruebas y fuera de
alcance): intentar **renovar** el token con un refresh antes de rendirse.
Eso queda anotado como pendiente, no como deuda de esta fase.

### El patrón a memorizar

Cada servicio externo tiene su propia instancia de axios con su propio
`baseURL` y su propio `timeout`; el manejo transversal (token, request-id,
401) vive en los interceptores de esa instancia, **no** repetido en cada
componente. Un componente nunca debería saber qué es un 401.

### 💸 Deuda técnica que queda abierta en esta fase

- El resultado de lotería está **hardcodeado** (`winningNumber: "0347"`) —
  no depende de qué números se vendieron. Se paga en la Fase 7.
- El `CHAOS_LEVEL` se lee una sola vez al arrancar: cambiarlo requiere
  reiniciar el proceso. Intencional; si un incidente lo justifica, se
  agrega `POST /_chaos` (hay un 🔥 para eso).

### Prueba de fuego

Con `CHAOS_LEVEL=high`, logueate y hacé clic repetidas veces en algo que
pegue a `/raffles`. Tarde o temprano vas a comer un 401 inyectado: la app
debería **sacarte a `/login` sola**, con el `localStorage` limpio. Volvé a
entrar y confirmá que la sesión persiste tras recargar (F5) — eso valida
los dos pagos a la vez: el 401 dispara el logout global, y la persistencia
mantiene la sesión mientras el 401 no aparezca.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

1. **"El CRUD nunca falla, no sirve para nada este caos."** El middleware
   caos se montó *después* del `router`. Fix: verificar el orden de
   `server.use()`.
2. **"La app se congela y no hay ningún error en consola."** Timeout del
   mock sin `timeout` en el cliente axios. Corrección mínima: agregar
   `timeout: 5000`. Refactor (fuera de alcance): interceptor global de
   timeouts.
3. **"Me saca a login al azar y no entiendo por qué."** Es el 401
   inyectado por el caos sobre ruta protegida, funcionando como debe. No
   es un bug: es la práctica. Bajá `CHAOS_LEVEL` a `low` u `off` para
   trabajar tranquilo.
4. **"Recargo la página y sigo logueado aunque el token ya no vale."** La
   persistencia guarda el token, pero solo un 401 real lo invalida. Es
   correcto: el frontend no puede saber solo que un token venció; se
   entera cuando el backend lo rechaza. Ese es justamente el rol del
   interceptor de 401.
5. **"Confundí en qué puerto está cada mock."** Verificá `baseURL` contra
   la tabla: `3000` app, `3001` CRUD, `3002` lotería.

### Pieza forense de esta fase — Simular caos con Express: cómo reacciona la SPA

Con `CHAOS_LEVEL=high` en `3001` y la app corriendo, abrí Network en
Chrome DevTools y reproducí, anotando qué ve el usuario:

1. **500 puro:** filtrá Network por status `500`. ¿La UI avisa algo o
   falla en silencio?
2. **Timeout:** buscá una petición "pendiente" más de 5s. ¿Tu axios la
   corta? ¿Qué ve el usuario?
3. **Malformado:** forzalo (subí `failRate` a 1 temporalmente) y mirá si
   el componente explota al parsear o lo maneja con gracia.
4. **401 y correlación:** provocá un 401, confirmá que la app te saca a
   `/login`, y **cruzá el `request-id`** del `console.warn` del
   interceptor con el mismo `request-id` en el log del servidor mock.
   Este es el ejercicio de correlación de punta a punta.

> 💡 Truco: para forzar un tipo de fallo específico sin esperar al azar,
> hacé que `pickFailureType()` devuelva siempre el tipo que querés.
> Revertí después.

Esta pieza forense se referencia luego en `Forense - Fase 03`.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**
1. Levantá `json-server` en `3001` y confirmá con `curl` que `GET /raffles`
   devuelve la rifa de ejemplo.
2. Cambiá `CHAOS_LEVEL` a `off` y confirmá respuestas en menos de 50ms.
3. Cambiá `CHAOS_LEVEL` a `high` y contá cuántas de 20 peticiones a
   `/raffles` fallan.
4. Levantá el mock de lotería en `3002` y confirmá con `curl` que
   `GET /results/1` devuelve el JSON esperado.
5. Con la sesión iniciada, recargá la página (F5) y confirmá que seguís
   logueado (validación del pago de persistencia).
6. Hacé logout y confirmá en DevTools → Application → Local Storage que la
   clave `rifas.auth` desapareció.
7. Agregá `console.log(level)` en `chaosMiddleware.js` y confirmá que
   coincide con tu `.env`.
8. Explicá en un comentario por qué el caos debe montarse antes del
   `router` de json-server.

**🟡 Intermedio (9–17)**
9. Provocá un 401 con `CHAOS_LEVEL=high` y confirmá que la app te
   redirige a `/login` sola.
10. Meté a mano un JSON corrupto en la clave `rifas.auth` de localStorage
    y confirmá que la app arranca como "sin sesión" en vez de reventar
    (probá que `readSession()` devuelve `null`).
11. Agregá un nivel `CHAOS_LEVEL=extreme` a `CHAOS_LEVELS` con
    `failRate: 0.4` y probalo.
12. Quitá el `timeout` de `apiClient` y documentá, con capturas de
    Network, qué le pasa a la UI bajo `high`.
13. Verificá que el 401 **no** se inyecta sobre una ruta pública (agregá
    una ruta pública de prueba y comprobá que `isProtectedRoute()` la
    excluye).
14. Correlacioná un 401: encontrá el `request-id` en el `console.warn` del
    interceptor y buscalo en el log del servidor mock.
15. Agregá una ruta `/health` a json-server que **no** pase por el caos,
    para health-checks.
16. Documentá en un comentario la diferencia entre corrección mínima
    (logout en interceptor) y refactor (refresh token) para el 401.
17. Cambiá `CHAOS_LOTTERY_LEVEL` a `off` y confirmá que `/results/1`
    responde siempre rápido y sin fallos.

**🟠 Difícil (18–24)**
18. Reproducí el error común #1 a propósito (caos después del router) y
    confirmá con Network que nunca se activa.
19. Escribí un script Node que dispare 50 peticiones concurrentes a
    `/raffles` bajo `high` y cuente cuántas cayeron en cada tipo
    (`ok`/`unauthorized`/`serverError`/`timeout`/`malformed`).
20. Diagnosticá: "a veces el dashboard muestra `undefined` en vez del
    nombre de la rifa". Formulá una hipótesis con lo que sabés del caos y
    confirmala con Network.
21. Agregá al interceptor de response un log cuando una respuesta tarde
    más de 1000ms (instrumentación de latencia).
22. Hacé que el `failRate` del tipo `unauthorized` dependa de la ruta (por
    ejemplo, `/settlements` nunca da 401) y explicá un caso de uso real.
23. Sin mirar `chaosMiddleware.js`, deducí a partir de Network qué
    `failRate` aproximado está configurado.
24. Diagnosticá un `PATCH /numbers/...` que cae en `malformed`: ¿el número
    queda en estado inconsistente en `db.json`?

**🔴 Muy difícil (25–30)**
25. **Sesión zombi entre pestañas:** abrí la app en dos pestañas, logueate
    en ambas, y hacé logout en una. Confirmá que la otra pestaña sigue
    mostrando sesión activa en su store de Redux aunque el `localStorage`
    ya se limpió. Documentá por qué pasa y proponé (sin implementar) cómo
    sincronizarlas.
26. Diseñá y documentá un incidente propio (síntoma + reproducción + causa
    raíz) combinando un 401 inyectado y un componente que no maneja el
    redirect.
27. Correlación punta a punta: armá el flujo completo que cruza un 401 en
    Network → `request-id` en consola → `request-id` en el log del mock,
    y escribilo como procedimiento reproducible.
28. Extendé `chaosMiddleware` con latencia de distribución no uniforme
    (muchas rápidas, pocas muy lentas) y justificá por qué se parece más a
    un backend real.
29. Investigá qué pasa si un 401 llega **mientras** una segunda petición
    protegida ya está en vuelo: ¿se despacha `logout` dos veces? ¿importa?
30. Semilla para el cuaderno de incidentes: proponé un incidente 🟡 de
    "CORS" para la Semana 1, considerando los tres orígenes (`3000`,
    `3001`, `3002`).

**🔥 Opcionales**
- 🔥 Agregá `POST /_chaos` para cambiar `CHAOS_LEVEL` en caliente sin
  reiniciar (adelanto de la deuda de la sección 5).
- 🔥 Sincronizá el logout entre pestañas con el evento `storage` de
  `window` (resuelve el ejercicio 🔴 #25 de verdad).
- 🔥 Dockerizá ambos mocks en el `docker-compose.yml` de la Fase 0.

---

## 📚 8. Referencias

**Documentación oficial**
- https://github.com/typicode/json-server — json-server, versión 0.16.x fijada en el proyecto.
- https://expressjs.com/en/guide/using-middleware.html — orden y uso de middleware en Express.
- https://axios-http.com/docs/interceptors — interceptores de request y response en axios 0.21.x.
- https://developer.mozilla.org/es/docs/Web/API/Window/localStorage — `localStorage`, incluyendo notas de seguridad.

**Video / apoyo**
- Búsqueda sugerida en YouTube: "json-server tutorial crash course" — confirmá que corresponda a la versión 0.x (json-server tuvo cambios grandes en su v1).

**Orden de lectura sugerido:** README de json-server → guía de middleware de Express → doc de interceptores de axios → volver al código de `chaosMiddleware.js` y `apiClient.js`.

> ⚠️ Verificá siempre la versión de la documentación: `json-server` tuvo
> cambios de API entre 0.x y versiones recientes (este proyecto fija
> 0.16.x). Los títulos y URLs de videos pueden estar desactualizados;
> confirmalos antes de recomendarlos al grupo.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Con esto la app dejó de vivir en un mundo perfecto: tiene un backend que
responde como uno real (500, lentitudes, respuestas rotas y 401), un mock
de lotería ya inestable esperando en `3002`, y —por fin— el andamiaje de
auth de la Fase 2 cobrando sus dos deudas: la sesión persiste entre
recargas y un 401 real te saca a login de forma global y correlacionable.
La frontera quedó respetada: Fase 2 puso el andamiaje, Fase 3 lo enfrentó
al backend áspero.

La Fase 4 va a usar el CRUD de `3001` para construir el primer slice de
Redux Toolkit real —el `raffleSlice`, con su `RaffleTable` y su
`RaffleForm`— ya sobre un mock que a veces falla y que a veces te pide
volver a loguearte, no sobre un mundo ideal.

> **La señal de que quedó bien:** si apagás `json-server` a mitad de una
> demo y la app muestra un error claro en vez de congelarse —y si un token
> vencido te devuelve a login sin dejar la sesión colgada— esta fase
> cumplió su propósito.
