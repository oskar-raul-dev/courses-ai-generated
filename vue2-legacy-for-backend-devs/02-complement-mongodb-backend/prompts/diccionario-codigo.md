# 📖 Diccionario de código: español → inglés
## Cursos Mini Jira — Track A (Vue 2 Legacy) + Track B (MongoDB / Express)

Documento operativo, complementario a `GUIA-DE-ESTILO-Y-CONVENCIONES.md` §4.
Úsalo mientras escribís código nuevo o ajustás una fase ya escrita, en
cualquiera de los dos tracks.

**Regla de una línea:** el **código en inglés**; todo lo demás —comentarios,
narrativa, textos de interfaz— **en español**.

Los dos tracks comparten dominio (Mini Jira) y contrato (`AUDIT-CONTRATO.md`),
así que comparten este diccionario. Lo que un ticket es en Vue es lo mismo que
es en Express y en Mongo: `ticket`. Esa es la razón de que el diccionario sea
uno solo.

---

## 1. Qué se traduce y qué no (referencia rápida)

| Cosa | ¿Traducir a inglés? | Ejemplo |
|---|---|---|
| `function nombreDeFuncion()` | ✅ Sí | `function takeTicket()` |
| `const variable = ...` | ✅ Sí | `const isLoading = false` |
| Dato/prop/computed de componente | ✅ Sí | `this.form.assignee`, `<ticket-form :initial-ticket="…" />` |
| Módulo Vuex / mutation / action / getter | ✅ Sí | `ticketsModule`, `SET_TICKETS`, `fetchTickets`, `currentUser` |
| Endpoint / ruta de API | ✅ Sí | `apiClient.get('/tickets')`, `router.patch('/tickets/:id')` |
| Colección / campo de Mongo | ✅ Sí | `db.collection('comments')`, `{ assignee, createdAt }` |
| Nombre de componente / archivo | ✅ Sí | `TicketsTable.vue`, `tickets.service.js` |
| Nombre de servicio / capa backend | ✅ Sí | `ticketService`, `tickets.controller.js` |
| Nombre de evento de socket | ✅ Sí | `ticket:created` |
| Valor de enum / status interno | ✅ Sí | `status: 'open'`, `priority: 'high'` |
| Clase CSS/Sass propia del proyecto | ✅ Sí | `.ticket-card` |
| `data-testid` | ✅ Sí | `data-testid="ticket-row"` |
| `// comentario explicando el porqué` | ❌ No | se queda en español |
| Texto que ve el usuario (`<button>`, `alert`, `label`) | ❌ No | `"Tomar ticket"` |
| Valor de un mensaje de error legible | ❌ No | `{ message: 'No se pudo cargar el ticket' }` — la *key* en inglés, el *valor* en español |
| `label` de un mapeo estado→etiqueta | ⚠️ Parcial | `open: { label: 'Abierto' }` — la *clave* en inglés, el `label` (lo que ve el usuario) en español |
| Nombre del dominio en la narrativa/prosa | ❌ No | seguís hablando de "ticket", "comentario", "agente" |
| Nombres de fase, archivo `.md`, títulos | ❌ No | siguen en español (`fase-05-lookup-y-por-que-es-una-alarma.md`) |

---

## 2. Diccionario del dominio (Mini Jira)

### 2.1 Entidades principales

| Español | Inglés (código) |
|---|---|
| ticket / tickets | `ticket` / `tickets` |
| comentario / comentarios | `comment` / `comments` |
| usuario / usuarios | `user` / `users` |
| adjunto / adjuntos | `attachment` / `attachments` |
| agente | `agent` |
| reportador | `reporter` |
| historial (de estados) | `history` |
| métrica / indicador | `metric` / `stats` |
| tablero / dashboard | `dashboard` |

> ℹ️ **`agent` y `reporter` son los dos únicos roles.** `admin` **no** es un
> rol válido: aparece en el material solo como *username* de un usuario
> (`{ username: 'admin', role: 'agent' }`) y como valor **ilegal** que un
> ejercicio de validación (Fase 4 de Track B) usa para probar que el enum de
> roles lo rechaza. Si algún día se agrega un tercer rol, se fija acá primero.

### 2.2 Estados del ticket (máquina de estados)

| Español (UI/narrativa) | Inglés (enum) | Nota |
|---|---|---|
| abierto | `open` | valor de enum; nace así todo ticket |
| en progreso | `in_progress` | `snake_case`, no `inProgress` |
| resuelto | `resolved` | |
| cerrado | `closed` | |

