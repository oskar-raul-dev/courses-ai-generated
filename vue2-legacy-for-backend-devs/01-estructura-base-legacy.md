# 🏗️ Fase 1 — Estructura base legacy

## 🎯 Propósito

Tomar el Hello World de la Fase 0 y darle **forma de proyecto real**: carpetas,
layout, router y vistas placeholder. Todavía no construimos funcionalidades;
construimos el esqueleto sobre el que crecerá el Mini Jira.

La idea pedagógica es simple:

> antes de agregar funcionalidades, primero se deja clara la forma del proyecto.

En muchos proyectos legacy el problema no es Vue: es que todo termina mezclado
(rutas en archivos enormes, HTTP desde componentes de pantalla, layout acoplado
a lógica de negocio). Aquí aprendemos a evitar eso desde el día uno.

---

## ✅ Qué queda listo al terminar

- la app corre en local y **se ve como un sistema interno** (header + sidebar + contenido);
- se navega entre varias vistas placeholder;
- estructura de carpetas mínima pero reconocible;
- Bootstrap integrado para maquetación;
- `services/`, `router/` y `store/` preparados para crecer.

## 🚫 Qué NO entra todavía

- autenticación ni guards (Fase 2)
- consumo real de API (Fase 3)
- CRUD y validaciones (Fase 5)
- Vuex en serio (Fase 10)
- testing (Fase 11)

---

## 🧱 Versiones de esta fase

Las del [plan del curso](0-plan-del-curso.md). Recordatorio de lo nuevo:

```bash
npm install vue-router@3 vuex@3
```

> ⚠️ **Corrección respecto a borradores anteriores:** la versión oficial de Vue
> del curso es **2.6.14** (y `vue-template-compiler@2.6.14`). Si tu proyecto de
> la Fase 0 quedó en otra versión 2.x, actualiza ambos paquetes ahora:
>
> ```bash
> npm install vue@2.6.14
> npm install --save-dev vue-template-compiler@2.6.14
> ```

---

## 🛠️ VS Code para Vue 2 legacy

Extensiones: **Vetur** (no Volar, que es para Vue 3), ESLint, Prettier,
Path Intellisense.

`settings.json` sugerido:

```json
{
  "editor.formatOnSave": true,
  "editor.tabSize": 2,
  "eslint.validate": ["javascript", "vue"],
  "[vue]": { "editor.defaultFormatter": "octref.vetur" },
  "vetur.validation.template": true,
  "vetur.validation.script": true
}
```

