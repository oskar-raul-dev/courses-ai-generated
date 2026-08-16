# 💥 NX2 — Hidratación y `window is not defined`

> El error que define el framework. Y la fase que define la ruta.

> 🅝 **Ruta Nuxt.** No hay núcleo común aquí: esta fase **no existe** en Q ni en
> VU. Donde ellos migran un formulario, tú descubres que tu código corre en dos
> sitios distintos y que hasta hoy solo probaste uno. Si vienes de leer que "X2
> es migrar el CRUD", olvídalo: en Nuxt migrar el CRUD no enseña nada. El
> formulario de F5 se queda **exactamente igual**. Lo que cambia es dónde vive.

---

## 🎯 Propósito

Poner el dashboard de F4 en Nuxt, arrancar el servidor, y **verlo reventar en la
primera línea del log** con un `window is not defined` que no habías visto nunca
en cinco años de Vue.

Y a partir de ahí, la fase entera:

- entender **por qué** revienta — no como accidente, sino como consecuencia
  directa de que tu componente ahora se ejecuta primero en un **Node sin DOM**;
- aprender **dónde va cada cosa**: qué corre en el servidor, qué corre solo en el
  cliente, y cómo Nuxt te da las herramientas para decidirlo (`mounted`,
  `process.client`, `<client-only>`);
- meterte de lleno en el concepto que cambia el modelo mental de todo el curso —
  la **hidratación** — y provocar tú mismo, a mano, el error de hidratación
  silencioso que te va a perseguir en producción;
- y **pagar la deuda de NX1** 💸: la auth de F2 usa `localStorage`, `localStorage`
  no existe en el servidor, y por lo tanto el login **se rompe de raíz**. La
  solución no es un parche: son **cookies**.

> La regla de la fase: en Nuxt universal, **`created()` es territorio compartido y
> `mounted()` es territorio cliente**. Todo lo que toque `window`, `document`,
> `localStorage` o `navigator` vive en `mounted()` — o no vive.

Y al final, el remate: **vuelve a correr la suite de NX0. Está en verde. Y la app
está rota.** Esa contradicción es la lección que abrió la ruta, ahora cobrada.

---

## ✅ Qué queda listo al terminar

- el dashboard de F4 viviendo en `pages/tickets/index.vue`, renderizado **en el
  servidor** y funcionando en el cliente;
- el error `window is not defined` **reproducido, leído y entendido** — con su
  stack trace, sabiendo señalar la línea culpable;
- la regla de oro del ciclo de vida dual aplicada: nada que toque el navegador en
  `created()`; todo eso movido a `mounted()` o detrás de `process.client`;
- `<client-only>` usado donde toca (chart.js, socket.io) y **entendido dónde es
  una trampa**;
- un **error de hidratación provocado a propósito** (`Date.now()` en el template),
  visto en consola, y luego arreglado — para saber reconocerlo cuando aparezca
  solo;
- la **auth de F2 migrada a cookies** 💸: `localStorage` fuera, `cookie-universal-nuxt`
  dentro, el interceptor de axios reescrito como plugin con acceso al contexto;
- y la comprensión, incómoda pero necesaria, de que **NX0 tenía un agujero** y de
  que esta fase lo tapa **solo a medias**.

## 🚫 Qué NO entra todavía

- **`asyncData` / `fetch` / `nuxtServerInit`.** El dashboard de esta fase sigue
  cargando datos en `mounted()`, igual que en F4 — feo para SSR, pero es a
  propósito: aquí arreglamos **dónde corre el código**, no **quién carga los
  datos**. Eso es NX3, y es una decisión con criterio, no un `mounted` más;
- SSR "de verdad" del listado: hoy el HTML del servidor llega **con el spinner de
  carga**, no con los tickets. Lo notarás. Es la puerta a NX3;
- middleware de auth server-side robusto (los guards de F2 en `middleware/`
  aterrizan del todo en NX3);
- meta tags, `head()`, rutas anidadas, `validate()` — todo eso es NX4;
- **el formulario del CRUD (F5).** No se toca. Nada de `:rules`, nada de sacar
  vuelidate. Eso es Q2/VU2, **no esta ruta**. Si te descubres editando un
  `<b-form>`, te equivocaste de curso.

---

## 🧠 Concepto 1: tu código ahora corre dos veces, en dos mundos

En el tronco (F0–F11) y en las rutas Q/VU, tu app es una **SPA**: un `index.html`
casi vacío, y todo el trabajo lo hace el navegador. `main.js` arranca Vue **en el
cliente**, y punto. `window` siempre existe porque **solo hay un sitio donde tu
código corre: el navegador.**

Nuxt en modo `universal` (el que elegimos en NX1) rompe esa suposición de raíz:

