# 📖 Fase NX1 — Leer Nuxt

> Sin migrar nada. Reconocimiento puro. Y aquí cambia el mapa entero del proyecto.

---

## 🎯 Propósito

Aprender a **leer** un proyecto Nuxt 2 antes de tocarlo. No a migrar — a orientarte.
A abrir un repo Nuxt ajeno y saber, en treinta segundos, dónde vive cada cosa que
en el curso base tenía su carpeta fija: dónde está el routing, dónde se configura
axios, dónde se metieron los guards. Porque en Nuxt **casi nada está donde tú lo
dejaste**, y el que no sabe leer el mapa nuevo se pasa media hora buscando el
`router/index.js` que no existe.

Y hay una segunda capa, la que de verdad importa: entender que Nuxt **no es un
framework de UI**. No trae componentes. No hay `NxTable` ni `NxForm` — y si vienes
de Quasar o Vuetify esperando eso, vas a buscar una tabla mágica que nunca aparece.
Lo que Nuxt cambia no es *cómo se ven* tus componentes; es **dónde se ejecutan**.
Tu `TicketForm` de F5 se queda idéntico, carácter por carácter. Lo que cambia es
que ahora ese código corre **primero en un servidor Node** y **luego otra vez en el
navegador** — y ese "dos veces" es el modelo mental nuevo de toda la ruta.

Esta fase es reconocimiento puro. No rompemos nada (eso es NX2). Solo miramos.

> La regla de la fase: en Nuxt no preguntes *"¿qué componente uso?"*.
> Pregunta *"¿esto en qué entorno se está ejecutando ahora mismo?"*.

---

## ✅ Qué queda listo al terminar

- Un proyecto Nuxt 2.15.x recién generado con `create-nuxt-app`, corriendo en
  modo `universal`, que puedes abrir y **leer sin perderte**;
- el mapa mental de las carpetas mágicas: `pages/`, `layouts/`, `plugins/`,
  `store/`, `middleware/`, y qué hace cada una **por convención** (sin registrar
  nada a mano);
- saber que el routing **sale de las carpetas** — `pages/tickets/index.vue` es
  `/tickets`, `pages/tickets/_id.vue` es `/tickets/:id` — y que `router/index.js`
  ya no existe;
- entender `nuxt.config.js` como el sitio donde se fue a vivir lo que en el curso
  base estaba repartido entre `main.js` y `vue.config.js`;
- el concepto que define la ruta: **el ciclo de vida corre dos veces**, y la
  regla de oro que se deriva de ahí (`window`/`document`/`localStorage` → solo en
  `mounted()`);
- la **tabla de equivalencias** curso-base → Nuxt, memorizada, para traducir de un
  vistazo cualquier repo Nuxt que te caiga encima.

## 🚫 Qué NO entra todavía

- **Romper la app.** El `window is not defined`, la hidratación, el arreglo de la
  auth con cookies — todo eso es NX2. Aquí solo *anticipamos* la deuda 💸.
- **`process.client` / `process.server`.** Los flags para discriminar entorno
  aparecen cuando haya que arreglar algo (NX2). Aquí basta con saber que
  `created()` corre en los dos lados y `mounted()` en uno.
- **`asyncData` / `fetch` / `nuxtServerInit`.** La forma Nuxt de cargar datos —
  y su pelea con Vuex — es NX3. Aquí solo notamos que `store/` viene de fábrica.
- **`head()`, `validate()`, rutas anidadas, transiciones.** Features de creación
  (NX4).
- **Escribir código nuevo.** Esta fase es de lectura. Como mucho, arrancas el
  proyecto y navegas por él.

---

## 🧠 Concepto 1: Nuxt es un META-framework, no una librería de UI

Dígalo sin rodeos, porque es el malentendido número uno del que viene de Quasar o
Vuetify:

> **Nuxt no tiene componentes propios. No existe `NxButton`. No existe `NxTable`.**

Quasar y Vuetify son **librerías de UI**: te dan un catálogo de componentes bonitos
(`QTable`, `VForm`) y tú cambias tus `<div>` por los suyos. "Migrar a Quasar"
significa *reescribir la vista con sus piezas*.

