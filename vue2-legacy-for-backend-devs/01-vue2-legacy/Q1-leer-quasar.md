# 🔷 Fase Q1 — Leer Quasar

> **Ruta Q · Fase 2 de 5** — Reconocimiento puro. Cero código del Mini Jira.
> Después de esta fase abrís cualquier repo Quasar de la empresa y sabés **dónde está cada cosa**.
> Si tu trabajo es solo *leer* código Quasar (parchear un bug, entender un flujo, revisar un PR), **esta fase te alcanza**. Q2, Q3 y Q4 son para quien va a escribir.

> ### 📍 Venís de Q0
> Ya escribiste la red: tests de **regresión** sobre el CRUD (F5) y el dashboard (F4), **contra el código que vas a borrar**. Esos tests **no se tocan en Q1** — Q1 no escribe una línea del Mini Jira. Vuelven a correr en Q2, verdes o rojos, y ahí te dirán si migraste o si rompiste.
>
> Y una pregunta que Q0 dejó abierta sigue abierta: *"tus tests buscan `.b-table`; `QTable` no la tiene."* Q1 **no** la contesta — solo te da el vocabulario para entenderla. La respuesta es de **Q3**.

---

## 1. 🎯 Propósito

Aprender a **leer** un proyecto Quasar 1.x sin escribir una línea del Mini Jira.

Tu objetivo al terminar: te pasan un repo Quasar, lo clonás, y en 20 minutos podés responder:

- ¿Dónde está el equivalente de `main.js`?
- ¿Dónde se configuró axios y el interceptor de token?
- ¿Dónde están las rutas?
- ¿Por qué este componente `<QBtn>` no aparece en pantalla?
- ¿Esta clase `q-pa-md` es de Bootstrap o de Quasar?

Nada más. Nada menos.

**Antes de empezar: corrijamos la premisa.**

Casi todo el mundo que llega a Quasar desde afuera cree una de estas dos cosas:

> ❌ "Quasar es una librería de formularios bonitos"
> ❌ "Quasar es el Bootstrap de Vue"

Las dos están mal.

**Quasar es dos cosas a la vez, y esa es toda la dificultad:**

| Quasar es… | Qué significa |
|---|---|
| 🎨 **Un framework de UI completo** | ~120 componentes (`QBtn`, `QTable`, `QDialog`, `QLayout`…), sistema de grid propio, clases de spacing propias, tipografía, iconos, dark mode, plugins (`$q.notify`, `$q.dialog`, `$q.loading`) |
| 🏗️ **Un build system completo** | Reemplaza a Vue CLI. Tiene su propio CLI, su propio `quasar.conf.js`, su propio ciclo de arranque (boot files), y compila el **mismo código fuente** a SPA, PWA, SSR, Electron, Cordova o BEX |

El segundo punto es el que te muerde. Vos venís del curso base con un `main.js` donde hacés `new Vue({...})` a mano. En Quasar **ese archivo no existe**. Y no es que esté escondido: es que Quasar lo genera. Vos solo le pasás configuración.

> 🔑 **La frase para memorizar:** en Vue CLI vos armás la app. En Quasar, Quasar arma la app y vos le decís cómo.

---

## 2. ✅ Qué queda al terminar

- Sabés qué es Quasar y qué **no** es.
- Sabés por qué elegimos **Quasar CLI** y no el plugin de Vue CLI (y por qué esa decisión te va a doler un poco, a propósito).
- Distinguís **v0.x / v1.x / v2.x** y sabés en cuál está el código legacy de la empresa.
- Podés correr `quasar create` y **explicar cada carpeta** que genera.
- Ubicás `quasar.conf.js` como el reemplazo de `main.js` + `vue.config.js`.
- Entendés qué es un **boot file** y por qué es el lugar donde va a vivir tu `apiClient` de F2.
- Reconocés el patrón `QLayout > QPageContainer > QPage` y por qué **no es un div con router-view**.
- Sabés que `src/router/routes.js` es el mismo Vue Router 3 de F1, con otro entry point.
- Distinguís el grid de Quasar del de Bootstrap 4 (que son sospechosamente parecidos… hasta que no).
- Sabés usar `this.$q.notify` y `this.$q.dialog`.
- Tenés la **tabla de equivalencias** curso-base → Quasar internalizada.
- Reconocés el error clásico: componente no declarado → **no renderiza y no hay error claro**.

---

## 3. 🚫 Qué NO hacemos acá

- ❌ **No tocamos el Mini Jira.** Cero. Ni un componente. Q1 es reconocimiento.
- ❌ **No tocamos los tests de Q0.** Siguen intactos hasta Q2. En Q1 no hay nada que puedan verificar.
- ❌ **No migramos nada.** Eso es Q2.
- ❌ **No usamos QTable, QForm ni componentes complejos.** Q3.
- ❌ **No hablamos de PWA, SSR, Electron ni Cordova.** Existen, sabelo, seguí.
- ❌ **No Quasar 2.x** (Vue 3, Composition API). Fuera de scope del curso entero.
- ❌ **No sacamos Bootstrap del proyecto.** Se queda. Conviven. La colisión se explota en Q3.
- ❌ **No optimizamos el build.** `quasar.conf.js` tiene 200 líneas y vamos a mirar 6.

---

## 4. 🧠 Concepto

### 4.1 Las tres versiones de Quasar

Vas a googlear un error y vas a caer en un post de 2018. Aprendé a datar el código de un vistazo:

| Versión | Vue | Estado | Cómo la reconocés |
|---|---|---|---|
| **v0.x** (2016–2018) | Vue 2 | 💀 **Muerta.** Sin soporte, docs caídas | Componentes en `kebab-case` sin prefijo claro, `q-layout` con props raras, `quasar.conf.js` distinto o inexistente |
| **v1.x** (2019–2022) | **Vue 2.6** | ✅ **La nuestra.** Options API | `QBtn`, `QLayout`, `quasar.conf.js` con `framework: { components: [...] }` |
| **v2.x** (2021–hoy) | Vue 3 | 🔮 Actual, **fuera de scope** | `quasar.conf.js` **sin** `framework.components` (auto-import), Composition API, `createApp` |

> 🔎 **Qué hace:** la señal más rápida para saber si estás en v1 o v2 es abrir `quasar.conf.js` y buscar `framework: { components: [...] }`.
> - Si hay una **lista larga de componentes** → **v1.x**. Es tu curso.
> - Si `framework` solo tiene `plugins` y `config` → **v2.x**. No es tu curso.

Nosotros usamos **Quasar 1.22.x**, la última v1. Vue 2.6.14. Options API. Igual que todo el curso base.

---

### 4.2 Quasar CLI vs plugin de Vue CLI (y por qué elegimos el difícil)

Hay dos formas de meter Quasar en un proyecto:

**Opción A — Plugin de Vue CLI** (`vue add quasar`)
Tenés un proyecto Vue CLI normal (con su `main.js`, su `vue.config.js`) y le enchufás Quasar como una librería de componentes más. Todo lo que aprendiste en F0–F11 sigue igual. Solo agregás componentes.

**Opción B — Quasar CLI** (`@quasar/app`, con `quasar create`)
Quasar **es** el proyecto. Se lleva puesto tu `main.js`, tu `vue.config.js` y tu estructura de carpetas. Te da a cambio: boot files, layouts, modos de build, HMR más rápido, y una convención rígida.

**Elegimos B. A propósito. Sabiendo que es más incómodo.**

Razón, sin vueltas:

> 🔑 **La fricción ES el contenido.**
> El plugin de Vue CLI te ahorra la fricción — y con eso te ahorra el aprendizaje. Si hacés `vue add quasar`, tu `main.js` sigue ahí, tus imports siguen ahí, y nunca vas a entender qué es un boot file. Vas a saber usar `<QBtn>` y nada más.
>
> Pero el código legacy de la empresa **está en Quasar CLI**. Cuando abras ese repo y no encuentres `main.js`, vas a entrar en pánico. Ese pánico es lo que Q1 elimina.

Además, seamos honestos: casi nadie usa el plugin de Vue CLI en producción. Quasar CLI es lo que vas a encontrar.

---

### 4.3 `quasar create` y lo que genera

```bash
npm i -g @quasar/cli@1
quasar create mini-jira-q
```

Te pregunta cosas. Para este curso, respondé:

| Pregunta | Respuesta | Por qué |
|---|---|---|
| CSS preprocessor | **Sass with SCSS syntax** | Es el default de la mayoría de repos legacy |
| Features | **ESLint**, **Vuex**, **Axios** | Vuex 3 (F10), axios (F2). Sin TypeScript, sin Composition |
| Icon set | **Material Icons** | Default de Quasar 1 |
| Quasar language pack | **es** o **en-us** | Da igual |
| ESLint preset | **Standard** | El que menos ruido hace |
| Build mode | **SPA** | No PWA. No SSR. Q1 es SPA y punto |

Lo que sale:

```
mini-jira-q/
├── quasar.conf.js          ← 🔥 el archivo. Acá vive todo lo de main.js + vue.config.js
├── package.json
├── .eslintrc.js
├── src/
│   ├── App.vue             ← existe, pero está VACÍO (solo <router-view/>)
│   ├── boot/               ← 🔥 acá va apiClient + interceptores (F2)
│   │   └── axios.js
│   ├── components/         ← igual que el curso base
│   ├── css/
│   │   ├── app.scss
│   │   └── quasar.variables.scss
│   ├── layouts/            ← 🔥 concepto nuevo. NO existe en Vue CLI
│   │   └── MainLayout.vue
│   ├── pages/              ← lo que en el curso base eran "vistas"
│   │   ├── Index.vue
│   │   └── Error404.vue
│   ├── router/
│   │   ├── index.js        ← NO lo tocás casi nunca
│   │   └── routes.js       ← 🔥 acá SÍ. Mismo Vue Router 3 de F1
│   └── store/              ← Vuex 3. Igual que F10. Cero sorpresas
├── public/
└── dist/                   ← el build
```

> 🔎 **Qué hace:** notá lo que **NO está**.
> - **No hay `main.js`.** Quasar lo genera en tiempo de build.
> - **No hay `vue.config.js`.** Su lugar lo ocupa `quasar.conf.js`.
> - **No hay `index.html` "tuyo"** — hay `src/index.template.html`, que es un template, no el archivo final.
>
> Si venís de F0/F1 y buscás `main.js` desesperadamente: **no está y no va a estar**. Dejá de buscar.

---

### 4.4 `quasar.conf.js` — el archivo que reemplaza todo

Es el corazón. Y es un archivo **enorme** (~200 líneas con comentarios). No lo leas entero. Buscá estas 5 llaves:

```js
// quasar.conf.js
module.exports = function (ctx) {
  return {

    // 1️⃣ BOOT FILES — el reemplazo de main.js
    // Cada string acá = un archivo en src/boot/
    // Se ejecutan ANTES de montar la app, en orden
    boot: [
      'axios'          // 🔥 → src/boot/axios.js
    ],

    // 2️⃣ CSS GLOBAL
    css: [
      'app.scss'       // → src/css/app.scss
    ],

    // 3️⃣ EXTRAS (fonts, icon packs)
    // 🔎 Estos strings los sirve el paquete @quasar/extras (1.x), que
    //    quasar create instala junto con quasar y @quasar/app. Es donde
    //    viven los icon packs (material-icons, fontawesome, mdi) y las fonts.
    extras: [
      'material-icons'
    ],

    // 4️⃣ FRAMEWORK — 🔥🔥 EL PUNTO CRÍTICO DE QUASAR 1
    framework: {
      iconSet: 'material-icons',
      lang: 'es',

      // ⚠️⚠️ ACÁ ESTÁ EL ERROR CLÁSICO. Ver sección 6.
      // En Quasar 1, TODO componente que uses en un <template>
      // TIENE que estar declarado acá. Si no está, no renderiza.
      components: [
        'QLayout',
        'QHeader',
        'QDrawer',
        'QPageContainer',
        'QPage',
        'QToolbar',
        'QToolbarTitle',
        'QBtn',
        'QIcon',
        'QList',
        'QItem',
        'QItemSection',
        'QItemLabel'
      ],

      directives: [
        'Ripple',
        'ClosePopup'
      ],

      // Plugins = las cosas que después usás como this.$q.algo
      plugins: [
        'Notify',        // → this.$q.notify()
        'Dialog',        // → this.$q.dialog()
        'Loading'        // → this.$q.loading.show()
      ]
    },

    // 5️⃣ BUILD — el reemplazo de vue.config.js
    build: {
      vueRouterMode: 'hash',   // 'hash' | 'history' (F1)
      extendWebpack (cfg) {
        // acá metés lo que en Vue CLI iba en configureWebpack (A5)
      }
    },

    devServer: {
      port: 8080,
      open: true,
      proxy: {                 // el mismo proxy de json-server (F3)
        '/api': {
          target: 'http://localhost:3000',
          changeOrigin: true,
          pathRewrite: { '^/api': '' }
        }
      }
    },

    // Modo SPA. Ignorá pwa, ssr, electron, cordova.
    animations: [],
    ssr: {},
    pwa: {},
    electron: {}
  }
}
```

> ✅ **Buenas prácticas al leer un `quasar.conf.js` ajeno:**
> 1. Mirá `boot:` → te dice **qué se inicializa** antes de arrancar la app.
> 2. Mirá `framework.plugins:` → te dice **qué `$q.*` podés usar**.
> 3. Mirá `framework.components:` → si un componente **no está ahí**, no lo vas a poder usar. Es tu primera línea de debugging.
> 4. Mirá `build.vueRouterMode:` → te dice si las URLs llevan `#` o no.
> 5. Mirá `devServer.proxy:` → te dice **contra qué backend pega en dev** (acá, json-server de F3).
> 6. El resto (`ssr`, `pwa`, `electron`, `cordova`) **ignoralo** si el proyecto es SPA.

> 💸 **DEUDA — El proxy de dev (heredada de F3)**
> `devServer.proxy` reescribe `/api` → `http://localhost:3000` **solo en dev**. El `pathRewrite` que le saca el `/api` también. En producción **no hay proxy**: el backend vive en otro dominio, y ahí aparece **CORS** — que en dev el proxy te tapaba.
>
> Es **exactamente** la deuda de **F3**, mudada de `vue.config.js` a `quasar.conf.js`. No cambió el problema, cambió el archivo.
>
> **La frase:** *"El `pathRewrite` no viaja contigo al deploy. Eso lo arregla infra (o una `baseURL` distinta por entorno), no vos."*
> No se paga en la ruta: es infra, igual que en el tronco.

---

### 4.5 Boot files — dónde vive ahora tu `apiClient`

En el curso base, tu `main.js` de F2 hacía algo así:

```js
// ❌ main.js — CURSO BASE (F2). En Quasar esto NO EXISTE.
import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import apiClient from './services/apiClient'

apiClient.interceptors.request.use(function (config) {
  const token = store.state.auth.token
  if (token) {
    config.headers.Authorization = 'Bearer ' + token
  }
  return config
})

Vue.prototype.$api = apiClient

new Vue({
  router,
  store,
  render: function (h) { return h(App) }
}).$mount('#app')
```

En Quasar, la parte de `new Vue({...})` **la hace Quasar**. Vos solo aportás la parte del medio. Y eso va en un **boot file**:

```js
// ✅ src/boot/axios.js — QUASAR
import Vue from 'vue'
import axios from 'axios'

// El apiClient de F2. Idéntico. Cero cambios.
const apiClient = axios.create({
  baseURL: '/api',
  timeout: 10000
})

// 🔎 Un boot file exporta una función que recibe { app, router, store, Vue }
//    Se ejecuta ANTES de montar la app.
//    Acá tenés acceso al store SIN import circular. Ese es el punto.
export default function ({ app, router, store, Vue }) {

  // El interceptor de F2. Idéntico.
  apiClient.interceptors.request.use(function (config) {
    const token = store.state.auth.token
    if (token) {
      config.headers.Authorization = 'Bearer ' + token
    }
    return config
  })

  // Interceptor de respuesta (F2): 401 → logout
  apiClient.interceptors.response.use(
    function (response) { return response },
    function (error) {
      if (error.response && error.response.status === 401) {
        store.dispatch('auth/logout')
        router.push('/login')
      }
      return Promise.reject(error)
    }
  )

  // Lo que en el curso base era Vue.prototype.$api
  Vue.prototype.$api = apiClient
}

// Se exporta también suelto para importarlo desde services/
export { apiClient }
```

> 🔎 **Continuidad — el token se lee del STORE, no de `localStorage`.** Ojo con
> esto, porque **cambia respecto a F2**. En el tronco, el interceptor y el guard
> leían `localStorage.getItem("token")` directo (F2 lo dejó así a propósito, para
> evitar líos de orden de inicialización entre router y store; su ejercicio 24
> proponía justamente pasar a "el store es la única fuente de verdad"). En Quasar
> **ese ejercicio 24 se vuelve gratis**: el boot file recibe el `store` ya
> construido por parámetro, así que leer `store.state.auth.token` no tiene coste
> de orden. Aprovechamos el cambio de casa para hacer la limpieza que F2 dejó
> pendiente. **Misma verdad, mejor fuente** — el `localStorage` sigue existiendo
> como *persistencia* (lo escribe el `authService` de F2 al loguear y lo hidrata
> al store al arrancar), pero quien pregunta "¿hay token?" ahora es el store, no
> el navegador. Si copias el interceptor de F2 tal cual (`localStorage`) también
> funciona; el del curso Q usa el store por coherencia con el boot file.

Y para que se ejecute, tiene que estar registrado:

```js
// quasar.conf.js
boot: [ 'axios' ]   // ← el nombre del archivo, sin .js
```

> 🔎 **Qué hace:** el boot file es un **hook de arranque**. Quasar lo llama antes de `new Vue()`, le pasa el `router` y el `store` ya construidos, y espera (puede ser `async`) a que termine.
>
> 🔑 **El equivalente mental:**
> `main.js` (curso base) = `src/boot/*.js` (Quasar) + lo que Quasar genera solo.
>
> La diferencia importante: en Quasar **no tenés que importar el store** dentro del boot file. Te lo pasan. Eso mata la dependencia circular clásica de `apiClient → store → apiClient`.

> ✅ **Buena práctica:** un boot file por responsabilidad. `axios.js`, `i18n.js`, `auth-guard.js`. No metas todo en uno.

---

### 4.6 Layouts — `QLayout > QPageContainer > QPage`

Este es el concepto que **no existe** en el curso base y el que más confunde.

En F1, tu `App.vue` era esto:

```vue
<!-- ❌ App.vue — CURSO BASE (F1) -->
<template>
  <div id="app">
    <nav class="navbar navbar-dark bg-dark">...</nav>
    <div class="container mt-4">
      <router-view />
    </div>
  </div>
</template>
```

Navbar arriba, `router-view` abajo, todo dentro de un div. Sencillo.

En Quasar, tu `App.vue` es **esto**:

```vue
<!-- ✅ App.vue — QUASAR. Sí, es todo. -->
<template>
  <router-view />
</template>

<script>
export default {
  name: 'App'
}
</script>
```

**Vacío.** El chrome de la app (navbar, sidebar, footer) **no vive en `App.vue`**. Vive en un **layout**, que es un componente más, que se monta **desde el router**.

```vue
<!-- src/layouts/MainLayout.vue -->
<template>
  <!--
    🔎 QLayout es el contenedor raíz de una "pantalla completa".
       La prop `view` es un string de 9 letras (LHh Lpr lFf) que le dice a Quasar
       cómo se comportan header/footer/drawers respecto al contenido.
       No lo memorices. "hHh LpR fFf" es el default sano.
  -->
  <q-layout view="hHh LpR fFf">

    <!-- 🔎 QHeader = el navbar. Quasar lo posiciona fijo y le reserva espacio. -->
    <q-header elevated class="bg-primary text-white">
      <q-toolbar>
        <q-btn flat dense round icon="menu" @click="drawer = !drawer" />
        <q-toolbar-title>Mini Jira</q-toolbar-title>
        <q-btn flat label="Salir" @click="logout" />
      </q-toolbar>
    </q-header>

    <!-- 🔎 QDrawer = el sidebar. side="left", v-model controla abierto/cerrado. -->
    <q-drawer v-model="drawer" show-if-above bordered>
      <q-list>
        <q-item clickable to="/tickets">
          <q-item-section avatar><q-icon name="list" /></q-item-section>
          <q-item-section>Tickets</q-item-section>
        </q-item>
      </q-list>
    </q-drawer>

    <!--
      🔥 QPageContainer: OBLIGATORIO.
         Es el que le calcula el padding correcto al contenido para que
         NO quede tapado por el header y el drawer.
         Si te lo olvidás, tu contenido se mete DEBAJO del navbar.
    -->
    <q-page-container>
      <router-view />   <!-- ← acá se monta la QPage hija -->
    </q-page-container>

  </q-layout>
</template>

<script>
export default {
  name: 'MainLayout',
  data: function () {
    return {
      drawer: false
    }
  },
  methods: {
    logout: function () {
      this.$store.dispatch('auth/logout')
      this.$router.push('/login')
    }
  }
}
</script>
```

Y la página que se monta adentro:

```vue
<!-- src/pages/TicketsPage.vue -->
<template>
  <!--
    🔎 QPage: SIEMPRE la raíz de una página.
       Calcula min-height para llenar el viewport restando header+footer.
       `padding` le mete el spacing estándar de Quasar.
  -->
  <q-page padding>
    <h5>Tickets</h5>
    <!-- contenido -->
  </q-page>
</template>
```

**La jerarquía es rígida y no negociable:**

```
App.vue
  └── <router-view/>
       └── MainLayout.vue          ← QLayout (montado por el router)
            ├── QHeader
            ├── QDrawer
            └── QPageContainer
                 └── <router-view/>
                      └── TicketsPage.vue   ← QPage (ruta hija)
```

> ⚠️ **Los dos errores de novato con layouts:**
> 1. **Olvidar `QPageContainer`** → tu contenido queda debajo del header, tapado. No hay error en consola. Solo se ve mal.
> 2. **No usar `QPage` como raíz de la página** → se pierde el `min-height` y el padding. La página se ve "chiquita" y el footer sube.

