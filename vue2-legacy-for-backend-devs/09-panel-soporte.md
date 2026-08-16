# 🎧 Fase 9 — Panel de soporte mínimo

## 🎯 Propósito

Todo lo construido hasta ahora mira al Mini Jira desde el lado del que
**reporta**. Hoy construimos el otro lado: el **panel del agente de
soporte** — la pantalla donde alguien de la mesa trabaja la cola: toma
tickets, cambia estados, comenta y ve llegar trabajo nuevo en vivo.

Esta es la **fase de síntesis** prometida en el plan: casi ningún concepto
nuevo, mucha composición. Y esa es precisamente la lección — en legacy real,
el 90% del trabajo no es aprender piezas nuevas sino **ensamblar bien las
que ya existen**. Vamos a medir qué tan bien construimos las nuestras:

- servicios de las Fases 3 y 5 → se reutilizan tal cual;
- badges y colores de las Fases 4 y 7 → se reutilizan tal cual;
- el patrón de transiciones del ejercicio 19 de la Fase 5 → **se gradúa a
  contenido oficial** como mini máquina de estados;
- los sockets de la Fase 8 → alimentan la cola en vivo;
- y aparecen tres piezas de Vue que faltaban en el arsenal: **master-detail
  sin navegar**, **`:key` para forzar recreación** y **`v-model` en
  componentes propios**.

> La regla de la fase: si para armar esta pantalla hay que MODIFICAR piezas
> de fases anteriores (no extenderlas), esas piezas estaban mal hechas.
> Este capítulo es el examen de arquitectura de todo el curso.

---

## ✅ Qué queda listo al terminar

- ruta `/support` visible y accesible **solo para agentes** (el ejercicio 19
  de la Fase 2 se gradúa: guard por roles oficial);
- layout master-detail: **cola** a la izquierda (sin asignar + míos),
  **workspace** a la derecha con el ticket seleccionado;
- botón "Tomar" que asigna el ticket al agente logueado;
- cambio de estado mediante una **máquina de estados declarativa** (solo
  transiciones válidas, botones generados desde el mapa);
- comentarios: listar y agregar (el `commentService` de los ejercicios de la
  Fase 3 se gradúa a oficial);
- tickets nuevos entran a la cola **en vivo** vía socket, con resaltado;
- un componente con `v-model` propio (`CommentBox`).

## 🚫 Qué NO entra todavía

- SLA, prioridades de cola automáticas, escalamiento;
- asignación a terceros con selector (solo "tomar para mí"; el selector es
  ejercicio 🟡);
- edición del ticket desde el panel (para eso está la Fase 5; enlazamos);
- colaboración fina en vivo (typing, presencia — quedaron como ejercicios de
  la Fase 8 y aquí se pueden enchufar);
- permisos granulares (quién puede cerrar, reabrir — ejercicio 🟠).

---

## 🧠 Concepto 1: master-detail en UNA vista

Hasta ahora, "ver el detalle" significaba **navegar**: el dashboard te manda
a `/tickets/:id` y la lista muere (con sus filtros — lo sufrimos en la
Fase 4). Para trabajar una cola eso es inaceptable: el agente salta entre
tickets decenas de veces por hora y la cola debe seguir ahí, viva y con su
scroll.

La alternativa: **selección local** en vez de navegación.

| | 🧭 Navegación (dashboard) | 📌 Selección local (panel) |
|---|---|---|
| Estado al cambiar de ticket | la lista se destruye y renace | la cola permanece intacta |
| URL | refleja el ticket (compartible, F5 del navegador) | refleja la pantalla, no la selección* |
| Costo de cambiar | remontar vista + re-fetch de lista | re-fetch solo del detalle |
| Ideal para | consulta puntual, deep-linking | trabajo repetitivo sobre una lista |

\* salvo que sincronices la selección a un query param — ejercicio 13, el
mismo truco de la Fase 4 en su tercer uso.

El precio del master-detail es una pregunta nueva: cuando cambio de ticket
seleccionado, ¿cómo **reseteo** el estado del panel de detalle (comentarios
cargados, textarea a medias, errores)? La respuesta idiomática de Vue está en
el mini repaso: `:key`.

## 🧠 Concepto 2: transiciones como datos (máquina de estados de bolsillo)

El ciclo de vida de un ticket no es "cualquier estado a cualquier estado":

```
open ──→ in_progress ──→ resolved ──→ closed
 ↑            │              │           │
 └────────────┴──────────────┴───────────┘  (reabrir)
```

La versión ingenua son `if`s regados: *si está open muestra tal botón, si
está resolved muestra tal otro…* — y a la tercera regla nueva nadie sabe ya
qué transiciones existen. La versión adulta es **el mapa**:

```js
var TRANSITIONS = {
  open:        ["in_progress"],
  in_progress: ["resolved", "open"],
  resolved:    ["closed", "open"],
  closed:      ["open"]
};
```

Un objeto responde tres preguntas de golpe: qué transiciones existen (léelo),
cuáles son válidas desde X (`TRANSITIONS[x]`), y dónde se cambia una regla
(aquí y solo aquí). Los botones de la UI se **generan** del mapa —
configuración sobre condicionales, el mismo principio de `stepDefs` en la
Fase 6, tercera aparición. A la tercera vez, ya no es un truco: es tu
estilo. 😎

---

## 🧩 Mini repaso: los `.vue` de esta fase (lo nuevo respecto a la Fase 8)

### `:key` para forzar recreación (el as bajo la manga)

Ya sabemos que `:key` da identidad en `v-for` (Fase 4). Su segundo uso, menos
conocido y oro puro en master-detail: puesto sobre **cualquier componente**,
cambiar la key le dice a Vue *"este ya no es el mismo: destrúyelo y crea uno
nuevo"*.

```vue
<ticket-workspace :ticket="selectedTicket" :key="selectedTicket.id" />
```

