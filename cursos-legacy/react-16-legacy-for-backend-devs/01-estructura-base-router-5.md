# 🏗️ Fase 01 — Estructura base + Router 5

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · Fase 1 de 11 · **8 horas**
> Depende de: Fase 0 — Setup + Hola mundo CRA · Habilita: Fase 2 — Autenticación mínima

---

## 🎯 1. Propósito

Itzel arma las ruedas de cada evento y hoy, para ver la de la próxima Semana del Canal, le escribe a alguien que le mande una captura. Lo que pide en la primera llamada es poco y concreto: *"quiero abrir la Esclusa, ver las ruedas y entrar a cada una sin pedírselo a nadie"*.

Al terminar la Fase 0 tenías una app que compila, levanta en `localhost:3000` y muestra **una** `WheelCard` con una rueda hardcodeada. Bonito, pero es una postal: no va a ningún lado. Una SPA de verdad tiene secciones, una URL que significa algo, y una barra de navegación que no se recarga cada vez que la tocas.

En esta fase le damos **esqueleto navegable** a la Esclusa. Vas a montar React Router 5, un `AppLayout` con navbar de Bootstrap que persiste en todas las pantallas, y las primeras páginas del dominio: el listado de ruedas (reusando tu `WheelCard`), el detalle de una rueda, jugadores, y dos placeholders (bitácora y dashboard). Todo con datos hardcodeados todavía — ni store, ni backend, ni login. Solo navegación y estructura.

¿Por qué importa esto para mantenimiento? Porque el 90% de los bugs de navegación que vas a heredar viven acá: rutas que matchean de más, links que recargan la página entera, un `:id` que llega como string cuando alguien esperaba número, un componente que "no se actualiza" al cambiar de ruta. Entender el router es entender por dónde entra el operador a cada pantalla — y por dónde se rompe.

---

## ✅ 2. Qué queda listo al terminar

- [ ] La app navega entre **cinco rutas** y un 404 **sin recargar la página**: `/wheels`, `/wheels/:id`, `/players`, `/spin-log` y `/dashboard`, más un 404 para todo lo demás.
- [ ] Un `AppLayout` con navbar de Bootstrap persiste en todas las rutas, y el link de la sección activa se resalta solo.
- [ ] `WheelListPage` —un **class component con `withRouter`**— lista las ruedas hardcodeadas (renderizando tu `WheelCard` de Fase 0) y navega al detalle al hacer click en una.
- [ ] `WheelDetailPage` —un **funcional con `useParams`**— lee el `:id` de la URL, muestra la rueda correcta, y vuelve al listado con un botón que usa `useHistory`.
- [ ] Una URL inexistente como `/cualquier-cosa` cae en `NotFoundPage` sin romper nada, y te dice qué ruta intentaste.

---

## 🚫 3. Qué queda fuera por ahora

- **Redux y el store** → Fase 2 en adelante. Acá los datos son un array hardcodeado en un archivo `mock/`.
- **Autenticación y `PrivateRoute`** → Fase 2. En esta fase todas las rutas son públicas; cualquiera entra a cualquier lado.
- **Datos reales desde una API** → Fase 3 monta el backend, Fase 4 lo consume desde el store. Todavía no hay `axios` ni `fetch`.
- **Envíos de premios, giros, resultados** → Fases 5-7. El detalle de rueda muestra información, no permite operar.
- **La bitácora y el dashboard de verdad** → la bitácora llega con el track BE (be05); el dashboard, en la Fase 9. Acá son placeholders.
- **React Router 6** → nunca en el código principal. Trabajamos en v5 a propósito (ver nota de época más abajo).

> 📝 **Nota de época.** Si vienes de proyectos nuevos, tu instinto va a ser `npm install react-router-dom` y te va a instalar la v6 o v7, con `<Routes>`, `element={}` y `useNavigate`. **No es lo que corre en este sistema.** Acá es v5: `<Switch>`, `component={}`/`render={}` y `useHistory`. Son mundos parecidos pero incompatibles. Fija la versión exacta `5.3.4` y no te confundas de documentación.

---

## 🧠 4. Conceptos mínimos

Eres senior, así que no te voy a explicar qué es una URL. Lo que sí vale la pena encuadrar es **qué problema resuelve un router en una SPA**, porque de ahí sale todo lo demás.

En una app tradicional, cada URL es un documento que el servidor te devuelve entero: pides `/wheels`, el servidor arma el HTML de ruedas, lo manda, el navegador lo pinta desde cero. En una SPA hay **un solo documento** (`index.html`) y **un solo árbol de React** que ya está cargado en memoria. Cambiar de "página" no significa pedirle nada al servidor: significa **mostrar un subárbol de componentes distinto** y actualizar la barra de direcciones para que la URL siga siendo la fuente de verdad de "qué estoy viendo". Eso es todo lo que hace un router: mira la URL, decide qué componente renderizar, y cambia la URL sin recargar cuando navegas.

React Router 5 lo hace con cuatro piezas que vas a usar todo el tiempo:

- **`BrowserRouter`**: el contenedor. Va una sola vez, arriba de todo. Usa la History API del navegador para cambiar la URL sin recargar. Todo lo que navegue tiene que vivir adentro de él.
- **`Route`**: "si la URL matchea este `path`, renderiza este componente". El detalle traicionero es que en v5 el match es **por prefijo**: `path="/wheels"` matchea `/wheels`, pero también `/wheels/1` y `/wheels/lo-que-sea`. Por eso existen `exact` y `Switch`.
- **`Switch`**: renderiza **solo la primera** `Route` que matchea, como un `switch/case`. Sin él, si dos rutas matchean la misma URL, se pintan las dos. Es la causa número uno de "se me renderizan dos pantallas encimadas".
- **`Link` / `NavLink`**: reemplazan al `<a href>`. Un `<a>` normal recarga la página entera y mata la SPA; `Link` cambia la URL vía JavaScript y deja el árbol vivo. `NavLink` es un `Link` que además sabe si su ruta está activa, para resaltarse.

