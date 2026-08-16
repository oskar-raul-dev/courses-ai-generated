# 🕒 VU4 — Timeline de actividad

> Vuetify puro. Sin traducir nada.
>
> **Consume:** F8 (WebSockets), F10 (criterio de estado), VU1 (theming en JS, `<v-app>`), VU2 (`v-form`, `v-dialog`), VU3 (`v-data-table`, theming aplicado, convivencia Bootstrap).
> **Migra:** nada. Esta feature **no existe** en el curso base.

---

## 🎯 Propósito

> 🔗 **Vienes de VU3**, que cerró migrando el dashboard a `v-data-table` y peleándose
> con Vuex por quién controla la paginación. La última frase de VU3 fue: *"ya migraste
> lo que existía. Ahora te toca construir algo que no existía — Vuetify puro, sin un
> original al que mirar de reojo. Y ahí es donde el theming, que en VU3 solo tocaba
> los badges de una tabla, se convierte en el centro de la fase."* Esta es esa fase.

VU2 y VU3 fueron traducciones: tenías un formulario con vuelidate, te dieron `v-form`
con `:rules`; tenías una tabla con filtro y paginación a mano, te dieron
`v-data-table`. El riesgo de una migración es evidente — se puede aprobar haciendo
*pattern matching*, cambiando `<b-...>` por `<v-...>` sin entender qué hace el
framework por debajo.

Esta fase te quita la muleta. **No hay original que copiar.** Vas a construir un
**timeline de actividad del ticket**: una columna cronológica de quién hizo qué,
cuándo, sobre qué ticket. Se alimenta del **socket de F8**, que hasta ahora solo
servía para un toast que brillaba 5 segundos y moría.

Ese es el segundo objetivo, más de fondo: **aterrizar los WebSockets**. En F8 el
evento en vivo era una notificación — llegaba, brillaba, moría. Aquí el evento
**deja rastro**: se pinta, se acumula, se queda. Es la diferencia entre "me avisan"
y "hay un historial".

**Y aquí el theming se cobra.** En VU3 usaste el tema para pintar cuatro badges de
estado en una tabla. Estaba bien, pero era decorativo — podrías haberlo hecho con
clases de Bootstrap y nadie se habría muerto. En VU4 el tema **es la fase**: el color
de cada entrada del timeline sale del objeto de tema en JS (`primary`, `warning`,
`error`), no de una clase hardcodeada. Cambias el tema en `vuetify.js` → cambia todo
el timeline sin que toques el componente. Y cuando enciendas el **dark mode**, la
mitad de la app que sigue en Bootstrap se va a ver fea de golpe — y eso, lejos de ser
un bug, es la fase enseñándote qué queda sin migrar en tu propio proyecto.

Lo que realmente se aprende:

- `v-timeline` / `v-timeline-item` / `v-chip`: componentes **sin equivalente en
  Bootstrap 4**. No hay nada que borrar — hay algo que no podías tener;
- **el theming en serio**: el color no es un dato del evento, es un *rol semántico*
  (`primary`/`warning`/`error`) que el tema resuelve. Cambiar de tema no toca ni una
  línea del componente. Ese es el diferencial de esta ruta frente a Q4;
- **dark mode como radiografía**: `$vuetify.theme.dark = true` y de repente ves qué
  componentes se adaptan (los de Vuetify) y cuáles se quedan con el fondo blanco
  cristalizado (los `<span class="badge">` de Bootstrap que nunca migraste). Eso es
  convivencia real, no un diagrama;
- el patrón de sockets de F8 **reutilizado sin cambios**: el `socketService` es
  agnóstico — no le importa si quien pinta es Bootstrap, Quasar o Vuetify;
- aplicar **el criterio de F10** a un estado nuevo con la evidencia de esta fase, en
  vez de repetir un veredicto que venía dado.

> La regla de la fase: el color de una entrada es un **rol** (`warning`), no un
> **valor** (`#ff9800`). El rol lo resuelve el tema. Cambia el tema, cambia todo.
> Si escribes un hex, has perdido la fase.

---

## ✅ Qué queda listo al terminar

- colección nueva **`activity`** en `db.json`, con su `activityService.js`;
- componente **`TicketActivity.vue`** (Vuetify puro): `v-timeline` +
  `v-timeline-item`, con `v-chip` coloreado **por el tema** según el tipo de evento;
- integrado en el detalle del ticket, dentro del `<v-app>` de VU1 (obligatorio: sin
  `<v-app>` ancestro, `v-timeline` no calcula bien sus estilos);
- **carga inicial por HTTP** (GET `/activity?ticketId=X&_sort=at&_order=desc`) +
  **actualización en vivo por socket** (`activity:created`);
- emisión desde el front al guardar (F5/VU2) y al cambiar estado (F9): el evento se
  **POSTea** y se **emite**, marcado 💸 como muleta;
- ciclo de vida limpio, patrón F8 **idéntico**: `on` en `mounted`, `off` en
  `beforeDestroy`, handler guardado en el componente (no `.bind` inline);
- **theming demostrado en vivo**: un toggle de dark mode en el header
  (`$vuetify.theme.dark`) que recolorea todo el timeline sin tocar `TicketActivity.vue`
  — y que **revela** qué partes de la app siguen en Bootstrap;
- **decisión de estado documentada**: por qué el timeline es local y no Vuex, con las
  4 preguntas de F10 respondidas por escrito;
- proyecto final: **híbrido** — dashboard y CRUD en Vuetify, el resto en Bootstrap.
  Con eso se cierra la ruta VU.

## 🚫 Qué NO entra

- **generación del historial en el backend** (triggers, event sourcing, outbox): es
  exactamente lo que **falta** y por eso hay 💸;
- timeline global de "toda la actividad del sistema" (ejercicio 🟠 20);
- paginación / *infinite scroll* del historial (ejercicio 🟠 21 con `v-infinite-scroll`
  o `IntersectionObserver`);
- deduplicación fuerte (dos pestañas emitiendo a la vez duplican: ejercicio 🔴 24);
- diffs campo a campo tipo Jira ("descripción: +12 −3 caracteres");
- migrar el tema completo de la app a paleta corporativa (se toca de refilón en el
  ejercicio 🟠 19; el rediseño total es otra vida);
- `v-stepper` **como fase** — se paga como ejercicio 🔴 26 (migrar el wizard de F6).

---

## 🧠 Concepto 1: un timeline no es una lista

Podrías pintar esto con un `<ul>` y quince líneas de CSS. La pregunta legítima es por
qué usar un componente. La respuesta no es "porque es más bonito":

| | `<ul>` a mano (Bootstrap) | `v-timeline` |
|---|---|---|
| Línea vertical y nodos | CSS tuyo (`::before`, `border-left`, `position`) | de fábrica |
| Lado de cada entrada | tú lo calculas | `:side` por item, o alternado automático |
| Densidad | tuyo | `dense` (todo a un lado, compacto) |
| Punto/icono por entrada | tuyo | `<v-timeline-item :icon>` + `:icon-color` |
| **Color del nodo** | **una clase que tú eliges** | **`:color="rol"` → lo resuelve el tema** |
| Modo alternado izq/der | CSS de sufrimiento | de serie |
| Responsive / dark mode | tuyo, y el dark mode **no lo tienes** | de serie, y el dark **cambia solo** |

