# 📋 Fase VU3 — Migrar el dashboard a v-data-table

> El componente quiere el estado que tu Vuex ya controla. **¿Quién manda?**

**Migra:** F4 (Dashboard) · **Consume en tensión directa:** F10 (Vuex)
**Prerequisitos:** VU0 (red de seguridad), VU1 (leer Vuetify), VU2 (CRUD → v-form)

---

## 🎯 1. Propósito

Esta es **la fase núcleo de la ruta VU**. Como en Q3, pasan dos cosas a la vez, y
la segunda es la que importa. Pero la manera en que Vuetify plantea la tensión es
**suya**: no es `QTable` con otro nombre. La API que vas a pelear es
`:options.sync` + `:server-items-length`, no `:pagination.sync` + `rowsNumber`. Y
antes de terminar vas a hacer algo que en Quasar no tocaste: **conectar los badges
de F4 al tema en JS**, para que cambiar el tema cambie los colores de la tabla. Eso
es diferencial de esta ruta y va aquí.

Lo primero es un **borrado**. El dashboard de F4 tiene filtro manual, orden manual
y (si hiciste el ejercicio 🔴 24 de F4) paginación manual. `v-data-table` trae las
tres de fábrica. Vas a borrar ~150 líneas de código tuyo, funcionando y probado.
Debe sentirse raro. Es la primera señal de que estás cediendo control.

Lo segundo es un **conflicto de propiedad**. `v-data-table` no es un `<table>` con
estilos Material: es un componente **con estado propio**. Su objeto `options` sabe
en qué página estás, por qué columna ordenas y en qué dirección. Tu store de F10
**también** tiene opinión — o mejor: en F10 auditaste qué estado vive en Vuex y qué
no, y lo defendiste por escrito.

Ahora llega un componente de terceros con su propia idea de dónde vive el estado de
la tabla. **No puedes tener las dos.** O cedes el control a `v-data-table`, o se lo
quitas y lo devuelves al store. Ambas se pagan. Esto no es configuración: **es la
fase entera.**

---

## ✅ 2. Qué queda listo al terminar

- `TicketsView` renderizando un **`v-data-table`** con `headers`, `items`,
  `item-key`.
- El **filtro, el orden y la paginación manuales de F4: borrados.** Sin sustituto
  propio. El componente los hace.
- Los **badges de estado y prioridad de F4 dentro de la tabla**, montados vía el
  slot `item.status` / `item.priority`. Pero **ya no con clases Bootstrap
  hardcodeadas**: pintados con **colores del tema** (`v-chip :color`). Cambia el
  tema → cambian los badges. Enlaza con VU1.
- El dashboard funcionando en **modo cliente** (`v-data-table` pagina en memoria)
  **y** en **modo server-side** (`:server-items-length`, `@update:options`,
  `:loading`) — con la decisión de cuál usar tomada y defendida.
- Una **decisión escrita** sobre quién es el dueño del estado de la tabla:
  `v-data-table` (su `options`) o Vuex. Con sus costes. Al estilo de la auditoría
  de F10.
- **Bootstrap y Vuetify conviviendo en la misma vista**: `v-data-table` arriba, el
  modal Bootstrap de crear ticket abajo, emitiéndose eventos entre sí. Funcionando.
- El **`.row` de tres colisiones demostrado** (Bootstrap 4 / Vuetify 2 / Vuetify 1).
- Los **tests de regresión de VU0 pasando** — o rotos con motivo entendido.
- El mapeo del **`X-Total-Count`** de json-server a `serverItemsLength` 💸.

---

## 🚫 3. Qué NO entra todavía

- **Componentes nuevos que no existían**: eso es VU4 (el timeline). Aquí solo se
  traduce lo que ya funcionaba.
- **Selección múltiple** (`show-select`, `v-model` de selección) — ejercicio 🟠. El
  Mini Jira no tiene acciones en lote.
- **Expansión de filas** (`show-expand`, slot `expanded-item`) — ejercicio 🟡.
- **Agrupar por columna** (`group-by`, slot `group.header`) — se menciona, no se
  implementa. Aparece con datos jerárquicos; el Mini Jira es plano.
- **Virtual scroll** (`v-virtual-scroll`, `v-data-table-virtual` es v3) — fuera. Tú
  tienes 40 filas.
- **Migrar el panel de soporte (F9)**: es el ejercicio 🔴 obligatorio del final. Tú
  solo. Sin guía.
- **Quitar Bootstrap del proyecto.** No se va. Aquí aprendes a vivir con él.
- **Configurar a-la-carte / medir el bundle**: es el otro ejercicio 🔴, y paga la
  deuda 💸 de VU1. No es contenido guiado — es tu deber.

---

## 🧠 4. Concepto

### 4.1 El borrado: qué hacía F4 y quién lo hace ahora

Recordemos el dashboard de F4 (versión post-F10, con el store ya montado). En F4 el
componente era la vista orquestadora con `search`, `statusFilter` y `filteredTickets`
en local; si hiciste el ejercicio 🔴 24, además tenías orden y paginación a mano:

```js
// F4 + F10 — TicketsView.vue (lo que hay HOY, antes de tocar nada)
export default {
  data: function () {
    return {
      search: "",           // ← decisión de F10: NO va al store (la URL lo expresa mejor)
      statusFilter: "",     // ← decisión de F10: NO va al store
      sortKey: "createdAt", // ← el orden manual (ej. 🟠 18 de F4)
      sortOrder: "desc",
      page: 1,              // ← la paginación manual (ej. 🔴 24 de F4)
      perPage: 10
    };
  },

  computed: {
    ...mapGetters("tickets", ["allTickets"]),

    // 1. FILTRAR — ~15 líneas
    filteredTickets: function () {
      var self = this;
      var term = this.search.trim().toLowerCase();
      return this.allTickets.filter(function (t) {
        var matchesText = !term || t.title.toLowerCase().indexOf(term) !== -1;
        var matchesStatus = !self.statusFilter || t.status === self.statusFilter;
        return matchesText && matchesStatus;
      });
    },

    // 2. ORDENAR — ~12 líneas
    sortedTickets: function () {
      var self = this;
      var copy = this.filteredTickets.slice(); // sort muta: copia SIEMPRE
      copy.sort(function (a, b) {
        var av = a[self.sortKey];
        var bv = b[self.sortKey];
        if (av === bv) { return 0; }
        var result = av > bv ? 1 : -1;
        return self.sortOrder === "asc" ? result : -result;
      });
      return copy;
    },

    // 3. PAGINAR — ~8 líneas
    pagedTickets: function () {
      var start = (this.page - 1) * this.perPage;
      return this.sortedTickets.slice(start, start + this.perPage);
    },

    totalPages: function () {
      return Math.ceil(this.sortedTickets.length / this.perPage) || 1;
    }
  },

  methods: {
    // 4. CAMBIAR EL ORDEN AL CLICAR CABECERA — ~8 líneas
    toggleSort: function (key) {
      if (this.sortKey === key) {
        this.sortOrder = this.sortOrder === "asc" ? "desc" : "asc";
      } else {
        this.sortKey = key;
        this.sortOrder = "asc";
      }
      this.page = 1; // ← el bug clásico: si no reseteas, te quedas en la página 7 de 2
    },

    goToPage: function (n) {
      if (n < 1 || n > this.totalPages) { return; }
      this.page = n;
    }
  },

  watch: {
    // 5. RESETEAR PÁGINA AL FILTRAR — el otro bug clásico
    search: function () { this.page = 1; },
    statusFilter: function () { this.page = 1; }
  }
};
```

Más el template: la `<table class="table">` de Bootstrap, las cabeceras clicables
con flechas `▲▼`, el `<nav>` de paginación con `<li class="page-item">`… otras ~60
líneas.

**Total: ~150 líneas.** Filtro, orden, paginación, los dos watchers anti-bug y el
markup.

De todo eso, `v-data-table` hace:

| Lo que tenías en F4 | Quién lo hace en Vuetify |
|---|---|
| `filteredTickets` (computed) | prop `:search` + filtro built-in |
| `sortedTickets` (computed) | `headers[].sortable` + `options.sortBy` |
| `pagedTickets` (computed) | paginación interna (`options.page`, `options.itemsPerPage`) |
| `totalPages` (computed) | footer interno |
| `toggleSort()` | click en la cabecera. Gratis. |
| `goToPage()` | los botones del footer. Gratis. |
| `watch: search → page = 1` | **`v-data-table` lo hace solo.** El bug no existe. |
| `<table>` + `<nav>` de Bootstrap | `<v-data-table>` |

**El borrado neto es real.** No es "escribes menos". Es: **borras código que
funcionaba, borras sus bugs, y borras los watchers que parcheaban esos bugs.**

> 🔎 **Lo que se va contigo:** también se va tu control. Ese `page = 1` del watcher
> lo escribiste **porque un tester lo reportó**. `v-data-table` lo hace por defecto.
> Genial — hasta el día que **no** quieras resetear la página al filtrar (paginación
> server-side donde el filtro viaja aparte, por ejemplo). Entonces vas a pelearte
> con el `@update:options` para deshacer un comportamiento que ni pediste ni ves.

### 4.2 `v-data-table`: headers, items, item-key

Tres props que en la práctica siempre están:

```js
// El contrato mínimo de v-data-table
{
  items: Array,      // los datos. Uno por fila.
  headers: Array,    // la definición de columnas. NO es markup: es un objeto.
  "item-key": String // qué campo identifica a la fila. Único. Vital.
}
```

