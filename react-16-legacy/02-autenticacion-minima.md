# 🔐 Fase 02 — Autenticación mínima

> Tutorial React 16 — Rifas y chances · Fase 2 de 11 · **8 horas**
> Depende de: Fase 1 — Estructura base y Router 5 · Habilita: Fase 3 — Mock API y Express caos

---

## 🎯 1. Propósito

Hasta ahora la app de rifas es un showroom con las puertas abiertas: cualquiera que teclee `/raffles` en la barra de direcciones entra y ve el tablero. En un sistema que vas a mantener eso no vuela ni en UAT. Esta fase pone la cerradura mínima —y de paso estrena el **primer Redux del curso**—: un login que valida contra un backend mock, un lugar central donde vive "quién está logueado" (el `authSlice`), un punto único por donde pasan todas las peticiones HTTP (el interceptor de `apiClient`) y una guarda de rutas (`PrivateRoute`) que manda al login a quien no tenga sesión.

El objetivo no es construir un sistema de identidad de verdad —eso lo hace un equipo de plataforma, no tú en un hotfix— sino montar el andamiaje que te vas a encontrar en el código real y aprender a leerlo, correlacionar sus peticiones con un `requestId`, y depurarlo cuando algo devuelve 401 y nadie sabe por qué. Todo lo que construyas aquí está deliberadamente incompleto (token de mentira, sin persistencia, sin roles). Eso es a propósito: es la versión que cabe en 8 horas y sobre la que las fases siguientes van a apilar realidad.

Enganchas directo con lo que dejó la Fase 1: las cinco rutas de `AppRouter` hoy son públicas; tu trabajo natural es envolver las que corresponda con `PrivateRoute` dentro del mismo `<Switch>`, sin reescribir el router desde cero.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Existe un formulario de login funcional en `/login` (`LoginPage`) que valida credenciales contra json-server y muestra un error legible cuando fallan.
- [ ] Hay un `authSlice` (Redux Toolkit) que guarda `user`, `token`, `loading` y `error`, con un thunk `login` y una acción síncrona `logout`.
- [ ] `apiClient` tiene dos interceptors: uno de request que adjunta el header `Authorization` cuando hay token, y uno de response que lee y loguea el `X-Request-Id` que devuelve el mock.
- [ ] Las rutas de rifas están protegidas con `PrivateRoute`; sin sesión, redirige a `/login` recordando a dónde querías ir para volver ahí tras autenticarte.
- [ ] La `Navbar` (heredada de Fase 1) muestra el usuario logueado y un botón de "Cerrar sesión" que limpia el store y devuelve al login.

---

## 🚫 3. Qué queda fuera por ahora

- **Persistencia de sesión** (que el login sobreviva a un F5) → se paga en **Fase 3**. Por ahora, refrescar te desloguea. Es una 💸 deliberada, explicada abajo.
- **Roles y permisos** (que un usuario "vendedor" no vea la liquidación) → fuera del curso base; se menciona como ampliación 🔥.
- **Refresh token / expiración real** → fuera de alcance. Nuestro token no expira porque no es un token: es una string en un `db.json`.
- **Verificación server-side de la contraseña, hashing, JWT firmado** → no existe backend de auth real. json-server compara strings en claro. Otra 💸 nombrada explícitamente.
- **Middleware Express de caos** (latencia, 5xx intermitentes) → llega en **Fase 3**. Aquí json-server responde limpio y predecible.
- **Conectar `demoRaffles` / `demoParticipants` al backend** → la deuda 💸 de datos hardcodeados de Fase 1 sigue abierta y se paga en Fase 3. No la toques en esta fase.

---

## 🧠 4. Conceptos mínimos

### 4.1 Qué es "auth" en esta SPA (y qué NO vamos a hacer)

Eres senior, así que no te voy a explicar qué es un token ni por qué no se manda la contraseña en cada request. Lo que importa aquí es el *reparto de responsabilidades* dentro de la SPA, porque es lo que vas a tener que desenredar cuando algo falle:

- El **backend mock** (json-server) tiene la lista de usuarios y, para cada uno, un `token` ya escrito a mano. No firma nada, no valida nada: si le pides un usuario cuyo `email` y `password` coinciden, te lo devuelve con su token pegado. Es una mentira piadosa que se sostiene solo hasta que aparezca un backend de verdad.
- El **store** (`authSlice`) es la única fuente de verdad de "¿hay alguien logueado?". Ni los componentes ni el interceptor guardan sesión por su cuenta: todos preguntan al store.
- El **cliente HTTP** (`apiClient` + interceptors) es el punto por donde pasa *toda* petición. Ahí se inyecta el `Authorization` y ahí se lee el `requestId`. Un solo lugar, no repartido por veinte componentes.
- Los **componentes** (`LoginPage`, `PrivateRoute`, `Navbar`) solo leen del store y despachan acciones. No hablan con axios directamente.

> 📝 **Nota de época.** En apps de 2020-2022 era normalísimo que "auth" fuera exactamente esto: un endpoint que devuelve un token opaco, `localStorage` para guardarlo (spoiler: eso llega en Fase 3) y un interceptor que lo reinyecta. No había cookies `httpOnly` ni PKCE ni la mitad de las buenas prácticas de hoy. Vas a mantener código así; conviene reconocerlo sin juzgarlo.

### 4.2 Mini-repaso: `createSlice` de Redux Toolkit 1.8