Lo que compras es **estructura semántica y — la clave de esta ruta — color por rol,
no por valor**. Tus datos tienen que salir en la forma que `v-timeline` espera, y esa
transformación tiene un nombre en Vue 2: **computed** (o un método `meta()`). Guarda
el crudo, pinta el derivado. Misma lección que VU3 con los `headers` de la tabla.

### La anatomía mínima

```
<v-timeline>                    ← el contenedor: dibuja la línea vertical
  ├── <v-timeline-item>         ← un evento: :color, :icon, :icon-color
  │      ├── slot opposite      ← lo que va al OTRO lado (la fecha, típicamente)
  │      └── slot default       ← el cuerpo: aquí van el v-chip y el texto
  └── <v-timeline-item>
```

Fíjate en el slot `opposite`: en un timeline alternado, es lo que aparece enfrentado
al nodo. Lo usaremos para la fecha, y así el cuerpo queda limpio para el `v-chip`.

## 🧠 Concepto 2: `v-chip` — el badge de VU3, coloreado por el tema

En F4 hiciste badges de estado a mano (`<span class="badge badge-danger">`). En VU3
los metiste en el slot `item.status` de `v-data-table`, ya usando el tema. `v-chip`
es el mismo concepto, con más superficie:

```html
<v-chip small label color="warning" text-color="white">
  <v-icon left small>mdi-swap-horizontal</v-icon>
  cambio de estado
</v-chip>
```

Props que vas a usar: `color`, `text-color`, `small`, `label` (esquinas rectas en vez
de píldora), `outlined`, `close` (emite `@click:close`, útil para filtros), `link`.

**⚠️ El detalle que es TODA la fase:** ¿ves que `color="warning"`? No es un color CSS.
Es un **rol del tema**. Vuetify busca `warning` en `theme.themes.light` (o `.dark`) de
tu `vuetify.js` y aplica ese color. Si escribes `color="#ff9800"` **funciona** —
Vuetify sí acepta hex, a diferencia de Quasar — **pero acabas de tirar la fase a la
basura.** Con un hex, cambiar el tema no cambia el chip. Con `warning`, cambias una
línea en `vuetify.js` y **todos** los chips de estado del sistema cambian. Y al
encender el dark mode, `warning` se resuelve a la variante oscura **sola**; el hex se
queda igual de chillón sobre fondo negro.

> Este es el punto donde VU se separa de Q. En Q4, `color="orange"` era la paleta fija
> de Quasar — un valor con otro nombre. En VU4, `color="warning"` es un **rol
> semántico** que el tema resuelve y el dark mode reinterpreta. Mismo componente
> aparente, lección completamente distinta.

## 🧠 Concepto 3: el theming en JS — el diferencial de esta ruta

En VU1 viste el objeto de tema. En VU3 lo rozaste con los badges. Aquí lo exprimes.

Tu `src/plugins/vuetify.js` tiene, desde VU1, algo así:

```js
// src/plugins/vuetify.js
import Vue from "vue";
import Vuetify from "vuetify/lib"; // /lib para a-la-carte (deuda de VU1, pagada en VU3)

Vue.use(Vuetify);

export default new Vuetify({
  theme: {
    dark: false, // ← el interruptor global. Lo vamos a tocar en vivo.
    themes: {
      light: {
        primary: "#1976D2",
        secondary: "#424242",
        accent: "#82B1FF",
        error: "#FF5252",
        info: "#2196F3",
        success: "#4CAF50",
        warning: "#FB8C00"
      },
      dark: {
        // 💡 si no defines dark, Vuetify usa unos por defecto razonables.
        // Definirlo tú es lo que te da control fino sobre el modo oscuro.
        primary: "#2196F3",
        error: "#FF5252",
        info: "#2196F3",
        success: "#4CAF50",
        warning: "#FB8C00"
      }
    }
  }
});
```

Tres cosas que hay que entender de este objeto, porque son la fase:

1. **`primary`, `warning`, `error`... son roles, no colores.** Un color con nombre
   semántico. `error` no es "rojo", es "el color que esta app usa para errores". Que
   hoy sea `#FF5252` es un detalle que vive **aquí y solo aquí**.
2. **`light` y `dark` son dos mapas de los mismos roles.** `warning` existe en ambos.
   Cuando `theme.dark` pasa a `true`, Vuetify resuelve `color="warning"` contra el
   mapa `dark` en vez del `light`. **Tu componente no se entera.**
3. **Nada de esto es CSS que tú escribas.** Vuetify genera las clases (`.warning`,
   `.warning--text`, etc.) a partir de este objeto. Por eso el theming "vive en JS":
   la fuente de verdad del color es un objeto JavaScript, no una hoja de estilos.

**La consecuencia práctica**, y es lo que vas a demostrar en vivo: si tu
`TicketActivity.vue` nunca escribe un color literal — solo roles — entonces **el
componente es inmune al tema**. Cambias `warning: "#FB8C00"` por `warning: "#E65100"`
en `vuetify.js`, recargas, y cada chip de "cambio de estado" del sistema entero cambia
de naranja. Cero ediciones en el componente. Eso es lo que Bootstrap no te daba: allí
el color vivía en la clase (`badge-warning`), pegado al marcado, repetido en veinte
sitios.

### El acceso en runtime: `$vuetify.theme`

Desde cualquier componente:

```js
this.$vuetify.theme.dark          // lee el modo actual (true/false)
this.$vuetify.theme.dark = true   // lo cambia — reactivo, toda la app responde
this.$vuetify.theme.themes.light.warning // lee (o escribe) un rol en caliente
```

Esto último — escribir un rol en runtime — es potente y peligroso a partes iguales.
Lo tocaremos en el ejercicio 🟠 19.

## 🧠 Concepto 4: el modelo `activity`

Colección nueva en el `db.json` del curso (la misma forma que en la ruta Q — el modelo
de datos no depende del framework de UI):

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

Cinco tipos, y solo cinco (`created`, `status_change`, `assigned`, `priority_change`,
`comment`). Fíjate en la forma: **`from`/`to` genéricos**, no un campo distinto por
tipo. Es un evento de dominio pobre, deliberadamente:

- ✅ **Buenas prácticas:** el timeline **no interpreta datos, interpreta eventos.** Si
  mañana el backend añade `type: "reopened"`, el front debe **degradar con dignidad**
  (chip gris, icono genérico), no reventar con un `undefined`. El mapa de tipos siempre
  tiene un `default`. Y ese chip gris usará el rol `grey`... que **también responde al
  dark mode**. Degradar con dignidad incluye degradar sin romper el theming.
- 💸 `from`/`to` como `string | null` para todo (incluido el cuerpo de un comentario)
  es una simplificación fea. En un backend de verdad tendrías un `payload` tipado por
  evento. *"Aquí caben tres tipos en la misma caja; en producción cada evento trae su
  forma."*