Nuxt es otra categoría de bicho. Es un **meta-framework**: un armazón que envuelve a
Vue y le añade **infraestructura** — routing automático, renderizado en servidor,
una convención de carpetas, un sistema de plugins. No toca tus `<template>`. Toca
**el ciclo de vida de la aplicación entera**.

La consecuencia práctica, que hay que interiorizar ya:

| Pregunta | Quasar / Vuetify | **Nuxt** |
|---|---|---|
| ¿Cambian mis componentes? | Sí, usas los suyos | **No. Los tuyos, igual** |
| ¿Qué me da el framework? | Componentes de UI | **Estructura + SSR + routing** |
| "Migrar el CRUD" significa… | Reescribir el form con sus inputs | **Nada. El form no cambia** |
| ¿Qué tengo que reaprender? | Un vocabulario de componentes | **Dónde y cuándo corre mi código** |

Por eso esta ruta **no tiene** "tabla de componentes equivalentes". No hay nada que
equivaler a nivel de UI. La equivalencia de Nuxt es de **estructura** (dónde vive
cada archivo) y de **momento de ejecución** (en qué entorno corre). Guárdate esa
distinción: es la brújula de todo lo que viene.

## 🧠 Concepto 2: los tres modos — y por qué elegimos `universal`

Nuxt 2 puede construir tu app de tres maneras. La diferencia es **quién genera el
HTML y cuándo**:

| Modo | Quién pinta el HTML | Cuándo | Es como… |
|---|---|---|---|
| `spa` | El navegador | En tiempo de ejecución, tras cargar el JS | Tu Mini Jira de F1–F11 |
| `universal` (**el nuestro**) | El **servidor Node**, la primera vez; luego el navegador | En cada request + al navegar | SSR de verdad |
| `static` | Se pre-genera **en el build** | Una sola vez, al desplegar | Un sitio estático con hidratación |

El modo `spa` **no enseña nada nuevo**: es exactamente lo que ya sabes hacer a pelo,
solo que con la estructura de carpetas de Nuxt encima. Si eligiéramos `spa`, esta
ruta sería "el mismo curso con otro layout de archivos" — un desperdicio.

**Elegimos `universal` porque SSR *es* la lección.** Es lo que mete el servidor Node
en la ecuación, lo que hace que tu `created()` corra donde no hay `window`, lo que
rompe la auth de F2. Todo lo interesante de esta ruta nace de haber elegido
`universal`. Los otros dos modos existen; los nombramos y seguimos.

> 🔎 **Qué hace `universal`:** en el primer request, el servidor Node ejecuta tu
> app, genera el HTML **ya pintado** y se lo manda al navegador. El usuario ve
> contenido al instante (bueno para SEO y para el *time-to-first-byte*). Luego el
> JS carga y el navegador "revive" ese HTML — eso es la **hidratación**, y es la
> fuente de la mitad de los dolores de NX2.

## 🧠 Concepto 3: ⭐⭐ el ciclo de vida se ejecuta DOS VECES

Este es **el** concepto. Si te llevas una sola cosa de la fase, es esta. Dedícale el
tiempo que haga falta, porque reordena todo lo que creías saber del ciclo de vida de
Vue.

En tu Mini Jira a pelo, cuando un componente nace, `beforeCreate → created →
beforeMount → mounted` corren **una vez, en el navegador**. Punto. Ese es el único
mundo que existía.

En Nuxt `universal`, tu componente **nace dos veces**:

```
        ┌─────────────── SERVIDOR (Node) ───────────────┐   ┌──── CLIENTE (navegador) ────┐
        │                                                │   │                             │
  ►─────┤  beforeCreate()   ✅ corre aquí                │   │  beforeCreate()  ✅ otra vez │
        │  created()        ✅ corre aquí                │   │  created()       ✅ otra vez │
        │                                                │   │  beforeMount()   ✅          │
        │  (NO hay mounted en el servidor)               │   │  mounted()       ✅ SOLO aquí│
        │  (NO hay window, document, localStorage)       │   │  (aquí SÍ hay window)        │
        └────────────────────────────────────────────────┘   └─────────────────────────────┘
                     │                                                    ▲
                     └──────── manda el HTML ya pintado ──────────────────┘
                                    (hidratación)
```