```
        ┌─────────────────── SERVIDOR (Node) ───────────────────┐
Petición │  1. Nuxt ejecuta tu componente                        │
  GET   →│  2. Corre beforeCreate() y created()                  │
/tickets │  3. Renderiza el HTML final                           │  →  HTML
        │     ⚠️ AQUÍ NO HAY window, document, localStorage      │
        └───────────────────────────────────────────────────────┘
                                    │
                                    ▼ (el navegador recibe el HTML pintado)
        ┌─────────────────── CLIENTE (navegador) ───────────────┐
        │  4. El navegador muestra el HTML (rápido, ya viene)   │
        │  5. Vue arranca OTRA VEZ sobre ese HTML                │
        │  6. Corre beforeCreate() y created()  ← ¡DE NUEVO!    │
        │  7. Corre mounted()  ← ESTA VEZ SÍ, y solo aquí       │
        │     ✅ AQUÍ SÍ hay window, document, etc.             │
        └───────────────────────────────────────────────────────┘
```

Dos consecuencias que hay que interiorizar antes de tocar una línea:

1. **`created()` se ejecuta DOS VECES.** Una en Node, una en el navegador. Si
   metes un `console.log` en `created()`, lo verás en la terminal **y** en la
   consola del navegador. No es un bug. Es el modelo.

2. **`mounted()` se ejecuta UNA VEZ, solo en el cliente.** El servidor nunca monta
   nada en un DOM porque **no tiene DOM**. Por eso `mounted()` es el único sitio
   seguro para tocar el navegador.

> Regla de oro, tatuáatela: **si lo toca el navegador, va en `mounted()`.**
> `window`, `document`, `localStorage`, `sessionStorage`, `navigator`, cualquier
> API del DOM, cualquier librería que por dentro las use (chart.js, socket.io) —
> todas viven en `mounted()` o detrás de un flag `process.client`. En `created()`
> van a estallar en el servidor.

### Qué NO existe en el servidor

Node es JavaScript, sí. Pero **no es un navegador**. No tiene:

| Global del navegador | ¿En Node (servidor)? | Qué usar en su lugar |
|---|---|---|
| `window` | ❌ no existe | `mounted()` o `process.client` |
| `document` | ❌ no existe | `mounted()` |
| `localStorage` / `sessionStorage` | ❌ no existen | **cookies** (ver Concepto 3) |
| `navigator` | ❌ no existe | `mounted()`, y con cuidado |
| `location` | ⚠️ usar `this.$route` / contexto | `this.$route`, `context.redirect` |

`process`, en cambio, **sí** existe (es de Node) — y Nuxt lo aprovecha para darte
dos flags:

```js
process.server   // true si el código corre ahora mismo en Node
process.client   // true si corre ahora mismo en el navegador
```

Son la escotilla de emergencia rápida: `if (process.client) { ... }` blinda un
bloque para que solo corra donde hay `window`. Útil, pero no abuses — si TODO tu
componente va detrás de `process.client`, estás haciendo una SPA cara (ver
Concepto 2).

---

## 🧠 Concepto 2: `<client-only>`, la escotilla — y la trampa

Nuxt trae un componente contenedor: **`<client-only>`** (en Nuxt 2.15 también
existe el alias legacy `<no-ssr>`, que verás en bases más viejas). Lo que envuelve
**no se renderiza en el servidor**: se salta en el HTML del server y aparece solo
cuando Vue arranca en el cliente.

```vue
<!-- El gráfico de F7 usa chart.js, que necesita un <canvas> y window.
     En el servidor no hay ninguno de los dos → lo aislamos del SSR. -->
<client-only>
  <tickets-chart :tickets="tickets" />
</client-only>
```

Es la herramienta correcta para tres casos concretos:

- **librerías que tocan el DOM directamente**: chart.js (necesita `<canvas>` +
  `window`), cualquier cosa con `document.getElementById`;
- **componentes que dependen de tamaño de ventana / scroll / geolocalización**;
- **widgets de terceros** que asumen navegador (mapas, editores WYSIWYG legacy).

### 🪤 Dónde es una trampa

`<client-only>` **desactiva el SSR de lo que envuelve**. Ese es su trabajo. El
problema es la tentación:

> "El dashboard entero peta en el servidor… ¿y si lo envuelvo TODO en
> `<client-only>` y ya?"

Si haces eso, **has construido una SPA** — pero una SPA que además arrastra el
coste de un servidor Node renderizando una página en blanco que el cliente tira a
la basura. Pagas SSR y no lo usas. Es lo peor de los dos mundos.

```
❌ Antipatrón: toda la página en client-only
   → el servidor renderiza <div></div> vacío
   → el navegador lo recibe, lo tira, y monta todo desde cero
   → SEO cero, TTFB peor que una SPA normal, y encima mantienes un servidor

✅ Uso correcto: client-only quirúrgico
   → el servidor renderiza la tabla, los badges, el layout (todo lo que puede)
   → SOLO el <canvas> del gráfico se salta el SSR
   → el 95% de la página llega pintada; el 5% que necesita window espera al cliente
```

La regla: **`<client-only>` envuelve la pieza que no puede vivir sin navegador, no
la página que no quieres pensar.** Si te descubres envolviendo el `<template>`
raíz, para y arregla el componente concreto que revienta.

---

## 🧠 Concepto 3 (el central): HIDRATACIÓN

Aquí está el modelo mental nuevo, el que Q y VU nunca te dan.

El servidor te manda **HTML ya pintado** (rápido de ver, bueno para SEO). Pero ese
HTML está muerto: no reacciona a clics, no tiene reactividad, no es Vue todavía —
es texto. Entonces el navegador descarga el JS, arranca Vue **encima de ese HTML**,
y le da vida: engancha los listeners, activa la reactividad, conecta el virtual
DOM al DOM real que ya estaba ahí.