## 🧠 Concepto 5: ¿el timeline vive en Vuex? — el criterio de F10, aplicado

Aquí no hay regla, hay **las cuatro preguntas de F10**. Respóndelas antes de leer el
veredicto:

| Pregunta | Timeline de UN ticket | Sesión (F2) | Tickets (F10) |
|---|---|---|---|
| ¿2+ vistas lo consumen? | ❌ solo el detalle | ✅ | ✅ |
| ¿Sobrevive a la navegación? | ❌ y **no quiero**: al cambiar de ticket, muere | ✅ | ✅ |
| ¿Lo mutan varias fuentes? | ✅ **HTTP + socket** | ✅ | ✅ |
| ¿La inconsistencia sería un bug visible? | ❌ nadie más lo ve | ✅ | ✅ |

**1 sí de 4 → local.** El timeline vive en el `data()` del componente, con el mismo
argumento que los **comentarios de F9**: quieres que muera con la vista. Cambias de
ticket, el `:key` renueva el componente, la lista se recarga. Eso no es un fallo: es la
semántica correcta.

El "sí" solitario (multi-fuente) es real y **no es gratis** — es lo que te obliga a
tener dos caminos de escritura al mismo array (`load()` y `onActivity()`), y lo que
crea el riesgo de duplicados del ejercicio 24. Un solo "sí" no es cero.

> **El contra-caso está en el ejercicio 20**: un contador global de "actividad no
> leída" en el header **sí** va al store (2+ vistas ✅, sobrevive a la navegación ✅).
> Mismo dominio, distinto estado, **distinto veredicto**. Eso es criterio y no dogma:
> "el timeline es local" es falso como regla; es verdadero **para este estado**.

> 🔌 **¿Y por qué `activity:created` NO va al `socketPlugin` de F10?** En F10 sacaste
> los handlers de socket de las vistas y los centralizaste en un **plugin de Vuex**
> (`store/plugins/socketPlugin.js`) que escucha `ticket:created`/`ticket:updated` y
> commitea `tickets/UPSERT_TICKET` **una sola vez** para todas las vistas. Ese patrón
> fue correcto **porque los tickets viven en el store**. El timeline **no vive en el
> store** (acabas de decidirlo). Meter `activity:created` en el `socketPlugin` te
> obligaría a subir `entries` a Vuex — justo lo que la tabla dice que **no** hagas — y
> a limpiarlo al cambiar de ticket. **La regla que sale de aquí:** un evento de socket
> va al plugin **si su destino es el store**; si su destino es un componente que muere
> con la vista, se escucha en el componente. `ticket:*` → plugin. `activity:created` →
> componente. Mismo socket, dos destinos, dos sitios. No es incoherencia: es el
> criterio de F10 decidiendo *dónde escuchar*, no solo *dónde guardar*.

---

## 💻 Código

### 1. `db.json` — la colección nueva

Añade `activity` al `db.json` que arrastras desde F3. json-server te regala el CRUD y
los filtros (`?ticketId=1`, `_sort`, `_order`) sin escribir una línea. El backend no
cambia porque cambies el framework de UI — es el mismo `db.json` de la ruta Q, del
tronco, de todo.

### 2. `src/services/activityService.js`

Mismo patrón de F3, misma arquitectura del curso (Componente → Store → services/ →
apiClient → API). **En Vuetify el `apiClient` sigue viniendo de donde siempre**
(`main.js` / `services/apiClient.js`): a diferencia de Quasar, `vue add vuetify` **no
se comió tu `main.js`** (VU1). El servicio es idéntico al de Q4 — y ese es el punto.

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

**🔎 Qué hace:** nada nuevo. Y ese es el punto — **Vuetify no toca la capa de
servicios.** VU1, VU2 y VU3 no cambiaron un solo `service`. El framework es de UI:
llega hasta el `<template>` y ahí se detiene. Si abrieras el `activityService.js` de
la ruta Q al lado de este, serían **idénticos byte a byte**. La UI cambia; los datos,
no.

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

  // 1) persistir  → para el que entre después y haga GET
  // 2) emitir     → para el que YA está mirando el ticket ahora
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
  primero) tienes *optimistic UI*, que es legítimo, pero entonces necesitas **plan de
  rollback**. Aquí no lo tenemos, así que no lo hacemos. Es el ejercicio 🔴 25.

> **Este archivo es idéntico al de Q4.** El emisor no sabe qué framework pinta el
> resultado. Es una prueba más de que la muleta 💸 vive en la capa de datos, no en la
> de UI — y de que el día que el backend genere el historial, se borra igual sin tocar
> Vuetify.

### 4. Dónde se llama a `record()`

En los sitios donde el dominio ya cambia. En el curso base, el cambio de estado y la
asignación pasan por **`ticketService.updateTicket(id, changes)`** (firma de F10). El
sitio limpio para registrar la actividad es **la action de F10
`tickets/updateTicket`**, el único cuello de botella por donde pasan todos los cambios:

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
      var actor = context.rootGetters["auth/currentUser"].username; // getter de F2/F10
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

**⚠️ Por qué en la action y no en el componente — y qué implica para F9:** en F9, el
panel hace el PATCH **desde el componente**, **sin pasar por Vuex**. Si dejas el
registro en la action, **el panel de F9 no registrará nada** hasta que lo reencamines
por `dispatch("tickets/updateTicket", ...)`. Esa reconducción es precisamente **parte
del ejercicio 🔴 de migrar el panel (VU3)** y del ejercicio 10 de esta fase — no es un
descuido, es la deuda de tener dos caminos de escritura al mismo recurso. F10 cobrando
intereses.

> 💡 **Nota de continuidad:** un `changes` puede traer `status` **y** `assignee` a la
> vez (el `takeTicket` de F9 manda los dos). Por eso derivamos **cero, uno o dos**
> eventos del mismo PATCH, no uno fijo por llamada.

### 5. `TicketActivity.vue` — Vuetify puro, color por rol

Aquí está el corazón de la fase. Lee el `TYPE_META` con lupa: **cada `color` es un rol
del tema, no un hex.** Compáralo mentalmente con el de Q4, donde ponía
`color: "orange"` / `"purple"` — colores fijos de la paleta de Quasar. Aquí ponemos
roles semánticos que el tema resuelve y el dark mode reinterpreta.

