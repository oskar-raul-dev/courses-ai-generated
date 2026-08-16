# 📚 Diccionario Rápido de Referencia
## Para llevar a mano mientras traduces

---

## 🔤 Funciones y Métodos (BÚSQUEDA Y REEMPLAZO)

```
BUSCAR → REEMPLAZAR

obtener               → get
obtenerTickets        → getTickets
obtenerTicketById     → getTicketById
obtenerTicketPor      → getTicketBy*
obtenerUsuario        → getUser
obtenerAgente         → getAgent
obtenerComentario     → getComment
obtenerMétricas       → getMetrics

crear                 → create
crearTicket           → createTicket
crearComentario       → createComment
crearUsuario          → createUser

actualizar            → update
actualizarTicket      → updateTicket
editarTicket          → updateTicket (mismo método)
actualizarUsuario     → updateUser

eliminar              → delete
borrar                → delete
eliminarTicket        → deleteTicket
eliminarComentario    → deleteComment

listar                → list / get (depende contexto)
listarTickets         → listTickets o getTickets

cargar                → load
cargarTickets         → loadTickets
cargarUsuarios        → loadUsers
cargarDatos           → loadData

guardar               → save
guardarDatos          → saveData
guardarLocal          → saveToLocal

validar               → validate
validarFormulario     → validateForm
validarEmail          → validateEmail

enviar                → submit
enviarFormulario      → submitForm
enviarDatos           → submitData

conectar              → connect
conectarWebSocket     → connectWebSocket

desconectar           → disconnect
desconectarWebSocket  → disconnectWebSocket

restaurar             → restore
restaurarSesión       → restoreSession

establecer            → set
establecerTickets     → setTickets
establecerFiltros     → setFilters
establecerOrdenamiento → setSorting
```

---

## 📍 Endpoints y Rutas

```
BUSCAR → REEMPLAZAR

/usuarios             → /users
/agentes              → /agents
/comentarios          → /comments
/métricas             → /metrics
/notificaciones       → /notifications
/buscar               → /search
/tickets/nuevo        → /tickets/new
/tickets/:id/editar   → /tickets/:id/edit
/tickets/:id/detalles → /tickets/:id/details
/dashboard            → /dashboard (✅ ya inglés)
/login                → /login (✅ ya inglés)
/panel-soporte        → /support-panel
/configuración        → /settings
/perfil               → /profile
```

---

## 🔤 Variables y Properties (Data)

```
BUSCAR → REEMPLAZAR

tickets               → tickets (✅ ya inglés)
usuarios              → users
agentes               → agents
comentarios           → comments
métricas              → metrics
notificaciones        → notifications

cargando              → loading
guardando             → saving
editando              → editing
validando             → validating
buscando              → searching
conectando            → connecting

error                 → error (✅ ya inglés)
éxito                 → success
mensaje               → message
mensajeError          → errorMessage
mensajeÉxito          → successMessage

formulario            → form
usuarioActual         → currentUser
ticketActual          → currentTicket
sesión                → session
filtros               → filters
ordenamiento          → sorting
paginación            → pagination
búsqueda              → search
resultado             → result
resultados            → results

estado                → status
prioridad             → priority
asignado              → assignee
reportero             → reporter
creado                → createdAt
actualizado           → updatedAt
descripción           → description (✅ ya inglés)
título                → title (✅ ya inglés)

ticketInicial         → initialTicket
usuarioPor            → userBy* (depende)
datosFormulario       → formData
datosGuardados        → savedData
```

---

## 🏷️ Props y Atributos

```
BUSCAR → REEMPLAZAR

:ticketInicial        → :initialTicket
:usuarioActual        → :currentUser
:cargando             → :loading
:error                → :error (✅ ya inglés)
:éxito                → :success
:guardando            → :saving
:editando             → :editing
:deshabilitado        → :disabled (✅ ya inglés)
:visible              → :visible (✅ ya inglés)
:filtros              → :filters
:ordenamiento         → :sorting
:paginación           → :pagination
:resultados           → :results
```

---

## 📤 Eventos Personalizados

