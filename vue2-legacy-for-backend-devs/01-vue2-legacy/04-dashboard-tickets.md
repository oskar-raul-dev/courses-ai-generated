# 📋 Fase 4 — Dashboard de tickets mínimo

## 🎯 Propósito

Convertir la lista fea de la Fase 3 en un **dashboard que parezca una mesa de
soporte de verdad**: tabla, badges de estado y prioridad, tarjetas resumen,
búsqueda y filtros.

Pero el dashboard es la excusa. Lo que realmente se aprende aquí es el pan de
cada día del frontend legacy:

- **computed properties** como motor de filtrado y derivación de datos;
- **props abajo, eventos arriba**: el patrón de comunicación entre componentes;
- **filtros de Vue 2** (los `| filter` de la época, hoy extintos pero vivísimos
  en cualquier base legacy);
- la decisión **filtrar en cliente vs filtrar en servidor**.

> La regla de la fase: la vista orquesta, los componentes presentan,
> los computed derivan. Nadie duplica estado.

---

## ✅ Qué queda listo al terminar

- tabla de tickets con Bootstrap (`table`, `thead`, filas clicables);
- badges de color por estado y prioridad como componentes reutilizables;
- tarjetas resumen con conteos por estado;
- búsqueda por texto y filtro por estado **en cliente** con computed;
- fecha formateada con un filtro de Vue 2;
- estado vacío ("no hay resultados") bien manejado;
- criterio claro de cuándo filtrar en cliente y cuándo en servidor.

## 🚫 Qué NO entra todavía

- crear/editar/eliminar tickets (Fase 5);
- paginación (ejercicio 🔴 para valientes);
- ordenamiento por columna completo (ejercicio 🟠);
- gráficos (Fase 7);
- mover tickets al store (Fase 10 decide eso con criterio).

---

## 🧠 Concepto 1: computed properties a fondo

Ya usamos `computed` de pasada. Ahora es la herramienta central.

```js
computed: {
  filteredTickets: function () {
    // se recalcula SOLO si cambia this.tickets, this.search o this.statusFilter
    var self = this;
    return this.tickets.filter(function (t) {
      return t.title.toLowerCase().indexOf(self.search.toLowerCase()) !== -1;
    });
  }
}
```

Lo que hay que entender:

| | `computed` | `method` |
|---|---|---|
| Caché | ✅ se recalcula solo si cambian sus dependencias reactivas | ❌ se ejecuta en cada render |
| Se usa como | propiedad: `{{ filteredTickets }}` | llamada: `{{ filterTickets() }}` |
| Ideal para | **derivar** datos del estado | acciones, handlers, cosas con argumentos |
| Efectos secundarios | 🚫 jamás (no mutar, no HTTP, no `this.x =`) | permitidos |

**La regla de oro:** el estado guarda lo *crudo* (`tickets`, `search`,
`statusFilter`); los computed derivan lo *presentable* (`filteredTickets`,
`countByStatus`). Si te descubres copiando `tickets` a `filteredTickets` en
`data` y sincronizándolos a mano con watchers… detente: eso es un computed.

## 🧠 Concepto 2: props abajo, eventos arriba

El patrón de comunicación de Vue (y el que más se viola en legacy):

```
        props (datos)  ↓
  Padre ─────────────────→ Hijo
        ←─────────────────
        $emit (eventos) ↑
```

- El padre **pasa datos** por props. El hijo los trata como **solo lectura**.
- El hijo **avisa** lo que pasó con `$emit("algo", payload)`. El padre decide
  qué hacer.
- El hijo **nunca** muta una prop ni navega ni hace HTTP por su cuenta si es
  un componente de presentación.

Cuando en una base legacy ves un hijo mutando props o metiéndose con
`this.$parent`, encontraste el origen de la mitad de los bugs del sprint.

## 🧠 Concepto 3: filtros de Vue 2 (sabor de época puro)

Vue 2 tiene "filters" para formatear en el template con pipe:

```html
<td>{{ ticket.createdAt | formatDate }}</td>
```