Ese proceso de "revivir el HTML muerto del servidor" se llama **hidratación**.

```
SERVIDOR                          CLIENTE
────────                          ───────
render → HTML "muerto"    ──►    el navegador lo pinta (ya se ve)
                                          │
                                          ▼
                                  Vue arranca y HIDRATA:
                                  "¿el HTML que hay coincide con
                                   el que YO habría generado?"
                                          │
                        ┌─────────────────┴─────────────────┐
                        ▼                                     ▼
                  ✅ COINCIDE                          ❌ NO COINCIDE
             Vue reutiliza el DOM               Vue tira el HTML del server
             existente. Perfecto.               y re-renderiza en cliente.
             Rápido y sin parpadeo.             → parpadeo, o peor: el DOM
                                                  se rompe EN SILENCIO.
```

### La condición que no puedes violar

Para que la hidratación funcione, **el HTML que genera el servidor y el que
generaría el cliente tienen que ser idénticos.** Byte a byte, en la práctica.

¿Y qué hace que difieran? Cualquier cosa **no determinista** que se evalúe en el
render: algo que dé un valor distinto en el servidor (a las 10:00:00.000) que en
el cliente (250 ms después, a las 10:00:00.250).

Los dos culpables clásicos, los que vas a ver en bases legacy reales:

```html
<!-- 💣 Date.now() / new Date(): el servidor pinta una hora, el cliente otra -->
<span>Generado a las {{ new Date().toLocaleTimeString() }}</span>

<!-- 💣 Math.random(): el servidor pinta un número, el cliente otro -->
<div :class="'theme-' + Math.floor(Math.random() * 3)">
```

En ambos, servidor y cliente pintan **distinto**, la hidratación detecta el
desajuste, y Vue tira el HTML del servidor. Con suerte lo ves como un parpadeo o
un warning en consola (`The client-side rendered virtual DOM tree is not matching
server-rendered content`). **Sin suerte, el DOM se rompe en silencio**: un
atributo se queda pegado, un listener no se engancha, y tienes un bug que solo
aparece en producción con SSR y jamás en tu `npm run dev` de una SPA.

> Vas a **reproducir esto a mano** en el código de la fase. Provocarlo una vez, con
> intención, vale más que diez párrafos: cuando lo veas aparecer solo dentro de
> seis meses, lo reconocerás en treinta segundos en vez de en dos días.

Solución cuando de verdad necesitas algo no determinista (una hora, un random): no
lo pintes en el render. Calcúlalo en **`mounted()`** (solo cliente → no hay nada
del servidor con qué chocar) y mételo en `data`.

---

## 🧠 Concepto 4: por qué la auth de F2 se rompe (y por qué son cookies) 💸

Esta es la deuda que NX1 dejó abierta con nombre y apellido. Toca cobrarla.

Recuerda F2. El token de sesión vivía en `localStorage`, y **tres sitios distintos
lo leían**:

```js
// store/modules/auth.js  →  al construir el estado inicial
var storedSession = authService.getStoredSession();  // lee localStorage

// router/index.js  →  el guard
var token = localStorage.getItem("token");           // lee localStorage

// services/apiClient.js  →  el interceptor
var token = localStorage.getItem("token");           // lee localStorage
```

En una SPA los tres corren en el navegador, donde `localStorage` existe. **En Nuxt
universal, los tres corren primero en el servidor** — el estado del store se
inicializa en Node, el middleware corre en Node, el interceptor de axios corre en
Node cuando `asyncData` pida datos. Y en Node:

```
ReferenceError: localStorage is not defined
```

No es un bug arreglable con un `if`. Es **arquitectónico**: el mecanismo entero de
sesión asumía "un solo mundo, el navegador". Ahora hay dos.

### Por qué cookies y no otra cosa

El servidor necesita saber **quién es el usuario** en el momento de renderizar
(para pintar el header con su nombre, para decidir si redirige al login). ¿Cómo le
llega esa info al servidor? Con la petición HTTP. ¿Qué viaja en cada petición HTTP
del navegador al servidor, automáticamente? **Las cookies.**

```
localStorage:  vive SOLO en el navegador. El servidor NUNCA lo ve. ❌
cookie:        viaja en CADA request. El servidor la lee. El cliente también. ✅
```

Por eso la sesión de una app SSR va en cookies: es el **único almacén que ambos
mundos comparten**. En Nuxt 2 el paquete de la época es
`cookie-universal-nuxt`, que da una API de cookies que funciona igual en servidor
(`this.$cookies` con acceso a la request/response) y en cliente.

> 💸 **Nota honesta de seguridad, heredada de F2:** meter el token en una cookie
> legible por JS (`httpOnly: false`) tiene el **mismo** problema de XSS que
> `localStorage`. La cookie *bien hecha* de producción es `httpOnly` + `secure` +
> `sameSite`, y entonces **el JS del cliente no la puede leer** — solo el servidor.
> Eso cambia el diseño (el interceptor del cliente ya no adjunta el token a mano;
> el navegador la manda solo). En esta fase hacemos la versión legible por
> simetría con F2 y para que el código quepa; la `httpOnly` de verdad es el
> ejercicio 🔴 25. *"En producción la cookie de sesión es httpOnly y la pone el
> backend en el login; aquí la ponemos desde el front por didáctica."*

