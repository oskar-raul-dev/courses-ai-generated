# 🕒 Q4 — Timeline de actividad

> Quasar puro. Sin traducir nada.
>
> **Consume:** F8 (WebSockets), F10 (criterio de estado), Q1 (layouts/boot), Q2 (QForm), Q3 (QTable).
> **Migra:** nada. Esta feature **no existe** en el curso base.

---

## 🎯 Propósito

> 🔗 **Vienes de Q3**, que cerró con: *"ya migraste. Ahora construye algo que no
> existía — Quasar puro, sin traducir."* Esta es esa fase.

Q2 y Q3 fueron traducciones: tenías un formulario, te dieron `QForm`; tenías una
tabla, te dieron `QTable`. El riesgo es evidente — se puede aprobar una migración
haciendo *pattern matching* sin entender nada del framework.

Esta fase te quita la muleta. **No hay original que copiar.** Vas a construir un
**timeline de actividad del ticket**: una columna cronológica que dice quién hizo
qué, cuándo, sobre qué ticket. Y se alimenta del **socket de F8**, que hasta ahora
solo servía para un toast fugaz que desaparecía en 4 segundos.

Ese es el otro objetivo, más de fondo: **aterrizar los WebSockets**. En F8 el
evento en vivo era una notificación — llegaba, brillaba, moría. Aquí el evento
**deja rastro**: se pinta, se acumula, se queda. Es la diferencia entre "me
avisan" y "hay un historial".

Lo que realmente se aprende:

- `QTimeline` / `QTimelineEntry` / `QChip`: componentes que **no tienen equivalente
  en Bootstrap 4**. No hay nada que borrar — hay algo que no podías tener;
- el patrón de sockets de F8 **reutilizado sin cambios** en un proyecto Quasar
  (el `socketService` es agnóstico: no le importa quién pinta);
- aplicar **el criterio de F10** a un estado nuevo, con la evidencia de esta fase,
  en vez de repetir un veredicto que ya venía dado;
- y la deuda más honesta del curso: **este historial lo genera el backend**, no el
  front. Aquí lo fabricamos nosotros porque json-server no sabe hacerlo.

> La regla de la fase: el front **pinta** el historial, no lo **produce**.
> Que aquí lo produzca es una muleta, y las muletas se marcan 💸.

---

## ✅ Qué queda listo al terminar

- colección nueva **`activity`** en `db.json`, con su `activityService.js`;
- vista/panel **`TicketActivity.vue`** (Quasar puro): `QTimeline` + `QTimelineEntry`,
  con `QChip` de color por tipo de evento;
- integrado en el detalle del ticket dentro del `QLayout` de Q1 (`QPage` + `q-pa-md`);
- **carga inicial por HTTP** (GET `/activity?ticketId=X&_sort=at&_order=desc`) +
  **actualización en vivo por socket** (`activity:created`);
- emisión desde el front al guardar (F5/Q2) y al cambiar estado (F9): el evento se
  **POSTea** y se **emite**, marcado 💸 como muleta;
- ciclo de vida limpio, patrón F8 **idéntico**: `on` en `mounted`, `off` en
  `beforeDestroy`, handler guardado en el componente (no `.bind` inline);
- **decisión de estado documentada**: por qué el timeline es local y no Vuex,
  con las 4 preguntas de F10 respondidas por escrito;
- proyecto final: **híbrido** — dashboard y CRUD en Quasar, el resto en Bootstrap.
  Con eso se cierra la ruta.

## 🚫 Qué NO entra

- **generación del historial en el backend** (triggers, event sourcing, outbox):
  es exactamente lo que **falta** y por eso hay 💸;
- timeline global de "toda la actividad del sistema" (ejercicio 🟠);
- paginación / *infinite scroll* del historial (ejercicio 🟠 con `QInfiniteScroll`);
- deduplicación fuerte (si dos pestañas emiten a la vez, duplicas: ejercicio 🔴 22);
- diffs de campo a campo tipo Jira ("cambió descripción: +12 −3 caracteres");
- avatares reales de usuario (`QAvatar` con iniciales, ejercicio 🟢);
- `QStepper` **como fase** — se paga como ejercicio 🔴 26 (migrar el wizard de F6).

---

## 🧠 Concepto 1: un timeline no es una lista

Podrías pintar esto con un `<ul>` y quince líneas de CSS. La pregunta legítima es
por qué usar un componente. La respuesta no es "porque es más bonito":

| | `<ul>` a mano (Bootstrap) | `QTimeline` |
|---|---|---|
| Línea vertical y nodos | CSS tuyo (`::before`, `border-left`, `position`) | de fábrica |
| Layout | tú decides | `side` (`left`/`right`), `layout="dense"` / `"comfortable"` / `"loose"` |
| Icono/color por entrada | tuyo | `:icon` + `:color` por `QTimelineEntry` |
| Encabezado y subtítulo | tuyo | `title` + `subtitle` (slots si quieres más) |
| Modo "titulo de sección" | — | `<q-timeline-entry heading>` (agrupar por día 👀) |
| Accesibilidad / responsive | tuyo | razonable de serie |

Lo que compras es **estructura semántica y variación por entrada**. Lo que pagas
es lo mismo que pagaste en Q3: **el componente impone su forma**. Tus datos tienen
que salir en la forma que `QTimeline` espera, y esa transformación tiene un nombre
en Vue 2: **computed**. Guarda el crudo, pinta el derivado.

### La anatomía mínima