```js
// main.js — filtro global
Vue.filter("formatDate", function (value) {
  if (!value) return "";
  var d = new Date(value);
  return d.toLocaleDateString("es-CO", {
    year: "numeric", month: "short", day: "numeric"
  });
});
```

⚰️ Dato importante: los filters **fueron eliminados en Vue 3**. Pero en bases
2018–2021 están por todas partes (`| currency`, `| uppercase`, `| truncate`),
así que hay que saber leerlos y escribirlos. La alternativa moderna es un
computed o un method — lo comparamos en el ejercicio 21.

---

## 🧩 Mini repaso: los `.vue` de esta fase (lo nuevo respecto a la Fase 3)

Antes de leer el código, la mecánica de Vue que estrena esta fase:

### ¿Cómo sabe un computed cuándo recalcularse? (reactividad en 1 minuto)

Magia no es. En Vue 2, cada propiedad de `data` se envuelve con
getters/setters (vía `Object.defineProperty`). Cuando un computed se ejecuta,
Vue **anota qué propiedades leyó** — esas son sus dependencias. Cuando alguna
cambia (se ejecuta su setter), Vue marca el computed como sucio y lo
recalcula en el próximo acceso.

```
data: tickets, search, statusFilter        ← observados por Vue
                 │
                 ▼ (los LEE al ejecutarse → quedan registrados)
computed: filteredTickets
                 │
                 ▼ (el template lo lee)
render de la tabla
```

Consecuencias prácticas:

- escribir en el input → `v-model` asigna a `search` → su setter avisa →
  `filteredTickets` se recalcula → la tabla se repinta. **Cero código tuyo.**
- si el computed no lee una propiedad (p. ej. está detrás de un `if` que no
  entró), un cambio en ella **no** dispara recálculo — origen de bugs sutiles;
- ⚠️ límite famoso de Vue 2: agregar una propiedad **nueva** a un objeto ya
  observado (`this.ticket.nuevoCampo = x`) o asignar por índice a un array
  (`this.tickets[3] = t`) NO es reactivo. Para eso existe
  `Vue.set(obj, "campo", valor)` / `this.$set(...)`. En legacy verás `$set`
  por todas partes: ahora sabes por qué.

### `:class` — las tres sintaxis

Esta fase usa dos; conviene reconocer las tres:

```vue
<!-- 1. String desde un computed (los badges): la clase completa se calcula -->
<span class="badge" :class="badgeClass">

<!-- 2. Objeto: cada clase se prende/apaga con un boolean (la usará la Fase 5) -->
<tr :class="{ 'table-danger': ticket.priority === 'high' }">

<!-- 3. Array: combinar las anteriores -->
<span :class="['badge', badgeClass, { 'badge-pill': rounded }]">
```

En todas, Vue **fusiona** con el `class` estático: `class="badge"` +
`:class="badgeClass"` conviven sin pisarse.

### `$emit` — el hijo avisa, el padre decide (versión corta)

En `TicketsTable`, la fila hace esto:

```vue
<tr @click="$emit('select', ticket)">
```

Dos cosas encadenadas: el **click nativo** en el `<tr>` dispara un
`$emit('select', ticket)` — un **evento personalizado** que solo escucha el
padre directo, con el ticket como payload:

```vue
<tickets-table :tickets="filteredTickets" @select="goToDetail" />
<!-- goToDetail(ticket) recibe el payload automáticamente -->
```

La tabla no sabe qué pasará con el clic (¿navegar? ¿abrir modal? ¿seleccionar
para borrado masivo?). Por eso es reutilizable. *(La Fase 5 profundiza en
nativos vs personalizados; aquí basta con este uso.)*

### `:key` en `v-for` — no es decorativo

```vue
<tr v-for="ticket in tickets" :key="ticket.id">
```

El `:key` le da identidad a cada nodo para que Vue, al cambiar la lista
(filtrar, reordenar), **mueva y reutilice** filas en vez de reciclarlas por
posición. Sin key (o con el índice como key en listas que cambian), Vue
recicla por posición y aparecen los bugs fantasma clásicos: estados internos
o inputs que "se quedan" en la fila equivocada al filtrar. Regla: **key =
identificador estable del dato** (el `id`), nunca el índice si la lista se
filtra u ordena.