### Los hooks de router, y por qué las clases se los pierden

React Router 5.1+ trae hooks: `useParams` (los `:parametros` de la URL), `useHistory` (para navegar por código: `history.push('/wheels')`), y `useLocation` (la URL actual, con su `pathname`, `search`, etc.). Son cómodos y limpios.

Pero **los hooks solo funcionan en componentes funcionales**. Un class component no puede llamar `useParams()`. Para esos casos —y vas a tener muchos, porque el código real está lleno de clases pre-hooks— React Router ofrece `withRouter`, un HOC (higher-order component) que **inyecta `history`, `location` y `match` como props**. Es el equivalente clásico: donde el funcional escribe `const { id } = useParams()`, la clase lee `this.props.match.params.id`.

En esta fase vas a ver los dos lados a propósito: `WheelListPage` es una **clase con `withRouter`** (legacy, como lo vas a encontrar en producción) y `WheelDetailPage` es un **funcional con `useParams`** (el estilo nuevo). No es un accidente ni una inconsistencia: es exactamente la mezcla que heredas. Aprender a leer ambos sin marearte es medio objetivo del curso.

> 📚 Si nunca tocaste un HOC, no te asustes: `withRouter(Component)` devuelve otro componente con props extra. Cinco minutos en https://v5.reactrouter.com/web/api/withRouter y sigues. El apéndice A5 (class components vs hooks) tiene el mapeo completo cuando lo necesites.

### Mini-repaso: JSX que vas a ver en esta fase

Por si el JSX no es tu pan de cada día, un repaso exprés de lo que aparece en el código de abajo:

| Escribes | Significa |
|---|---|
| `<Route path="/wheels" component={WheelListPage} />` | Si la URL empieza con `/wheels`, renderiza `WheelListPage` |
| `<Route path="/wheels/:id" ... />` | `:id` es un parámetro; en `/wheels/1`, `id` vale `"1"` (string) |
| `<Link to="/players">` | Navega sin recargar a esa ruta |
| `{wheels.map(w => <li key={w.id}>...)}` | Renderiza una lista; `key` estable por item |
| `history.push('/wheels')` | Navega por código, como si hicieras click en un Link |

> 💡 Ojo con un detalle que muerde: **los params de la URL siempre son strings.** `/wheels/1` te da `id = "1"`, no `1`. Si comparas `wheel.id === id` y `wheel.id` es número, nunca matchea. Lo vamos a ver en errores comunes porque es un clásico.

### Dónde va el navbar, y por qué

Decisión de diseño de esta fase: el `Navbar` y el `AppLayout` viven **por fuera del `Switch`**, envolviéndolo. ¿Por qué? Porque el navbar tiene que estar en todas las pantallas — no es "una ruta más", es el marco. Si lo metes adentro de una `Route`, aparece y desaparece con esa ruta. Poniéndolo alrededor del `Switch`, el navbar es persistente y solo cambia el contenido de adentro. Es el patrón de layout más común y el que vas a ver en este sistema.

---

## 💻 5. Implementación y código comentado

Todo lo de esta fase vive en el **frontend**. No hay store, no hay epic, no hay backend — es puro árbol de React y router. Lo aclaro ahora porque a partir de la Fase 2 esa distinción (frontend / store / epic / backend) va a ser crítica para depurar, y quiero que te acostumbres a preguntártela: *¿esto de dónde sale?* Acá, siempre, de un array hardcodeado en memoria.

Recuerda la convención de idioma del proyecto: **el código va en inglés, los comentarios y todo lo que ve el usuario van en español.** Por eso vas a ver `goToDetail` pero también `<button>Volver</button>`, y `status: 'live'` pero `statusLabel('live') → 'En vivo'`.

### 5.1 Instalar React Router 5

```bash
# La versión importa: 5.3.4 exacta, no la 6. Sin --save-exact npm guarda ^5.3.4.
npm install --save-exact react-router-dom@5.3.4
```

> ⚠️ Si por costumbre corriste `npm install react-router-dom` a secas y te instaló una v6, desinstala y fija la versión. Medio archivo de esta fase no compila en v6 (`Switch` no existe, `useHistory` tampoco). Revisa tu `package.json`: tiene que decir `"react-router-dom": "5.3.4"`.

Y una limpieza que esta fase te pide: el `src/App.js` de la Fase 0 ya no es el punto de entrada. Lo reemplaza `AppRouter` (sección 5.5). Bórralo con `rm src/App.js`; `WheelCard` no cambia de sitio.

### 5.2 Las ruedas hardcodeadas

En Fase 0 tenías una sola rueda (`demoWheel`). Ahora necesitas varias para listar. La deuda 💸 sigue abierta y crece: esto lo reemplaza el store en Fase 4, cuando `WheelListPage` tome la ruta `/wheels`. Respeto los campos ya fijados en Fase 0 (`id`, `name`, `timezone`, `closesAt`, `status`, `segments`) para no renombrar nada después.