```
<q-timeline>                     ← el contenedor: dibuja la línea
  ├── <q-timeline-entry heading> ← opcional: separador de sección ("10 mar 2020")
  ├── <q-timeline-entry>         ← un evento: icon, color, title, subtitle
  │      └── slot default        ← el cuerpo libre: aquí van los QChip
  └── <q-timeline-entry>
```

## 🧠 Concepto 2: `QChip` — el badge de Q3, con más superficie

En F4 hiciste badges de estado a mano (`<span class="badge badge-danger">`). En
Q3 los metiste en un slot `body-cell-status` de `QTable`. `QChip` es el mismo
concepto, ampliado:

```html
<q-chip dense square color="orange" text-color="white" icon="swap_horiz">
  cambio de estado
</q-chip>
```

Props que vas a usar: `color`, `text-color`, `icon`, `dense`, `square`, `outline`,
`removable` (emite `@remove`, útil para filtros), `clickable`.

**⚠️ El detalle que muerde:** `color="orange"` es la **paleta de Quasar**, no un
color CSS. Si escribes `color="#ff9800"` **no funciona** — Quasar aplica una clase
(`bg-orange`), no un estilo inline. Para colores fuera de la paleta necesitas
`:style` a mano o definir una **brand color** en `quasar.conf.js`. Es exactamente
el mismo tipo de fricción que ya te comiste en Q1 con el grid: **Quasar tiene su
propio vocabulario y no acepta el tuyo**.

## 🧠 Concepto 3: el modelo `activity`

Colección nueva en el `db.json` del curso:

```json
{
  "activity": [
    {
      "id": 1,
      "ticketId": 1,
      "type": "status_change",
      "actor": "agente1",
      "from": "open",
      "to": "in_progress",
      "at": "2020-03-10T11:00:00Z"
    },
    {
      "id": 2,
      "ticketId": 1,
      "type": "assigned",
      "actor": "admin",
      "from": null,
      "to": "agente1",
      "at": "2020-03-10T11:02:00Z"
    },
    {
      "id": 3,
      "ticketId": 1,
      "type": "comment",
      "actor": "agente1",
      "from": null,
      "to": "¿Probaste apagarla y prenderla?",
      "at": "2020-03-10T11:05:00Z"
    }
  ]
}
```

Cinco tipos, y solo cinco (`created`, `status_change`, `assigned`,
`priority_change`, `comment`). Fíjate en la forma: **`from`/`to` genéricos**, no
un campo distinto por tipo. Es un evento de dominio pobre, deliberadamente:

- ✅ **Buenas prácticas:** el timeline **no interpreta datos, interpreta eventos.**
  Si mañana el backend añade `type: "reopened"`, el front debe **degradar con
  dignidad** (chip gris, icono genérico), no reventar con un `undefined`. El mapa
  de tipos siempre tiene un `default`.
- 💸 `from`/`to` como `string | null` para todo (incluido el cuerpo de un
  comentario) es una simplificación fea. En un backend de verdad tendrías un
  `payload` tipado por evento. *"Aquí caben tres tipos en la misma caja; en
  producción cada evento trae su forma."*

## 🧠 Concepto 4: ¿el timeline vive en Vuex? — el criterio de F10, aplicado

Aquí no hay regla, hay **las cuatro preguntas de F10**. Respóndelas antes de leer
el veredicto:

| Pregunta | Timeline de UN ticket | Sesión (F2) | Tickets (F10) |
|---|---|---|---|
| ¿2+ vistas lo consumen? | ❌ solo el detalle | ✅ | ✅ |
| ¿Sobrevive a la navegación? | ❌ y **no quiero**: al cambiar de ticket, muere | ✅ | ✅ |
| ¿Lo mutan varias fuentes? | ✅ **HTTP + socket** | ✅ | ✅ |
| ¿La inconsistencia sería un bug visible? | ❌ nadie más lo ve | ✅ | ✅ |

**1 sí de 4 → local.** El timeline vive en el `data()` del componente, con el mismo
argumento que los **comentarios de F9**: quieres que muera con la vista. Cambias de
ticket, el `:key` renueva el componente, la lista se recarga. Eso no es un fallo:
es la semántica correcta.

El "sí" solitario (multi-fuente) es real y **no es gratis** — es lo que te obliga a
tener dos caminos de escritura al mismo array (`loadHistory()` y `onActivity()`), y
lo que crea el riesgo de duplicados del ejercicio 22. Un solo "sí" no es cero.

> **El contra-caso está en el ejercicio 20**: un contador global de "actividad no
> leída" en el header **sí** va al store (2+ vistas ✅, sobrevive a la navegación ✅).
> Mismo dominio, distinto estado, **distinto veredicto**. Eso es criterio y no dogma:
> "el timeline es local" es falso como regla; es verdadero **para este estado**.

> 🔌 **¿Y por qué `activity:created` NO va al `socketPlugin` de F10?** Buena
> pregunta, porque en F10 hiciste justo lo contrario: sacaste los handlers de
> socket de las vistas y los centralizaste en un **plugin de Vuex**
> (`store/plugins/socketPlugin.js`), que escucha `ticket:created` / `ticket:updated`
> y commitea `tickets/UPSERT_TICKET` **una sola vez** para todas las vistas. Ese
> patrón fue correcto **porque los tickets viven en el store** (2+ vistas, sobrevive
> a la navegación): el plugin es el sitio natural para un evento cuyo destino es el
> estado global.
>
> El timeline **no vive en el store** (acabas de decidirlo: 1 sí de 4). Meter
> `activity:created` en el `socketPlugin` te obligaría a subir `entries` a Vuex —
> exactamente lo que la tabla de arriba dice que **no** hagas — y a limpiarlo al
> cambiar de ticket. Por eso el handler de `activity:created` vive **en el
> componente** (`mounted`/`beforeDestroy`), como los comentarios de F9 y como el
> socket **antes** de que F10 lo centralizara. **La regla que sale de aquí:** un
> evento de socket va al plugin **si su destino es el store**; si su destino es un
> componente que muere con la vista, se escucha en el componente. `ticket:*` → plugin
> (store). `activity:created` → componente (local). Mismo socket, dos destinos,
> dos sitios. No es incoherencia: es el criterio de F10 decidiendo *dónde escuchar*,
> no solo *dónde guardar*.