Lo que tienes que grabarte:

- **`beforeCreate()` y `created()` corren en el SERVIDOR *y* en el CLIENTE.**
  Dos ejecuciones. Si metes ahí algo que toque el navegador, en el servidor
  **revienta** — porque en Node no existe `window`.
- **`mounted()` corre SOLO en el CLIENTE.** El servidor nunca monta nada en un DOM
  (no hay DOM en Node). `mounted` es tu zona segura, el único hook donde el
  navegador ya existe con seguridad.

De ahí sale la **regla de oro** de toda la ruta:

> 🌟 **Todo lo que toque `window`, `document`, `localStorage`, `navigator` o
> cualquier API del navegador va en `mounted()`. Nunca en `created()`.**

Ejemplos de lo que rompe si lo pones en `created()`:

```js
// 💥 EN created(): revienta en el servidor
created: function () {
  var token = localStorage.getItem("token"); // ❌ localStorage no existe en Node
  this.width = window.innerWidth;             // ❌ window no existe en Node
}

// ✅ EN mounted(): a salvo, solo corre en el navegador
mounted: function () {
  var token = localStorage.getItem("token"); // ok, aquí hay navegador
  this.width = window.innerWidth;             // ok
}
```

No vamos a arreglar nada hoy — solo a **reconocer el patrón al leer**. Cuando abras
un componente Nuxt ajeno y veas `mounted()` haciendo cosas que "deberían" estar en
`created()`, ya sabes por qué: quien lo escribió estaba huyendo del servidor.

---

## 🧩 Mini repaso: el tour por las carpetas mágicas

Nuxt funciona por **convención sobre configuración**. Cada carpeta con nombre
reservado tiene un significado, y Nuxt la lee sola — sin que tú registres nada.
Este es el mapa. Léelo como quien aprende a moverse por una ciudad nueva.

### `create-nuxt-app` — de dónde sale todo esto

```bash
npx create-nuxt-app mini-jira-nx
# En el asistente, elige:
#   Rendering mode:  Universal (SSR / SSG)   ← la lección
#   Vuex:            Yes
#   Axios:           Yes  (@nuxtjs/axios)
#   Testing:         Jest
```

Y la estructura que te genera — **fíjate en lo que NO está**:

```
mini-jira-nx/
├── nuxt.config.js      ← ⭐ el nuevo main.js + vue.config.js
├── pages/              ← ⭐ el routing sale de AQUÍ (carpetas = rutas)
│   └── index.vue
├── layouts/            ← default.vue sustituye a App.vue
│   └── default.vue
├── plugins/            ← ⭐ aquí se inyecta axios y sus interceptores
├── store/              ← Vuex de fábrica, con OTRA sintaxis de módulos
├── middleware/         ← los guards de F2 viven aquí
├── components/         ← tus componentes normales (igual que siempre)
├── static/             ← assets servidos tal cual
└── package.json

  ❌ NO hay main.js
  ❌ NO hay App.vue
  ❌ NO hay router/index.js
  ❌ NO hay src/
```

Esa lista de "no hay" es la primera cosa que descoloca. Vamos carpeta por carpeta.

### `nuxt.config.js` — dónde se fue `main.js`

Todo lo que en el curso base hacías en `main.js` (registrar plugins globales,
configurar el título, meta tags, CSS global) y en `vue.config.js` (build, proxy,
alias) vive ahora aquí, en un **objeto de configuración declarativo**:

```js
// nuxt.config.js
export default {
  ssr: true,                         // modo universal
  head: {                            // lo que hacías con vue-meta / <title>
    title: 'Mini Jira',
    meta: [{ charset: 'utf-8' }]
  },
  css: ['bootstrap/dist/css/bootstrap.css'],  // CSS global (antes en main.js)
  plugins: [                         // ⭐ tus plugins, registrados aquí
    '~/plugins/axios-interceptors'
  ],
  modules: ['@nuxtjs/axios'],        // módulos de Nuxt (axios oficial)
  axios: {
    baseURL: 'http://localhost:3000' // lo que configurabas en apiClient
  }
}
```