### Registro local y carpetas por dominio

```js
import TicketStatusBadge from "./TicketStatusBadge.vue";
export default { components: { TicketStatusBadge } };
```

Registro **local**: el componente solo existe donde se importa. La
alternativa de la época — `Vue.component("ticket-status-badge", ...)` global
en `main.js` — se ve mucho en legacy y tiene el costo de que nadie sabe de
dónde salen los componentes ni quién los usa. Preferimos local + la carpeta
por dominio (`components/tickets/`): cuando un dominio junta 3+ piezas, se
gana su carpeta.

---

## 💻 Código de la fase

### Estructura que se agrega

```
src/
  components/
    tickets/
      TicketStatusBadge.vue     ← nuevo
      TicketPriorityBadge.vue   ← nuevo
      TicketsTable.vue          ← nuevo
      TicketsSummary.vue        ← nuevo
```

(Sub-carpeta `tickets/` dentro de `components/`: cuando un dominio junta 3+
componentes, se gana su carpeta.)

### `components/tickets/TicketStatusBadge.vue`

```vue
<template>
  <span class="badge" :class="badgeClass">{{ label }}</span>
</template>

<script>
var STATUS_MAP = {
  open:        { label: "Abierto",     css: "badge-danger" },
  in_progress: { label: "En progreso", css: "badge-warning" },
  resolved:    { label: "Resuelto",    css: "badge-success" },
  closed:      { label: "Cerrado",     css: "badge-secondary" }
};

export default {
  name: "TicketStatusBadge",
  props: {
    status: { type: String, required: true }
  },
  computed: {
    badgeClass: function () {
      var entry = STATUS_MAP[this.status];
      return entry ? entry.css : "badge-light";
    },
    label: function () {
      var entry = STATUS_MAP[this.status];
      return entry ? entry.label : this.status;
    }
  }
};
</script>
```

Detalles con intención:

- el **mapa de configuración** arriba del componente en vez de un `if/else`
  gigante en el template: patrón clásico y fácil de extender;
- si llega un estado desconocido, no revienta: badge gris con el valor crudo;
- la prop se declara con `type` y `required` — Vue avisa en consola si el
  padre la usa mal. En legacy, esas validaciones son documentación gratis.

### `components/tickets/TicketPriorityBadge.vue`

```vue
<template>
  <span class="badge badge-pill" :class="badgeClass">{{ priority }}</span>
</template>

<script>
var PRIORITY_CSS = {
  high: "badge-danger",
  medium: "badge-warning",
  low: "badge-info"
};

export default {
  name: "TicketPriorityBadge",
  props: {
    priority: { type: String, required: true }
  },
  computed: {
    badgeClass: function () {
      return PRIORITY_CSS[this.priority] || "badge-light";
    }
  }
};
</script>
```

### `components/tickets/TicketsTable.vue`

Componente de **presentación pura**: recibe tickets, emite selección. No sabe
de rutas, HTTP ni store.

```vue
<template>
  <div>
    <table class="table table-hover table-sm">
      <thead class="thead-light">
        <tr>
          <th>#</th>
          <th>Título</th>
          <th>Estado</th>
          <th>Prioridad</th>
          <th>Asignado</th>
          <th>Creado</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="ticket in tickets"
          :key="ticket.id"
          style="cursor: pointer;"
          @click="$emit('select', ticket)"
        >
          <td>{{ ticket.id }}</td>
          <td>{{ ticket.title }}</td>
          <td><ticket-status-badge :status="ticket.status" /></td>
          <td><ticket-priority-badge :priority="ticket.priority" /></td>
          <td>{{ ticket.assignee }}</td>
          <td>{{ ticket.createdAt | formatDate }}</td>
        </tr>
      </tbody>
    </table>

    <div v-if="tickets.length === 0" class="text-center text-muted py-4">
      <p class="mb-0">🔍 No hay tickets que coincidan con los filtros.</p>
    </div>
  </div>
</template>

<script>
import TicketStatusBadge from "./TicketStatusBadge.vue";
import TicketPriorityBadge from "./TicketPriorityBadge.vue";

export default {
  name: "TicketsTable",
  components: { TicketStatusBadge, TicketPriorityBadge },
  props: {
    tickets: { type: Array, required: true }
  }
};
</script>
```