---

## 💻 Código de la fase

### El punto de partida: el dashboard, tal cual, reventando

Copia `TicketsView.vue` de F4 a `pages/tickets/index.vue` **sin cambiar nada** y
arranca `npm run dev`. Vas a ver esto en la **terminal** (no en el navegador — esa
es la primera pista de que algo cambió):

```
 ERROR  window is not defined

  at pages/tickets/index.vue:XX
  at Object.created (pages/tickets/index.vue)
  at callHook (node_modules/vue/dist/vue.runtime.common.dev.js)
  at Watcher.get (...)
  ...
  at renderToString (node_modules/vue-server-renderer/...)
```

> 🔎 **Qué hace este stack trace.** Léelo de abajo arriba: `renderToString` es Nuxt
> pidiéndole al servidor que convierta tu componente en HTML. Sube y encuentras
> `callHook → created`. Es decir: **el error salió en `created()`, ejecutándose en
> el servidor.** La línea `XX` es donde tu código tocó `window`. Si el mismo
> componente funcionaba en F4, es porque en F4 `created()` solo corría en el
> navegador. Ahora corre en Node primero, y Node no tiene `window`.

*(Si tu `TicketsView` de F4 no toca `window` directamente, lo hará en cuanto le
enganches el gráfico de F7 o el socket de F8, o en cuanto un ejercicio de F4 —el
del `setInterval`, el de leer scroll— lo haga. El patrón es el mismo. Y si de
verdad ninguna línea toca `window`, mete tú una a propósito para verlo:
`created() { console.log(window.innerWidth); }` y arranca. Ese es el punto.)*

### ✅ El arreglo: mover lo del navegador a `mounted()`

```vue
<!-- pages/tickets/index.vue -->
<script>
import TicketsTable from "~/components/tickets/TicketsTable.vue";
import TicketsSummary from "~/components/tickets/TicketsSummary.vue";
import ticketService from "~/services/ticketService";

export default {
  name: "TicketsPage",
  components: { TicketsTable, TicketsSummary },
  data: function () {
    return {
      tickets: [],
      search: "",
      statusFilter: "",
      loading: false,
      error: ""
    };
  },
  computed: {
    filteredTickets: function () {
      var self = this;
      var term = this.search.trim().toLowerCase();
      return this.tickets.filter(function (t) {
        var matchesSearch = !term || t.title.toLowerCase().indexOf(term) !== -1;
        var matchesStatus = !self.statusFilter || t.status === self.statusFilter;
        return matchesSearch && matchesStatus;
      });
    }
  },
  // 🔎 mounted() SOLO corre en el cliente. Por eso loadTickets() —que dispara
  //    axios— y cualquier cosa que toque el navegador van aquí, NO en created().
  //    (Esto es feo para SSR: el servidor manda el spinner, no los tickets.
  //     Lo arreglamos con asyncData en NX3. Hoy solo evitamos que reviente.)
  mounted: function () {
    this.loadTickets();
  },
  methods: {
    loadTickets: function () {
      var self = this;
      this.loading = true;
      this.error = "";
      ticketService
        .getTickets({ _sort: "createdAt", _order: "desc" })
        .then(function (tickets) { self.tickets = tickets; })
        .catch(function () {
          self.error = "No se pudieron cargar los tickets. ¿Está corriendo la Mock API?";
        })
        .finally(function () { self.loading = false; });
    },
    clearFilters: function () {
      this.search = "";
      this.statusFilter = "";
    },
    goToDetail: function (ticket) {
      this.$router.push("/tickets/" + ticket.id);
    }
  }
};
</script>
```

> ✅ **Buenas prácticas.** Nada en `created()` que huela a navegador. Si necesitas
> una decisión temprana (antes del render) que dependa de datos, esa NO va en
> `mounted()` sino en `asyncData` — pero eso es NX3. Aquí, la regla mínima: mueve a
> `mounted()` y respira.

### El error de hidratación, provocado a mano

Antes de arreglar nada más, **rompe la hidratación a propósito** para verla fallar.
Añade esto al `<template>` de la página:

```html
<!-- 💣 A PROPÓSITO: esto pinta distinto en servidor y cliente -->
<p class="text-muted small">Dashboard cargado a las {{ ahora }}</p>
```

```js
// y en el componente:
computed: {
  ahora: function () {
    return new Date().toLocaleTimeString();  // 💣 no determinista
  }
}
```

Arranca, abre la consola del navegador y verás el warning:

```
[Vue warn]: The client-side rendered virtual DOM tree is not matching
server-rendered content. This is likely caused by incorrect HTML markup,
for example nesting block-level elements inside <p>, or missing <tbody>.
Bailing hydration and performing full client-side render.
```

> 🔎 **Qué pasó.** El servidor renderizó `10:00:00`. Para cuando el navegador
> hidrató, eran `10:00:00` + 300 ms → `10:00:01`. No coinciden → Vue **abandona la
> hidratación** (*"Bailing hydration"*) y re-renderiza toda la página en cliente.
> Perdiste el SSR de esa página entera por un reloj en el template.