> 🔎 **Qué hace:** es el panel de control central. No hay `new Vue({...}).$mount()`
> por ningún lado — Nuxt hace ese arranque por ti, leyendo esta config. Cuando
> busques "dónde se registra X globalmente" en un repo Nuxt, empieza siempre aquí.

### ⭐ `pages/` — el routing sale de las CARPETAS

La joya de la corona. **Adiós `router/index.js`, adiós el array de `routes`.** En
Nuxt, la estructura de archivos de `pages/` **ES** el router. Nuxt la lee y genera
la configuración de rutas sola:

```
pages/
├── index.vue              →  /
├── login.vue              →  /login
└── tickets/
    ├── index.vue          →  /tickets
    └── _id.vue            →  /tickets/:id     ← el _ es el parámetro dinámico
```

- Un archivo `.vue` en `pages/` **es** una ruta.
- Una carpeta anida el path.
- Un archivo o carpeta que empieza por `_` es un **parámetro dinámico**:
  `_id.vue` → `:id`. Ese `_id` de F5 (`/tickets/:id`) que definías a mano en el
  router, ahora es literalmente el nombre del archivo.

> ✅ **Buenas prácticas de lectura:** para saber qué URLs existen en un proyecto
> Nuxt, no busques un archivo de rutas — **mira el árbol de `pages/`**. El árbol
> es el mapa de rutas. Punto.

### `layouts/default.vue` — el nuevo `App.vue`

Tu `App.vue` era el cascarón: header, sidebar, y un `<router-view>` en medio donde
se pintaba la vista actual. En Nuxt ese cascarón es `layouts/default.vue`, y el
hueco se llama `<Nuxt />`:

```html
<!-- layouts/default.vue -->
<template>
  <div>
    <AppHeader />
    <Nuxt />        <!-- aquí se pinta la página actual (era <router-view/>) -->
  </div>
</template>
```

Puedes tener varios layouts (`default.vue`, `empty.vue` para el login sin header) y
una página elige el suyo con `layout: 'empty'`. Pero el mapa mental es directo:
**`App.vue` → `layouts/default.vue`, `<router-view/>` → `<Nuxt/>`**.

### ⭐ `plugins/` — dónde vive ahora axios (y sus interceptores de F2)

En el curso base, tu `apiClient` creaba la instancia de axios y le pegaba el
interceptor que adjuntaba el Bearer token (F2). Todo eso se registraba en `main.js`.

En Nuxt, eso es un **plugin**: un archivo en `plugins/` que Nuxt ejecuta al
arrancar, con acceso al **contexto** de la app:

```js
// plugins/axios-interceptors.js
export default function ({ $axios, store, redirect }) {
  $axios.onRequest(function (config) {
    // el interceptor de F2 que adjunta el token — vive aquí ahora
    var token = store.state.auth.token;
    if (token) config.headers.Authorization = 'Bearer ' + token;
    return config;
  });
}
```

Y aquí aparece un detalle **clave** que vas a necesitar leer bien:

> ⭐ **`mode: 'client'` vs `mode: 'server'`** — un plugin se puede marcar para que
> corra **solo en el navegador** o **solo en el servidor**. Se declara en
> `nuxt.config.js`:
>
> ```js
> plugins: [
>   { src: '~/plugins/axios-interceptors' },              // ambos entornos
>   { src: '~/plugins/solo-navegador', mode: 'client' },  // SOLO cliente
>   { src: '~/plugins/solo-servidor', mode: 'server' }    // SOLO servidor
> ]
> ```

¿Por qué importa? Porque un plugin que toque `localStorage` o `window` (como el de
la auth de F2) **no puede correr en el servidor** — reventaría. `mode: 'client'` es
la forma de decir "esto solo tiene sentido en el navegador". Hoy solo lo reconoces;
en NX2 lo vas a necesitar de verdad.

### `store/` — Vuex de fábrica, otra sintaxis de módulos