```vue
<template>
  <!-- Nada de <div class="card"> de Bootstrap: aquí manda <v-card>.
       ⚠️ Este componente ASUME que hay un <v-app> ancestro (VU1). Sin él,
       v-timeline no calcula sus estilos y el detalle es sutil de diagnosticar. -->
  <v-card outlined class="pa-4">
    <div class="d-flex align-center mb-4">
      <span class="text-h6">Actividad</span>
      <v-spacer />
      <v-chip v-if="live" small color="success" text-color="white">en vivo</v-chip>
    </div>

    <!-- 3 estados: loading / error / data. El patrón de F3, intacto -->
    <div v-if="loading" class="py-4">
      <v-skeleton-loader type="list-item-two-line@3" />
    </div>

    <v-alert v-else-if="error" type="error" dense text>
      No se pudo cargar la actividad.
      <template v-slot:append>
        <v-btn small text @click="load">Reintentar</v-btn>
      </template>
    </v-alert>

    <div v-else-if="entries.length === 0" class="text--secondary py-4">
      Sin actividad todavía.
    </div>

    <!-- ⭐ El timeline. dense = todo a un lado, compacto (cabe en la columna del detalle) -->
    <v-timeline v-else dense>
      <v-timeline-item
        v-for="e in entries"
        :key="e.id"
        :color="meta(e.type).color"
        :icon="meta(e.type).icon"
        small
        fill-dot
      >
        <!-- La fecha va enfrentada al nodo. En dense se ve como subtítulo. -->
        <template v-slot:opposite>
          <span class="text-caption text--secondary">{{ formatDate(e.at) }}</span>
        </template>

        <div class="d-flex align-center flex-wrap">
          <!-- ⭐ EL CHIP CLAVE: color = rol del tema. Cambia el tema → cambia esto.
               NUNCA un hex aquí. Si escribes color="#ff9800" pierdes la fase. -->
          <v-chip
            small
            label
            :color="meta(e.type).color"
            text-color="white"
            class="mr-2"
          >
            <v-icon left small>{{ meta(e.type).icon }}</v-icon>
            {{ meta(e.type).label }}
          </v-chip>
          <span class="font-weight-medium">{{ e.actor }}</span>
        </div>

        <div class="text-body-2 mt-1">{{ describe(e) }}</div>
      </v-timeline-item>
    </v-timeline>
  </v-card>
</template>

<script>
import activityService from "../services/activityService";
import socketService from "../services/socketService"; // F8, sin tocar

// ⭐ Mapa de tipos: fuera de data() — es una constante, no estado reactivo.
// (Misma disciplina que el chart de F7 y el socket de F8: lo que no cambia, no reacciona.)
//
// 🎨 LA DECISIÓN DE LA FASE ESTÁ AQUÍ: el `color` es un ROL del tema
// (primary/warning/error/...), NO un hex ni una clase. Vuetify lo resuelve
// contra theme.themes.light — o theme.themes.dark si el modo oscuro está activo.
// Cambiar el look de TODOS los timelines del sistema = editar vuetify.js, no esto.
var TYPE_META = {
  created:         { label: "creado",     color: "primary", icon: "mdi-plus-circle" },
  status_change:   { label: "estado",     color: "warning", icon: "mdi-swap-horizontal" },
  assigned:        { label: "asignado",   color: "info",    icon: "mdi-account-plus" },
  priority_change: { label: "prioridad",  color: "error",   icon: "mdi-priority-high" },
  comment:         { label: "comentario", color: "success", icon: "mdi-comment-text" }
};
// El fallback también usa un rol (grey), no un hex: degrada Y sigue respetando el tema.
var FALLBACK = { label: "evento", color: "grey", icon: "mdi-circle-small" };

export default {
  name: "TicketActivity",

  props: {
    ticketId: { type: [Number, String], required: true }
  },

  data: function () {
    return {
      entries: [],   // 🎯 LOCAL, no Vuex. Ver Concepto 5.
      loading: false,
      error: null,
      live: false,
      onActivityHandler: null // referencia estable para el off(). F8, lección 1.
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
| `TYPE_META` con **roles** (`warning`, `error`...) | ⭐ el corazón de la fase: color = rol del tema, no valor. Cambia `vuetify.js`, cambia todo. El dark mode lo reinterpreta solo |
| `TYPE_META` fuera de `data()` | constante, no estado. Meterla en `data` es hacer reactivo un objeto que nunca cambia |
| `FALLBACK` con `color: "grey"` | el backend puede inventar un `type` mañana. Degradar > reventar — **y sin romper el theming** |
| `entries` en `data()` | **el veredicto del Concepto 5**, escrito en código |
| `onActivityHandler` en `data()` | la referencia **idéntica** que exige el `off()`. `.bind` inline en `on` y otro en `off` = dos funciones = zombis (F8) |
| filtro por `ticketId` en `onActivity` | el socket es global; el componente es de UN ticket |
| `unshift` | método parcheado de Vue 2 → dispara reactividad. `entries[0] = x` **no** (F4) |
| `v-skeleton-loader` en loading | el patrón loading/error/data de F3, con la caja de Vuetify |
| `<v-card outlined>` asume `<v-app>` | VU1: sin `<v-app>` ancestro, los estilos de `v-timeline` fallan de forma sutil |

### 6. Uso desde el detalle (dentro del `<v-app>` de VU1)

```html
<!-- src/views/TicketDetail.vue — TODO cuelga de <v-app> (en App.vue, VU1) -->
<v-container>
  <v-row>
    <v-col cols="12" md="7">
      <!-- 🤝 el formulario de VU2. Firma REAL de F5: prop initialTicket, evento @submit -->
      <ticket-form :initial-ticket="ticket" @submit="onSubmit" @cancel="onCancel" />
    </v-col>
    <v-col cols="12" md="5">
      <!-- :key fuerza el remount al cambiar de ticket: la lista muere y renace. A propósito. -->
      <ticket-activity :key="ticket.id" :ticket-id="ticket.id" />
    </v-col>
  </v-row>
</v-container>
```

### 7. ⭐ El toggle de dark mode — el theming demostrado (y la radiografía)

Esto es lo que Q4 **no tiene** y no puede tener. Un botón en el header que invierte
`$vuetify.theme.dark`. Míralo: no toca `TicketActivity.vue`, no toca `TYPE_META`, no
toca ningún color. Solo cambia un flag global, y **todo el timeline se recolorea solo**
porque sus colores son roles.

```vue
<!-- AppHeader.vue -->
<template>
  <v-app-bar app>
    <v-toolbar-title>Mini Jira</v-toolbar-title>
    <v-spacer />
    <!-- el interruptor. Un flag. Nada más. -->
    <v-btn icon @click="toggleDark" :title="dark ? 'Modo claro' : 'Modo oscuro'">
      <v-icon>{{ dark ? "mdi-weather-sunny" : "mdi-weather-night" }}</v-icon>
    </v-btn>
    <!-- ⚠️ MIRA ESTE de al lado cuando enciendas el dark: es Bootstrap, NO migrado -->
    <span class="badge badge-primary ml-3">v2.6-legacy</span>
  </v-app-bar>
</template>