Al seleccionar otro ticket, cambia la key → Vue ejecuta `beforeDestroy` del
workspace viejo y `created`+`mounted` del nuevo. Consecuencias en cascada,
todas deseables:

- el `mounted` que carga comentarios **corre de nuevo** para el ticket nuevo
  (sin watch sobre la prop, sin método `reload()` manual);
- el textarea a medias, los errores, el estado de "guardando" — todo muere
  con la instancia vieja: **reset gratis y completo**;
- las limpiezas de `beforeDestroy` (listeners, timers) corren solas.

La alternativa — mantener la instancia y reaccionar con
`watch: { ticket: ... }` reseteando campo por campo a mano — es más
"eficiente" y es también donde nacen los bugs de "quedó el comentario del
ticket anterior en el textarea". Regla práctica: **si al cambiar la entidad
quieres borrón y cuenta nueva, cambia la key; si quieres transición suave
conservando algo, usa watch.** El 80% de las veces quieres la key.

### `v-model` en componentes propios

En la Fase 5 desazucaramos `v-model` sobre un `<input>`. Sobre un
**componente**, el azúcar es un contrato que tú implementas:

```vue
<comment-box v-model="newComment" />
<!-- azúcar de: -->
<comment-box :value="newComment" @input="newComment = $event" />
```

O sea: el componente debe (1) recibir una prop llamada `value` y (2) emitir
un evento llamado `input` con el valor nuevo. Nada más:

```js
export default {
  props: { value: { type: String, default: "" } },
  methods: {
    onInput: function (e) {
      this.$emit("input", e.target.value); // el padre actualiza; la prop vuelve
    }
  }
};
```

Nota fina: el componente **no guarda copia local** del valor — pinta la prop
y emite cambios; el dato vive en el padre. Es "props abajo, eventos arriba"
con nombres estandarizados, y por eso compone con todo lo que espera
v-model. ⚰️ Dato de época: en Vue 2 el par es fijo (`value`/`input`, o
personalizable con la opción `model`); en Vue 3 cambió a
`modelValue`/`update:modelValue` — otra mina al migrar.

### `Promise.all` — cargar en paralelo

El panel necesita tickets **y** usuarios (para pintar nombres de agentes).
En serie sería lento y en cascada de `.then` ilegible; en paralelo:

```js
Promise.all([ticketService.getTickets(params), userService.getUsers()])
  .then(function (results) {
    self.tickets = results[0]; // el orden de results = orden del arreglo
    self.users = results[1];
  })
  .catch(function () { /* si CUALQUIERA falla, cae aquí */ });
```

Semántica a memorizar: resuelve cuando **todas** resuelven (con los
resultados en orden), rechaza en cuanto **una** rechaza. Para "quiero lo que
se pueda aunque algo falle" existe `Promise.allSettled` — pero es de 2019+ y
en el Node/navegadores de nuestro stack hay que verificar soporte: en legacy
lo verás emulado a mano (ejercicio 22).

---

## 💻 Código de la fase

### Estructura que se agrega

```
src/
  components/
    support/
      SupportQueue.vue        ← la cola (master)
      TicketWorkspace.vue     ← el detalle activo (detail)
      StatusActions.vue       ← botones desde la máquina de estados
      CommentList.vue
      CommentBox.vue          ← v-model propio
  services/
    commentService.js         ← se gradúa de ejercicio a oficial
    userService.js            ← ídem (ej. 9 de la Fase 5)
  utils/
    ticketTransitions.js      ← la máquina de estados
  views/
    SupportView.vue
```

### Ajuste previo: el usuario mock gana rol

Para que el guard por roles tenga qué mirar, `authService.js` (Fase 2/3)
agrega `role` a la sesión:

```js
// services/authService.js — el user del login ahora incluye role
user: { username: MOCK_USER.username, name: MOCK_USER.name, role: "agent" }
```

(Si hiciste el ejercicio 18 de la Fase 3 — login contra json-server — el
`role` ya viene de `db.json` gratis. 🎉)

### `utils/ticketTransitions.js`

```js
// La máquina de estados del ticket. UNA fuente de verdad para
// qué movimientos existen y cómo se llaman de cara al usuario.
export var TRANSITIONS = {
  open:        ["in_progress"],
  in_progress: ["resolved", "open"],
  resolved:    ["closed", "open"],
  closed:      ["open"]
};

export var TRANSITION_LABELS = {
  in_progress: { label: "▶️ Empezar a trabajar", css: "btn-warning" },
  resolved:    { label: "✅ Marcar resuelto",    css: "btn-success" },
  closed:      { label: "🔒 Cerrar",             css: "btn-secondary" },
  open:        { label: "↩️ Reabrir",            css: "btn-outline-danger" }
};

export function nextStatuses(status) {
  return TRANSITIONS[status] || [];
}
```

**🔎 Qué hace:** dos mapas y una función. `TRANSITIONS` define el grafo;
`TRANSITION_LABELS` define cómo se ve cada movimiento (label + estilo);
`nextStatuses` es la consulta con fallback a `[]` para estados desconocidos
(un ticket con estado corrupto muestra cero botones en vez de reventar).

**✅ Buenas prácticas aplicadas:**
- Grafo y presentación en **mapas separados**: el label de "Reabrir" es el
  mismo venga de donde venga la transición — un solo mapa mezclado habría
  duplicado labels por cada origen.
- Es un módulo de `utils/` sin `this` ni Vue: la Fase 11 lo testeará con
  asserts de tres líneas, y si json-server quisiera validar transiciones
  server-side (ejercicio 24), importa **el mismo archivo** — el truco de las
  funciones puras compartidas de la Fase 7, reutilizado.

### `services/commentService.js` (graduación oficial)