Buena noticia: **Vuex viene incluido**, no lo instalas ni lo registras. Mala (o
rara) noticia: la sintaxis de módulos cambia. En el curso base tenías un
`store/index.js` con `new Vuex.Store({ modules: { tickets, auth } })`. En Nuxt,
**cada archivo dentro de `store/` es automáticamente un módulo**:

```
store/
├── index.js       →  el módulo raíz (state, mutations, actions "root")
├── tickets.js     →  módulo 'tickets'  (namespaced automáticamente)
└── auth.js        →  módulo 'auth'
```

Y **no exportas una `Store`** — exportas las piezas sueltas:

```js
// store/tickets.js  — fíjate: no hay "new Vuex.Store", solo las partes
export const state = function () {
  return { list: [] };
};
export const mutations = {
  SET_TICKETS: function (state, tickets) { state.list = tickets; }
};
export const actions = {
  // ...
};
```

De momento solo reconócelo. La **tensión** entre este store y la forma Nuxt de
cargar datos (`asyncData`) es el corazón de NX3 — no la tocamos aquí.

### `middleware/` — los guards de F2, mudados

Tu guard de navegación de F2 (el `beforeEach` que revisaba el token y redirigía a
`/login`) ahora vive en `middleware/`:

```js
// middleware/auth.js
export default function ({ store, redirect }) {
  if (!store.state.auth.token) {
    return redirect('/login');
  }
}
```

Y se activa en una página con `middleware: 'auth'`, o global desde
`nuxt.config.js`. Mismo trabajo que el guard de F2, otra dirección.

### La tabla que resume todo (memorízala)

Esta es la **tabla de equivalencias** curso-base → Nuxt. Es lo mínimo que tienes
que llevarte para leer cualquier repo Nuxt sin perderte:

```
┌─────────────────────┬──────────────────────────────────────────────────┐
│  CURSO BASE          │  NUXT                                             │
├─────────────────────┼──────────────────────────────────────────────────┤
│  main.js             │  nuxt.config.js  +  plugins/                      │
│  App.vue             │  layouts/default.vue                              │
│  <router-view/>      │  <Nuxt/>                                           │
│  router/index.js     │  pages/  (las carpetas SON las rutas)             │
│  /tickets/:id        │  pages/tickets/_id.vue                            │
│  guards (beforeEach) │  middleware/                                       │
│  store/index.js      │  store/  (mismo Vuex, módulos con otra sintaxis)  │
│  apiClient + axios   │  @nuxtjs/axios  +  plugins/  (con mode client/srv)│
│  services/           │  igual — pero axios se inyecta desde plugins/     │
│  created()           │  created() — ¡pero corre 2 veces! (srv + cliente) │
│  mounted()           │  mounted() — solo cliente (tu zona segura)        │
└─────────────────────┴──────────────────────────────────────────────────┘
```

---

## ⚠️ Errores y confusiones típicas al leer Nuxt por primera vez

- **"¿Dónde está el router?"** No existe como archivo. El router **es** `pages/`.
  Si buscas `router/index.js`, vas a buscar en vano — mira el árbol de carpetas.
- **"¿Dónde se registra este plugin/componente?"** En Nuxt casi nada se registra a
  mano: la convención de carpetas lo hace. Lo que sí se declara explícito va en
  `nuxt.config.js`. Esos son los dos únicos sitios donde buscar "el registro de X".
- **Confundir `created()` de Nuxt con el de siempre.** Tu instinto de "pongo la
  carga inicial en `created()`" es peligroso aquí: ese hook corre en el servidor,
  donde no hay navegador. Al leer, sospecha de cualquier `created()` que toque el
  DOM.
- **Buscar componentes de Nuxt que no existen.** Si vienes de Quasar, tu ojo busca
  `<n-algo>`. No los hay. `<Nuxt/>` y `<NuxtLink>` (el `<router-link>` de Nuxt) son
  casi los únicos "componentes" que aporta, y son de infraestructura, no de UI.
- **Creer que `store/index.js` monta la Store.** No: exporta `state`/`mutations`/
  `actions` sueltos. Si buscas `new Vuex.Store`, no está — Nuxt lo ensambla solo.