El arreglo: si de verdad quieres mostrar la hora, que la ponga el cliente.

```js
data: function () {
  return { ahora: "" };  // el servidor pinta vacío
},
mounted: function () {
  this.ahora = new Date().toLocaleTimeString();  // el cliente la rellena
  this.loadTickets();
}
```

Ahora servidor y cliente **coinciden** (ambos pintan vacío en el render inicial), y
el cliente actualiza el texto tras montar. Cero warning.

### chart.js (F7) y socket.io (F8): mismo mal, misma escotilla

El gráfico de F7 instancia chart.js sobre un `<canvas>` — necesita `window` y un
nodo del DOM. El socket de F8 abre una conexión con `io()` que asume navegador.
Ambos revientan en el servidor por lo mismo. Dos arreglos, según el caso:

```vue
<!-- Opción A: <client-only> para el componente entero del gráfico -->
<client-only>
  <tickets-chart :tickets="tickets" />
</client-only>
```

```js
// Opción B: para el socket, no hay componente que envolver → process.client
//           dentro de mounted() (que ya es cliente, pero explícito no sobra
//           si el componente pudiera montarse en algún flujo raro)
mounted: function () {
  if (process.client) {
    this.socket = io("http://localhost:4000");
    this.socket.on("ticket:new", this.onNewTicket);
  }
},
beforeDestroy: function () {
  if (this.socket) this.socket.close();  // limpiar SIEMPRE
}
```

> 🔎 Regla rápida: **¿es un componente visual que necesita el DOM?** → `<client-only>`.
> **¿es lógica (un socket, un timer, leer `navigator`)?** → `mounted()` +
> `process.client`, y limpia en `beforeDestroy`.

### La auth a cookies 💸

**1. Instalar y registrar el módulo** (`nuxt.config.js`):

```js
// nuxt.config.js
export default {
  modules: [
    "@nuxtjs/axios",
    "cookie-universal-nuxt"   // ← da this.$cookies en servidor Y cliente
  ]
};
```

**2. El `authService` deja de hablar con `localStorage`.** Ya no persiste él la
sesión (no puede: no sabe en qué mundo está). Solo valida:

```js
// services/authService.js
var MOCK_USER = { username: "admin", password: "1234", name: "Usuario Demo" };

function login(username, password) {
  if (username === MOCK_USER.username && password === MOCK_USER.password) {
    return {
      token: "mock-jwt-token-123",
      user: { username: MOCK_USER.username, name: MOCK_USER.name }
    };
  }
  throw new Error("Credenciales inválidas");
}

export default { login: login };
// saveSession/clearSession/getStoredSession SE VAN: los mata el cambio de mundo.
```

**3. El interceptor de axios se vuelve un plugin con contexto.** En F2 el
interceptor leía `localStorage` a pelo. Ahora vive en `plugins/` y recibe el
**contexto de Nuxt**, desde donde alcanza `$cookies` y el `$axios` de fábrica:

```js
// plugins/axios-auth.js
export default function (context) {
  var $axios = context.$axios;
  var $cookies = context.app.$cookies;   // funciona en servidor Y cliente

  // 🔎 En el servidor, $cookies lee la cookie que vino en la request.
  //    En el cliente, lee la del navegador. El MISMO código, dos mundos.
  $axios.onRequest(function (config) {
    var token = $cookies.get("token");
    if (token) {
      config.headers.Authorization = "Bearer " + token;
    }
    return config;
  });
}
```

```js
// nuxt.config.js  →  registrarlo
export default {
  modules: ["@nuxtjs/axios", "cookie-universal-nuxt"],
  plugins: ["~/plugins/axios-auth.js"]
};
```

**4. El módulo Vuex de auth guarda/limpia la cookie** (a través del contexto, no
de `localStorage`). En un store de Nuxt, `this` dentro de una action **es el
propio store**, y ahí `cookie-universal-nuxt` deja colgado `this.$cookies` —el
mismo objeto que funciona en servidor y en cliente:

```js
// store/modules/auth.js
import authService from "~/services/authService";

export const actions = {
  login: function (context, credentials) {
    // authService solo VALIDA (ya no persiste nada: no sabe en qué mundo está)
    var session = authService.login(credentials.username, credentials.password);
    // this.$cookies: inyectado por cookie-universal-nuxt, sirve en ambos mundos
    this.$cookies.set("token", session.token, { path: "/" });
    this.$cookies.set("user", session.user, { path: "/" });
    context.commit("SET_SESSION", session);
  },
  logout: function (context) {
    this.$cookies.remove("token");
    this.$cookies.remove("user");
    context.commit("CLEAR_SESSION");
  }
};
```

> ⚠️ **Esto cubre el flujo del cliente** (login/logout disparados por el usuario).
> Falta la otra mitad: cuando el servidor renderiza una recarga, el store nace
> **vacío** y hay que **rehidratar la sesión leyendo la cookie de la request**
> antes de que corra cualquier guard. Ese arranque server-side es
> `nuxtServerInit`, y lo cerramos en **NX3** (ejercicio 11). Por ahora, tras un
> login la sesión persiste en cliente; la recarga con SSR "completo" es deuda
> abierta de una fase.