```
BUSCAR → REEMPLAZAR

@enviar               → @submit
@cancelar             → @cancel
@eliminar             → @delete
@guardar              → @save
@actualizar           → @update
@crear                → @create
@filtrar              → @filter
@buscar               → @search
@cargar               → @load
@abrir                → @open
@cerrar               → @close
@conectar             → @connect
@desconectar          → @disconnect
@cambiar              → @change
@seleccionar          → @select
@deseleccionar        → @deselect
@ordenar              → @sort
@paginar              → @paginate
```

---

## 🎯 Acciones de Vuex (Dispatch)

```
BUSCAR → REEMPLAZAR

auth/login            → auth/login (✅)
auth/logout           → auth/logout (✅)
auth/restaurarSesión  → auth/restoreSession

tickets/cargarTickets          → tickets/loadTickets
tickets/obtenerTicket          → tickets/fetchTicket
tickets/crearTicket            → tickets/createTicket
tickets/actualizarTicket       → tickets/updateTicket
tickets/eliminarTicket         → tickets/deleteTicket
tickets/establecerFiltros      → tickets/setFilters
tickets/establecerOrdenamiento → tickets/setSorting

usuarios/cargarUsuarios        → users/loadUsers
usuarios/obtenerUsuario        → users/fetchUser
usuarios/crearUsuario          → users/createUser
usuarios/actualizarUsuario     → users/updateUser

agentes/cargarAgentes          → agents/loadAgents
agentes/obtenerAgente          → agents/fetchAgent

comentarios/cargarComentarios  → comments/loadComments
comentarios/crearComentario    → comments/createComment

métricas/cargarMétricas        → metrics/loadMetrics
métricas/obtenerMétricas       → metrics/fetchMetrics

notificaciones/conectar        → notifications/connect
notificaciones/desconectar     → notifications/disconnect
notificaciones/enviar          → notifications/send
```

---

## 💾 Mutaciones de Vuex (Commit)

```
BUSCAR → REEMPLAZAR

establecerTickets      → SET_TICKETS
establecerCargando     → SET_LOADING
establecerError        → SET_ERROR
establecerÉxito        → SET_SUCCESS
establecerUsuario      → SET_USER
establecerSesión       → SET_SESSION
establecerFiltros      → SET_FILTERS
establecerOrdenamiento → SET_SORTING

agregarTicket          → ADD_TICKET
agregarComentario      → ADD_COMMENT
agregarUsuario         → ADD_USER

actualizarTicket       → UPDATE_TICKET
actualizarComentario   → UPDATE_COMMENT
actualizarUsuario      → UPDATE_USER

eliminarTicket         → DELETE_TICKET
eliminarComentario     → DELETE_COMMENT
eliminarUsuario        → DELETE_USER

limpiarError           → CLEAR_ERROR
limpiarSesión          → CLEAR_SESSION
limpiarDatos           → CLEAR_DATA
```

---

## 🔍 Getters de Vuex

```
BUSCAR → REEMPLAZAR

obtenerTicketPorId     → getTicketById
obtenerUsuarioPorId    → getUserById
obtenerAgentePorId     → getAgentById

obtenerTicketsAbiertos → getOpenTickets
obtenerTicketsCerrados → getClosedTickets
obtenerTicketsPorEstado → getTicketsByStatus
obtenerTicketsPorPrioridad → getTicketsByPriority

obtenerUsuariosActivos → getActiveUsers
obtenerAgentesDisponibles → getAvailableAgents

obtenerComentariosPorTicket → getCommentsByTicket

estaAutenticado        → isAuthenticated
estaConectado          → isConnected
tienePermiso           → hasPermission
```

---

## 🏗️ Nombres de Componentes