Los pesos de los segmentos son los de la Esclusa de Oro (`00-historia-del-sistema.md` §8) y suman 10.000 puntos básicos. Las tres ruedas de demo comparten esa tabla a propósito: así F04 valida una sola regla para todas.

```javascript
// src/mock/wheels.js
// 💸 Deuda técnica intencional: datos hardcodeados en el front.
// Lo correcto es traerlos de la API — llega en Fase 3 (json-server).
// Por ahora esto nos deja construir la navegación sin depender de un backend.

/**
 * @typedef {Object} Segment
 * @property {string} segmentId  - slug kebab: el slug es el id
 * @property {'none'|'lives'|'avatar'|'gemSet'} prizeType
 * @property {number} weightBp   - peso en puntos básicos; la rueda suma 10.000
 */

/**
 * @typedef {Object} Wheel
 * @property {number} id
 * @property {string} name
 * @property {string} timezone     - zona de presentación (America/Panama)
 * @property {string} closesAt     - ISO 8601 con offset de zona horaria
 * @property {'draft'|'scheduled'|'live'|'ended'|'reconciled'} status
 * @property {Segment[]} segments
 */

// Los pesos son los de la Esclusa de Oro (suman 10.000); la misma tabla
// sirve a las tres ruedas de demo para que F04 valide una sola regla.
const demoSegments = [
  { segmentId: "sin-premio", prizeType: "none", weightBp: 3000 },
  { segmentId: "vidas-2", prizeType: "lives", weightBp: 2000 },
  { segmentId: "avatar-comun", prizeType: "avatar", weightBp: 1500 },
  { segmentId: "set-gemas-basico", prizeType: "gemSet", weightBp: 1500 },
  { segmentId: "vidas-5", prizeType: "lives", weightBp: 1000 },
  { segmentId: "set-gemas-plata", prizeType: "gemSet", weightBp: 800 },
  { segmentId: "avatar-raro", prizeType: "avatar", weightBp: 150 },
  { segmentId: "esclusa-de-oro", prizeType: "avatar", weightBp: 50 },
];

/** @type {Wheel[]} */
export const demoWheels = [
  {
    id: 1,
    name: "Esclusa de Oro",
    timezone: "America/Panama",
    closesAt: "2030-12-31T20:00:00-05:00",
    status: "live",
    segments: demoSegments,
  },
  {
    id: 2,
    name: "Semana del Canal",
    timezone: "America/Panama",
    closesAt: "2026-08-15T20:00:00-05:00",
    status: "scheduled",
    segments: demoSegments,
  },
  {
    id: 3,
    name: "Rueda de la costa",
    timezone: "America/Panama",
    closesAt: "2026-02-15T20:00:00-05:00",
    status: "reconciled",
    segments: demoSegments,
  },
];

/**
 * Busca una rueda por id. Recibe el id como string (viene de la URL)
 * y lo compara como número — el clásico bug de params lo evitamos acá.
 * @param {string} idParam
 * @returns {Wheel | undefined}
 */
export function findWheel(idParam) {
  const id = Number(idParam);
  return demoWheels.find((wheel) => wheel.id === id);
}
```

**Detalles con intención:**
- Exportamos `findWheel`, que **convierte el string de la URL a número** antes de comparar. Si dejáramos que cada componente hiciera `demoWheels.find(w => w.id === id)` con `id` string, tendríamos el bug repartido por todos lados. Centralizarlo es la corrección; que cada componente lo resuelva a mano sería la versión frágil.
- El `@typedef` con JSDoc nos da autocompletado y documenta la forma sin traer TypeScript (decisión D3: JS plano).
- `statusLabel` **no se redefine acá**: ya existe desde Fase 0 y lo reusamos. Los valores de `status` viajan en inglés (`'live'`); la etiqueta que ve el usuario ('En vivo') sale de `statusLabel`.

Para que esta fase pueda importar `statusLabel`, la función tiene que estar exportada. En Fase 0 no lo estaba. Cambia una sola palabra en `src/components/WheelCard.jsx`:

```javascript
// antes (Fase 0):
function statusLabel(status) {
// ahora (Fase 1): la misma función, exportada
export function statusLabel(status) {
```

### 5.3 El navbar

```javascript
// src/components/Navbar.jsx
import React from "react";
import { NavLink } from "react-router-dom";

// Funcional: no necesita estado ni ciclo de vida, solo pinta links.
// NavLink resalta solo el link de la ruta activa vía la clase active.
// Los textos visibles van en español; las rutas (URLs) en inglés.
function Navbar() {
  return (
    <nav className="navbar navbar-expand navbar-dark bg-dark">
      <NavLink className="navbar-brand" to="/wheels">
        🎡 Esclusa
      </NavLink>
      <div className="navbar-nav">
        <NavLink className="nav-item nav-link" to="/wheels">
          Ruedas
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
    </nav>
  );
}

export default Navbar;
```

> 💡 `NavLink` agrega la clase `active` (Bootstrap ya la estiliza) cuando su `to` matchea la URL. Si quieres controlar el nombre de la clase, es `activeClassName="mi-clase"`. En v5 es `activeClassName`; en v6 cambia a una función en `className` — otra razón para no mezclar docs.

### 5.4 El layout

```javascript
// src/components/AppLayout.jsx
import React from "react";
import Navbar from "./Navbar";

// Envuelve el navbar persistente + el área de contenido.
// children es lo que el router mete adentro según la ruta.
function AppLayout({ children }) {
  return (
    <>
      <Navbar />
      <main className="container mt-4">{children}</main>
    </>
  );
}

export default AppLayout;
```

### 5.5 El router