<script>
export default {
  name: "AppHeader",
  computed: {
    dark: function () {
      return this.$vuetify.theme.dark; // lectura reactiva del flag global
    }
  },
  methods: {
    toggleDark: function () {
      this.$vuetify.theme.dark = !this.$vuetify.theme.dark; // una línea. Toda la app responde.
      // (persistir en localStorage → ejercicio 🟢 5)
    }
  }
};
</script>
```

**🔎 Qué demuestra este botón, en dos actos:**

**Acto 1 — lo que se adapta (la victoria del theming).** Enciende el dark mode. El
`v-card`, el `v-timeline`, cada `v-chip`, los iconos: todo pasa a la variante oscura.
Los chips de `warning`/`error`/`success` siguen siendo naranja/rojo/verde, pero
resueltos contra `theme.themes.dark`. **No tocaste ni una línea del componente.** Ese
es el pago de haber escrito roles en vez de hexes. Si en `TYPE_META` hubieras puesto
`color: "#FB8C00"`, ese chip seguiría igual de chillón sobre el fondo negro, porque un
hex no sabe que existe el dark mode.

**Acto 2 — lo que NO se adapta (la radiografía, la lección de convivencia).** Mira el
resto de la app con el dark encendido. El `<span class="badge badge-primary">` del
header sigue con su fondo azul de Bootstrap sobre... nada, porque Bootstrap no sabe que
hay un modo oscuro. Peor: las pantallas que nunca migraste — el wizard de F6, las
métricas de F7, el modal de Bootstrap — se quedan con **fondo blanco cristalizado** en
mitad de una app oscura. Cajas blancas flotando en negro.

> **Eso no es un bug que tengas que arreglar. Es el mapa de tu propia deuda.** El dark
> mode es una radiografía gratis: enciéndelo y ve **exactamente** qué componentes son
> Vuetify (se adaptan) y cuáles siguen siendo Bootstrap (se quedan blancos). En un
> legacy real a medio migrar, ese contraste te dice de un vistazo cuánto camino queda.
> Y es la razón por la que muchos equipos **no encienden el dark mode hasta terminar la
> migración**: no porque no funcione, sino porque *revela* que no terminaron.

Esta es la diferencia de fondo entre esta ruta y la Q. En Q4, el timeline se ve bien y
punto. En VU4, el timeline se ve bien **y encender un flag te audita el proyecto
entero**. El theming en JS de Vuetify no es "colores más bonitos": es un sistema que
sabe qué está dentro de él y qué se quedó fuera.

### 8. El flujo completo, evento por evento

```
PESTAÑA A (agente1 cambia el estado)          SERVER            PESTAÑA B (mira el mismo ticket)
        │                                        │                        │
1. click en "En progreso"                        │                        │
        │                                        │                        │
2. dispatch("tickets/updateTicket", {id:1, changes:{status:"in_progress"}})
        │                                        │                        │
3. PATCH /tickets/1 ────────────────────► json-server (:3000)             │
        │◄──────────────── 200 {..., status:"in_progress"}                │
        │                                        │                        │
4. commit("UPSERT_TICKET") → la v-data-table de VU3 se repinta (Vuex)     │
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
        │                                        │      🎨 v-timeline-item nuevo, arriba
        │                                        │         con :color="warning" → lo resuelve
        │                                        │         el tema ACTIVO de esa pestaña.
        │                                        │         (¡si B tiene dark, sale en variante oscura!)
        │                                        │
   (A no recibe el broadcast — ya lo tiene       │
    del .then del POST. Cero duplicados.)        │

⚠️ Detalle bonito del theming: el MISMO evento, pintado en A (claro) y en B (oscuro),
   sale con el rol `warning` resuelto DISTINTO en cada pestaña. El dato viaja igual;
   el color lo decide el tema local. Eso es color-por-rol trabajando de verdad.
```

---

## ⚠️ Errores comunes

- **`color="#FB8C00"` en un `v-chip` "porque Vuetify acepta hex"** → funciona, y por
  eso es la trampa más peligrosa de la fase. Cambia el tema: el chip no cambia. Enciende
  el dark mode: el chip se queda chillón. **Un hex es un color; un rol es una decisión.**
  Si escribiste hexes, tu componente no es *themable* aunque parezca que va bien.
- **Timeline sin `<v-app>` ancestro** → los estilos de `v-timeline` fallan de forma
  sutil (la línea vertical desaparece o se descoloca) y **no hay error en consola**. El
  clásico de VU1, tercera víctima. Si montas `TicketActivity` en un test aislado, tienes
  que envolverlo en `<v-app>` — exactamente el problema que VU0 te avisó (`mount()` roto
  por `v-app`).
- **`v-skeleton-loader` no registrado / a-la-carte mal configurado** → no renderiza y
  no avisa. Si hiciste el a-la-carte de VU3 (ejercicio del bundle), asegúrate de que los
  componentes nuevos (`VTimeline`, `VTimelineItem`, `VChip`, `VSkeletonLoader`) entran.
- **No filtrar por `ticketId`** en el handler del socket → ves en el timeline del ticket
  1 los eventos del ticket 7. Y lo peor: **parece** que funciona hasta que hay dos
  usuarios trabajando a la vez.
- **`.bind(this)` distinto en `on` y `off`** → el `off` no desuscribe nada. Navegas
  entre 3 tickets y el cuarto evento aparece 3 veces. **Zombis de F8, capítulo dos.**
- **`entries[0] = nueva`** en vez de `unshift` → Vue 2 no lo detecta. No es un bug de
  Vuetify: es F4 volviendo a cobrar.
- **Emitir sin persistir** ("total, el otro ya lo ve") → el que entre después hace GET y
  no encuentra nada. El evento existió 5 segundos en dos navegadores.
- **Registrar la actividad en el componente** en vez de en la action → el día que la
  `v-data-table` de VU3 permita editar inline, ese cambio no deja rastro. Silencioso.
- **`at` con `new Date()` del cliente** → dos usuarios con relojes distintos y el
  timeline se desordena. 💸 declarada abajo, no accidente.
- **Meter `entries` en Vuex "por si acaso"** → ahora tienes que limpiarlo al salir, o el
  timeline del ticket 3 arranca con los eventos del ticket 1. Lo que sube al store, hay
  que bajarlo.
- **Escribir `theme.themes.light.warning = ...` en runtime sin pensar** (ejercicio 19) →
  es reactivo y global; tocas un rol y cambias **todos** los componentes que lo usan en
  toda la app, no solo tu timeline. Potente, pero un cuchillo sin mango.

---

## 💸 Deuda: el historial lo genera el BACKEND

**Lo que hicimos:** el front, al guardar, hace un `POST /activity` y emite un socket.
**Lo que se hace en producción:** nada de eso.

Un historial de actividad es un **subproducto del dominio**, no una petición del front.
Se genera donde ocurre el cambio:

| Mecanismo | Dónde vive | Cómo llega al front |
|---|---|---|
| Triggers de BD (`AFTER UPDATE ON tickets`) | la base | el front hace GET y ya está ahí |
| Eventos de dominio / CQRS | la capa de aplicación | el backend publica al bus y de ahí al socket |
| Outbox pattern | tabla + relay | igual, pero **transaccional** |

**Los tres agujeros de nuestra versión, sin maquillaje:**

1. **Se puede saltar.** Un `curl -X PATCH /tickets/1` cambia el estado y **no deja
   rastro**. Nuestro historial solo registra lo que pasa por nuestra UI. Un historial
   que se puede evitar **no es un historial**, es un log de la UI.
2. **No es atómico.** El `PATCH` puede tener éxito y el `POST /activity` fallar. Te queda
   un cambio sin historia. Con un trigger o un outbox, o van los dos o no va ninguno.
3. **El reloj es del cliente.** `new Date().toISOString()` en el navegador. Dos agentes
   con la hora mal puesta y tu cronología es ficción. En el backend, el timestamp lo pone
   el servidor y punto.

> 💸 **La frase:** *"Aquí lo emitimos desde el front al guardar; en producción eso llega
> solo, y el front solo lo pinta."*

**Y esto es lo importante para tu trabajo:** el `TicketActivity.vue` que escribiste **no
cambia** el día que el backend haga bien su trabajo. Sigue haciendo GET, sigue escuchando
`activity:created`, sigue coloreando por rol. Lo que se **borra** es el
`activityEmitter.js` y las llamadas a `record()` en las actions. Ese archivo tiene 💸 en
la cabecera **por eso**: está marcado para morir. La feature está bien construida; la
muleta está señalizada.

*(Simular un backend decente es el ejercicio 🔴 25.)*

---

## 🧪 Ejercicios (27)

**🟢 Fácil (1–8)**

1. Añade `activity` a tu `db.json` con al menos 6 eventos de 2 tickets distintos.
   Verifica en el navegador que `GET /activity?ticketId=1&_sort=at&_order=desc` devuelve
   lo que esperas, **antes** de escribir una línea de Vue.
2. Quita `dense` del `<v-timeline>` y añade un ancho suficiente: mira el modo alternado
   (izquierda/derecha automático) y cómo el slot `opposite` pasa a estar enfrentado de
   verdad. Captura ambos. Elige uno para la columna del detalle y **di por qué en un
   comentario** (pista: el ancho que tienes manda).
3. Añade un sexto tipo, `reopened`, al `TYPE_META` con `color: "secondary"` e icono
   `mdi-replay`. Verifica primero que **sin** añadirlo el chip sale gris (`FALLBACK`) y
   no revienta. Luego enciende el dark mode y comprueba que `secondary` también se
   adapta: acabas de confirmar que hasta el tipo nuevo respeta el tema.
4. Cambia en `vuetify.js` el valor de `warning` (de `#FB8C00` a `#E65100`, un naranja más
   oscuro). Recarga. Cuenta cuántos archivos tuviste que tocar para que **todos** los
   chips de "cambio de estado" del sistema cambiaran. (Respuesta esperada: uno, y no es
   `TicketActivity.vue`.) Escribe la cifra en un comentario. Este ejercicio **es** la
   fase en tres minutos.