```js
import apiClient from "./apiClient";

function getByTicket(ticketId) {
  return apiClient
    .get("/comments", { params: { ticketId: ticketId, _sort: "createdAt", _order: "asc" } })
    .then(function (res) { return res.data; });
}

function create(comment) {
  return apiClient.post("/comments", comment).then(function (res) {
    return res.data;
  });
}

export default { getByTicket: getByTicket, create: create };
```

(Mismo molde que `ticketService` de la Fase 3: devuelve `res.data`, esconde
axios, ordena en el servidor. Cero sorpresas — y esa monotonía es una
virtud: el tercer servicio del proyecto se lee en diez segundos porque es
idéntico en forma a los otros dos.)

### `components/support/SupportQueue.vue` — el master

```vue
<template>
  <div>
    <h6 class="text-muted px-2">
      Sin asignar <span class="badge badge-danger">{{ unassigned.length }}</span>
    </h6>
    <div class="list-group mb-3">
      <button
        v-for="t in unassigned"
        :key="t.id"
        class="list-group-item list-group-item-action py-2"
        :class="{ active: t.id === selectedId, 'list-group-item-warning': t.isNew }"
        @click="$emit('select', t)"
      >
        <div class="d-flex justify-content-between align-items-center">
          <span class="text-truncate mr-2">#{{ t.id }} {{ t.title }}</span>
          <ticket-priority-badge :priority="t.priority" />
        </div>
      </button>
    </div>

    <h6 class="text-muted px-2">
      Míos <span class="badge badge-primary">{{ mine.length }}</span>
    </h6>
    <div class="list-group">
      <button
        v-for="t in mine"
        :key="t.id"
        class="list-group-item list-group-item-action py-2"
        :class="{ active: t.id === selectedId }"
        @click="$emit('select', t)"
      >
        <div class="d-flex justify-content-between align-items-center">
          <span class="text-truncate mr-2">#{{ t.id }} {{ t.title }}</span>
          <ticket-status-badge :status="t.status" />
        </div>
      </button>
    </div>
  </div>
</template>

<script>
import TicketPriorityBadge from "../tickets/TicketPriorityBadge.vue";
import TicketStatusBadge from "../tickets/TicketStatusBadge.vue";

export default {
  name: "SupportQueue",
  components: { TicketPriorityBadge, TicketStatusBadge },
  props: {
    tickets: { type: Array, required: true },
    selectedId: { type: Number, default: null },
    currentUsername: { type: String, required: true }
  },
  computed: {
    unassigned: function () {
      return this.tickets.filter(function (t) {
        return !t.assignee && t.status !== "closed";
      });
    },
    mine: function () {
      var self = this;
      return this.tickets.filter(function (t) {
        return t.assignee === self.currentUsername && t.status !== "closed";
      });
    }
  }
};
</script>
```

**🔎 Qué hace:** divide los tickets recibidos en dos secciones derivadas
(sin asignar / míos) con computed, pinta cada fila con los badges de las
fases anteriores, resalta la selección actual (clase `active` de Bootstrap
sobre `list-group-item`) y el trabajo nuevo (`isNew` en amarillo, lo pone el
socket 👇). Al hacer clic, **emite** `select` con el ticket — no decide qué
significa seleccionar.

**✅ Buenas prácticas aplicadas:**
- Recibe `selectedId` por prop en vez de guardar su propia selección: si la
  cola tuviera su copia, cola y workspace podrían discrepar sobre qué está
  seleccionado. **El dueño de la selección es el padre**; la cola solo la
  pinta — mismo principio anti-duplicación de estado de la Fase 4.
- `unassigned` y `mine` son derivaciones del mismo arreglo, no dos arreglos
  en `data`: cuando el socket haga `unshift` en el padre, ambas secciones se
  reparten el ticket solas.
- Las filas son `<button>` y no `<div @click>`: accesible con teclado gratis
  y estilos de foco incluidos. Detalle pequeño que en sistemas internos
  (donde la gente vive con Tab y Enter) se agradece a diario.
- Badges de las Fases 4 reutilizados sin tocar — el examen de arquitectura
  se va aprobando. ✅

### `components/support/StatusActions.vue`

```vue
<template>
  <div>
    <button
      v-for="status in available"
      :key="status"
      class="btn btn-sm mr-2"
      :class="labelFor(status).css"
      :disabled="busy"
      @click="$emit('change', status)"
    >
      {{ labelFor(status).label }}
    </button>
    <span v-if="available.length === 0" class="text-muted small">
      Sin movimientos disponibles.
    </span>
  </div>
</template>

<script>
import { nextStatuses, TRANSITION_LABELS } from "../../utils/ticketTransitions";

export default {
  name: "StatusActions",
  props: {
    status: { type: String, required: true },
    busy: { type: Boolean, default: false }
  },
  computed: {
    available: function () {
      return nextStatuses(this.status);
    }
  },
  methods: {
    labelFor: function (status) {
      return TRANSITION_LABELS[status] || { label: status, css: "btn-light" };
    }
  }
};
</script>
```

**🔎 Qué hace:** consulta la máquina de estados con el estado actual y
**genera** un botón por transición válida — el `v-for` itera reglas de
negocio, no HTML escrito a mano. Emite `change` con el estado destino; quién
hace el PATCH es problema del padre.

**✅ Buenas prácticas aplicadas:**
- Este componente es la recompensa del mapa: agregar mañana la transición
  `in_progress → waiting_customer` es tocar `ticketTransitions.js` y **este
  archivo ni se abre**. Cuando la UI se genera de la configuración, la
  configuración es el único punto de cambio.
- `labelFor` con fallback: una transición sin label definido sale fea pero
  sale — los mapas de presentación siempre con red de seguridad (mismo
  criterio que los badges de la Fase 4).
- La prop `busy` deshabilita durante el PATCH: la lección del doble submit de
  la Fase 5, aplicada a botones de acción. Toda acción con request tiene su
  estado de "en vuelo".

### `components/support/CommentBox.vue` — el v-model propio