> 🔑 **La frase:** `QLayout` NO es un div con `router-view`. Es un **sistema de layout** que hace cálculos de posicionamiento. `QPageContainer` es el que sabe cuánto mide tu header. Si te lo salteás, nadie le avisa a nadie.

---

### 4.7 `src/router/routes.js` — el mismo Vue Router 3, otro entry point

Buena noticia: **no cambia nada de F1**. Vue Router 3, mismo API, mismos guards.

Lo único distinto: **dónde** escribís las rutas.

```js
// src/router/index.js — 🔒 casi nunca lo tocás
import Vue from 'vue'
import VueRouter from 'vue-router'
import routes from './routes'

Vue.use(VueRouter)

// 🔎 Quasar exporta una FUNCIÓN, no una instancia.
//    (Es por SSR: cada request necesita su propio router.)
//    Aunque estemos en SPA, la convención se mantiene.
export default function (/* { store, ssrContext } */) {
  const Router = new VueRouter({
    scrollBehavior: function () { return { x: 0, y: 0 } },
    routes: routes,
    mode: process.env.VUE_ROUTER_MODE,       // ← viene de quasar.conf.js
    base: process.env.VUE_ROUTER_BASE
  })
  return Router
}
```

```js
// src/router/routes.js — 🔥 ACÁ SÍ trabajás
const routes = [
  {
    path: '/',
    component: function () { return import('layouts/MainLayout.vue') },  // ← LAYOUT como padre
    children: [
      { path: '', redirect: '/tickets' },
      { path: 'tickets', component: function () { return import('pages/TicketsPage.vue') } },
      { path: 'tickets/:id', component: function () { return import('pages/TicketDetail.vue') } }
    ]
  },
  {
    path: '/login',
    component: function () { return import('layouts/BlankLayout.vue') },  // ← OTRO layout, sin navbar
    children: [
      { path: '', component: function () { return import('pages/LoginPage.vue') } }
    ]
  },
  {
    path: '*',
    component: function () { return import('pages/Error404.vue') }
  }
]

export default routes
```

> 🔎 **Qué hace:** notá el **patrón layout-como-ruta-padre**. Esto es Vue Router 3 puro (rutas anidadas de F1) — Quasar no inventó nada. Lo que aporta es la **convención**: el padre es siempre un layout, los hijos son siempre páginas.
>
> Esto te da gratis algo que en el curso base tenías que hackear: **layouts distintos por sección**. Login sin navbar, dashboard con navbar. En F1 lo hacías con un `v-if` feo en `App.vue`. Acá es una ruta más.

> ✅ **Buena práctica:** los alias `layouts/` y `pages/` son de Quasar (los define en su webpack). No son `@/layouts/`. Si copiás código del curso base con `@/components/Algo.vue`, va a fallar. En Quasar el alias es `components/Algo.vue` (sin `@/`).

---

### 4.8 Grid Quasar vs Bootstrap 4 — la trampa de las clases parecidas

Acá viene el momento incómodo. Quasar y Bootstrap tienen **grids que se parecen mucho**. Y en nuestro proyecto **conviven los dos** (Bootstrap se queda, se explota en Q3).

**Lo que SE PARECE (y funciona igual):**

```html
<!-- Bootstrap 4 -->
<div class="row">
  <div class="col-md-6">A</div>
  <div class="col-md-6">B</div>
</div>

<!-- Quasar -->
<div class="row">
  <div class="col-md-6">A</div>
  <div class="col-md-6">B</div>
</div>
```

Sí. **Idénticos.** Quasar 1 también usa `row` / `col-{bp}-{n}` con 12 columnas. Un dev de Bootstrap puede escribir grid Quasar sin darse cuenta.

**Lo que NO se parece:**

| Concepto | Bootstrap 4 | Quasar 1 |
|---|---|---|
| Contenedor | `<div class="container">` | ❌ **No existe.** El ancho lo maneja `QPage` |
| Gutters | Automáticos (padding en `.col`) | ❌ **Cero por defecto.** Tenés que agregar `q-gutter-md` o `q-col-gutter-md` |
| Spacing | `mt-3`, `p-2`, `mx-auto` | `q-mt-md`, `q-pa-sm`, `q-mx-auto` |
| Escala de spacing | `0..5` (numérica) | `none/xs/sm/md/lg/xl` (semántica) |
| Alineación flex | `justify-content-center` | `justify-center` |
| Texto | `text-center`, `text-muted` | `text-center` ✅ igual, pero `text-grey-7` |
| Colores | `bg-primary`, `text-danger` | `bg-primary` ✅ igual, pero `text-negative` |
| Ocultar | `d-none d-md-block` | `hidden`, `gt-sm`, `lt-md` |

**Tabla de traducción rápida de spacing:**

```
Bootstrap        Quasar
─────────────────────────────
mt-0    →   q-mt-none
mt-1    →   q-mt-xs
mt-2    →   q-mt-sm
mt-3    →   q-mt-md
mt-4    →   q-mt-lg
mt-5    →   q-mt-xl

p-3     →   q-pa-md      (all)
px-3    →   q-px-md      (horizontal)
py-3    →   q-py-md      (vertical)
```

> ⚠️ **La trampa que te va a morder:**
> `q-pa-md` **NO es Bootstrap.** No busques `pa-md` en la doc de Bootstrap, no existe.
> `p-3` **NO es Quasar.** Si el proyecto no tiene Bootstrap cargado, `p-3` no hace nada.
>
> Y como en nuestro proyecto **conviven los dos**, `p-3` y `q-pa-md` **ambos funcionan**. En el mismo template. Lo cual es exactamente el tipo de cosa que ves en código legacy real y que te hace dudar de tu cordura.

> 💸 **DEUDA — Convivencia Bootstrap + Quasar**
> Tener las dos librerías de CSS cargadas es **~30KB extra de CSS muerto** y una fuente permanente de bugs visuales (Bootstrap tiene un `box-sizing` y un `reboot` que pisan cosas de Quasar).
>
> **En producción esto NO se hace.** Se migra el CSS a un solo sistema y se saca el otro del bundle. Lo dejamos así **a propósito** porque es exactamente el estado en el que vas a encontrar los proyectos legacy de la empresa: alguien empezó a migrar a Quasar, no terminó, y quedaron los dos.
>
> **La frase:** *"El día que borres Bootstrap del `package.json` y no se rompa nada, terminaste la migración."*
> Lo pagamos en **Q3**.

---

### 4.9 `$q` — los plugins que reemplazan tu código de F4/F5

En el curso base, cuando querías avisar algo, hacías esto:

```js
// ❌ CURSO BASE — F5. Componente de alerta hecho a mano.
this.mensaje = 'Ticket creado'
this.tipoAlerta = 'success'
this.mostrarAlerta = true
setTimeout(function () { this.mostrarAlerta = false }.bind(this), 3000)
```

Y para confirmar un borrado:

```js
// ❌ CURSO BASE — F5. Modal de Bootstrap + estado a mano.
this.ticketAEliminar = ticket
this.mostrarModalConfirmacion = true
// ...y después un método confirmarEliminacion(), y otro cancelar(), y un <div class="modal">...
```

En Quasar, eso es una línea:

```js
// ✅ QUASAR — Notify
this.$q.notify({
  message: 'Ticket creado',
  color: 'positive',      // positive | negative | warning | info
  icon: 'check_circle',
  position: 'top-right',
  timeout: 3000
})
```

```js
// ✅ QUASAR — Dialog (devuelve una Promise-like con .onOk() / .onCancel())
this.$q.dialog({
  title: 'Confirmar',
  message: '¿Seguro que querés eliminar el ticket #' + ticket.id + '?',
  cancel: true,
  persistent: true
}).onOk(function () {
  this.$store.dispatch('tickets/eliminar', ticket.id)
}.bind(this))              // 🔎 .bind(this) porque NO usamos arrow (convención del curso)
 .onCancel(function () {
   // no hacemos nada
 })
```

Y también:

```js
this.$q.loading.show({ message: 'Guardando...' })
this.$q.loading.hide()

this.$q.platform.is.mobile   // true/false
this.$q.screen.lt.md         // reactivo: true si viewport < md
this.$q.dark.isActive        // true si dark mode
```

> ⚠️ **`$q` NO viene gratis.** Cada plugin tiene que estar declarado en `quasar.conf.js`:
> ```js
> framework: {
>   plugins: [ 'Notify', 'Dialog', 'Loading' ]
> }
> ```
> Si `Notify` no está en esa lista, `this.$q.notify` es **`undefined`** y vas a tener un `TypeError: this.$q.notify is not a function` en runtime. Ese error al menos es claro. El de la sección 6 no lo es.

---

### 4.10 🔥 TABLA DE EQUIVALENCIAS — curso base → Quasar

**Esto es el núcleo de Q1. Si te llevás una sola cosa, es esto.**

#### Estructura y arranque

| Curso base (F0–F11) | Quasar 1.22 | Nota |
|---|---|---|
| `main.js` | `quasar.conf.js` + `src/boot/*.js` | Quasar genera el `new Vue()` |
| `new Vue({ router, store, render })` | *(no existe, lo hace Quasar)* | — |
| `vue.config.js` | `quasar.conf.js` → `build` + `devServer` | A5 sigue aplicando conceptualmente |
| `configureWebpack` / `chainWebpack` | `build.extendWebpack` / `build.chainWebpack` | Mismo webpack 4 |
| `public/index.html` | `src/index.template.html` | Es un **template**, no el HTML final |
| `.env` / `process.env.VUE_APP_*` | `quasar.conf.js` → `build.env` | Distinto prefijo |
| `npm run serve` | `quasar dev` | |
| `npm run build` | `quasar build` | |
| `@/components/X.vue` (el `@` de F1, vía `jsconfig.json`) | `components/X.vue` | ⚠️ **sin `@/`** — Quasar no define `@` |
| — | `layouts/X.vue`, `pages/X.vue` | Alias nuevos |

#### Componentes y UI

| Curso base (nombres reales de F1) | Quasar 1.22 | Nota |
|---|---|---|
| `App.vue` con navbar + `<router-view>` | `App.vue` = solo `<router-view/>`; el chrome va a `layouts/MainLayout.vue` | Cambio mental grande |
| `components/layout/AppHeader.vue` + `AppSidebar.vue` | `layouts/MainLayout.vue` → `<q-header>` + `<q-drawer>` | Los dos componentes de F1 **se funden** en el layout |
| *(no existe)* | `QLayout > QHeader/QDrawer > QPageContainer > QPage` | Concepto nuevo |
| `views/TicketsView.vue` | `pages/TicketsPage.vue` (raíz = `<q-page>`) | Renombre + raíz obligatoria |
| `<button class="btn btn-primary">` | `<q-btn color="primary" label="..." />` | |
| `<input class="form-control" v-model>` | `<q-input v-model outlined />` | Se ve en Q3 |
| `<table class="table">` | `<q-table :columns :rows>` | Se ve en Q3 |
| `<div class="modal">` (Bootstrap CSS + jQuery) + estado manual | `<q-dialog v-model>` o `this.$q.dialog()` | ⚠️ El tronco **no usa `bootstrap-vue`**: el modal de F5 es CSS+jQuery, no `<b-modal>` |
| `<div class="alert alert-success">` + `setTimeout` | `this.$q.notify({ color: 'positive' })` | |
| `<div class="spinner-border">` | `<q-spinner>` o `this.$q.loading.show()` | |
| `<span class="badge badge-danger">` | `<q-badge color="negative">` o `<q-chip>` | |