> 🔎 **Lo que cambió de fondo:** en F2 la sesión vivía en un almacén que solo el
> cliente veía. Ahora vive en uno que **viaja en cada request**, y por eso el
> servidor puede renderizar la página **sabiendo ya quién eres**. Ese es el
> desbloqueo real de la migración a cookies — no es "otro storage", es "el storage
> que el servidor también lee".

---

## ⚠️ Errores comunes

- **dejar `loadTickets()` en `created()`** "porque en F4 estaba ahí": en F4
  `created`/`mounted` daba casi igual porque solo había cliente. Aquí `created`
  corre en Node y si algo de la cadena toca `window`, revienta;
- **envolver el `<template>` raíz entero en `<client-only>`** para que deje de
  petar: funciona, y acabas de convertir tu app SSR en una SPA con un servidor
  Node de adorno. Aísla la pieza culpable, no la página;
- **`Date.now()`, `Math.random()`, `new Date()` en el template o en un computed que
  se renderiza**: hidratación rota, a veces silenciosa. Va en `mounted()`;
- **asumir que `process.client` "arregla" un computed**: los computed se evalúan en
  el render, que corre en ambos mundos. `process.client` sirve en `mounted`/methods,
  no para blindar lo que pinta el template (para eso, `<client-only>` o dato en
  `mounted`);
- **seguir leyendo `localStorage` en el guard o el interceptor** tras migrar: son
  exactamente los tres puntos de F2 que hay que reescribir. Si dejas uno, revienta
  en el servidor la primera vez que corra allí;
- **cookie sin `path: "/"`**: se guarda con el path de la ruta actual y "desaparece"
  al navegar. Clásico de tarde perdida;
- **olvidar `beforeDestroy` en el socket**: en SSR + navegación cliente, los
  componentes se montan y desmontan más de lo que crees. Sin limpieza, fugas de
  conexión.

---

## 🧪 Ejercicios (26)

> Todos corren sobre `mini-jira-nx` (el proyecto Nuxt de NX1) con json-server en
> `:3000`. Recuerda: **el formulario de F5 no se toca en ningún ejercicio.** Si un
> ejercicio te lleva a editar `:rules` o vuelidate, lo entendiste mal.

**🟢 Fácil (1–7)**

1. Copia `TicketsView` de F4 a `pages/tickets/index.vue` sin tocar nada, arranca
   `npm run dev` y **provoca el error**. Pega el stack trace completo en un
   comentario y señala con una flecha la línea donde el servidor tocó el navegador.
2. Mete un `console.log("hola desde created")` en `created()` y otro
   `console.log("hola desde mounted")` en `mounted()`. Recarga la página y anota:
   ¿cuántas veces sale cada uno y **dónde** (terminal vs consola del navegador)?
3. Añade `<p>process.client vale: {{ esCliente }}</p>` con un computed que devuelva
   `process.client`. Míralo en el HTML fuente (Ctrl+U) y en la página ya cargada.
   ¿Por qué dicen cosas distintas?
4. Mueve `loadTickets()` de `created()` a `mounted()` y confirma que el dashboard
   deja de reventar. Anota en un comentario qué llega en el HTML del servidor
   (pista: abre Ctrl+U y busca una fila de ticket… no está).
5. Provoca un error de hidratación a mano con `{{ new Date().toLocaleTimeString() }}`
   en el template. Captura el warning de consola literal.
6. Arregla el ejercicio 5 moviendo la hora a `data` + `mounted()`. Confirma que el
   warning desaparece.
7. Envuelve un bloque cualquiera del dashboard en `<client-only>` y compruébalo en
   el HTML fuente: ese bloque **no está** en el HTML del servidor. Explica en una
   línea por qué.

**🟡 Intermedio (8–16)**

8. Instala y registra `cookie-universal-nuxt`. Desde `mounted()`, escribe una
   cookie `test` con `this.$cookies.set("test", "hola", { path: "/" })` y léela en
   DevTools → Application → Cookies. Prueba a quitar `path: "/"` y navega a
   `/tickets/1`: ¿sigue ahí?
9. Migra el interceptor de F2 a `plugins/axios-auth.js` usando `$cookies` en vez de
   `localStorage`. Verifica en la pestaña Network que el header `Authorization`
   sale en las peticiones a json-server.
10. Reescribe `store/modules/auth.js` para que `login`/`logout` usen `this.$cookies`
    en vez de `localStorage`. Borra `saveSession`/`getStoredSession` de
    `authService`.
11. Provoca `window is not defined` **a propósito** metiendo
    `created() { this.w = window.innerWidth; }`. Luego arréglalo de **dos formas
    distintas** (mover a `mounted`; envolver en `if (process.client)`) y comenta
    cuándo preferirías cada una.
12. Enchufa el gráfico de F7 (`TicketsChart` con chart.js) al dashboard. Verás que
    revienta en el servidor. Arréglalo con `<client-only>`. Confirma que la tabla
    **sí** sale en el HTML del servidor y el gráfico **no**.