```vue
<template>
  <form @submit.prevent="submit">
    <div class="form-group mb-2">
      <textarea
        :value="value"
        rows="2"
        class="form-control"
        placeholder="Escribe un comentario..."
        @input="$emit('input', $event.target.value)"
      ></textarea>
    </div>
    <button class="btn btn-sm btn-primary" :disabled="!value.trim() || sending">
      {{ sending ? "Enviando..." : "💬 Comentar" }}
    </button>
  </form>
</template>

<script>
export default {
  name: "CommentBox",
  props: {
    value: { type: String, default: "" },   // ← mitad 1 del contrato v-model
    sending: { type: Boolean, default: false }
  },
  methods: {
    submit: function () {
      if (this.value.trim()) this.$emit("submit");
    }
  }
};
</script>
```

**🔎 Qué hace:** implementa el contrato v-model de Vue 2 — pinta la prop
`value` en el textarea (`:value`, binding de una vía) y en cada tecla emite
`input` con el texto nuevo (mitad 2 del contrato). El padre lo usa como
`<comment-box v-model="newComment" ...>` y el texto vive en el padre. El
submit es un evento aparte, sin payload: el padre ya tiene el texto (está en
SU data).

**✅ Buenas prácticas aplicadas:**
- **Sin copia local**: a diferencia del `TicketForm` (F5) o los pasos del
  wizard (F6) — que editan borradores y entregan al final — un input
  controlado por v-model debe reflejar al dueño en cada tecla. Dos patrones
  distintos para dos necesidades: copia local para "editar y entregar",
  v-model para "espejo en vivo". Saber cuál toca es criterio, no dogma.
- El botón se deshabilita con `!value.trim()`: validación de un solo campo
  sin invocar a vuelidate — proporcionalidad (un textarea no amerita `$v`).
- `sending` por prop, como `saving` en la Fase 5: el hijo muestra el estado
  del request, el padre lo controla. Tercera vez del patrón: ya es tuyo.

### `components/support/CommentList.vue`

```vue
<template>
  <div>
    <div v-if="comments.length === 0" class="text-muted small py-2">
      Sin comentarios todavía. Sé el primero. 🎤
    </div>
    <div v-for="c in comments" :key="c.id" class="border-bottom py-2">
      <div class="d-flex justify-content-between">
        <strong class="small">{{ c.author }}</strong>
        <span class="text-muted small">{{ c.createdAt | formatDate }}</span>
      </div>
      <div class="small" style="white-space: pre-line;">{{ c.body }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: "CommentList",
  props: {
    comments: { type: Array, required: true }
  }
};
</script>
```

(Presentacional puro con estado vacío amable, el filtro `formatDate` de la
Fase 4 y el `pre-line` de la Fase 6. Tres fases en quince líneas — así se ve
la síntesis.)

### `components/support/TicketWorkspace.vue` — el detail

```vue
<template>
  <div class="card">
    <div class="card-body">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <h5 class="mb-1">#{{ ticket.id }} — {{ ticket.title }}</h5>
          <ticket-status-badge :status="ticket.status" class="mr-1" />
          <ticket-priority-badge :priority="ticket.priority" />
        </div>
        <router-link
          :to="'/tickets/' + ticket.id + '/edit'"
          class="btn btn-sm btn-outline-secondary"
        >
          ✏️ Editar
        </router-link>
      </div>

      <p class="mt-3" style="white-space: pre-line;">{{ ticket.description }}</p>

      <p class="small text-muted mb-1">
        Reportado por <strong>{{ ticket.reporter }}</strong> ·
        {{ ticket.createdAt | formatDate }} ·
        Asignado a <strong>{{ ticket.assignee || "nadie" }}</strong>
      </p>

      <div v-if="error" class="alert alert-danger py-2 my-2">{{ error }}</div>

      <div class="my-3">
        <button
          v-if="!ticket.assignee"
          class="btn btn-sm btn-primary mr-2"
          :disabled="busy"
          @click="takeTicket"
        >
          🙋 Tomar
        </button>
        <status-actions :status="ticket.status" :busy="busy" @change="changeStatus" />
      </div>

      <hr />

      <h6 class="text-muted">Comentarios</h6>
      <div v-if="loadingComments" class="spinner-border spinner-border-sm text-primary"></div>
      <comment-list v-else :comments="comments" />

      <div class="mt-3">
        <comment-box v-model="newComment" :sending="sendingComment" @submit="addComment" />
      </div>
    </div>
  </div>
</template>

<script>
import TicketStatusBadge from "../tickets/TicketStatusBadge.vue";
import TicketPriorityBadge from "../tickets/TicketPriorityBadge.vue";
import StatusActions from "./StatusActions.vue";
import CommentList from "./CommentList.vue";
import CommentBox from "./CommentBox.vue";
import ticketService from "../../services/ticketService";
import commentService from "../../services/commentService";

export default {
  name: "TicketWorkspace",
  components: { TicketStatusBadge, TicketPriorityBadge, StatusActions, CommentList, CommentBox },
  props: {
    ticket: { type: Object, required: true }
  },
  data: function () {
    return {
      comments: [],
      newComment: "",
      loadingComments: false,
      sendingComment: false,
      busy: false,
      error: ""
    };
  },
  mounted: function () {
    // Corre por CADA ticket seleccionado: el :key del padre nos recrea. 🔑
    this.loadComments();
  },
  methods: {
    loadComments: function () {
      var self = this;
      this.loadingComments = true;

      commentService
        .getByTicket(this.ticket.id)
        .then(function (comments) { self.comments = comments; })
        .catch(function () { self.error = "No se pudieron cargar los comentarios."; })
        .finally(function () { self.loadingComments = false; });
    },
    takeTicket: function () {
      var me = this.$store.getters["auth/currentUser"].username;
      this.patchTicket({ assignee: me, status: "in_progress" });
    },
    changeStatus: function (newStatus) {
      this.patchTicket({ status: newStatus });
    },
    patchTicket: function (changes) {
      var self = this;
      this.busy = true;
      this.error = "";

      ticketService
        .updateTicket(this.ticket.id, changes)
        .then(function (updated) {
          self.$emit("updated", updated); // el padre actualiza la lista maestra
        })
        .catch(function () {
          self.error = "No se pudo actualizar el ticket.";
        })
        .finally(function () {
          self.busy = false;
        });
    },
    addComment: function () {
      var self = this;
      var user = this.$store.getters["auth/currentUser"];
      this.sendingComment = true;

      commentService
        .create({
          ticketId: this.ticket.id,
          author: user.username,
          body: this.newComment.trim(),
          createdAt: new Date().toISOString()
        })
        .then(function (created) {
          self.comments.push(created); // push: método parcheado, reactivo (F8)
          self.newComment = "";        // v-model: limpia el textarea del hijo
        })
        .catch(function () {
          self.error = "No se pudo enviar el comentario.";
        })
        .finally(function () {
          self.sendingComment = false;
        });
    }
  }
};
</script>
```