#### CSS

| Bootstrap 4 (curso base) | Quasar 1.22 |
|---|---|
| `container` | ❌ no existe — usar `q-page` |
| `row` / `col-md-6` | `row` / `col-md-6` ✅ **igual** |
| *(gutters automáticos)* | `q-gutter-md` / `q-col-gutter-md` (**manual**) |
| `mt-3`, `p-2` | `q-mt-md`, `q-pa-sm` |
| `justify-content-center` | `justify-center` |
| `text-danger` / `text-success` | `text-negative` / `text-positive` |
| `bg-primary` | `bg-primary` ✅ igual |
| `d-none d-md-block` | `hidden` / `gt-sm` |
| `text-muted` | `text-grey-7` |

#### Router / Store / HTTP

| Curso base | Quasar 1.22 | Nota |
|---|---|---|
| Vue Router 3 en `src/router/index.js` | Vue Router 3 en `src/router/routes.js` | ✅ **Mismo router.** Otro archivo |
| `export default new VueRouter({...})` | `export default function () { return new VueRouter({...}) }` | Función, por SSR |
| `mode: 'history'` | `build.vueRouterMode: 'history'` en `quasar.conf.js` | |
| `router.beforeEach` (guards de F2) | ✅ **Igual.** En `router/index.js` o en un boot file | ⚠️ En F2 el guard leía `localStorage`; en Quasar lo leemos del `store` (inyectado en el boot). Ver nota en 4.5 |
| Vuex 3 en `src/store/` | Vuex 3 en `src/store/` | ✅ **Idéntico.** F10 aplica tal cual |
| `store/modules/tickets.js` (un archivo por módulo, F10) | `store/tickets/{actions,getters,mutations,state}.js` (scaffold de Quasar) | ⚠️ Misma Vuex 3, **otra organización**. Ver nota abajo |
| `services/apiClient.js` + `services/ticketService.js` | `src/boot/axios.js` (+ `services/` si querés) | El interceptor se mueve al boot; los `service` pueden quedarse. ⚠️ Y ahora lee el token del `store`, no de `localStorage` (F2 lo leía del navegador) |
| `Vue.prototype.$api = apiClient` | Igual, pero dentro del boot file | |
| `vuelidate` (F5) en `package.json` | *(nada — se va en Q2)* | En Q1 sigue instalado. Q2 lo **saca** y usa `:rules` |
| proxy de json-server en `vue.config.js` | `quasar.conf.js` → `devServer.proxy` | ✅ Misma config de F3 |

> ⚠️ **Nota sobre el store:** `quasar create` parte cada módulo Vuex en 4 archivos (`state.js`, `getters.js`, `mutations.js`, `actions.js`). El tronco (F10) usa **un archivo por módulo** (`store/modules/tickets.js`). Las dos formas son **Vuex 3 idéntico** — la diferencia es de organización de carpetas, no de API. En Q2 decidís si adoptás el scaffold de Quasar o mantenés el estilo de F10.

> 🔑 **Lo que NO cambia (respirá):**
> - Vue 2.6, Options API, `function () {}`, `data()` como función
> - Props, `$emit`, slots, `v-model`, computed, watchers
> - **Vue Router 3 entero** (F1)
> - **Vuex 3 entero** (F10): state, getters, mutations, actions, modules, `mapState`
> - **axios entero** (A4, F2, F3)
> - El ciclo de vida (`created`, `mounted`, ...)
>
> **Lo que cambia:** dónde vive el arranque, dónde vive el chrome de la app, y cómo se llaman los componentes de UI. **Nada más.**

---

## 5. 💻 Código — La sesión de reconocimiento

No hay Mini Jira acá. Hay **un proyecto scratch** que creás, mirás y tirás.

```bash
# 1. Instalar el CLI de Quasar 1 (¡el @1 importa!)
npm i -g @quasar/cli@1

# 2. Crear el proyecto
quasar create mini-jira-q
# Respondé según la tabla de 4.3

cd mini-jira-q

# 3. Verificar que estás en v1
cat package.json | grep quasar
# Debe decir: "quasar": "^1.22.x"  y  "@quasar/app": "^2.x"
#   (1.22.x es la versión oficial del curso: la ÚLTIMA v1. Ver 0-plan-del-curso.
#    Un repo legacy ajeno puede traer cualquier 1.x — 1.15, 1.9… — y también es v1.)
# ⚠️ Si dice "quasar": "^2.x" → creaste un proyecto Vue 3. Borrá y volvé a empezar con @quasar/cli@1

# 4. Arrancar
quasar dev
# → http://localhost:8080
```

**Ahora el recorrido guiado. Abrí estos archivos, en este orden:**

```bash
# 1. El corazón
code quasar.conf.js
#    → buscá: boot, css, framework.components, framework.plugins, build, devServer

# 2. El App.vue vacío (¡el shock!)
code src/App.vue
#    → 4 líneas. Solo <router-view/>. Esto es correcto.

# 3. El boot file de axios
code src/boot/axios.js
#    → mirá la firma: export default function ({ app, router, store, Vue }) {...}
#    → esto es tu main.js de F2, partido en pedazos

# 4. El layout
code src/layouts/MainLayout.vue
#    → contá los niveles: QLayout > QHeader > QToolbar; QLayout > QPageContainer > router-view

# 5. Las rutas
code src/router/routes.js
#    → notá: el layout es el componente PADRE, las páginas son children

# 6. El store
code src/store/index.js
#    → Vuex 3. Es idéntico a F10. Confirmalo vos mismo.
```

**Experimento obligatorio (el que te enseña el error de la sección 6):**

Abrí `src/pages/Index.vue` y agregá un componente que **no esté** en `framework.components`:

```vue
<template>
  <q-page padding>
    <h5>Index</h5>

    <!-- 🧪 EXPERIMENTO: QChip NO está en framework.components -->
    <q-chip color="primary" text-color="white">
      Soy un chip que no vas a ver
    </q-chip>
  </q-page>
</template>
```

Guardá. Mirá el navegador. Mirá la consola.

**Resultado:** nada. El chip no aparece. La consola está limpia (o con un warning genérico de Vue). Nada te dice qué pasó.

Ahora agregá `'QChip'` a `framework.components` en `quasar.conf.js`, reiniciá el dev server (⚠️ **`quasar.conf.js` no tiene HMR — hay que reiniciar**), y ahí sí aparece.

**Ese experimento es Q1.** Si lo hiciste, entendiste el 60% de lo que te va a costar leer Quasar legacy.

---

## 6. ⚠️ Errores clásicos

### 6.1 🔥 EL ERROR — Componente no declarado en `framework.components`

**Este es EL error de Quasar 1. El que te va a costar horas si no lo conocés.**

```vue
<template>
  <q-page padding>
    <q-card>              <!-- ❌ QCard NO está en framework.components -->
      <q-card-section>    <!-- ❌ QCardSection tampoco -->
        Contenido
      </q-card-section>
    </q-card>
  </q-page>
</template>
```

**Qué pasa:**
- El componente **no renderiza**. Simplemente no está en el DOM.
- **NO hay error en consola.**
- En el mejor de los casos, un `[Vue warn]: Unknown custom element: <q-card>` genérico — pero como Quasar registra parcialmente cosas, muchas veces **ni eso**.
- Si el componente tenía un `<slot>`, el contenido de adentro **también desaparece**.
- Lo peor: **funciona en el proyecto del compañero** (porque él sí lo tiene declarado). Vos copiaste el template, no el `quasar.conf.js`.

**Cómo lo reconocés:**

```
Síntoma: "Copié este template de otro archivo y no se ve nada."
Diagnóstico: abrí quasar.conf.js → framework.components → ¿está el componente?
```

**Cómo lo arreglás:**

```js
// quasar.conf.js
framework: {
  components: [
    'QLayout', 'QPageContainer', 'QPage',
    'QCard', 'QCardSection', 'QCardActions',   // ← agregar TODOS los que uses
    'QBtn', 'QChip'
  ]
}
```

Y **reiniciar `quasar dev`**. `quasar.conf.js` no tiene hot reload.

> ⚠️ **Sub-trampa:** un componente con sub-componentes es **varias entradas**.
> `<q-card>` + `<q-card-section>` + `<q-card-actions>` = `'QCard'`, `'QCardSection'`, `'QCardActions'`. **Tres**. Declarar solo `'QCard'` te deja las secciones invisibles.

> 🔎 **Por qué existe esta fricción:** es tree-shaking manual. Quasar 1 no tenía auto-import (Quasar 2 sí). Solo se empaquetan los componentes que declarás. Bundle chico a cambio de una lista que mantenés a mano.

> 💸 **DEUDA — La lista de `framework.components`**
> Es una lista que **crece y nunca se limpia**. En un proyecto legacy de 2 años vas a encontrar 80 componentes declarados de los cuales se usan 40. Nadie los saca porque nadie sabe cuáles están vivos.
>
> **En producción se arregla así:** o migrás a Quasar 2 (auto-import, la lista desaparece), o usás `framework: { all: 'auto' }` de `@quasar/app` 2.x — que hace auto-detección con un parser de templates y elimina el problema.
>
> **La frase:** *"Si nadie borró un componente de `framework.components` en 18 meses, esa lista no es configuración: es sedimento."*
>
> **Deuda que NO pagamos.** No es deuda tuya: es deuda del curso. Mientras estemos en Quasar 1, **la ruta convive con la lista** — a mano, sedimento y todo. Se pagaría **fuera de scope**, el día que el proyecto migre a Quasar 2 (auto-import). Q1 solo te enseña a reconocerla.

---

### 6.2 Plugin de `$q` no declarado

```js
this.$q.notify({ message: 'Hola' })
// ❌ TypeError: Cannot read property 'notify' of undefined
//    o: this.$q.notify is not a function
```

Falta `'Notify'` en `framework.plugins`. Este al menos **explota con un error claro**. Gracias, Quasar.

---

### 6.3 Contenido tapado por el header

```vue
<!-- ❌ MAL: falta QPageContainer -->
<q-layout view="hHh LpR fFf">
  <q-header>...</q-header>
  <router-view />     <!-- ← el contenido se mete DEBAJO del header -->
</q-layout>
```

Sin `<q-page-container>`, nadie calcula el offset del header. **No hay error.** Solo se ve roto.

---

### 6.4 Página sin `<q-page>` como raíz

```vue
<!-- ❌ MAL -->
<template>
  <div>Tickets</div>
</template>
```

Funciona… hasta que notás que la página no llena el viewport, el footer sube, y el padding no coincide con las otras páginas. `<q-page>` calcula `min-height: calc(100vh - header - footer)`. Si no lo usás, ese cálculo no existe.

---

### 6.5 Editar `quasar.conf.js` y esperar HMR