5. Persiste el modo oscuro: en `toggleDark`, guarda el flag en `localStorage`, y léelo al
   arrancar la app (en `App.vue`, `created`, aplicándolo a `this.$vuetify.theme.dark`).
   Recarga con dark activo y verifica que sigue oscuro.
6. Sustituye el `toLocaleString()` por un formato relativo ("hace 5 min") con una función
   tuya, sin librerías. ⚠️ Ojo: no es reactivo — no se refresca solo. Documenta el
   problema, **no lo arregles** (es el ejercicio 12).
7. Añade un `<v-avatar>` pequeño con las iniciales del `actor` junto al chip. Dale color
   con un **rol** derivado del nombre (hash simple → índice en `["primary","info",
   "success","warning","error"]`). Enciende el dark: comprueba que los avatares también
   cambian. Si hubieras usado hexes, no cambiarían — anótalo.
8. Fuerza el estado de error: apaga json-server, recarga el detalle. Comprueba que ves el
   `<v-alert type="error">` y que "Reintentar" funciona **con el servidor ya encendido de
   nuevo**. Fíjate: el `type="error"` del alert **también** sale del tema — el rojo del
   error y el rojo del chip `priority_change` son el mismo rol.

**🟡 Intermedio (9–17)**

9. **Agrupa por día.** Inserta un separador de fecha ("10 mar 2020") cada vez que cambia
   el día. Pista: no toques `entries` — es la fuente cruda. Hazlo en un **computed** que
   devuelva la lista ya intercalada con marcadores, y píntalos con `<v-subheader>` o un
   `v-timeline-item` con `hide-dot`. *(Esto es "guarda el crudo, pinta el derivado" del
   Concepto 1, en la práctica.)*
10. Registra `priority_change` (F5/VU2) y `assigned` (F9) además de `status_change`.
    ¿Dónde metes la llamada a `record()`? Justifica por qué **no** en el componente.
11. Emite `comment` desde el panel de soporte (F9) al añadir un comentario. Nota que
    ahora el comentario vive en **dos sitios**: `comments` y `activity`. ¿Es duplicación
    o son cosas distintas? Escribe tu respuesta en 3 líneas.
12. Haz que el "hace 5 min" del ejercicio 6 **sí** se refresque: un `setInterval` de 60s
    en `mounted` que incrementa un contador en `data`, del que depende el computed. ⚠️ Y
    su `clearInterval` en `beforeDestroy` — **F7 y F8, misma lección, tercera vez.**
13. **Filtro de tipos con chips.** Una fila de `<v-chip>` con `filter` + `outlined`
    arriba del timeline, que filtra las entradas visibles. Colorea cada chip de filtro
    con el rol de su tipo (reutiliza `TYPE_META`). ¿El estado del filtro va a `data` o a
    Vuex? Aplica las 4 preguntas de F10 y **escribe la tabla**.
14. `<v-chip close>` con `@click:close`: haz que los chips de filtro activos se puedan
    quitar uno a uno. Compara la ergonomía con el `filter` del ejercicio 13.
15. Deja el `TicketActivity` **abierto** en una pestaña y cambia el estado desde otra.
    Ahora **para el socket server** y repite. Documenta exactamente qué ve el usuario
    (spoiler: el POST funciona, el timeline de la otra pestaña no se entera hasta
    recargar). ¿Es aceptable? ¿Qué le dirías al usuario? Muestra el estado con el chip
    "en vivo" cambiando de `success` a `error` (¡otro rol!).
16. **Rompe el `<v-app>` a propósito.** Monta `TicketActivity` en una vista que NO cuelgue
    de `<v-app>` (o quita el `<v-app>` de `App.vue` un momento). **Documenta el síntoma
    exacto** (qué ves, qué NO dice la consola, cuánto tardarías en diagnosticarlo si no
    supieras la causa). Restaura. Este ejercicio vale por diez lecturas de VU1 — y es el
    gemelo del "componente no declarado" de Q4, pero con la trampa propia de Vuetify.
17. Reemplaza los `v-skeleton-loader` por un `<v-progress-linear indeterminate>` sobre la
    card mientras `loading`. Coloréalo con `color="primary"`. Compara UX: ¿cuál miente
    menos sobre cuánto queda? ¿Cuál respeta mejor el dark mode?

**🟠 Difícil (18–23)**

18. **Rooms por ticket.** Ahora cada `activity:created` viaja a **todos** los clientes, y
    el 95% se descarta en el `if` del handler. Implementa `join`/`leave` de una room
    `ticket:<id>` en `mounted`/`beforeDestroy` (patrón del ejercicio 19 de F8) y emite con
    `io.to("ticket:" + id).emit(...)`. Verifica con 3 pestañas en 2 tickets distintos que
    el tráfico baja. **Y la pregunta buena:** ¿puedes borrar el `if` del handler?
    ¿Deberías?