```javascript
// src/AppRouter.jsx
import React from "react";
import { BrowserRouter, Switch, Route, Redirect } from "react-router-dom";
import AppLayout from "./components/AppLayout";
import WheelListPage from "./pages/WheelListPage";
import WheelDetailPage from "./pages/WheelDetailPage";
import PlayersPage from "./pages/PlayersPage";
import SpinLogPage from "./pages/SpinLogPage";
import DashboardPage from "./pages/DashboardPage";
import NotFoundPage from "./pages/NotFoundPage";

function AppRouter() {
  return (
    <BrowserRouter>
      <AppLayout>
        {/* Switch: solo la PRIMERA ruta que matchea se renderiza. */}
        <Switch>
          {/* La raíz redirige al listado de ruedas. */}
          <Route exact path="/">
            <Redirect to="/wheels" />
          </Route>

          {/* exact acá es CLAVE: sin él, /wheels matchearía también
              /wheels/1 y nunca llegaríamos al detalle. */}
          <Route exact path="/wheels" component={WheelListPage} />
          <Route path="/wheels/:id" component={WheelDetailPage} />

          <Route path="/players" component={PlayersPage} />
          <Route path="/spin-log" component={SpinLogPage} />
          <Route path="/dashboard" component={DashboardPage} />

          {/* Sin path: matchea todo lo que no matcheó antes. El 404. */}
          <Route component={NotFoundPage} />
        </Switch>
      </AppLayout>
    </BrowserRouter>
  );
}

export default AppRouter;
```

**El patrón a memorizar:** en v5, el orden dentro de `<Switch>` importa y `exact` decide el filo del match. Ruta específica con `exact` antes que la paramétrica; el `<Route>` sin `path` al final como catch-all. Si ves dos pantallas encimadas o el 404 comiéndose todo, mira primero el `Switch`, el `exact` y el orden.

Y en `src/index.js`, montas `AppRouter` en vez del `App` de la Fase 0:

```javascript
// src/index.js
import React from "react";
import ReactDOM from "react-dom";
import "./index.scss"; // el entry de Sass de la Fase 0 (tokens → bootstrap → propios)
import AppRouter from "./AppRouter";

// React 16: ReactDOM.render, NO createRoot (eso es React 18).
ReactDOM.render(<AppRouter />, document.getElementById("root"));
```

> 📝 **Nota de época.** `ReactDOM.render(...)` es lo correcto en React 16. Si tu instinto moderno te lleva a `createRoot`, frena: eso es React 18 y acá no existe. Es de las primeras cosas que delatan a alguien que copió un snippet nuevo en una base vieja.

### 5.6 WheelListPage — class component con `withRouter` (legacy)

Este es el lado "viejo" a propósito. Una clase que lista ruedas reusando tu `WheelCard` de Fase 0 y navega al detalle usando `this.props.history`, inyectado por `withRouter`.

```javascript
// src/pages/WheelListPage.jsx
import React from "react";
import { withRouter } from "react-router-dom";
import { demoWheels } from "../mock/wheels";
import WheelCard from "../components/WheelCard";

// Class component al estilo pre-16.8: sin hooks, métodos con function-binding.
// withRouter le inyecta history/location/match como props.
class WheelListPage extends React.Component {
  // Arrow como property para no pelear con el binding de 'this'.
  // (En bases muy viejas verás .bind(this) en el constructor; mismo fin.)
  goToDetail = (id) => {
    // history viene de withRouter. push = navegar sin recargar.
    this.props.history.push(`/wheels/${id}`);
  };

  render() {
    return (
      <div>
        <h1 className="mb-3">Ruedas</h1>
        <div className="row">
          {demoWheels.map((wheel) => (
            <div
              key={wheel.id}
              className="col-md-4 mb-3"
              style={{ cursor: "pointer" }}
              onClick={() => this.goToDetail(wheel.id)}
            >
              {/* Reusamos WheelCard de Fase 0: recibe la rueda por la prop wheel. */}
              <WheelCard wheel={wheel} />
            </div>
          ))}
        </div>
      </div>
    );
  }
}

// withRouter envuelve la clase y le pasa las props del router.
export default withRouter(WheelListPage);
```

**Detalles con intención:**
- `goToDetail = (id) => {...}` es una **class property arrow function**: evita tener que hacer `this.goToDetail = this.goToDetail.bind(this)` en un constructor. En código más viejo vas a ver el `.bind(this)` explícito; es lo mismo con más ceremonia.
- Necesitamos `withRouter` **solo porque es una clase**. Si esto fuera funcional, un `useHistory()` alcanzaría y no haría falta el HOC.
- **Reusamos `WheelCard`** sin tocarlo: recibe la rueda por su prop `wheel`, tal como la dejó Fase 0.

### 5.7 WheelDetailPage — funcional con hooks (nuevo)

El lado moderno. Lee el `:id` con `useParams`, busca la rueda, y vuelve con `useHistory`.