- **Asumir que Nuxt 2 = Nuxt.** Ojo con la documentación: `nuxt.com` sirve Nuxt 3
  (que es **Vue 3**, fuera de este curso). La doc de nuestro Nuxt vive en
  **`v2.nuxt.com`**. Leer doc de Nuxt 3 y aplicarla a Nuxt 2 es una fuente
  infinita de frustración.

> 💸 **Deuda que apuntamos hoy (y pagamos en NX2):** la auth de F2 guarda la sesión
> en `localStorage`. **En el servidor `localStorage` no existe.** En cuanto
> pongamos SSR de verdad, el login se va a romper de raíz — el plugin de axios va a
> intentar leer el token en el servidor y no habrá dónde leerlo. *"El login se
> rompe en cuanto arranca el SSR. Lo pagamos en NX2, cambiando `localStorage` por
> cookies — que sí viajan entre servidor y cliente."* En producción, además, la
> sesión sobre cookies es cosa que **el backend** valida y firma; el front solo la
> transporta.

---

## 🧪 Ejercicios (27)

Todos de **lectura y reconocimiento**. No escribes lógica nueva: abres, navegas,
identificas, traduces. El entregable de casi todos es *"señala dónde"* o
*"explica por qué"*, no *"haz que funcione"*.

**🟢 Fácil (1–8) — orientarse en el mapa**

1. Genera el proyecto con `create-nuxt-app` (preset universal + Vuex + axios +
   Jest). Arráncalo con `npm run dev` y ábrelo en el navegador. Sin tocar nada:
   ¿en qué archivo está el HTML que ves en `/`?
2. Lista, de memoria y luego verificando, las **tres cosas del curso base que NO
   existen** en la estructura Nuxt (`main.js`, `App.vue`, `router/index.js`) y, al
   lado, dónde se fue cada responsabilidad.
3. Dado este árbol de `pages/`, escribe la URL de cada archivo:
   `index.vue`, `login.vue`, `tickets/index.vue`, `tickets/_id.vue`,
   `perfil/ajustes.vue`.
4. Y al revés: para las rutas `/`, `/tickets`, `/tickets/42` y `/login`, escribe el
   archivo de `pages/` que las sirve.
5. Abre `layouts/default.vue`. Identifica el equivalente de tu `<router-view/>` de
   F1. ¿Cómo se llama el componente-hueco?
6. En `nuxt.config.js`, señala **dónde** meterías el CSS de Bootstrap 4 (que en el
   curso base importabas en `main.js`).
7. En la tabla de equivalencias, tapa la columna derecha y reconstrúyela de
   memoria para: `main.js`, `App.vue`, `router/index.js`, guards, `created()`.
8. Marca cada afirmación como V/F y corrige las falsas: (a) "Nuxt trae una tabla
   `NxTable`"; (b) "en Nuxt el routing sale de las carpetas"; (c) "`mounted()`
   corre en el servidor"; (d) "Vuex hay que instalarlo aparte en Nuxt".

**🟡 Intermedio (9–17) — leer con criterio**

9. Traduce mentalmente la ruta `/tickets/:id` de tu F5 al archivo Nuxt que la
   representa. Explica qué papel juega el guion bajo del nombre.
10. Abre un componente cualquiera del curso base que use
    `localStorage.getItem` en `created()`. Sin arreglarlo: explica en dos frases
    **por qué** ese código, tal cual, reventaría bajo Nuxt `universal`, y **en qué
    hook** habría que moverlo.
11. Dado un `plugins/axios-interceptors.js`, identifica: (a) de dónde salen
    `$axios` y `store` (¿los importa o se los inyectan?); (b) qué interceptor de F2
    reconoces ahí.
12. En `nuxt.config.js` te encuentras tres plugins, uno con `mode: 'client'`.
    Explica qué tipo de código esperarías encontrar en ese plugin marcado, y por
    qué NO puede correr en el servidor.
13. Abre `store/tickets.js` de un proyecto Nuxt y compáralo con tu `store/modules/
    tickets.js` del curso base. Lista **tres diferencias de sintaxis** (pista:
    `new Vuex.Store`, cómo se exporta el `state`, el namespacing).