### `components/tickets/TicketsSummary.vue`

Tarjetas resumen. Recibe los tickets **completos** (no filtrados) y deriva los
conteos con un computed:

```vue
<template>
  <div class="row mb-4">
    <div class="col-6 col-md-3" v-for="card in cards" :key="card.status">
      <div class="card text-center">
        <div class="card-body py-3">
          <h2 class="mb-0">{{ card.count }}</h2>
          <small class="text-muted">{{ card.label }}</small>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "TicketsSummary",
  props: {
    tickets: { type: Array, required: true }
  },
  computed: {
    cards: function () {
      var self = this;
      var defs = [
        { status: "open", label: "Abiertos" },
        { status: "in_progress", label: "En progreso" },
        { status: "resolved", label: "Resueltos" },
        { status: "closed", label: "Cerrados" }
      ];

      return defs.map(function (def) {
        return {
          status: def.status,
          label: def.label,
          count: self.tickets.filter(function (t) {
            return t.status === def.status;
          }).length
        };
      });
    }
  }
};
</script>
```

### `views/TicketsView.vue` — la vista orquestadora

```vue
<template>
  <section>
    <page-title title="Tickets" subtitle="Mesa de soporte" />

    <!-- estado: cargando -->
    <div v-if="loading" class="text-center my-5">
      <div class="spinner-border text-primary" role="status"></div>
    </div>

    <!-- estado: error -->
    <div v-else-if="error" class="alert alert-danger">
      {{ error }}
      <button class="btn btn-sm btn-outline-danger ml-2" @click="loadTickets">
        Reintentar
      </button>
    </div>

    <!-- estado: datos -->
    <template v-else>
      <tickets-summary :tickets="tickets" />

      <div class="form-row mb-3">
        <div class="col-md-6 mb-2">
          <input
            v-model="search"
            type="text"
            class="form-control"
            placeholder="🔍 Buscar por título..."
          />
        </div>
        <div class="col-md-3 mb-2">
          <select v-model="statusFilter" class="form-control">
            <option value="">Todos los estados</option>
            <option value="open">Abiertos</option>
            <option value="in_progress">En progreso</option>
            <option value="resolved">Resueltos</option>
            <option value="closed">Cerrados</option>
          </select>
        </div>
        <div class="col-md-3 mb-2 text-right">
          <button class="btn btn-outline-secondary btn-block" @click="clearFilters">
            Limpiar filtros
          </button>
        </div>
      </div>

      <p class="text-muted small">
        Mostrando {{ filteredTickets.length }} de {{ tickets.length }} tickets
      </p>

      <tickets-table :tickets="filteredTickets" @select="goToDetail" />
    </template>
  </section>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";
import TicketsTable from "../components/tickets/TicketsTable.vue";
import TicketsSummary from "../components/tickets/TicketsSummary.vue";
import ticketService from "../services/ticketService";

export default {
  name: "TicketsView",
  components: { PageTitle, TicketsTable, TicketsSummary },
  data: function () {
    return {
      tickets: [],        // crudo: lo que devolvió la API
      search: "",         // crudo: lo que escribió el usuario
      statusFilter: "",   // crudo: lo que seleccionó
      loading: false,
      error: ""
    };
  },
  computed: {
    // derivado: nunca vive en data
    filteredTickets: function () {
      var self = this;
      var term = this.search.trim().toLowerCase();

      return this.tickets.filter(function (t) {
        var matchesSearch =
          !term || t.title.toLowerCase().indexOf(term) !== -1;
        var matchesStatus =
          !self.statusFilter || t.status === self.statusFilter;
        return matchesSearch && matchesStatus;
      });
    }
  },
  mounted: function () {
    this.loadTickets();
  },
  methods: {
    loadTickets: function () {
      var self = this;
      this.loading = true;
      this.error = "";

      ticketService
        .getTickets({ _sort: "createdAt", _order: "desc" })
        .then(function (tickets) {
          self.tickets = tickets;
        })
        .catch(function () {
          self.error = "No se pudieron cargar los tickets. ¿Está corriendo la Mock API?";
        })
        .finally(function () {
          self.loading = false;
        });
    },
    clearFilters: function () {
      this.search = "";
      this.statusFilter = "";
    },
    goToDetail: function (ticket) {
      this.$router.push("/tickets/" + ticket.id);
    }
  }
};
</script>
```