**`item-key` no es decorativo.** Es el `:key` del `v-for` de F4 — el mismo concepto,
el mismo problema si te lo saltas. `v-data-table` lo usa para reconciliar el DOM al
reordenar, para la selección (`show-select`) y para saber qué fila está expandida.

Si pones `item-key="title"` y dos tickets se llaman igual, tienes un bug silencioso
que aparece dentro de tres semanas — la selección "salta" entre filas homónimas.
**`item-key="id"`. Siempre.**

> ⚠️ **Diferencia de vocabulario con Quasar, no de concepto.** Quasar llamaba a esto
> `rows` / `columns` / `row-key`. Vuetify lo llama `items` / `headers` / `item-key`.
> Es la misma idea con otra etiqueta. **No traduzcas mentalmente "columns" a
> "headers" y te olvides**: el formato del objeto también cambia (ver §4.3). Traducir
> palabra por palabra desde Quasar es exactamente el error que esta ruta existe para
> evitar.

### 4.3 El formato de `headers`

Aquí está la primera fricción de verdad. En F4, una columna era markup:

```html
<!-- F4 — Bootstrap. La columna es HTML. -->
<th @click="toggleSort('title')">Título ▲</th>
...
<td>{{ ticket.title }}</td>
```

En Vuetify, una columna es **un objeto en JavaScript**:

```js
// TicketsView.vue — headers NO va en data(), va como constante del módulo.
// No es reactivo: no cambia nunca. Meterlo en data() es desperdiciar
// un observer de Vue sobre un array que jamás muta (misma lección que F4/F10).
const HEADERS = [
  {
    text: "#",              // lo que ve el usuario en la cabecera.
    value: "id",            // de dónde saca el valor de la fila. Y el NOMBRE del slot.
    align: "start",
    sortable: true
  },
  {
    text: "Título",
    value: "title",
    align: "start",
    sortable: true
  },
  {
    text: "Estado",
    value: "status",        // ← el slot será item.status
    align: "center",
    sortable: true
  },
  {
    text: "Prioridad",
    value: "priority",      // ← el slot será item.priority
    align: "center",
    sortable: true
  },
  {
    text: "Asignado",
    value: "assignee",
    align: "start",
    sortable: true
  },
  {
    text: "Creado",
    value: "createdAt",
    align: "end",
    sortable: true
  },
  {
    text: "",               // columna de acciones: sin cabecera
    value: "actions",       // ← NO existe en el ticket. Es una columna "virtual".
    align: "end",
    sortable: false,        // no tiene sentido ordenar por un botón
    filterable: false       // ni buscar en ella
  }
];
```

**🔎 Qué hace, campo por campo:**

| Campo | Su trabajo | Trampa |
|---|---|---|
| `text` | El texto de la cabecera. | En Quasar era `label`. Aquí es `text`. Si escribes `label`, la cabecera sale **vacía** sin avisar. |
| `value` | Clave de la fila **y** nombre del slot (`item.<value>`). | Es dos cosas a la vez. Cambiarlo rompe el slot **en silencio**. |
| `align` | `start` / `center` / `end`. | **`start`/`end`, no `left`/`right`** (Quasar usaba `left`/`right`). Si pones `left`, se ignora y alinea a la izquierda "por suerte" — hasta que RTL. |
| `sortable` | `true` (por defecto) → cabecera clicable. | **Por defecto `true`, al revés que Quasar** (que era `false`). En Vuetify tienes que **apagar** el orden de la columna de acciones, no encenderlo en las demás. |
| `filterable` | `true` (por defecto) → entra en el `:search`. | La columna `actions` debe llevar `filterable: false` o el buscador la "encuentra" y ensucia resultados. |
| `width` | Ancho fijo opcional (`"120px"`, `120`). | — |

> 💡 **`value` es el filtro de Vue 2 de F4, pero repartido.** En F4,
> `{{ ticket.createdAt | formatDate }}` formateaba en el template. En Vuetify no hay
> un campo `format` en el header (eso era Quasar). El formato se hace **en el slot**
> `item.createdAt` (ver §4.4) o con un filtro de Vue 2 dentro de ese slot. Los
> `filters` de Vue 2 **siguen vivos** en el resto del proyecto; dentro de la tabla,
> el sitio idiomático es el slot. **No inventes un `format` en el header: no existe.**

**⚠️ La diferencia que más muerde al venir de Quasar:** `sortable` por defecto es
`true`. En Quasar era `false` y tenías que encenderlo. Aquí **todas** las columnas
ordenan de fábrica, incluida la de acciones si no la apagas — y ordenar por la
columna de un botón es un no-op que confunde al usuario. **Apaga `sortable` y
`filterable` en `actions`.**

### 4.4 Los slots: `item.status` y los badges de F4 — ahora con el tema

`v-data-table` sustituye una celda con el slot `item.<value>`. En F4 los badges eran
`<span class="badge badge-danger">`. Aquí los vamos a montar dentro de un `v-chip`
**cuyo color sale del tema**, no de una clase Bootstrap. Esto es el ⭐ diferencial de
la ruta VU: el theming en JS aterriza en la tabla.

```html
<v-data-table
  :headers="headers"
  :items="allTickets"
  item-key="id"
  :search="search"
>
  <!--
    item.<value> — el <value> es el `value` del header.
    v-slot="{ item }" te da la fila entera (además de header, value, index...).
  -->
  <template v-slot:item.status="{ item }">
    <!-- El componente de F4, adaptado: ahora recibe un color de TEMA. Véase abajo. -->
    <ticket-status-badge :status="item.status" />
  </template>

  <template v-slot:item.priority="{ item }">
    <ticket-priority-badge :priority="item.priority" />
  </template>

  <template v-slot:item.createdAt="{ item }">
    <!-- El filtro de Vue 2 de F4 sigue funcionando DENTRO del slot -->
    {{ item.createdAt | formatDate }}
  </template>

  <!-- Columna de acciones (value: "actions" en headers) -->
  <template v-slot:item.actions="{ item }">
    <!-- Botón de VUETIFY que abre un modal de BOOTSTRAP. Véase §4.7. -->
    <v-btn icon small @click="onEdit(item)">
      <v-icon small>mdi-pencil</v-icon>
    </v-btn>
  </template>

  <!-- Estado vacío: el "no hay resultados" de F4, ahora es un slot -->
  <template v-slot:no-data>
    <div class="py-4 text-center grey--text">
      🔍 No hay tickets que coincidan con los filtros.
    </div>
  </template>

  <!-- Mientras el :search no encuentra nada (distinto de no-data) -->
  <template v-slot:no-results>
    <div class="py-4 text-center grey--text">
      Sin coincidencias para "{{ search }}".
    </div>
  </template>
</v-data-table>
```

**🔎 Qué hace:**
- `v-slot:item.status` sustituye **solo** la celda de la columna cuyo `value` es
  `"status"`. Las demás columnas se renderizan solas.
- `v-slot="{ item }"` desestructura el scope. Vuetify te pasa `{ item, header, value,
  index, ... }`; casi siempre solo quieres `item`.
- **`v-data-table` no necesita un envoltorio tipo `<q-td>`.** Metes tu contenido y ya.
  (En Quasar tenías que envolver en `<q-td :props="props">` o se descuadraba. Aquí
  no. Una fricción menos.)
- Hay **dos** estados vacíos distintos: `no-data` (la tabla no tiene items) y
  `no-results` (el `:search` no encontró nada). F4 tenía uno solo. Si solo pones
  `no-data`, buscar algo inexistente muestra el mensaje equivocado.

#### ⭐ Theming aplicado: los badges pasan del hardcode al tema

En F4, `TicketStatusBadge` tenía las clases Bootstrap escritas a mano:

```js
// F4 — TicketStatusBadge.vue (el mapa hardcodeado)
var STATUS_MAP = {
  open:        { label: "Abierto",     css: "badge-danger" },   // ← clase Bootstrap
  in_progress: { label: "En progreso", css: "badge-warning" },
  resolved:    { label: "Resuelto",    css: "badge-success" },
  closed:      { label: "Cerrado",     css: "badge-secondary" }
};
```

El problema no es que funcione — funciona. El problema es que **`badge-danger` es un
rojo concreto de Bootstrap** (`#dc3545`), soldado al componente. Si mañana el equipo
de diseño cambia el rojo de la marca, o activas dark mode, ese badge sigue siendo el
rojo de Bootstrap de 2018. No sabe que existe un tema.

En Vuetify, el color vive en `src/plugins/vuetify.js` (VU1), y los componentes lo
piden **por nombre**:

```js
// src/plugins/vuetify.js (de VU1) — el tema define los nombres, no los componentes
import Vue from "vue";
import Vuetify from "vuetify/lib";

Vue.use(Vuetify);

export default new Vuetify({
  theme: {
    themes: {
      light: {
        primary: "#1976D2",
        // nombres semánticos que los badges van a pedir:
        error:   "#C62828",   // el "rojo" de la app. Cámbialo AQUÍ y cambian los badges.
        warning: "#F9A825",
        success: "#2E7D32",
        info:    "#0277BD"
      },
      dark: {
        // dark mode: los MISMOS nombres, otros valores. Los badges no se enteran.
        primary: "#2196F3",
        error:   "#EF5350",
        warning: "#FFB300",
        success: "#66BB6A",
        info:    "#29B6F6"
      }
    }
  }
});
```