---

## 💻 Código

### 1. `db.json` — la colección nueva

Añade `activity` al `db.json` que arrastras desde F3. json-server te regala el CRUD
y los filtros (`?ticketId=1`, `_sort`, `_order`) sin escribir una línea.

### 2. `src/services/activityService.js`

Mismo patrón de F3, misma arquitectura del curso (Componente → Store → services/ →
apiClient → API). **El `apiClient` viene del boot file de Q1**, no de `main.js`.

```js
// src/services/activityService.js
import apiClient from "./apiClient";

function getByTicket(ticketId) {
  // json-server: filtro + orden, gratis
  return apiClient
    .get("/activity", {
      params: { ticketId: ticketId, _sort: "at", _order: "desc" }
    })
    .then(function (res) {
      return res.data;
    });
}

function create(activity) {
  return apiClient.post("/activity", activity).then(function (res) {
    return res.data;
  });
}

export default {
  getByTicket: getByTicket,
  create: create
};
```

**🔎 Qué hace:** nada nuevo. Y ese es el punto — **Quasar no toca la capa de
servicios.** Q1, Q2 y Q3 no cambiaron un solo `service`. El framework es de UI:
llega hasta el `<template>` y ahí se detiene.

### 3. 💸 El emisor — la muleta declarada

```js
// src/services/activityEmitter.js
// 💸 ESTO NO DEBERÍA EXISTIR. Ver la sección de deuda.
import activityService from "./activityService";
import socketService from "./socketService"; // el de F8, intacto

function record(evt) {
  var activity = {
    ticketId: evt.ticketId,
    type: evt.type,
    actor: evt.actor,
    from: evt.from === undefined ? null : evt.from,
    to: evt.to === undefined ? null : evt.to,
    at: new Date().toISOString() // 💸 el reloj del CLIENTE. Ver deuda.
  };

  // 1) persistir     → para el que entre después y haga GET
  // 2) emitir        → para el que YA está mirando el ticket ahora
  return activityService.create(activity).then(function (saved) {
    socketService.emit("activity:created", saved); // emitimos el guardado (trae id real)
    return saved;
  });
}

export default { record: record };
```

Y en el mini servidor de F8, **una línea**, con el mismo `broadcast` de siempre:

```js
// server/socket-server.js — añadir junto a ticket:created
socket.on("activity:created", function (activity) {
  socket.broadcast.emit("activity:created", activity); // a todos menos al emisor
});
```

**🔎 Qué hace, y en qué orden:**

| Paso | Quién | Por qué en ese orden |
|---|---|---|
| `POST /activity` | el cliente que actúa | primero la verdad persistida: si falla, no anuncias una mentira |
| `emit("activity:created", saved)` | el mismo cliente | emites **la respuesta del POST**, no tu objeto local: así todos ven el mismo `id` |
| `broadcast.emit` | el server | a todos **menos** al emisor — que ya lo tiene del `.then` |

- ✅ **Buenas prácticas:** persistir → **después** anunciar. Al revés (anunciar
  primero) tienes *optimistic UI*, que es legítimo, pero entonces necesitas **plan
  de rollback**. Aquí no lo tenemos, así que no lo hacemos. Es el ejercicio 🔴 24.

### 4. Dónde se llama a `record()`

En los sitios donde el dominio ya cambia. En el curso base, el cambio de estado y
la asignación pasan por **`ticketService.updateTicket(id, changes)`** (la firma de
F10, la misma que usa el `patchTicket` de F9). El sitio limpio para registrar la
actividad es **la action de F10 `tickets/updateTicket`**, porque es el único cuello
de botella por donde pasan todos los cambios:

```js
// store/modules/tickets.js — la action YA EXISTE en F10. Le añadimos la línea 💸.
updateTicket: function (context, payload) {
  // payload: { id, changes }  ← firma de F10, no la inventamos
  var before = context.getters.ticketById(payload.id); // getter-función de F10

  return ticketService
    .updateTicket(payload.id, payload.changes)
    .then(function (updated) {
      context.commit("UPSERT_TICKET", updated); // mutación real de F10

      // 💸 el front generando historial. Ver deuda.
      // Derivamos el tipo de evento del CHANGES: no inventamos actions nuevas.
      var actor = context.rootGetters["auth/currentUser"].username; // getter real de F2/F10
      if (payload.changes.status && payload.changes.status !== before.status) {
        activityEmitter.record({
          ticketId: updated.id, type: "status_change", actor: actor,
          from: before.status, to: updated.status
        });
      }
      if (payload.changes.assignee && payload.changes.assignee !== before.assignee) {
        activityEmitter.record({
          ticketId: updated.id, type: "assigned", actor: actor,
          from: before.assignee, to: updated.assignee
        });
      }

      return updated;
    });
}
```