Este es el primer Redux del curso, así que vale un repaso corto. Si vienes de Redux clásico (action types en constantes, un `switch` gigante en el reducer, action creators a mano), `createSlice` te va a parecer sospechosamente corto. Lo es. Genera el reducer, los action creators y los types por ti, y usa Immer por debajo para que puedas "mutar" el estado sin romper la inmutabilidad.

| Redux clásico | Redux Toolkit 1.8 |
|---|---|
| `const LOGIN = 'auth/login'` | Lo genera `createSlice` a partir del nombre del reducer |
| `function reducer(state, action) { switch… }` | `reducers: { logout(state) {…} }` |
| `return { ...state, user: action.payload }` | `state.user = action.payload` (Immer lo hace inmutable) |
| Thunk a mano con `redux-thunk` | `createAsyncThunk` genera `pending/fulfilled/rejected` |

> 📚 Si el modelo mental de `createSlice` te queda flojo, 15 minutos en https://redux-toolkit.js.org/api/createSlice y https://redux-toolkit.js.org/api/createAsyncThunk bastan. Ojo: fija la vista en la línea 1.x; la doc actual cubre 2.x y algunos imports cambiaron.

### 4.3 Interceptors de axios: el punto único por donde pasa todo

Un interceptor es una función que axios ejecuta *antes* de mandar cada request (request interceptor) o *después* de recibir cada response (response interceptor), sin que el código que llamó a `apiClient.get(...)` se entere. Es el lugar correcto para tres cosas transversales: adjuntar el `Authorization`, loguear/correlacionar con un `requestId`, y —más adelante— manejar 401 globales.

La regla de oro: **el interceptor lee del store, no al revés**. No guardamos el token dentro del módulo de axios; se lo pedimos al store en el momento de cada request. Así, cuando haces `logout`, la próxima request ya sale sin `Authorization` sin que tengas que "avisarle" a axios.

`apiClient` es tuyo para estrenar en esta fase, y lo dejamos genérico a propósito: la Fase 3 lo va a reusar apuntando al mismo json-server, ya con el caos encima.

### 4.4 `PrivateRoute` en React Router 5

React Router 5 **no** tiene el patrón de v6 (`<Navigate>`, rutas anidadas con `<Outlet>`). Aquí se protege una ruta envolviéndola en un componente que decide, en tiempo de render, si muestra el contenido o hace `<Redirect>`. Se usa el prop `render` (o `children`) de `<Route>`, se lee la sesión del store, y si no hay, se redirige a `/login` pasando en el `state` de la location a dónde querías ir. Es el patrón canónico de la v5 y el que vas a ver en el código real.

> ⚠️ No copies un `PrivateRoute` de un blog sin mirar la versión: la mitad de los ejemplos en internet son de React Router 6 y usan `<Navigate>` / `useNavigate`, que **no existen** en la 5.3.4 que fijó la Fase 1. Si ves `element={...}` en un `<Route>`, es v6: no aplica aquí.

---

## 💻 5. Implementación y código comentado

Vamos capa por capa, de abajo hacia arriba: primero el backend mock, después el cliente HTTP, el store, y por último los componentes que el usuario ve. Todo el código nuevo respeta la convención vigente desde 2026-07-15: **identificadores en inglés, comentarios y textos de interfaz en español**.

### 5.1 Los usuarios en `db.json` (el "backend" mock) 💸

json-server sirve como backend de lectura. Le damos un recurso `users` con el token ya escrito a mano:

```json
{
  "users": [
    {
      "id": 1,
      "email": "vendedor@rifas.test",
      "password": "rifas123",
      "name": "Ana Vendedora",
      "token": "tok_ana_9f2c"
    },
    {
      "id": 2,
      "email": "organizador@rifas.test",
      "password": "rifas123",
      "name": "Beto Organizador",
      "token": "tok_beto_4a1d"
    }
  ]
}
```

> 💸 **Deuda técnica intencional (doble).** Dos cosas están mal a propósito aquí:
> 1. **La contraseña viaja y se guarda en claro.** No hay hashing, no hay verificación server-side. json-server solo compara strings. En producción esto sería un incidente de seguridad de primer orden.
> 2. **El token es una constante hardcodeada**, no algo firmado ni con expiración. Es una etiqueta, no una credencial.
>
> Se dejan así porque el foco de la fase es el *flujo* de auth en el frontend (slice, interceptor, guarda de rutas), no construir un servidor de identidad. Lo correcto —un endpoint `POST /login` que valide y firme un JWT— vive del lado del backend real y queda fuera del alcance del tutorial. Lo que **sí** vamos a pagar (Fase 3) es la persistencia.

Levantas el mock como en la Fase 0/1, pero ahora con un middleware que agrega el `X-Request-Id` (ver 5.7):

```bash
npx json-server --watch db.json --port 3001 --middlewares ./mock/requestIdMiddleware.js
```

> 📝 **Nota de época.** Usar json-server como "backend de auth" es una muleta de desarrollo clásica. Funciona porque el filtrado por query (`?email=...&password=...`) te deja simular un login sin escribir un endpoint. Es frágil (ver errores comunes) pero enormemente común en repos de esta época.

### 5.2 `apiClient` y sus dos interceptors

Un único cliente compartido. Todo el que quiera hablar con el mock importa *este* axios, no el global. Este archivo es nuevo en el curso y lo estrenas tú.