No. **No hay hot reload en `quasar.conf.js`.** Cambiás algo, `Ctrl+C`, `quasar dev` de nuevo. Todos los días. Aceptalo.

---

### 6.6 Alias `@/` que no existe

```js
import Ticket from '@/components/Ticket.vue'   // ❌ falla en Quasar
import Ticket from 'components/Ticket.vue'     // ✅ correcto
```

Copiaste un import del curso base. Quasar define sus propios alias (`components`, `layouts`, `pages`, `boot`, `assets`, `src`) y **`@` no es uno de ellos** por defecto.

---

### 6.7 Instalar el CLI equivocado

```bash
npm i -g @quasar/cli       # ❌ te instala el CLI que crea proyectos Quasar 2 (Vue 3)
npm i -g @quasar/cli@1     # ✅ Quasar 1, Vue 2
```

Si creaste el proyecto y `package.json` dice `"quasar": "^2.x"` → **estás en Vue 3**. Borrá la carpeta y volvé a empezar. No hay "downgrade".

---

### 6.8 `container` de Bootstrap dentro de `QPage`

```vue
<q-page padding>
  <div class="container">   <!-- ❌ doble padding + max-width que pelea con QPage -->
```

`QPage padding` **ya te dio** el spacing. Metiendo `container` de Bootstrap encima le sumás su propio padding y su `max-width`. Resultado: contenido descentrado y márgenes raros. En un proyecto con Bootstrap + Quasar, esto pasa **todo el tiempo**.

---

## 7. 🏋️ Ejercicios

> ⚠️ **Todos son de LECTURA y RECONOCIMIENTO.** No se migra nada. No se toca el Mini Jira.
> Usá el proyecto scratch `mini-jira-q` que creaste en la sección 5, o repos Quasar públicos de GitHub.

---

### 🟢 Fácil (1–8) — Ubicación y vocabulario

**🟢 1.** En el proyecto scratch, abrí `quasar.conf.js` y listá los 6 bloques principales que identificaste. Al lado de cada uno, escribí **qué archivo del curso base reemplaza** (o "ninguno, es nuevo").

<details><summary>Solución</summary>

| Bloque | Reemplaza |
|---|---|
| `boot` | `main.js` (la parte de inicialización) |
| `css` | los imports de CSS de `main.js` |
| `extras` | los `<link>` de fonts/iconos de `index.html` |
| `framework` | **nuevo**, no existe equivalente |
| `build` | `vue.config.js` (`configureWebpack`, `publicPath`) |
| `devServer` | `vue.config.js` → `devServer` (el proxy de F3) |
</details>

---

**🟢 2.** Abrí `src/App.vue`. ¿Cuántas líneas de `<template>` tiene? ¿Dónde está el navbar que esperabas encontrar ahí?

<details><summary>Solución</summary>
Una: `<router-view/>`. El navbar vive en `src/layouts/MainLayout.vue`, dentro de `<q-header>`. En Quasar el chrome de la app es un **layout**, montado desde el router, no un wrapper en `App.vue`.
</details>

---

**🟢 3.** Dado este `package.json`, decidí: ¿es Quasar 1 o 2? ¿Vue 2 o Vue 3?

```json
{ "dependencies": { "quasar": "^1.15.21", "vue": "^2.6.14" },
  "devDependencies": { "@quasar/app": "^2.4.3" } }
```

<details><summary>Solución</summary>
**Quasar 1.x, Vue 2.6.** Es nuestro target. La señal doble: `quasar: ^1.x` y `@quasar/app: ^2.x` (el CLI v2 es el que construye proyectos Quasar v1 — nombres confusos a propósito de nadie).
</details>

---

**🟢 4.** Traducí a Quasar: `<div class="mt-3 p-2 text-center">`

<details><summary>Solución</summary>
`<div class="q-mt-md q-pa-sm text-center">`
(`text-center` es **igual** en ambos. `mt-3` → `q-mt-md`, `p-2` → `q-pa-sm`.)
</details>

---

**🟢 5.** ¿Cuál de estas dos clases es de Quasar y cuál de Bootstrap? `q-pa-md` / `p-3`. ¿Qué pasa si en nuestro proyecto usás las dos en el mismo div?

<details><summary>Solución</summary>
`q-pa-md` → Quasar. `p-3` → Bootstrap.
Si usás las dos: **ambas aplican** (los dos CSS están cargados) y el padding se pisa según el orden de especificidad del bundle. Resultado impredecible. Es exactamente el bug visual que vas a encontrar en legacy.
</details>

---

**🟢 6.** ¿Qué comando corre el dev server en Quasar? ¿Y en Vue CLI (F0)?

<details><summary>Solución</summary>
Quasar: `quasar dev`. Vue CLI: `npm run serve` (que llama a `vue-cli-service serve`).
</details>

---

**🟢 7.** En Quasar, ¿dónde escribís tus rutas? ¿Y dónde **no** las escribís?

<details><summary>Solución</summary>
**Sí:** `src/router/routes.js`.
**No:** `src/router/index.js` — ese archivo crea la instancia del router (como función, por SSR) y casi nunca se toca.
</details>

---

**🟢 8.** Mirá este import y decí si funciona en Quasar:
```js
import TicketCard from '@/components/TicketCard.vue'
```

<details><summary>Solución</summary>
❌ **No funciona.** Quasar no define el alias `@`. El correcto es `import TicketCard from 'components/TicketCard.vue'`.
</details>

---

### 🟡 Medio (9–17) — Lectura de código real

**🟡 9.** Este template no renderiza nada visible. ¿Por qué?

```vue
<template>
  <q-page>
    <q-banner class="bg-warning">Cuidado</q-banner>
  </q-page>
</template>
```
```js
// quasar.conf.js
framework: { components: ['QLayout', 'QPageContainer', 'QPage', 'QBtn'] }
```

<details><summary>Solución</summary>
`QBanner` **no está declarado** en `framework.components`. El componente no se registra, no renderiza, y **no hay error claro**. El texto "Cuidado" también desaparece (era el slot de `QBanner`).
**Fix:** agregar `'QBanner'` a la lista y **reiniciar** `quasar dev`.
</details>

---

**🟡 10.** Este código explota. ¿Qué falta y dónde?

```js
methods: {
  guardar: function () {
    this.$q.notify({ message: 'Guardado', color: 'positive' })
  }
}
```
```js
// quasar.conf.js
framework: {
  components: ['QLayout', 'QPage', 'QBtn'],
  plugins: ['Dialog']
}
```

<details><summary>Solución</summary>
Falta `'Notify'` en `framework.plugins`. Error: `this.$q.notify is not a function`.
Notá que este error **sí es claro** — a diferencia del de componentes (ej. 9), que es silencioso.
</details>

---

**🟡 11.** Reordená esta jerarquía (está mal):

```
QPage > QLayout > QPageContainer > QHeader
```

<details><summary>Solución</summary>

```
QLayout
 ├── QHeader
 └── QPageContainer
      └── QPage
```
`QLayout` es la raíz. `QHeader` y `QPageContainer` son hermanos, hijos directos de `QLayout`. `QPage` va **dentro** de `QPageContainer` (normalmente vía `<router-view/>`).
</details>

---

**🟡 12.** Este `routes.js` tiene un problema estructural. ¿Cuál?

```js
const routes = [
  { path: '/tickets', component: function () { return import('pages/TicketsPage.vue') } },
  { path: '/login',   component: function () { return import('pages/LoginPage.vue') } }
]
```

<details><summary>Solución</summary>
**No hay layout.** Las páginas se montan directo, sin `MainLayout`, o sea sin `QLayout`/`QPageContainer`. Resultado: no hay header, no hay drawer, y `<q-page>` no tiene un `QLayout` padre del cual calcular el `min-height` (Quasar te va a tirar un warning de "QPage needs to be child of QLayout").

**Correcto:** el layout es la ruta **padre**, las páginas son `children`.
</details>

---

**🟡 13.** Traducí este bloque de Bootstrap a Quasar (grid + spacing):

```html
<div class="container mt-4">
  <div class="row">
    <div class="col-md-8 p-3">Contenido</div>
    <div class="col-md-4 p-3">Sidebar</div>
  </div>
</div>
```

<details><summary>Solución</summary>

```html
<q-page padding>
  <div class="row q-col-gutter-md">
    <div class="col-md-8">Contenido</div>
    <div class="col-md-4">Sidebar</div>
  </div>
</q-page>
```
Notá tres cosas:
1. `container mt-4` → desaparece; `<q-page padding>` da el wrapper y el spacing.
2. `row` / `col-md-8` → **iguales**.
3. `p-3` en cada columna → se reemplaza por `q-col-gutter-md` en el `row` (los gutters de Quasar **no son automáticos** como en Bootstrap).
</details>

---

**🟡 14.** Este boot file tiene un bug conceptual. ¿Cuál?

```js
// src/boot/axios.js
import Vue from 'vue'
import axios from 'axios'
import store from 'src/store'          // ⚠️

const apiClient = axios.create({ baseURL: '/api' })

export default function ({ Vue }) {
  apiClient.interceptors.request.use(function (config) {
    const token = store.state.auth.token
    if (token) config.headers.Authorization = 'Bearer ' + token
    return config
  })
  Vue.prototype.$api = apiClient
}
```

<details><summary>Solución</summary>
Importa el `store` a mano (`import store from 'src/store'`) cuando **Quasar ya se lo pasa por parámetro**.

Problema: en Quasar el store se exporta como **función** (por SSR), así que ese import te devuelve la factory, no la instancia. `store.state` es `undefined`. Y aunque funcionara, es la puerta de entrada al import circular clásico `apiClient → store → services → apiClient`.

**Fix:**
```js
export default function ({ Vue, store, router }) {
  apiClient.interceptors.request.use(function (config) {
    const token = store.state.auth.token   // ← el store que te pasan
    ...
  })
}
```
</details>

---

**🟡 15.** Te pasan un repo Quasar de la empresa. Escribí la **secuencia de 5 archivos** que abrís, en orden, para entender el proyecto. Justificá cada uno en una línea.

<details><summary>Solución</summary>

1. `package.json` → confirmar Quasar **1** vs 2 (o sea Vue 2 vs 3). Todo lo demás depende de esto.
2. `quasar.conf.js` → boot files, componentes declarados, plugins, proxy, router mode.
3. `src/router/routes.js` → el mapa de la app: qué layouts, qué páginas.
4. `src/boot/*.js` → qué se inicializa antes de arrancar (axios, auth, i18n, guards).
5. `src/layouts/MainLayout.vue` → el chrome real de la app.

(El store lo dejás para el final: es Vuex 3 estándar, ya lo sabés de F10.)
</details>

---

**🟡 16.** Este código de Q busca replicar un modal de confirmación de F5. Reescribilo con `$q.dialog`, **sin arrow functions** (convención del curso).

```js
// versión curso base
eliminar: function (ticket) {
  this.ticketAEliminar = ticket
  this.mostrarModal = true
}
```

<details><summary>Solución</summary>

