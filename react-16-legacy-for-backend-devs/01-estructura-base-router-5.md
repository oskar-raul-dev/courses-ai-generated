# 🏗️ Fase 01 — Estructura base + Router 5

> Tutorial React 16 — Rifas y chances · Fase 1 de 11 · **8 horas**
> Depende de: Fase 0 — Setup + Hola mundo CRA · Habilita: Fase 2 — Autenticación mínima

---

## 🎯 1. Propósito

Al terminar la Fase 0 tenías una app que compila, levanta en `localhost:3000` y muestra **una** `RaffleCard` con una rifa hardcodeada. Bonito, pero es una postal: no va a ningún lado. Una SPA de verdad tiene secciones, una URL que significa algo, y una barra de navegación que no se recarga cada vez que la tocás.

En esta fase le damos **esqueleto navegable** a la app de rifas. Vas a montar React Router 5, un `AppLayout` con navbar de Bootstrap que persiste en todas las pantallas, y las primeras páginas del dominio: el listado de rifas (reusando tu `RaffleCard`), el detalle de una rifa, participantes y un placeholder de dashboard. Todo con datos hardcodeados todavía — ni store, ni backend, ni login. Solo navegación y estructura.

¿Por qué importa esto para mantenimiento? Porque el 90% de los bugs de navegación que vas a heredar viven acá: rutas que matchean de más, links que recargan la página entera, un `:id` que llega como string cuando alguien esperaba número, un componente que "no se actualiza" al cambiar de ruta. Entender el router es entender por dónde entra el usuario a cada pantalla — y por dónde se rompe.

---

## ✅ 2. Qué queda listo al terminar

- [ ] La app navega entre 5 rutas **sin recargar la página**: `/raffles`, `/raffles/:id`, `/participants`, `/dashboard` y un 404 para todo lo demás.
- [ ] Un `AppLayout` con navbar de Bootstrap persiste en todas las rutas, y el link de la sección activa se resalta solo.
- [ ] `RaffleListPage` —un **class component con `withRouter`**— lista rifas hardcodeadas (renderizando tu `RaffleCard` de Fase 0) y navega al detalle al hacer click en una.
- [ ] `RaffleDetailPage` —un **funcional con `useParams`**— lee el `:id` de la URL, muestra la rifa correcta, y vuelve al listado con un botón que usa `useHistory`.
- [ ] Una URL inexistente como `/cualquier-cosa` cae en `NotFoundPage` sin romper nada, y te dice qué ruta intentaste.

---

## 🚫 3. Qué queda fuera por ahora

- **Redux y el store** → Fase 2 en adelante. Acá los datos son un array hardcodeado en un archivo `mock/`.
- **Autenticación y `PrivateRoute`** → Fase 2. En esta fase todas las rutas son públicas; cualquiera entra a cualquier lado.
- **Datos reales desde una API** → Fase 3 (json-server + Express caos). Todavía no hay `axios` ni `fetch`.
- **Venta de números, reserva, resultados** → Fases 5-7. El detalle de rifa muestra información, no permite operar.
- **React Router 6** → nunca en el código principal. Trabajamos en v5 a propósito (ver nota de época más abajo).

> 📝 **Nota de época.** Si venís de proyectos nuevos, tu instinto va a ser `npm install react-router-dom` y te va a instalar la v6 o v7, con `<Routes>`, `element={}` y `useNavigate`. **No es lo que corre en este sistema.** Acá es v5: `<Switch>`, `component={}`/`render={}` y `useHistory`. Son mundos parecidos pero incompatibles. Fijá la versión con `@5.3` y no te confundas de documentación.

---

## 🧠 4. Conceptos mínimos

Sos senior, así que no te voy a explicar qué es una URL. Lo que sí vale la pena encuadrar es **qué problema resuelve un router en una SPA**, porque de ahí sale todo lo demás.

En una app tradicional, cada URL es un documento que el servidor te devuelve entero: pedís `/raffles`, el servidor arma el HTML de rifas, lo manda, el navegador lo pinta desde cero. En una SPA hay **un solo documento** (`index.html`) y **un solo árbol de React** que ya está cargado en memoria. Cambiar de "página" no significa pedirle nada al servidor: significa **mostrar un subárbol de componentes distinto** y actualizar la barra de direcciones para que la URL siga siendo la fuente de verdad de "qué estoy viendo". Eso es todo lo que hace un router: mira la URL, decide qué componente renderizar, y cambia la URL sin recargar cuando navegás.

React Router 5 lo hace con cuatro piezas que vas a usar todo el tiempo:

- **`BrowserRouter`**: el contenedor. Va una sola vez, arriba de todo. Usa la History API del navegador para cambiar la URL sin recargar. Todo lo que navegue tiene que vivir adentro de él.
- **`Route`**: "si la URL matchea este `path`, renderizá este componente". El detalle traicionero es que en v5 el match es **por prefijo**: `path="/raffles"` matchea `/raffles`, pero también `/raffles/1` y `/raffles/lo-que-sea`. Por eso existen `exact` y `Switch`.
- **`Switch`**: renderiza **solo la primera** `Route` que matchea, como un `switch/case`. Sin él, si dos rutas matchean la misma URL, se pintan las dos. Es la causa número uno de "se me renderizan dos pantallas encimadas".
- **`Link` / `NavLink`**: reemplazan al `<a href>`. Un `<a>` normal recarga la página entera y mata la SPA; `Link` cambia la URL vía JavaScript y deja el árbol vivo. `NavLink` es un `Link` que además sabe si su ruta está activa, para resaltarse.

### Los hooks de router, y por qué las clases se los pierden

React Router 5.1+ trae hooks: `useParams` (los `:parametros` de la URL), `useHistory` (para navegar por código: `history.push('/raffles')`), y `useLocation` (la URL actual, con su `pathname`, `search`, etc.). Son cómodos y limpios.

Pero **los hooks solo funcionan en componentes funcionales**. Un class component no puede llamar `useParams()`. Para esos casos —y vas a tener muchos, porque el código real está lleno de clases pre-hooks— React Router ofrece `withRouter`, un HOC (higher-order component) que **inyecta `history`, `location` y `match` como props**. Es el equivalente clásico: donde el funcional escribe `const { id } = useParams()`, la clase lee `this.props.match.params.id`.

En esta fase vas a ver los dos lados a propósito: `RaffleListPage` es una **clase con `withRouter`** (legacy, como lo vas a encontrar en producción) y `RaffleDetailPage` es un **funcional con `useParams`** (el estilo nuevo). No es un accidente ni una inconsistencia: es exactamente la mezcla que heredás. Aprender a leer ambos sin marearte es medio objetivo del curso.

> 📚 Si nunca tocaste un HOC, no te asustes: `withRouter(Component)` devuelve otro componente con props extra. Cinco minutos en https://v5.reactrouter.com/web/api/withRouter y seguís. El apéndice A5 (class components vs hooks) tiene el mapeo completo cuando lo necesites.

### Mini-repaso: JSX que vas a ver en esta fase

Por si el JSX no es tu pan de cada día, un repaso exprés de lo que aparece en el código de abajo:

| Escribís | Significa |
|---|---|
| `<Route path="/raffles" component={RaffleListPage} />` | Si la URL empieza con `/raffles`, renderizá `RaffleListPage` |
| `<Route path="/raffles/:id" ... />` | `:id` es un parámetro; en `/raffles/7`, `id` vale `"7"` (string) |
| `<Link to="/participants">` | Navega sin recargar a esa ruta |
| `{raffles.map(r => <li key={r.id}>...)}` | Renderiza una lista; `key` estable por item |
| `history.push('/raffles')` | Navega por código, como si hicieras click en un Link |

> 💡 Ojo con un detalle que muerde: **los params de la URL siempre son strings.** `/raffles/7` te da `id = "7"`, no `7`. Si comparás `raffle.id === id` y `raffle.id` es número, nunca matchea. Lo vamos a ver en errores comunes porque es un clásico.

### Dónde va el navbar, y por qué

Decisión de diseño de esta fase: el `Navbar` y el `AppLayout` viven **por fuera del `Switch`**, envolviéndolo. ¿Por qué? Porque el navbar tiene que estar en todas las pantallas — no es "una ruta más", es el marco. Si lo metés adentro de una `Route`, aparece y desaparece con esa ruta. Poniéndolo alrededor del `Switch`, el navbar es persistente y solo cambia el contenido de adentro. Es el patrón de layout más común y el que vas a ver en el sistema real.

---

## 💻 5. Implementación y código comentado

Todo lo de esta fase vive en el **frontend**. No hay store, no hay epic, no hay backend — es puro árbol de React y router. Lo aclaro ahora porque a partir de la Fase 2 esa distinción (frontend / store / epic / backend) va a ser crítica para depurar, y quiero que te acostumbres a preguntártela: *¿esto de dónde sale?* Acá, siempre, de un array hardcodeado en memoria.

Recordá la convención de idioma del proyecto: **el código va en inglés, los comentarios y todo lo que ve el usuario van en español.** Por eso vas a ver `goToDetail` pero también `<button>Volver</button>`, y `status: 'open'` pero `statusLabel('open') → 'Abierta'`.

### 5.1 Instalar React Router 5