13. Enchufa el socket de F8 en `mounted()` con `process.client` y limpia en
    `beforeDestroy`. Deja `console.log` en ambos y navega entrando y saliendo de
    `/tickets` tres veces: confirma que abres y cierras la conexión cada vez.
14. Crea un computed `saludo` que dependa de la hora del día ("Buenos días/tardes")
    calculada con `new Date().getHours()`. Compruébalo: ¿rompe la hidratación?
    ¿Por qué sí o por qué no depende de la hora a la que pruebes? Documenta el
    riesgo.
15. Añade un `<p v-if="process.server">Renderizado en servidor</p>` y otro con
    `v-if="process.client"`. Explica en un comentario por qué el usuario acaba
    viendo solo uno aunque el HTML del servidor traiga el otro.
16. Haz que el header muestre el nombre del usuario **leído de la cookie en el
    servidor**, de modo que salga ya pintado en el HTML fuente (Ctrl+U), sin
    parpadeo. Pista: la cookie viaja en la request, el servidor la puede leer.

**🟠 Difícil (17–22)**

17. **La cacería de `window`.** Recorre todo el Mini Jira (F2–F9) y haz una lista de
    cada punto que toca `window`, `document`, `localStorage` o `navigator`. Por cada
    uno, decide: ¿`mounted()`, `process.client`, `<client-only>` o cookie? Entrega
    `WINDOW-AUDIT.md`. (Esta es la fase entera en forma de checklist.)
18. Reproduce el **verde falso de NX0 en vivo**: coge uno de tus tests de regresión
    de NX0 que monta `TicketsPage` con `@vue/test-utils`, córrelo (pasa, jsdom tiene
    `window`), y luego rompe la página metiendo `window` en `created()`. El test
    **sigue verde**. La app **está rota en `npm run dev`**. Escribe en un comentario
    por qué el test no lo caza y qué haría falta para que lo cazara.
19. `<client-only>` con placeholder: usa el slot `#placeholder` (o `<template
    #placeholder>`) para mostrar "Cargando gráfico…" en el servidor mientras el
    cliente monta chart.js. Compruébalo en el HTML fuente.
20. Migra el **guard de auth de F2** a `middleware/auth.js`. Ojo: el middleware
    corre en servidor Y cliente, y `localStorage` no existe en el primero. Léelo de
    la cookie vía el contexto. ¿Qué pasa si un usuario sin cookie pide `/tickets`
    directo por URL (no navegando)? Verifícalo.
21. **El logout que no limpia el servidor.** Haz logout, borra la cookie en cliente,
    pero navega con el botón "atrás" del navegador a una página cacheada. ¿Sigues
    "dentro"? Investiga por qué y qué headers de cache (`Cache-Control`) haría falta
    que pusiera el servidor. Documenta el hallazgo (arreglarlo del todo es de
    backend 💸).
22. Mide el coste real del antipatrón: envuelve **todo** el dashboard en
    `<client-only>`, mira el HTML fuente (está vacío) y compara el TTFB / lo que ve
    el usuario contra la versión quirúrgica. Escribe 5 líneas: ¿qué exactamente
    perdiste y por qué es peor que una SPA normal?

**🔴 Muy difícil (23–26)**

23. **El bug de hidratación silencioso (el kata).** Construye un caso donde la
    hidratación falle **sin warning visible** pero con consecuencia real: por
    ejemplo, un `:class` con `Math.random()` que deja un botón con la clase
    equivocada y su `@click` sin enganchar tras "bailing hydration". Demuestra que
    el clic no responde. Luego arréglalo. Escribe por qué este es peor que el del
    ejercicio 5: el del 5 te avisa; este no.
24. **Dos `baseURL`, primer contacto.** json-server corre en `localhost:3000`. Desde
    el **servidor** Node, `localhost:3000` puede no ser la misma máquina/red que
    desde el **navegador**. Provoca el fallo (o razónalo si en tu setup local
    coinciden) y documenta por qué en producción el servidor y el cliente necesitan
    `baseURL` distintas. **No lo arregles del todo** — es la deuda que abre NX3 💸.
    Solo déjalo escrito y entendido.
25. **La cookie httpOnly de verdad.** Rehaz la sesión con una cookie `httpOnly` +
    `secure` + `sameSite=lax`, puesta por un endpoint (usa un middleware de servidor
    de Nuxt o un `serverMiddleware`). Consecuencia: el JS del cliente **ya no puede
    leer el token** → el interceptor del cliente ya no lo adjunta a mano; el
    navegador manda la cookie solo. Reescribe el flujo y explica en `AUTH-SSR.md`
    qué ataque (XSS) acabas de mitigar y cuál sigue abierto (CSRF) y por qué
    `sameSite` ayuda con el segundo.
26. **El informe de la red rota.** Escribe `NX0-POSTMORTEM.md`: la suite de NX0 está
    en verde y la app reventó en producción con `window is not defined` el día del
    despliegue. Reconstruye hacia atrás: ¿qué asumía cada test que era falso bajo
    SSR? ¿Por qué jsdom te mintió? ¿Qué tipo de test **sí** habría cazado esto (y
    por qué probablemente sea e2e o un test que corra el render en un entorno sin
    `window`)? Cierra respondiendo la pregunta que abrió NX0, ahora con la
    experiencia: *¿la suite está en verde porque todo está bien… o porque está
    mirando el mundo equivocado?*