```
BUSCAR → REEMPLAZAR (en nombres de archivo)

TicketFormulario.vue         → TicketForm.vue
TicketLista.vue              → TicketList.vue
TicketDetalle.vue            → TicketDetail.vue
TicketCrearVista.vue         → TicketCreateView.vue
TicketEditarVista.vue        → TicketEditView.vue
TicketDetalleVista.vue       → TicketDetailView.vue
TicketWizardVista.vue        → TicketWizardView.vue

UsuarioLista.vue             → UserList.vue
UsuarioDetalle.vue           → UserDetail.vue
UsuarioFormulario.vue        → UserForm.vue

AgentePanel.vue              → AgentPanel.vue
AgenteFormulario.vue         → AgentForm.vue

ComentarioLista.vue          → CommentList.vue
ComentarioFormulario.vue     → CommentForm.vue

EncabezadoApp.vue            → AppHeader.vue (✅ check)
BarraLateral.vue             → AppSidebar.vue (✅ check)
PáginaPrincipal.vue          → HomePage.vue
PáginaLogin.vue              → LoginView.vue
PáginaDashboard.vue          → DashboardView.vue
PáginaMétricas.vue           → MetricsView.vue
PáginaPanelSoporte.vue       → SupportPanelView.vue

TítuloPágina.vue             → PageTitle.vue
TablaDatos.vue               → DataTable.vue
ModalConfirmación.vue        → ConfirmModal.vue
ModalError.vue               → ErrorModal.vue
ModalÉxito.vue               → SuccessModal.vue

CargandoSpinner.vue          → LoadingSpinner.vue
PaginaciónControles.vue      → PaginationControls.vue
FiltroPanel.vue              → FilterPanel.vue
OrdenamientoControles.vue    → SortingControls.vue

LoginFormulario.vue          → LoginForm.vue
```

---

## 📄 Archivos de Servicios

```
BUSCAR → REEMPLAZAR (en nombres de archivo)

autenticacionService.js      → authService.js
ticketService.js             → ticketService.js (✅)
usuarioService.js            → userService.js
agenteService.js             → agentService.js
comentarioService.js         → commentService.js
notificacionService.js       → notificationService.js
métricaService.js            → metricService.js
busquedaService.js           → searchService.js
```

---

## 🎭 Enums y Constantes

```
BUSCAR → REEMPLAZAR (en VALUES, no en claves)

Status:
"abierto"              → "open"
"cerrado"              → "closed"
"en_progreso"          → "in_progress"
"resuelto"             → "resolved"
"pendiente"            → "pending"
"en_espera"            → "waiting"

Priority:
"alto"                 → "high"
"medio"                → "medium"
"bajo"                 → "low"
"crítico"              → "critical"

Role:
"agente"               → "agent"
"usuario"              → "user"
"administrador"        → "admin"
"operador"             → "operator"

Estado de conexión:
"conectado"            → "connected"
"desconectado"         → "disconnected"
"conectando"           → "connecting"
"error"                → "error" (✅)

Tipo de notificación:
"éxito"                → "success"
"error"                → "error" (✅)
"advertencia"          → "warning"
"información"          → "info"
```

---

## 🔗 Importaciones en Código

```
BUSCAR → REEMPLAZAR

import usuarioService from 
  → import userService from

import agenteService from 
  → import agentService from

import comentarioService from 
  → import commentService from

import autenticacionService from / authService
  → import authService from

import { obtener* } from 
  → import { get* } from (si usa ES6)
```

---

## 📝 Patrones en Comentarios de Código (Permanecen en Español)

```
// ✅ ESTOS PERMANECEN EN ESPAÑOL:

// Obtener lista de tickets
// Crear un nuevo ticket
// Validar los datos del formulario
// Enviar la solicitud a la API
// Actualizar el estado local
// Eliminar el ticket seleccionado
// Conectar al WebSocket
// Restaurar sesión del usuario
```

---

## 📋 Tabla de Buscar/Reemplazar Rápida (Copy-Paste)