Transiciones legales (idénticas en ambos tracks y en el contrato):
`open → in_progress → resolved → closed`, con reapertura (`reopen`) desde
`resolved`/`closed` de vuelta a `open`.

> ⚠️ La **etiqueta que ve el usuario** ("Abierto", "En progreso") vive
> separada del valor interno, en un mapeo. La clave es el enum en inglés; el
> valor es la etiqueta en español. Nunca guardes `'Abierto'` como `status`.

### 2.3 Prioridad del ticket

| Español (UI) | Inglés (enum) |
|---|---|
| baja | `low` |
| media | `medium` |
| alta | `high` |

### 2.4 Verbos de negocio

| Español | Inglés (código) |
|---|---|
| tomar (un ticket) | `take` |
| asignar | `assign` |
| resolver | `resolve` |
| cerrar | `close` |
| reabrir | `reopen` |
| comentar | `comment` |
| transicionar (de estado) | `transition` |
| reportar (crear un ticket) | `report` / `create` |

### 2.5 Campos frecuentes del ticket

| Español | Inglés (código) |
|---|---|
| título | `title` |
| descripción | `description` |
| estado | `status` |
| prioridad | `priority` |
| asignado (a) | `assignee` |
| reportado por | `reporter` |
| fecha de creación | `createdAt` |
| fecha de actualización | `updatedAt` |
| versión de esquema | `schemaVersion` |
| historial | `history` |

### 2.6 Etiquetas de UI (mapeos en español — referencia canónica)

Estos mapeos ya existen en Track A y son la fuente de verdad de cómo se ve el
dominio en pantalla. La **clave** viaja por la API y vive en Mongo; el **valor**
es lo que lee el usuario.

```js
// estado → etiqueta + estilo
const STATUS_META = {
  open:        { label: 'Abierto',     css: 'badge-danger' },
  in_progress: { label: 'En progreso', css: 'badge-warning' },
  resolved:    { label: 'Resuelto',    css: 'badge-success' },
  closed:      { label: 'Cerrado',     css: 'badge-secondary' }
};

// prioridad → etiqueta
const PRIORITY_LABEL = { low: 'Baja', medium: 'Media', high: 'Alta' };
```

Formas plurales usadas en filtros y tarjetas del dashboard: "Abiertos",
"En progreso", "Resueltos", "Cerrados".

---

## 3. Diccionario técnico general (común a ambos tracks)

| Español | Inglés (código) |
|---|---|
| usuario | `user` |
| sesión | `session` |
| iniciar sesión | `login` |
| cerrar sesión | `logout` |
| token | `token` |
| cargando / carga | `loading` |
| guardando | `saving` |
| formulario | `form` |
| borrador | `draft` |
| validar | `validate` |
| enviar (submit) | `submit` |
| cancelar | `cancel` |
| reintentar | `retry` |
| obtener / traer | `get` / `fetch` |
| crear | `create` |
| actualizar | `update` |
| eliminar / borrar | `delete` |
| listar | `list` |
| buscar | `search` |
| filtrar | `filter` |
| ordenar | `sort` |
| en edición | `editing` |
| lista vacía | `empty` |

### 3.1 Verbos técnicos para componer nombres

Combina un verbo con el sustantivo del dominio: `fetch` + `Tickets` →
`fetchTickets`; `take` + `Ticket` → `takeTicket`; `serialize` + `Ticket` →
`serializeTicket`. Los más usados en estos cursos:

`get`, `fetch`, `create`, `update`, `delete`, `list`, `search`, `filter`,
`sort`, `select`, `take`, `assign`, `resolve`, `close`, `reopen`,
`transition`, `serialize`, `validate`, `login`, `logout`, `emit`, `subscribe`,
`upload`, `download`, `cancel`, `retry`.

---

## 4. Convenciones de nombrado por artefacto

### 4.1 Track A (Vue 2)

