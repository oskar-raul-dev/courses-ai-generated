# 🌍 Prompt Maestro: Traducción de Endpoints y Constantes al Inglés
## Curso Vue 2 Legacy — Cambio Editorial Global

---

## 📋 Resumen Ejecutivo

**Objetivo:** Traducir **TODO el código, endpoints y constantes** de español a inglés en los 16 archivos de contenido del curso + 5 apéndices + 9 variantes de frameworks.

**Scope:**
- ✅ Código fuente (variables, funciones, constantes, endpoint URLs)
- ✅ Comentarios en código permanecen en ESPAÑOL
- ✅ Texto narrativo del curso permanece en ESPAÑOL
- ✅ Especificadores de props, eventos, data keys
- ❌ Títulos, párrafos explicativos, ejemplos narrativos → todo sigue en español

**Total de archivos:** 30 documentos Markdown (~1.5 MB)

---

## 🎯 Qué Cambiar (El Diccionario)

### Endpoints HTTP y URLs

| Español | Inglés | Contexto |
|---------|--------|---------|
| `/tickets` | `/tickets` | ✅ ya en inglés |
| `GET /tickets` | `GET /tickets` | ✅ ya en inglés |
| `POST /tickets` | `POST /tickets` | ✅ ya en inglés |
| `/usuarios` | `/users` | API REST |
| `/agentes` | `/agents` | API REST |
| `/comentarios` | `/comments` | API REST |
| `/estados` | `/statuses` | referencial |
| `/prioridades` | `/priorities` | referencial |
| `/métricas` | `/metrics` | API REST |
| `/notificaciones` | `/notifications` | WebSocket route |
| `/buscar` | `/search` | query/endpoint |

### Nombres de Funciones y Métodos

| Español | Inglés | Contexto |
|---------|--------|---------|
| `obtenerTickets()` | `getTickets()` | service method |
| `obtenerTicketPor()` / `obtenerTicketById()` | `getTicketById()` | service method |
| `crearTicket()` | `createTicket()` | service method |
| `actualizarTicket()` / `editarTicket()` | `updateTicket()` | service method |
| `eliminarTicket()` / `borrarTicket()` | `deleteTicket()` | service method |
| `listarTickets()` | `listTickets()` | service method |
| `obtenerUsuario()` | `getUser()` | service method |
| `crearComentario()` | `createComment()` | service method |
| `obtenerComentarios()` | `getComments()` | service method |
| `obtenerMétricas()` | `getMetrics()` | service method |
| `conectarWebSocket()` | `connectWebSocket()` | method |
| `desconectarWebSocket()` | `disconnectWebSocket()` | method |
| `cargarDatos()` | `loadData()` | method |
| `guardarDatos()` | `saveData()` | method |
| `validarFormulario()` | `validateForm()` | method |
| `enviarFormulario()` | `submitForm()` | method |

### Nombres de Variables y Data Properties

| Español | Inglés | Contexto |
|---------|--------|---------|
| `tickets` | `tickets` | ✅ ya en inglés |
| `usuarios` | `users` | array |
| `agentes` | `agents` | array |
| `comentarios` | `comments` | array |
| `cargando` | `loading` | boolean |
| `error` | `error` | string |
| `éxito` | `success` | boolean |
| `guardando` | `saving` | boolean |
| `editando` | `editing` | boolean |
| `formulario` | `form` | object |
| `usuarioActual` | `currentUser` | object |
| `ticketActual` | `currentTicket` | object |
| `filtros` | `filters` | object |
| `ordenamiento` | `sorting` | object |
| `paginación` | `pagination` | object |
| `sesión` | `session` | object |
| `token` | `token` | ✅ ya en inglés |
| `estado` | `status` | enum/property |
| `prioridad` | `priority` | enum/property |
| `asignado` | `assignee` | property |
| `reportero` | `reporter` | property |
| `creado` | `createdAt` | timestamp |
| `actualizado` | `updatedAt` | timestamp |
| `mensaje` | `message` | string |
| `descripción` | `description` | ✅ ya en inglés |
| `titulo` | `title` | ✅ ya en inglés |

### Estados y Enums

| Español | Inglés | Contexto |
|---------|--------|---------|
| `abierto` | `open` | ticket status |
| `cerrado` | `closed` | ticket status |
| `en_progreso` | `in_progress` | ticket status |
| `resuelto` | `resolved` | ticket status |
| `pendiente` | `pending` | ticket status |
| `alto` | `high` | priority level |
| `medio` | `medium` | priority level |
| `bajo` | `low` | priority level |
| `crítico` | `critical` | priority level |
| `desconocido` | `unknown` | fallback status |