**⚠️ Por qué en la action y no en el componente — y qué implica eso para F9:** en
F9, el panel hace el PATCH **desde el componente** (`patchTicket` →
`ticketService.updateTicket` → `$emit("updated")`), **sin pasar por Vuex**. Si dejas
el registro en la action, **el panel de F9 no registrará nada** hasta que lo
reencamines por `dispatch("tickets/updateTicket", ...)`. Esa reconducción es
precisamente **parte del ejercicio 🔴 de migrar el panel (Q3)** y del ejercicio 10
de esta fase — no es un descuido, es la deuda de tener dos caminos de escritura al
mismo recurso. Lo honesto es decirlo: hoy el panel escribe por un lado y el resto
por otro, y unificarlos es trabajo. Es F10 cobrando intereses.

> 💡 **Nota de continuidad:** la action `updateTicket` de F10 recibe `{ id, changes }`.
> Un `changes` puede traer `status` **y** `assignee` a la vez (el `takeTicket` de F9
> manda los dos). Por eso derivamos **cero, uno o dos** eventos del mismo PATCH, en
> vez de asumir un evento por llamada.

### 5. `TicketActivity.vue` — Quasar puro

```vue
<template>
  <!-- Nada de <div class="card"> de Bootstrap: aquí mandan QCard y q-pa-md (Q1) -->
  <q-card flat bordered class="q-pa-md">
    <div class="row items-center q-mb-md">
      <div class="text-h6 col">Actividad</div>
      <q-badge v-if="live" color="green" align="middle">en vivo</q-badge>
    </div>

    <!-- 3 estados: loading / error / data. El patrón de F3, intacto -->
    <div v-if="loading" class="q-py-md">
      <q-skeleton type="text" v-for="n in 3" :key="n" class="q-mb-sm" />
    </div>

    <q-banner v-else-if="error" dense class="bg-red-1 text-red-9">
      No se pudo cargar la actividad.
      <template v-slot:action>
        <q-btn flat dense label="Reintentar" @click="load" />
      </template>
    </q-banner>

    <div v-else-if="entries.length === 0" class="text-grey-7 q-py-md">
      Sin actividad todavía.
    </div>

    <q-timeline v-else color="primary" layout="comfortable">
      <q-timeline-entry
        v-for="e in entries"
        :key="e.id"
        :icon="meta(e.type).icon"
        :color="meta(e.type).color"
        :subtitle="formatDate(e.at)"
      >
        <template v-slot:title>
          <q-chip
            dense
            square
            :color="meta(e.type).color"
            text-color="white"
            :icon="meta(e.type).icon"
          >
            {{ meta(e.type).label }}
          </q-chip>
          <span class="text-weight-medium q-ml-sm">{{ e.actor }}</span>
        </template>

        <div class="text-body2">{{ describe(e) }}</div>
      </q-timeline-entry>
    </q-timeline>
  </q-card>
</template>

<script>
import activityService from "../services/activityService";
import socketService from "../services/socketService"; // F8, sin tocar

// Mapa de tipos: fuera de data() — es una constante, no estado reactivo.
// (Misma disciplina que el chart de F7 y el socket de F8: lo que no cambia, no reacciona.)
var TYPE_META = {
  created:         { label: "creado",     color: "primary", icon: "add_circle" },
  status_change:   { label: "estado",     color: "orange",  icon: "swap_horiz" },
  assigned:        { label: "asignado",   color: "purple",  icon: "person_add" },
  priority_change: { label: "prioridad",  color: "red",     icon: "priority_high" },
  comment:         { label: "comentario", color: "teal",    icon: "chat_bubble" }
};
var FALLBACK = { label: "evento", color: "grey", icon: "circle" };

export default {
  name: "TicketActivity",

  props: {
    ticketId: { type: [Number, String], required: true }
  },

  data: function () {
    return {
      entries: [],   // 🎯 LOCAL, no Vuex. Ver Concepto 4.
      loading: false,
      error: null,
      live: false,
      onActivityHandler: null // la referencia estable para el off(). F8, lección 1.
    };
  },

  methods: {
    meta: function (type) {
      return TYPE_META[type] || FALLBACK; // degrada, no revienta
    },

    describe: function (e) {
      if (e.type === "comment") return e.to;
      if (e.from === null) return e.to;
      return e.from + " → " + e.to;
    },

    formatDate: function (iso) {
      return new Date(iso).toLocaleString();
    },

    load: function () {
      var self = this;
      this.loading = true;
      this.error = null;

      return activityService
        .getByTicket(this.ticketId)
        .then(function (data) {
          self.entries = data;
        })
        .catch(function (err) {
          self.error = err;
          self.$q.notify({ type: "negative", message: "Error cargando actividad" });
        })
        .finally(function () {
          self.loading = false;
        });
    },

    onActivity: function (activity) {
      // 🔎 El socket es un canal ABIERTO: llegan eventos de TODOS los tickets.
      // Filtrar por ticketId no es opcional. (El ejercicio 18 lo arregla con rooms.)
      if (String(activity.ticketId) !== String(this.ticketId)) return;

      // unshift: orden descendente, lo nuevo arriba. Método parcheado por Vue 2 → reactivo.
      this.entries.unshift(activity);
    }
  },

  mounted: function () {
    this.load();

    this.onActivityHandler = this.onActivity.bind(this);
    socketService.on("activity:created", this.onActivityHandler);
    this.live = socketService.isConnected();
  },

  beforeDestroy: function () {
    // Simétrico y completo. Todo lo que se suscribe, se desuscribe. (F8)
    socketService.off("activity:created", this.onActivityHandler);
    this.onActivityHandler = null;
  }
};
</script>
```

**🔎 Qué hace, punto por punto:**