| Artefacto | Convención | Ejemplo |
|---|---|---|
| Componente | `PascalCase` | `TicketsTable`, `TicketForm`, `TicketWizard`, `StatusBadge` |
| Archivo de componente | igual al componente, `.vue` | `TicketForm.vue` |
| Uso en template | `kebab-case` | `<ticket-form>`, `<status-badge>` |
| Función / variable | `camelCase` | `takeTicket`, `isTicketOpen` |
| Módulo Vuex | `<dominio>Module` / namespace corto | `ticketsModule`, `'tickets'`, `'auth'`, `'ui'`, `'comments'` |
| Mutation | `SCREAMING_SNAKE_CASE` | `SET_TICKETS`, `SET_LOADING`, `UPSERT_TICKET`, `CLEAR_SESSION` |
| Action | verbo + dominio, `camelCase` | `fetchTickets`, `createTicket`, `takeTicket`, `login` |
| Getter | sustantivo o `is/can` | `currentUser`, `openTickets`, `canTransition` |
| Acceso con namespace | `'modulo/miembro'` | `'auth/currentUser'`, `'tickets/fetchTickets'` |
| Servicio HTTP | `<dominio>Service` | `ticketService`, `authService`, `commentService`, `userService`, `socketService`, `attachmentService`, `statsService` |
| `data-testid` | kebab-case descriptivo | `data-testid="ticket-row"` |

### 4.2 Track B (MongoDB / Express)

| Artefacto | Convención | Ejemplo |
|---|---|---|
| Colección | sustantivo plural | `tickets`, `users`, `comments`, `attachments` |
| Campo de documento | `camelCase` | `title`, `assignee`, `createdAt`, `schemaVersion` |
| Ruta (router) | `<dominio>.routes.js` | `tickets.routes.js`, `auth.routes.js` |
| Controller | `<dominio>.controller.js` | `tickets.controller.js` |
| Service | `<dominio>.service.js` | `tickets.service.js` |
| Helper / librería interna | `lib/<nombre>.js` | `lib/serializers.js`, `lib/jwt.js` |
| Middleware | `middleware/<nombre>.js` | `middleware/auth.js` |
| Tiempo real | `realtime/io.js` | `realtime/io.js` |
| Endpoint REST | sustantivo plural | `/tickets`, `/tickets/:id/comments`, `/stats`, `/auth/login` |
| Evento de socket | `recurso:acción` | `ticket:created`, `ticket:updated`, `ticket:deleted` |
| Índice | autogenerado o explícito, inglés | `status_1_createdAt_-1` |
| Constante de config | `SCREAMING_SNAKE_CASE` | `MAX_UPLOAD_BYTES`, `JWT_EXPIRES_IN` |

### 4.3 El anti-patrón `soporte_v1` (Track B) — también en inglés

`soporte_v1` es el villano: una base "migrada a Mongo transcribiendo el
esquema relacional tabla por tabla". Por decisión de estilo
(`GUIA-DE-ESTILO-Y-CONVENCIONES.md` §4.6), **el villano se nombra en inglés
igual que todo lo demás.** Su fealdad es de estructura, no de idioma.

| ❌ Nombre viejo (español) | ✅ Nombre normalizado (inglés) |
|---|---|
| `usuarios` | `users` |
| `estados` (lookup-table) | `statuses` |
| `prioridades` (lookup-table) | `priorities` |
| `roles` (lookup-table) | `roles` |
| `comentarios` | `comments` |
| `ticket_historial` | `ticketHistory` (colección) |
| `estado_id` | `statusId` |
| `prioridad_id` | `priorityId` |
| `asignado_id` | `assigneeId` |
| `reportador_id` | `reporterId` |
| `autor_id` | `authorId` |
| `ticket_id` (campo Mongo) | `ticketId` |
| `titulo` / `descripcion` | `title` / `description` |
| `creado_en` | `createdAt` |

> El olor a "Postgres disfrazado" se conserva por lo que sí lo delata:
> lookup-tables de ≤10 docs con forma `{ _id: <número>, name: '…' }`, FKs
> enteras sin validar, siete colecciones para lo que el buen modelo
> (`minijira`) resuelve en una o dos. El "detector de traducido-no-diseñado"
> (ejercicio de la Fase 3) huele estructura, no idioma.
>
> ⚠️ **Excepción SQL:** en las 📖 tablas de traducción, el lado **SQL** puede
> usar nombres relacionales en español si el ejemplo lo pide (es SQL, no
> código del proyecto). Lo que se normaliza a inglés es el **MQL/JS** y los
> nombres de colección/campo de Mongo.

---

## 5. Ejemplos antes/después

### 5.1 Track A — módulo Vuex y servicio