```javascript
// src/pages/WheelDetailPage.jsx
import React from "react";
import { useParams, useHistory } from "react-router-dom";
import { findWheel } from "../mock/wheels";
import { statusLabel } from "../components/WheelCard"; // el mapeo estado→etiqueta de Fase 0

function WheelDetailPage() {
  // useParams devuelve los :params de la URL, SIEMPRE como strings.
  const { id } = useParams();
  const history = useHistory();

  // findWheel convierte el string a número internamente.
  const wheel = findWheel(id);

  if (!wheel) {
    // La rueda no existe (id inválido o inexistente). No es un 404 de ruta:
    // la ruta /wheels/:id matcheó, pero el dato no está.
    return (
      <div className="alert alert-warning">
        No existe la rueda #{id}.{" "}
        <button className="btn btn-link p-0" onClick={() => history.push("/wheels")}>
          Volver al listado
        </button>
      </div>
    );
  }

  return (
    <div>
      <button className="btn btn-outline-secondary btn-sm mb-3" onClick={() => history.goBack()}>
        ← Volver
      </button>
      <h1>{wheel.name}</h1>
      <dl className="row">
        <dt className="col-sm-3">Estado</dt>
        {/* statusLabel traduce el valor interno ('live') a la etiqueta en español ('En vivo') */}
        <dd className="col-sm-9">{statusLabel(wheel.status)}</dd>
        <dt className="col-sm-3">Cierre</dt>
        <dd className="col-sm-9">{wheel.closesAt}</dd>
        <dt className="col-sm-3">Zona horaria</dt>
        <dd className="col-sm-9">{wheel.timezone}</dd>
        <dt className="col-sm-3">Segmentos</dt>
        <dd className="col-sm-9">{wheel.segments.length}</dd>
      </dl>
      {/* Los envíos y el resultado llegan en Fases 5-7. */}
      <p className="text-muted">
        <em>Los envíos de premios se habilitan en fases posteriores.</em>
      </p>
    </div>
  );
}

export default WheelDetailPage;
```

> 💡 `history.goBack()` vuelve a la entrada anterior del historial (como el botón atrás del navegador); `history.push('/wheels')` empuja una ruta nueva. Elige según lo que quieras: "volver a donde estaba" vs "ir al listado sí o sí". Puse `goBack` en el botón principal y `push` en el fallback de rueda inexistente, a propósito, para que veas los dos.

> 📝 Nota sobre el import de `statusLabel`: en Fase 0 quedó junto a `WheelCard`. Si en tu proyecto lo tienes en un archivo aparte (por ejemplo `src/utils/statusLabel.js`), ajusta el import — lo importante es **no redefinirlo** para no tener dos versiones que se contradigan.

### 5.8 Las páginas placeholder

```javascript
// src/pages/PlayersPage.jsx
import React from "react";

// Datos hardcodeados otra vez. Se conectan al store en fases posteriores.
const demoPlayers = [
  { id: 42, name: "Juan P.", country: "Colombia" },
  { id: 43, name: "María R.", country: "Chile" },
];

function PlayersPage() {
  return (
    <div>
      <h1 className="mb-3">Jugadores</h1>
      <ul className="list-group">
        {demoPlayers.map((player) => (
          <li key={player.id} className="list-group-item d-flex justify-content-between">
            <span>{player.name}</span>
            <span className="text-muted">{player.country}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default PlayersPage;
```

> 📝 `PlayersPage` es la antigua `ParticipantsPage`, renombrada con `mv` y con sus datos demo. La página no es un placeholder vacío: es el demo que la Fase 4 reemplaza, y la deuda 💸 de esos datos sigue viva.

```javascript
// src/pages/SpinLogPage.jsx
import React from "react";

// Placeholder puro. La bitácora de giros llega con el track BE (be05).
function SpinLogPage() {
  return (
    <div>
      <h1>Bitácora</h1>
      <div className="alert alert-info">
        La bitácora de giros se construye en el track BE (be05).
      </div>
    </div>
  );
}

export default SpinLogPage;
```

```javascript
// src/pages/DashboardPage.jsx
import React from "react";

// Placeholder puro. El dashboard real (gráficos, KPIs) llega en Fase 9.
function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>
      <div className="alert alert-info">
        El dashboard con métricas y gráficos se construye en la Fase 9.
      </div>
    </div>
  );
}

export default DashboardPage;
```

### 5.9 NotFoundPage — el 404 que ayuda a depurar

```javascript
// src/pages/NotFoundPage.jsx
import React from "react";
import { useLocation, Link } from "react-router-dom";

function NotFoundPage() {
  // useLocation nos dice qué URL intentó el usuario. Útil para el forense:
  // si alguien reporta "me da 404", esto muestra exactamente qué ruta falló.
  const location = useLocation();

  return (
    <div className="text-center mt-5">
      <h1 className="display-4">404</h1>
      <p className="lead">
        No hay nada en <code>{location.pathname}</code>
      </p>
      <Link to="/wheels" className="btn btn-primary">
        Ir al listado de ruedas
      </Link>
    </div>
  );
}

export default NotFoundPage;
```

**Prueba de fuego.** Levanta la app con `npm start` y verifica a mano, en este orden:

1. Entras a `/` y te redirige a `/wheels`. Ves las 3 `WheelCard`.
2. Click en una tarjeta → vas a `/wheels/1` y ves el detalle. La URL cambió pero **la página no recargó** (el navbar no parpadeó).
3. El botón "← Volver" te devuelve al listado.
4. Escribe a mano `/wheels/999` en la barra → ves "No existe la rueda #999" (la ruta matcheó, el dato no).
5. Escribe `/cualquier-cosa` → cae en el 404 y te dice `/cualquier-cosa`.
6. Click en "Jugadores" en el navbar → cambia el contenido, el navbar sigue ahí, y "Jugadores" queda resaltado.