**🔎 Qué hace, pieza por pieza:**

| Pieza | Su trabajo |
|---|---|
| prop `ticket` | el ticket a trabajar — **el padre decide cuál**, este componente nunca busca |
| `mounted` → `loadComments` | carga los comentarios de SU ticket; se re-ejecuta con cada selección gracias al `:key` del padre |
| `takeTicket` / `changeStatus` | ambos convergen en `patchTicket`: un solo camino para toda mutación del ticket |
| `$emit("updated", updated)` | el resultado del PATCH sube al padre — este componente NO muta la prop ni la lista maestra |
| `addComment` | el ciclo completo de la Fase 5 en miniatura: payload con reglas de negocio (author, fecha) + push reactivo + limpiar v-model |

**✅ Buenas prácticas aplicadas:**
- **La prop es sagrada, versión avanzada:** el PATCH devuelve el ticket
  actualizado y el componente lo *emite* en vez de hacer
  `this.ticket.status = ...`. El padre — dueño de la lista — decide cómo
  incorporarlo. Si el workspace mutara la prop, la fila de la cola y el
  detalle podrían divergir en silencio: la fuente de verdad es una y vive
  arriba.
- `patchTicket` como **embudo único**: "tomar" y "cambiar estado" son el
  mismo verbo HTTP con distinto payload. Un solo lugar para busy/error/emit
  significa que el ejercicio 18 (permisos) o el 20 (socket en updates) tocan
  UNA función.
- `takeTicket` asigna **y** pasa a `in_progress` en un solo PATCH: regla de
  negocio ("tomar es empezar") explícita en el código y en un solo request —
  dos PATCH seguidos serían una carrera esperando perderse.
- El comentario nuevo se `push`ea con la respuesta del **servidor** (que trae
  el `id` real), no con el payload local: mismo criterio que la redirección
  post-POST de la Fase 5. Lo que muestra la UI es lo que quedó persistido.

### `views/SupportView.vue` — el orquestador

```vue
<template>
  <section>
    <page-title title="Panel de soporte" subtitle="Cola de trabajo del agente" />

    <div v-if="loading" class="text-center my-5">
      <div class="spinner-border text-primary" role="status"></div>
    </div>

    <div v-else-if="error" class="alert alert-danger">
      {{ error }}
      <button class="btn btn-sm btn-outline-danger ml-2" @click="loadData">Reintentar</button>
    </div>

    <div v-else class="row">
      <div class="col-md-4 col-lg-3">
        <support-queue
          :tickets="tickets"
          :selected-id="selectedId"
          :current-username="me.username"
          @select="selectTicket"
        />
      </div>

      <div class="col-md-8 col-lg-9">
        <ticket-workspace
          v-if="selectedTicket"
          :key="selectedTicket.id"
          :ticket="selectedTicket"
          @updated="onTicketUpdated"
        />
        <div v-else class="text-center text-muted py-5">
          <p class="h4">👈 Selecciona un ticket de la cola</p>
          <p class="small">Los tickets nuevos aparecen resaltados en amarillo.</p>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";
import SupportQueue from "../components/support/SupportQueue.vue";
import TicketWorkspace from "../components/support/TicketWorkspace.vue";
import ticketService from "../services/ticketService";
import userService from "../services/userService";
import socketService from "../services/socketService";

export default {
  name: "SupportView",
  components: { PageTitle, SupportQueue, TicketWorkspace },
  data: function () {
    return {
      tickets: [],
      users: [],
      selectedId: null,
      loading: true,
      error: ""
    };
  },
  computed: {
    me: function () {
      return this.$store.getters["auth/currentUser"];
    },
    selectedTicket: function () {
      var self = this;
      return this.tickets.find(function (t) {
        return t.id === self.selectedId;
      }) || null;
    }
  },
  mounted: function () {
    this.loadData();
    this.onCreatedHandler = this.onTicketCreated.bind(this);
    socketService.on("ticket:created", this.onCreatedHandler);
  },
  beforeDestroy: function () {
    socketService.off("ticket:created", this.onCreatedHandler);
  },
  methods: {
    loadData: function () {
      var self = this;
      this.loading = true;
      this.error = "";

      Promise.all([
        ticketService.getTickets({ _sort: "createdAt", _order: "desc" }),
        userService.getUsers()
      ])
        .then(function (results) {
          self.tickets = results[0];
          self.users = results[1];
        })
        .catch(function () {
          self.error = "No se pudo cargar el panel. ¿Está corriendo la Mock API?";
        })
        .finally(function () {
          self.loading = false;
        });
    },
    selectTicket: function (ticket) {
      this.selectedId = ticket.id;
      ticket.isNew = false; // deja de brillar al abrirlo
    },
    onTicketUpdated: function (updated) {
      var index = this.tickets.findIndex(function (t) {
        return t.id === updated.id;
      });
      if (index !== -1) {
        this.tickets.splice(index, 1, updated); // splice: reactivo (F8) ✅
      }
    },
    onTicketCreated: function (ticket) {
      ticket.isNew = true; // ⚠️ ver nota abajo
      this.tickets.unshift(ticket);
    }
  }
};
</script>
```