```js
eliminar: function (ticket) {
  this.$q.dialog({
    title: 'Confirmar',
    message: '¿Eliminar el ticket #' + ticket.id + '?',
    cancel: true,
    persistent: true
  }).onOk(function () {
    this.$store.dispatch('tickets/eliminar', ticket.id)
  }.bind(this))
}
```
El `.bind(this)` es obligatorio: sin arrow, el callback de `.onOk()` pierde el contexto del componente.
Y `'Dialog'` tiene que estar en `framework.plugins`.
</details>

---

**🟡 17.** ¿Por qué `src/router/index.js` exporta una **función** y no una instancia? (En F1 exportábamos `new VueRouter({...})` directo.)

<details><summary>Solución</summary>
Por **SSR**. En server-side rendering, cada request necesita su propia instancia de router (si compartieras una, el estado de navegación de un usuario se filtraría a otro).

Quasar mantiene esa convención **aunque estés en SPA**, porque el mismo código fuente tiene que poder compilarse a SSR sin tocarlo. Es una de las consecuencias de que Quasar sea "un build system multi-target".

Lo mismo aplica a `src/store/index.js`: también exporta una función.
</details>

---

### 🟠 Difícil (18–24) — Diagnóstico y arqueología

**🟠 18.** Un compañero te dice: *"copié tu template de `TicketCard.vue` a mi proyecto y no se ve nada, ni siquiera el texto. No hay errores."*

Escribí las **3 preguntas** que le hacés, en orden de probabilidad.

<details><summary>Solución</summary>

1. **"¿Copiaste también las entradas de `framework.components` de mi `quasar.conf.js`?"** — 80% de probabilidad. Es EL error. Si el componente raíz del template (ej. `QCard`) no está declarado, todo el contenido interno (que era su slot) desaparece con él.
2. **"¿Reiniciaste `quasar dev` después de tocar `quasar.conf.js`?"** — no hay HMR en ese archivo.
3. **"¿Tu proyecto es Quasar 1 o 2?"** — si es v2, `framework.components` ni existe, y otros componentes cambiaron de API.
</details>

---

**🟠 19.** Encontrás este `quasar.conf.js` en un repo de la empresa. Datalo y describí el proyecto en 3 frases:

```js
framework: {
  iconSet: 'material-icons',
  lang: 'es',
  components: [
    'QLayout','QHeader','QDrawer','QPageContainer','QPage','QToolbar','QToolbarTitle',
    'QBtn','QIcon','QList','QItem','QItemSection','QItemLabel','QSeparator',
    'QTable','QTd','QTr','QInput','QSelect','QDate','QPopupProxy','QCard','QCardSection',
    'QCardActions','QDialog','QChip','QBadge','QSpinner','QTooltip','QMenu','QAvatar',
    'QExpansionItem','QTabs','QTab','QTabPanels','QTabPanel','QUploader','QEditor'
  ],
  directives: ['Ripple','ClosePopup'],
  plugins: ['Notify','Dialog','Loading','LocalStorage']
},
build: { vueRouterMode: 'history' },
boot: ['axios','auth','i18n']
```

<details><summary>Solución</summary>
**Datación: Quasar 1.x** (la clave es `framework.components` con lista manual — en v2 no existe).

Descripción:
1. **Es una app CRUD grande y madura:** `QTable` + `QInput` + `QSelect` + `QDate` + `QUploader` + `QEditor` = formularios complejos, tablas con filtros, subida de archivos y edición de texto rico. No es un prototipo.
2. **Tiene autenticación propia y persistencia local:** boot file `auth` + plugin `LocalStorage` → sesión guardada en el navegador (probablemente el token de F2).
3. **Es multi-idioma y está pensada para producción:** boot `i18n` + `vueRouterMode: 'history'` (URLs limpias, o sea que alguien configuró el servidor para el fallback a `index.html` — ver F1).

**Bonus (deuda):** 36 componentes declarados. Apostaría que ~12 no se usan más. Nadie los sacó.
</details>

---

**🟠 20.** En un repo legacy encontrás este template. Está **mezclando** Bootstrap y Quasar. Identificá cada clase, decí de quién es, y marcá cuáles están peleando entre sí.

```html
<q-page padding>
  <div class="container">
    <div class="row justify-content-between q-mb-md">
      <div class="col-md-6 p-3">
        <h5 class="text-muted mb-2">Tickets abiertos</h5>
      </div>
      <div class="col-md-6 text-right q-pa-md">
        <button class="btn btn-primary">Nuevo</button>
      </div>
    </div>
  </div>
</q-page>
```

<details><summary>Solución</summary>

| Clase | Origen | Problema |
|---|---|---|
| `q-page padding` | Quasar | ok |
| `container` | Bootstrap | ⚠️ **pelea**: `q-page padding` ya dio padding; `container` suma el suyo + un `max-width` |
| `row` | Ambos (colisión) | ⚠️ Los dos definen `.row`. Gana el que se cargue después en el bundle. **Bomba de tiempo.** |
| `justify-content-between` | Bootstrap | ⚠️ Quasar usa `justify-between`. Solo funciona porque Bootstrap está cargado |
| `q-mb-md` | Quasar | ok |
| `col-md-6` | Ambos (colisión) | ⚠️ Igual que `.row` |
| `p-3` | Bootstrap | ⚠️ Mezclado con `q-pa-md` en la columna hermana → **spacing asimétrico** |
| `text-muted` | Bootstrap | Quasar usaría `text-grey-7` |
| `mb-2` | Bootstrap | Quasar: `q-mb-sm` |
| `text-right` | Bootstrap | Quasar: `text-right` ✅ igual |
| `q-pa-md` | Quasar | ⚠️ La columna hermana tiene `p-3`. **Padding distinto en cada mitad de la fila.** |
| `btn btn-primary` | Bootstrap | Quasar: `<q-btn color="primary">` |

**Las peleas reales:**
- `.row` y `.col-md-6` están **duplicadas** en ambos CSS. Funciona por casualidad (los valores son parecidos), pero un cambio de orden en el bundle rompe el layout entero.
- `p-3` vs `q-pa-md` en columnas hermanas: `p-3` = 16px, `q-pa-md` = 16px. **Coinciden por suerte.** Cambiá `q-pa-md` a `q-pa-lg` y se descuadra.
- `container` dentro de `q-page padding` = doble padding.

💸 **Esto es la deuda de convivencia en estado puro.** Se paga en Q3.
</details>

---

**🟠 21.** Este boot file "funciona" pero tiene un bug de timing. ¿Cuál?

```js
// src/boot/auth.js
export default function ({ router, store }) {
  router.beforeEach(function (to, from, next) {
    const token = store.state.auth.token
    if (to.meta.requiresAuth && !token) {
      next('/login')
    } else {
      next()
    }
  })
}
```
```js
// quasar.conf.js
boot: ['auth', 'axios']
```

<details><summary>Solución</summary>
**El orden de los boot files.** `auth` corre **antes** que `axios`.

Si `boot/axios.js` es el que hidrata el token desde `LocalStorage` al store (patrón común), entonces cuando `auth.js` registra el guard, el store **todavía no tiene el token**. En sí el guard se registra bien (se ejecuta después, en la primera navegación), así que muchas veces **funciona por casualidad**.

Pero si `auth.js` hiciera una lectura *inmediata* del token (ej. `const t = store.state.auth.token` fuera del guard, para decidir una redirección inicial), leería `null` y patearía al usuario logueado a `/login`.

**Fix:** `boot: ['axios', 'auth']`. Los boot files corren **en el orden del array**, secuencialmente, y Quasar **espera** si devolvés una Promise.

🔑 **La regla:** el orden en `boot: []` **importa**. Es la única parte de `quasar.conf.js` donde el orden es semántico.
</details>

---

**🟠 22.** Te dan solo este fragmento de un repo desconocido. Reconstruí (a) qué versión de Quasar es, (b) qué versión de Vue, (c) si el proyecto usa Vuex, (d) si tiene autenticación:

```
src/
├── boot/
│   ├── axios.js
│   ├── i18n.js
│   └── vuelidate.js
├── layouts/
│   ├── MainLayout.vue
│   └── LoginLayout.vue
├── pages/
├── router/
│   ├── index.js
│   └── routes.js
└── store/
    ├── index.js
    └── auth/
        ├── actions.js
        ├── getters.js
        ├── mutations.js
        └── state.js
```

<details><summary>Solución</summary>
(a) **Quasar 1.x.** La carpeta `src/boot/` con esa estructura es la convención de `@quasar/app` v1/v2 (Quasar 1). En Quasar 2 la carpeta también existe, así que **no es concluyente por sí sola** — pero sumado a (b) sí.

(b) **Vue 2.** Señal: `vuelidate` (boot file). Vuelidate v0.x es Vue 2. Además `store/auth/` con `state.js`/`getters.js`/`mutations.js`/`actions.js` en archivos separados es el scaffold de **Vuex 3**, no de Pinia.
> ⚠️ Para confirmar 100%: hay que abrir `package.json`. Esto es inferencia, no certeza.

(c) **Sí, Vuex, con módulos namespaced.** `store/auth/` como módulo separado con los 4 archivos = el patrón de F10 exacto.

(d) **Sí.** Tres señales convergentes: el módulo `store/auth/`, el `LoginLayout.vue` (un layout sin navbar, solo para login — exactamente el patrón de 4.7), y `boot/axios.js` (que casi seguro tiene el interceptor de Bearer token de F2).

**Lo que falta y deberías ir a buscar:** ¿dónde está el `router.beforeEach`? No hay `boot/auth.js`. Probablemente esté dentro de `router/index.js`. Andá ahí.
</details>

---

**🟠 23.** ¿Por qué Quasar 1 te obliga a declarar componentes a mano y Quasar 2 no? Explicá el trade-off en términos de **bundle** y de **mantenimiento**.

<details><summary>Solución</summary>

**Quasar 1** hace tree-shaking **manual y explícito**: solo empaqueta lo que declarás en `framework.components`. El build no analiza tus templates.
- ✅ **Bundle:** mínimo, garantizado. Vos controlás exactamente qué entra.
- ❌ **Mantenimiento:** una lista que hay que actualizar a mano cada vez que usás un componente nuevo. Y que **nunca se limpia** cuando dejás de usarlo. → 💸 sedimento.
- ❌ **DX:** el error de "no declaré el componente" es **silencioso**. Es la peor clase de error.

**Quasar 2** hace tree-shaking **automático**: un parser de webpack/vite lee tus `<template>` y detecta qué `<q-*>` usás.
- ✅ **Mantenimiento:** cero. No hay lista.
- ✅ **DX:** no existe el error silencioso.
- ⚠️ **Bundle:** depende de que el parser acierte. Si usás `<component :is="nombreDinamico">`, el parser **no puede detectarlo** y tenés que declararlo igual.

**El trade-off en una frase:** Quasar 1 cambió DX por control de bundle. Cuando el tooling mejoró lo suficiente para hacerlo solo, v2 se lo llevó puesto.

**Por qué te importa a vos:** el código de la empresa está en v1. Vas a convivir con la lista. Conocerla es la diferencia entre 5 minutos y 3 horas de debugging.
</details>

---

**🟠 24.** Escribí un **diagrama de arranque** (ASCII o Mermaid) que muestre el orden exacto en que Quasar 1 inicializa una app SPA, desde `quasar dev` hasta el primer render. Marcá dónde entra cada boot file y dónde se monta el layout.