Si los seis pasan, la estructura quedó. (Las rutas y la navegación sin recarga también están probadas en el repo de prueba con pruebas de render en jsdom; el paso 2 y el resaltado del navbar son de mirar en el navegador.)

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Olvidar `Switch` → dos pantallas encimadas.** Sin `<Switch>`, todas las `Route` que matcheen se renderizan. Como `path="/wheels"` matchea por prefijo, entras a `/wheels/1` y ves el listado *y* el detalle apilados. Síntoma: contenido duplicado o de más. Fix mínimo: envuelve las rutas en `<Switch>`. Refactor (otro momento): revisar si además faltan `exact` donde corresponde.

**2. Falta `exact` en `/wheels` → nunca llegas al detalle.** Con `<Switch>` pero sin `exact`, `/wheels` matchea primero en `/wheels/1` y el `Switch` corta ahí: siempre ves el listado, nunca el detalle. Síntoma: el detalle "no funciona" pero no hay error en consola. Fix: `exact` en la ruta del listado, o pon la ruta paramétrica antes (menos legible).

**3. Usar `<a href>` en vez de `<Link>` → recarga completa.** Un `<a href="/wheels">` hace que el navegador pida la página al servidor y recargue todo el árbol de React: pierdes el estado en memoria y ves un parpadeo. Síntoma: la navegación "funciona" pero flashea y es lenta. Fix: `<Link to="...">` o `<NavLink>`. Es de los primeros que vas a cazar en código heredado.

**4. Comparar el `:id` string con un id número → detalle vacío.** `useParams` te da `id = "1"` (string). Si haces `demoWheels.find(w => w.id === id)` y `w.id` es `1` (número), `"1" === 1` es `false` y no encuentras nada. Síntoma: "no existe la rueda" aunque exista. Fix: convierte con `Number(id)` (lo hicimos en `findWheel`). Este bug es tan común que lo centralizamos a propósito.

### Pieza forense de esta fase: componente que no re-renderiza — cómo saber por qué

El síntoma más frustrante del principiante-en-React-legacy: *"cambié algo y la pantalla no se actualiza"*. En esta fase todavía no hay store, así que las causas están acotadas y son perfectas para entrenar el ojo. Un componente de React re-renderiza cuando **cambia su estado**, **cambian sus props**, o **su padre re-renderiza**. Si no pasa ninguna de las tres, no se pinta de nuevo — por más que tú hayas "cambiado" algo.

El caso típico acá: editas el array `demoWheels` en `mock/wheels.js` mientras la app corre, y el listado no cambia. ¿Bug de React? No. O el hot-reload no recargó el módulo, o —más educativo— estás mutando el array en vez de reemplazarlo y nada le avisa a React que redibuje. React no observa objetos: reacciona a cambios de referencia en estado/props. Un array hardcodeado que mutas a mano no dispara nada.

Cómo diagnosticarlo con **React DevTools** (que instalaste en Fase 0):

1. Abre la pestaña **Components**, selecciona el componente que "no se actualiza" (por ejemplo `WheelDetailPage`).
2. Mira sus **props** y su **hooks/state** en el panel derecho. ¿El valor que esperas que cambie está ahí? ¿Con qué valor?
3. Activa **"Highlight updates when components render"** (en las opciones de DevTools). Cuando algo re-renderiza, se pinta un borde de color. Navega y observa: si al cambiar de ruta el componente **no** se enciende, es que no está recibiendo props nuevas ni cambió su estado.
4. Para `WheelDetailPage`: navega de `/wheels/1` a `/wheels/2`. El `id` de `useParams` cambia, el componente se re-renderiza, se enciende el borde. Si **no** cambia, revisa que el `:id` esté bien en la ruta y que no estés cacheando la rueda en un estado que nadie actualiza.

> ⚠️ Rompe a propósito para aprender: en `WheelDetailPage`, guarda la rueda en un `useState` inicializado con `findWheel(id)` **sin** un `useEffect` que lo actualice cuando cambia `id`. Ahora navega de `/wheels/1` a `/wheels/2`: la URL cambia, pero el detalle sigue mostrando la rueda 1. El componente **sí** re-renderiza, pero el estado se inicializó una vez y nadie lo refresca. Con DevTools vas a ver el `id` de params en 2 y el estado de la rueda en 1 — la foto exacta del bug. Es el germen del clásico "los datos viejos se quedan pegados" que vas a ver en serio con el store más adelante.

> 📓 De esta fase salen los incidentes **03** y **04** de `cuaderno-incidentes.md`. El 04 es justamente el bug de arriba, llegando como llega en la vida real: en palabras de una operadora que no sabe qué es un `useState`.

---

## 🧪 7. Ejercicios (30)

Trabaja sobre la app de la fase. Varios son de diagnóstico: te entrego algo roto y tienes que localizar el porqué, no solo construir. Ancla todo al dominio de ruedas. Respeta la convención de idioma: identificadores en inglés, textos de UI y comentarios en español.

**🟢 Fácil (1–8)**

1. Agrega una ruta `/about` con un componente `AboutPage` que muestre un párrafo sobre la consola de la Esclusa. Súmala al navbar (el link visible dice "Acerca").
2. Cambia el `NavLink` del brand para que solo esté activo en `/wheels` exacto y no dentro de `/wheels/1` (pista: `exact`).
3. Agrega una cuarta rueda hardcodeada a `demoWheels` y verifica que aparece en el listado sin tocar nada más.
4. En `WheelDetailPage`, muestra también la cantidad de segmentos con su peso total (suma de `weightBp`, debe dar 10.000) formateado con `toLocaleString('es-PA')`.
5. Cambia el botón "← Volver" para que use `history.push('/wheels')` en vez de `goBack()`. Describe en un comentario la diferencia de comportamiento.
6. Agrega un `<Link>` desde el `DashboardPage` placeholder hacia `/wheels`.
7. Haz que el 404 muestre además el `location.search` (la query string) si existe. Prueba con `/nada?x=1`.
8. En el navbar, agrega un badge con la cantidad total de ruedas (`demoWheels.length`).