**🔎 Qué hace, pieza por pieza:**

| Pieza | Su trabajo |
|---|---|
| `selectedId` (data) + `selectedTicket` (computed) | guarda solo el **id**; el objeto se deriva. Si el ticket se actualiza en la lista, la derivación entrega la versión fresca sola |
| `:key="selectedTicket.id"` en el workspace | el as bajo la manga: cambiar de ticket = workspace nuevo, `mounted` nuevo, estado limpio |
| `onTicketUpdated` + `splice(i, 1, updated)` | incorpora el resultado del PATCH a la lista maestra de forma **reactiva** (la asignación por índice no lo sería — Fase 8) |
| socket on/off con handler guardado | el protocolo anti-zombis de la Fase 8, al pie de la letra |
| `Promise.all` | tickets y usuarios en paralelo; un solo loading para ambos |

**✅ Buenas prácticas (y una trampa señalizada):**
- **Guardar el id, derivar el objeto** es la versión master-detail de "crudo
  en data, derivado en computed": cuando `onTicketUpdated` reemplaza el
  ticket en la lista, `selectedTicket` apunta a la versión nueva sin código
  extra — y el `:key` no cambia (mismo id), así que el workspace NO se
  recrea por una edición propia. Dos mecanismos coordinándose gratis.
- El estado vacío del panel derecho instruye ("selecciona de la cola") en vez
  de quedar en blanco: en pantallas de trabajo, el vacío inicial es la
  primera impresión del usuario nuevo.
- ⚠️ **La trampa señalizada:** `ticket.isNew = true` agrega una propiedad
  nueva a un objeto que *aún no está* en `data` — funciona porque se asigna
  ANTES del `unshift` (Vue lo observará completo al entrar). Pero
  `ticket.isNew = false` en `selectTicket` muta una propiedad que… ¿Vue
  observó? Sí, porque ya entró con ella. Si el orden se invirtiera
  (unshift primero, isNew después), el resaltado no se apagaría: es
  **exactamente** el caveat de la Fase 4, en su forma más traicionera. La
  solución robusta es `this.$set(ticket, "isNew", false)` — el ejercicio 7
  te hace romperlo y arreglarlo.

### Router y guard por roles (graduación del ejercicio 19, Fase 2)

```js
// router/index.js
import SupportView from "../views/SupportView.vue";
// ...
{
  path: "/support",
  name: "support",
  component: SupportView,
  meta: { requiresAuth: true, roles: ["agent"] }
}
```

```js
// extensión del guard existente (después del chequeo de token):
var requiredRoles = to.matched.reduce(function (acc, record) {
  return record.meta.roles ? acc.concat(record.meta.roles) : acc;
}, []);

if (requiredRoles.length > 0) {
  var user = JSON.parse(localStorage.getItem("user") || "null");
  var role = user && user.role;
  if (requiredRoles.indexOf(role) === -1) {
    next("/"); // sin drama: a Home (ForbiddenView con mensaje = ejercicio 5)
    return;
  }
}
```

Y el enlace en el sidebar, **solo para agentes**:

```vue
<li v-if="isAgent" class="nav-item">
  <router-link class="nav-link" to="/support">🎧 Soporte</router-link>
</li>
```

```js
// AppSidebar.vue
computed: {
  isAgent: function () {
    var user = this.$store.getters["auth/currentUser"];
    return !!(user && user.role === "agent");
  }
}
```

**✅ Buena práctica (con su asterisco honesto):** ocultar el link **y**
proteger la ruta son dos capas del mismo control — el link escondido es UX
(no ofrezcas lo que no puedes usar), el guard es el control real dentro del
frontend. Y el asterisco de siempre: ambos son teatro frente a un usuario
que edita su localStorage — la autorización de verdad vive en el backend
(SECURITY-NOTES.md ya lo sabe desde la Fase 2).

---

## 🔄 Los flujos del panel, paso a paso

### 📌 Seleccionar un ticket (el flujo estrella del `:key`)

```
1. clic en una fila de la cola → SupportQueue emite select con el ticket
2. selectTicket: selectedId = ticket.id (+ apagar isNew)
3. cadena reactiva: selectedTicket (computed) encuentra el ticket
4. el template evalúa <ticket-workspace :key="selectedTicket.id">
   └─ ¿cambió la key respecto al render anterior?
      ├─ SÍ (otro ticket) → Vue DESTRUYE el workspace viejo:
      │   ├─ beforeDestroy corre (nada que limpiar hoy; mañana quién sabe)
      │   ├─ muere el textarea a medias, los errores, los comments viejos
      │   └─ y MONTA uno nuevo → mounted → loadComments del ticket nuevo
      └─ NO (mismo id, p.ej. tras un PATCH propio) → misma instancia,
          la prop actualizada fluye, nada se recarga
5. la cola pinta la fila activa (selectedId bajó por prop)
```

El paso 4 es la elegancia de la fase: **un atributo** reemplaza lo que en
legacy suele ser un watch sobre la prop + un método `reset()` de veinte
líneas que siempre olvida limpiar algo.

### 🙋 Tomar un ticket

```
1. clic en "Tomar" → takeTicket lee mi username del store
2. patchTicket({assignee: yo, status: "in_progress"}) → busy=true → PATCH
3. json-server responde el ticket completo actualizado
4. $emit("updated", updated) → el flujo SUBE al padre
5. onTicketUpdated: findIndex + splice(i, 1, updated)
   └─ cadena reactiva desde la lista maestra:
      ├─ la cola re-deriva: el ticket SALE de "Sin asignar", ENTRA a "Míos"
      │   (cambió de sección ante tus ojos, sin que la cola tenga idea de por qué)
      └─ selectedTicket entrega la versión nueva → el workspace repinta
          estado y "Asignado a" — misma key, misma instancia, sin recarga
6. finally → busy=false
```