### `main.js` — registrar el filtro global

```js
import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import store from "./store";
import "bootstrap/dist/css/bootstrap.min.css";

Vue.config.productionTip = false;

// Filtro global de la época. En Vue 3 esto ya no existe.
Vue.filter("formatDate", function (value) {
  if (!value) return "";
  var d = new Date(value);
  return d.toLocaleDateString("es-CO", {
    year: "numeric", month: "short", day: "numeric"
  });
});

new Vue({
  router: router,
  store: store,
  render: function (h) {
    return h(App);
  }
}).$mount("#app");
```

**Radiografía de responsabilidades del resultado:**

| Pieza | Sabe de HTTP | Sabe de rutas | Tiene estado | Rol |
|---|---|---|---|---|
| `TicketsView` | ✅ (vía servicio) | ✅ | ✅ crudo + derivado | orquestar |
| `TicketsTable` | ❌ | ❌ | ❌ | presentar + emitir |
| `TicketsSummary` | ❌ | ❌ | ❌ (solo computed) | presentar |
| Badges | ❌ | ❌ | ❌ | presentar |
| `ticketService` | ✅ | ❌ | ❌ | acceso a datos |

Si mañana te sueltan en un legacy real, esta tabla es tu mapa mental para
saber qué pieza tocar.

---

## 🔄 Los flujos del dashboard, paso a paso

El dashboard no tiene submits ni redirecciones complejas, pero tiene algo que
el CRUD no: **cadenas reactivas**. Seguirlas evento por evento es la mejor
forma de entender (y debuggear) por qué "la tabla se actualiza sola".

### 🚀 Carga inicial

```
1. usuario navega a /tickets
   └─ guard verifica sesión → router monta TicketsView
      └─ data se inicializa: tickets=[], search="", loading=false
      └─ PRIMER RENDER: loading=false, error="", tickets=[]
         → cae en la rama de datos → summary con ceros, tabla vacía... por un instante

2. mounted → loadTickets()
   └─ loading = true  → la reactividad repinta → SPINNER visible
   └─ GET /tickets?_sort=createdAt&_order=desc (token vía interceptor)

3a. ÉXITO → .then → this.tickets = respuesta
    └─ el setter de tickets avisa a TODOS sus dependientes:
       ├─ filteredTickets (computed de la vista) se recalcula
       ├─ TicketsSummary recibe la prop nueva → su computed cards se recalcula
       └─ TicketsTable recibe filteredTickets → v-for pinta filas (cada una con su :key)

3b. ERROR → .catch → error = mensaje
    └─ el v-else-if="error" gana → alerta roja con botón Reintentar
       (Reintentar simplemente vuelve a llamar loadTickets: mismo ciclo)

4. siempre → .finally → loading = false → se va el spinner
```

El detalle del paso 1 (ese render con tabla vacía antes del `mounted`) casi
nunca se ve porque `loading` se prende enseguida — pero existe, y explica
parpadeos en apps legacy lentas. Solución de la época si molesta: inicializar
`loading: true` en `data`.

### 🔍 Escribir en la búsqueda (la cadena reactiva pura)