**🟡 Intermedio (9–17)**

9. Agrega una ruta anidada `/wheels/:id/players` que muestre los jugadores de esa rueda (hardcodea la relación). Usa `useParams` para leer el `id`.
10. Convierte `PlayersPage` de funcional a **class component con `withRouter`**, solo para practicar el estilo legacy. Deja el funcional comentado al lado.
11. Haz que al hacer click en una rueda con `status: 'draft'`, en vez de ir al detalle, muestre un `alert` de "rueda en borrador". Lógica en `WheelListPage`.
12. Agrega un filtro de ruedas por estado en el listado, controlado por query string (`/wheels?status=live`). Lee el filtro con `location` — pero ojo, `WheelListPage` es clase: resuelve con `this.props.location`.
13. Crea un `<Redirect>` de `/home` hacia `/wheels`.
14. En `WheelDetailPage`, agrega un botón "Siguiente rueda" que navegue a `/wheels/{id+1}` con `history.push`. Maneja el caso de que no exista.
15. Haz que el `NavLink` de Dashboard tenga un `activeClassName` personalizado y estílalo distinto al resto en tu Sass (suma un token a `_tokens.scss`, no hardcodees el color).
16. Agrega un breadcrumb (miga de pan) en `WheelDetailPage`: "Ruedas / {name}". El "Ruedas" es un `Link` al listado.
17. Extrae la grilla de tarjetas de `WheelListPage` a un componente `WheelGrid` que reciba las ruedas por props y un callback `onSelect`. `WheelListPage` queda como contenedor.

**🟠 Difícil (18–24)**

18. Te paso `WheelListPage` sin `withRouter` pero llamando `this.props.history.push(...)`. Reproduce el error exacto (mensaje en consola), explica por qué pasa, y arréglalo con el fix mínimo.
19. En el `AppRouter`, alguien puso `<Route path="/wheels/:id" />` **antes** que `<Route exact path="/wheels" />`. Reproduce el síntoma, explica el orden de match en `Switch`, y corrige.
20. Diagnóstico: te entrego una versión donde el detalle muestra siempre "No existe la rueda" aunque el id sea válido. La causa está en la comparación de tipos (`wheel.id === id` con `id` string). Localízala con React DevTools (mirando params vs el dato) y arréglala.
21. Implementa el bug de la caja ⚠️ de la sección forense (rueda cacheada en `useState` sin `useEffect`) y después arréglalo correctamente con un `useEffect` que dependa de `id`. Explica por qué re-renderizar no bastaba.
22. Agrega una ruta con parámetro opcional `/wheels/:id/:tab?` donde `tab` puede ser `info` o `players`. Renderiza contenido distinto según `tab`, con `info` por defecto.
23. Haz que el navbar resalte "Ruedas" también cuando estás en `/wheels/1` (detalle), usando `isActive` de `NavLink` con una función custom.
24. Diagnóstico: te entrego la app con un `<a href="/players">` en el navbar en vez de `Link`. Describe cómo lo detectas (qué observas en la Network tab al hacer click) y por qué es un problema en una SPA.

**🔴 Muy difícil (25–30)**

25. Implementa un componente `ScrollToTop` que, usando `useLocation` y `useEffect`, lleve el scroll al tope cada vez que cambia la ruta. Explica por qué el router no lo hace solo.
26. Reproduce y explica el problema de refrescar (F5) en `/wheels/1` cuando la app se sirve como archivos estáticos sin configuración de fallback: por qué en `npm start` funciona y en un server estático da 404. (Pista: history mode vs el servidor.) Documenta la solución conceptual sin implementarla — es tema de deploy, no de esta fase.
27. Construye un HOC propio `withWheel(Component)` que inyecte la rueda correspondiente al `:id` como prop, replicando la idea de `withRouter`. Úsalo en un componente de clase.
28. Diagnóstico forense completo: te entrego la app donde al navegar entre `/wheels/1` y `/wheels/2` el detalle no cambia. Puede ser el bug de `useState` sin `useEffect`, o un `key` mal puesto. Distingue cuál de las dos causas es, usando "Highlight updates" de DevTools, y documenta el razonamiento como mini post-mortem (síntoma, evidencia, causa, fix).
29. Haz que `WheelListPage` (la clase) navegue programáticamente respetando un parámetro de origen: si vienes de `/dashboard`, el detalle debe tener un botón "volver al dashboard"; si vienes del listado, "volver a ruedas". Pasa el origen por `location.state` en el `history.push`.
30. Integra las 5 rutas en un objeto de configuración `routes = [{ path, component, exact }]` y genera los `<Route>` con un `.map()` dentro del `Switch`. Cuida que `exact` y el orden se respeten. Explica qué ganas y qué pierdes versus escribir las rutas a mano.

**🔥 Opcionales**

- 🔥 Migra `WheelListPage` de class + `withRouter` a funcional + `useHistory`. Compara ambas versiones lado a lado y anota qué desaparece (el HOC, el `this`). Es un ensayo del apéndice A5.
- 🔥 Reemplaza el layout hecho a mano por uno con rutas anidadas dentro de un componente `AppLayout` que use render props. Compara legibilidad.
- 🔥 Prueba lazy-loading de `DashboardPage` con `React.lazy` + `Suspense` y explica qué implica en React 16.14 (Suspense para code-splitting sí existe; para data no).