Nota el viaje completo del dato: hijo → evento → padre → lista maestra →
computed → de vuelta a los DOS hijos. Un solo camino de escritura (arriba) y
N caminos de lectura (abajo): el patrón que hace que master y detail jamás
discrepen.

### 💬 Comentar

```
1. teclear → CommentBox emite input por tecla → newComment (en el workspace)
   se actualiza → la prop value baja → el textarea refleja (círculo v-model)
2. submit → addComment arma el payload (author + fecha: reglas del negocio,
   no del CommentBox) → POST
3. .then(created) → comments.push(created) — con el id REAL del servidor
4. newComment = "" → baja por la prop value → textarea limpio
   (limpiar el input del hijo = asignar en el padre: la gracia del v-model)
```

### 🔔 Llega un ticket nuevo en vivo

```
1. otro usuario crea → socket (Fase 8) → onTicketCreated en ESTA vista
2. isNew=true ANTES del unshift (orden crítico — la trampa señalizada)
3. unshift → la cola re-deriva → fila amarilla arriba de "Sin asignar"
4. (además, el LiveToast global de la Fase 8 suena por su cuenta:
    dos suscriptores, cero coordinación — el diseño de la F8 pagando)
5. el agente lo abre → selectTicket apaga isNew → la fila deja de brillar
```

---

## ⚠️ Errores comunes

- que el workspace **mute la prop** `ticket` tras el PATCH en vez de emitir:
  funciona hoy, divergen cola y detalle mañana (Vue además lo gritará en
  consola en cuanto el padre repinte);
- guardar el **objeto** ticket seleccionado en `data` en vez del id: al
  actualizarse la lista, tu copia queda vieja — el clásico "cambié el estado
  y el detalle no se enteró";
- olvidar el `:key` en el workspace: los comentarios del ticket anterior
  visibles medio segundo, textarea con texto ajeno — la firma inconfundible
  de instancia reutilizada sin reset;
- asignar por índice (`tickets[i] = updated`) en `onTicketUpdated`: silencio
  reactivo total (Fase 8 lo advirtió; aquí es donde de verdad muerde);
- dos PATCH encadenados para "tomar" (uno de assignee, otro de status):
  carrera innecesaria — si el negocio dice que van juntos, viajan juntos;
- construir el guard de roles pero olvidar esconder el link (o al revés):
  las dos capas o la UX cojea;
- meter la cola, la selección y los comentarios en Vuex "porque es la vista
  grande": nada de esto se comparte fuera de `/support` — resiste, que la
  Fase 10 es el lugar de esa decisión con criterio.

---

## 🧪 Ejercicios (26)

**🟢 Fácil (1–8)**

1. Agrega a la cola un contador total en el título de la página:
   "Panel de soporte (7 pendientes)".
2. Muestra en cada fila de "Míos" cuántos días lleva abierto el ticket
   (reusa el cálculo del ejercicio 22 de la Fase 4 si lo hiciste).
3. Ordena "Sin asignar" con los `high` primero (computed con `lodash.orderBy`).
4. Agrega un botón "↻" junto al título de la cola que recargue `loadData`.
5. Gradúa el `next("/")` del guard: crea `ForbiddenView.vue` (403 con mensaje
   amable) y redirige ahí.
6. Cuando la cola quede vacía, celebra: "🎉 ¡Cola limpia!" con un estado
   vacío propio en cada sección.
7. Rompe y arregla la trampa señalizada: invierte el orden
   (`unshift` primero, `isNew` después), observa que el resaltado no se apaga
   al seleccionar, y arréglalo con `this.$set`. Documenta el porqué en un
   comentario de tres líneas.
8. Haz que Editar (el `router-link` del workspace) abra en el flujo normal y
   que al volver de editar… los cambios no estén 😱. Documenta por qué
   (pista: nadie recargó) — lo arreglas en el ejercicio 16.

**🟡 Intermedio (9–17)**

9. Selector "Asignar a…": un `<select>` con los agentes (de `users`) que
   permita asignar a otro, no solo tomar. El PATCH sigue pasando por el
   embudo `patchTicket`.
10. Filtro de la cola: input de búsqueda arriba que filtre ambas secciones
    por título (computed sobre computed — o refactor a un solo lugar, tú
    decides y justificas).
11. Pestañas en la cola: "Activos" / "Resueltos hoy" / "Todos" con
    `<component :is>` o simple estado + computed (elige y justifica contra
    la Fase 6).
12. Agrega al workspace el historial de cambios de estado: cada `patchTicket`
    también POSTea a una colección `activity`
    (`{ticketId, from, to, by, at}`) y una lista la muestra bajo los
    comentarios.
13. Sincroniza la selección a la URL (`/support?ticket=5`) con
    `router.replace` y restáurala al montar: el agente puede compartir "mira
    este ticket" — tercer uso del truco de la Fase 4, ya deberías hacerlo con
    los ojos cerrados.
14. Contador de comentarios en la cola: cada fila muestra 💬 N. Cuidado: NO
    cargues los comentarios de todos los tickets (N requests) — json-server
    permite `GET /comments` completo y agrupar con lodash `countBy` en un
    solo request (Fase 7 déjà vu).
15. Auto-selección inteligente: al entrar al panel, selecciona
    automáticamente el ticket sin asignar más antiguo de prioridad más alta.
16. Arregla el ejercicio 8: al volver de editar (usa `beforeRouteEnter` o
    detecta el `from` en un guard), recarga el ticket afectado — o más
    simple y honesto: recarga la lista. Discute el trade-off en un
    comentario.