<details><summary>Solución</summary>

```
quasar dev
    │
    ▼
[1] webpack lee quasar.conf.js
    │   → framework.components  → registra SOLO los declarados como globales
    │   → framework.plugins     → instala Notify, Dialog... en $q
    │   → framework.directives  → registra v-ripple, v-close-popup
    │   → css / extras          → inyecta CSS y fonts
    │
    ▼
[2] Quasar GENERA el entry point (tu "main.js" invisible)
    │   → import Vue, Vuex, VueRouter, Quasar
    │   → const store = createStore()      ← src/store/index.js (función)
    │   → const router = createRouter()    ← src/router/index.js (función)
    │
    ▼
[3] EJECUTA LOS BOOT FILES, EN ORDEN, SECUENCIALMENTE
    │   (cada uno recibe { app, router, store, Vue, ssrContext })
    │   (si devuelve Promise, Quasar ESPERA)
    │
    ├─► boot/axios.js   → crea apiClient, registra interceptores, Vue.prototype.$api
    ├─► boot/auth.js    → hidrata token desde LocalStorage, registra router.beforeEach
    └─► boot/i18n.js    → Vue.use(VueI18n), app.i18n = ...
    │
    ▼
[4] new Vue({ router, store, render: h => h(App) }).$mount('#q-app')
    │
    ▼
[5] App.vue  →  <router-view/>
    │
    ▼
[6] Router resuelve la URL actual
    │   → ¿pasa el beforeEach de boot/auth.js?
    │      NO → redirect a /login
    │      SÍ ↓
    │
    ▼
[7] Monta el LAYOUT (ruta padre)
    │   layouts/MainLayout.vue
    │     └── QLayout
    │          ├── QHeader
    │          ├── QDrawer
    │          └── QPageContainer
    │               └── <router-view/>   ← ruta hija
    │
    ▼
[8] Monta la PAGE (ruta hija)
        pages/TicketsPage.vue
          └── QPage
               └── created() → this.$store.dispatch('tickets/cargar')
                                  └── $api.get('/tickets')  ← el interceptor de [3] mete el Bearer
```

**Los tres puntos clave del diagrama:**
- **[1] es donde muere tu componente** si no está en `framework.components`. Nunca llega a [7].
- **[3] es tu `main.js`.** Partido en pedazos, con el store y el router ya construidos y pasados por parámetro.
- **[7] es lo que no existe en el curso base.** Entre el `<router-view>` de `App.vue` y tu página, hay **un layout entero**.
</details>

---

### 🔴 Muy difícil (25–29) — Arqueología real

**🔴 25.** Te asignan un bug: *"en producción, al recargar la página `/tickets/42`, el usuario ve un 404 del servidor. En dev funciona."*

El proyecto es Quasar 1. Sin abrir el código, escribí las **dos** configuraciones que tenés que revisar y **por qué esto es exactamente el mismo problema de F1**.

<details><summary>Solución</summary>
**Las dos configs:**
1. `quasar.conf.js` → `build.vueRouterMode`. Si está en `'history'`, las URLs no llevan `#`.
2. **La config del servidor web** (nginx/Apache/S3) → tiene que tener el fallback a `index.html`.

**Por qué:** es **idéntico** al problema de F1.

Con `mode: 'history'`, la URL `/tickets/42` es una URL "real" desde el punto de vista del servidor. En `quasar dev`, el dev server de webpack tiene `historyApiFallback: true` por defecto → cualquier ruta desconocida devuelve `index.html`, y ahí el router de Vue toma el control.

En producción, nginx recibe `GET /tickets/42`, busca el archivo `/tickets/42` en el disco, no lo encuentra → **404**. El JS de Vue **nunca se carga**, así que el router nunca corre.

**El fix (F1, mismo capítulo):**
```nginx
location / {
  try_files $uri $uri/ /index.html;
}
```

**El fix cobarde:** cambiar a `vueRouterMode: 'hash'`. Las URLs quedan `/#/tickets/42`, el servidor solo ve `/`, y funciona en cualquier lado. Feo pero indestructible.

🔑 **La lección de Q1:** Quasar cambió **dónde** se configura el router mode (`quasar.conf.js` en vez de `router/index.js`), pero **no cambió el problema**. F1 sigue siendo válido. Esto es el patrón de toda la fase.
</details>

---

**🔴 26.** Encontrás este componente en un repo. **Funciona.** Pero tiene 4 problemas que un revisor senior marcaría. Listalos.

```vue
<template>
  <q-page class="container">
    <div class="row">
      <div class="col-12 p-3">
        <q-card>
          <q-card-section>
            <div class="text-h6">{{ ticket.titulo }}</div>
            <span class="badge badge-danger">{{ ticket.prioridad }}</span>
          </q-card-section>
        </q-card>
      </div>
    </div>
    <button class="btn btn-primary mt-3" @click="eliminar">Eliminar</button>
  </q-page>
</template>

<script>
import { apiClient } from '@/boot/axios'

export default {
  data: () => ({ ticket: {} }),
  mounted () {
    apiClient.get('/tickets/' + this.$route.params.id).then(r => { this.ticket = r.data })
  },
  methods: {
    eliminar () {
      if (confirm('¿Seguro?')) {
        apiClient.delete('/tickets/' + this.$route.params.id)
        this.$router.push('/tickets')
      }
    }
  }
}
</script>
```

<details><summary>Solución</summary>

**Los 4 (bueno, son más — pero estos son los que un senior marca primero):**

1. **🔴 Import con alias `@/`** → `import { apiClient } from '@/boot/axios'`. En Quasar **`@` no existe**. Debería ser `'boot/axios'`. (Que "funcione" significa que alguien agregó el alias a mano en `build.extendWebpack` — deuda oculta.)

2. **🔴 Bypassea el store.** Llama a `apiClient` directo desde el componente. **Rompe la arquitectura del curso**: `Componente → Store → services/ → apiClient → API`. El ticket no queda en Vuex, así que ningún otro componente se entera del borrado. Debería ser `this.$store.dispatch('tickets/cargar', id)`.

3. **🔴 `confirm()` nativo del navegador.** Feo, bloqueante, no estilizable, y hay `$q.dialog` **ya instalado** en el proyecto (o debería). Peor: `confirm()` es síncrono y bloquea el event loop.

4. **🔴 Delete sin `await` / sin `.then()`.** `apiClient.delete(...)` se dispara y **acto seguido** hace `this.$router.push('/tickets')`. Si el DELETE falla (404, 500, sin red), el usuario **igual** navega y cree que borró. Error silencioso. Y encima ni siquiera hay `.catch()`.

**Bonus (los que también marcaría):**
5. Arrow functions (`data: () => ({})`, `.then(r => ...)`, `eliminar () {}` shorthand) → **rompe la convención del curso** (`function () {}`, siempre).
6. `q-page class="container"` → mezcla Bootstrap con Quasar. Doble padding.
7. `p-3` (Bootstrap) dentro de un template Quasar → debería ser `q-pa-md`.
8. `badge badge-danger` (Bootstrap 4) → debería ser `<q-badge color="negative">`.
9. `btn btn-primary` → debería ser `<q-btn color="primary">`.
10. `mounted()` para cargar datos → el curso usa `created()` (no necesita DOM).
11. `data: () => ({})` con arrow → **funciona** en Vue 2 pero es exactamente el tipo de cosa que se rompe si alguien intenta usar `this` ahí.

💸 **Este componente es la deuda del curso completa, en 30 líneas.** Es el tipo de código que vas a encontrar y que "funciona", así que nadie lo toca.
</details>

---

**🔴 27.** Un componente `<q-select>` no renderiza. `'QSelect'` **está** en `framework.components`. Reiniciaste el dev server. El proyecto es Quasar 1.15. Listá **5 hipótesis** en orden de probabilidad, con cómo verificarías cada una en < 2 minutos.

<details><summary>Solución</summary>

1. **Hay más de un `quasar.conf.js` / estás editando el equivocado.** (monorepo, o un `quasar.conf.js` en la raíz y otro en un subpaquete)
   → `find . -name "quasar.conf.js" -not -path "*/node_modules/*"`

2. **El `q-select` está dentro de un componente padre que tampoco está declarado** (ej. `<q-card>` sin `'QCard'`). El padre no renderiza → su slot desaparece → el `q-select` se va con él.
   → Mirá el template **completo** y chequeá **cada** `<q-*>` contra la lista. Especialmente el **más externo**.

3. **El `q-select` está dentro de un `v-if` que es `false`.** Trivial, pero es el 20% de los casos.
   → Vue DevTools → mirá el componente → chequeá el estado que controla el `v-if`.

4. **Error de nombre en la lista.** `'Qselect'`, `'QSelect '` (espacio), `'q-select'`. Quasar **no valida** los strings de esa lista — si ponés basura, la ignora en silencio.
   → Copiá/pegá el nombre exacto de la doc. Buscá typos con `grep -n "QSelect" quasar.conf.js`.

5. **El componente falla en runtime y Vue lo desmonta.** Ej: `<q-select :options="opciones">` y `opciones` es `undefined` → error dentro del componente → Vue lo saca del árbol.
   → Consola: buscá **cualquier** error de Vue, incluso los que parecen no relacionados. Y ponele `:options="[]"` hardcodeado para descartar.

**Bonus 6 (el que te hace perder la tarde):** el proyecto tiene un `.quasar/` cacheado corrupto.
→ `rm -rf .quasar node_modules/.cache && quasar dev`
</details>

---

**🔴 28.** Diseñá el **checklist de onboarding a un repo Quasar 1 legacy**: una página, ~15 ítems, que le das a un dev nuevo el primer día. Tiene que servir para que en 1 hora pueda leer el código sin romper nada.

<details><summary>Solución (ejemplo — hay muchas válidas)</summary>

## ✅ Checklist — Primer día en un repo Quasar 1

### Datación (5 min)
- [ ] `package.json` → ¿`"quasar": "^1.x"`? **Si es `^2.x`, este checklist NO aplica** (es Vue 3).
- [ ] `package.json` → ¿Vue 2.6.x? ¿Vuex 3? ¿Vue Router 3?
- [ ] `package.json` → ¿está Bootstrap? Si sí: **el CSS está mezclado**. Cuidado con `.row` / `.col-*`.
- [ ] `npm i -g @quasar/cli@1` (¡el `@1`!) → `npm install` → `quasar dev` → ¿arranca?

### El mapa (15 min)
- [ ] `quasar.conf.js` → `boot: []` → **anotar el orden**. Ese es tu `main.js`.
- [ ] `quasar.conf.js` → `framework.plugins` → qué `$q.*` está disponible.
- [ ] `quasar.conf.js` → `framework.components` → **cuántos son**. Guardá el número; lo vas a mirar mucho.
- [ ] `quasar.conf.js` → `build.vueRouterMode` → ¿`hash` o `history`?
- [ ] `quasar.conf.js` → `devServer.proxy` → **¿contra qué backend pega en dev?**
- [ ] `src/router/routes.js` → el mapa completo. ¿Cuántos layouts? ¿Qué rutas son protegidas?