### Acciones de Vuex (Store)

| Español | Inglés | Contexto |
|---------|--------|---------|
| `auth/login` | `auth/login` | ✅ check consistency |
| `auth/logout` | `auth/logout` | ✅ check consistency |
| `auth/restaurarSesion` | `auth/restoreSession` | store action |
| `tickets/cargarTickets` | `tickets/loadTickets` | store action |
| `tickets/obtenerTicket` | `tickets/fetchTicket` | store action |
| `tickets/crearTicket` | `tickets/createTicket` | store action |
| `tickets/actualizarTicket` | `tickets/updateTicket` | store action |
| `tickets/eliminarTicket` | `tickets/deleteTicket` | store action |
| `tickets/establecerFiltros` | `tickets/setFilters` | store action |
| `tickets/establecerOrdenamiento` | `tickets/setSorting` | store action |
| `usuarios/cargarUsuarios` | `users/loadUsers` | store action |
| `comentarios/cargarComentarios` | `comments/loadComments` | store action |

### Rutas del Router (paths)

| Español | Inglés | Contexto |
|---------|--------|---------|
| `/login` | `/login` | ✅ ya en inglés |
| `/tickets` | `/tickets` | ✅ ya en inglés |
| `/tickets/nuevo` | `/tickets/new` | route |
| `/tickets/:id` | `/tickets/:id` | ✅ ya en inglés |
| `/tickets/:id/editar` | `/tickets/:id/edit` | route |
| `/tickets/:id/detalles` | `/tickets/:id/details` | route |
| `/dashboard` | `/dashboard` | ✅ ya en inglés |
| `/métricas` | `/metrics` | route |
| `/panel-soporte` | `/support-panel` | route |
| `/configuración` | `/settings` | route |
| `/perfil` | `/profile` | route |

### Nombres de Componentes

| Español | Inglés | Contexto |
|---------|--------|---------|
| `TicketFormulario.vue` | `TicketForm.vue` | component |
| `TicketLista.vue` | `TicketList.vue` | component |
| `TicketDetalle.vue` | `TicketDetail.vue` | component |
| `TicketCrearVista.vue` | `TicketCreateView.vue` | view |
| `TicketEditarVista.vue` | `TicketEditView.vue` | view |
| `EncabezadoApp.vue` | `AppHeader.vue` | ✅ check |
| `BarraLateral.vue` | `AppSidebar.vue` | ✅ check |
| `TítuloPágina.vue` | `PageTitle.vue` | component |
| `TablaDatos.vue` | `DataTable.vue` | component |
| `ModalConfirmacion.vue` | `ConfirmModal.vue` | component |

### Nombres de Servicios

| Español | Inglés | Contexto |
|---------|--------|---------|
| `ticketService.js` | `ticketService.js` | ✅ ya en inglés |
| `usuarioService.js` | `userService.js` | service |
| `agenteService.js` | `agentService.js` | service |
| `comentarioService.js` | `commentService.js` | service |
| `autenticacionService.js` / `authService.js` | `authService.js` | service |
| `notificacionService.js` | `notificationService.js` | service |
| `clienteAPI.js` | `apiClient.js` | ✅ check |

### Props y Eventos Personalizados

| Español | Inglés | Contexto |
|---------|--------|---------|
| `:ticketInicial` | `:initialTicket` | prop |
| `:usuarioActual` | `:currentUser` | prop |
| `:cargando` | `:loading` | prop |
| `:error` | `:error` | prop |
| `@enviar` | `@submit` | event |
| `@cancelar` | `@cancel` | event |
| `@eliminar` | `@delete` | event |
| `@actualizar` | `@update` | event |
| `@guardar` | `@save` | event |

### Claves de Store (state, getters, etc.)

| Español | Inglés | Contexto |
|---------|--------|---------|
| `state.tickets` | `state.tickets` | ✅ ya en inglés |
| `state.usuarioActual` | `state.currentUser` | store state |
| `state.sesión` | `state.session` | store state |
| `state.cargando` | `state.loading` | store state |
| `state.error` | `state.error` | store state |
| `getters.obtenerTicketPorId` | `getters.getTicketById` | store getter |
| `getters.usuariosActivos` | `getters.activeUsers` | store getter |
| `getters.ticketsAbiertos` | `getters.openTickets` | store getter |
| `mutations.establecerTickets` | `mutations.SET_TICKETS` | store mutation |
| `mutations.establecerCargando` | `mutations.SET_LOADING` | store mutation |
| `mutations.establecerError` | `mutations.SET_ERROR` | store mutation |

