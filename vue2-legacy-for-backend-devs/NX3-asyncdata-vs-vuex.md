# 🔄 NX3 — `asyncData` vs Vuex

> Tu store de F10 pierde protagonismo. Y hay que decidir cuánto.
> No con dogma: por escrito, defendiendo la decisión, como hiciste en F10.

---

## 🎯 Propósito

Nuxt trae **su propia forma de cargar datos**. Corre en el servidor, antes de
que el componente exista, y deja el HTML ya pintado con los tickets dentro. Es
justo el trabajo que en F10 le diste a Vuex con tanto criterio: **una carga, N
vistas, el store como fuente de verdad.**

Ahora dos mecanismos quieren el mismo trabajo. Y no puedes tener los dos a la
vez sin pagar algo:

- Si carga **`asyncData`** → SSR de verdad (SEO, TTFB), pero **el store no tiene
  los tickets** y el resto de la app depende de él.
- Si carga **Vuex** → el store sigue siendo la verdad, pero **el HTML llega
  vacío** y se rellena en cliente: perdiste el SSR que viniste a buscar.

Esta fase **no es** "aprende `asyncData`". Es la fase donde **decides quién
carga los datos y lo defiendes por escrito** — el mismo ejercicio de criterio de
F10, con otro eje. Allí la pregunta era *qué estado se vuelve global*. Aquí es
*dónde nace ese estado: en el servidor o en el cliente*.

> La regla de la fase: la respuesta honesta es **"depende"**, y "depende" no es
> una excusa para no decidir — es una obligación de argumentar. Igual que en F10.

> 🎯 Esta fase **sustituye** a "migrar el dashboard" de Q3/VU3. El conflicto es
> el mismo en **espíritu** (*el framework quiere el trabajo que tu store ya
> hace*), pero el eje es **otro**: allí peleabas la **paginación** contra
> `QTable`; aquí no hay tabla nueva. El dashboard es el mismo HTML de NX2. Lo
> que se pelea es **la carga entera de datos**.

---

## ✅ Qué queda listo al terminar

- el dashboard de NX2 cargando sus tickets con **`asyncData`**, renderizados en
  el servidor: ves los datos en el "View Source", no solo en el DOM ya hidratado;
- entendido el **contexto de Nuxt** (`$axios`, `store`, `params`, `redirect`,
  `error`) y **por qué `asyncData` no tiene `this`**;
- `fetch()` y `nuxtServerInit` claros: los dos hermanos que **sí** pueden llenar
  el store, y cuándo cada uno;
- un **documento de decisión** (`DATA-LOADING-DECISIONS.md`) que dice, por
  vista, quién carga y por qué — la versión NX3 del `STATE-DECISIONS.md` de F10;
- el manejo de errores de carga movido a **`error()` del contexto** (la página
  de error de Nuxt) en lugar del `try/catch` que pinta un div rojo;
- entendido por qué **el trío `loading/error/data` de F3 se rompe** en SSR, y
  qué queda vivo de él;
- la **deuda de las dos `baseURL`** documentada: el servidor Node habla con el
  backend por una dirección, el navegador por otra. 💸

## 🚫 Qué NO entra todavía

- páginas nuevas SSR desde cero (eso es NX4 — aquí solo migramos carga);
- `head()`, `validate()`, rutas anidadas (NX4);
- caché de SSR a nivel de servidor (Redis, `ssrContext` avanzado) — otro curso;
- reemplazar Vuex por `useAsyncData`/`useФetch` de Nuxt 3 — **eso es Vue 3, fuera**;
- convertir TODO a `asyncData` — precisamente el anti-objetivo de la fase.

---

## 🧠 Concepto 1: `asyncData` — el método que corre antes de existir

En el tronco, un componente cargaba sus datos en `created()` o `mounted()`:
el componente nacía, y **después** pedía. Con `asyncData` el orden se invierte:

```
         ┌──────────── SERVIDOR (Node) ────────────┐
petición → asyncData(context)  ──→  devuelve {tickets}
             (pide a la API)              │
                                          ▼
                             se FUSIONA con data()
                                          │
                                          ▼
                          el componente se crea YA con los datos
                                          │
                                          ▼
                          HTML renderizado CON los tickets dentro
         └─────────────────────────────────────────┘
                                          │  (viaja al navegador)
                                          ▼
         ┌──────────── CLIENTE (browser) ───────────┐
                          hidratación: revive el HTML
         └──────────────────────────────────────────┘
```

Las cuatro cosas que tienes que interiorizar de `asyncData`:

| Propiedad | Qué significa | Consecuencia práctica |
|---|---|---|
| **Corre en el servidor** (la primera vez) | antes de crear el componente | el HTML sale ya con datos → SEO/TTFB |
| **Devuelve un objeto** | se **fusiona** con `data()` | lo que devuelvas aparece como `this.xxx` en el template |
| **NO tiene `this`** | el componente aún no existe | no puedes hacer `this.$store`, `this.$axios`… |
| **Solo en PÁGINAS** | `pages/`, no `components/` | 🧨 los componentes de F4 dejan de poder pedir sus propios datos |

Esa última fila es la que **rompe la arquitectura del tronco**. En F4 un
componente hijo podía tener su `created()` y pedir lo suyo. En Nuxt, si quieres
carga en servidor, **solo la página manda**: los datos entran arriba y bajan por
props. Componente tonto, página lista. (Sí, es lo que F10 ya empujaba con "una
fuente, N consumidores" — Nuxt lo vuelve **obligatorio** para SSR.)

```js
// pages/tickets/index.vue
export default {
  // ⬇️ NO tiene this. Recibe el contexto.
  asyncData: function (context) {
    return context.$axios
      .$get("/tickets", { params: { _sort: "createdAt", _order: "desc" } })
      .then(function (tickets) {
        // lo que devuelves se fusiona con data()
        return { tickets: tickets };
      });
    // 🔎 fíjate: NO hay context.commit. Esto NO toca el store.
    //    Los tickets viven en data() de ESTA página, y en ningún lado más.
  },

  data: function () {
    // 'tickets' se fusiona aquí. Este default es lo que ves si asyncData
    // no corriera (no pasa en SSR, pero deja el contrato explícito).
    return { tickets: [] };
  }
};
```

> **`$get` vs `get`.** `@nuxtjs/axios` añade helpers `$get/$post/...` que
> **devuelven el body directamente** (ya sin `.data`). Es azúcar de época del
> módulo; el `axios.get().then(r => r.data)` de tu apéndice A4 sigue siendo lo
> que hay debajo.

## 🧠 Concepto 2: el contexto — por qué `this` no sirve

`asyncData` no tiene `this` porque **el componente no existe cuando corre**.
En su lugar recibe el **contexto de Nuxt**, un objeto con todo lo que
normalmente sacarías de `this`:

```js
asyncData: function (context) {
  context.$axios     // ⬅️ el axios inyectado en NX1 (con tus interceptores)
  context.store      // ⬅️ el store de Vuex, SÍ, aquí está — ojo con esto
  context.params     // ⬅️ lo que era this.$route.params (params.id)
  context.query      // ⬅️ this.$route.query (los filtros de la URL de F4/F10)
  context.redirect   // ⬅️ redirigir ANTES de renderizar (el guard de F2, evolucionado)
  context.error      // ⬅️ mandar a la página de error (ver Concepto 4)
  context.req        // ⬅️ el request de Node — SOLO existe en servidor
}
```

Es idiomático desestructurar solo lo que usas:

```js
asyncData: function (ctx) {
  var $axios = ctx.$axios;
  var params = ctx.params;
  // ...
}
```

**El detalle que confunde a todos:** `context.store` **está ahí**. Puedes
commitear desde `asyncData`. Entonces, ¿por qué existe la disyuntiva del título
si `asyncData` puede llenar el store? Porque puede, sí — pero entonces estás
**usando `asyncData` como un `fetch()` disfrazado**, y `fetch()` es la
herramienta hecha para eso (Concepto 3). Poder hacerlo no significa que sea el
lugar. Ese matiz **es** la fase.

## 🧠 Concepto 3: `fetch()` y `nuxtServerInit` — los que SÍ llenan el store

Nuxt te da tres mecanismos de carga, no uno. La diferencia está en **para qué
sirven** y en **si tienen `this`**:

| Mecanismo | ¿`this`? | ¿Dónde corre? | ¿Devuelve datos? | Para qué es |
|---|---|---|---|---|
| **`asyncData`** | ❌ no | servidor (1ª vez), cliente (navegación) | ✅ se fusiona con `data` | datos que **vive la página** |
| **`fetch()`** (Nuxt 2.12+) | ✅ **sí** | igual | ❌ no devuelve; **muta el store** | llenar **Vuex** desde la página |
| **`nuxtServerInit`** | — (es una action) | **solo servidor, una vez** | ❌ commitea | precargar el store **antes de todo** |

```js
// pages/tickets/index.vue — versión "el store manda"
export default {
  // ⬇️ fetch SÍ tiene this → puede despachar la action de F10 tal cual
  fetch: function () {
    return this.$store.dispatch("tickets/fetchTickets");
    // 🔎 los tickets acaban en el STORE, no en data(). El dashboard los lee
    //    con mapGetters, EXACTAMENTE como en F10. Cero cambios en la vista.
  },

  computed: Object.assign(
    {},
    // los mismos helpers de F10, intactos:
    // mapGetters("tickets", ["allTickets"]), etc.
  )
};
```

```js
// store/index.js — nuxtServerInit: la sesión y lo global, una vez, en servidor
export const actions = {
  // ⬇️ nombre reservado. Nuxt la llama sola, en el servidor, antes de renderizar.
  nuxtServerInit: function (context, nuxtContext) {
    // nuxtContext.req existe: aquí lees la COOKIE de sesión (la de NX2)
    // y rehidratas auth ANTES de que cualquier guard corra.
    // Es donde la auth de F2 (rota en NX2) queda por fin bien en SSR.
    var token = leerCookie(nuxtContext.req, "token");
    if (token) {
      context.commit("auth/SET_TOKEN", token, { root: true });
    }
  }
};
```

**La regla mental limpia:**

- ¿el dato lo vive **una página** y no le importa a nadie más? → **`asyncData`**
  (y aceptas que el store no lo tenga).
- ¿el dato lo comparten varias vistas, muta por sockets, y la inconsistencia
  sería un bug? *(las cuatro preguntas de F10, ¿te suenan?)* → **`fetch` +
  Vuex**.
- ¿es global y hay que tenerlo **antes** de renderizar nada (la sesión)? →
  **`nuxtServerInit`**.

Los tickets, según la auditoría de F10, marcaban **cuatro sí**: viven en
dashboard + panel + métricas, sobreviven navegación, los mutan HTTP + socket +
PATCH, y la inconsistencia es un bug visible ("tomé el ticket y métricas no se
enteró"). Esa auditoría **no cambia porque cambiemos de framework.** Empújala
hasta su conclusión en la sección de Concepto 5.

## 🧠 Concepto 4: errores de carga — `error()`, no el div rojo

En F3/F4 el patrón era: `try/catch`, guardar `error` en `data`, pintar un div
rojo. En SSR eso tiene un problema: **el error ocurre en el servidor, antes de
que exista una vista donde pintar el div.** Nuxt te da la salida por el contexto:

```js
asyncData: function (ctx) {
  return ctx.$axios.$get("/tickets")
    .then(function (tickets) { return { tickets: tickets }; })
    .catch(function () {
      // ⬇️ manda a la página de error de Nuxt (layouts/error.vue),
      //    renderizada en el servidor con el status correcto.
      ctx.error({ statusCode: 503, message: "No se pudieron cargar los tickets." });
    });
}
```

`error()` es distinto de `redirect()`: `redirect` cambia de ruta; `error`
**renderiza la página de error en el sitio**, con el código HTTP real (un
buscador que reciba un 503 no indexa la página vacía — SSR también significa
**responder con el status correcto**, cosa que una SPA no puede).

## 🧠 Concepto 5: qué queda del trío `loading/error/data` — la pregunta de la fase

Este es el corazón. Léelo despacio.

Desde F3 arrastras un patrón sagrado: **`loading` → `data` → `error`**. Pintabas
un spinner, llegaban los datos, o pintabas el error. En F10 lo ascendiste a
estado del store (`items/loading/error`). Era la columna vertebral de cada vista.

**En SSR ese patrón se rompe.** Y hay que mirarlo de frente:

> Si el HTML **ya llega con los tickets dentro**, ¿cuándo se ve el `loading`?
> **Nunca.** No hay momento de "esperando" en el servidor: el usuario recibe la
> página cuando ya está lista. `loading = true` no se pinta jamás en el primer
> render SSR.

Lo que le pasa a cada pieza del trío:

| Pieza (F3/F10) | En SSR (primer render) | En cliente (navegación SPA interna) |
|---|---|---|
| **`loading`** | 💀 nunca se ve (el HTML llega listo) | ✅ sigue vivo: al navegar de A→B, `asyncData` corre en cliente y sí hay espera |
| **`error`** | movido a `error()` del contexto (página de error) | vuelve a tener sentido como estado in-page |
| **`data`** | ✅ ya viene fusionado en el HTML | se rellena al navegar |

La lección incómoda: **`loading` no muere, se vuelve condicional al entorno.**
En la carga inicial (SSR) no existe; en la navegación cliente-a-cliente
resucita. Un `<div v-if="loading">` que en el tronco protegía SIEMPRE, en Nuxt
protege **solo a veces** — y si no lo entiendes, meterás un spinner que nadie ve
en SSR y que sí aparece al navegar, y jurarás que "a veces funciona".

Y aquí desemboca **la pregunta de la fase**, que es la fase entera:

> Los tickets, ¿los carga `asyncData` o Vuex?

No hay respuesta universal. Hay una **decisión defendida**:

**Opción A — `asyncData` (SSR real):**
- ✅ HTML con datos: SEO indexable, TTFB bajo, el dashboard "aparece" pintado.
- ❌ el store no tiene los tickets. Panel y métricas (que en F10 leían del
  store) **no los ven**. O duplicas la carga, o pasas datos por props/eventos,
  o rompes la fuente única de verdad que tanto te costó.
- ❌ el `UPSERT_TICKET` del socket (F8/F10) commitea al store… que la página no
  está leyendo. El tiempo real deja de reflejarse. **Este es el choque duro.**

**Opción B — `fetch` + Vuex (store manda):**
- ✅ el store sigue siendo la verdad. Panel, métricas y socket funcionan como en
  F10, sin tocar nada. `mapGetters` intacto.
- ✅ el `fetch()` corre también en servidor, así que **sí hay SSR** de los
  tickets (llegan en el HTML vía estado serializado del store — Nuxt inyecta
  `window.__NUXT__` con el state).
- ❌ es un SSR más "indirecto": los datos viajan como estado hidratado, no como
  HTML semántico puro. Para SEO de contenido suele bastar; para casos extremos
  de TTFB, `asyncData` gana por un pelo.

**La respuesta honesta para Mini Jira:** dado que los tickets **ya cumplían las
cuatro preguntas de F10** (multi-vista, sobreviven navegación, multi-fuente,
inconsistencia = bug), y dado que **el socket de F8 commitea al store**, romper
la fuente única para ganar un TTFB marginal es un mal negocio. → **Opción B:
`fetch` + Vuex.** El store que construiste en F10 **no se rinde**; Nuxt lo
alimenta desde el servidor en vez de desde `mounted()`.

Pero — y esto es F10 puro — **eso hay que escribirlo, no asumirlo.** El
ejercicio 26 es redactar `DATA-LOADING-DECISIONS.md` con esta defensa. Si tu
app fuera un blog público (una página, sin socket, SEO crítico), la respuesta
honesta sería la contraria. **El criterio, no el dogma, decide.**

---

## 💻 Código de la fase

### El dashboard, versión "el store manda" (la decisión defendida)

```vue
<!-- pages/tickets/index.vue -->
<template>
  <div class="container mt-3">
    <!-- loading: solo se ve al navegar en cliente; en SSR nunca. Y está bien. -->
    <div v-if="loading" class="text-muted">Cargando tickets…</div>

    <TicketTable v-else :tickets="allTickets" />
    <!-- 🔎 TicketTable es el componente TONTO de F4: recibe tickets por prop,
         no pide nada. En Nuxt esto deja de ser buena práctica opcional y pasa
         a ser obligatorio: los componentes no cargan datos en SSR. -->
  </div>
</template>

<script>
import { mapState, mapGetters } from "vuex";
import TicketTable from "~/components/TicketTable.vue";

export default {
  components: { TicketTable: TicketTable },

  // ⬇️ fetch (con this): corre en servidor la 1ª vez, en cliente al navegar.
  //    Despacha la MISMA action de F10. La vista no sabe que está en Nuxt.
  fetch: function () {
    return this.$store.dispatch("tickets/fetchTickets");
  },

  // desde Nuxt 2.12, fetch expone su propio estado de carga:
  computed: Object.assign(
    {},
    mapState("tickets", { storeError: "error" }),
    mapGetters("tickets", ["allTickets"]),
    {
      loading: function () {
        // $fetchState.pending: true mientras fetch() está en curso (cliente)
        return this.$fetchState.pending;
      }
    }
  )
};
</script>
```

**🔎 Qué hace, pieza por pieza:**

| Pieza | Su trabajo |
|---|---|
| `fetch()` despachando `tickets/fetchTickets` | reusa la action de F10 **sin tocarla**. El store se llena en el servidor; el HTML sale con estado hidratado |
| `this.$fetchState.pending` | el `loading` de F3, ahora provisto por Nuxt — y solo relevante en navegación cliente |
| `allTickets` (getter de F10) | la vista lee del store, igual que en F10. Panel y métricas leen del mismo sitio: **fuente única intacta** |
| `TicketTable` con `:tickets` | el componente tonto de F4. En Nuxt, "tonto" no es estilo: es requisito de SSR |

### La alternativa, para que la veas y la rechaces con criterio

```js
// pages/tickets/index.vue — Opción A: asyncData (NO la elegimos, pero míralas juntas)
export default {
  asyncData: function (ctx) {
    return ctx.$axios
      .$get("/tickets", { params: { _sort: "createdAt", _order: "desc" } })
      .then(function (tickets) { return { tickets: tickets }; })
      .catch(function () {
        ctx.error({ statusCode: 503, message: "No se pudieron cargar los tickets." });
      });
  },
  data: function () { return { tickets: [] }; }
  // ❌ el socket commiteará al store; este 'tickets' de data() NUNCA se entera.
  //    El tiempo real muere en silencio. Por eso NO es la opción para Mini Jira.
};
```

**✅ Buenas prácticas aplicadas:**
- **La action de F10 no se toca.** Si migrar a Nuxt te obliga a reescribir
  `fetchTickets`, algo está mal: `fetch()` la consume tal cual. La capa de
  servicios y el store sobreviven al cambio de framework — igual que json-server.
- **El componente hijo sigue tonto.** No le añadas un `asyncData` (ni podrías:
  no es página). Datos arriba, props abajo.
- **`error()` para fallos de carga en servidor**, `storeError` para fallos que
  ocurren en cliente. Dos entornos, dos caminos — pero el mismo mensaje al
  usuario.
- **Decisión escrita.** El `DATA-LOADING-DECISIONS.md` no es burocracia: es el
  `STATE-DECISIONS.md` de F10 aplicado al eje "servidor vs cliente".

### 💸 La deuda de las dos `baseURL`

json-server corre en `localhost:3000`. Tu app Nuxt, en `localhost:3000`… no,
espera: Nuxt sirve en otro puerto. Y aquí aparece la deuda propia de la fase.

```js
// nuxt.config.js
export default {
  axios: {
    // el navegador pide a esta (la PÚBLICA):
    browserBaseURL: "http://localhost:3000",
    // el servidor Node pide a esta (podría ser una RED INTERNA):
    baseURL: "http://localhost:3000"
  }
}
```

En desarrollo las dos apuntan al mismo sitio y parece redundante. **No lo es.**

> 💸 **Deuda.** En producción el servidor Node y el navegador **no comparten
> dirección**. El servidor habla con el backend por **red interna**
> (`http://api-internal:8080`, sin salir a Internet); el navegador, por la
> **pública** (`https://api.miempresa.com`). Son **dos `baseURL`** para el mismo
> backend. Aquí las igualamos porque todo corre en tu máquina, pero **el día que
> despliegues, si solo configuras una, la mitad de las peticiones fallará** — y
> el error será desconcertante porque "en mi máquina funciona". `browserBaseURL`
> vs `baseURL` es el gancho donde se paga. *(Relacionado: el CORS de json-server
> también muerde distinto según quién pida — el servidor Node no tiene política
> de origen; el navegador sí.)*

---

## ⚠️ Errores comunes

1. **`this.$store` dentro de `asyncData`.** `TypeError: Cannot read 'store' of
   undefined`. No hay `this`. Usa `context.store`. (Y si necesitas `this`, la
   herramienta es `fetch()`, no `asyncData`.)
2. **Poner `asyncData` en un componente hijo.** No corre, y no avisa fuerte.
   `asyncData` **solo funciona en `pages/`**. El componente de F4 no puede
   pedir sus datos: se los pasa la página.
3. **Esperar ver el spinner de `loading` en la carga inicial.** No aparece: el
   HTML llega con datos. Si lo pusiste "para que se vea bonito al cargar", en
   SSR es código muerto. Solo vive en navegación cliente-a-cliente.
4. **Elegir `asyncData` y llorar porque el socket no actualiza la tabla.** El
   socket commitea al **store**; `asyncData` guardó los datos en `data()` de la
   página. Son dos sitios distintos. Coherencia: si quieres tiempo real, los
   datos viven en el store → `fetch` + Vuex.
5. **`context.req` en cliente.** `req` **solo existe en servidor**. Al navegar
   internamente, `asyncData`/`fetch` corren en el navegador y `req` es
   `undefined`. Protege con `if (process.server)` lo que dependa de `req`.
6. **Una sola `baseURL`.** Funciona en local, revienta en prod (la deuda 💸). Si
   el servidor Node y el navegador comparten URL, es coincidencia del entorno de
   desarrollo, no diseño.
7. **`nuxtServerInit` en un módulo namespaced.** Es una action **del store raíz**
   (`store/index.js`), con nombre reservado. Ponerla en `store/tickets.js` no la
   ejecuta. Nuxt solo la busca en la raíz.
8. **Devolver una Promise sin `return` en `asyncData`/`fetch`.** Sin `return`,
   Nuxt no espera: renderiza antes de que lleguen los datos, y el SSR pinta
   vacío. La lección del `return` de F3, ahora con castigo doble (rompe el SSR,
   no solo el `.then` de la vista).

---

## 🧪 Ejercicios (28)

**🟢 Fácil (1–8)**

1. Convierte `pages/tickets/index.vue` a `fetch()` + Vuex (la decisión de la
   fase). Verifica en Vue Devtools → Vuex que el módulo `tickets` tiene items
   **antes** de que montes nada en cliente (el estado llegó hidratado).
2. Mira el HTML crudo: clic derecho → "Ver código fuente de la página" (no el
   inspector, el **source**). ¿Están los títulos de los tickets en el HTML?
   Compara con la versión `asyncData` del ej. 9. Documenta la diferencia.
3. Añade un `console.log("fetch corriendo en:", process.server ? "servidor" :
   "cliente")` dentro de `fetch()`. Recarga (F5) y luego navega desde otra
   página al dashboard. ¿Qué imprime cada caso y **dónde** (terminal vs consola
   del navegador)?
4. Rompe json-server (apágalo) y recarga el dashboard con `asyncData`. Sin
   `ctx.error`, ¿qué ves? Ahora añade `ctx.error({statusCode: 503, ...})` y
   compara. ¿Qué status devuelve la respuesta HTTP? (mira la pestaña Network).
5. Muestra `this.$fetchState.pending` en pantalla como texto. Navega
   dashboard→detalle→dashboard y observa cuándo se pone `true`. ¿Se puso `true`
   alguna vez en la recarga con F5? Explica por qué no.
6. Desestructura el contexto de `asyncData` a `{ $axios, params }` y usa esa
   forma. Confirma que sigue funcionando. (Es cosmética, pero verás ambas en
   legacy.)
7. Cambia `browserBaseURL` a un puerto equivocado dejando `baseURL` bien.
   ¿Qué peticiones fallan: las de recarga (SSR) o las de navegación (cliente)?
   Diagnostica por qué **solo esas**.
8. Añade `nuxtServerInit` en `store/index.js` que haga `console.log` con la
   hora. Recarga tres veces y navega dentro de la app. ¿Cuántas veces corrió?
   ¿En servidor o cliente?

**🟡 Intermedio (9–17)**

9. Implementa la **Opción A** completa (`asyncData` guardando en `data`) en una
   rama aparte. Déjala funcionando. Ahora abre el panel de soporte: ¿ve los
   tickets? Documenta exactamente qué se rompió y por qué (la fuente única
   partida en dos).
10. Con la Opción A del ej. 9, emite un update por socket (F8). Observa: el
    store se actualiza, la tabla no. Explica el bug en tres frases y por qué la
    Opción B no lo tiene.
11. Mueve la rehidratación de la sesión (la cookie de NX2) a `nuxtServerInit`.
    Antes vivía en un plugin/middleware; ahora corre una vez en servidor antes
    de todo. ¿Desaparece algún parpadeo de "no logueado→logueado" que tenías?
12. Los filtros del dashboard vivían en la **URL** (F4 ej.13, F10). En Nuxt,
    léelos con `context.query` dentro de `fetch`/`asyncData` y pásalos a la
    action `fetchTickets`. Ahora el filtro se aplica **en el servidor**: el HTML
    llega ya filtrado. Verifícalo en el source.
13. Detalle de ticket (`pages/tickets/_id.vue`) con `asyncData` usando
    `context.params.id`. Si el ticket no existe (404 de json-server), manda a
    `context.error({ statusCode: 404 })`. Prueba con un id inventado.
14. Caché del store en SSR: tu `fetchTickets` de F10 ya evita re-pedir si hay
    items. Pero en SSR el store nace vacío en cada request de servidor.
    ¿El caché de F10 ayuda o es irrelevante en la carga inicial? Razónalo y
    verifica con logs.
15. Compara TTFB real: con la extensión de red del navegador, mide el tiempo de
    la primera respuesta HTML en Opción A vs Opción B vs la versión SPA de NX2.
    Anota los tres números. ¿La diferencia justifica romper el store? (spoiler
    razonable: no, para Mini Jira).
16. Maneja el caso "el backend interno tarda 5s" en `asyncData`: el usuario ve
    **pantalla en blanco** hasta que el servidor responde (no hay spinner en
    SSR). Documenta este trade-off: SSR intercambia "spinner rápido" por
    "respuesta completa pero potencialmente lenta". ¿Cuándo es mala idea?
17. `fetch()` con `fetchOnServer: false`: fuérzalo a correr solo en cliente.
    Ahora el HTML llega sin tickets y el spinner SÍ aparece. Has recreado una
    SPA dentro de Nuxt. ¿Cuándo querrías esto? (pista: datos privados que no
    deben estar en el HTML cacheable).

**🟠 Difícil (18–23)**

18. **Doble carga:** con `asyncData` mal hecho, los datos se piden en servidor Y
    otra vez al hidratar en cliente. Reprodúcelo, detéctalo en Network (dos
    llamadas a `/tickets` en una recarga), y arréglalo. Explica por qué Nuxt no
    debería re-pedir en la hidratación inicial y qué lo estaba causando.
19. `nuxtServerInit` que precarga **tickets Y sesión** en el store, de modo que
    el dashboard no necesite ni `fetch()` ni `asyncData` (el store ya llega
    lleno del servidor). Compara este enfoque contra `fetch()` por página:
    ¿qué ganas (una sola precarga) y qué pierdes (todo se carga siempre, aunque
    no vayas al dashboard)?
20. Errores por entorno: haz que `fetchTickets` distinga un fallo en servidor
    (→ `nuxtContext.error`, página de error SSR con status) de un fallo en
    cliente (→ `storeError`, div in-page con botón reintentar). Una sola action,
    dos comportamientos según `process.server`. Documenta la ramificación.
21. Redirección server-side: si `nuxtServerInit` no encuentra sesión válida y la
    ruta es privada, redirige **antes de renderizar** (nada de flash de
    contenido protegido). Compáralo con el guard de F2 que redirigía en cliente:
    ¿qué ve el usuario en cada caso? ¿Cuál filtra un bot?
22. Serialización del estado: abre el HTML source y busca `window.__NUXT__`.
    Ahí está tu store serializado. Mete en el state algo **no serializable**
    (una función, un `Date` vivo, una instancia de clase) y observa qué pasa al
    hidratar. Concluye la regla: qué puede vivir en el store bajo SSR.
23. Las dos `baseURL` de verdad: simula producción con json-server en un
    puerto "interno" (3001) y un proxy en otro "público" (3000). Configura
    `baseURL: :3001` (servidor) y `browserBaseURL: :3000` (navegador) y consigue
    que la app funcione con AMBAS rutas activas a la vez. Documenta qué petición
    salió por cada una.

**🔴 Muy difícil (24–28)**

24. **[OBLIGATORIO] Migra el panel de soporte (F9) a Nuxt.** Los sockets de F8
    **no sobreviven al servidor** (`socket.io-client` necesita `window`). El
    panel carga su estado inicial en servidor pero se actualiza en vivo en
    cliente. ¿Cómo lo resuelves? Requisitos: (a) la cola de tickets llega
    renderizada en el HTML (SSR); (b) el socket se conecta **solo en cliente**
    (`mounted()` + `process.client`); (c) los updates entran por el plugin de
    Vuex de F10, que ahora debe registrarse **solo en cliente**; (d) al recargar
    en mitad de una sesión, no se pierde estado. Escribe qué parte es servidor,
    qué parte cliente, y dónde está la costura. *(Esta es la fase entera en un
    ejercicio: el híbrido SSR-inicial + tiempo-real-cliente que NX4 formaliza.)*
25. El plugin de socket de F10 en SSR: si lo registras sin protección, el
    servidor intenta abrir un WebSocket y revienta (o cuelga el render). Hazlo
    un **plugin `mode: 'client'`** (NX1) y verifica que `nuxtServerInit` puede
    precargar el estado inicial mientras el plugin de socket ni se carga en
    servidor. Diagrama la secuencia: servidor (sin socket, con datos) →
    hidratación → cliente (socket se conecta, empieza a commitear).
26. **[OBLIGATORIO] Escribe `DATA-LOADING-DECISIONS.md`.** Una fila por
    entidad/vista (tickets, sesión, comentarios, métricas, filtros), con
    columnas: *quién carga* (`asyncData`/`fetch`+Vuex/`nuxtServerInit`/cliente),
    *por qué*, *qué pasa con el socket*, *qué pasa con el `loading`*. Reusa la
    lógica de las cuatro preguntas de F10 pero aplicada al eje servidor/cliente.
    Este documento es el `STATE-DECISIONS.md` de F10 evolucionado: en una base
    Nuxt legacy real vale más que cualquier diagrama.
27. Optimistic update (F10 ej.18) bajo SSR: el `UPSERT` optimista commitea antes
    del PATCH. En SSR la primera carga no tiene interacción, pero al navegar en
    cliente sí. ¿Cambia algo el patrón optimista entre "datos que nacieron en
    servidor" y "datos que nacieron en cliente"? Pruébalo y documenta si el
    snapshot de rollback sigue siendo válido tras una hidratación.
28. Caché de página SSR (`ssr: true` + un LRU casero en un plugin de servidor):
    cachea el HTML renderizado del dashboard 30s para no re-pedir tickets en
    cada request. Ahora el problema: si un socket actualiza un ticket, la caché
    sirve HTML viejo. Discute la invalidación. Concluye por qué el caché de SSR
    y el tiempo real **se pelean** — y por qué eso justifica que NX4 separe el
    estado inicial (SSR, cacheable) del tiempo real (cliente, nunca cacheado).

---

## 📚 Referencias

**Documentación oficial (Nuxt 2 — ojo con el dominio)**

- ⚠️ Usa **`https://v2.nuxt.com`**. El dominio raíz `nuxt.com` sirve Nuxt 3+,
  cuya API (`useAsyncData`, `useFetch`) **no aplica** a este curso.
- `asyncData`: https://v2.nuxt.com/docs/features/data-fetching/#async-data
- `fetch()` (Nuxt 2.12+): https://v2.nuxt.com/docs/features/data-fetching/#the-fetch-hook
- El contexto de Nuxt: https://v2.nuxt.com/docs/internals-glossary/context/
- `nuxtServerInit`: https://v2.nuxt.com/docs/directory-structure/store/#the-nuxtserverinit-action
- `@nuxtjs/axios` (baseURL vs browserBaseURL):
  https://axios.nuxtjs.org/options/
- Manejo de errores (`error()`):
  https://v2.nuxt.com/docs/directory-structure/layouts/#error-page

**Del propio curso (releer)**

- **F10 — Vuex a fondo:** las cuatro preguntas del criterio y la auditoría de
  estado. Esta fase **es** F10 aplicado al eje servidor/cliente.
- **F3 — Mock API:** el trío `loading/error/data` y la lección del `return` en
  las promesas. Aquí se rompe y se recompone.
- **NX2 — Hidratación:** por qué el socket y chart.js necesitan `window`, y por
  qué eso condiciona quién puede cargar qué.

**Orden de lectura sugerido:** el contexto de Nuxt → `asyncData` → `fetch` →
volver a leer la auditoría de F10 → tomar la decisión → escribirla → `error()`
cuando toques el ej. 13 → `nuxtServerInit` antes del ej. 24.

---

## 🚀 Cierre

Dos mecanismos querían el mismo trabajo, y elegiste con criterio, no con dogma:
para Mini Jira, **`fetch` + Vuex**, porque los tickets ya cumplían las cuatro
preguntas de F10 y el socket commitea al store. El store que construiste con
tanto cuidado **no se rindió** ante Nuxt: solo cambió de dónde recibe su primera
carga — del `mounted()` del navegador al servidor Node. Te llevas:

- **`asyncData`** (sin `this`, en servidor, fusiona con `data`), **`fetch`** (con
  `this`, llena el store) y **`nuxtServerInit`** (global, una vez, en servidor) —
  y el criterio para elegir entre los tres;
- el **contexto de Nuxt** como sustituto de `this`, y `error()`/`redirect()`
  como las salidas server-side que una SPA no tiene;
- la muerte y resurrección del **`loading`**: nunca en SSR, vivo en navegación
  cliente;
- la deuda de las **dos `baseURL`** que espera para morderte en el despliegue;
- y la habilidad de F10 llevada a otro eje: **decidir dónde nace un dato y
  defenderlo por escrito**.

La señal de que quedó bien:

> "puedo señalar cualquier dato de la app y decir **dónde se carga** (servidor o
> cliente), **quién lo carga** (`asyncData`, `fetch`, `nuxtServerInit`), y
> defender por qué — incluido por qué el `loading` a veces no se ve."

**Siguiente parada:** 🆕 NX4 — la página SSR nueva. Hasta aquí has **traducido**
lo que ya existía. Ahora construyes algo que a pelo no podías: un timeline de
actividad que **nace renderizado en el servidor** (`asyncData`, `head()`
dinámico, `validate()`) **y se actualiza en vivo por socket** — solo en cliente.
Ese híbrido —estado inicial en servidor, tiempo real en cliente— es exactamente
la costura que el ejercicio 24 te hizo tocar. NX4 la convierte en la lección
final de la ruta.