### El arranque (15 min)
- [ ] `src/boot/*.js` → leé **cada uno**. Especialmente el de axios: **ahí está el interceptor del token**.
- [ ] ¿Dónde está el `router.beforeEach`? (`router/index.js` o un boot file). **Ese es tu guard de auth.**
- [ ] `src/store/` → ¿módulos namespaced? ¿cuál maneja `auth`?

### El chrome (10 min)
- [ ] `src/layouts/` → ¿cuántos layouts hay? (Típico: `MainLayout` + `LoginLayout`/`BlankLayout`.)
- [ ] `src/layouts/MainLayout.vue` → confirmá la jerarquía: `QLayout > QHeader/QDrawer > QPageContainer`.

### Antes de tocar nada (5 min)
- [ ] ⚠️ **Regla de oro:** si agregás un `<q-*>` nuevo a un template → agregarlo a `framework.components` → **reiniciar `quasar dev`**. Si no lo hacés, no renderiza y **no hay error**.
- [ ] ⚠️ Los imports son `components/X.vue`, **no** `@/components/X.vue`.
- [ ] ⚠️ `quasar.conf.js` **no tiene HMR**. Todo cambio ahí = reiniciar.

### 🚩 Red flags a reportar
- [ ] Componentes llamando a `apiClient` directo, sin pasar por el store.
- [ ] `class="container"` dentro de `<q-page>`.
- [ ] `confirm()` / `alert()` nativos cuando `$q.dialog` está instalado.
- [ ] Mezcla de `p-3` (Bootstrap) y `q-pa-md` (Quasar) en el mismo componente.
</details>

---

**🔴 29.** **El ejercicio de la fase.** Buscá un repo Quasar 1 real en GitHub (buscá `"quasar" "vue": "^2.6"` en el buscador de código, o probá los starters de la comunidad). Cloná uno, **sin correrlo**, y escribí un informe de 1 página:

1. **Datación:** versión de Quasar, de Vue, de Vuex/Router. ¿Cómo lo confirmaste?
2. **El `main.js` invisible:** ¿qué boot files hay? ¿en qué orden? ¿qué hace cada uno?
3. **Auth:** ¿tiene? ¿dónde está el interceptor? ¿dónde el guard?
4. **Chrome:** ¿cuántos layouts? Dibujá la jerarquía de uno.
5. **Deuda de componentes:** ¿cuántos componentes hay en `framework.components`? Grepeá el `src/` y estimá **cuántos están realmente en uso**. La diferencia es sedimento.
6. **Deuda de CSS:** ¿hay Bootstrap/Tailwind/otra librería conviviendo? ¿Dónde colisionan?
7. **Un bug que ya podés predecir** sin correr el proyecto, y por qué.

> 💡 **¿Sin conexión o sin encontrar un repo?** Hacé el informe sobre tu `mini-jira-q` scratch (secciones 1–4) más el `quasar.conf.js` del **ejercicio 19** (secciones 5–7). El ejercicio funciona igual: lo que se entrena es la lectura, no de dónde salió el código.

<details><summary>Guía de evaluación</summary>

No hay solución única. Se evalúa:

- **(1)** ¿Miró `package.json` **y** `quasar.conf.js`? Una sola fuente no alcanza.
- **(2)** ¿Entendió que los boot files son secuenciales y que **el orden importa**? (ej. 21)
- **(3)** ¿Encontró el interceptor en `boot/axios.js` **y** el guard (que puede estar en `router/index.js`, en un boot file, o — peor — repartido)?
- **(5)** El grep correcto es algo tipo:
  ```bash
  grep -ohrE "<q-[a-z-]+" src/ | sort -u | wc -l
  ```
  Comparalo con el largo de `framework.components`. **Casi siempre hay 20–40% de sedimento.**
- **(7)** El mejor informe predice un bug **estructural**, no cosmético. Ejemplos de buena predicción:
  - "`vueRouterMode: 'history'` + no hay `nginx.conf` / `_redirects` / `vercel.json` en el repo → **404 al recargar en prod**" (ej. 25)
  - "Bootstrap y Quasar cargados, `.row` definido en ambos → **si alguien reordena los imports de CSS, se rompe el grid entero**" (ej. 20)
  - "`boot: ['auth', 'axios']` → si `auth` lee el token en el arranque, lo lee `null`" (ej. 21)

**Este ejercicio es Q1 entero.** Si lo podés hacer, ya podés leer Quasar legacy.
</details>

---

## 8. 📚 Referencias

### Quasar 1 (⚠️ la doc de v1 está **archivada** — cuidado de no caer en la de v2)

- **Docs Quasar v1 (archivo oficial):** https://v1.quasar.dev/
  > 🔥 **Guardá este link.** Si googleás "quasar QTable" vas a caer en `quasar.dev` (que es **v2**, Vue 3) y la API es distinta. Siempre `v1.quasar.dev`.
- **`quasar.conf.js` (v1):** https://v1.quasar.dev/quasar-cli/quasar-conf-js
- **Boot files (v1):** https://v1.quasar.dev/quasar-cli/boot-files
- **Layouts — QLayout (v1):** https://v1.quasar.dev/layout/layout
- **QPage / QPageContainer (v1):** https://v1.quasar.dev/layout/page
- **Routing (v1):** https://v1.quasar.dev/quasar-cli/routing
- **Vuex en Quasar (v1):** https://v1.quasar.dev/quasar-cli/vuex-store
- **Flexbox / Grid (v1):** https://v1.quasar.dev/layout/grid/introduction
- **Spacing (v1):** https://v1.quasar.dev/style/spacing
- **Notify plugin (v1):** https://v1.quasar.dev/quasar-plugins/notify
- **Dialog plugin (v1):** https://v1.quasar.dev/quasar-plugins/dialog
- **Layout Builder (v1)** — herramienta visual para el string `view="hHh LpR fFf"`: https://v1.quasar.dev/layout-builder

### Del curso base (releé si algo no cierra)

| Si te perdés en… | Volvé a… |
|---|---|
| Los tests de regresión que ya escribiste (y no tocás en Q1) | **Q0 — La red de seguridad** |
| Vue Router 3, rutas anidadas, guards, `history` mode, el alias `@` | **F1 — Estructura base legacy** |
| Bearer token, interceptores, `router.beforeEach` de auth | **F2 — Autenticación mínima** |
| json-server, proxy de dev, `baseURL` | **F3 — Mock API mínima** |
| El dashboard con filtro/orden/paginación manual que **Q3** va a migrar | **F4 — Dashboard de tickets** |
| El CRUD y el form con **vuelidate** que **Q2** va a migrar | **F5 — CRUD de tickets** |
| Vuex 3, módulos, `mapState`, actions | **F10 — Vuex a fondo** |
| axios, `create()`, interceptores | **A4 — axios** |
| Bootstrap 4: grid, spacing, utilidades | **A1 — Bootstrap** |
| webpack, babel, `configureWebpack` | **A5 — webpack y babel** |
| npm, `-g`, semver (`^1.15.x`) | **A3 — npm** |

### Externos útiles

- **Quasar v1 → v2 upgrade guide** (para entender qué cambió, **no** para migrar): https://quasar.dev/start/upgrade-guide
- **Awesome Quasar** (repos de ejemplo, muchos v1): https://github.com/quasarframework/quasar-awesome

---

## 9. 🌉 Cierre y puente a Q2

**Qué lograste:**

Podés abrir un repo Quasar 1 y en 20 minutos armar el mapa mental completo. Sabés que:

- Tu `main.js` se llama `quasar.conf.js` + `src/boot/*.js`, y **el orden del array `boot` importa**.
- Tu `App.vue` está vacío, y eso está **bien** — el chrome vive en `layouts/`.
- `QLayout > QPageContainer > QPage` **no es un div con router-view**: es un sistema de posicionamiento que hace cálculos, y saltearse `QPageContainer` te mete el contenido debajo del header sin decirte nada.
- **Vue Router 3 y Vuex 3 no cambiaron.** F1 y F10 valen tal cual. Solo cambió el archivo.
- Bootstrap y Quasar **conviven** en el proyecto, comparten `.row` y `.col-*`, y eso es una 💸 bomba de tiempo que vamos a desactivar en Q3.
- Y sobre todo: **si un `<q-*>` no está en `framework.components`, no renderiza y nadie te avisa.** Eso solo te va a costar horas **una vez**. Después, es lo primero que mirás.

**Lo que NO hiciste:** tocar el Mini Jira. Ni una línea. Q1 es reconocimiento y nada más.

**Y si tu trabajo es solo leer código Quasar** — parchear, revisar PRs, entender un flujo antes de una reunión — **acá podés parar**. En serio. Q1 es autosuficiente para eso, y esa es la mayoría de la gente.

---

### 🌉 Puente a Q2 — Migrar el CRUD

Ahora que sabés **dónde vive cada cosa**, Q2 te hace **moverlas**.

Vas a tomar el Mini Jira que construiste en F0–F11 y lo vas a montar sobre `mini-jira-q`:

| De… (curso base) | A… (Q2) | Qué aprendés |
|---|---|---|
| `main.js` con el interceptor de F2 | `src/boot/axios.js` | Que el store te lo pasan por parámetro, y por qué eso mata el import circular |
| `App.vue` con navbar + `router-view` | `layouts/MainLayout.vue` + `App.vue` vacío | Que el chrome es una ruta, no un wrapper |
| `views/*.vue` | `pages/*.vue` con `<q-page>` de raíz | Que la raíz importa |
| `router/index.js` de F1 | `router/routes.js` con layouts como padres | Que Vue Router 3 no cambió; el patrón sí |
| `store/modules/tickets.js` de F10 | `store/` | **Nada.** Se copia tal cual. Ese es el punto |
| `<button class="btn btn-primary">` | `<q-btn color="primary">` | Y a agregar `'QBtn'` a `framework.components` — **cada vez** |
| Tu modal de confirmación de F5 | `this.$q.dialog()` | Que borraste 40 líneas |
| Tu componente de alertas de F5 | `this.$q.notify()` | Que borraste otras 30 |
| **`vuelidate` (F5) en `package.json`** | `:rules` de `<q-input>` | Que **sacás una dependencia entera** del proyecto, no cambiás un componente |

**El spoiler incómodo de Q2:**

Q2 no es solo "cambiar `<b-form-input>` por `<q-input>`". F5 valida con **vuelidate 0.7.7**. Migrar a `:rules` significa **borrar vuelidate del `package.json`** — adiós `$v`, `$touch`, `$error`. Qué ganás y qué perdés en ese trueque es media Q2.

**La pregunta que abre Q2:**

> Tenés el CRUD de tickets (F5, con vuelidate) funcionando en Vue CLI + Bootstrap.
> Tenés `mini-jira-q` vacío, en Quasar.
> Y tenés los tests de regresión de Q0, intactos.
> **¿Qué copiás tal cual, qué reescribís, qué borrás porque Quasar ya lo trae — y qué tests se ponen rojos sin que hayas roto nada?**

Esa clasificación — **copiar / reescribir / borrar** — es Q2 entera. Y los tests de Q0 son el árbitro.

Y spoiler: la columna de "borrar" es más larga de lo que esperás. Y la de "copiar tal cual" también.

**Nos vemos en Q2.** 🚀