| Línea | Por qué está |
|---|---|
| `TYPE_META` fuera de `data()` | constante, no estado. Meterla en `data` es hacer reactivo un objeto que nunca cambia — coste sin beneficio |
| `meta()` con `FALLBACK` | el backend puede inventar un `type` mañana. Degradar > reventar |
| `entries` en `data()` | **el veredicto del Concepto 4**, escrito en código |
| `onActivityHandler` en `data()` | la referencia **idéntica** que exige el `off()`. `.bind(this)` inline en el `on` y otro en el `off` = dos funciones distintas = zombis (F8) |
| filtro por `ticketId` en `onActivity` | el socket es global; el componente es de UN ticket |
| `unshift` | está en la lista de métodos parcheados de Vue 2 → dispara reactividad. `entries[0] = x` **no** |
| `$q.notify` en el catch | Q1: adiós a las alertas propias |
| `q-skeleton` en loading | el patrón loading/error/data de F3, pero con la caja de herramientas de Quasar |

### 6. Uso desde el detalle (dentro del `QLayout` de Q1)

```html
<!-- src/pages/TicketDetail.vue -->
<q-page class="q-pa-md">
  <div class="row q-col-gutter-md">
    <div class="col-12 col-md-7">
      <!-- 🤝 el formulario de Q2. Firma REAL de F5: prop initialTicket, evento @submit -->
      <ticket-form :initial-ticket="ticket" @submit="onSubmit" @cancel="onCancel" />
    </div>
    <div class="col-12 col-md-5">
      <!-- :key fuerza el remount al cambiar de ticket: la lista muere y renace. A propósito. -->
      <ticket-activity :key="ticket.id" :ticket-id="ticket.id" />
    </div>
  </div>
</q-page>
```

### 7. El flujo completo, evento por evento

```
PESTAÑA A (agente1 cambia el estado)          SERVER            PESTAÑA B (mirando el mismo ticket)
        │                                        │                        │
1. click en "En progreso"                        │                        │
        │                                        │                        │
2. dispatch("tickets/updateTicket", {id:1, changes:{status:"in_progress"}})
        │                                        │                        │
3. PATCH /tickets/1 ────────────────────► json-server (:3000)             │
        │◄──────────────── 200 {..., status:"in_progress"}                │
        │                                        │                        │
4. commit("UPSERT_TICKET") → la tabla de Q3 se repinta (Vuex)             │
        │                                        │                        │
5. 💸 activityEmitter.record(...)                │                        │
        │                                        │                        │
6. POST /activity ───────────────────────► json-server                    │
        │◄──────────────── 201 { id: 42, ... }                            │
        │                                        │                        │
7. socket.emit("activity:created", saved) ──────►│                        │
        │                                        │                        │
8.      │                     socket.broadcast.emit(...) ────────────────►│
        │                                        │                        │
9.      │                                        │      onActivity(a) → ¿a.ticketId === mío?
        │                                        │      SÍ → entries.unshift(a)
        │                                        │      🎨 QTimelineEntry nuevo, arriba
        │                                        │
   (A no recibe el broadcast — ya lo tiene       │
    del .then del POST. Cero duplicados.)        │

⚠️ Pestaña C, mirando OTRO ticket: recibe el broadcast en el paso 8,
   el filtro del paso 9 dice NO, se descarta. El evento viaja igual.
   Eso es tráfico que no sirve → ejercicio 🟠 18 (rooms por ticket).
```

---

## ⚠️ Errores comunes

- **`color="#ff9800"` en un `QChip`** → no pasa nada, literalmente. Quasar aplica
  clases (`bg-orange`), no estilos inline. Usa la paleta o define brand colors.
- **Componente no declarado** en `framework.components` de `quasar.conf.js`
  (`QTimeline`, `QTimelineEntry`, `QChip`, `QSkeleton`, `QBanner`) → **no renderiza
  y no hay error claro**. El error clásico de Q1, cobrándose su tercera víctima.
- **No filtrar por `ticketId`** en el handler del socket → ves en el timeline del
  ticket 1 los eventos del ticket 7. Y lo peor: **parece** que funciona hasta que
  hay dos usuarios trabajando a la vez.
- **`.bind(this)` distinto en `on` y `off`** → el `off` no desuscribe nada. Navegas
  entre 3 tickets y el cuarto evento aparece 3 veces. **Zombis de F8, capítulo dos.**
- **`entries[0] = nueva`** en vez de `unshift` → Vue 2 no lo detecta. No es un bug
  de Quasar: es F4 volviendo a cobrar.
- **Emitir sin persistir** ("total, el otro ya lo ve") → el que entre después hace
  GET y no encuentra nada. El evento existió durante 4 segundos en dos navegadores.
- **Registrar la actividad en el componente** en vez de en la action → el día que
  el `QTable` de Q3 permita editar inline, ese cambio no deja rastro. Silencioso.
- **`at` con `new Date()` del cliente** → dos usuarios con relojes distintos y el
  timeline se desordena. 💸 declarada abajo, no accidente.
- **Meter `entries` en Vuex "por si acaso"** → ahora tienes que limpiarlo al salir,
  o el timeline del ticket 3 arranca mostrando los eventos del ticket 1. El store
  no es gratis: **lo que sube al store, hay que bajarlo**.

---

## 💸 Deuda: el historial lo genera el BACKEND

**Lo que hicimos:** el front, al guardar, hace un `POST /activity` y emite un socket.
**Lo que se hace en producción:** nada de eso.

Un historial de actividad es un **subproducto del dominio**, no una petición del
front. Se genera donde ocurre el cambio:

| Mecanismo | Dónde vive | Cómo llega al front |
|---|---|---|
| Triggers de BD (`AFTER UPDATE ON tickets`) | la base | el front hace GET y ya está ahí |
| Eventos de dominio / CQRS | la capa de aplicación | el backend publica al bus y de ahí al socket |
| Outbox pattern | tabla + relay | igual, pero **transaccional** |

**Los tres agujeros de nuestra versión, sin maquillaje:**

1. **Se puede saltar.** Un `curl -X PATCH /tickets/1` cambia el estado y **no deja
   rastro**. Nuestro historial solo registra lo que pasa por nuestra UI. Un historial
   que se puede evitar **no es un historial**, es un log de la UI.
2. **No es atómico.** El `PATCH` puede tener éxito y el `POST /activity` fallar. Te
   queda un cambio sin historia. Con un trigger o un outbox, o van los dos o no va
   ninguno.
3. **El reloj es del cliente.** `new Date().toISOString()` en el navegador. Dos
   agentes con la hora mal puesta y tu cronología es ficción. En el backend, el
   timestamp lo pone el servidor y punto.

> 💸 **La frase:** *"Aquí lo emitimos desde el front al guardar; en producción eso
> llega solo, y el front solo lo pinta."*

**Y esto es lo importante para tu trabajo:** el `TicketActivity.vue` que escribiste
**no cambia** el día que el backend haga bien su trabajo. Sigue haciendo GET, sigue
escuchando `activity:created`. Lo que se **borra** es el `activityEmitter.js` y las
llamadas a `record()` en las actions. Ese archivo tiene 💸 en la cabecera **por eso**:
está marcado para morir. La feature está bien construida; la muleta está señalizada.

*(Simular un backend decente es el ejercicio 🔴 25.)*

---

## 🧪 Ejercicios (26)

**🟢 Fácil (1–8)**

1. Añade `activity` a tu `db.json` con al menos 6 eventos de 2 tickets distintos.
   Verifica en el navegador que `GET /activity?ticketId=1&_sort=at&_order=desc`
   devuelve lo que esperas, **antes** de escribir una línea de Vue.
2. Cambia `layout="comfortable"` por `"dense"` y `"loose"`. Captura las tres.
   Elige una y **escribe en un comentario por qué**.
3. Añade un sexto tipo, `reopened`, al `TYPE_META` (color `indigo`, icono
   `replay`). Verifica primero que **sin** añadirlo el chip sale gris y no
   revienta: eso es el `FALLBACK` haciendo su trabajo.
4. Pon el timeline a la **izquierda** con `side="left"`, y luego alterna
   izquierda/derecha según el `type` (`created` a la izquierda, el resto a la
   derecha). ¿Mejora o distrae?
5. Añade un `QAvatar` con las iniciales del `actor` en el slot `title` de cada
   entrada. Color derivado del nombre (hash simple → índice de paleta).
6. Sustituye el `toLocaleString()` por un formato relativo ("hace 5 min") con una
   función tuya. Sin librerías. ⚠️ Ojo: no es reactivo — no se refresca solo.
   Documenta el problema, **no lo arregles** (es el ejercicio 12).
7. Añade `<q-separator />` entre el header de la card y el timeline. Y quita el
   `flat` del `QCard`: mira la sombra. Decide.
8. Fuerza el estado de error: apaga json-server, recarga el detalle. Comprueba
   que ves el `QBanner` y que el botón "Reintentar" funciona **con el servidor ya
   encendido de nuevo**.

**🟡 Intermedio (9–17)**

9. **Agrupa por día.** Usa `<q-timeline-entry heading>` para insertar un separador
   ("10 mar 2020") cada vez que cambia la fecha. Pista: no toques `entries` — es
   la fuente cruda. Hazlo en un **computed** que devuelva la lista ya intercalada.
   *(Esto es "guarda el crudo, pinta el derivado" del Concepto 1, en la práctica.)*
10. Registra `priority_change` (F5/Q2) y `assigned` (F9) además de `status_change`.
    ¿Dónde metes la llamada a `record()`? Justifica por qué **no** en el componente.
11. Emite `comment` desde el panel de soporte (F9) cuando se añade un comentario.
    Nota que ahora el comentario vive en **dos sitios**: `comments` y `activity`.
    ¿Es duplicación o son cosas distintas? Escribe tu respuesta en 3 líneas.
12. Haz que el "hace 5 min" del ejercicio 6 **sí** se refresque: un `setInterval` de
    60s en `mounted` que incrementa un contador en `data`, del que depende el
    computed. ⚠️ Y su `clearInterval` en `beforeDestroy` — **F7 y F8, misma lección,
    tercera vez**.
13. Filtro de tipos: una fila de `QChip` con `clickable` + `outline` arriba del
    timeline, que filtra las entradas visibles. ¿El estado del filtro va a `data` o
    a Vuex? Aplica las 4 preguntas de F10 y **escribe la tabla**.
14. `QChip` con `removable` y `@remove`: haz que los chips de filtro activos se
    puedan quitar uno a uno.
15. Deja el `TicketActivity` **abierto** en una pestaña y cambia el estado desde
    otra. Ahora **para el socket server** y repite. Documenta exactamente qué ve
    el usuario (spoiler: el POST funciona, el timeline de la otra pestaña no se
    entera hasta que recarga). ¿Es aceptable? ¿Qué le dirías al usuario?
16. Quita `QTimelineEntry` de `framework.components` en `quasar.conf.js`. Recarga.
    **Documenta el síntoma exacto** (qué ves, qué dice la consola, cuánto tardarías
    en diagnosticarlo si no supieras la causa). Restaura. Este ejercicio vale por
    diez lecturas de Q1.