---

## 📚 8. Referencias

**Documentación oficial**

- React Router 5 — API web completa: https://v5.reactrouter.com/web/guides/quick-start (esta es la v5; **no** uses reactrouter.com a secas, que hoy documenta v6/v7).
- `withRouter`: https://v5.reactrouter.com/web/api/withRouter
- Hooks de router (`useParams`, `useHistory`, `useLocation`): https://v5.reactrouter.com/web/api/Hooks
- React 16 (componentes, ciclo de vida de clases): https://legacy.reactjs.org/docs/react-component.html
- React DevTools: https://legacy.reactjs.org/blog/2019/08/15/new-react-devtools.html
- Bootstrap 4.6 navbar: https://getbootstrap.com/docs/4.6/components/navbar/ — y `A1-bootstrap-4-y-sass.md` §6 para las utilidades que usa el `AppLayout` sin tener que salir del curso.

**Video / apoyo**

- Cualquier "React Router v5 crash course" en YouTube sirve como refuerzo visual, pero verifica que sea **v5** y no v6 (el cambio de API es grande). Busca por "react router dom 5" explícito.

> ⚠️ Las URLs, títulos y contenidos de referencias pueden estar desactualizados o haber cambiado de lugar; verifícalos al abrirlos. Sobre todo con React Router: mucho material online es de v6 y **no aplica** a nuestro código. Si un snippet usa `<Routes>`, `element={}` o `useNavigate`, es v6 — descártalo para esta fase.

**Orden de lectura sugerido:** Quick start de v5 (para el mapa mental de `BrowserRouter`/`Switch`/`Route`) → la página de Hooks (para `useParams`/`useHistory`) → `withRouter` (para entender el lado de las clases) → vuelve al código de `AppRouter` y `WheelListPage` y releélo con eso fresco.

---

## 🚀 9. Cierre y conexión con la Fase 2

Tienes un esqueleto navegable: cinco rutas, un layout persistente con navbar, el detalle de rueda leyendo su `:id`, y un 404 que te dice qué falló. Viste convivir una clase con `withRouter` y un funcional con hooks de router — la mezcla exacta que heredas, y que tiene fecha: la clase es de 2019 y el hook de 2021. Reusaste `WheelCard` de Fase 0 sin reescribirlo, y arrancaste el track forense entrenando el ojo para el "no se re-renderiza", que es la madre de muchos bugs que vienen.

Pero todo es público y todo es mentira: cualquiera entra a cualquier ruta, y los datos son un array hardcodeado que nadie comparte entre componentes. La **Fase 2** ataca la primera mitad de eso: **autenticación mínima**. Ahí aparece el primer Redux del curso —un `authSlice`—, un login mock, el componente `PrivateRoute` que va a envolver a estas mismas rutas para cerrarles el paso a los no logueados, y el primer interceptor de axios. Vas a ver por qué el router y el store se necesitan mutuamente, y cómo una ruta "protegida" es solo una `Route` con una guarda adentro.

> **La señal de que quedó bien:** si navegas toda la app sin un solo parpadeo de recarga, si el navbar te dice siempre dónde estás, y si cuando algo no se ve sabes en menos de un minuto si es la ruta, el `exact`, el `Switch` o el dato — entonces la estructura está firme y puedes construir auth encima sin miedo.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-01-estructura-base-router-5 -m "F1 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f01: …`) y los de ejercicio su
> número (`f01 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f01/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura. Va acá abajo, fuera de la plantilla de nueve
> secciones, porque es lo que apareció al escribir la fase y no cabía adentro — y
> porque no debe competir con el cierre.

- **El bug del detalle cacheado se cuenta dos veces.** La pieza forense de §6 y
  el ejercicio 21 describen el mismo `useState` sin `useEffect`. Como además es el
  incidente 04, hay tres enunciados del mismo bug. → Dejar el desarrollo completo
  en el cuaderno y que fase y ejercicio lo referencien.
- ~~**La deuda 💸 de datos hardcodeados sigue abierta** desde Fase 0 y crece.~~
  **Resuelto:** la salda la **Fase 4 §5.5** para el listado. El detalle
  (`WheelDetailPage`, que usa `findWheel`) **no** se migra en el curso: queda
  declarado como deuda en `A12-mapa-de-deuda-tecnica.md` con su disparador.
- **`withRouter` en clase frente a los hooks de router.** La convivencia se
  muestra al pasar, y es justo el tipo de lectura mezclada que el curso entrena.
  → Sección propia en `A5-class-components-vs-hooks.md`.
- **Comparar el `:id` string con un id numérico** es el error común #4 y no tiene
  ejercicio de diagnóstico. → Ejercicio 🟡.

### Reservas para el cuaderno de incidentes

Los IDs quedan reservados en `cuaderno-incidentes.md`, donde el enunciado ya
está redactado con sus pistas y su solución de referencia. El ID nunca se reasigna.

- **03** — *Hago clic en el menú y se recarga toda la aplicación* · UI / routing · 🟢.
  Sale del error común #3 (`<a href>` en vez de `<Link>`).
- **04** — *Entro al detalle de otra rueda y sigo viendo la anterior* · UI / routing · 🟡.
  Sale de la pieza forense: `useState` inicializado con la rueda y sin `useEffect`
  que reaccione al cambio de `id`. Admite una segunda causa plausible (`key` mal
  puesta), y esa ambigüedad es justamente lo que lo hace formativo.