```
1. usuario teclea "imp" (tres eventos nativos "input", uno por tecla)
   └─ v-model asigna: search="i" → search="im" → search="imp"

2. cada asignación dispara el setter reactivo de search
   └─ filteredTickets estaba anotado como dependiente (leyó this.search)
      → se marca sucio → se recalcula: filter por título + estado

3. el template lee filteredTickets en dos lugares:
   ├─ el contador "Mostrando X de Y" se actualiza
   └─ TicketsTable recibe la prop nueva
      └─ v-for reconcilia por :key → Vue MUEVE/quita filas, no las reconstruye

4. si el filtro deja 0 resultados
   └─ tickets.length === 0 dentro de TicketsTable → estado vacío 🔍
```

Nota lo que NO hay: ni watchers, ni llamadas manuales a "refrescarTabla()",
ni eventos entre componentes. **Estado crudo cambia → derivados se recalculan
→ UI se repinta.** Ese es el contrato reactivo, y romperlo (duplicando
`filteredTickets` en `data`, error común #1) es volver a sincronizar a mano.

Ojo también al paso 2: se recalcula el filtro **en cada tecla**. Con 50
tickets, gratis; con 5.000, se siente — de ahí el debounce del ejercicio 19.

### 🖱️ Clic en una fila (el viaje del evento)

```
1. clic sobre cualquier <td> de la fila
   └─ el evento nativo "click" BURBUJEA hasta el <tr> que tiene @click

2. el <tr> ejecuta $emit('select', ticket)
   └─ evento PERSONALIZADO: no burbujea más allá del padre directo
   └─ payload: el objeto ticket completo de esa fila (cortesía del v-for)

3. TicketsView lo escucha: @select="goToDetail"
   └─ goToDetail(ticket) recibe el payload → $router.push("/tickets/" + ticket.id)

4. el router hace su parte:
   └─ guard (requiresAuth ✓) → DESTRUYE TicketsView → monta TicketDetailView
      └─ los filtros y la búsqueda SE PIERDEN (estado local muere con la vista)
         → exactamente el problema que resuelve el ejercicio 13 (filtros en la URL)
```

El paso 4 esconde la lección de arquitectura de la fase: el estado local es
barato y suficiente… hasta que quieres que sobreviva a la navegación.
Opciones legacy, de más simple a más pesada: query params en la URL
(ejercicio 13) → sessionStorage → Vuex (Fase 10 decide con criterio).

### 🎚️ Cambiar el `<select>` de estado

```
1. usuario elige "Abiertos"
   └─ evento nativo "change" → v-model asigna statusFilter="open"
2. misma cadena que la búsqueda: setter → filteredTickets → contador + tabla
3. "Limpiar filtros" no tiene magia: clearFilters() asigna search="" y
   statusFilter="" → dos setters → un recálculo → todo vuelve
```

Búsqueda y select comparten **el mismo computed**: combinar filtros costó un
`&&`. Cuando en la fase que viene agregues el de prioridad (ejercicio 9),
será otro `&&`. Esa es la promesa del cierre de la fase, cumplida por diseño.

---

## ⚖️ Filtrar en cliente vs filtrar en servidor

En la Fase 3 (ejercicio 10) filtraste con `?status=open` (servidor). Hoy
filtraste con computed (cliente). ¿Cuál va cuándo?

| | 🖥️ Cliente (computed) | 🌐 Servidor (query params) |
|---|---|---|
| Cómo | traer todo una vez, filtrar en memoria | un request por cada cambio de filtro |
| Velocidad al filtrar | instantánea, sin red | latencia de red en cada cambio |
| Volumen de datos | ⚠️ solo viable con cientos, no miles | ✅ escala a millones |
| Datos frescos | los del último load (pueden quedar stale) | frescos en cada filtro |
| Complejidad del front | un computed | manejar loading en cada cambio, debounce |
| Combinar filtros | trivial (un `&&` más) | armar params, cuidar el contrato |
| Típico en | dashboards internos, catálogos chicos | listados grandes, buscadores |

**Regla práctica legacy:** si la API devuelve < ~500 registros y no crece,
cliente y a dormir tranquilo. Si el dataset crece sin techo, servidor. Y el
híbrido más común de la época: **servidor para el corte grueso** (ej. "mis
tickets del último mes") **+ cliente para el refinamiento fino** (búsqueda por
texto sobre eso).

---

## ⚠️ Errores comunes

- duplicar estado: guardar `filteredTickets` en `data` y sincronizarlo con
  watchers — es la fuente #1 de "la tabla no refleja lo que hay";
- mutar props en los componentes hijos (Vue lo grita en consola: hazle caso);
- meter la navegación o el HTTP **dentro** de `TicketsTable` — muere la
  reutilización;
- computed con efectos secundarios (mutar estado, disparar requests): los
  computed derivan, no actúan;
- olvidar el `:key` en `v-for` o usar el índice como key en listas que cambian;
- olvidar el estado vacío: una tabla sin filas y sin mensaje parece un bug;
- abusar de filters de Vue 2 para lógica compleja: son para formateo cosmético.

---

## 🧪 Ejercicios (26)

**🟢 Fácil (1–8)**

1. Agrega el estado `closed` a un par de tickets en `db.json` y verifica que
   el badge sale gris y la tarjeta resumen cuenta bien.
2. Agrega una columna "Reportado por" (`reporter`) a la tabla.
3. Cambia el placeholder de búsqueda y haz que también busque en `description`.
4. Agrega un filtro `| uppercase` global y úsalo en la columna de asignado.
5. Haz que la tarjeta de "Abiertos" tenga borde rojo (`border-danger`).
6. Muestra "1 ticket" vs "N tickets" (singular/plural) en el contador de
   resultados.
7. Agrega un botón "Recargar" junto a los filtros que llame a `loadTickets`.
8. Haz clic en una tarjeta resumen y… no pasa nada. Anota qué esperarías que
   pasara (lo implementas en el ejercicio 13).

**🟡 Intermedio (9–17)**

9. Agrega un tercer filtro: `<select>` de prioridad, combinado con los otros
   dos en el mismo computed.
10. Agrega un filtro por asignado cuyo `<select>` se llene **dinámicamente**
    con un computed `assignees` (valores únicos de `tickets`, pista: `lodash
    uniq` o un objeto como set).
11. Haz que las tarjetas resumen muestren el conteo de los tickets
    **filtrados** además del total, formato "3 / 8".
12. Haz clicable cada tarjeta resumen: al hacer clic, setea `statusFilter` a
    ese estado (y clic de nuevo lo limpia — toggle).
13. Persiste los filtros en la URL como query params
    (`/tickets?status=open&q=impresora`) usando `router.replace`, y
    restáuralos en `mounted` desde `$route.query`.
14. Resalta las filas de prioridad `high` con la clase `table-danger` usando
    `:class` en el `<tr>`.
15. Agrega un filtro global `truncate` que corte títulos a 40 caracteres con
    "…". Úsalo en la tabla.
16. Crea el computed `oldestOpenTicket` que devuelva el ticket abierto más
    antiguo y muéstralo en una alerta amarilla arriba del dashboard:
    "⚠️ El ticket más antiguo sin resolver es #X (N días)".
17. Agrega un `watch` sobre `search` que loguee cada cambio en consola.
    Después responde en un comentario: ¿por qué el filtrado NO necesitó un
    watcher y sí bastó un computed? ¿Cuándo sí usarías watch?

**🟠 Difícil (18–23)**

18. Ordenamiento por columna: clic en el header ordena asc, otro clic desc,
    con indicador ▲/▼. Todo con computed (`sortBy`, `sortDir` en data;
    `sortedAndFilteredTickets` derivado). Sin librerías.
19. Implementa **debounce** en la búsqueda con `lodash.debounce`: el filtrado
    de texto se aplica 300 ms después de dejar de escribir. Pista: v-model
    contra un `rawSearch` y un método debounced que copia a `search`.
20. Extrae los filtros a un componente `TicketsFilters.vue` que reciba los
    valores por props y emita `update` con el objeto de filtros. La vista
    queda solo orquestando (props abajo, eventos arriba, en serio).
21. Reescribe `formatDate` de tres formas: filter global, method y computed
    (en un componente de prueba). Escribe en un comentario cuándo conviene
    cada una y por qué Vue 3 mató los filters.
22. Agrega la columna "Antigüedad" que muestre "hace 2 días / hace 3 horas"
    calculado a mano (sin moment.js). Bonus: investiga por qué moment.js —
    omnipresente en legacy — hoy está en modo mantenimiento.
23. Modo "solo míos": un checkbox que filtre tickets donde `assignee` sea el
    username del usuario logueado (léelo del getter `auth/currentUser`).
    Primer cruce real entre módulos. 🎉

**🔴 Muy difícil (24–26)**

24. Paginación client-side: computed `paginatedTickets` sobre los filtrados,
    selector de tamaño de página (5/10/20) y botones anterior/siguiente con
    Bootstrap `pagination`. Cuidado con el caso "estoy en la página 3 y el
    filtro deja solo 1 página".
25. Compara en serio cliente vs servidor: implementa un toggle "modo servidor"
    donde los filtros de estado y prioridad viajen como query params a
    json-server (la búsqueda de texto sigue en cliente). Mide con el
    interceptor de tiempos (Fase 3, ej. 20) y escribe 5 líneas de conclusión.
26. Auto-refresh: recarga los tickets cada 30 segundos con `setInterval`…
    hecho bien: se limpia en `beforeDestroy`, se pausa mientras `loading`,
    y **no pisa** los filtros ni el scroll del usuario. Deja un comentario
    sobre qué haría esto mal un `setInterval` ingenuo. (Spoiler de la Fase 8:
    los WebSockets matan este patrón.)

---

## 📚 Referencias

**Documentación oficial**

- Vue 2 — Computed y Watchers: https://v2.vuejs.org/v2/guide/computed.html
- Vue 2 — Reactivity in Depth (cómo funciona por dentro):
  https://v2.vuejs.org/v2/guide/reactivity.html
- Vue 2 — Change Detection Caveats (Vue.set y los límites de la reactividad):
  https://v2.vuejs.org/v2/guide/reactivity.html#Change-Detection-Caveats
- Vue 2 — Props: https://v2.vuejs.org/v2/guide/components-props.html
- Vue 2 — Eventos personalizados ($emit): https://v2.vuejs.org/v2/guide/components-custom-events.html
- Vue 2 — Filters: https://v2.vuejs.org/v2/guide/filters.html
- Vue 2 — List Rendering y :key: https://v2.vuejs.org/v2/guide/list.html
- Vue 2 — Class y Style bindings: https://v2.vuejs.org/v2/guide/class-and-style.html
- Bootstrap 4.6 — Tables: https://getbootstrap.com/docs/4.6/content/tables/
- Bootstrap 4.6 — Badges: https://getbootstrap.com/docs/4.6/components/badge/
- Bootstrap 4.6 — Cards: https://getbootstrap.com/docs/4.6/components/card/
- Lodash — debounce: https://lodash.com/docs/4.17.15#debounce

**Video / apoyo**

- Vue Mastery — Intro to Vue 2 (lecciones de computed y components):
  https://www.vuemastery.com/courses/intro-to-vue-js/vue-instance/
- Net Ninja — Vue JS 2: episodios de props y eventos (playlist en YouTube)

**Orden de lectura sugerido:** Computed y Watchers → Props → Custom Events →
volver al código. Filters solo como lectura de reconocimiento.

---

## 🚀 Cierre

Al final de esta fase el Mini Jira ya tiene cara de producto: tarjetas resumen,
tabla con badges, búsqueda y filtros instantáneos. Y tú tienes tres armas que
valen para cualquier base legacy:

- **computed** para derivar sin duplicar estado,
- **props abajo / eventos arriba** para componer sin acoplar,
- el **criterio cliente vs servidor** para filtrar donde toca.

La señal de que quedó bien:

> "puedo agregar un filtro nuevo tocando un `&&` en un computed,
> y un componente nuevo sin que la tabla se entere de rutas ni HTTP".

**Siguiente parada:** 📝 Fase 5 — CRUD de tickets: crear, editar y eliminar
con formularios validados por vuelidate (por fin paga la instalación que
hicimos en la Fase 0 🎉).