```bash
# La versión importa: 5.3.x, no la 6. Si omitís el @5.3 te trae la última mayor.
npm install react-router-dom@5.3.4
```

> ⚠️ Si por costumbre corriste `npm install react-router-dom` a secas y te instaló una v6, desinstalá y fijá la versión. Medio archivo de esta fase no compila en v6 (`Switch` no existe, `useHistory` tampoco). Revisá tu `package.json`: tiene que decir `"react-router-dom": "^5.3.4"`.

### 5.2 Los datos hardcodeados

En Fase 0 tenías una sola rifa (`demoRaffle`). Ahora necesitás varias para listar. La deuda 💸 sigue abierta: esto lo reemplaza el backend en Fase 3. Respeto los campos ya fijados en Fase 0 (`id`, `name`, `lotteryId`, `closesAt`, `pricePerNumber`, `basePrize`, `status`) para no renombrar nada después.

```javascript
// src/mock/raffles.js
// 💸 Deuda técnica intencional: datos hardcodeados en el front.
// Lo correcto es traerlos de la API — llega en Fase 3 (json-server).
// Por ahora esto nos deja construir la navegación sin depender de un backend.
// En Fase 0 esto era un único demoRaffle; acá pasa a un array demoRaffles.

/**
 * @typedef {Object} Raffle
 * @property {number} id
 * @property {string} name
 * @property {string} lotteryId
 * @property {string} closesAt      - ISO 8601 con offset de zona horaria
 * @property {number} pricePerNumber
 * @property {number} basePrize
 * @property {'draft'|'open'|'closed'|'resolved'|'settled'} status
 */

/** @type {Raffle[]} */
export const demoRaffles = [
  {
    id: 1,
    name: 'Rifa fin de mes',
    lotteryId: 'boyaca',
    closesAt: '2024-03-30T22:00:00-05:00',
    pricePerNumber: 5000,
    basePrize: 500000,
    status: 'open',
  },
  {
    id: 2,
    name: 'Rifa aguinaldo',
    lotteryId: 'cundinamarca',
    closesAt: '2024-12-20T20:00:00-05:00',
    pricePerNumber: 10000,
    basePrize: 2000000,
    status: 'draft',
  },
  {
    id: 3,
    name: 'Rifa del barrio',
    lotteryId: 'boyaca',
    closesAt: '2024-02-15T21:00:00-05:00',
    pricePerNumber: 2000,
    basePrize: 150000,
    status: 'settled',
  },
];

/**
 * Busca una rifa por id. Recibe el id como string (viene de la URL)
 * y lo compara como número — el clásico bug de params lo evitamos acá.
 * @param {string} idParam
 * @returns {Raffle | undefined}
 */
export function findRaffle(idParam) {
  const id = Number(idParam);
  return demoRaffles.find((raffle) => raffle.id === id);
}
```

**Detalles con intención:**
- Exportamos `findRaffle`, que **convierte el string de la URL a número** antes de comparar. Si dejáramos que cada componente hiciera `demoRaffles.find(r => r.id === id)` con `id` string, tendríamos el bug repartido por todos lados. Centralizarlo es la corrección; que cada componente lo resuelva a mano sería la versión frágil.
- El `@typedef` con JSDoc nos da autocompletado y documenta la forma sin traer TypeScript (decisión D3: JS plano).
- `statusLabel` **no se redefine acá**: ya existe desde Fase 0 y lo reusamos. Los valores de `status` viajan en inglés (`'open'`); la etiqueta que ve el usuario ('Abierta') sale de `statusLabel`.

### 5.3 El navbar

```javascript
// src/components/Navbar.jsx
import React from 'react';
import { NavLink } from 'react-router-dom';

// Funcional: no necesita estado ni ciclo de vida, solo pinta links.
// NavLink resalta solo el link de la ruta activa vía la clase active.
// Los textos visibles van en español; las rutas (URLs) en inglés.
function Navbar() {
  return (
    <nav className="navbar navbar-expand navbar-dark bg-dark">
      <NavLink className="navbar-brand" to="/raffles">
        🎲 Rifas
      </NavLink>
      <div className="navbar-nav">
        <NavLink className="nav-item nav-link" to="/raffles">
          Rifas
        </NavLink>
        <NavLink className="nav-item nav-link" to="/participants">
          Participantes
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

> 💡 `NavLink` agrega la clase `active` (Bootstrap ya la estiliza) cuando su `to` matchea la URL. Si querés controlar el nombre de la clase, es `activeClassName="mi-clase"`. En v5 es `activeClassName`; en v6 cambia a una función en `className` — otra razón para no mezclar docs.

### 5.4 El layout

```javascript
// src/components/AppLayout.jsx
import React from 'react';
import Navbar from './Navbar';