17. `CommentBox` v2: soporta Ctrl+Enter para enviar (`@keydown.ctrl.enter`)
    y muestra un contador de caracteres si pasa de 200. ¿El contador va en
    el hijo o el padre? Justifica con el contrato v-model.

**🟠 Difícil (18–23)**

18. Permisos de transición: solo el **assignee** puede resolver, y solo un
    agente puede cerrar. Modela como función pura
    `canTransition(ticket, user, to)` en `ticketTransitions.js`, úsala para
    filtrar `available` en `StatusActions` (nueva prop `user`). Los botones
    prohibidos no se muestran — y anota dónde más habría que validar esto en
    un sistema real.
19. `ticket:updated` por socket, versión completa: `patchTicket` emite el
    evento tras el éxito; el server rebota; los OTROS paneles hacen splice
    del actualizado. Prueba con dos ventanas: dos agentes viendo la misma
    cola moverse.
20. Conflicto de "tomar": dos agentes toman el mismo ticket casi a la vez.
    Con json-server gana el último PATCH silenciosamente 💀. Mitiga en el
    cliente: antes del PATCH de tomar, re-consulta el ticket; si ya tiene
    assignee, aborta con mensaje "Ana se te adelantó". Explica en un
    comentario por qué esto reduce pero NO elimina la carrera (y qué haría
    falta del lado del servidor).
21. Panel dividido redimensionable: arrastra el borde entre cola y workspace
    (mousedown/mousemove/mouseup en `mounted`, limpiados en `beforeDestroy` —
    checklist de la Fase 7). Persiste el ancho en localStorage.
22. `Promise.allSettled` casero: implementa `allSettled(promises)` que nunca
    rechaza y devuelve `[{status, value|reason}]`. Úsalo en `loadData` para
    que si `users` falla, el panel cargue igual con tickets (y los nombres
    degradados a usernames).
23. Atajos de teclado del agente: `j`/`k` navegan la cola, `Enter` abre,
    `t` toma, `r` resuelve. Listener global de keydown en `mounted` de la
    vista (¡limpiado en `beforeDestroy`!) que ignora eventos cuando el foco
    está en un input/textarea (pista: `event.target.tagName`).

**🔴 Muy difícil (24–26)**

24. Validación de transiciones server-side: middleware de json-server que,
    en PATCH de tickets con cambio de `status`, cargue el estado actual y
    valide contra `TRANSITIONS` — **importando el mismo
    `ticketTransitions.js`** (ajusta a exports compatibles con require, o
    duplica con un comentario de vergüenza). Rechaza con 422 y maneja ese
    error en el workspace. Cierra el círculo: la máquina de estados vive una
    vez, gobierna en ambos lados.
25. Cola en vivo total: integra los ejercicios 19 (updated), 11 de la Fase 8
    (deleted) y el created existente, y añade el caso maldito: te
    **des-asignan** el ticket que tienes abierto. Diseña qué debe pasar
    (¿aviso? ¿cierre del workspace? ¿solo actualizar?) y por qué. Documenta
    la matriz evento × estado-de-la-UI que consideraste.
26. "Modo enfoque": botón que oculte la cola y muestre el workspace a pantalla
    completa con el ticket actual + botón "Siguiente de la cola" que aplique
    la lógica del ejercicio 15 para traer el próximo sin ver la lista. El
    estado del modo, la selección y la regla de "siguiente" — decide dónde
    vive cada cosa y escribe 5 líneas defendiéndolo. Es el ensayo general de
    la Fase 10.

---

## 📚 Referencias

**Documentación oficial**

- Vue 2 — key en componentes (forzar reemplazo):
  https://v2.vuejs.org/v2/api/#key
- Vue 2 — v-model en componentes:
  https://v2.vuejs.org/v2/guide/components-custom-events.html#Customizing-Component-v-model
- Vue 2 — la opción `model`: https://v2.vuejs.org/v2/api/#model
- Vue 2 — Change Detection Caveats (la trampa de `isNew`):
  https://v2.vuejs.org/v2/guide/reactivity.html#Change-Detection-Caveats
- MDN — Promise.all:
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all
- Vue Router 3 — meta fields (roles en rutas):
  https://v3.router.vuejs.org/guide/advanced/meta.html
- Bootstrap 4.6 — List group: https://getbootstrap.com/docs/4.6/components/list-group/

**Video / apoyo**

- Vue Mastery / Net Ninja — episodios de custom v-model y comunicación entre
  componentes (playlists ya citadas)

**Orden de lectura sugerido:** key en componentes → custom v-model →
Promise.all → volver al código. Meta fields solo si extiendes el guard.

---

## 🚀 Cierre

El Mini Jira ya tiene sus dos caras — quien reporta y quien resuelve — y la
fase de síntesis dejó su veredicto: los badges, servicios, la máquina de
estados nacida de un ejercicio, los sockets y hasta los filtros de fecha se
ensamblaron **sin modificar nada de lo anterior**. Examen aprobado. 🎓

Lo (poco) nuevo que te llevas:

- **master-detail con selección local**: guardar el id, derivar el objeto,
  y `:key` como botón de reset de instancias,
- **v-model propio**: el contrato `value`/`input` y cuándo NO hacer copia
  local,
- **`Promise.all`** para cargas paralelas con un solo loading,
- y la disciplina de que **el hijo emite resultados y el padre incorpora**:
  un camino de escritura, N de lectura, cero divergencias.

La señal de que quedó bien:

> "el panel más complejo del sistema se construyó componiendo piezas de
> ocho fases sin abrir ninguna para 'ajustarla'. Y cuando algo cambia,
> sé exactamente en qué capa se toca."

**Siguiente parada:** 🗂️ Fase 10 — Vuex a fondo: con tres fases de
experiencia diciendo "esto NO va al store todavía", por fin la pregunta con
evidencia en la mano: ¿qué SÍ va, qué no, y cómo migrar sin romper nada?