14. Dibuja (ASCII o a mano) el diagrama del ciclo de vida dual para un componente:
    marca qué hooks corren en el servidor, cuáles en el cliente, y el punto de la
    hidratación.
15. Recorre el árbol de `pages/` de un repo Nuxt de ejemplo y **reconstruye el mapa
    de rutas completo** que Nuxt generaría — sin abrir ningún archivo de router
    (porque no lo hay).
16. Localiza en un proyecto Nuxt dónde vive el guard de autenticación de F2. Explica
    cómo se "enchufa" a una página concreta (`middleware: '...'`).
17. Te dan un componente con lógica repartida entre `created()` y `mounted()`.
    Clasifica cada línea en "segura en servidor" o "solo cliente", y di si está en
    el hook correcto.

**🟠 Difícil (18–23) — leer un repo ajeno de verdad**

18. Clona un repo Nuxt 2 público pequeño (o usa uno de ejemplo del equipo). En
    **cinco minutos cronometrados**, sin leer el README, responde: ¿qué URLs
    expone?, ¿dónde se configura axios?, ¿usa middleware de auth?, ¿qué layout
    usa el login? Escribe el mapa que armaste.
19. En ese mismo repo, busca **un `created()` que toque el navegador** (window,
    document, localStorage). Documenta: ¿lo encontraste?, ¿está protegido de
    alguna forma?, ¿o es una bomba de `window is not defined` esperando a NX2?
20. Toma tu tabla de equivalencias y **auditá** un repo Nuxt real contra ella: por
    cada fila, señala el archivo concreto del repo que la cumple. ¿Alguna fila no
    tiene equivalente porque el repo hace algo distinto? Anótalo.
21. Compara `nuxt.config.js` con tu `main.js` + `vue.config.js` del curso base,
    línea a línea: haz una tabla de "esto de main.js → aquí en la config",
    incluyendo CSS global, plugins, y baseURL de axios.
22. Lee `store/index.js` de un proyecto Nuxt y determina: ¿tiene módulo raíz con
    estado propio, o solo actúa de contenedor? ¿Cómo sabrías, leyendo, si
    `store/auth.js` está namespaced? (Pista: en Nuxt lo está por defecto.)
23. Sin ejecutar nada, **predice** qué tres piezas del Mini Jira base van a
    romperse bajo SSR con solo leer el código: busca todo lo que toque `window`,
    `document` o `localStorage` (auth de F2, chart.js de F7, socket.io de F8) y
    haz la lista de "sospechosos para NX2". Ordénalos por gravedad.

**🔴 Muy difícil (24–27) — dominar el modelo mental**

24. **El documento del molde.** Escribe una página (`NUXT-VS-QUASAR.md`) dirigida a
    un compañero que acaba de terminar la ruta Quasar y va a empezar Nuxt. Explícale,
    con sus propias analogías, por qué "migrar el CRUD a Nuxt no significa nada" y
    por qué **no va a haber** tabla de componentes equivalentes. Que quede claro que
    lo que cambia es el *entorno de ejecución*, no la UI. El entregable es el texto.
25. **La caza del `window`.** Recorre el Mini Jira base entero y produce un
    `SSR-RISK-MAP.md`: cada archivo que toca una API del navegador, en qué hook lo
    hace, y una nota de "cómo se leería que está a salvo" vs "cómo se leería que va a
    reventar". No arregles nada — es el mapa de trabajo que NX2 va a consumir.
26. **Reconstrucción a ciegas.** Te dan solo el árbol de carpetas de un proyecto
    Nuxt (sin abrir ni un archivo). A partir del árbol únicamente, redacta: el mapa
    de rutas, qué layouts existen, qué plugins corren y en qué entorno (si el nombre
    lo delata), y qué módulos de store hay. Luego abre los archivos y puntúa tu
    acierto. La lección: **cuánto se lee de un proyecto Nuxt solo por su estructura**.
27. **El puente escrito.** Redacta el "informe de reconocimiento" que le entregarías
    a tu yo de NX2: el mapa completo del proyecto Nuxt, la tabla de equivalencias
    aplicada al Mini Jira, la lista priorizada de lo que va a romperse bajo SSR, y —
    lo importante — **la deuda de la auth explicada**: por qué `localStorage` en el
    servidor es imposible y qué pista tienes ya (cookies) para NX2. Este informe es
    literalmente tu punto de partida de la siguiente fase.