Y el badge de F4 se adapta: el mapa deja de guardar una **clase CSS** y pasa a
guardar un **nombre de color del tema**:

```vue
<!-- components/tickets/TicketStatusBadge.vue — versión VU3 -->
<template>
  <!-- v-chip toma el color por NOMBRE de tema. `small` y `dark` para el texto. -->
  <v-chip :color="chipColor" small dark>{{ label }}</v-chip>
</template>

<script>
var STATUS_MAP = {
  open:        { label: "Abierto",     color: "error"     },  // ← nombre de TEMA, no clase
  in_progress: { label: "En progreso", color: "warning"   },
  resolved:    { label: "Resuelto",    color: "success"   },
  closed:      { label: "Cerrado",     color: "grey"      }
};

export default {
  name: "TicketStatusBadge",
  props: {
    status: { type: String, required: true }
  },
  computed: {
    chipColor: function () {
      var entry = STATUS_MAP[this.status];
      return entry ? entry.color : "grey";
    },
    label: function () {
      var entry = STATUS_MAP[this.status];
      return entry ? entry.label : this.status;
    }
  }
};
</script>
```

**🔎 Qué cambió, y por qué importa:**
- El componente ya **no conoce ningún color**. Conoce **nombres semánticos**
  (`error`, `warning`, `success`). El valor de esos nombres vive en un solo sitio:
  `vuetify.js`.
- **Cambia `error` en el tema → cambian todos los badges de estado `open`.** Sin
  tocar el componente. Ese es el enganche con VU1: el theming en JS deja de ser
  teoría y se ve en la tabla.
- **Dark mode gratis.** `$vuetify.theme.dark = true` y los badges usan la paleta
  `dark`. En F4, con `badge-danger` hardcodeado, dark mode no tocaba el badge.

> ✅ **Buena práctica: nombres semánticos, no nombres de color.** Llama al color
> `error`, no `red`. El día que "urgente" pase de rojo a naranja por decisión de
> diseño, cambias un valor y toda la app obedece. Si lo llamaste `red` y ahora es
> naranja, tienes un color llamado "rojo" que es naranja. Bienvenido a otro legacy.

> ⚠️ **La trampa de migrar esto "a lo Quasar".** En Q3 los badges se quedaban
> **intactos**, con sus clases Bootstrap, porque Quasar no empujaba a tocarlos. Aquí
> **sí los tocamos**, y a propósito: es donde el theming en JS se cobra su peso.
> Copiar la decisión de Q3 ("no toques los badges") sería perderte la única parte de
> esta fase que Quasar no tiene.

### 4.5 ⚔️ El conflicto: `:options.sync` vs el store

Aquí está la fase.

`v-data-table` mantiene un objeto **`options`** por dentro:

```js
{
  page: 1,
  itemsPerPage: 10,
  sortBy: ["createdAt"],   // ← es un ARRAY (soporta multi-columna). Ojo.
  sortDesc: [true],        // ← otro array, en paralelo a sortBy
  groupBy: [],
  groupDesc: [],
  multiSort: false,
  mustSort: false
}
```

Ese objeto **es estado de la aplicación**. Y tú, en F10, hiciste una auditoría de
qué estado va al store y cuál no. Las cuatro preguntas que defendiste:

> 1. ¿Lo consumen 2+ vistas que conviven o se alternan?
> 2. ¿Debe sobrevivir a la navegación (sin ser algo que la URL exprese mejor)?
> 3. ¿Lo mutan varias fuentes?
> 4. ¿La inconsistencia entre consumidores sería un bug visible?

Aplicadas a la paginación del dashboard, la auditoría de F10 respondió **local** —
igual que `search` y `statusFilter`, que la tabla de F10 mandó a la URL/local, no al
store. Una sola vista lo lee. No sobrevive a la navegación (y no quieres que
sobreviva). Nadie más lo necesita.

**Pero ahora la pregunta es otra.** No es "¿store o local?". Es:

> **Si es local, ¿local *de tu componente* (`options` en `data()`, sincronizado con
> `:options.sync`) o local *del `v-data-table`* (no pasas `options`, la tabla se lo
> guarda sola)?**

Y ahí hay dos opciones. No hay una tercera limpia.

---

#### Opción A — Manda `v-data-table` (el componente es el dueño)

No pasas `options`. La tabla se lo gestiona todo internamente.

```html
<!-- Sin :options. Sin data() de paginación. La tabla se apaña. -->
<v-data-table
  :headers="headers"
  :items="allTickets"
  item-key="id"
  :search="search"
  :items-per-page="10"
  :footer-props="{ 'items-per-page-options': [10, 25, 50] }"
/>
```

```js
// TicketsView.vue — el data() de paginación: NO EXISTE.
export default {
  data: function () {
    return {
      search: ""   // el search sigue local (decisión de F10), NADA de paginación
    };
  },
  computed: {
    ...mapGetters("tickets", ["allTickets"])
  },
  created: function () {
    this.$store.dispatch("tickets/fetchTickets");
  }
};
```

**Qué ganas:**
- Cero código de paginación. Cero. El borrado es total.
- Cero bugs de paginación. El `page = 1` al filtrar viene hecho.
- Cuando actualices Vuetify y arreglen un edge case, te lo llevas gratis.

**Qué pagas:**

| Coste | Cuándo te muerde |
|---|---|
| **El estado es invisible.** No sale en las devtools de Vuex. No sale en el time travel de F10. Vive dentro de un componente de `node_modules`. | El día que un usuario reporta "estaba en la página 3 y se me fue a la 1" y no puedes reproducirlo. |
| **No puedes leerlo desde fuera.** Si otra vista quiere saber en qué página está el dashboard, no puede. | Casi nunca. Pero si pasa, es un refactor. |
| **No puedes escribirlo desde fuera** sin `$refs`. Un botón "ir a la primera página" fuera de la tabla necesita tocar el `options` interno vía `$refs`. | Ejercicio 25. |
| **No es serializable.** No lo metes en la URL, ni en localStorage, ni en un assert de test que verifique "tras filtrar, `page` vale 1". | Al escribir los tests. Se nota **ya**. |

---

#### Opción B — Mandas tú (`:options.sync` + Vuex)

Pones el objeto `options` en el store y lo sincronizas.