```javascript
// src/api/apiClient.js
import axios from 'axios';

// Cliente único de la app. Un solo baseURL: si mañana el mock cambia de
// puerto o aparece un backend real, se toca aquí y ninguna vista se entera.
const apiClient = axios.create({
  baseURL: 'http://localhost:3001',
});

/**
 * Inyecta el token del store en cada request, si lo hay, y loguea el
 * requestId que devuelve el mock en cada response.
 * Clave: el token NO vive en este módulo. Se lee del store en el momento
 * de cada petición (vía getToken), así el logout surte efecto sin avisarle
 * a axios y se evita el import circular store → apiClient → store.
 * @param {() => (string|null)} getToken - devuelve el token actual (o null)
 */
export function setupInterceptors(getToken) {
  // --- REQUEST: adjuntar Authorization ---
  apiClient.interceptors.request.use((config) => {
    const token = getToken();
    if (token) {
      // Bearer aunque el token sea de mentira: así el día que sea real,
      // el formato ya es el correcto y no hay que tocar nada aquí.
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  });

  // --- RESPONSE: leer y loguear el requestId que genera el mock ---
  apiClient.interceptors.response.use(
    (response) => {
      // El backend (mock) es quien genera el id; el cliente SOLO lo lee.
      // Sirve para correlacionar lo que ves en la UI con la línea del log
      // del servidor. Pieza forense de esta fase.
      const requestId = response.headers['x-request-id'];
      if (requestId) {
        // console.debug para no ensuciar; en la pieza forense lo miramos.
        const { method, url } = response.config;
        console.debug(`[req-id ${requestId}] ${method?.toUpperCase()} ${url} → ${response.status}`);
      }
      return response;
    },
    (error) => {
      // También logueamos el id en el error: es el momento donde MÁS lo vas
      // a necesitar (correlacionar un 401/500 con el log del server).
      const requestId = error.response?.headers['x-request-id'];
      if (requestId) {
        console.debug(`[req-id ${requestId}] ERROR ${error.response?.status} en ${error.config?.url}`);
      }
      return Promise.reject(error);
    }
  );
}

export default apiClient;
```

> **Detalles con intención.**
> - Devolvemos `Bearer ${token}` aunque el token sea falso: el formato correcto desde el día uno significa que migrar a un token real no toca este archivo.
> - El interceptor **lee** el `x-request-id`, no lo genera. json-server no lo emite por defecto, así que en 5.7 le agregamos un middleware de una línea para que lo haga. En Fase 3, ese id se vuelve central cuando el caos empieza.
> - Pasamos `getToken` como función en vez de importar el store aquí: evita el import circular clásico (`store` → `apiClient` → `store`) y mantiene a axios ignorante de Redux.

### 5.3 `authService`: el login contra json-server

El servicio traduce "quiero loguearme" a la request concreta que json-server entiende. Los componentes y el slice hablan con el servicio, no con la forma cruda de la URL.

```javascript
// src/api/authService.js
import apiClient from './apiClient';

/**
 * "Login" mock: json-server no tiene POST /login, así que filtramos users
 * por email y password vía query. 💸 Esto manda la password en la URL como
 * query param: horrible en la vida real, aceptable en un mock local.
 * @param {{ email: string, password: string }} credentials
 * @returns {Promise<{ id: number, email: string, name: string, token: string }>}
 */
export async function login({ email, password }) {
  const { data } = await apiClient.get('/users', {
    params: { email, password },
  });

  // json-server devuelve un ARRAY (filtro), no un objeto. Cero coincidencias
  // = credenciales inválidas. Traducimos eso a un error con mensaje legible.
  if (!Array.isArray(data) || data.length === 0) {
    // el valor del mensaje va en español: lo lee el usuario final
    throw new Error('Email o contraseña incorrectos');
  }

  const user = data[0];

  // No dejamos que la password vuelva al store: se descarta aquí.
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    token: user.token,
  };
}

export default { login };
```

> **El patrón a memorizar.** El servicio es la frontera que traduce la forma fea del backend (un array filtrado, la password en la query) a la forma limpia que el resto de la app quiere (un user o un error legible). Cuando mañana haya un `POST /login` real, cambia *este* archivo y nada más.

### 5.4 `authSlice`: estado, thunk de login, logout

El store es la fuente de verdad de la sesión. Primer slice del curso; los siguientes (rifas, ventas) van a seguir esta misma forma.

```javascript
// src/features/auth/authSlice.js
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import * as authService from '../../api/authService';

const initialState = {
  user: null,     // { id, email, name } — sin token ni password
  token: null,    // string opaca (de mentira, por ahora)
  loading: false, // true mientras el login está en vuelo
  error: null,    // mensaje legible para la UI (en español), o null
};

/**
 * Thunk de login. createAsyncThunk genera auth/login/pending|fulfilled|rejected.
 * Devolvemos el user+token; si el service tira, rejectWithValue lleva el
 * mensaje legible al estado para que LoginForm lo muestre.
 */
export const login = createAsyncThunk(
  'auth/login',
  async (credentials, { rejectWithValue }) => {
    try {
      return await authService.login(credentials);
    } catch (err) {
      return rejectWithValue(err.message);
    }
  }
);

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    // logout es síncrono: no hay que avisarle a ningún backend (no hay sesión
    // server-side). Simplemente volvemos al estado inicial.
    logout() {
      return initialState;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(login.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(login.fulfilled, (state, action) => {
        state.loading = false;
        state.user = {
          id: action.payload.id,
          email: action.payload.email,
          name: action.payload.name,
        };
        state.token = action.payload.token;
      })
      .addCase(login.rejected, (state, action) => {
        state.loading = false;
        // rejectWithValue → action.payload; fallback por si algo raro pasa
        state.error = action.payload || 'Error al iniciar sesión';
      });
  },
});

export const { logout } = authSlice.actions;

// --- Selectores: los componentes leen SIEMPRE por aquí, nunca state.auth.x ---
export const selectCurrentUser = (state) => state.auth.user;
export const selectIsAuthenticated = (state) => Boolean(state.auth.token);
export const selectAuthLoading = (state) => state.auth.loading;
export const selectAuthError = (state) => state.auth.error;

export default authSlice.reducer;
```