```
obtenerTickets          getTickets
obtenerTicketById       getTicketById
obtenerUsuario          getUser
obtenerAgente           getAgent
obtenerComentario       getComment
obtenerMétricas         getMetrics
crearTicket             createTicket
crearComentario         createComment
crearUsuario            createUser
actualizarTicket        updateTicket
actualizarUsuario       updateUser
eliminarTicket          deleteTicket
eliminarComentario      deleteComment
listarTickets           listTickets
cargarTickets           loadTickets
cargarUsuarios          loadUsers
guardarDatos            saveData
validarFormulario       validateForm
enviarFormulario        submitForm
conectarWebSocket       connectWebSocket
desconectarWebSocket    disconnectWebSocket
restaurarSesión         restoreSession
establecerTickets       setTickets
establecerFiltros       setFilters
establecerOrdenamiento  setSorting
usuarios                users
agentes                 agents
comentarios             comments
métricas                metrics
notificaciones          notifications
cargando                loading
guardando               saving
editando                editing
formulario              form
usuarioActual           currentUser
ticketActual            currentTicket
sesión                  session
filtros                 filters
ordenamiento            sorting
paginación              pagination
estado                  status
prioridad               priority
asignado                assignee
reportero               reporter
creado                  createdAt
actualizado             updatedAt
/usuarios               /users
/agentes                /agents
/comentarios            /comments
/métricas               /metrics
/notificaciones         /notifications
/tickets/nuevo          /tickets/new
/tickets/:id/editar     /tickets/:id/edit
/panel-soporte          /support-panel
/configuración          /settings
/perfil                 /profile
TicketFormulario.vue    TicketForm.vue
TicketLista.vue         TicketList.vue
TicketDetalle.vue       TicketDetail.vue
TicketCrearVista.vue    TicketCreateView.vue
TicketEditarVista.vue   TicketEditView.vue
EncabezadoApp.vue       AppHeader.vue
BarraLateral.vue        AppSidebar.vue
TítuloPágina.vue        PageTitle.vue
TablaDatos.vue          DataTable.vue
ModalConfirmación.vue   ConfirmModal.vue
tickets/cargarTickets   tickets/loadTickets
tickets/crearTicket     tickets/createTicket
tickets/actualizarTicket tickets/updateTicket
tickets/eliminarTicket  tickets/deleteTicket
usuarios/cargarUsuarios users/loadUsers
agentes/cargarAgentes   agents/loadAgents
comentarios/cargarComentarios comments/loadComments
establecerTickets       SET_TICKETS
establecerCargando      SET_LOADING
establecerError         SET_ERROR
agregarTicket           ADD_TICKET
actualizarTicket        UPDATE_TICKET
eliminarTicket          DELETE_TICKET
```

---

## 🎯 Pautas Mnemotécnicas

Para memorizar mientras traduces:

| Regla | Inglés | Aplicar a |
|-------|--------|-----------|
| Verbos base | get, create, update, delete, set, load, save, validate, submit | Funciones, métodos, acciones |
| Sustantivos | user, agent, comment, ticket, metric, notification | Variables, propiedades, arrays |
| Booleanos | loading, saving, editing, connected, authenticated | Flags, booleans, estado |
| Rutas | /new, /edit, /details, /settings, /profile | Paths de router |
| Props | :initialData, :currentUser, :isLoading | Atributos componentes |
| Eventos | @submit, @cancel, @delete, @save, @update | Eventos personalizados |
| Enums | "open", "closed", "high", "low" | Valores de estado/prioridad |
| Getters | getBy*, getAll*, is* | Funciones de lectura |
| Setters | set* | Mutaciones de Vuex |

---

## 🚨 Casos Especiales (¿Traducir o No?)

| Caso | Traducir | Ejemplo |
|------|----------|---------|
| Comentarios de código | ❌ NO | `// Obtener tickets` queda igual |
| Strings de UI | ❌ NO | `"Cargando..."` permanece español |
| Valores de enum | ✅ SÍ | `status: "open"` no `"abierto"` |
| Nombres de librerías | ❌ NO | Vue, Vuex, Bootstrap, QTable |
| Métodos nativos JS | ❌ NO | `.map()`, `.filter()`, `.then()` |
| Métodos nativos Vue | ❌ NO | `this.$emit()`, `this.$watch()` |
| Métodos de npm packages | ❌ NO | `axios.get()`, `store.dispatch()` |
| Nombres de propiedades custom | ✅ SÍ | `:initialTicket`, `:currentUser` |
| Nombres de métodos custom | ✅ SÍ | `getTickets()`, `submitForm()` |

---

## ✅ Listo para Usar

**Imprime este documento o mantenlo en otra ventana mientras traduces.**

Cuando encuentres una palabra en español:
1. Busca en alguna sección de arriba
2. Reemplaza por el equivalente en inglés
3. Verifica consistencia con otros archivos

**¡A traducir!** 🚀