17. Añade un `QInnerLoading` sobre la card mientras `loading`, en vez de los
    skeletons. Compara UX: ¿cuál miente menos sobre cuánto queda?

**🟠 Difícil (18–23)**

18. **Rooms por ticket.** Ahora mismo cada `activity:created` viaja a **todos** los
    clientes, y el 95% se descarta en el `if` del handler. Implementa
    `join`/`leave` de una room `ticket:<id>` en `mounted`/`beforeDestroy` (patrón
    del ejercicio 19 de F8) y emite con `io.to("ticket:" + id).emit(...)`. Verifica
    con 3 pestañas en 2 tickets distintos que el tráfico se reduce. **Y ahora la
    pregunta buena:** ¿puedes borrar el `if` del handler? ¿Deberías?
19. **`QInfiniteScroll`.** Un ticket con 300 eventos carga 300 entradas. Pagina con
    `_page` y `_limit` de json-server y `QInfiniteScroll`. 💸 Ojo: el evento en vivo
    llega **arriba** mientras tú paginas **hacia abajo**. ¿Se rompe algo?
20. **El contra-caso del store.** Contador de "actividad no leída" en el header del
    `QLayout` (un `QBadge` sobre un `QBtn`), que cuenta eventos de tickets **que no
    estás mirando**. Aplica las 4 preguntas: **este sí va a Vuex**. Implementa el
    módulo. Y explica en un comentario por qué el timeline **no** va y este **sí**,
    siendo el mismo dominio.
21. **Timeline global.** Una página `/activity` con la actividad de **todos** los
    tickets, con `QSelect` de filtro por actor y por tipo. Reutiliza
    `TicketActivity.vue` sin duplicarlo: extrae un componente presentacional
    (recibe `entries` por prop, no hace fetch ni escucha nada) y dos contenedores.
    Este ejercicio es la prueba de fuego de si tu componente estaba bien diseñado.
22. **Duplicados.** Abre 2 pestañas del **mismo** usuario en el **mismo** ticket y
    haz que ambas emitan casi a la vez. Reproduce el duplicado. Ahora arréglalo:
    ¿deduplicas por `id` en el `unshift`? ¿O el problema real es que **el front no
    debería emitir**? Argumenta las dos, elige una, y **enlázalo con la deuda 💸**.