> **Detalles con intención.**
> - `selectIsAuthenticated` mira el **token**, no `user`: es el token lo que habilita las requests. Si algún día tienes user sin token (estado imposible hoy, pero defensivo), la guarda sigue siendo correcta.
> - `logout()` devuelve `initialState` en vez de mutar campo por campo: menos superficie para olvidarse de limpiar algo.
> - El slice **nunca** guarda la password ni la deja entrar. La frontera fue el `authService`.

Y el registro en el store (nuevo archivo, primer store del curso):

```javascript
// src/app/store.js
import { configureStore } from '@reduxjs/toolkit';
import authReducer from '../features/auth/authSlice';
import { setupInterceptors } from '../api/apiClient';

export const store = configureStore({
  reducer: {
    auth: authReducer,
    // los slices de rifas/ventas se agregan en fases siguientes
  },
});

// Cerramos el lazo del interceptor: le damos su getToken leyendo del store
// ya construido. El interceptor pregunta al store por el token en cada request.
setupInterceptors(() => store.getState().auth.token);
```

Y el `<Provider>` envolviendo la app, junto al `AppRouter` que ya montó la Fase 1:

```jsx
// src/index.js (fragmento — se añade Provider alrededor de lo de Fase 1)
import { Provider } from 'react-redux';
import { store } from './app/store';
import AppRouter from './AppRouter';

ReactDOM.render(
  <Provider store={store}>
    <AppRouter />
  </Provider>,
  document.getElementById('root')
);
```

### 5.5 `LoginPage` / `LoginForm`: funcional con hooks

Módulo nuevo, así que funcional con hooks (nada de clases aquí; las clases aparecen en los módulos heredados como `RaffleListPage`). Formulario controlado, sin librería de formularios. Sigo la convención de páginas de Fase 1 (`*Page`) y meto el formulario dentro.

```jsx
// src/pages/LoginPage.jsx
import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useHistory, useLocation } from 'react-router-dom';
import {
  login,
  selectAuthLoading,
  selectAuthError,
} from '../features/auth/authSlice';

function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const dispatch = useDispatch();
  const loading = useSelector(selectAuthLoading);
  const error = useSelector(selectAuthError);
  const history = useHistory();
  const location = useLocation();

  // ¿A dónde volver tras loguear? Lo dejó PrivateRoute en location.state.
  // Si entraste directo a /login, vas al listado de rifas.
  const target = location.state?.from?.pathname || '/raffles';

  async function handleSubmit(event) {
    event.preventDefault();
    // unwrap vía match: si el thunk fue fulfilled, navegamos; si no, el
    // error ya quedó en el store y se pinta abajo.
    const result = await dispatch(login({ email, password }));
    if (login.fulfilled.match(result)) {
      history.replace(target); // replace: que el "atrás" del navegador no vuelva al login
    }
  }

  return (
    <div className="row justify-content-center mt-5">
      <div className="col-12 col-md-5">
        <h1 className="h4 mb-3">Iniciar sesión</h1>

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="email">Usuario</label>
            <input
              id="email"
              type="email"
              className="form-control"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              autoComplete="username"
              required
            />
          </div>

          <div className="form-group">
            <label htmlFor="password">Contraseña</label>
            <input
              id="password"
              type="password"
              className="form-control"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              autoComplete="current-password"
              required
            />
          </div>

          {/* Error legible del store, no el stack de axios */}
          {error && (
            <div className="alert alert-danger py-2" role="alert" data-testid="login-error">
              {error}
            </div>
          )}

          <button
            type="submit"
            className="btn btn-primary btn-block"
            disabled={loading}
          >
            {loading ? 'Ingresando…' : 'Iniciar sesión'}
          </button>
        </form>
      </div>
    </div>
  );
}

export default LoginPage;
```

> **El patrón a memorizar.** `loading = true` (lo pone el `pending` del thunk) → llamar al service → `fulfilled` guarda user+token / `rejected` guarda error legible → la UI lee `loading` y `error` del store. El componente casi no tiene lógica: dispara y observa.

### 5.6 `PrivateRoute`: proteger las rutas de rifas

```jsx
// src/components/PrivateRoute.jsx
import React from 'react';
import { Route, Redirect } from 'react-router-dom';
import { useSelector } from 'react-redux';
import { selectIsAuthenticated } from '../features/auth/authSlice';

/**
 * Ruta protegida al estilo React Router 5: envuelve una <Route> y decide,
 * en render, si muestra el componente o redirige a /login.
 * Pasa la location actual en state.from para poder volver tras loguear.
 */
function PrivateRoute({ component: Component, children, ...rest }) {
  const isAuthenticated = useSelector(selectIsAuthenticated);

  return (
    <Route
      {...rest}
      render={(props) =>
        isAuthenticated ? (
          // Soporta ambas formas: <PrivateRoute component={X} /> y
          // <PrivateRoute><X /></PrivateRoute>
          Component ? <Component {...props} /> : children
        ) : (
          <Redirect
            to={{
              pathname: '/login',
              state: { from: props.location }, // ← a dónde querías ir
            }}
          />
        )
      }
    />
  );
}

export default PrivateRoute;
```