#### ❌ Antes (español)
```javascript
// src/store/modules/tickets.js
const modulo = {
  namespaced: true,
  state: { items: [], cargando: false, error: null },
  mutations: {
    SET_TICKETS(state, tickets) { state.items = tickets; },
    SET_CARGANDO(state, v) { state.cargando = v; }
  },
  actions: {
    async traerTickets({ commit }) {
      commit('SET_CARGANDO', true);
      // trae el listado y lo guarda ya validado
      const items = await servicioTickets.listar();
      commit('SET_TICKETS', items);
      commit('SET_CARGANDO', false);
    }
  }
};
```

#### ✅ Después (inglés en código, español en comentarios y UI)
```javascript
// src/store/modules/tickets.js
const ticketsModule = {
  namespaced: true,
  state: { items: [], loading: false, error: null },
  mutations: {
    SET_TICKETS(state, tickets) { state.items = tickets; },
    SET_LOADING(state, v) { state.loading = v; }
  },
  actions: {
    async fetchTickets({ commit }) {
      commit('SET_LOADING', true);
      // trae el listado y lo guarda ya validado
      const items = await ticketService.list();
      commit('SET_TICKETS', items);
      commit('SET_LOADING', false);
    }
  }
};
```

### 5.2 Track A — componente y mapeo de estado

#### ❌ Antes
```javascript
export default {
  name: 'TablaTickets',
  computed: {
    ...mapState('tickets', { cargando: 'cargando', tickets: 'items' })
  },
  methods: {
    etiquetaEstado(estado) {
      switch (estado) {
        case 'open': return 'Abierto';
        default: return estado;
      }
    }
  }
};
```

#### ✅ Después
```javascript
export default {
  name: 'TicketsTable',
  computed: {
    ...mapState('tickets', { loading: 'loading', tickets: 'items' })
  },
  methods: {
    // devuelve la etiqueta en español que ve el usuario
    statusLabel(status) {
      switch (status) {
        case 'open': return 'Abierto';
        default: return status;
      }
    }
  }
};
```

Notá que `'Abierto'` **no cambia**: es texto de interfaz. El `case 'open'` sí
está en inglés: es el valor del enum.

### 5.3 Track B — service del backend

#### ❌ Antes (español)
```javascript
// src/services/tickets.servicio.js
async function tomarTicket(db, ticketId, agente) {
  // precondición en el filtro: si otro ya lo tomó, no matchea
  const resultado = await db.collection('tickets').findOneAndUpdate(
    { _id: ticketId, asignado: null },
    { $set: { asignado: agente, estado: 'in_progress' } },
    { returnDocument: 'after' }
  );
  return resultado.value;
}
```

#### ✅ Después
```javascript
// src/services/tickets.service.js
async function takeTicket(db, ticketId, agent) {
  // precondición en el filtro: si otro ya lo tomó, no matchea
  const result = await db.collection('tickets').findOneAndUpdate(
    { _id: ticketId, assignee: null },
    { $set: { assignee: agent, status: 'in_progress' } },
    { returnDocument: 'after' }
  );
  return result.value;
}
```

### 5.4 Track B — fixtures de test

#### ❌ Antes (español)
```javascript
const users = {
  agente:    { _id: new ObjectId(), username: 'soporte1', name: 'Agente Uno',   role: 'agent' },
  reportero: { _id: new ObjectId(), username: 'usuario1', name: 'Usuario Reportador', role: 'reporter' }
};

function ticketLibre(overrides) {
  return Object.assign({
    _id: new ObjectId(), title: 'Ticket de prueba', status: 'open',
    priority: 'medium', assignee: null, reporter: 'usuario1'
  }, overrides || {});
}
```

#### ✅ Después
```javascript
const users = {
  agent:    { _id: new ObjectId(), username: 'soporte1', name: 'Agente Uno',   role: 'agent' },
  reporter: { _id: new ObjectId(), username: 'usuario1', name: 'Usuario Reportador', role: 'reporter' }
};

// fábrica de ticket "libre" (sin asignar) para los tests
function makeTicket(overrides) {
  return Object.assign({
    _id: new ObjectId(), title: 'Ticket de prueba', status: 'open',
    priority: 'medium', assignee: null, reporter: 'usuario1'
  }, overrides || {});
}
```