`jsconfig.json` en la raíz (mejora imports y autocompletado con el alias `@`):

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": { "@/*": ["src/*"] }
  },
  "exclude": ["node_modules", "dist"]
}
```

No hace falta TypeScript ni nada más moderno. Vetur + jsconfig y a trabajar.

---

## 📦 Estructura del proyecto

```
src/
  assets/
  components/
    common/
      PageTitle.vue
    layout/
      AppHeader.vue
      AppSidebar.vue
  router/
    index.js
  services/
    apiClient.js
    ticketService.js
  store/
    index.js
    modules/
      tickets.js
  views/
    HomeView.vue
    TicketsView.vue
    TicketDetailView.vue
    NotFoundView.vue
  App.vue
  main.js
```

### Criterio de cada carpeta

| Carpeta | Qué vive ahí | Ejemplo |
|---|---|---|
| `views/` | pantallas completas asociadas a rutas | listado de tickets |
| `components/` | piezas reutilizables de UI | header, sidebar, PageTitle |
| `router/` | configuración de navegación | `index.js` |
| `services/` | consumo HTTP (futuro) | `ticketService.js` |
| `store/` | estado global compartido | módulo `tickets` |
| `assets/` | CSS, imágenes, estáticos | logo |

**Regla mental para dev backend:** `views/` son tus controllers, `services/` tu
capa de acceso a datos, `store/` tu caché compartida. No es exacto, pero orienta.

---

## 🧩 Layout base

```
+--------------------------------------------------+
| Header                                           |
+----------------------+---------------------------+
| Sidebar              | Contenido principal       |
|                      | <router-view />           |
+----------------------+---------------------------+
```

Bootstrap aquí es un atajo, no un tema de estudio: grid, spacing, navbar,
cards. Nada de modals, tooltips ni JS de Bootstrap todavía.

### `App.vue`

```vue
<template>
  <div id="app" class="d-flex flex-column min-vh-100">
    <app-header />

    <div class="container-fluid flex-grow-1">
      <div class="row">
        <div class="col-md-3 col-lg-2 bg-light border-right p-0">
          <app-sidebar />
        </div>

        <main class="col-md-9 col-lg-10 p-4">
          <router-view />
        </main>
      </div>
    </div>
  </div>
</template>

<script>
import AppHeader from "./components/layout/AppHeader.vue";
import AppSidebar from "./components/layout/AppSidebar.vue";

export default {
  name: "App",
  components: { AppHeader, AppSidebar }
};
</script>
```

### `components/layout/AppHeader.vue`

```vue
<template>
  <header class="navbar navbar-dark bg-dark px-3">
    <span class="navbar-brand mb-0 h1">Mini Jira</span>
  </header>
</template>

<script>
export default { name: "AppHeader" };
</script>
```

### `components/layout/AppSidebar.vue`

```vue
<template>
  <aside class="p-3">
    <ul class="nav flex-column">
      <li class="nav-item">
        <router-link class="nav-link" to="/">Inicio</router-link>
      </li>
      <li class="nav-item">
        <router-link class="nav-link" to="/tickets">Tickets</router-link>
      </li>
    </ul>
  </aside>
</template>

<script>
export default { name: "AppSidebar" };
</script>
```

---

## 🛣️ Router mínimo

Rutas de la fase:

- `/` → HomeView
- `/tickets` → TicketsView
- `/tickets/:id` → TicketDetailView (ruta dinámica)
- `*` → NotFoundView (fallback)

### `router/index.js`

```js
import Vue from "vue";
import Router from "vue-router";
import HomeView from "../views/HomeView.vue";
import TicketsView from "../views/TicketsView.vue";
import TicketDetailView from "../views/TicketDetailView.vue";
import NotFoundView from "../views/NotFoundView.vue";

Vue.use(Router);

export default new Router({
  mode: "history",
  routes: [
    { path: "/", name: "home", component: HomeView },
    { path: "/tickets", name: "tickets", component: TicketsView },
    { path: "/tickets/:id", name: "ticket-detail", component: TicketDetailView },
    { path: "*", name: "not-found", component: NotFoundView }
  ]
});
```

Y en `main.js`:

```js
import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import store from "./store";
import "bootstrap/dist/css/bootstrap.min.css";

Vue.config.productionTip = false;

new Vue({
  router: router,
  store: store,
  render: function (h) {
    return h(App);
  }
}).$mount("#app");
```

### Vistas placeholder

```vue
<!-- views/HomeView.vue -->
<template>
  <section>
    <h1>Inicio</h1>
    <p>Mesa de soporte Mini Jira — base legacy del proyecto.</p>
  </section>
</template>
```

```vue
<!-- views/TicketsView.vue -->
<template>
  <section>
    <h1>Tickets</h1>
    <p>Aquí luego irá el listado de tickets.</p>
  </section>
</template>
```

```vue
<!-- views/TicketDetailView.vue -->
<template>
  <section>
    <h1>Detalle de ticket</h1>
    <p>ID recibido: {{ $route.params.id }}</p>
  </section>
</template>
```

```vue
<!-- views/NotFoundView.vue -->
<template>
  <section>
    <h1>404</h1>
    <p>La ruta no existe.</p>
  </section>
</template>
```

Con esto ya se explica lo esencial: ruta normal, ruta dinámica con `:id`,
fallback, `router-view` y `router-link`. Lazy loading, nested routes y guards
quedan para después.

---

## 🧰 Servicios preparados (sin API real)

`services/` no debe quedar vacía: el mensaje es que **el componente no es el
lugar natural para la lógica HTTP**.

### `services/apiClient.js` (placeholder honesto)

```js
// 💸 Deuda declarada: esto se aterriza en la Fase 2 (interceptor)
// y se conecta a json-server en la Fase 3.
import axios from "axios";

var apiClient = axios.create({
  baseURL: "http://localhost:3000"
});

export default apiClient;
```

### `services/ticketService.js` (datos simulados)

```js
var MOCK_TICKETS = [
  { id: 1, title: "La impresora no imprime", status: "open", priority: "high" },
  { id: 2, title: "No me llega el correo", status: "in_progress", priority: "medium" }
];

function getTickets() {
  return MOCK_TICKETS;
}

function getTicketById(id) {
  return MOCK_TICKETS.find(function (t) {
    return t.id === Number(id);
  });
}

export default {
  getTickets: getTickets,
  getTicketById: getTicketById
};
```

---

## 🗂️ Store mínimo, sin sobreusarlo

La fase aún no es de Vuex, pero dejamos la forma lista.

### `store/modules/tickets.js`

```js
const state = { items: [] };

const mutations = {
  setTickets: function (state, tickets) {
    state.items = tickets;
  }
};

export default {
  namespaced: true,
  state: state,
  mutations: mutations
};
```

### `store/index.js`

```js
import Vue from "vue";
import Vuex from "vuex";
import tickets from "./modules/tickets";

Vue.use(Vuex);

export default new Vuex.Store({
  modules: { tickets: tickets }
});
```

**Mensaje pedagógico:** en legacy real se ven dos extremos — todo en Vuex sin
necesidad, o nada centralizado y cada vista con su copia del estado. Vuex se
reserva para lo *realmente compartido*. Lo demás, estado local del componente.

---

## ⚠️ Errores comunes

- meter demasiada lógica en `App.vue`;
- una sola carpeta `components/` para todo (vistas incluidas);
- consumir datos desde cualquier parte sin capa de servicios;
- meter Vuex antes de saber qué estado será compartido de verdad;
- sobrediseñar el layout antes de tener funcionalidad;
- desalinear `vue` y `vue-template-compiler` (error críptico de compilación garantizado).

---

## 🧪 Ejercicios (25)

**🟢 Fácil (1–8)**

1. Crea `AboutView.vue` con un título y una descripción del proyecto.
2. Agrega la ruta `/about` al router.
3. Agrega el enlace a `/about` en el sidebar.
4. Cambia `HomeView.vue` para que hable del Mini Jira y no del Hello World.
5. Cambia el título del header por "Mini Jira — Soporte" y agrega un emoji.
6. Crea el componente `common/PageTitle.vue` que reciba un prop `title` y lo pinte en un `<h1>`.
7. Usa `PageTitle` en dos vistas distintas.
8. Navega a `/tickets/999` y verifica qué muestra el detalle. ¿Por qué no da 404?

**🟡 Intermedio (9–16)**

9. Haz que `TicketsView.vue` pinte la lista de `ticketService.getTickets()` con un `v-for` en una lista `<ul>`.
10. Convierte esa lista en una tabla Bootstrap (`table table-striped`) con columnas id, título y estado.
11. Haz que cada fila tenga un `router-link` al detalle del ticket.
12. En `TicketDetailView.vue`, usa `ticketService.getTicketById($route.params.id)` para mostrar los datos reales del ticket.
13. Si el id no existe, muestra un mensaje "Ticket no encontrado" en vez de romper.
14. Agrega un prop opcional `subtitle` a `PageTitle` que solo se muestre si viene.
15. Agrega un tercer ticket mock con estado `resolved` y verifica que aparece en la tabla.
16. Marca el enlace activo del sidebar con la clase de Vue Router (`router-link-active`) y dale un estilo visible.

**🟠 Difícil (17–22)**

17. Crea un componente `TicketStatusBadge.vue` que reciba el estado y pinte un badge Bootstrap con color según estado (`open` rojo, `in_progress` amarillo, `resolved` verde). Úsalo en la tabla.
18. Extrae la tabla a un componente `TicketsTable.vue` que reciba los tickets por prop y emita un evento `select` al hacer clic en una fila. La vista hace la navegación.
19. Crea el módulo Vuex `tickets` completo: al montar `TicketsView`, despacha una action que llame al servicio y haga commit de `setTickets`; la vista lee de un getter.
20. Agrega un contador "N tickets" en el sidebar leyendo del store (getter `count`).
21. Cambia el router a `mode: "hash"` y observa qué pasa con las URLs. Vuelve a `history` y explica en un comentario cuándo usarías cada uno.
22. Agrega una ruta `/tickets/new` **antes** de `/tickets/:id`. Prueba qué pasa si la pones después y explica por qué el orden importa.

**🔴 Muy difícil (23–25)**

23. Implementa breadcrumbs simples: un componente que, según `$route`, muestre `Inicio / Tickets / Detalle #id`. Sin librerías.
24. Simula latencia: haz que `getTickets()` devuelva una `Promise` con `setTimeout` de 800 ms y maneja un estado `loading` en la vista (spinner Bootstrap). *Pista de lo que viene en la Fase 3.*
25. Refactor completo de la vista de tickets separando: componente de pantalla, componente de tabla, badge de estado, servicio de datos y estado compartido. El objetivo no es que quede "perfecto", sino decidir bien qué responsabilidad va en cada capa.

---

## 📚 Referencias

**Documentación oficial (empieza aquí)**

- Vue 2 Guide — https://v2.vuejs.org/v2/guide/
- Vue 2 Components Basics — https://v2.vuejs.org/v2/guide/components
- Vue Router 3 — https://v3.router.vuejs.org/
- Vuex 3 — https://v3.vuex.vuejs.org/
- Vue CLI — https://cli.vuejs.org/guide/
- Bootstrap 4.6 — https://getbootstrap.com/docs/4.6/getting-started/introduction/

**Cursos / video (apoyo, no obligatorio)**

- Vue Mastery — Intro to Vue 2: https://www.vuemastery.com/courses/intro-to-vue-js/vue-instance/
- Vue School — Vue Router for Everyone: https://vueschool.io/courses/vue-router-for-everyone
- Net Ninja — Vue JS 2 Tutorial (playlist en YouTube)
- Traversy Media — Vue JS Crash Course

**Libros (consulta selectiva)**

- *Vue.js in Action* — Hanchett & Listwon
- *Vue.js 2 Design Patterns and Best Practices*

> 💡 Usa estos materiales para fundamentos, pero implementa siguiendo la
> estructura de este curso, no copiando la arquitectura de los cursos externos.

---

## 🚀 Cierre

Esta fase no busca impresionar por complejidad. Busca dejar:

- una base reconocible,
- una estructura razonable,
- una app simple pero ordenada,
- el terreno listo para la autenticación de la Fase 2.

La señal de que quedó bien: que alguien abra el proyecto y diga
**"entiendo dónde vive cada cosa y cómo crecería este sistema"**.