Y el uso dentro del `AppRouter` de Fase 1. **No lo reescribimos desde cero**: insertamos la ruta pública `/login` y cambiamos `<Route>` por `<PrivateRoute>` en las rutas que deben quedar protegidas.

```jsx
// src/AppRouter.jsx (fragmento — se parte del router de Fase 1)
import { Switch, Route, Redirect } from 'react-router-dom';
import PrivateRoute from './components/PrivateRoute';
import LoginPage from './pages/LoginPage';
import RaffleListPage from './pages/RaffleListPage';
import RaffleDetailPage from './pages/RaffleDetailPage';
import ParticipantsPage from './pages/ParticipantsPage';
import DashboardPage from './pages/DashboardPage';
import NotFoundPage from './pages/NotFoundPage';

function AppRouter() {
  return (
    <AppLayout>
      <Switch>
        {/* pública: sin esto, loop de redirección infinito */}
        <Route path="/login" component={LoginPage} />

        {/* protegidas: eran <Route> en Fase 1, ahora <PrivateRoute> */}
        <PrivateRoute exact path="/raffles" component={RaffleListPage} />
        <PrivateRoute path="/raffles/:id" component={RaffleDetailPage} />
        <PrivateRoute path="/participants" component={ParticipantsPage} />
        <PrivateRoute path="/dashboard" component={DashboardPage} />

        <Redirect exact from="/" to="/raffles" />
        <Route component={NotFoundPage} />
      </Switch>
    </AppLayout>
  );
}
```

> ⚠️ El orden importa: `/login` debe ser **pública**. Si la envuelves sin querer en `PrivateRoute`, creas un loop de redirección infinito (sin sesión → redirige a /login → que también exige sesión → redirige a /login → …). Es un clásico; está en los errores comunes.

### 5.7 Cablear todo: `requestId` en el mock y logout en la `Navbar`

**Que el mock devuelva `X-Request-Id`.** json-server no lo hace solo; le agregamos un middleware trivial. Esto es un adelanto mínimo de lo que en Fase 3 se vuelve el "servidor de caos".

```javascript
// mock/requestIdMiddleware.js
const { randomBytes } = require('crypto');

// Genera un id por request y lo mete en el header de respuesta.
// EL CLIENTE NO LO GENERA: lo lee. Este es el emisor.
module.exports = (req, res, next) => {
  const requestId = randomBytes(4).toString('hex'); // p.ej. "9f2c4a1d"
  res.setHeader('X-Request-Id', requestId);
  next();
};
```

**`Navbar` con usuario y logout.** Extendemos la `Navbar` que montó la Fase 1 (no la reescribimos): le agregamos el bloque de sesión a la derecha.