19. **⭐ Theming en runtime — el poder y el peligro.** Añade un `<v-color-picker>` en una
    pantalla de ajustes que escriba `this.$vuetify.theme.themes.light.primary` en caliente.
    Cambia el primary y mira: **cada** componente que usa `primary` en toda la app cambia
    al instante, incluido tu timeline, sin recargar. Ahora la parte difícil: (a) explica
    en 5 líneas por qué esto es a la vez la mayor virtud y el mayor riesgo del theming en
    JS; (b) ¿qué pasa con el modo oscuro — tocaste `light`, no `dark`? (c) ¿esta
    preferencia de tema va a Vuex? Aplica las 4 preguntas.
20. **El contra-caso del store.** Contador de "actividad no leída" en el header (un
    `<v-badge>` sobre el icono de campana), que cuenta eventos de tickets **que no estás
    mirando**. Aplica las 4 preguntas: **este sí va a Vuex** (2+ vistas ✅, sobrevive a la
    navegación ✅). Implementa el módulo. Y explica en un comentario por qué el timeline
    **no** va y este **sí**, siendo el mismo dominio. *(Este ejercicio es el que demuestra
    que "el timeline es local" era criterio, no dogma.)*
21. **Timeline global.** Una vista `/activity` con la actividad de **todos** los tickets,
    con `<v-select>` de filtro por actor y por tipo. Reutiliza `TicketActivity.vue` sin
    duplicarlo: extrae un componente presentacional (recibe `entries` por prop, no hace
    fetch ni escucha nada) y dos contenedores. Es la prueba de fuego de si tu componente
    estaba bien diseñado.
22. **Paginación / scroll infinito.** Un ticket con 300 eventos carga 300 items. Pagina
    con `_page` y `_limit` de json-server, disparando la carga con un `IntersectionObserver`
    al final de la lista (o `v-intersect`). 💸 Ojo: el evento en vivo llega **arriba**
    mientras tú paginas **hacia abajo**. ¿Se rompe algo?