// Envuelve el navbar persistente + el área de contenido.
// children es lo que el router meta adentro según la ruta.
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
import React from 'react';
import { BrowserRouter, Switch, Route, Redirect } from 'react-router-dom';
import AppLayout from './components/AppLayout';
import RaffleListPage from './pages/RaffleListPage';
import RaffleDetailPage from './pages/RaffleDetailPage';
import ParticipantsPage from './pages/ParticipantsPage';
import DashboardPage from './pages/DashboardPage';
import NotFoundPage from './pages/NotFoundPage';

function AppRouter() {
  return (
    <BrowserRouter>
      <AppLayout>
        {/* Switch: solo la PRIMERA ruta que matchea se renderiza. */}
        <Switch>
          {/* La raíz redirige al listado de rifas. */}
          <Route exact path="/">
            <Redirect to="/raffles" />
          </Route>

          {/* exact acá es CLAVE: sin él, /raffles matchearía también
              /raffles/1 y nunca llegaríamos al detalle. */}
          <Route exact path="/raffles" component={RaffleListPage} />
          <Route path="/raffles/:id" component={RaffleDetailPage} />

          <Route path="/participants" component={ParticipantsPage} />
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

**El patrón a memorizar:** en v5, el orden dentro de `<Switch>` importa y `exact` decide el filo del match. Ruta específica con `exact` antes que la paramétrica; el `<Route>` sin `path` al final como catch-all. Si ves dos pantallas encimadas o el 404 comiéndose todo, mirá primero el `Switch`, el `exact` y el orden.

Y en `src/index.js`, montás `AppRouter` en vez del `App` de la Fase 0:

```javascript
// src/index.js
import React from 'react';
import ReactDOM from 'react-dom';
import './index.scss'; // el entry de Sass de la Fase 0 (tokens → bootstrap → propios)
import AppRouter from './AppRouter';

// React 16: ReactDOM.render, NO createRoot (eso es React 18).
ReactDOM.render(<AppRouter />, document.getElementById('root'));
```

> 📝 **Nota de época.** `ReactDOM.render(...)` es lo correcto en React 16. Si tu instinto moderno te lleva a `createRoot`, frená: eso es React 18 y acá no existe. Es de las primeras cosas que delatan a alguien que copió un snippet nuevo en una base vieja.

### 5.6 RaffleListPage — class component con `withRouter` (legacy)

Este es el lado "viejo" a propósito. Una clase que lista rifas reusando tu `RaffleCard` de Fase 0 y navega al detalle usando `this.props.history`, inyectado por `withRouter`.

```javascript
// src/pages/RaffleListPage.jsx
import React from 'react';
import { withRouter } from 'react-router-dom';
import { demoRaffles } from '../mock/raffles';
import RaffleCard from '../components/RaffleCard'; // reusado de Fase 0

// Class component al estilo pre-16.8: sin hooks, métodos con function-binding.
// withRouter le inyecta history/location/match como props.
class RaffleListPage extends React.Component {
  // Arrow como property para no pelear con el binding de 'this'.
  // (En bases muy viejas verás .bind(this) en el constructor; mismo fin.)
  goToDetail = (id) => {
    // history viene de withRouter. push = navegar sin recargar.
    this.props.history.push(`/raffles/${id}`);
  };

  render() {
    return (
      <div>
        <h1 className="mb-3">Rifas</h1>
        <div className="row">
          {demoRaffles.map((raffle) => (
            <div
              key={raffle.id}
              className="col-md-4 mb-3"
              style={{ cursor: 'pointer' }}
              onClick={() => this.goToDetail(raffle.id)}
            >
              {/* Reusamos RaffleCard de Fase 0: recibe la rifa por la prop raffle. */}
              <RaffleCard raffle={raffle} />
            </div>
          ))}
        </div>
      </div>
    );
  }
}

// withRouter envuelve la clase y le pasa las props del router.
export default withRouter(RaffleListPage);
```

**Detalles con intención:**
- `goToDetail = (id) => {...}` es una **class property arrow function**: evita tener que hacer `this.goToDetail = this.goToDetail.bind(this)` en un constructor. En código más viejo vas a ver el `.bind(this)` explícito; es lo mismo con más ceremonia.
- Necesitamos `withRouter` **solo porque es una clase**. Si esto fuera funcional, un `useHistory()` alcanzaría y no haría falta el HOC.
- **Reusamos `RaffleCard`** sin tocarlo: recibe la rifa por su prop `raffle`, tal como la dejó Fase 0.

### 5.7 RaffleDetailPage — funcional con hooks (nuevo)

El lado moderno. Lee el `:id` con `useParams`, busca la rifa, y vuelve con `useHistory`.

```javascript
// src/pages/RaffleDetailPage.jsx
import React from 'react';
import { useParams, useHistory } from 'react-router-dom';
import { findRaffle } from '../mock/raffles';
import { statusLabel } from '../components/RaffleCard'; // el mapeo estado→etiqueta de Fase 0

function RaffleDetailPage() {
  // useParams devuelve los :params de la URL, SIEMPRE como strings.
  const { id } = useParams();
  const history = useHistory();

  // findRaffle convierte el string a número internamente.
  const raffle = findRaffle(id);

  if (!raffle) {
    // La rifa no existe (id inválido o inexistente). No es un 404 de ruta:
    // la ruta /raffles/:id matcheó, pero el dato no está.
    return (
      <div className="alert alert-warning">
        No existe la rifa #{id}.{' '}
        <button className="btn btn-link p-0" onClick={() => history.push('/raffles')}>
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
      <h1>{raffle.name}</h1>
      <dl className="row">
        <dt className="col-sm-3">Lotería</dt>
        <dd className="col-sm-9">{raffle.lotteryId}</dd>
        <dt className="col-sm-3">Estado</dt>
        {/* statusLabel traduce el valor interno ('open') a la etiqueta en español ('Abierta') */}
        <dd className="col-sm-9">{statusLabel(raffle.status)}</dd>
        <dt className="col-sm-3">Cierre</dt>
        <dd className="col-sm-9">{raffle.closesAt}</dd>
        <dt className="col-sm-3">Precio por número</dt>
        <dd className="col-sm-9">${raffle.pricePerNumber.toLocaleString('es-CO')}</dd>
      </dl>
      {/* La venta de números y el resultado llegan en Fases 5-7. */}
      <p className="text-muted">
        <em>La venta de números se habilita en fases posteriores.</em>
      </p>
    </div>
  );
}

export default RaffleDetailPage;
```

> 💡 `history.goBack()` vuelve a la entrada anterior del historial (como el botón atrás del navegador); `history.push('/raffles')` empuja una ruta nueva. Elegí según lo que quieras: "volver a donde estaba" vs "ir al listado sí o sí". Puse `goBack` en el botón principal y `push` en el fallback de rifa inexistente, a propósito, para que veas los dos.

> 📝 Nota sobre el import de `statusLabel`: en Fase 0 quedó junto a `RaffleCard`. Si en tu proyecto lo tenés en un archivo aparte (por ejemplo `src/utils/statusLabel.js`), ajustá el import — lo importante es **no redefinirlo** para no tener dos versiones que se contradigan.

### 5.8 Las páginas placeholder

```javascript
// src/pages/ParticipantsPage.jsx
import React from 'react';

// Datos hardcodeados otra vez. Se conectan al store en fases posteriores.
const demoParticipants = [
  { id: 42, name: 'Juan P.', phone: '300...' },
  { id: 43, name: 'María R.', phone: '311...' },
];

function ParticipantsPage() {
  return (
    <div>
      <h1 className="mb-3">Participantes</h1>
      <ul className="list-group">
        {demoParticipants.map((participant) => (
          <li key={participant.id} className="list-group-item d-flex justify-content-between">
            <span>{participant.name}</span>
            <span className="text-muted">{participant.phone}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default ParticipantsPage;
```

```javascript
// src/pages/DashboardPage.jsx
import React from 'react';

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
import React from 'react';
import { useLocation, Link } from 'react-router-dom';

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
      <Link to="/raffles" className="btn btn-primary">
        Ir al listado de rifas
      </Link>
    </div>
  );
}

export default NotFoundPage;
```

**Prueba de fuego.** Levantá la app con `npm start` y verificá a mano, en este orden:

1. Entrás a `/` y te redirige a `/raffles`. Ves las 3 `RaffleCard`.
2. Click en una tarjeta → vas a `/raffles/1` y ves el detalle. La URL cambió pero **la página no recargó** (el navbar no parpadeó).
3. El botón "← Volver" te devuelve al listado.
4. Escribí a mano `/raffles/999` en la barra → ves "No existe la rifa #999" (la ruta matcheó, el dato no).
5. Escribí `/cualquier-cosa` → cae en el 404 y te dice `/cualquier-cosa`.
6. Click en "Participantes" en el navbar → cambia el contenido, el navbar sigue ahí, y "Participantes" queda resaltado.

Si los seis pasan, la estructura quedó.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Olvidar `Switch` → dos pantallas encimadas.** Sin `<Switch>`, todas las `Route` que matcheen se renderizan. Como `path="/raffles"` matchea por prefijo, entrás a `/raffles/1` y ves el listado *y* el detalle apilados. Síntoma: contenido duplicado o de más. Fix mínimo: envolvé las rutas en `<Switch>`. Refactor (otro momento): revisar si además faltan `exact` donde corresponde.

**2. Falta `exact` en `/raffles` → nunca llegás al detalle.** Con `<Switch>` pero sin `exact`, `/raffles` matchea primero en `/raffles/1` y el `Switch` corta ahí: siempre ves el listado, nunca el detalle. Síntoma: el detalle "no funciona" pero no hay error en consola. Fix: `exact` en la ruta del listado, o poné la ruta paramétrica antes (menos legible).

**3. Usar `<a href>` en vez de `<Link>` → recarga completa.** Un `<a href="/raffles">` hace que el navegador pida la página al servidor y recargue todo el árbol de React: perdés el estado en memoria y ves un parpadeo. Síntoma: la navegación "funciona" pero flashea y es lenta. Fix: `<Link to="...">` o `<NavLink>`. Es de los primeros que vas a cazar en código heredado.

**4. Comparar el `:id` string con un id número → detalle vacío.** `useParams` te da `id = "1"` (string). Si hacés `demoRaffles.find(r => r.id === id)` y `r.id` es `1` (número), `"1" === 1` es `false` y no encontrás nada. Síntoma: "no existe la rifa" aunque exista. Fix: convertí con `Number(id)` (lo hicimos en `findRaffle`). Este bug es tan común que lo centralizamos a propósito.

### Pieza forense de esta fase: componente que no re-renderiza — cómo saber por qué

El síntoma más frustrante del principiante-en-React-legacy: *"cambié algo y la pantalla no se actualiza"*. En esta fase todavía no hay store, así que las causas están acotadas y son perfectas para entrenar el ojo. Un componente de React re-renderiza cuando **cambia su estado**, **cambian sus props**, o **su padre re-renderiza**. Si no pasa ninguna de las tres, no se pinta de nuevo — por más que vos hayas "cambiado" algo.

El caso típico acá: editás el array `demoRaffles` en `mock/raffles.js` mientras la app corre, y el listado no cambia. ¿Bug de React? No. O el hot-reload no recargó el módulo, o —más educativo— estás mutando el array en vez de reemplazarlo y nada le avisa a React que redibuje. React no observa objetos: reacciona a cambios de referencia en estado/props. Un array hardcodeado que mutás a mano no dispara nada.

Cómo diagnosticarlo con **React DevTools** (que instalaste en Fase 0):

1. Abrí la pestaña **Components**, seleccioná el componente que "no se actualiza" (por ejemplo `RaffleDetailPage`).
2. Mirá sus **props** y su **hooks/state** en el panel derecho. ¿El valor que esperás que cambie está ahí? ¿Con qué valor?
3. Activá **"Highlight updates when components render"** (en las opciones de DevTools). Cuando algo re-renderiza, se pinta un borde de color. Navegá y observá: si al cambiar de ruta el componente **no** se enciende, es que no está recibiendo props nuevas ni cambió su estado.
4. Para `RaffleDetailPage`: navegá de `/raffles/1` a `/raffles/2`. El `id` de `useParams` cambia, el componente se re-renderiza, se enciende el borde. Si **no** cambia, revisá que el `:id` esté bien en la ruta y que no estés cacheando la rifa en un estado que nadie actualiza.

> ⚠️ Rompé a propósito para aprender: en `RaffleDetailPage`, guardá la rifa en un `useState` inicializado con `findRaffle(id)` **sin** un `useEffect` que lo actualice cuando cambia `id`. Ahora navegá de `/raffles/1` a `/raffles/2`: la URL cambia, pero el detalle sigue mostrando la rifa 1. El componente **sí** re-renderiza, pero el estado se inicializó una vez y nadie lo refresca. Con DevTools vas a ver el `id` de params en 2 y el estado de la rifa en 1 — la foto exacta del bug. Es el germen del clásico "los datos viejos se quedan pegados" que vas a ver en serio con el store más adelante.

---

## 🧪 7. Ejercicios (30)

Trabajá sobre la app de la fase. Varios son de diagnóstico: te entrego algo roto y tenés que localizar el porqué, no solo construir. Anclá todo al dominio de rifas. Respetá la convención de idioma: identificadores en inglés, textos de UI y comentarios en español.

**🟢 Fácil (1–8)**

1. Agregá una ruta `/about` con un componente `AboutPage` que muestre un párrafo sobre la plataforma de rifas. Sumala al navbar (el link visible dice "Acerca").
2. Cambiá el `NavLink` del brand para que solo esté activo en `/raffles` exacto y no dentro de `/raffles/1` (pista: `exact`).
3. Agregá una cuarta rifa hardcodeada a `demoRaffles` y verificá que aparece en el listado sin tocar nada más.
4. En `RaffleDetailPage`, mostrá también el `basePrize` formateado con `toLocaleString('es-CO')`.
5. Cambiá el botón "← Volver" para que use `history.push('/raffles')` en vez de `goBack()`. Describí en un comentario la diferencia de comportamiento.
6. Agregá un `<Link>` desde el `DashboardPage` placeholder hacia `/raffles`.
7. Hacé que el 404 muestre además el `location.search` (la query string) si existe. Probá con `/nada?x=1`.
8. En el navbar, agregá un badge con la cantidad total de rifas (`demoRaffles.length`).

**🟡 Intermedio (9–17)**

9. Agregá una ruta anidada `/raffles/:id/participants` que muestre los participantes de esa rifa (hardcodeá la relación). Usá `useParams` para leer el `id`.
10. Convertí `ParticipantsPage` de funcional a **class component con `withRouter`**, solo para practicar el estilo legacy. Dejá el funcional comentado al lado.
11. Hacé que al hacer click en una rifa con `status: 'draft'`, en vez de ir al detalle, muestre un `alert` de "rifa en borrador". Lógica en `RaffleListPage`.
12. Agregá un filtro de rifas por estado en el listado, controlado por query string (`/raffles?status=open`). Leé el filtro con `location` — pero ojo, `RaffleListPage` es clase: resolvé con `this.props.location`.
13. Creá un `<Redirect>` de `/home` hacia `/raffles`.
14. En `RaffleDetailPage`, agregá un botón "Siguiente rifa" que navegue a `/raffles/{id+1}` con `history.push`. Manejá el caso de que no exista.
15. Hacé que el `NavLink` de Dashboard tenga un `activeClassName` personalizado y estilalo distinto al resto en tu Sass (sumá un token a `_tokens.scss`, no hardcodees el color).
16. Agregá un breadcrumb (miga de pan) en `RaffleDetailPage`: "Rifas / {name}". El "Rifas" es un `Link` al listado.
17. Extraé la grilla de tarjetas de `RaffleListPage` a un componente `RaffleGrid` que reciba las rifas por props y un callback `onSelect`. `RaffleListPage` queda como contenedor.

**🟠 Difícil (18–24)**

18. Te paso `RaffleListPage` sin `withRouter` pero llamando `this.props.history.push(...)`. Reproducí el error exacto (mensaje en consola), explicá por qué pasa, y arreglalo con el fix mínimo.
19. En el `AppRouter`, alguien puso `<Route path="/raffles/:id" />` **antes** que `<Route exact path="/raffles" />`. Reproducí el síntoma, explicá el orden de match en `Switch`, y corregí.
20. Diagnóstico: te entrego una versión donde el detalle muestra siempre "No existe la rifa" aunque el id sea válido. La causa está en la comparación de tipos (`raffle.id === id` con `id` string). Localizala con React DevTools (mirando params vs el dato) y arreglala.
21. Implementá el bug de la caja ⚠️ de la sección forense (rifa cacheada en `useState` sin `useEffect`) y después arreglalo correctamente con un `useEffect` que dependa de `id`. Explicá por qué re-renderizar no bastaba.
22. Agregá una ruta con parámetro opcional `/raffles/:id/:tab?` donde `tab` puede ser `info` o `participants`. Renderizá contenido distinto según `tab`, con `info` por defecto.
23. Hacé que el navbar resalte "Rifas" también cuando estás en `/raffles/1` (detalle), usando `isActive` de `NavLink` con una función custom.
24. Diagnóstico: te entrego la app con un `<a href="/participants">` en el navbar en vez de `Link`. Describí cómo lo detectás (qué observás en la Network tab al hacer click) y por qué es un problema en una SPA.

**🔴 Muy difícil (25–30)**

25. Implementá un componente `ScrollToTop` que, usando `useLocation` y `useEffect`, lleve el scroll al tope cada vez que cambia la ruta. Explicá por qué el router no lo hace solo.
26. Reproducí y explicá el problema de refrescar (F5) en `/raffles/1` cuando la app se sirve como archivos estáticos sin configuración de fallback: por qué en `npm start` funciona y en un server estático da 404. (Pista: history mode vs el servidor.) Documentá la solución conceptual sin implementarla — es tema de deploy, no de esta fase.
27. Construí un HOC propio `withRaffle(Component)` que inyecte la rifa correspondiente al `:id` como prop, replicando la idea de `withRouter`. Usalo en un componente de clase.
28. Diagnóstico forense completo: te entrego la app donde al navegar entre `/raffles/1` y `/raffles/2` el detalle no cambia. Puede ser el bug de `useState` sin `useEffect`, o un `key` mal puesto. Distinguí cuál de las dos causas es, usando "Highlight updates" de DevTools, y documentá el razonamiento como mini post-mortem (síntoma, evidencia, causa, fix).
29. Hacé que `RaffleListPage` (la clase) navegue programáticamente respetando un query param de origen: si venís de `/dashboard`, el detalle debe tener un botón "volver al dashboard"; si venís del listado, "volver a rifas". Pasá el origen por `location.state` en el `history.push`.
30. Integrá las 5 rutas en un objeto de configuración `routes = [{ path, component, exact }]` y generá los `<Route>` con un `.map()` dentro del `Switch`. Cuidá que `exact` y el orden se respeten. Explicá qué ganás y qué perdés versus escribir las rutas a mano.

**🔥 Opcionales**

- 🔥 Migrá `RaffleListPage` de class + `withRouter` a funcional + `useHistory`. Compará ambas versiones lado a lado y anotá qué desaparece (el HOC, el `this`). Es un ensayo del apéndice A5.
- 🔥 Reemplazá el layout hecho a mano por uno con rutas anidadas dentro de un componente `AppLayout` que use render props. Compará legibilidad.
- 🔥 Probá lazy-loading de `DashboardPage` con `React.lazy` + `Suspense` y explicá qué implica en React 16.14 (Suspense para code-splitting sí existe; para data no).

---

## 📚 8. Referencias

**Documentación oficial**

- React Router 5 — API web completa: https://v5.reactrouter.com/web/guides/quick-start (esta es la v5; **no** uses reactrouter.com a secas, que hoy documenta v6/v7).
- `withRouter`: https://v5.reactrouter.com/web/api/withRouter
- Hooks de router (`useParams`, `useHistory`, `useLocation`): https://v5.reactrouter.com/web/api/Hooks
- React 16 (componentes, ciclo de vida de clases): https://legacy.reactjs.org/docs/react-component.html
- React DevTools: https://legacy.reactjs.org/blog/2019/08/15/new-react-devtools.html
- Bootstrap 4.6 navbar: https://getbootstrap.com/docs/4.6/components/navbar/

**Video / apoyo**

- Cualquier "React Router v5 crash course" en YouTube sirve como refuerzo visual, pero verificá que sea **v5** y no v6 (el cambio de API es grande). Buscá por "react router dom 5" explícito.

> ⚠️ Las URLs, títulos y contenidos de referencias pueden estar desactualizados o haber cambiado de lugar; verificalos al abrirlos. Sobre todo con React Router: mucho material online es de v6 y **no aplica** a nuestro código. Si un snippet usa `<Routes>`, `element={}` o `useNavigate`, es v6 — descartalo para esta fase.

**Orden de lectura sugerido:** Quick start de v5 (para el mapa mental de `BrowserRouter`/`Switch`/`Route`) → la página de Hooks (para `useParams`/`useHistory`) → `withRouter` (para entender el lado de las clases) → volvé al código de `AppRouter` y `RaffleListPage` y releélo con eso fresco.

---

## 🚀 9. Cierre y conexión con la Fase 2

Tenés un esqueleto navegable: cinco rutas, un layout persistente con navbar, el detalle de rifa leyendo su `:id`, y un 404 que te dice qué falló. Viste convivir una clase con `withRouter` y un funcional con hooks de router — la mezcla exacta que heredás en el sistema real. Reusaste `RaffleCard` de Fase 0 sin reescribirlo, y arrancaste el track forense entrenando el ojo para el "no se re-renderiza", que es la madre de muchos bugs que vienen.

Pero todo es público y todo es mentira: cualquiera entra a cualquier ruta, y los datos son un array hardcodeado que nadie comparte entre componentes. La **Fase 2** ataca la primera mitad de eso: **autenticación mínima**. Ahí aparece el primer Redux del curso —un `authSlice`—, un login mock, el componente `PrivateRoute` que va a envolver a estas mismas rutas para cerrarles el paso a los no logueados, y el primer interceptor de axios. Vas a ver por qué el router y el store se necesitan mutuamente, y cómo una ruta "protegida" es solo una `Route` con una guarda adentro.

> **La señal de que quedó bien:** si navegás toda la app sin un solo parpadeo de recarga, si el navbar te dice siempre dónde estás, y si cuando algo no se ve sabés en menos de un minuto si es la ruta, el `exact`, el `Switch` o el dato — entonces la estructura está firme y podés construir auth encima sin miedo.