```jsx
// src/components/Navbar.jsx (fragmento relevante añadido a la Navbar de Fase 1)
import React from 'react';
import { NavLink } from 'react-router-dom';
import { useSelector, useDispatch } from 'react-redux';
import { useHistory } from 'react-router-dom';
import { selectCurrentUser, logout } from '../features/auth/authSlice';

function Navbar() {
  const user = useSelector(selectCurrentUser);
  const dispatch = useDispatch();
  const history = useHistory();

  function handleLogout() {
    dispatch(logout());        // limpia el store → la próxima request sale sin token
    history.push('/login');
  }

  return (
    <nav className="navbar navbar-expand navbar-dark bg-dark">
      <span className="navbar-brand">Rifas y chances</span>

      {/* Links heredados de Fase 1 */}
      <div className="navbar-nav">
        <NavLink className="nav-link" to="/raffles">Rifas</NavLink>
        <NavLink className="nav-link" to="/participants">Participantes</NavLink>
        <NavLink className="nav-link" to="/dashboard">Dashboard</NavLink>
      </div>

      {/* Bloque de sesión nuevo en Fase 2 */}
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

> **Prueba de fuego.** Con json-server arriba: entra a `/raffles` sin login → deberías caer en `/login`. Loguéate con `vendedor@rifas.test` / `rifas123` → deberías volver a `/raffles` y ver "Ana Vendedora" en la navbar. Abre la consola: cada request loguea su `[req-id ...]`. Ahora dale **F5**: te desloguea y te manda al login. Eso es la 💸 de persistencia, y es esperado.

### 💸 La deuda de persistencia (y su fecha de pago)

El estado de Redux vive en memoria. Al refrescar, el store se reconstruye desde `initialState` y la sesión se evapora. En una app real esto es inaceptable: nadie quiere reloguearse cada vez que toca F5.

Lo dejamos así **a propósito** en esta fase para mantener el foco en el flujo (slice → interceptor → guarda) sin mezclarlo con la mecánica de storage. La solución —rehidratar `token` y `user` desde `localStorage` al arrancar, y sincronizarlos en cada cambio— entra de lleno en **Fase 3**, donde además vas a ver por qué guardar un token en `localStorage` tiene sus propias trampas (se comparte entre pestañas, es legible por cualquier script, no se limpia solo).

> 💸 **Marca de deuda.** `authSlice` sin persistencia. Fase de origen: 2. Fase de pago: 3. No la parchees antes con un `localStorage.setItem` suelto en el componente: la vamos a hacer bien, en un solo lugar, en la próxima fase.

---

## ⚠️ 6. Errores comunes y pieza forense

### 6.1 Errores comunes

**1. El interceptor no adjunta el token (todo sale sin `Authorization`).**
Síntoma: te logueas bien pero las requests protegidas van sin header. Causa casi siempre: capturaste el token en una variable al montar el módulo (`const token = store.getState().auth.token`) en vez de leerlo *dentro* del interceptor. Esa variable quedó congelada en `null`. Fix mínimo: lee el token dentro de la función del interceptor (como en 5.2, vía `getToken()`), no afuera.

**2. Loop de redirección infinito en `/login`.**
Síntoma: la pestaña se cuelga redirigiendo, o ves parpadeo. Causa: `/login` quedó protegida por `PrivateRoute`, así que sin sesión pide login… que exige sesión. Fix mínimo: `/login` va como `<Route>` pública, nunca `PrivateRoute`.

**3. `login` "no falla" con credenciales malas.**
Síntoma: metes cualquier password y no ves error, o el estado queda raro. Causa: json-server devuelve `200` con un **array vacío** cuando el filtro no matchea; si no chequeas `data.length === 0`, tratas el array vacío como éxito. Fix mínimo: la validación de `authService` (5.3) que traduce array vacío → `throw`. Corrección vs refactor: el `throw` es el parche mínimo; el refactor sería mover la validación a un `POST /login` real en el backend, fuera de alcance.

**4. `useSelector` que devuelve un objeto nuevo cada render y re-renderiza de más.**
Síntoma: el componente parpadea o hay renders sospechosos en el Profiler. Causa: seleccionaste un objeto derivado inline (`useSelector(state => ({ user: state.auth.user, token: state.auth.token }))`) que crea una referencia nueva cada vez. Fix mínimo: usa selectores estables (los exportados del slice) o selecciona campos primitivos por separado. No es un bug de correctitud, es de performance; conviene reconocerlo temprano —y es la excusa perfecta para estrenar Redux DevTools.

### 6.2 Pieza forense: primer uso de Redux DevTools + correlación por `requestId`

Esta fase estrena dos herramientas del track forense: **Redux DevTools** (porque es el primer store del curso) y la **correlación por `requestId`** en Network. El objetivo no es arreglar nada, es aprender a **ver**.

**Parte A — Redux DevTools: "quedé logueado pero el store dice que no".** Instala la extensión, abre la pestaña Redux y loguéate. Vas a ver la secuencia de acciones despachadas: `auth/login/pending` → `auth/login/fulfilled`. Haz clic en cada una y mira el panel *State* y *Diff*:

1. En `pending`, `loading` pasa a `true` y `error` a `null`. Nada más.
2. En `fulfilled`, `loading` vuelve a `false`, y aparecen `user` y `token`. Confirma que `user` **no** trae la `password`: si la ves ahí, tu `authService` no está filtrando (bug real, y de seguridad).
3. Haz un login fallido y observa `auth/login/rejected`: `error` se llena con el string en español, `token` sigue en `null`. Ese `token: null` es exactamente lo que `selectIsAuthenticated` lee para mandarte al login. Si alguna vez ves "estoy logueado pero me redirige", este es el primer lugar donde mirar: ¿qué dice `state.auth.token` de verdad?

**Parte B — `requestId`: correlacionar UI con servidor.** Con json-server levantado *con* el middleware de `X-Request-Id`, abre DevTools → Network y loguéate.

1. **Ubica el header en Network.** Clic en la request `GET /users?email=...` → pestaña Headers → Response Headers → ahí está `X-Request-Id`. Ese mismo id lo imprimió tu interceptor en la consola. Comprueba que **coinciden**: eso demuestra que la UI y el server están hablando del mismo evento.

2. **Rompe a propósito y observa.** Apaga json-server (Ctrl-C) y vuelve a intentar login. Ahora el interceptor de *error* entra en acción. ¿Aparece un `req-id` en el log de error? No, y eso es información: sin respuesta del servidor no hay header, así que el fallo fue *antes* de llegar al backend (conexión rechazada), no un rechazo del backend. Saber distinguir "no llegué al server" de "el server me dijo que no" es media investigación resuelta.

3. **Correlación simulada.** Con el server prendido de nuevo, haz login fallido (password mala). Anota el `req-id` de la consola. Ese es el dato que, en un sistema real, pegarías en el ticket: "request 9f2c4a1d devolvió credenciales inválidas a las 14:32". El de soporte busca ese id en el log del backend y encuentra la línea exacta. Sin el id, buscas a ciegas entre miles de líneas.

> 💡 **Truco.** Loguear el `requestId` en `console.debug` (no `console.log`) te deja filtrarlo por nivel en DevTools sin ahogarte en ruido. En Fase 3, cuando el caos meta latencia y 5xx aleatorios, este id va a ser tu mejor amigo para saber *cuál* de veinte requests concurrentes falló.

> Enlaza con **FORENSE-FASE-02** (Redux DevTools + correlación por requestId) y con los incidentes 🟢 de login/auth del cuaderno. Las fichas formales del cuaderno todavía no están escritas; el enlace queda marcado como pendiente de coordinación.

---

## 🧪 7. Ejercicios (30)

Todos anclados al dominio de rifas y a los identificadores en inglés vigentes. Varios son de diagnóstico: te entregan un bug y te piden reproducir y localizar, no solo construir.

**🟢 Fácil (1–8)**

1. Agrega un tercer usuario a `db.json` (un "cajero") con su `token` hardcodeado y loguéate con él.
2. Cambia el texto del botón de login para que muestre "Validando…" en vez de "Ingresando…" mientras `loading` es `true`.
3. Haz que el campo email tenga foco automático al montar `LoginPage` (`autoFocus`).
4. Muestra el email del usuario (además del `name`) en la `Navbar` cuando hay sesión.
5. Agrega un selector `selectAuthStatus` al slice que devuelva `'loading' | 'authenticated' | 'anonymous'` y úsalo en algún punto de la UI.
6. Deshabilita el botón de login también cuando `email` o `password` estén vacíos, sin depender solo de `required`.
7. Mueve el `baseURL` de `apiClient` a una constante `API_BASE_URL` importada desde un archivo `config.js`. Verifica que el login sigue funcionando.
8. Loguea en consola el `name` del usuario dentro del `fulfilled` del thunk (temporalmente) y confirma que aparece tras un login exitoso.

**🟡 Intermedio (9–17)**

9. Haz que tras logout, además de ir a `/login`, se muestre un mensaje "Sesión cerrada" en la pantalla de login (pista: pásalo por `location.state`).
10. Envuelve una ruta nueva `/settlements` (con un componente placeholder) en `PrivateRoute` y verifica que sin sesión redirige.
11. Escribe una variante de `selectIsAuthenticated` que mire `user` en vez de `token` y explica en un comentario por qué la versión con `token` es más correcta para esta app.
12. Haz que el interceptor de request loguee en `console.debug` la URL de cada petición y si llevó o no `Authorization`. Confirma que las requests post-login lo llevan y la de login no.
13. Agrega manejo de "email con espacios": aplica `trim` al email antes de mandarlo en el thunk. Reproduce primero el bug (login falla con `" vendedor@rifas.test"`).
14. Agrega una acción síncrona `clearError` al `authSlice` y despáchala al desmontar `LoginPage` con un `useEffect`. Justifica por qué conviene.
15. Convierte el mensaje de error del store en un componente reutilizable `AuthError` que reciba el texto por prop.
16. Documenta en 5 pasos cómo reproducir el "loop de redirección infinito" y luego cómo evitarlo. (Diagnóstico.)
17. Haz que `RaffleListPage` (que es una clase con `connect()`) lea `selectCurrentUser` vía `connect(mapStateToProps)` y muestre "Hola, {name}" arriba del listado. Esto estrena la convivencia `connect()` + `useSelector()` que pide la guía.

**🟠 Difícil (18–24)**

18. **Diagnóstico.** Te entregan un `apiClient` donde el token se lee *fuera* del interceptor (`const token = getToken()` en el nivel del módulo). Reproduce que las requests salen sin `Authorization` tras login, explica por qué, y aplica el fix mínimo.
19. Haz que si una request protegida devuelve `401`, el interceptor de response despache `logout` automáticamente y redirija a `/login`. (Pista: el interceptor necesita `dispatch`; pásalo igual que `getToken` en `setupInterceptors`.) Nota: en Fase 2 nada emite 401 todavía; simula el 401 a mano para probarlo. Este ejercicio es el germen del manejo global de 401 que se implementa de base en Fase 3.
20. **Diagnóstico.** Con el middleware de `requestId` apagado, una request falla y no ves `req-id` en el log. Explica cómo distinguir, solo con eso, si el fallo fue de red o de backend.
21. Haz que el thunk `login` distinga entre "credenciales inválidas" (array vacío) y "el mock está caído" (error de red), guardando mensajes distintos en `error`. Reproduce ambos casos.
22. Usa Redux DevTools para grabar una sesión de login exitoso, exporta el trace (feature de import/export de la extensión) y reprodúcelo con "time travel". Documenta qué acción revierte exactamente el `token` a `null`.
23. **Diagnóstico.** Un compañero reporta que tras loguear, al apretar "atrás" del navegador vuelve al login ya autenticado y todo se ve raro. Reproduce el bug y explica por qué `history.replace` (en vez de `push`) en el login lo evita.
24. Escribe un helper `isPublicRoute(pathname)` y úsalo para documentar (en comentario) qué rutas deben quedar fuera de `PrivateRoute` para no crear loops.

**🔴 Muy difícil (25–30)**

25. **Diagnóstico integrador.** Te dan un repo donde el login "funciona" pero, de forma intermitente, algunas requests protegidas salen sin token. Investiga con Redux DevTools + Network: ¿es orden de registro del interceptor, una copia congelada del token, o un `logout` que no limpió bien? Documenta reproducción, causa raíz y fix.
26. Implementa un mini-esquema de "sesión que sobrevive al F5" **solo en memoria de la pestaña** (sin `localStorage` todavía) y explica por qué no alcanza. Conéctalo con la 💸 que se paga en Fase 3.
27. **Corrección vs refactor.** Dado el `authService` con la password en la query, escribe (a) el parche mínimo que reduce el riesgo sin cambiar el backend y (b) describe el refactor correcto (endpoint `POST /login`), marcando cuál iría en un hotfix y cuál no.
28. Haz que dos pestañas del navegador con la misma app muestren estados de sesión independientes (loguear en una no loguea la otra) y explica por qué eso ocurre hoy y cambiará al introducir `localStorage` en Fase 3.
29. **Diagnóstico.** Reproduce el re-render excesivo del error común #4 (selector que devuelve objeto nuevo), demuéstralo con el React Profiler o con un `console.count` en el render, y corrígelo con selectores estables.
30. Escribe un post-mortem completo (8 puntos: síntoma, reproducción, evidencia, causa raíz, corrección, prueba de regresión, prevención, análisis sin culpa) para un incidente ficticio: "usuarios reportan que a veces quedan deslogueados sin apretar Cerrar sesión". Diseña la causa raíz plausible con lo construido en esta fase.

**🔥 Opcionales**

- 🔥 Reescribe `LoginPage` como **class component** (`this.state`, `componentDidMount`, `connect()`), para practicar leer y escribir el estilo legacy que vas a encontrar en módulos como `RaffleListPage`. Compara ambas versiones.
- 🔥 Agrega **roles** mínimos (`seller` vs `organizer`) leídos del `user` y un `RoleRoute` que proteja `/settlements` solo para `organizer`. (Fuera del alcance base; adelanta lógica de fases posteriores.)
- 🔥 Migra el login de json-server a un endpoint `POST /login` servido por un pequeño Express propio que devuelva un token distinto en cada login. Discute qué cambia (y qué no) en el frontend.

---

## 📚 8. Referencias

**Documentación oficial**

- Redux Toolkit — `createSlice`: https://redux-toolkit.js.org/api/createSlice (fija la vista en la línea 1.x; la doc actual cubre 2.x).
- Redux Toolkit — `createAsyncThunk`: https://redux-toolkit.js.org/api/createAsyncThunk
- Redux Toolkit — `configureStore`: https://redux-toolkit.js.org/api/configureStore
- React Redux — hooks `useSelector` / `useDispatch`: https://react-redux.js.org/api/hooks (compatible con React-Redux 7.2).
- React Router 5 — `<Redirect>` y ejemplo oficial de auth: https://v5.reactrouter.com/web/api/Redirect y https://v5.reactrouter.com/web/example/auth-workflow (el ejemplo de la v5 es casi textual a nuestro `PrivateRoute`).
- React Router 5 — hooks (`useHistory`, `useLocation`): https://v5.reactrouter.com/web/api/Hooks
- axios — interceptors: https://axios-http.com/docs/interceptors (nuestra versión es 0.21.4; la API de interceptors no cambió, pero verifica firmas).
- json-server — filtros por query y middlewares: https://github.com/typicode/json-server (fija la vista en la v0.16.x/0.17.x; el README de `master` documenta versiones más nuevas).

**Video / apoyo**

- Busca un crash course de Redux Toolkit centrado en `createSlice` + `createAsyncThunk`; abundan en YouTube. Verifica que sea de RTK 1.x (no 2.x) y que use la sintaxis de `extraReducers` con builder callback, que es la de esta fase.

> ⚠️ Las URLs, títulos y contenidos de terceros pueden estar desactualizados o haber cambiado de ruta; verifica siempre que la doc que abras corresponde a la versión fijada del stack. En particular, gran parte de los tutoriales de "PrivateRoute React" en blogs son de **React Router 6** y no aplican a la 5.3.4 que fijó la Fase 1.

**Orden de lectura sugerido:** ejemplo oficial de auth-workflow de React Router 5 → `createSlice` / `createAsyncThunk` de RTK → `configureStore` → interceptors de axios → vuelve al código de la sección 5 y relee `apiClient.js` con eso fresco.

---

## 🚀 9. Cierre y conexión con la Fase 3

Ya tienes la cerradura mínima y el primer Redux del curso montado: un login que valida contra el mock, un `authSlice` como fuente única de verdad de la sesión, un `apiClient` con interceptors que inyecta el token y lee el `requestId`, y un `PrivateRoute` que manda a los intrusos al login envolviendo las rutas que ya existían desde Fase 1. La app dejó de tener las puertas abiertas.

Pero dejaste dos cabos sueltos a propósito: la sesión se pierde al refrescar (💸 persistencia) y json-server responde siempre limpio, sin la aspereza de un backend real. La **Fase 3 — Mock API y Express caos** ataca los dos. Ahí vas a rehidratar la sesión desde storage (pagando la deuda que marcamos hoy) y, sobre todo, vas a montar el middleware Express que inyecta latencia, errores 5xx intermitentes y timeouts sobre este mismo json-server. Es entonces cuando el `requestId` que aprendiste a leer deja de ser una curiosidad y se vuelve la herramienta que te dice *cuál* de las peticiones se cayó cuando todo empieza a fallar de a ratos. El `apiClient` que estrenaste hoy es, justamente, el lugar donde ese caos se va a manejar mañana.

> **La señal de que quedó bien:** si mañana alguien reemplaza json-server por un backend real con JWT de verdad, el único archivo que debería cambiar de forma significativa es `authService.js` (la forma de la request y de la respuesta). Ni `LoginPage`, ni `PrivateRoute`, ni el `authSlice`, ni el interceptor deberían enterarse del cambio. Y si un compañero mete una password equivocada, ve "Email o contraseña incorrectos" —no un stack trace de axios—, y tú, mirando Redux DevTools y la consola, puedes cantarle el `requestId` de esa petición fallida sin abrir el código.