23. **Detección de cambios sin trigger.** Un `curl -X PATCH` cambia un ticket y no deja
    rastro (agujero #1 de la deuda). Escribe un test (Jest, F11/VU0) que lo **demuestre**:
    PATCH directo → GET `/activity` → assert de que **falta** el evento. Un test que
    documenta una deuda vale más que un párrafo.

**🔴 Muy difícil (24–27)**

24. **Duplicados por concurrencia.** Abre 2 pestañas del **mismo** usuario en el **mismo**
    ticket y haz que ambas emitan casi a la vez. Reproduce el duplicado. Ahora arréglalo:
    ¿deduplicas por `id` en el `unshift`? ¿O el problema real es que **el front no debería
    emitir**? Argumenta las dos, elige una, y **enlázalo con la deuda 💸.**

25. **Paga la deuda 💸: mueve la generación al backend.** Escribe un middleware en el mini
    servidor de Node (el de F8, ampliado) que **intercepte** los PATCH a `/tickets`,
    compare el estado anterior con el nuevo y genere él mismo el registro de `activity` +
    el emit del socket. Después **borra** `activityEmitter.js` y todas las llamadas a
    `record()` de tus actions.

    Los tres criterios de aceptación, y son duros:
    - un `curl -X PATCH` **sin pasar por la UI** deja rastro en el timeline;
    - el `at` lo pone el **servidor**, no el cliente;
    - `TicketActivity.vue` **no se toca ni una línea** — ni siquiera los roles de color.

    Si el tercero falla, tu componente estaba acoplado a la muleta. Ese es exactamente el
    diagnóstico que esta fase quería enseñarte a hacer.

26. **🔀 MIGRACIÓN TRANSVERSAL — el wizard (F6) a `v-stepper`.**

    Migra el wizard de alta de ticket en 3 pasos (F6) a `<v-stepper>`, **reutilizando los
    `v-form` de VU2**. Sin guía. Escribe primero los tests de regresión (VU0).

    > 💡 **Por qué esto es un ejercicio y no una fase:** `v-stepper` **no es un componente
    > de formularios** — es de **navegación por pasos**. El `v-form` de dentro lo montas
    > exactamente igual que en VU2. Llegas ya sabiendo `v-form` + `:rules`; lo único nuevo
    > que tienes que resolver es la **navegación**. Dártelo masticado enseñaría menos que
    > pelearte con ello.

    Lo que te vas a encontrar (y no te vamos a decir cómo se arregla):

    - `<v-stepper>` + `<v-stepper-step :complete :rules>` + `<v-stepper-content>`, con
      `v-model` del paso actual;
    - **la pregunta de la fase:** el botón "Continuar" vive en el `v-stepper-content`,
      pero la validación vive en el `v-form` de dentro. ¿Quién le pregunta a quién?
      - ¿El stepper llama a `this.$refs["form" + n].validate()` (que en Vuetify devuelve
        **booleano**, no promesa — a diferencia del `QForm` de Quasar, ojo con esa
        diferencia) antes de avanzar?
      - ¿O cada `v-form` mantiene `v-model="valid"` y el stepper solo mira ese flag?
      - **Ninguna es "la correcta".** Elige, impleméntala, escribe en 5 líneas qué acoplas
        en cada caso.
    - `<v-stepper-step :rules="[...]">` puede pintar el paso en rojo (estado de error del
      propio step). ¿Lo usas, o dejas la validación solo en el form? ¿Duplicas?
    - **`keep-alive` (F6) vuelve a la mesa:** el `v-stepper` **no** cachea los
      `v-stepper-content` por defecto igual que tu `<keep-alive>` — investiga qué monta y
      qué desmonta al cambiar de paso. ¿Sobra tu `keep-alive`? ¿Sobrevive el `valid` de
      cada form al ir y volver?
    - **La decisión de F6 vuelve:** ¿el borrador vive en el componente o en el store? Con
      `v-stepper` montando/desmontando pasos, **¿cambia tu respuesta?** Si cambia, di por
      qué. Si no, di por qué tampoco.
    - Y una que muerde: `v-stepper` puede navegar **hacia atrás** (`editable`). ¿Qué pasa
      con la validación de un paso que ya pasaste y ahora vuelves a romper?

    **Criterio de terminado:** los tests de regresión que escribiste **antes** siguen
    verdes, sin tocarlos.

27. **⭐ Auditoría de tema — la radiografía convertida en herramienta.** Escribe una
    pequeña vista `/theme-audit` que, con el dark mode encendido, te ayude a **listar** qué
    componentes de la app no se adaptan. Pista de implementación honesta: no hay una API
    mágica que diga "esto es Bootstrap". Tienes que decidir un método — por ejemplo,
    recorrer el proyecto y grepear `class="badge` / `class="btn ` / `class="alert` (marcas
    de Bootstrap) vs `<v-`. Entrégalo como un **checklist en Markdown**
    (`THEME-DEBT.md`) con la lista de pantallas aún-Bootstrap y, al lado, el componente
    Vuetify que las reemplazaría. **Este documento es tu plan de migración del resto del
    proyecto** — y lo generaste porque el dark mode te enseñó dónde mirar. Cierra el
    círculo de la fase: el theming no solo pinta, **audita**.

---

## 📚 Referencias

> ⚠️ **`vuetifyjs.com` (dominio raíz) sirve la documentación de v3 (Vue 3) por defecto.**
> Necesitas la **v2**: usa **`v2.vuetifyjs.com`**. Comprueba siempre que la URL empieza
> por `v2.` — si el ejemplo usa Composition API o `createVuetify`, estás en la versión
> equivocada.

**Documentación oficial (Vuetify 2)**

- v-timeline: https://v2.vuetifyjs.com/en/components/timelines/
- v-chip: https://v2.vuetifyjs.com/en/components/chips/
- v-card: https://v2.vuetifyjs.com/en/components/cards/
- v-skeleton-loader: https://v2.vuetifyjs.com/en/components/skeleton-loaders/
- v-alert: https://v2.vuetifyjs.com/en/components/alerts/
- **Theme (el corazón de la fase):** https://v2.vuetifyjs.com/en/features/theme/
- **Dark mode:** https://v2.vuetifyjs.com/en/features/theme/#dark-mode
- Iconos MDI (por defecto): https://v2.vuetifyjs.com/en/features/icon-fonts/
- v-stepper (ejercicio 26): https://v2.vuetifyjs.com/en/components/steppers/
- v-color-picker (ejercicio 19): https://v2.vuetifyjs.com/en/components/color-pickers/
- v-badge (ejercicio 20): https://v2.vuetifyjs.com/en/components/badges/

**Del curso base (repasa antes de empezar)**

- socket.io 2.x — cliente (`on`/`off`/`emit`): https://socket.io/docs/v2/client-api/
- socket.io 2.x — rooms (ejercicio 18): https://socket.io/docs/v2/rooms/
- Vue 2 — métodos de array parcheados (`unshift`):
  https://v2.vuejs.org/v2/guide/list.html#Mutation-Methods
- Vue 2 — `:key` para forzar remount: https://v2.vuejs.org/v2/api/#key
- json-server — filtros, `_sort`, `_page`: https://github.com/typicode/json-server#filter

**Contexto (la deuda 💸, para entender qué falta de verdad)**

- Martin Fowler — Domain Event: https://martinfowler.com/eaaDev/DomainEvent.html
- microservices.io — Transactional Outbox:
  https://microservices.io/patterns/data/transactional-outbox.html

**Orden de lectura sugerido:** Theme (léelo entero, es la fase — 15 min bien
invertidos) → v-timeline (solo los ejemplos) → Dark mode → volver al código. Fowler solo
si vas a hacer el 25.

---

## 🚀 Cierre — y cierre de la ruta VU

Construiste algo que **no existía**. Sin original que traducir, sin `v-data-table` al que
mirar de reojo. Te llevas:

- `v-timeline` / `v-timeline-item` / `v-chip`: componentes **sin equivalente Bootstrap**
  — no todo en un framework es "lo que ya tenías, pero con otro nombre";
- **el theming en JS de verdad**, que es lo que esta ruta tiene y la de Quasar no en la
  misma medida: el color es un **rol**, no un valor; el rol lo resuelve el tema; el dark
  mode reinterpreta el rol **solo**; y tu componente, si lo escribiste con roles, es
  inmune a todo eso;
- **el dark mode como radiografía**: un flag que audita tu proyecto entero y te dibuja el
  mapa de lo que sigue en Bootstrap — cajas blancas flotando en negro que son, literalmente,
  tu deuda de migración hecha visible;
- el patrón de sockets de F8 **reutilizado tal cual**: el `socketService` no se enteró de
  que cambiaste de framework, porque **no tenía por qué**;
- el criterio de F10 aplicado a un caso nuevo — y su contra-caso en el mismo dominio (el
  timeline es local, el contador global es del store);
- y una deuda 💸 que sabes **exactamente cómo se paga**: borrando un archivo.

La señal de que quedó bien:

> "cambio un color en `vuetify.js` y todos los timelines del sistema cambian, sin tocar el
> componente. Enciendo el dark mode y veo de un vistazo qué me falta por migrar. Y el día
> que el backend genere el historial de verdad, borro `activityEmitter.js` y el componente
> no se toca."

---

### 🏁 Y con esto termina la ruta VU. Mira lo que tienes.

Abre el proyecto. El dashboard es `v-data-table`. El CRUD es `v-form` dentro de un
`v-dialog`. El timeline es `v-timeline`, coloreado por el tema. **Y el wizard sigue siendo
Bootstrap. Y las métricas de F7 siguen siendo un `<canvas>` con chart.js. Y hay un
`<b-modal>` conviviendo con `<v-dialog>` en el mismo árbol.** El `.row` de Bootstrap y el
`.row` de Vuetify se pisan, y tú sabes exactamente dónde y por qué.

Ahora enciende el dark mode una última vez. La mitad Vuetify se vuelve oscura, elegante,
coherente. La mitad Bootstrap se queda con sus cajas blancas cristalizadas en mitad de la
noche. **Esa foto — mitad adaptada, mitad no — es el entregable.** No es un curso a medio
terminar: es el estado real de un legacy a medio migrar, y el dark mode te lo dibuja sin
que tengas que buscarlo.

Nadie migra un legacy de golpe. Se migra la pantalla que duele, se deja la que funciona, y
el proyecto **vive años en ese estado intermedio**. Un curso que terminara con el 100% en
Vuetify te estaría mintiendo sobre tu trabajo.

Lo que de verdad te llevas de la ruta VU no es `v-data-table`. Es esto:

- **saber qué es Vue y qué es Vuetify** cuando abres un `.vue` ajeno — y saber que Vuetify,
  a diferencia de Quasar, **no** se comió el `main.js`, así que la frontera es más fácil de
  ver;
- **saber que el color es una decisión, no un dato**: roles semánticos, tema en JS, dark
  mode gratis — la lección que Bootstrap, con su color pegado a cada clase, no podía
  enseñarte;
- **saber qué te ha quitado**: vuelidate salió del proyecto en VU2, y sabes decir en voz
  alta qué perdiste (no "nada");
- **saber quién manda sobre el estado** cuando el componente y tu Vuex se lo pelean (VU3, y
  no se entiende sin F10);
- **saber migrar con red**: tests de regresión primero, componente después (VU0);
- y **saber convivir**: dos frameworks de UI en el mismo árbol, funcionando — y un flag que
  te dice, sin pedirlo, cuánto de esa convivencia sigue pendiente.

Ese híbrido incómodo, mitad Bootstrap mitad Vuetify, con un `activityEmitter.js` que tiene
💸 en la cabecera y una fecha de caducidad, y un dark mode que ilumina lo que falta — **ahí
es donde vas a vivir.**

Ahora ya sabes moverte por ahí. Y sabes encender la luz.