---

## 📚 Referencias

**Documentación oficial (¡OJO — Nuxt 2, no Nuxt 3!)**

- ⚠️ Doc de **Nuxt 2**: https://v2.nuxt.com/  — el dominio raíz `nuxt.com` sirve
  Nuxt 3 (Vue 3). Para este curso, **siempre `v2`**.
- Nuxt 2 — Directory Structure (el tour de carpetas):
  https://v2.nuxt.com/docs/directory-structure/nuxt/
- Nuxt 2 — `pages/` y routing por carpetas:
  https://v2.nuxt.com/docs/features/file-system-routing/
- Nuxt 2 — `nuxt.config.js` (referencia de la config):
  https://v2.nuxt.com/docs/configuration-glossary/configuration-build/
- Nuxt 2 — Plugins (y `mode: client`/`server`):
  https://v2.nuxt.com/docs/directory-structure/plugins/
- Nuxt 2 — Store / Vuex (sintaxis de módulos):
  https://v2.nuxt.com/docs/directory-structure/store/
- Nuxt 2 — Middleware:
  https://v2.nuxt.com/docs/directory-structure/middleware/
- Nuxt 2 — Lifecycle / Rendering (el ciclo dual y SSR):
  https://v2.nuxt.com/docs/concepts/nuxt-lifecycle/
- Vue 2 — ciclo de vida (para contrastar con el de siempre):
  https://v2.vuejs.org/v2/guide/instance.html#Lifecycle-Diagram

**Contexto útil**

- `create-nuxt-app` (el generador): https://github.com/nuxt/create-nuxt-app
- Nota de EOL de Nuxt 2 (**30 de junio de 2024**) — por qué esto ES legacy
  relevante: anuncio oficial con fecha en el blog de Nuxt,
  https://nuxt.com/blog/nuxt2-eol (⚠️ este enlace es informativo sobre el fin de
  vida; la **doc técnica** del curso sigue siendo `v2.nuxt.com`, no `nuxt.com`).

**Orden de lectura sugerido:** Directory Structure (visión general) → File-system
routing (`pages/`) → Nuxt Lifecycle (el concepto central) → volver al proyecto
generado y recorrerlo carpeta por carpeta con la tabla de equivalencias al lado.

---

## 🚀 Cierre — ya sabes leer el mapa. Ahora rómpela.

Sales de esta fase sin haber migrado una sola línea, y aun así con el activo más
importante de toda la ruta: **el modelo mental correcto**. Ahora sabes que Nuxt no
es "Vue con otros botones" — es Vue ejecutándose en dos sitios. Sabes leer un repo
Nuxt ajeno y encontrar el routing (en `pages/`), la config (en `nuxt.config.js`),
la auth (en `middleware/` y `plugins/`) y el store (de fábrica, con otra sintaxis).
Y sabes la regla de oro que lo gobierna todo: **`created()` corre dos veces,
`mounted()` una — lo que toque el navegador va en `mounted()`**.

Te llevas:

- la distinción que evita el error nº1: **meta-framework, no librería de UI** —
  no hay componentes que equivaler, hay *estructura* y *momento de ejecución*;
- la **tabla de equivalencias** curso-base → Nuxt, tu diccionario para cualquier
  repo Nuxt del mundo;
- el **ciclo de vida dual** dibujado en la cabeza, con su regla de oro;
- y una deuda apuntada con nombre y apellido: 💸 **la auth de F2 va a reventar en
  cuanto haya servidor**, porque `localStorage` no existe en Node.

Esa deuda no es un pendiente administrativo: es la **puerta de NX2**. Hasta ahora
solo hemos mirado. En la siguiente fase ponemos el dashboard de F4 en
`pages/tickets/index.vue`, arrancamos el SSR de verdad… y lo vemos reventar con el
error que define al framework entero: **`window is not defined`**. Ya sabes leer la
estructura. Ahora toca romper la app — y aprender a escribir código que sobreviva a
dos entornos. 💥