---

## 📚 Referencias

**Documentación oficial (Nuxt 2 — ojo al dominio)**

- Nuxt 2 — Ciclo de vida y renderizado SSR: https://v2.nuxt.com/docs/concepts/nuxt-lifecycle
- Nuxt 2 — `<client-only>` (antes `<no-ssr>`): https://v2.nuxt.com/docs/features/nuxt-components#the-client-only-component
- Nuxt 2 — Plugins (y `mode: client`/`server`): https://v2.nuxt.com/docs/directory-structure/plugins
- Nuxt 2 — Módulo axios (`@nuxtjs/axios`): https://axios.nuxtjs.org/
- `cookie-universal-nuxt`: https://github.com/microcipcip/cookie-universal
- Nuxt 2 — Middleware: https://v2.nuxt.com/docs/directory-structure/middleware

> ⚠️ El dominio raíz `nuxt.com` sirve **Nuxt 3**. Para Nuxt 2 usa siempre
> **`v2.nuxt.com`**. Es el error de referencia #1 de esta ruta.

**Vue SSR / hidratación (el concepto, a fondo)**

- Vue 2 SSR Guide — Hydration: https://v2.ssr.vuejs.org/guide/hydration.html
- Vue 2 SSR Guide — Writing Universal Code (qué evitar en el servidor):
  https://v2.ssr.vuejs.org/guide/universal.html
- MDN — HTTP Cookies (por qué viajan en cada request):
  https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies

**Seguridad (para el ejercicio 25)**

- OWASP — HttpOnly: https://owasp.org/www-community/HttpOnly
- OWASP — SameSite: https://owasp.org/www-community/SameSite

**Orden de lectura sugerido:** Nuxt Lifecycle → Vue SSR "Writing Universal Code"
(quince minutos y es medio concepto 1) → Vue SSR Hydration → volver al código y
**provocar el error tú mismo**. El módulo axios y las cookies, cuando llegues a la
sección de auth.

---

## 🚀 Cierre

No migraste un formulario. No sacaste vuelidate. No tocaste `:rules`. Si esta fase
se pareciera a Q2 o VU2, estaría mal escrita — porque en Nuxt "migrar el CRUD" no
significa nada. Lo que hiciste fue mucho más grande y mucho más incómodo:
**descubriste que tu código corre en dos mundos y que hasta hoy solo probaste
uno.**

Lo que te llevas:

- el modelo mental que Q y VU nunca dan: **`created()` es territorio compartido,
  `mounted()` es territorio cliente**, y todo lo que toca el navegador vive en el
  segundo o no vive;
- el error que define el framework, `window is not defined`, **leído en su stack
  trace** y entendido como consecuencia, no como accidente;
- **`<client-only>` como bisturí, no como manta** — la diferencia entre una app SSR
  y una SPA cara con un servidor de adorno;
- la **hidratación** como contrato: servidor y cliente tienen que pintar lo mismo, y
  cualquier `Date.now()` o `Math.random()` en el render lo rompe — a veces gritando,
  a veces en silencio, que es peor;
- la deuda de NX1 **pagada** 💸: la sesión ya no vive en `localStorage` (un almacén
  de un solo mundo) sino en **cookies** (el único que ambos comparten), y por eso el
  servidor por fin puede renderizar sabiendo quién eres;

y la lección que cierra el círculo que abrió NX0. **Corre la suite de regresión.
Está en verde.** Los seis tests pasan, impecables. Y sin embargo hoy viste la app
reventar en la terminal antes de pintar un solo pixel.

> Esa contradicción **es** la fase. En NX0 te dijimos que tu red tenía un agujero
> porque tus tests corren en **jsdom** —que tiene `window`— mientras tu código
> corre en **Node** —que no—. Hoy lo tocaste con las manos: un test verde y una
> app rota, al mismo tiempo, por la misma línea. **La cobertura no te protegió del
> `window` que no existe en el sitio donde tus tests nunca miraron.**

Y lo tapaste **solo a medias**: moviste el código al mundo correcto, pero la red
que lo vigila sigue ciega al servidor. Por eso NX0 te lo dijo desde el principio —
*"del todo, nunca; por eso existe el e2e"*.

La señal de que quedó bien:

> "sé qué línea de mi componente corre en Node y cuál en el navegador, sé mover lo
> que toca el DOM al único sitio donde el DOM existe, y cuando vea un parpadeo raro
> en una página SSR sabré, antes de abrir DevTools, que alguien metió una hora o un
> random en el render."

**Siguiente parada:** 🔄 **NX3 — `asyncData` vs Vuex**. La app ya no revienta. Pero
fíjate en lo que dejamos feo a propósito: el dashboard carga los tickets en
`mounted()`, o sea **en el cliente**, o sea el HTML del servidor llega con el
spinner y no con los datos. Estás pagando un servidor Node para que renderice una
página de carga. La pregunta de la próxima fase es directa: **¿quién debería cargar
los datos ahora — tu Vuex de F10, o el `asyncData` que Nuxt trae para eso?** Y la
respuesta, como en F10, no es un dogma: es una decisión que vas a tener que
defender por escrito.