23. **Detección de cambios sin trigger.** Un `curl -X PATCH` cambia un ticket y no
    deja rastro (agujero #1 de la deuda). Escribe un test que lo **demuestre**:
    PATCH directo → GET `/activity` → assert de que **falta** el evento. Un test que
    documenta una deuda vale más que un párrafo.

**🔴 Muy difícil (24–26)**

24. **Optimistic UI con rollback.** Ahora mismo: POST → luego pintar. Invierte el
    orden — pinta el evento **antes** de que el POST responda (con un `id`
    temporal y el chip en `outline`, para que se note que está "en vuelo"). Si el
    POST falla: quita la entrada, `$q.notify` negativo, revierte también el cambio
    de estado del ticket. **Compara con la versión actual y decide cuál mantienes.**
    Pista: la pregunta no es "¿cuál es más rápido?", es "¿qué le estoy prometiendo
    al usuario y puedo cumplirlo?".

25. **Paga la deuda 💸: mueve la generación al backend.** Escribe un middleware en
    el mini servidor de Node (el de F8, ampliado) que **intercepte** los PATCH a
    `/tickets`, compare el estado anterior con el nuevo, y genere él mismo el
    registro de `activity` + el emit del socket. Después **borra**
    `activityEmitter.js` y todas las llamadas a `record()` de tus actions.

    Los tres criterios de aceptación, y son duros:
    - un `curl -X PATCH` **sin pasar por la UI** deja rastro en el timeline;
    - el `at` lo pone el **servidor**, no el cliente;
    - `TicketActivity.vue` **no se toca ni una línea**.

    Si el tercero falla, tu componente estaba acoplado a la muleta. Y ese es
    exactamente el diagnóstico que esta fase quería que aprendieras a hacer.

26. **🔀 MIGRACIÓN TRANSVERSAL — el wizard (F6) a `QStepper`.**

    Migra el wizard de alta de ticket en 3 pasos (F6) a `QStepper`, **reutilizando
    los `QForm` de Q2**. Sin guía. Escribe primero los tests de regresión (Q0).

    > 💡 **Por qué esto es un ejercicio y no una fase:** `QStepper` **no es un
    > componente de formularios** — es de **navegación por pasos**. El formulario de
    > dentro lo montas exactamente igual que en Q2. Llegas ya sabiendo `QForm`; lo
    > único que tienes que resolver es la **navegación**. Dártelo masticado te
    > enseñaría menos que pelearte con ello.

    Lo que te vas a encontrar (y no te vamos a decir cómo se arregla):

    - `QStepper` + `QStep` con `:done`, `:error`, `v-model` del paso actual;
    - **la pregunta de la fase:** el botón "Siguiente" vive en el **stepper**, pero
      la validación vive en el **form** de dentro. ¿Quién le pregunta a quién?
      - ¿El stepper llama a `this.$refs["form" + n].validate()` (que devuelve
        **promesa**, Q2) antes de avanzar?
      - ¿O cada `QForm` emite `@validation-success` / `@validation-error` y el
        stepper solo escucha?
      - **Ninguna es "la correcta".** Elige, impleméntala, y escribe en 5 líneas
        qué acoplas en cada caso.
    - `keep-alive` (F6): `QStepper` tiene `keep-alive` propio. ¿Chocan? ¿Sobra el tuyo?
    - **La decisión de F6 vuelve a la mesa:** ¿el borrador vive en el componente o en
      el store? Con `QStepper` desmontando/remontando pasos, **¿cambia tu respuesta?**
      Si cambia, di por qué. Si no cambia, di por qué tampoco.
    - Y una que muerde: `QStepper` puede navegar **hacia atrás**. ¿Qué pasa con la
      validación de un paso que ya pasaste y ahora vuelves a romper?

    **Criterio de terminado:** los tests de regresión que escribiste **antes** siguen
    verdes, sin tocarlos.

---

## 📚 Referencias

> ⚠️ **quasar.dev sirve la documentación de v2 (Vue 3) por defecto.** Necesitas la
> **v1**. Comprueba siempre el selector de versión de la esquina superior.

**Documentación oficial (Quasar v1)**

- QTimeline: https://v1.quasar.dev/vue-components/timeline
- QChip: https://v1.quasar.dev/vue-components/chip
- QCard: https://v1.quasar.dev/vue-components/card
- QSkeleton: https://v1.quasar.dev/vue-components/skeleton
- QBanner: https://v1.quasar.dev/vue-components/banner
- QInfiniteScroll (ejercicio 19): https://v1.quasar.dev/vue-components/infinite-scroll
- QStepper (ejercicio 26): https://v1.quasar.dev/vue-components/stepper
- Paleta de color y brand colors: https://v1.quasar.dev/style/color-palette
- Iconos (Material Icons por defecto): https://v1.quasar.dev/vue-components/icon
- Notify (`$q.notify`): https://v1.quasar.dev/quasar-plugins/notify

**Del curso base (repasa antes de empezar)**

- socket.io 2.x — cliente (`on`/`off`/`emit`): https://socket.io/docs/v2/client-api/
- socket.io 2.x — rooms (ejercicio 18): https://socket.io/docs/v2/rooms/
- Vue 2 — métodos de array parcheados (`unshift`):
  https://v2.vuejs.org/v2/guide/list.html#Mutation-Methods
- Vue 2 — `:key` para forzar remount:
  https://v2.vuejs.org/v2/api/#key
- json-server — filtros, `_sort`, `_page`: https://github.com/typicode/json-server#filter

**Contexto (la deuda 💸, para entender qué falta de verdad)**

- Martin Fowler — Domain Event:
  https://martinfowler.com/eaaDev/DomainEvent.html
- microservices.io — Transactional Outbox:
  https://microservices.io/patterns/data/transactional-outbox.html

**Orden de lectura sugerido:** QTimeline (solo los ejemplos) → Color Palette (5 min,
te ahorra la hora del `#ff9800`) → volver al código. Fowler solo si vas a hacer el 25.

---

## 🚀 Cierre — y cierre de la ruta Q

Construiste algo que **no existía**. Sin original que traducir, sin `v-data-table`
al que mirar de reojo. Te llevas:

- `QTimeline` / `QTimelineEntry` / `QChip`: componentes **sin equivalente Bootstrap**
  — no todo en un framework es "lo que ya tenías, pero con otro nombre";
- el patrón de sockets de F8 **reutilizado tal cual**: el `socketService` no se enteró
  de que cambiaste de framework, porque **no tenía por qué**;
- el criterio de F10 aplicado a un caso nuevo — y su contra-caso en el mismo dominio
  (el timeline es local, el contador global es del store);
- y una deuda 💸 que sabes **exactamente cómo se paga**: borrando un archivo.

La señal de que quedó bien:

> "el día que el backend genere el historial de verdad, borro `activityEmitter.js`,
> quito tres llamadas de mis actions, y **el componente no se toca**."

---

### 🏁 Y con esto termina la ruta Q. Mira lo que tienes.

Abre el proyecto. El dashboard es `QTable`. El CRUD es `QForm`. El timeline es
`QTimeline`. **Y el wizard sigue siendo Bootstrap. Y las métricas de F7 siguen
siendo un `<canvas>` con chart.js. Y hay un modal de Bootstrap (`.modal` + jQuery)
conviviendo con `<q-dialog>` en el mismo árbol.** El `.row` de Bootstrap y el
`.row` de Quasar se pisan, y tú
sabes exactamente dónde y por qué.

**Eso no es un curso a medio terminar. Eso es el entregable.**

Nadie migra un legacy de golpe. Se migra la pantalla que duele, se deja la que
funciona, y el proyecto **vive años en ese estado intermedio**. Un curso que
terminara con el 100% en Quasar te estaría mintiendo sobre tu trabajo: te habría
enseñado a hacer un *greenfield*, que es justo lo que **no** vas a hacer.

Lo que de verdad te llevas de la ruta Q no es `QTable`. Es esto:

- **saber qué es Vue y qué es Quasar** cuando abres un `.vue` ajeno — y qué te está
  haciendo el framework **por debajo, sin avisarte**;
- **saber qué te ha quitado**: vuelidate salió del proyecto en Q2, y sabes decir en
  voz alta qué perdiste (no "nada");
- **saber quién manda sobre el estado** cuando el componente y tu Vuex se lo pelean
  (Q3, y no se entiende sin F10);
- **saber migrar con red**: tests de regresión primero, componente después (Q0);
- y **saber convivir**: dos frameworks de UI en el mismo árbol, funcionando. Sin
  disculparse.

Ese híbrido incómodo, mitad Bootstrap mitad Quasar, con un `activityEmitter.js` que
tiene 💸 en la cabecera y una fecha de caducidad — **ahí es donde vas a vivir.**

Ahora ya sabes moverte por ahí.