Notá que el `username` (`'soporte1'`, `'usuario1'`) y el `name`
(`'Agente Uno'`) **no** se traducen: son datos de la fixture, no
identificadores. Lo que cambia son las **claves** del objeto (`agente` →
`agent`) y el nombre de la **función** (`ticketLibre` → `makeTicket`).

---

## 6. Matriz de verificación por archivo (copiar para ajustar)

### 6.1 Track A

```markdown
| Archivo | Componentes | Módulos/Store | Servicios | Endpoints | Enums | Comentarios ✅ | UI ✅ | Estado |
|---|---|---|---|---|---|---|---|---|
| TRACKA-01-estructura-base-legacy.md | — | — | — | — | — | — | — | TODO |
| TRACKA-02-autenticacion-minima.md | — | — | — | — | — | — | — | TODO |
| TRACKA-03-mock-api-minima.md | — | — | — | — | — | — | — | TODO |
| TRACKA-04-dashboard-tickets.md | — | — | — | — | — | — | — | TODO |
| TRACKA-05-crud-tickets.md | — | — | — | — | — | — | — | TODO |
| TRACKA-06-wizard-minimo.md | — | — | — | — | — | — | — | TODO |
| TRACKA-07-metricas-minimas.md | — | — | — | — | — | — | — | TODO |
| TRACKA-08-websockets-minimos.md | — | — | — | — | — | — | — | TODO |
| TRACKA-09-panel-soporte.md | — | — | — | — | — | — | — | TODO |
| TRACKA-10-vuex-a-fondo.md | — | — | — | — | — | — | — | TODO |
| TRACKA-11-testing-minimo.md | — | — | — | — | — | — | — | TODO |
```

### 6.2 Track B

```markdown
| Archivo | Colecciones | Campos | Capas (route/ctrl/svc) | Endpoints | Enums | Comentarios ✅ | UI ✅ | Estado |
|---|---|---|---|---|---|---|---|---|
| fase-00-preliminares.md | — | — | — | — | — | — | — | TODO |
| fase-01-mongo-en-30-min.md | — | — | — | — | — | — | — | TODO |
| fase-02-consultar-tu-sql-traducido.md | — | — | — | — | — | — | — | TODO |
| fase-03-embeber-vs-referenciar.md | — | — | — | — | — | — | — | TODO |
| ... | | | | | | | | |
```

Marca ✅ cuando confirmes que ese aspecto ya está en inglés (o, para
comentarios/UI, que sigue intacto en español).

---

## 7. Checklist antes de dar por ajustado un archivo

- [ ] Ningún `function`, `const`, `class`, `data()`, `methods`, mutation o action con nombre en español.
- [ ] Ningún endpoint ni ruta Express con segmento en español.
- [ ] Ninguna colección ni campo de Mongo en español (incluido el villano `soporte_v1`, ver §4.3).
- [ ] Ningún valor de `status`/`priority`/`role`/enum interno en español.
- [ ] Nombres de componente y archivo en `PascalCase` inglés; uso en template en `kebab-case`.
- [ ] Mutations en `SCREAMING_SNAKE_CASE` inglés; actions/getters en `camelCase` inglés.
- [ ] Nombres de servicio (`ticketService`) y de capa backend (`tickets.service.js`) en inglés.
- [ ] Nombres de evento de socket en inglés (`ticket:created`), y solo los del contrato salvo extensión declarada.
- [ ] Comentarios de código 100% en español, explicando el porqué.
- [ ] Textos de interfaz (botones, labels, alertas, placeholders) 100% en español.
- [ ] Etiquetas de estado/prioridad: clave en inglés, `label` en español (§2.6).
- [ ] Consistencia con otras fases ya ajustadas **y con el otro track** (mismo nombre para el mismo concepto: `takeTicket` en Vue y en Express).
- [ ] Ejercicios que mencionan identificadores actualizados al nuevo nombre.
- [ ] Nada contradice `AUDIT-CONTRATO.md` (forma de respuestas, `id`↔`_id`, enums).

---

## 8. Duda frecuente: ¿y si dudo del nombre?

Antes de inventar un identificador nuevo, buscá el concepto en §2 y §3. Si no
está, componelo con un verbo de §3.1 + un sustantivo de dominio de §2, y —si
va a vivir en más de una fase o cruza tracks— agregalo a este diccionario para
que el próximo documento lo use igual. La consistencia entre tracks es más
importante que la elección concreta: mejor un nombre imperfecto usado en los
dos lados que dos nombres "buenos" que no coinciden.