> ⚠️ **Ajuste de continuidad con F10.** En el tronco, `search` y `statusFilter`
> **NO están en el store**: la auditoría de F10 los dejó locales/URL ("el store no
> los pidió"). El patrón computed `get`/`set` contra una mutation aparece en F10
> como ejemplo, no como el estado por defecto. Así que la Opción B mete el estado de
> la tabla en el store **solo si eliges la Opción B para todo el estado de la
> tabla**. Si te quedas en la A (lo recomendado), `search` sigue local. **No subas
> `search` al store "de paso"**: súbelo solo si decidiste que la paginación también
> sube.

```js
// store/modules/ui.js — el módulo `ui` de F10 (flash), ampliado para la Opción B
const state = {
  flash: null,   // el único estado que F10 puso aquí por defecto (F5 ej. 20)
  // ↓↓ esto sube al store SOLO en la Opción B (no es el default de F10)
  ticketsOptions: {
    page: 1,
    itemsPerPage: 10,
    sortBy: ["createdAt"],
    sortDesc: [true],
    groupBy: [],
    groupDesc: [],
    multiSort: false,
    mustSort: false
  }
};

const mutations = {
  SET_TICKETS_OPTIONS: function (state, options) {
    // Reemplazo completo. v-data-table emite el objeto entero, no un patch.
    // Reasignar es reactivo (F8: reemplazar > mutar propiedad a propiedad).
    state.ticketsOptions = options;
  }
};
```

```html
<!-- TicketsView.vue -->
<v-data-table
  :headers="headers"
  :items="allTickets"
  item-key="id"
  :options.sync="options"
  :footer-props="{ 'items-per-page-options': [10, 25, 50] }"
/>
```

```js
// El computed con get/set de F10 — el mismo patrón, otra vez.
// .sync es azúcar de :options + @update:options. Necesita un setter.
computed: {
  ...mapGetters("tickets", ["allTickets"]),

  options: {
    get: function () {
      return this.$store.state.ui.ticketsOptions;
    },
    set: function (value) {
      this.$store.commit("ui/SET_TICKETS_OPTIONS", value);
    }
  }
}
```

**🔎 Qué hace `:options.sync`:** Vue 2.3+ expande `:options.sync="x"` a `:options="x"`
+ `@update:options="x = $event"`. Como `x` es un computed con setter, la asignación
**corre el `set`** → commit → mutation → store. Es el patrón de `v-model` contra el
store de F10. **No es magia nueva: es el mismo truco.**

> ⚠️ **Sin el `set`, `strict: true` te mata.** Si `options` es un computed
> solo-lectura, `v-data-table` va a intentar mutarlo y Vuex lanza
> `Error: [vuex] do not mutate vuex store state outside mutation handlers`. **En
> dev.** En producción `strict` está apagado (F10) → **muta el store en silencio, sin
> commit, sin devtools, sin time travel.** El peor bug: funciona.

> ⚠️ **La trampa de `sortBy` como array.** En Quasar `sortBy` era un string
> (`"createdAt"`) y `descending` un boolean. En Vuetify **`sortBy` es un array**
> (`["createdAt"]`) y **`sortDesc` es otro array** (`[true]`), en paralelo. Si en tu
> mutation inicializas `sortBy: "createdAt"` (string, copiando de Quasar), la tabla
> **no ordena y no da error**. Tiene que ser `["createdAt"]`. Media tarde, aquí.

**Qué ganas:** visibilidad en devtools, serializable (a URL, a localStorage, a un
assert), escribible desde fuera (`commit("ui/SET_TICKETS_OPTIONS", {...})` sin
`$refs`), sobrevive a la navegación (lo cual **puede ser un bug** si no lo querías).

**Qué pagas:**

| Coste | Cuándo te muerde |
|---|---|
| **Estado de UI en el store global.** Exactamente lo que la auditoría de F10 dijo que NO hicieras. Tu propia regla, rota. | Cuando el siguiente dev lea el store y pregunte "¿por qué el `sortBy` de una tabla vive aquí?". |
| **Un commit por interacción.** Ordenar → commit. Página siguiente → commit. Cambiar `itemsPerPage` → commit. El time travel real se pierde en el ruido. | La primera vez que uses el time travel para depurar algo de verdad. |
| **Acoplas el store a un componente de terceros.** Ese objeto con `sortBy[]`/`sortDesc[]` **es el formato de Vuetify 2**. Si mañana migras a Vue 3 (donde `v-data-table` cambió la API de options), tu store tiene la forma vieja. | En la próxima migración. Que la habrá. |
| **Multiplica.** Si el panel de soporte también tiene tabla, ahora hay `supportOptions`. Y `metricsOptions`. El módulo `ui` se vuelve un vertedero. | Al llegar al ejercicio 🔴 final. |

---

#### 📝 La decisión defendida

Como en F10: **elegir, y escribir por qué.**

> **Manda `v-data-table`. Opción A.**
>
> **Salvo** que el estado tenga que salir del componente. Y en el Mini Jira, no
> tiene que salir.
>
> El razonamiento es el de F10, aplicado con honestidad. La regla no era "todo al
> store": era **"¿lo lee alguien más? ¿sobrevive a la navegación de forma que la URL
> no exprese mejor? ¿lo necesita un guard o un interceptor?"**. Para el estado de la
> tabla del dashboard, las respuestas son **no, no, no**.
>
> El único argumento fuerte a favor de B es la **visibilidad en devtools**. Es real:
> depurar estado que no ves es una tortura. Pero es un argumento de *herramientas*,
> no de *arquitectura*. Y el coste que paga es arquitectónico: metes en el store
> global el objeto de configuración de un componente de `node_modules`, con su forma
> exacta (`sortBy` como array incluido), y creas un precedente que la siguiente tabla
> seguirá. Así nacen los módulos `ui` de 400 líneas del legacy real.
>
> **Cuándo sí es B**, sin dudarlo:
>
> 1. **El estado va en la URL.** `/tickets?page=3&sort=title&desc=1`. Un usuario
>    copia el link, lo comparte, el compañero ve la misma vista. Feature de producto
>    real, y la razón nº1 para sacar el estado del componente. (No necesita Vuex,
>    ojo — necesita `$route.query` y `:options.sync`. Ejercicio 22.)
> 2. **Server-side con filtro compartido.** Si el filtro vive en el store (porque lo
>    leen las métricas de F7, ej. 27) y la paginación depende del filtro, tenerlos
>    separados es peor que juntos.
> 3. **El estado debe sobrevivir a la navegación** por requisito explícito.
>
> Fuera de eso: **cede el control.** Es lo que compraste al meter Vuetify. Si quieres
> controlarlo todo, no metas un framework de UI.
>
> **La trampa que debes evitar:** el híbrido. Paginación en la tabla, filtro en el
> store, orden en el componente. Tres dueños. Eso no es "lo mejor de ambos": es un
> sistema donde nadie sabe quién resetea la página al filtrar, y el bug aparece un
> martes.

**Tu turno.** Escribe tu versión (ejercicio 26). Puede ser la contraria. Lo que no
puede ser es "depende".

### 4.6 Modo server-side: `:server-items-length`, `@update:options`, `:loading`

Todo lo anterior asume **modo cliente**: `v-data-table` recibe las 40 filas y pagina,
ordena y busca en memoria. Es lo que hacía F4 y es correcto para 40 tickets.

Cuando son 40.000, no.

**🔎 El interruptor es `:server-items-length`.** No hay una prop `server-side="true"`.
En cuanto pasas `:server-items-length="N"` (con `N >= 0`), `v-data-table` **deja de
paginar/ordenar/filtrar en memoria** y confía en que tú le das ya la página lista.
Emite `@update:options` cada vez que el usuario cambia página, orden o `itemsPerPage`,
y espera que **tú** vayas al backend. Si no pasas `:server-items-length`, sigue en
cliente. **Esto no está en la doc en letras grandes y es la fuente nº1 de "¿por qué
me pagina dos veces / por qué solo veo 10 de las 40?"**.

```html
<v-data-table
  :headers="headers"
  :items="allTickets"
  item-key="id"
  :loading="loading"
  :options.sync="options"
  :server-items-length="serverItemsLength"
  @update:options="onOptionsChange"
/>
```

```js
// TicketsView.vue — modo server-side
export default {
  data: function () {
    return {
      options: {
        page: 1,
        itemsPerPage: 10,
        sortBy: ["createdAt"],
        sortDesc: [true]
      },
      serverItemsLength: 0   // ← lo rellena la API. NO es el interruptor por su valor:
                             //   el interruptor es que la PROP exista en el template.
    };
  },

  computed: {
    ...mapGetters("tickets", ["allTickets"]),
    ...mapState("tickets", ["loading"])
  },

  // OJO: en modo server-side NO dispares el primer fetch en created().
  // @update:options se emite SOLO al montar la tabla, con las options iniciales.
  // Si además lo llamas en created(), disparas DOS peticiones. Ver abajo.

  methods: {
    // @update:options se dispara al montar y cada vez que cambian página/orden/tamaño.
    // Recibe el objeto `options` NUEVO (el que el usuario quiere).
    onOptionsChange: function (options) {
      var self = this;

      return this.$store
        .dispatch("tickets/fetchTicketsPaged", {
          page: options.page,
          limit: options.itemsPerPage,
          // sortBy/sortDesc son ARRAYS: coge el primero (multiSort está apagado)
          sortBy: options.sortBy[0] || "createdAt",
          descending: options.sortDesc[0] === true
        })
        .then(function (result) {
          self.serverItemsLength = result.total; // ← 💸 véase abajo
        });
    }
  }
};
```

**🔎 Qué hace, paso a paso (el flujo evento por evento):**

```
1. La tabla se monta → v-data-table emite @update:options con las options iniciales
     ↳ (por eso NO se dispara fetch en created(): la tabla ya lo pide sola)
2. onOptionsChange() dispara la action de Vuex
3. La action commitea SET_LOADING(true)
     ↳ :loading="loading" → v-data-table pinta su barra lineal de progreso ⏳
4. El service llama a GET /tickets?_page=1&_limit=10&_sort=createdAt&_order=desc
5. json-server responde: body = 10 tickets, header X-Total-Count = 43
6. El service mapea → { items: [...], total: 43 }
7. La action commitea SET_TICKETS(items) + SET_LOADING(false)
8. onOptionsChange() (en el .then) asigna serverItemsLength = 43
     ↳ v-data-table ya sabe: página 1 de 5. Pinta el footer bien.
9. :items="allTickets" ya tiene los 10 → la tabla se repinta

  (usuario clica "página 2" → vuelve al paso 1 con options.page = 2)
```

**✅ Buenas prácticas:**
- **NO dispares el primer fetch en `created()`.** A diferencia de Quasar (donde
  `QTable` NO pedía datos al montar y tenías que hacerlo tú), `v-data-table`
  **emite `@update:options` al montarse**. Si además llamas al fetch en `created()`,
  haces **dos peticiones** al arrancar. El síntoma: dos requests idénticas en la
  pestaña Network cada vez que entras al dashboard. (Este es el error espejo del de
  Q3: allí faltaba el disparo inicial, aquí sobra.)
- **`loading` es del store, no local.** Existe desde F3 (`loading/error/data`) y en
  F10 vive en el módulo `tickets`. `:loading="loading"` lo consume. **No crees un
  `loading` nuevo en el componente.**
- **`sortBy`/`sortDesc` son arrays.** Con `multiSort` apagado (por defecto), coges
  `[0]`. Si algún día activas multi-columna, el service tiene que aceptar varios.
- **El `:search` built-in NO funciona en server-side.** Filtra sobre los items en
  memoria, y en server-side solo tienes la página actual (10 filas). El texto de
  búsqueda tiene que viajar al backend como param, igual que en Q3. No pongas
  `:search` y esperes que filtre las 40.000: filtra 10.

#### 💸 Deuda: `serverItemsLength` vs `X-Total-Count`

```
💸 v-data-table server-side espera `server-items-length`: un número que le dices
   tú, calculado a partir de lo que devuelva la API.

   json-server manda el total en un HEADER: `X-Total-Count: 43`.

   No es capricho de json-server: es una convención REST bastante extendida. Pero
   es UNA de ellas. Otra API te lo manda en el body:
   { data: [...], meta: { total: 43 } }. Otra en un envelope. Otra no te lo manda
   y tienes que pedir la página siguiente para saber si existe (cursor-based).

   "En producción el backend te da el total en el body o en un header; aquí lo
    pescamos del header y lo mapeamos a mano."

   El sitio donde se mapea NO es el componente. Es el SERVICE. Que la vista sepa
   que existe un header llamado X-Total-Count es un fallo de capas.
```

```js
// services/ticketService.js — el mapeo vive AQUÍ (idéntico patrón que Q3:
// la deuda es del backend/json-server, no del framework de UI)
import apiClient from "./apiClient";

export default {
  // ...getTickets(), createTicket(), etc. de F3

  getTicketsPaged: function (params) {
    // params: { page, limit, sortBy, descending }
    return apiClient
      .get("/tickets", {
        params: {
          _page: params.page,
          _limit: params.limit,
          _sort: params.sortBy,
          _order: params.descending ? "desc" : "asc"
        }
      })
      .then(function (response) {
        // 🔎 AQUÍ se paga la deuda. El componente nunca ve "X-Total-Count".
        // axios normaliza los headers a minúsculas. SIEMPRE. Buscar
        // response.headers["X-Total-Count"] devuelve undefined y te vuelves loco.
        var total = parseInt(response.headers["x-total-count"], 10);

        return {
          items: response.data,
          total: isNaN(total) ? response.data.length : total
        };
      });
  }
};
```

**🔎 Qué hace:** el service traduce **el contrato de la API** (headers, `_page`,
`_limit`) al **contrato de tu app** (`{items, total}`). El store recibe `{items,
total}`. El componente recibe `total` y lo asigna a `serverItemsLength`. Tres capas,
tres vocabularios, ninguna filtración.

**⚠️ El fallo con nombre propio:** `response.headers["X-Total-Count"]` →
`undefined`. **axios pasa los headers a minúsculas.** No lo dice en ningún sitio
visible. Es `response.headers["x-total-count"]`. Media tarde perdida, garantizado.

> **⚠️ CORS, el otro fallo con nombre propio.** Si tu API está en otro origen, el
> navegador **no te deja leer** headers custom salvo que el servidor mande
> `Access-Control-Expose-Headers: X-Total-Count`. Entonces
> `response.headers["x-total-count"]` → `undefined`, **con la petición devolviendo
> 200 y el header visible en la pestaña Network**. Lo ves, y no lo puedes leer.
> json-server lo expone; **tu backend de producción probablemente no**. Esa
> conversación con backend, tenla el primer día. 💸

```js
// store/modules/tickets.js — la action nueva
actions: {
  fetchTicketsPaged: function (context, params) {
    context.commit("SET_LOADING", true);
    context.commit("SET_ERROR", "");

    return ticketService
      .getTicketsPaged(params)
      .then(function (result) {
        context.commit("SET_TICKETS", result.items);
        return result;   // ← devuelve {items, total}: la vista necesita el total
      })
      .catch(function (error) {
        context.commit("SET_ERROR", "No se pudieron cargar los tickets.");
        throw error;
      })
      .finally(function () {
        context.commit("SET_LOADING", false);
      });
  }
}
```

> 🔎 **Ojo con la caché de `fetchTickets` (F10).** La action original tenía un
> `if (context.state.items.length > 0 && !options.force) return ...`. Esa caché **no
> vale en server-side**: cada página es un fetch nuevo, siempre. Si copias el patrón
> sin pensar, el usuario clica "página 2" y ve la 1 otra vez, sin error, sin loading.
> **`fetchTicketsPaged` no cachea. Punto.**

**¿Cliente o servidor en el Mini Jira?** **Cliente.** 40 tickets. El modo server-side
está aquí porque **lo vas a ver en producción** y porque `serverItemsLength` es donde
la deuda 💸 se hace visible — no porque el Mini Jira lo necesite. Montar server-side
para 40 filas es la definición de complejidad accidental.

### 4.7 🤝 Convivencia Bootstrap + Vuetify

Esta sección **no es un anexo**. Es la mitad del valor de la fase.

> ⚠️ **Sobre el modal.** El curso base **no usa bootstrap-vue** — usa Bootstrap 4
> crudo con jQuery, encapsulado en un componente frontera (`ConfirmModal.vue`, ej. 18
> de F5 y el patrón de librería imperativa de A1). Así que en el Mini Jira **no hay
> `<b-modal>` ni `this.$bvModal`**: hay un `<div class="modal">` de Bootstrap que
> abres con `$('#id').modal('show')`. Los bosquejos maestros escriben `<b-modal>` como
> taquigrafía de "el modal de Bootstrap"; aquí lo escribimos como el curso lo enseña.
> La lección de convivencia es idéntica: es un componente que no sabe que Vuetify
> existe.

Después de VU2 y VU3, tu proyecto está así:

```
Mini Jira (post-VU3)
├── Dashboard         → v-data-table    🅥 Vuetify
├── Formulario CRUD   → v-form/v-text-field 🅥 Vuetify
├── Modal de crear    → div.modal+jQuery 🅱️ Bootstrap
├── Wizard (F6)       → a pelo + BS4    🅱️ Bootstrap
├── Panel soporte (F9)→ a pelo + BS4    🅱️ Bootstrap
├── Métricas (F7)     → chart.js + BS4  🅱️ Bootstrap
├── Badges (F4)       → v-chip :color   🅥 Vuetify (¡migrados en §4.4!), DENTRO de la tabla
└── Layout            → <v-app>         🅥 Vuetify
```

Esto **no es un estado transitorio que vas a limpiar el mes que viene.** Es tu
proyecto durante los próximos tres años. Bienvenido.

#### ¿Se pisan los estilos? SÍ. Y en Vuetify a TRES bandas.

En Q3, `.row` colisionaba entre **dos**: Bootstrap 4 y Quasar 1. En Vuetify hay una
vuelta de tuerca: **`.row` significó dos cosas distintas en Vuetify 1 y en Vuetify 2**.
Y en un legacy de 2019 te encuentras código de las dos versiones de Vuetify **más**
Bootstrap. Tres definiciones del mismo selector.

```css
/* Bootstrap 4 — bootstrap.css */
.row {
  display: flex;
  flex-wrap: wrap;
  margin-right: -15px;   /* ← gutter negativo */
  margin-left: -15px;
}

/* Vuetify 2 — vuetify.css : `.row` ES el grid (reemplazó a `v-layout`) */
.row {
  display: flex;
  flex-wrap: wrap;
  flex: 1 1 auto;
  margin: -12px;         /* ← gutter propio, distinto de Bootstrap */
}

/* Vuetify 1 — el grid NO se llamaba `.row`: era `.layout` (componente <v-layout>).
   Vuetify 1 SÍ tenía una clase `.row`, pero era una UTILIDAD de DIRECCIÓN de flex
   (equivalente a flex-direction: row), NO el contenedor del grid.
   → El MISMO nombre de clase cambió de SIGNIFICADO entre Vuetify 1 y Vuetify 2. */
.row {                   /* Vuetify 1 (aprox.) */
  flex-direction: row;   /* ← otra cosa completamente */
}
```

**Por qué esto es peor que en Quasar.** En Q3, `.row` de Bootstrap y de Quasar hacían
*casi lo mismo* (flex + gutter), y "solo" discrepaba el gutter. Aquí, si tu legacy
arrastra CSS de **Vuetify 1**, `.row` no es ni siquiera un grid: es una utilidad de
dirección. Un `<div class="row">` que en tu cabeza es "una fila del grid" puede estar
aplicando `flex-direction: row` de una hoja de Vuetify 1 que nadie recuerda haber
dejado. **El mismo nombre, tres comportamientos.**

**Cuál gana:** el que se cargue **último** en el bundle. Misma especificidad (`0,0,1,0`
— una clase). Regla de cascada CSS: **último gana**. Y "el que se cargue último" **no
es una decisión que hayas tomado**: es una consecuencia del orden de imports en tu
`main.js` (recuerda: en Vuetify sigues teniendo `main.js`, VU1 — Vuetify no se comió
el proyecto).

```js
// main.js — el orden IMPORTA y casi nadie lo piensa
import "bootstrap/dist/css/bootstrap.min.css"; // ¿este primero...
import vuetify from "./plugins/vuetify";        // ...o el CSS que arrastra Vuetify?
// Vuetify inyecta su CSS al usarse. Quién gana depende de esto y del build.
```

**Pruébalo. No te fíes de mí:**

```html
<!-- Ponlo en cualquier vista y abre el DevTools -->
<div class="row" style="border: 2px solid red;">
  <div class="col-6" style="background: #ffe;">A</div>
  <div class="col-6" style="background: #eff;">B</div>
</div>
```

**Qué ves:** inspecciona el `.row` en DevTools → pestaña Styles. Vas a ver **varias
reglas `.row`**, con las que perdieron **tachadas**. Esa es la demostración: no es que
"no se lleven bien", es que **literalmente el mismo selector está definido más de una
vez y una gana**. Si además hay CSS de Vuetify 1 en el proyecto, verás una tercera
`.row` con `flex-direction` que no cuadra con ninguna de las otras dos.

> ✅ **Buena práctica de convivencia: no uses `.row`/`.col` de nadie en pantallas
> Vuetify.** Dentro de Vuetify, maqueta con `<v-container>` / `<v-row>` / `<v-col>`
> (componentes, VU1), que renderizan sus propias clases prefijadas y no dependen de
> quién ganó la cascada. Reserva `.row`/`.col` de Bootstrap para las pantallas que
> **siguen** en Bootstrap. Mezclar `<div class="row">` de Bootstrap dentro de una
> vista Vuetify es pedir que la cascada decida por ti.

Otras clases que colisionan (parcial o totalmente):

| Clase | Bootstrap 4 | Vuetify 2 | ¿Choca? |
|---|---|---|---|
| `.row` | flex + gutter -15px | flex + gutter -12px (**y `.row` en v1 era otra cosa**) | 💥 **Sí, a tres bandas** |
| `.col`, `.col-6` | grid de 12, con padding | Vuetify usa `.col-6` también (grid de 12) | 💥 **Sí** — y parece que funciona |
| `.container` | ancho fijo por breakpoint | `<v-container>` genera `.container` con otro cálculo | 💥 **Sí** |
| `.text-center` | `text-align: center` | igual | ✅ Coinciden. Suerte. |
| `.d-flex` | `display: flex` | igual | ✅ Coinciden |
| `.v-*` | — | todo lo de Vuetify | ✅ Namespace. Por esto Vuetify prefija sus componentes |
| `.btn`, `.card`, `.badge` | Bootstrap | Vuetify usa `.v-btn`, `.v-card`, `.v-chip` | ✅ No chocan |

#### La convivencia que SÍ funciona: un evento cruza los dos frameworks

Lo interesante no es que los estilos se peleen. Es que la **lógica** convive sin
enterarse. El botón de editar de la tabla es Vuetify; el modal que abre es Bootstrap;
y el store no sabe que existe ninguno de los dos.

```vue
<!-- TicketsView.vue — el botón Vuetify abre el modal Bootstrap -->
<template v-slot:item.actions="{ item }">
  <v-btn icon small @click="onEdit(item)">   <!-- 🅥 Vuetify emite el click -->
    <v-icon small>mdi-pencil</v-icon>
  </v-btn>
</template>
```

```js
methods: {
  onEdit: function (ticket) {
    // 1. guardo el ticket a editar en local (o lo commiteo, según F10)
    this.editing = ticket;
    // 2. abro el modal de BOOTSTRAP con jQuery, crudo, como en A1/F5.
    //    El v-btn de Vuetify NO sabe que esto existe. El modal NO sabe
    //    que lo abrió un componente Vuetify. Y Vuex no se entera de nada.
    window.$("#ticketModal").modal("show");
  }
}
```

**🔎 El flujo completo, framework por framework:**

```
1. <v-btn> (Vuetify) recibe el click nativo
2. @click → onEdit(item)  ← código Vue normal, sin framework de UI
3. onEdit hace $('#ticketModal').modal('show')  ← jQuery + Bootstrap, crudo
4. el modal Bootstrap (div.modal) aparece
5. dentro del modal, el <v-form> de VU2 (Vuetify otra vez) edita el ticket
6. al guardar, el form emite un evento Vue → la vista dispatchea a Vuex
7. Vuex commitea → el getter allTickets cambia → :items del v-data-table cambia
8. <v-data-table> (Vuetify) se repinta con el ticket editado
```

Ocho pasos. Vuetify → Vue → jQuery/Bootstrap → Vuetify → Vue → Vuex → Vuetify. **Y el
store solo aparece en el paso 6-7**, porque es lo único que le importa: el dato. Los
frameworks de UI son intercambiables alrededor de él.

Esa es la lección. No es "Vuetify es bueno". Es: **si tu arquitectura está bien —
Componente → Store → services/ → apiClient → API — la capa de UI es reemplazable por
trozos.** Bootstrap y Vuetify conviven porque ninguno de los dos es dueño del estado.
El dueño es Vuex, y Vuex no sabe qué librería pinta los botones.

> ✅ **Cierre de la sección:** esto es un legacy real a medio migrar. Dashboard y CRUD
> en Vuetify, el resto en Bootstrap, un modal jQuery en medio, y todo funcionando.
> **Aquí vas a vivir.** No es una vergüenza que limpiar: es el estado natural de
> cualquier proyecto que lleva cinco años en producción y ha sobrevivido a dos modas
> de frontend.

---

## 💻 5. Código de la fase (el resultado, junto)

`TicketsView.vue` en **modo cliente + Opción A** (lo recomendado). Compara su tamaño
con el de F4:

```vue
<template>
  <v-container fluid>
    <!-- resumen: los cards de F4 pueden quedarse o migrarse (ejercicio 8) -->
    <tickets-summary :tickets="allTickets" />

    <!-- el buscador: v-text-field de Vuetify alimenta el :search built-in -->
    <v-text-field
      v-model="search"
      label="Buscar por título..."
      prepend-inner-icon="mdi-magnify"
      clearable
      dense
      class="mb-3"
    />

    <!-- error del store (F3/F10) -->
    <v-alert v-if="error" type="error" dense>
      {{ error }}
      <v-btn small text @click="reload">Reintentar</v-btn>
    </v-alert>

    <v-data-table
      :headers="headers"
      :items="allTickets"
      item-key="id"
      :search="search"
      :loading="loading"
      :items-per-page="10"
      :footer-props="{ 'items-per-page-options': [10, 25, 50] }"
      @click:row="goToDetail"
    >
      <template v-slot:item.status="{ item }">
        <ticket-status-badge :status="item.status" />
      </template>

      <template v-slot:item.priority="{ item }">
        <ticket-priority-badge :priority="item.priority" />
      </template>

      <template v-slot:item.createdAt="{ item }">
        {{ item.createdAt | formatDate }}
      </template>

      <template v-slot:item.actions="{ item }">
        <v-btn icon small @click.stop="onEdit(item)">
          <v-icon small>mdi-pencil</v-icon>
        </v-btn>
      </template>

      <template v-slot:no-data>
        <div class="py-4 grey--text">🔍 No hay tickets.</div>
      </template>
      <template v-slot:no-results>
        <div class="py-4 grey--text">Sin coincidencias para "{{ search }}".</div>
      </template>
    </v-data-table>
  </v-container>
</template>

<script>
import { mapGetters, mapState } from "vuex";
import TicketStatusBadge from "../components/tickets/TicketStatusBadge.vue";
import TicketPriorityBadge from "../components/tickets/TicketPriorityBadge.vue";
import TicketsSummary from "../components/tickets/TicketsSummary.vue";

// headers como constante del módulo: no es reactivo, no muta nunca.
const HEADERS = [
  { text: "#",         value: "id",        align: "start",  sortable: true },
  { text: "Título",    value: "title",     align: "start",  sortable: true },
  { text: "Estado",    value: "status",    align: "center", sortable: true },
  { text: "Prioridad", value: "priority",  align: "center", sortable: true },
  { text: "Asignado",  value: "assignee",  align: "start",  sortable: true },
  { text: "Creado",    value: "createdAt", align: "end",    sortable: true },
  { text: "",          value: "actions",   align: "end",    sortable: false, filterable: false }
];

export default {
  name: "TicketsView",
  components: { TicketStatusBadge, TicketPriorityBadge, TicketsSummary },
  data: function () {
    return {
      headers: HEADERS,
      search: "",       // local: la auditoría de F10 no lo mandó al store
      editing: null
    };
  },
  computed: {
    ...mapGetters("tickets", ["allTickets"]),
    ...mapState("tickets", ["loading", "error"])
  },
  created: function () {
    // modo CLIENTE: aquí SÍ disparas el fetch (no hay @update:options que lo haga)
    this.$store.dispatch("tickets/fetchTickets");
  },
  methods: {
    reload: function () {
      this.$store.dispatch("tickets/fetchTickets", { force: true });
    },
    goToDetail: function (ticket) {
      this.$router.push("/tickets/" + ticket.id);
    },
    onEdit: function (ticket) {
      this.editing = ticket;
      window.$("#ticketModal").modal("show"); // Bootstrap crudo, A1/F5
    }
  }
};
</script>
```

**🔎 Lo que NO ves y es la nota importante:** no hay `filteredTickets`, no hay
`sortedTickets`, no hay `pagedTickets`, no hay `toggleSort`, no hay `goToPage`, no hay
watchers `search → page = 1`. **~150 líneas menos.** El `data()` tiene tres cosas y una
es el `editing` del modal. Ese vacío es el borrado, hecho.

> ⚠️ **`@click:row` vs el botón de acciones.** `@click:row="goToDetail"` navega al
> hacer clic en la fila. Pero el botón de editar **también** está en una fila. Sin
> `@click.stop` en el `v-btn`, clicar "editar" **navega Y abre el modal**. El
> `.stop` corta la propagación. Es el bug clásico de tablas con acciones inline —
> aquí lo tienes marcado.

---

## ⚠️ 6. Errores comunes

- **Disparar el fetch en `created()` estando en server-side** → dos peticiones al
  montar. `@update:options` ya lo pide. (En modo cliente, al revés: `created()` SÍ.)
- **`sortBy: "createdAt"` (string) en vez de `["createdAt"]` (array)** → la tabla no
  ordena y no da error. En Vuetify `sortBy`/`sortDesc` son arrays.
- **`align: "left"` en vez de `"start"`** → se ignora en silencio (Vuetify usa
  `start`/`end`, pensando en RTL). Copiado directo de Quasar (`left`/`right`).
- **`text` escrito como `label` en el header** → cabecera vacía, sin aviso.
- **Olvidar `sortable: false`/`filterable: false` en la columna `actions`** → puedes
  "ordenar" por los botones (no-op confuso) y el buscador "encuentra" filas por esa
  columna.
- **`response.headers["X-Total-Count"]`** (mayúsculas) → `undefined`. axios los pasa
  a minúsculas: `["x-total-count"]`.
- **Poner `:search` y esperar que filtre en server-side** → solo filtra la página
  actual (10 filas). En server-side, la búsqueda viaja al backend como param.
- **Solo definir el slot `no-data`** → buscar algo inexistente muestra el mensaje
  equivocado; falta `no-results`.
- **Badge sin migrar el color al tema** → funciona, pero dark mode y los cambios de
  paleta no lo tocan. Es la mitad del punto de la fase; no te lo saltes.
- **`.row`/`.col` de Bootstrap dentro de una vista Vuetify** → la cascada decide por
  ti y el layout salta según el orden de imports. Usa `<v-row>`/`<v-col>` en Vuetify.
- **Meter `options` en el store "de paso" cuando elegiste Opción A** → contradices tu
  propia auditoría de F10 sin ganancia.

---

## 🧪 7. Ejercicios (28)

**🟢 Fácil (1–7)**

1. Cambia el orden inicial: que la tabla arranque ordenada por `priority`
   descendente. Pista: `:sort-by` / `:sort-desc` (arrays) o el `options` inicial.
2. Añade una columna "Reportado por" (`reporter`) a `headers`. Sin tocar el resto.
3. Haz que la columna `assignee` muestre "— sin asignar —" cuando esté vacía, con un
   slot `item.assignee`.
4. Cambia `items-per-page` inicial a 25 y las opciones del footer a `[25, 50, 100]`.
5. Añade `prepend-inner-icon="mdi-magnify"` y `clearable` al buscador (si no lo
   tienen ya) y comprueba que la X limpia el `search`.
6. Pon `dense` en el `v-data-table` y describe en un comentario qué cambia respecto a
   quitarlo. ¿Te gusta para un dashboard de soporte?
7. Cambia el color de un badge editando **solo** `vuetify.js` (por ejemplo, `warning`).
   Verifica que el badge de `in_progress` cambia sin tocar el componente. Ese es el
   punto de VU1 hecho carne.

**🟡 Intermedio (8–17)**

8. Migra `TicketsSummary` (los cards de F4) a `<v-card>` en un `<v-row>`/`<v-col>` de
   Vuetify. Que los conteos sigan saliendo de un computed.
9. Migra `TicketPriorityBadge` al tema (como se hizo con `TicketStatusBadge` en
   §4.4): `high→error`, `medium→warning`, `low→info`. Sin clases Bootstrap.
10. Activa **dark mode** con un `v-switch` que haga `this.$vuetify.theme.dark =
    !this.$vuetify.theme.dark`. Observa: ¿los badges migrados cambian? ¿Y los que
    dejaste con clases Bootstrap (si dejaste alguno)? Documenta la diferencia.
11. Filtro por estado con un `<v-select>` que alimente el `:search`… y date cuenta de
    que el `:search` built-in busca en **todas** las columnas, no solo en estado.
    ¿Por qué no sirve un `v-select` conectado a `:search`? (Pista: necesitas
    `custom-filter` o filtrar los `items` antes con un computed.)
12. Resuelve lo anterior: filtra por estado con un computed `visibleTickets`
    (`allTickets` + `statusFilter`) y pásalo como `:items`. El `:search` de texto se
    queda para el título. Dos filtros, dos mecanismos. Explica por qué.
13. Formatea `createdAt` con un slot que muestre "hace 2 días / hace 3 horas"
    calculado a mano (sin moment.js), reutilizando la lógica del ejercicio 22 de F4.
14. Añade `loading-text="Cargando tickets..."` y prueba a poner `:loading="true"`
    fijo para ver la barra. ¿Es lineal o circular? ¿Dónde aparece?
15. Haz clicable toda la fila con `@click:row` para navegar al detalle, pero que el
    botón de editar **no** navegue. Resuelve el conflicto de propagación (`.stop`).
16. Añade una columna virtual "Antigüedad (días)" con `value: "ageDays"` que **no
    existe** en el ticket, resuelta con un slot `item.ageDays` que calcula la
    diferencia de fechas. ¿Se puede ordenar por ella? ¿Por qué no directamente?
17. Personaliza el footer con `footer-props` para ocultar "Filas por página" y ver
    solo la navegación. ¿Cuándo querrías esto?

**🟠 Difícil (18–23)**

18. Selección múltiple: activa `show-select`, `v-model` a un array `selected`, y
    muestra "N seleccionados" arriba. `item-key` tiene que ser correcto o la
    selección "salta". Demuéstralo poniendo `item-key="title"` con dos títulos
    iguales.
19. Filas expandibles: `show-expand` + slot `expanded-item` que muestre la
    `description` del ticket. ¿Dónde vive el estado de "qué fila está expandida"?
    ¿Store o local? Aplica la regla de F10.
20. `custom-filter`: escribe una función de filtrado que ignore acentos (buscar
    "impresora" encuentra "Impresóra"). Conéctala al `:search`. Comenta por qué el
    filtro built-in no lo hace solo.
21. Estilo condicional de fila: usa `item-class` (o el slot `item`) para pintar de
    fondo tenue las filas de prioridad `high`. Hazlo con una **clase del tema**
    (`error--text` / `red lighten-5`), no con una clase Bootstrap. Enlaza con §4.4.
22. Persiste el estado de la tabla en la URL: `/tickets?page=3&sort=title&desc=1`.
    Usa `:options.sync` (Opción B), un watcher sobre `options` que haga
    `router.replace`, y restaura desde `$route.query` en `created`. Nota: esto
    necesita Opción B **aunque** no uses Vuex — la URL es el "store".
23. Ordenamiento personalizado: haz que la columna `priority` ordene por severidad
    real (`high > medium > low`), no alfabética. Pista: `sort` en el header o un
    `custom-sort`. Alfabéticamente "high" < "low" < "medium" y queda absurdo.

**🔴 Muy difícil (24–28)**

24. Implementa el **modo server-side completo**: `:server-items-length`,
    `@update:options`, la action `fetchTicketsPaged`, el mapeo de `X-Total-Count` en
    el service, y el `loading` del store. Mídelo con el interceptor de tiempos (F3,
    ej. 20). Luego responde: para 40 tickets, ¿mejoró algo? ¿Empeoró? Cinco líneas.

25. Control de la tabla **desde fuera** (el precio de la Opción A): añade un botón
    "Primera página" **fuera** del `v-data-table`. En Opción A el estado es interno,
    así que necesitas `$refs` o subir a `:options.sync`. Impleméntalo de las dos
    formas y escribe cuál preferirías mantener y por qué.

26. ⭐ **La decisión defendida (el gemelo del ejercicio de F10).** Escribe
    `TABLE-STATE-DECISION.md`: una tabla con cada pieza de estado de la tabla
    (`page`, `itemsPerPage`, `sortBy`, `sortDesc`, `search`, `serverItemsLength`,
    `selected`) y para cada una: ¿local del componente, local del `v-data-table`, o
    store? Aplica las cuatro preguntas de F10. **Y luego un párrafo defendiendo tu
    conclusión global.** Puede contradecir la de §4.5. Lo que no puede es decir
    "depende del caso".

27. El `search` de la tabla y las métricas de F7. En F10 decidiste que `search` era
    local. Pero ahora **las métricas de F7 quieren pintar solo los tickets
    filtrados**. Ahora sí lo lee otra vista. La regla de F10 dice: al store. Hazlo. Y
    responde: **¿cambia eso tu decisión sobre el estado de la tabla (ej. 26)?** ¿Por
    qué sí o por qué no?

28. ⭐ **EL EJERCICIO DE LA FASE — Migración transversal sin guía**

    > **Migra el panel de soporte (F9) a Vuetify. Tú solo.**

    Reglas:

    1. **Escribe TÚ los tests de regresión primero.** Antes de tocar una línea de
       `SupportView.vue`. Con lo de VU0: comportamiento observable, `data-testid`,
       contrato con el store, contrato con el service. **No** clases de Bootstrap.
       **No** estructura del DOM. Y ojo con lo tuyo de VU0: `<v-app>` obligatorio
       puede romper el `mount()` — resuélvelo sin acoplar el test al framework.
    2. **No hay guía.** El panel de F9 tiene: cola de tickets (¿`v-data-table`?
       ¿`v-list`? **decide tú**), asignación de agente (¿`v-select`?), comentarios
       (¿lista? ¿`v-timeline`, adelantando VU4?), cambio de estado.
    3. **El modal de comentarios se queda en Bootstrap.** No lo migres. Demuestra con
       un test que sigue funcionando.
    4. **El socket de F8 no se toca.** El `socketPlugin` de F10 sigue commiteando. Si
       tu migración obliga a tocar el plugin, **la migración está mal**.
    5. **Los tests deben pasar al final.** Si alguno no pasa: arregla el código, o
       **demuestra por escrito que el test estaba mal**.

    **Entregable — `MIGRACION-F9.md`:** qué se rompió (lista literal), cuántos tests
    fallaron al primer intento y cuántos eran culpa del test (acoplado al DOM) vs del
    código (regresión real), qué componentes sobrevivieron intactos y por qué,
    cuántas líneas borraste (netas), dónde tuviste que tocar el store (y si la
    respuesta es "en ningún sitio", **por qué esa es la nota más importante**), qué
    dejaste en Bootstrap y por qué (sin decir "por falta de tiempo").

    > 🎯 **Este es el examen de la ruta.** VU0 te enseñó a tejer la red. VU1, a leer.
    > VU2 y VU3, a migrar con guía. Aquí no hay red que no hayas tejido tú ni guía que
    > no seas tú. **Si el store no se entera de que has migrado el panel entero:
    > aprobaste.**

> 💸 **El otro ejercicio 🔴 obligatorio vive en el puente (§9): configurar
> a-la-carte y medir el bundle.** Paga la deuda de VU1. No lo pierdas de vista: es
> propio de esta ruta y Quasar no lo tiene.

---

## 📚 8. Referencias

> ⚠️ **`vuetifyjs.com` (dominio raíz) sirve la documentación de Vuetify 3 (Vue 3).**
> Tú necesitas **v2**: usa **`v2.vuetifyjs.com`**. Si acabas en una página con
> `<script setup>`, Composition API o props que no reconoces, **estás en la doc
> equivocada**.

**v-data-table (v2)**
- Introducción y props — https://v2.vuetifyjs.com/en/components/data-tables/
- `headers` (formato del objeto) — https://v2.vuetifyjs.com/en/api/v-data-table/#props-headers
- Paginación y `options` — https://v2.vuetifyjs.com/en/api/v-data-table/#props-options
- **Server-side (`server-items-length`, `@update:options`)** — https://v2.vuetifyjs.com/en/components/data-tables/#server-side-paginate-and-sort
- Slots (`item.<name>`, `no-data`, `no-results`) — https://v2.vuetifyjs.com/en/api/v-data-table/#slots
- `custom-filter` y `custom-sort` — https://v2.vuetifyjs.com/en/api/v-data-table/#props-custom-filter

**Componentes relacionados (v2)**
- v-chip (los badges) — https://v2.vuetifyjs.com/en/components/chips/
- v-select — https://v2.vuetifyjs.com/en/components/selects/
- v-icon (MDI) — https://v2.vuetifyjs.com/en/components/icons/
- v-container / v-row / v-col (grid, el que choca con Bootstrap) — https://v2.vuetifyjs.com/en/components/grids/

**Theming (el diferencial de esta ruta)**
- Theme configuration (`theme.themes.light.*`) — https://v2.vuetifyjs.com/en/features/theme/
- Colores de Material — https://v2.vuetifyjs.com/en/styles/colors/
- Dark mode (`$vuetify.theme.dark`) — https://v2.vuetifyjs.com/en/features/theme/#customizing

**A-la-carte y bundle (la deuda 💸, ejercicio del puente)**
- `vuetify-loader` (tree-shaking) — https://v2.vuetifyjs.com/en/features/treeshaking/
- Guía de instalación a-la-carte — https://v2.vuetifyjs.com/en/features/treeshaking/#manual-imports

**Vue 2 (el sustrato que no cambia)**
- Modificador `.sync` — https://v2.vuejs.org/v2/guide/components-custom-events.html#sync-Modifier
- Slots con scope — https://v2.vuejs.org/v2/guide/components-slots.html#Scoped-Slots
- Computed con getter y setter — https://v2.vuejs.org/v2/guide/computed.html#Computed-Setter

**Vuex 3**
- Strict mode — https://v3.vuex.vuejs.org/guide/strict.html
- Formas de commitear — https://v3.vuex.vuejs.org/guide/mutations.html

**Bootstrap 4 (lo que sigue vivo — crudo, con jQuery, como en A1/F5)**
- Modal (`$('#id').modal('show')`) — https://getbootstrap.com/docs/4.6/components/modal/
- Grid de Bootstrap 4 — https://getbootstrap.com/docs/4.6/layout/grid/

**json-server (la deuda 💸)**
- Paginación (`_page`, `_limit`) y `X-Total-Count` — https://github.com/typicode/json-server/tree/v0.16.3#paginate
- Búsqueda full-text (`?q=`) — https://github.com/typicode/json-server/tree/v0.16.3#full-text-search

**axios / CORS (los dos fallos con nombre propio)**
- Headers de respuesta (normalizados a minúsculas) — https://github.com/axios/axios#response-schema
- `Access-Control-Expose-Headers` — https://developer.mozilla.org/es/docs/Web/HTTP/Headers/Access-Control-Expose-Headers

---

## 🌉 9. Cierre y puente a VU4

### Lo que te llevas

**Borraste ~150 líneas.** Filtro, orden, paginación, los dos watchers que parcheaban
los bugs de la paginación, y el markup de la `<table>` con sus flechitas. Todo eso lo
hace `v-data-table`. **Y lo hace mejor que tú**, porque lo han depurado miles de
proyectos.

**Migraste los badges al tema.** Esto Quasar no te lo pidió, y es el sello de esta
ruta: `TicketStatusBadge` ya no sabe qué es "rojo"; sabe qué es `error`, y `error`
vive en un solo sitio. Cambia el tema, cambian los badges. Dark mode gratis. El
theming en JS de VU1 dejó de ser teoría.

**Cediste el control del estado de la tabla.** Ese es el precio, y lo pagaste a
conciencia: `v-data-table` es el dueño de su `options`, y ese estado **no se ve en
las devtools de Vuex**. Lo defendiste por escrito. Puedes cambiar de opinión mañana —
pero sabrás qué cambias y qué cuesta.

**Y viste el flujo completo.** Un `<v-btn>` que abre un modal Bootstrap con jQuery,
que contiene un `<v-form>` que emite un evento Vue que dispatchea a Vuex que repinta
un `<v-data-table>`. Ocho saltos, dos frameworks de UI, jQuery en medio. **Y el store
no se enteró de ninguno.** Si tu arquitectura está bien, la capa de UI es
reemplazable por trozos. El día que esto migre a Vue 3 — o a lo que venga en 2029 —
el store, los services y el interceptor van a sobrevivir. Los componentes no. Y está
bien: los componentes son lo barato.

### 💸 La deuda que se paga aquí mismo — el ejercicio 🔴 de a-la-carte

Antes de cerrar, **paga la deuda de VU1**. En VU1 importaste Vuetify entero
(`import Vuetify from "vuetify/lib"` con todo el CSS) para no distraerte, y quedó
anotado: ~500kb en el bundle.

> **Ejercicio 🔴 (propio de VU, Quasar no lo tiene):**
> 1. Mide el bundle **ahora**: `vue-cli-service build --report` (o
>    `webpack-bundle-analyzer`). Anota el tamaño de `vuetify`.
> 2. Configura **a-la-carte** con `vuetify-loader`: importa solo los componentes que
>    usas (`VDataTable`, `VChip`, `VBtn`, `VTextField`, `VContainer`…). El loader
>    hace tree-shaking automático de los componentes que referencias en templates.
> 3. Mide **otra vez**. Anota la diferencia.
> 4. Escribe cinco líneas: ¿cuánto ahorraste? ¿qué se rompió al pasar a a-la-carte
>    (spoiler: algún componente que usabas sin darte cuenta)? ¿vale la pena para el
>    Mini Jira? ¿y para un proyecto de 200 pantallas?

Esto **es** el diferencial de bundle de la ruta VU. En Quasar el tree-shaking venía
de fábrica; en Vuetify 2 es una decisión que tomas tú, y si no la tomas, arrastras
medio megabyte que nadie usa. Legacy real.

### El puente

Hasta aquí, todo lo que has hecho es **traducir**.

F5 → `v-form`. F4 → `v-data-table`. Los badges → el tema. F9 → lo que decidiste en el
ejercicio 28. En todos los casos había un original. Sabías cómo tenía que quedar,
porque lo tenías delante. Si algo se rompía, comparabas.

**Eso es una muleta.** Y muy buena — es exactamente lo que harás los primeros seis
meses en un proyecto legacy: leer lo que hay, entenderlo, cambiarlo por algo
equivalente.

Pero llega el día en que te piden **algo que no existe**. Un requisito nuevo. Y
entonces no hay original que copiar, no hay test de regresión que te diga si te
desviaste, y no puedes decir "es que antes funcionaba así". Tienes que **abrir la doc
de Vuetify y construir**.

**Eso es VU4.**

> **VU4 — Timeline de actividad.** Una feature que **no está en el curso base**.
> Aterriza los WebSockets de F8 en algo visual: `v-timeline`, `v-timeline-item`,
> `v-chip`, un modelo de datos nuevo (`activity`), y la decisión de F10 aplicada a un
> caso virgen — **¿el timeline vive en Vuex o es local?** Sin original que copiar.
> Sin trampa.
>
> Y ahí el theming se cobra en serio: el color de cada entrada del timeline sale del
> tema (`primary`, `warning`, `error`), no de clases. Cambia el tema → cambia el
> timeline entero. Dark mode incluido. **Vuetify puro. Sin traducir nada.**

Ahí, con el timeline pintándose en vivo, vas a descubrir si de verdad aprendiste
Vuetify… o si solo aprendiste a traducir de Bootstrap.

---

> 💸 **Deudas abiertas al cerrar VU3**
>
> | Deuda | Qué falta | Quién lo paga en producción |
> |---|---|---|
> | `X-Total-Count` → `serverItemsLength` | Mapeo a mano en el service. Y CORS con `Access-Control-Expose-Headers`. | **Backend**: te da el total en el body o en un header expuesto. Y lo acordáis **antes**. |
> | Server-side implementado pero no usado | El Mini Jira usa modo cliente (40 tickets). | Nadie. **El día que sean 40.000, el interruptor ya está montado.** |
> | Bundle a-la-carte | Si NO hiciste el ejercicio 🔴: ~500kb de Vuetify entero. | **Tú.** Y cada segundo de carga, tus usuarios. |
> | Bootstrap y Vuetify conviviendo | ~190KB de CSS y `.row` a tres bandas que nadie se atreve a tocar. | **Nadie, nunca.** Y no pasa nada. Bienvenido al legacy. |