### Textos dentro de código (strings que representan estado/estado)

Estos van en el diccionario pero verificar contexto:

| Español | Inglés | Contexto |
|---------|--------|---------|
| `"Cargando tickets..."` | Permanece en español | UI text en template |
| `"No se pudo crear..."` | Permanece en español | UI error message |
| `status: "abierto"` | `status: "open"` | enum value en data |
| `prioridad: "alto"` | `priority: "high"` | enum value en data |

---

## 📁 Archivos a Traducir (30 totales)

### Núcleo del Curso (12 fases)
- [ ] `00-setup-hola-mundo.md`
- [ ] `01-estructura-base-legacy.md`
- [ ] `02-autenticacion-minima.md`
- [ ] `03-mock-api-minima.md`
- [ ] `04-dashboard-tickets.md`
- [ ] `05-crud-tickets.md`
- [ ] `06-wizard-minimo.md`
- [ ] `07-metricas-minimas.md`
- [ ] `08-websockets-minimos.md`
- [ ] `09-panel-soporte.md`
- [ ] `10-vuex-a-fondo.md`
- [ ] `11-testing-minimo.md`

### Apéndices (5 archivos)
- [ ] `A1-bootstrap.md`
- [ ] `A2-node.md`
- [ ] `A3-npm.md`
- [ ] `A4-axios.md`
- [ ] `A5-webpack-babel.md`

### Documentación Meta (3 archivos)
- [ ] `README.md`
- [ ] `0-plan-del-curso.md`
- [ ] `0-ESTRUCTURA-CURSO.md`

### Rutas de Frameworks (10 archivos)

#### Quasar (5 archivos)
- [ ] `Q0-red-de-seguridad.md`
- [ ] `Q1-leer-quasar.md`
- [ ] `Q2-migrar-crud-qform.md`
- [ ] `Q3-migrar-dashboard-qtable.md`
- [ ] `Q4-timeline-actividad.md`

#### Vuetify (5 archivos)
- [ ] `VU0-red-de-seguridad.md`
- [ ] `VU1-leer-vuetify.md`
- [ ] `VU2-migrar-crud-vuetify.md`
- [ ] `VU3-migrar-dashboard-vdatatable.md`
- [ ] `VU4-timeline-vuetify.md`

#### NuxtJS (5 archivos)
- [ ] `NX0-red-de-seguridad.md`
- [ ] `NX1-leer-nuxt.md`
- [ ] `NX2-hidratacion-window-not-defined.md`
- [ ] `NX3-asyncdata-vs-vuex.md`
- [ ] `NX4-pagina-ssr-nueva.md`

---

## 🔍 Patrones de Búsqueda y Reemplazo (Regex/Exacto)

### Por tipo de archivo:

#### A. Dentro de bloques de código (` ```js ` y ` ```vue `)
- Funciones: `function obtener`, `function crear`, etc. → inglés
- Variables: `var usuario =`, `let comentarios =`, etc. → inglés
- Métodos en llamadas: `.obtenerTickets()`, `.crearComentario()` → inglés
- Props: `:ticketInicial`, `:usuarioActual` → inglés
- Eventos: `@enviar`, `@cancelar`, `@eliminar` → inglés
- Rutas: `path: "/tickets/nuevo"`, `path: "/tickets/:id/editar"` → inglés
- URLs de API: `"/usuarios"`, `"/comentarios"` → inglés
- Estados: `status: "abierto"`, `priority: "alto"` → inglés
- Acciones de Vuex: `this.$store.dispatch("tickets/crearTicket")` → inglés

#### B. Dentro de comentarios de código (permanecen en español)
- NO tocar: `// obtener lista de tickets`, `// validar formulario`

#### C. Dentro de narrativa (permanecen en español)
- NO tocar: títulos, párrafos explicativos, ejemplos de prosa

#### D. Dentro de templates HTML (mezclado)
- Literales de URL: `@click="$router.push('/tickets/nuevo')"` → `/tickets/new`
- Bindings a métodos: `@submit="enviarFormulario"` → `@submit="submitForm"`
- Condicionales: `v-if="cargando"` → `v-if="loading"`
- Loops: `v-for="ticket in tickets"` → ✅ ya en inglés

---

## 🛠️ Instructivo Paso a Paso por Archivo

### Para CADA archivo:

1. **Identificar bloques de código** (` ```js `, ` ```vue `, ` ```json `)
2. **Dentro de cada bloque:**
   - Traducir TODAS las variables, funciones, nombres de propiedades
   - Traducir endpoints y rutas
   - Traducir estados/enums
   - **NO tocar** comentarios (permanecen en español)
   - **NO tocar** strings UI ("Cargando...", "Error en...")
3. **Verificar coherencia:**
   - Si `A.js` define `getTickets()`, todas las llamadas usan `getTickets()`
   - Si una ruta es `/tickets/new`, todo router-link y push usan `/tickets/new`
   - Si un estado es `loading`, toda el componente usa `loading`
4. **Dejar narrativa intacta:**
   - Títulos, explicaciones, ejemplos prosa = 100% español
   - Solo código cambia

---

## ✅ Checklist Final por Archivo

Para cada archivo, validar:

- [ ] Endpoints `/usuarios`, `/agentes`, `/comentarios` → inglés
- [ ] Funciones `obtener*`, `crear*`, `actualizar*`, `eliminar*` → inglés
- [ ] Variables `cargando`, `error`, `usuario*`, `ticket*` → inglés
- [ ] Props `:ticketInicial`, `:usuarioActual` → inglés
- [ ] Eventos `@enviar`, `@cancelar` → inglés
- [ ] Rutas `/tickets/nuevo`, `/tickets/:id/editar` → inglés
- [ ] Estados en data y store `status: "abierto"` → `status: "open"`
- [ ] Acciones Vuex `tickets/crearTicket` → `tickets/createTicket`
- [ ] Comentarios de código SÍ permanecen en español
- [ ] Texto narrativo SÍ permanece en español
- [ ] No quedan referencias sueltas en español en código

---

## 🚀 Ejemplo Concreto: Antes y Después

### ANTES (Fase 3)

```js
// services/ticketService.js
function obtenerTickets(params) {
  // Obtener lista de tickets
  return apiClient.get("/tickets", { params: params }).then(function (res) {
    return res.data;
  });
}

function crearTicket(data) {
  // Crear un ticket nuevo
  return apiClient.post("/tickets", data).then(function (res) {
    return res.data;
  });
}

export default {
  obtenerTickets: obtenerTickets,
  crearTicket: crearTicket
};
```

### DESPUÉS (misma fase, traducido)

```js
// services/ticketService.js
function getTickets(params) {
  // Obtener lista de tickets
  return apiClient.get("/tickets", { params: params }).then(function (res) {
    return res.data;
  });
}

function createTicket(data) {
  // Crear un ticket nuevo
  return apiClient.post("/tickets", data).then(function (res) {
    return res.data;
  });
}

export default {
  getTickets: getTickets,
  createTicket: createTicket
};
```

---

### ANTES (Fase 2 - Form)

```vue
<template>
  <form @submit.prevent="enviarFormulario">
    <input v-model="formulario.titulo" placeholder="Título" />
    <input v-model="formulario.descripcion" placeholder="Descripción" />
    <button type="submit" :disabled="guardando">
      {{ guardando ? 'Guardando...' : 'Guardar' }}
    </button>
  </form>
</template>

<script>
export default {
  data() {
    return {
      formulario: { titulo: '', descripcion: '' },
      guardando: false
    };
  },
  methods: {
    enviarFormulario() {
      this.guardando = true;
      // ... lógica
    }
  }
};
</script>
```

### DESPUÉS

```vue
<template>
  <form @submit.prevent="submitForm">
    <input v-model="form.title" placeholder="Título" />
    <input v-model="form.description" placeholder="Descripción" />
    <button type="submit" :disabled="saving">
      {{ saving ? 'Guardando...' : 'Guardar' }}
    </button>
  </form>
</template>

<script>
export default {
  data() {
    return {
      form: { title: '', description: '' },
      saving: false
    };
  },
  methods: {
    submitForm() {
      this.saving = true;
      // ... lógica
    }
  }
};
</script>
```

---

### ANTES (Router)

```js
{
  path: "/tickets/nuevo",
  name: "ticket-crear",
  component: TicketCrearVista,
  meta: { requiresAuth: true }
},
{
  path: "/tickets/:id/editar",
  name: "ticket-editar",
  component: TicketEditarVista,
  meta: { requiresAuth: true }
}
```

### DESPUÉS

```js
{
  path: "/tickets/new",
  name: "ticket-create",
  component: TicketCreateView,
  meta: { requiresAuth: true }
},
{
  path: "/tickets/:id/edit",
  name: "ticket-edit",
  component: TicketEditView,
  meta: { requiresAuth: true }
}
```

---

### ANTES (Store action)

```js
// store/modules/tickets.js
const actions = {
  cargarTickets({ commit }, params) {
    // Cargar tickets desde la API
    return ticketService.obtenerTickets(params).then(tickets => {
      commit('establecerTickets', tickets);
      return tickets;
    });
  },
  crearTicket({ commit }, data) {
    // Crear ticket y actualizar estado
    return ticketService.crearTicket(data).then(ticket => {
      commit('agregarTicket', ticket);
      return ticket;
    });
  }
};
```

### DESPUÉS

```js
// store/modules/tickets.js
const actions = {
  loadTickets({ commit }, params) {
    // Cargar tickets desde la API
    return ticketService.getTickets(params).then(tickets => {
      commit('SET_TICKETS', tickets);
      return tickets;
    });
  },
  createTicket({ commit }, data) {
    // Crear ticket y actualizar estado
    return ticketService.createTicket(data).then(ticket => {
      commit('ADD_TICKET', ticket);
      return ticket;
    });
  }
};
```

---

## 📊 Validación de Cobertura

Después de terminar TODOS los archivos:

1. **Buscar restos en español en código:**
   ```bash
   grep -E "obtener|crear|actualizar|eliminar|cargar|guardar|formulario|usuario|agente|comentario" *.md \
     | grep -v "// " | grep -v "^[^:]*:.*Obtener\|Crear\|Actualizar" \
     | grep '```'
   ```

2. **Verificar consistencia de nombres:**
   - Todas las funciones `getTickets` usan `getTickets` (no `getTicket*s*`)
   - Todos los status usan `"open"`, no mezclar `"open"` y `"opened"`
   - Todas las rutas usan `/tickets/new`, no `/tickets/nuevo`

3. **Revisar manualmente:**
   - Una pasada de lectura de cada archivo
   - Verifica que código lea correctamente
   - Confirma que narrativa es 100% español

---

## 🎯 Orden Recomendado de Traducción

1. **Fase 0–1 (base):** `00-setup-hola-mundo.md`, `01-estructura-base-legacy.md`
   - Define la base de nombres
2. **Fase 2–3 (auth + API):** `02-autenticacion-minima.md`, `03-mock-api-minima.md`
   - Endpoints, servicios, store
3. **Fase 4–6 (UI):** `04-dashboard-tickets.md`, `05-crud-tickets.md`, `06-wizard-minimo.md`
   - Componentes, props, eventos
4. **Fase 7–11 (advanced):** métricas, websockets, panel, vuex, testing
   - Acciones, getters, listeners
5. **Apéndices A1–A5:** referencias técnicas
   - Menos código Vue, más conceptos
6. **Frameworks (Q/VU/NX):** traducir en el mismo orden que el tronco
   - Spookier porque reutilizan código del tronco
7. **Meta-docs:** README, plan, estructura
   - Menos código, más links

---

## 🚨 Errores Comunes a Evitar

1. ❌ Traducir nombres de métodos de npm (`.then()`, `.map()`, etc.)
   - ✅ Solo métodos **propios** del curso
2. ❌ Traducir comentarios de código
   - ✅ Los comentarios permanecen en español
3. ❌ Traducir strings de UI ("Cargando...", "Error")
   - ✅ Strings que representan **datos** (enums, status) sí se traducen
4. ❌ Dejar inconsistencia entre archivo y archivo
   - ✅ Usar el diccionario siempre
5. ❌ Olvidar traducir el mismo código en variantes de frameworks
   - ✅ Si `ticketService.getTickets()` está en tronco, está también en Q/VU/NX
6. ❌ Traducir nombres de librerías (`Vue`, `Vuex`, `Bootstrap`, `QTable`, etc.)
   - ✅ Solo código del usuario
7. ❌ Romper rutas del router
   - ✅ Si traducís `/tickets/nuevo` a `/tickets/new`, TODAS las referencias cambian

---

## 📝 Salida Esperada

**30 archivos Markdown**, idénticos en estructura y narrativa a los originales, pero:
- Código 100% en inglés ✅
- Comentarios 100% en español ✅
- Narrativa 100% en español ✅
- Referencias internas (links, etc.) ajustadas si tocaron nombres de archivo ✅

---

## 🔗 Integración con el Workflow

1. **Revisar** este prompt con el equipo
2. **Traducir en orden** (fase 0–1 → 2–3 → ... → frameworks)
3. **Validar coherencia** entre fases
4. **Ejecutar grep** para detectar restos en español
5. **Commit** a repo con mensaje: `refactor: translate endpoints and code to English`
6. **Rever** en CI/CD (si existe)

---

**Listo para empezar. ¿Alguna aclaración antes de traducir?**
