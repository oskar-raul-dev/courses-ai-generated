# 📋 Fase Q3 — Migrar el dashboard a QTable

> El componente quiere el estado que tu Vuex ya controla. **¿Quién manda?**

**Migra:** F4 (Dashboard) · **Consume en tensión directa:** F10 (Vuex)
**Prerequisitos:** Q0 (red de seguridad), Q1 (leer Quasar), Q2 (CRUD → QForm)

---

## 🎯 1. Propósito

Esta es **la fase núcleo de la ruta Q**. Aquí pasan dos cosas a la vez, y la
segunda es la que importa.

La primera es un **borrado**. El dashboard de F4 tiene filtro manual, orden
manual y (si hiciste el ejercicio 🔴 de F4) paginación manual. `QTable` trae las
tres de fábrica. Vas a borrar ~150 líneas de código tuyo, funcionando y probado.
Eso se siente raro. Debe sentirse raro.

La segunda es un **conflicto de propiedad**. `QTable` no es un `<table>` con
estilos: es un componente **con estado propio**. Quiere saber en qué página
estás, por qué columna ordenas y cuántas filas caben. Tu store de F10 **también**
quiere saberlo — o al menos, tú decidiste en F10 que ciertas cosas viven en Vuex
y otras no, y lo defendiste por escrito.

Ahora llega un componente de terceros que trae su propia opinión sobre dónde vive
el estado. **No puedes tener las dos.** O cedes el control a `QTable`, o se lo
quitas y lo devuelves al store. Ambas se pagan.

Esto no es un detalle de configuración. **Es la fase entera.**

---

## ✅ 2. Qué queda listo al terminar

- `TicketsView` renderizando un **`QTable`** con `columns`, `rows`, `row-key`.
- El **filtro, el orden y la paginación manuales de F4: borrados.** Sin sustituto
  propio. El componente los hace.
- Los **badges de estado y prioridad de F4 intactos**, montados dentro de
  `QTable` vía el slot `body-cell-status`. Los componentes de F4 no se tocan.
- El dashboard funcionando en **modo cliente** (`QTable` pagina en memoria) **y**
  en **modo server-side** (`@request`, `loading`, `rowsNumber`) — con la decisión
  de cuál usar tomada y defendida.
- Una **decisión escrita** sobre quién es el dueño del estado de paginación:
  `QTable` o Vuex. Con sus costes. Al estilo de la auditoría de F10.
- **Bootstrap y Quasar conviviendo en la misma vista**: `QTable` arriba,
  el modal Bootstrap de crear ticket abajo, emitiéndose eventos entre sí. Funcionando.
- Los **tests de regresión de Q0 pasando** — o rotos con motivo entendido.
- El mapeo del **`X-Total-Count`** de json-server a `rowsNumber` 💸.

---

## 🚫 3. Qué NO entra todavía

- **Componentes nuevos que no existían**: eso es Q4 (el timeline). Aquí solo se
  traduce lo que ya funcionaba.
- **Selección múltiple** (`selection`, `selected.sync`) — ejercicio 🟠, no
  contenido guiado. El Mini Jira no tiene acciones en lote.
- **Exportar a CSV / imprimir** — ejercicio 🟠.
- **`QTable` con `grid` prop** (modo tarjetas) — ejercicio 🟡. Es una vista, no
  un concepto.
- **Virtual scroll** (`virtual-scroll`) — se menciona, no se implementa. Aparece
  cuando tienes 10.000 filas; tú tienes 40.
- **Migrar el panel de soporte (F9)**: es el ejercicio 🔴 obligatorio del final.
  Tú solo. Sin guía.
- **Quitar Bootstrap del proyecto.** No se va. Todo lo contrario: aquí aprendes a
  vivir con él.

---

## 🧠 4. Concepto

### 4.1 El borrado: qué hacía F4 y quién lo hace ahora

Recordemos el dashboard de F4 (versión post-F10, con el store ya montado):

```js
// F4 + F10 — TicketsView.vue (lo que hay HOY, antes de tocar nada)
export default {
  data: function () {
    return {
      search: "",           // ← decisión de F10: NO va al store
      statusFilter: "",     // ← decisión de F10: NO va al store
      sortKey: "createdAt", // ← el orden manual
      sortOrder: "desc",
      page: 1,              // ← la paginación manual (ej. 🔴 de F4)
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

Y el template, con la `<table class="table">` de Bootstrap, las cabeceras
clicables con sus flechitas `▲▼`, el `<nav>` de paginación con los `<li
class="page-item">`… otras ~60 líneas.

**Total: ~150 líneas.** Filtro, orden, paginación, los dos watchers anti-bug, y
el markup.

De todo eso, `QTable` hace:

| Lo que tenías en F4 | Quién lo hace en Quasar |
|---|---|
| `filteredTickets` (computed) | prop `filter` + `filter-method` |
| `sortedTickets` (computed) | `columns[].sortable` + `sort-method` opcional |
| `pagedTickets` (computed) | `pagination` interna |
| `totalPages` (computed) | `pagination` interna |
| `toggleSort()` | click en la cabecera. Gratis. |
| `goToPage()` | los botones del footer. Gratis. |
| `watch: search → page = 1` | **`QTable` lo hace solo.** El bug no existe. |
| `<table>` + `<nav>` de Bootstrap | `<q-table>` |

**El borrado neto es real.** No es "escribes menos". Es: **borras código que
funcionaba, borras sus bugs, y borras los watchers que parcheaban esos bugs.**

> 🔎 **Lo que se va contigo:** también se va tu control. Ese `page = 1` del
> watcher lo escribiste **porque un tester lo reportó**. `QTable` lo hace por
> defecto. Genial — hasta el día que **no** quieras resetear la página al
> filtrar. Entonces vas a pelearte con el componente para deshacer un
> comportamiento que ni pediste ni puedes ver.

### 4.2 `QTable`: columns, rows, row-key

Tres props obligatorias. Ninguna es opcional en la práctica.

```js
// El contrato mínimo de QTable
{
  rows: Array,     // los datos. Uno por fila.
  columns: Array,  // la definición de columnas. NO es markup: es un objeto.
  "row-key": String // qué campo identifica a la fila. Único. Vital.
}
```

**`row-key` no es decorativo.** Es el `:key` del `v-for` de F4 — el mismo
concepto, el mismo problema si te lo saltas. `QTable` lo usa para:
- reconciliar el DOM cuando cambia el orden,
- identificar filas seleccionadas,
- decidir qué fila está expandida.

Si pones `row-key="title"` y dos tickets se llaman igual, tienes un bug
silencioso que aparece dentro de tres semanas. **`row-key="id"`. Siempre.**

### 4.3 El formato de `columns`

Aquí está la primera fricción de verdad. En F4, una columna era markup:

```html
<!-- F4 — Bootstrap. La columna es HTML. -->
<th @click="toggleSort('title')">Título ▲</th>
...
<td>{{ ticket.title }}</td>
```

En Quasar, una columna es **un objeto en JavaScript**:

```js
// TicketsView.vue — columns NO va en data(), va como constante del módulo.
// No es reactivo: no cambia nunca. Meterlo en data() es desperdiciar
// un observer de Vue sobre un array que jamás muta.
const COLUMNS = [
  {
    name: "id",              // identificador interno. Único. Lo usa el slot.
    label: "#",              // lo que ve el usuario en la cabecera.
    field: "id",             // de dónde saca el valor de la fila.
    align: "left",
    sortable: true
  },
  {
    name: "title",
    label: "Título",
    field: "title",
    align: "left",
    sortable: true
  },
  {
    name: "status",
    label: "Estado",
    field: "status",
    align: "center",
    sortable: true
  },
  {
    name: "priority",
    label: "Prioridad",
    field: "priority",
    align: "center",
    sortable: true
  },
  {
    name: "assignee",
    label: "Asignado",
    // field como FUNCIÓN: recibe la fila entera. Para datos anidados o derivados.
    // `assignee` es un STRING (el username) en el modelo del curso — no un objeto.
    field: function (row) {
      return row.assignee || "— sin asignar —";
    },
    align: "left",
    sortable: true
  },
  {
    name: "createdAt",
    label: "Creado",
    field: "createdAt",
    align: "right",
    sortable: true,
    // format: transforma el valor para MOSTRARLO. No afecta al orden.
    format: function (val) {
      return new Date(val).toLocaleDateString("es-ES");
    }
  }
];
```

**🔎 Qué hace, campo por campo:**

| Campo | Su trabajo | Trampa |
|---|---|---|
| `name` | ID interno de la columna. Lo usan los slots (`body-cell-status` ← `name: "status"`) y la paginación (`sortBy`). | Si lo cambias, se rompen los slots **en silencio**. |
| `label` | El texto de la cabecera. | — |
| `field` | String (clave de la fila) **o función** (`row => valor`). | Con función pierdes el orden "gratis" si el valor derivado no es comparable. |
| `align` | `left` / `center` / `right`. | **Obligatorio en la práctica.** Sin él, Quasar alinea a la derecha por defecto y tu tabla parece un extracto bancario. |
| `sortable` | `true` → cabecera clicable. | Por defecto **`false`**. Si no lo pones, la columna no ordena y nadie te avisa. |
| `format` | Transforma el valor **para pintarlo**. | **No afecta al orden.** Ordena por el valor crudo. Esto es correcto (`createdAt` ordena por fecha, no por string "10/03/2020") y es exactamente lo que quieres — pero sorprende. |

> 💡 **El `format` de `columns` es el filtro de Vue 2 de F4.**
> `{{ ticket.createdAt | formatDate }}` → `format: function (val) {...}`.
> Mismo concepto, otro sitio. Los `filters` de Vue 2 siguen funcionando en el
> resto del proyecto (F4 los usa); dentro de `QTable`, el sitio idiomático es
> `format`. **No los mezcles en la misma columna.**

### 4.4 Los slots: `body-cell-status` y los badges de F4

`format` sirve para texto. Los badges de F4 son **componentes**. Para eso están
los slots.

```html
<q-table
  :rows="allTickets"
  :columns="columns"
  row-key="id"
>
  <!--
    body-cell-<name> — el <name> es el `name` de la columna.
    Recibe un scope con: { row, col, value, rowIndex }
  -->
  <template v-slot:body-cell-status="props">
    <q-td :props="props">
      <!-- El componente de F4. Sin tocar. Ni una línea. -->
      <ticket-status-badge :status="props.row.status" />
    </q-td>
  </template>

  <template v-slot:body-cell-priority="props">
    <q-td :props="props">
      <ticket-priority-badge :priority="props.row.priority" />
    </q-td>
  </template>

  <!-- Columna de acciones: no existe en `columns`, se declara aparte -->
  <template v-slot:body-cell-actions="props">
    <q-td :props="props">
      <!-- Botón de QUASAR que abre un modal de BOOTSTRAP. Véase §4.7. -->
      <q-btn flat dense icon="edit" @click="onEdit(props.row)" />
    </q-td>
  </template>
</q-table>
```

**🔎 Qué hace:**
- `v-slot:body-cell-status` sustituye **solo** la celda de la columna `status`.
  Las demás columnas siguen renderizándose solas.
- `<q-td :props="props">` **no es opcional**. Es lo que hereda el `align`, la
  clase de la columna y el comportamiento responsive. Si escribes `<td>` pelado,
  se te descuadra la tabla en móvil y no vas a entender por qué.
- `props.row` es el objeto ticket entero. `props.value` es lo que devolvería
  `field` + `format`.

**✅ Buenas prácticas:**
- **Los badges de F4 no se migran.** Son componentes Vue, no Bootstrap. Que usen
  `class="badge badge-danger"` por dentro es irrelevante: son un contrato
  `props.status → un span de color`, y ese contrato lo cumplen igual dentro de
  `QTable`. **Migrar es cambiar el envoltorio, no repintar todo.**
- Si el slot no aparece, revisa el `name` de la columna. `body-cell-status`
  requiere `name: "status"`. Un typo aquí no da error: **renderiza la celda por
  defecto** y tú te quedas mirando la pantalla.
- La columna `actions` **sí debe existir en `columns`** (con `field: "id"` o lo
  que sea, `sortable: false`) o no aparecerá la cabecera. El slot pinta la celda;
  la columna reserva el hueco.

### 4.5 ⚔️ El conflicto: `:pagination.sync` vs el store

Aquí está la fase.

`QTable` mantiene un objeto de paginación **por dentro**:

```js
{
  sortBy: "createdAt",   // por qué columna (el `name`)
  descending: true,
  page: 1,
  rowsPerPage: 10,
  rowsNumber: 0          // solo en server-side. Véase §4.6.
}
```

Ese objeto **es estado de la aplicación**. Y tú, en F10, hiciste una auditoría de
qué estado va al store y cuál no. La regla que defendiste fue:

> **¿Lo lee más de una vista? ¿Sobrevive a la navegación? ¿Lo necesita un
> interceptor o un guard? → store. Si no → local.**

Aplicada a la paginación del dashboard, la respuesta de F10 fue **local** — igual
que `search` y `statusFilter`. Una sola vista lo lee. No sobrevive a la
navegación (y no quieres que sobreviva). Nadie más lo necesita.

**Pero ahora la pregunta es otra.** No es "¿store o local?". Es:

> **Si es local, ¿local *de tu componente* o local *del QTable*?**

Y ahí hay dos opciones. No hay una tercera.

---

#### Opción A — Manda `QTable` (el componente es el dueño)

No pasas nada. `QTable` se lo gestiona todo internamente.

```html
<!-- No hay :pagination. No hay data(). QTable se apaña. -->
<q-table
  :rows="allTickets"
  :columns="columns"
  row-key="id"
  :rows-per-page-options="[10, 25, 50]"
/>
```

```js
// TicketsView.vue — el data() de paginación: NO EXISTE.
export default {
  data: function () {
    return {}; // ← esto. Literalmente esto.
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
- Cuando actualices Quasar y arreglen un edge case, te lo llevas gratis.

**Qué pagas:**

| Coste | Cuándo te muerde |
|---|---|
| **El estado es invisible.** No sale en las devtools de Vuex. No sale en el time travel de F10. Vive dentro de un componente de `node_modules`. | El día que un usuario reporta "estaba en la página 3 y se me fue a la 1" y tú no puedes reproducirlo. |
| **No puedes leerlo desde fuera.** Si el panel de soporte quiere saber en qué página está el dashboard, no puede. | Nunca, probablemente. Pero si pasa, es un refactor entero. |
| **No puedes escribirlo desde fuera** sin `$refs`. Un botón "ir a la última página" fuera de la tabla necesita `this.$refs.tabla.setPagination(...)`. | Ejercicio 25. |
| **No es serializable.** No lo puedes meter en la URL, ni en localStorage, ni en un test de regresión que verifique "tras filtrar, `page` vale 1". | Al escribir los tests. Se nota **ya**. |

---

#### Opción B — Mandas tú (`:pagination.sync` + Vuex)

Pones el objeto en el store y lo sincronizas.

> ⚠️ **Antes de leer este código, un ajuste de continuidad con F10.** En el
> tronco, `search` y `statusFilter` **NO están en el store**: el refactor guiado de
> F10 los dejó **locales en el `data()` de `TicketsView`** (su auditoría dijo
> "local/URL, el store no los pidió"). Subirlos al módulo `ui` es **opt-in** — el
> *patrón* del computed `get`/`set` contra `ui/SET_SEARCH` aparece en F10 como
> ejemplo (ej. 12), no como el estado por defecto. Así que la Opción B de abajo
> los mete en el store **solo si eliges la Opción B para todo el estado de la
> tabla**. Si te quedas en la Opción A (lo recomendado, ver más abajo), `search` y
> `statusFilter` **siguen siendo locales**, como en F10. No los subas al store "de
> paso": súbelos solo si has decidido que la paginación también sube.

```js
// store/modules/ui.js — el módulo `ui` de F10 (flash), ampliado para la Opción B
const state = {
  flash: null,        // el único estado que F10 puso aquí por defecto (F5 ej. 20)
  // ↓↓ search/statusFilter suben al store SOLO en la Opción B (no es el default de F10)
  search: "",
  statusFilter: "",
  ticketsPagination: {
    sortBy: "createdAt",
    descending: true,
    page: 1,
    rowsPerPage: 10,
    rowsNumber: 0
  }
};

const mutations = {
  SET_TICKETS_PAGINATION: function (state, pagination) {
    // Reemplazo completo del objeto. QTable emite el objeto entero,
    // no un patch. Reasignar es reactivo (F8: reemplazar > mutar).
    state.ticketsPagination = pagination;
  }
};
```

```html
<!-- TicketsView.vue -->
<q-table
  :rows="allTickets"
  :columns="columns"
  row-key="id"
  :pagination.sync="pagination"
  :rows-per-page-options="[10, 25, 50]"
/>
```

```js
// El computed con get/set de F10 — el mismo patrón, otra vez.
// .sync es azúcar de :pagination + @update:pagination. Necesita un setter.
computed: {
  ...mapGetters("tickets", ["allTickets"]),

  pagination: {
    get: function () {
      return this.$store.state.ui.ticketsPagination;
    },
    set: function (value) {
      this.$store.commit("ui/SET_TICKETS_PAGINATION", value);
    }
  }
}
```

**🔎 Qué hace `:pagination.sync`:** Vue 2.3+ expande `:pagination.sync="x"` a
`:pagination="x"` + `@update:pagination="x = $event"`. Como `x` es un computed
con setter, la asignación **corre el `set`** → commit → mutation → store.
Exactamente el patrón de `v-model` contra el store de F10. **No es magia nueva:
es el mismo truco.**

> ⚠️ **Sin el `set`, `strict: true` te mata.** Si `pagination` es un computed
> solo-lectura que devuelve `state.ui.ticketsPagination`, `QTable` va a intentar
> mutarlo directamente y Vuex va a lanzar
> `Error: [vuex] do not mutate vuex store state outside mutation handlers`.
> **En dev.** En producción `strict` está apagado (F10) → **muta el store en
> silencio, sin commit, sin devtools, sin time travel.** El peor bug posible:
> funciona.

**Qué ganas:**
- El estado es **visible**: devtools de Vuex, time travel, cada cambio de página
  es un commit con nombre.
- Es **serializable**: lo puedes leer para meterlo en la URL (`?page=3&sort=title`),
  en localStorage, o en un assert de test.
- Es **escribible desde fuera**: cualquier componente puede hacer
  `commit("ui/SET_TICKETS_PAGINATION", {...page: 1})`. El botón "resetear
  filtros" del header lo hace sin `$refs`.
- Sobrevive a la navegación: sales al detalle del ticket, vuelves, sigues en la
  página 3. (Lo cual **puede ser un bug** si no lo querías. Cuidado.)

**Qué pagas:**

| Coste | Cuándo te muerde |
|---|---|
| **Estado de UI en el store global.** Exactamente lo que la auditoría de F10 dijo que NO hicieras. Tu propia regla, rota. | Cuando el siguiente dev lea el store y pregunte "¿por qué la página de una tabla vive aquí?". |
| **Un commit por click.** Ordenar → commit. Página siguiente → commit. Cambiar `rowsPerPage` → commit. Las devtools se llenan de ruido y el time travel real se pierde en el barro. | La primera vez que uses el time travel para depurar algo de verdad. |
| **Acoplas el store a un componente de terceros.** Ese objeto `{sortBy, descending, page, rowsPerPage, rowsNumber}` **es el formato de Quasar 1**. Si mañana migras a otra tabla, tu store tiene su forma. | En la próxima migración. Que la habrá. |
| **Multiplica.** Si el panel de soporte también tiene tabla, ahora hay `supportPagination`. Y `metricsPagination`. El módulo `ui` se convierte en un vertedero. | Al llegar al ejercicio 🔴 final. |

---

#### 📝 La decisión defendida

Vamos a hacer lo que hicimos en F10: **elegir, y escribir por qué.**

> **Manda `QTable`. Opción A.**
>
> **Salvo** que el estado tenga que salir del componente. Y en el Mini Jira, no
> tiene que salir.
>
> El razonamiento es el mismo de F10, aplicado con honestidad. La regla no era
> "todo al store": era **"¿lo lee alguien más? ¿sobrevive a la navegación? ¿lo
> necesita un guard o un interceptor?"**. Para la paginación del dashboard, las
> tres respuestas son **no**.
>
> El único argumento fuerte a favor de B es la **visibilidad en devtools**. Y es
> un argumento real: depurar estado que no puedes ver es una tortura. Pero es un
> argumento de *herramientas*, no de *arquitectura*. Y el coste que paga es
> arquitectónico: metes en el store global el objeto de configuración de un
> componente de `node_modules`, con su forma exacta, y creas un precedente que la
> siguiente tabla va a seguir. Ese precedente es cómo nacen los módulos `ui` de
> 400 líneas que ves en el legacy de verdad.
>
> **Cuándo sí es B**, sin dudarlo:
>
> 1. **La paginación va en la URL.** `/tickets?page=3&sort=title&desc=1`. Un
>    usuario copia el link, se lo manda a un compañero, y el compañero ve la
>    misma vista. Esto es una feature de producto real y es la razón nº1 para
>    sacar el estado del componente. (No necesita Vuex, ojo — necesita
>    `$route.query`. Véase ejercicio 22. Pero necesita `:pagination.sync`.)
> 2. **Server-side con filtros compartidos.** Si el filtro vive en el store
>    (porque lo lee el header, o las métricas), y la paginación depende del
>    filtro, tenerlos separados es peor que tenerlos juntos.
> 3. **El estado tiene que sobrevivir a la navegación** por requisito explícito.
>
> Fuera de eso: **cede el control.** Es lo que compraste al meter Quasar. Si
> quieres controlarlo todo, no metas un framework de UI.
>
> **La trampa que debes evitar:** el híbrido. Paginación en `QTable`, filtro en
> el store, orden en el componente. Tres dueños. Eso no es "lo mejor de ambos":
> eso es un sistema donde nadie sabe quién resetea la página al filtrar, y el bug
> aparece un martes.

**Tu turno.** Escribe tu versión. Puede ser la contraria. Lo que no puede ser es
"depende". (Ejercicio 26.)

### 4.6 Modo server-side: `@request`, `loading`, `rowsNumber`

Todo lo anterior asume **modo cliente**: `QTable` recibe las 40 filas y pagina en
memoria. Es lo que hacía F4 y es correcto para 40 tickets.

Cuando son 40.000, no.

En modo server-side, `QTable` deja de paginar y **te pide** los datos:

```html
<q-table
  :rows="allTickets"
  :columns="columns"
  row-key="id"
  :loading="loading"
  :pagination.sync="pagination"
  @request="onRequest"
/>
```

**🔎 El interruptor es `rowsNumber`.** No hay una prop `server-side="true"`.
Si `pagination.rowsNumber` está definido y es > 0, `QTable` entra en modo
servidor. Si no lo está, pagina en cliente. **Esto no está en la doc en letras
grandes y es la fuente nº1 de "¿por qué me pagina dos veces?"**.

```js
// TicketsView.vue — modo server-side
export default {
  data: function () {
    return {
      pagination: {
        sortBy: "createdAt",
        descending: true,
        page: 1,
        rowsPerPage: 10,
        rowsNumber: 0    // ← el interruptor. Empieza en 0, lo rellena la API.
      }
    };
  },

  computed: {
    ...mapGetters("tickets", ["allTickets"]),
    ...mapState("tickets", ["loading"])
  },

  created: function () {
    // QTable NO pide datos al montarse. Tienes que disparar el primer request
    // TÚ. Olvidarlo = tabla vacía, sin error, sin loading. El clásico.
    this.onRequest({ pagination: this.pagination });
  },

  methods: {
    // @request se dispara cuando el usuario cambia página, orden o rowsPerPage.
    // Recibe { pagination, filter }. La `pagination` del evento es la NUEVA,
    // la que el usuario quiere. La tuya sigue siendo la vieja.
    onRequest: function (props) {
      var self = this;
      var p = props.pagination;

      return this.$store
        .dispatch("tickets/fetchTicketsPaged", {
          page: p.page,
          limit: p.rowsPerPage,
          sortBy: p.sortBy,
          descending: p.descending
        })
        .then(function (result) {
          // Ahora, y SOLO ahora, actualizas tu pagination local.
          // Si la actualizas antes del fetch, la tabla se mueve y luego
          // se corrige: parpadeo.
          self.pagination.page = p.page;
          self.pagination.rowsPerPage = p.rowsPerPage;
          self.pagination.sortBy = p.sortBy;
          self.pagination.descending = p.descending;
          self.pagination.rowsNumber = result.total; // ← 💸 véase abajo
        });
    }
  }
};
```

**🔎 Qué hace, paso a paso (el flujo evento por evento):**

```
1. Usuario clica "página 2"
2. QTable emite @request con { pagination: { page: 2, ... }, filter: "" }
     ↳ QTable NO cambia su vista. Espera.
3. onRequest() dispara la action de Vuex
4. La action commitea SET_LOADING(true)
     ↳ :loading="loading" → QTable pinta su barra de progreso ⏳
5. El service llama a GET /tickets?_page=2&_limit=10&_sort=createdAt&_order=desc
6. json-server responde: body = 10 tickets, header X-Total-Count = 43
7. El service mapea → { items: [...], total: 43 }
8. La action commitea SET_TICKETS(items) + SET_LOADING(false)
9. onRequest() (en el .then) asigna pagination.rowsNumber = 43
     ↳ QTable ya sabe: página 2 de 5. Pinta el footer bien.
10. :rows="allTickets" ya tiene los 10 nuevos → la tabla se repinta
```

**✅ Buenas prácticas:**
- **`loading` es del store, no local.** Ya existe desde F3 (`loading/error/data`)
  y en F10 vive en el módulo `tickets`. `:loading="loading"` lo consume. **No
  crees un `loading` nuevo en el componente.** Ese es el olor de "no confío en mi
  propio store".
- **Actualiza tu `pagination` en el `.then`, no antes.** Si lo haces antes, la
  tabla se pinta con la paginación nueva y los datos viejos durante ~200ms.
- **El primer `onRequest` lo disparas tú en `created()`.** `QTable` no lo hace.
- **`filter` en server-side también viaja en `props.filter`.** No lo ignores: el
  campo de búsqueda de F4 tiene que llegar al backend, no filtrar 10 filas en
  memoria.

#### 💸 Deuda: `rowsNumber` vs `X-Total-Count`

```
💸 QTable server-side espera `rowsNumber`: un número, dentro del objeto de
   paginación, en el body de tu respuesta o donde tú lo pongas.

   json-server manda el total en un HEADER: `X-Total-Count: 43`.

   No es un capricho de json-server — es una convención REST bastante extendida
   (la usa el estándar de JSON API para paginación por rangos). Pero es UNA de
   las convenciones. Otra API te lo manda en el body:
   { data: [...], meta: { total: 43, page: 2 } }. Otra en un envelope.
   Otra no te lo manda y tienes que pedir la página siguiente para saber si
   existe (cursor-based). Otra te miente.

   "En producción el backend te da el total en el body o en un header;
    aquí lo pescamos del header y lo mapeamos a mano."

   El sitio donde se mapea NO es el componente. Es el SERVICE. Que la vista
   sepa que existe un header llamado X-Total-Count es un fallo de capas.
```

```js
// services/ticketService.js — el mapeo vive AQUÍ
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
`_limit`) al **contrato de tu app** (`{items, total}`). El store recibe
`{items, total}`. El componente recibe `total` y lo llama `rowsNumber`. Tres
capas, tres vocabularios, ninguna filtración.

**⚠️ El fallo con nombre propio:** `response.headers["X-Total-Count"]` →
`undefined`. **axios pasa los headers a minúsculas.** No lo dice en ningún sitio
visible. Es `response.headers["x-total-count"]`. Media tarde perdida, garantizado.

> **⚠️ CORS, el otro fallo con nombre propio.** Si tu API está en otro origen, el
> navegador **no te deja leer** headers custom salvo que el servidor mande
> `Access-Control-Expose-Headers: X-Total-Count`. `response.headers["x-total-count"]`
> → `undefined`, **con la petición devolviendo 200 y el header visible en la
> pestaña Network del DevTools**. Lo ves, y no lo puedes leer. json-server lo
> expone; **tu backend de producción probablemente no**. Esa conversación con el
> equipo de backend, tenla el primer día. 💸

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
> `if (context.state.items.length > 0 && !options.force) return ...`. Esa caché
> **no vale en server-side**: cada página es un fetch nuevo, siempre. Si copias
> el patrón sin pensar, el usuario clica "página 2" y ve la página 1 otra vez,
> sin error, sin loading. Y no vas a saber por qué. **`fetchTicketsPaged` no
> cachea. Punto.**

**¿Cliente o servidor en el Mini Jira?** **Cliente.** 40 tickets. El modo
server-side está aquí porque **lo vas a ver en producción** y porque `rowsNumber`
es donde la deuda 💸 se hace visible — no porque el Mini Jira lo necesite. Montar
server-side para 40 filas es la definición de complejidad accidental.

### 4.7 🤝 Convivencia Bootstrap + Quasar

Esta sección **no es un anexo**. Es la mitad del valor de la fase.

>
> ⚠️ **Sobre el modal.** El curso base **no usa bootstrap-vue** — usa Bootstrap 4
> crudo con jQuery, encapsulado en un componente frontera (`ConfirmModal.vue`, el
> ejercicio 18 de F5 y el patrón de librería imperativa de A1). Así que en el Mini
> Jira **no hay `<b-modal>` ni `this.$bvModal`**: hay un `<div class="modal">` de
> Bootstrap que abres con `$('#id').modal('show')`. Los bosquejos maestros dicen
> `<b-modal>` como taquigrafía de "el modal de Bootstrap"; aquí lo escribimos como
> el curso lo enseña. La lección de convivencia es idéntica: es un componente que
> no sabe que Quasar existe.
>
Después de Q2 y Q3, tu proyecto está así:

```
Mini Jira (post-Q3)
├── Dashboard         → QTable          🅠 Quasar
├── Formulario CRUD   → QForm/QInput    🅠 Quasar
├── Modal de crear    → div.modal+jQuery 🅱️ Bootstrap
├── Wizard (F6)       → a pelo + BS4    🅱️ Bootstrap
├── Panel soporte (F9)→ a pelo + BS4    🅱️ Bootstrap
├── Métricas (F7)     → chart.js + BS4  🅱️ Bootstrap
├── Badges (F4)       → <span class="badge"> 🅱️ Bootstrap, DENTRO de Quasar
└── Layout            → QLayout         🅠 Quasar
```

Esto **no es un estado transitorio que vas a limpiar el mes que viene.** Esto es
tu proyecto durante los próximos tres años. Bienvenido.

#### ¿Se pisan los estilos? SÍ. Demostración.

**`.row` existe en los dos.** Y no significan lo mismo.

```css
/* Bootstrap 4 — bootstrap.css */
.row {
  display: flex;
  flex-wrap: wrap;
  margin-right: -15px;   /* ← gutter negativo */
  margin-left: -15px;
}

/* Quasar 1 — quasar.css */
.row {
  display: flex;
  flex-wrap: wrap;
  /* sin márgenes negativos. El gutter se hace con q-gutter-* o q-col-gutter-* */
}
```

**Cuál gana:** el que se cargue **último** en el bundle. Misma especificidad
(`0,0,1,0` — una clase). Regla de cascada CSS: **último gana**.

Y "el que se cargue último" **no es una decisión que hayas tomado**. Es una
consecuencia del orden de tus imports en `quasar.conf.js`:

```js
// quasar.conf.js
css: [
  "app.sass"          // el tuyo
],
extras: [ /* ... */ ],
// y Bootstrap, ¿dónde lo metiste? Si fue con un import en un boot file,
// depende de cuándo corra ese boot file.
```

**Pruébalo. No te fíes de mí:**

```html
<!-- Ponlo en cualquier vista y abre el DevTools -->
<div class="row" style="border: 2px solid red;">
  <div class="col-6" style="background: #ffe;">A</div>
  <div class="col-6" style="background: #eff;">B</div>
</div>
```

**Qué ves:**
- Si **gana Bootstrap**: las columnas tienen padding lateral y el `.row` se sale
  15px por cada lado de su contenedor (margen negativo). El borde rojo queda
  **por dentro** del contenido.
- Si **gana Quasar**: sin margen negativo, sin padding. El borde rojo abraza el
  contenido. Las columnas se pegan.

**Y ahora el remate.** Inspecciona el `.row` en DevTools → pestaña Styles. Vas a
ver **las dos reglas**, una tachada. La tachada es la que perdió. Esa es la
demostración: **no es que "no se lleven bien". Es que literalmente el mismo
selector está definido dos veces y una gana.**

`.row` no es la única. También colisionan (parcial o totalmente):

| Clase | Bootstrap 4 | Quasar 1 | ¿Choca? |
|---|---|---|---|
| `.row` | flex + gutter negativo | flex, sin gutter | 💥 **Sí** |
| `.col`, `.col-6`, `.col-md-4` | grid de 12, con padding | grid de 12, sin padding | 💥 **Sí** — y este es el peligroso: *parece* que funciona |
| `.text-center` | `text-align: center` | `text-align: center` | ✅ Coinciden. Suerte. |
| `.hidden` | `display: none !important` | `display: none` | ⚠️ Casi |
| `.q-*` | — | todo lo de Quasar | ✅ Namespace. Por esto Quasar prefija. |
| `.btn`, `.card`, `.badge` | Bootstrap | — | ✅ Quasar usa `.q-btn`, `.q-card` |

**✅ La regla de supervivencia:**

> **No mezcles sistemas de grid en el mismo subárbol del DOM.**
>
> Una vista usa el grid de Bootstrap (`row`/`col-md-6`) **o** el de Quasar
> (`row`/`col-md-6` + `q-pa-md`). **Nunca los dos.** Y como se llaman igual, la
> única forma de saber cuál estás usando es **saber qué CSS ganó**.
>
> El componente que usa `<q-table>` usa el grid de Quasar. El que usa el modal Bootstrap
> usa el de Bootstrap. Y **entre ellos**: `<div>` pelados, sin clase de grid.

Si esto te parece frágil, es porque **lo es**. Bienvenido al legacy a medio
migrar.

#### El modal de crear ticket sigue siendo Bootstrap. Y funciona.

Tu `TicketsView` post-Q3:

```html
<template>
  <q-page padding>
    <!-- Cabecera: grid de QUASAR (estamos dentro de q-page) -->
    <div class="row items-center q-mb-md">
      <div class="col">
        <h5 class="q-my-none">Tickets</h5>
      </div>
      <div class="col-auto">
        <!-- Botón de QUASAR -->
        <q-btn color="primary" icon="add" label="Nuevo ticket" @click="openModal" />
      </div>
    </div>

    <!-- Tabla: QUASAR -->
    <q-table
      :rows="allTickets"
      :columns="columns"
      row-key="id"
      :loading="loading"
      :filter="search"
      :rows-per-page-options="[10, 25, 50]"
    >
      <template v-slot:top-right>
        <!-- Input de QUASAR -->
        <q-input dense debounce="300" v-model="search" placeholder="Buscar…">
          <template v-slot:append><q-icon name="search" /></template>
        </q-input>
      </template>

      <template v-slot:body-cell-status="props">
        <q-td :props="props">
          <!-- Badge de BOOTSTRAP (F4), dentro de una tabla de QUASAR -->
          <ticket-status-badge :status="props.row.status" />
        </q-td>
      </template>

      <template v-slot:body-cell-actions="props">
        <q-td :props="props">
          <q-btn flat dense icon="edit" @click="openModal(props.row)" />
        </q-td>
      </template>
    </q-table>

    <!--
      ⬇️ AQUÍ. El modal de F5. BOOTSTRAP 4 CRUDO (jQuery), sin tocar.
      Es el <div class="modal"> de siempre, envuelto en el componente frontera
      del ejercicio 18 de F5. NO es bootstrap-vue: el curso no lo usa.
      Fuera del q-page? No: dentro. Y funciona.
      OJO: dentro del modal NO uses grid de Quasar. El modal es territorio BS4.
    -->
    <div class="modal fade" id="ticket-modal" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ modalTitle }}</h5>
            <button type="button" class="close" @click="closeModal">&times;</button>
          </div>
          <div class="modal-body">
            <!-- El TicketForm de Q2: ya es QForm por dentro.
                 QForm dentro de un modal Bootstrap. Sí. Funciona.
                 Emite "submit" (F5), no "saved". -->
            <ticket-form
              :initial-ticket="selected"
              @submit="onSaved"
              @cancel="closeModal"
            />
          </div>
        </div>
      </div>
    </div>
  </q-page>
</template>
```

**Léelo otra vez.** Ahí dentro hay:
- Un `<q-page>` de Quasar
- Con un grid de Quasar
- Con un `<q-table>` de Quasar
- Que renderiza `<span class="badge badge-danger">` de Bootstrap
- Y un modal de **Bootstrap 4** (el `<div class="modal">` de jQuery)
- Que contiene un `<q-form>` de Quasar
- Que valida con `:rules` de Quasar

**Y funciona.** Porque a Vue le da exactamente igual. Un componente es un
componente. El modal de Bootstrap no sabe que existe Quasar. `<q-table>` no sabe que existe
Bootstrap. El navegador solo ve HTML y CSS.

> **⚠️ La única fricción real es el z-index.** El modal de Bootstrap usa `z-index: 1050`
> (Bootstrap). `<q-dialog>` y los menús de Quasar usan `z-index: 6000`. Si abres
> un `<q-select>` **dentro** del modal Bootstrap, el desplegable se pinta **encima**
> del modal — porque Quasar lo teletransporta al `<body>` con su portal. Se ve
> bien. **Pero si abres el modal Bootstrap sobre un `<q-dialog>`, el modal se pinta
> DEBAJO**. Y el usuario ve una pantalla congelada. **El día que pase, mira el
> z-index. Siempre es el z-index.**

#### Un componente Quasar emite un evento que consume un componente Bootstrap

Este es el punto que hay que ver con las manos.

```js
// TicketsView.vue — methods
methods: {
  // Lo llama el @click de un <q-btn>. Un botón de QUASAR.
  openModal: function (ticket) {
    this.selected = ticket && ticket.id ? ticket : null;
    this.editing = !!(ticket && ticket.id);

    // Abre el modal de BOOTSTRAP 4 con jQuery. El patrón imperativo de A1,
    // encapsulado en esta vista (o mejor, en un ConfirmModal.vue frontera).
    // eslint-disable-next-line no-undef
    $("#ticket-modal").modal("show");
  },

  closeModal: function () {
    // eslint-disable-next-line no-undef
    $("#ticket-modal").modal("hide");
  },

  // Lo emite el <ticket-form>, que por dentro es un <q-form> (Q2).
  onSaved: function (ticket) {
    this.closeModal();
    // Y esto va al store. Que no sabe nada de nada.
    this.$store.commit("tickets/UPSERT_TICKET", ticket);
    this.$store.commit("ui/FLASH", {
      type: "success",
      text: "Ticket #" + ticket.id + " guardado"
    });
  }
}
```

**El flujo, evento por evento:**

```
1. Usuario clica <q-btn>              🅠 QUASAR emite click nativo
2. → openModal()                      📦 tu código. Vue puro.
3. → $("#ticket-modal").modal("show") 🅱️ BOOTSTRAP+jQuery abre el modal
4. Dentro del modal: <ticket-form>    📦 tu componente (Q2)
5. Dentro del form: <q-input :rules>  🅠 QUASAR valida
6. Usuario da a Guardar
7. → $refs.form.validate()            🅠 QUASAR devuelve una Promise
8. → ticketService.updateTicket()     📦 tu service. axios. F3.
9. → this.$emit("submit", ticket)     💚 VUE. Solo Vue. Un evento.
10. → onSaved() en TicketsView        📦 tu código
11. → $("#ticket-modal").modal("hide") 🅱️ BOOTSTRAP+jQuery cierra
12. → commit("tickets/UPSERT_TICKET") 🗂️ VUEX
13. → el getter allTickets cambia     🗂️ VUEX
14. → :rows="allTickets" se repinta   🅠 QUASAR redibuja la tabla
```

**Cuenta los saltos de framework.** Seis. En un solo flujo de "guardar un ticket".

**Y ahora la pregunta importante:**

> **¿Qué línea de ese flujo sabe que hay dos frameworks mezclados?**
>
> **Ninguna.**

- El **store** (F10) no lo sabe. Recibe un commit con un objeto ticket. Le da
  igual quién lo mandó.
- El **service** (F3) no lo sabe. Hace un PATCH.
- El **evento `submit`** no lo sabe. Es `this.$emit`. Vue 2. El mismo `$emit` de
  F1.
- El **`apiClient`** y su interceptor de F2 no lo saben.

**Esta es la lección de la fase, y es la lección de la ruta entera:**

> **Vue es el sustrato. El framework de UI es una capa de pintura.**
>
> Si tu arquitectura (Componente → Store → services/ → apiClient → API) es
> sólida, puedes cambiar la capa de pintura **por trozos, sin parar la obra**.
> El store no se entera. El service no se entera. El interceptor no se entera.
>
> Si tu arquitectura NO es sólida — si el componente llama a axios directo, si el
> estado vive en `data()` disperso por seis vistas — entonces migrar el dashboard
> te obliga a tocar todo, y "migrar a Quasar" se convierte en "reescribir la
> app".
>
> **La razón por la que esta migración es posible en dos fases es F10.** No es
> Quasar. Es que hiciste los deberes.

#### 🎯 Cierre: aquí vas a vivir

No hay un final de la migración. No existe el día en que "ya está todo en
Quasar". Lo que hay es:

- Un dashboard en `QTable` que nadie toca porque funciona.
- Un panel de soporte en Bootstrap que nadie migra porque no da problemas.
- Un wizard que alguien empezó a migrar en 2021 y dejó a medias.
- Un `bootstrap.css` de 190KB que nadie se atreve a quitar porque no sabe qué
  usa.
- Un ticket en el backlog que dice "Unificar sistema de UI" con prioridad baja
  desde hace cuatro años.

**Eso no es un fracaso. Eso es el estado estable de un producto que se envía.**

Tu trabajo no es "terminar la migración". Tu trabajo es **saber en qué mitad
estás parado en cada momento**, y no romper la otra.

---

## 💻 5. Código de la fase

### `TicketsView.vue` — versión final (modo cliente, Opción A)

```html
<template>
  <q-page padding>
    <div class="row items-center q-mb-md">
      <div class="col">
        <h5 class="q-my-none">Tickets</h5>
      </div>
      <div class="col-auto">
        <q-btn color="primary" icon="add" label="Nuevo ticket" @click="openModal(null)" />
      </div>
    </div>

    <!-- Las tarjetas resumen de F4: se quedan. Grid de Quasar. -->
    <div class="row q-col-gutter-md q-mb-md">
      <div class="col-6 col-md-3" v-for="card in summaryCards" :key="card.status">
        <q-card flat bordered>
          <q-card-section>
            <div class="text-h4">{{ card.count }}</div>
            <div class="text-caption text-grey">{{ card.label }}</div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <q-table
      :rows="allTickets"
      :columns="columns"
      row-key="id"
      :loading="loading"
      :filter="filter"
      :filter-method="filterTickets"
      :rows-per-page-options="[10, 25, 50]"
      flat
      bordered
    >
      <template v-slot:top-right>
        <q-input dense debounce="300" v-model="filter.search" placeholder="Buscar…">
          <template v-slot:append><q-icon name="search" /></template>
        </q-input>
        <q-select
          dense
          v-model="filter.status"
          :options="statusOptions"
          emit-value
          map-options
          clearable
          label="Estado"
          style="min-width: 150px"
          class="q-ml-sm"
        />
      </template>

      <template v-slot:body-cell-status="props">
        <q-td :props="props">
          <ticket-status-badge :status="props.row.status" />
        </q-td>
      </template>

      <template v-slot:body-cell-priority="props">
        <q-td :props="props">
          <ticket-priority-badge :priority="props.row.priority" />
        </q-td>
      </template>

      <template v-slot:body-cell-actions="props">
        <q-td :props="props">
          <q-btn flat dense round icon="edit" @click="openModal(props.row)" />
          <q-btn flat dense round icon="delete" color="negative" @click="onDelete(props.row)" />
        </q-td>
      </template>

      <!-- El "no hay resultados" de F4. Slot no-data. -->
      <template v-slot:no-data>
        <div class="full-width row flex-center q-pa-md text-grey">
          🔍 No hay tickets que coincidan con los filtros.
        </div>
      </template>
    </q-table>

    <!-- 🅱️ BOOTSTRAP 4 crudo (jQuery). Aquí. Al lado. Funcionando.
         No es bootstrap-vue: el curso no lo usa (A1). -->
    <div class="modal fade" id="ticket-modal" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ modalTitle }}</h5>
            <button type="button" class="close" @click="closeModal">&times;</button>
          </div>
          <div class="modal-body">
            <ticket-form :initial-ticket="selected" @submit="onSaved" @cancel="closeModal" />
          </div>
        </div>
      </div>
    </div>
  </q-page>
</template>

<script>
import { mapGetters, mapState } from "vuex";
import TicketStatusBadge from "../components/tickets/TicketStatusBadge.vue";
import TicketPriorityBadge from "../components/tickets/TicketPriorityBadge.vue";
import TicketForm from "../components/tickets/TicketForm.vue";

// Constantes del módulo. NO en data(): no son reactivas, no cambian nunca.
const COLUMNS = [
  { name: "id",        label: "#",         field: "id",        align: "left",   sortable: true },
  { name: "title",     label: "Título",    field: "title",     align: "left",   sortable: true },
  { name: "status",    label: "Estado",    field: "status",    align: "center", sortable: true },
  { name: "priority",  label: "Prioridad", field: "priority",  align: "center", sortable: true },
  {
    name: "assignee",
    label: "Asignado",
    field: function (row) { return row.assignee || "—"; },
    align: "left",
    sortable: true
  },
  {
    name: "createdAt",
    label: "Creado",
    field: "createdAt",
    align: "right",
    sortable: true,
    format: function (val) { return new Date(val).toLocaleDateString("es-ES"); }
  },
  // La columna de acciones DEBE existir aquí o no hay cabecera.
  { name: "actions", label: "", field: "id", align: "right", sortable: false }
];

const STATUS_OPTIONS = [
  { label: "Abierto",     value: "open" },
  { label: "En progreso", value: "in_progress" },
  { label: "Resuelto",    value: "resolved" },
  { label: "Cerrado",     value: "closed" }
];

export default {
  name: "TicketsView",

  components: {
    TicketStatusBadge: TicketStatusBadge,
    TicketPriorityBadge: TicketPriorityBadge,
    TicketForm: TicketForm
  },

  data: function () {
    return {
      columns: COLUMNS,
      statusOptions: STATUS_OPTIONS,
      // El filtro sigue siendo local (decisión de F10, no cambia).
      // Es un OBJETO porque QTable pasa `filter` entero a filter-method.
      filter: { search: "", status: null },
      selected: null,
      editing: false
      // ⛔ NO hay: sortKey, sortOrder, page, perPage.
      // ⛔ NO hay: filteredTickets, sortedTickets, pagedTickets, totalPages.
      // ⛔ NO hay: toggleSort(), goToPage().
      // ⛔ NO hay: watch { search() { this.page = 1 } }.
      // QTable los hace. Los ~150 de F4 están BORRADOS.
    };
  },

  computed: {
    ...mapGetters("tickets", ["allTickets"]),
    ...mapState("tickets", ["loading"]),

    modalTitle: function () {
      return this.editing ? "Editar ticket" : "Nuevo ticket";
    },

    // Las tarjetas resumen de F4. Este computed SE QUEDA:
    // no es filtro, ni orden, ni paginación. QTable no lo hace.
    summaryCards: function () {
      var items = this.allTickets;
      return STATUS_OPTIONS.map(function (opt) {
        return {
          status: opt.value,
          label: opt.label,
          count: items.filter(function (t) { return t.status === opt.value; }).length
        };
      });
    }
  },

  created: function () {
    this.$store.dispatch("tickets/fetchTickets");
  },

  methods: {
    // filter-method: QTable llama a esto con (rows, terms).
    // `terms` es lo que hay en :filter. Nuestro objeto {search, status}.
    // QTable vigila :filter con deep watch → cambiar filter.status re-filtra
    // Y resetea la página a 1. GRATIS. El watcher de F4 no hace falta.
    filterTickets: function (rows, terms) {
      var term = (terms.search || "").trim().toLowerCase();
      var status = terms.status;

      return rows.filter(function (t) {
        var matchesText = !term || t.title.toLowerCase().indexOf(term) !== -1;
        var matchesStatus = !status || t.status === status;
        return matchesText && matchesStatus;
      });
    },

    openModal: function (ticket) {
      this.selected = ticket;
      this.editing = !!(ticket && ticket.id);
      // eslint-disable-next-line no-undef
      $("#ticket-modal").modal("show"); // 🅱️ Bootstrap 4 + jQuery
    },

    closeModal: function () {
      // eslint-disable-next-line no-undef
      $("#ticket-modal").modal("hide");
      this.selected = null;
    },

    onSaved: function (ticket) {
      this.closeModal();
      this.$store.commit("tickets/UPSERT_TICKET", ticket);
      // this.$q.notify de Quasar (Q1) — sustituye al flash de F10.
      // Y coexiste con el módulo `ui`: elige UNO. (Ejercicio 20.)
      this.$q.notify({ type: "positive", message: "Ticket #" + ticket.id + " guardado" });
    },

    onDelete: function (ticket) {
      var self = this;
      this.$q
        .dialog({
          title: "Confirmar",
          message: "¿Eliminar el ticket #" + ticket.id + "?",
          cancel: true
        })
        .onOk(function () {
          // ⚠️ `deleteTicket` como action es el ejercicio 13 de F10.
          //    Si no lo hiciste, aquí tienes DELETE en el service +
          //    commit("tickets/REMOVE_TICKET", id). Hazlo action ahora: es
          //    exactamente el mismo refactor y te lo vas a encontrar igual.
          self.$store.dispatch("tickets/deleteTicket", ticket.id);
        });
    }
  }
};
</script>
```

**🔎 Qué hace, en tres frases:**
1. `QTable` recibe **todas** las filas del store y se encarga de filtrar, ordenar
   y paginar en memoria. El componente **no tiene ni una línea** de eso.
2. Los slots `body-cell-*` inyectan los componentes de F4 sin modificarlos.
3. El modal de Bootstrap (jQuery) convive en la misma vista, y el store no se entera.

**✅ Buenas prácticas aplicadas:**
- `COLUMNS` y `STATUS_OPTIONS` **fuera de `data()`**. No son reactivos. Meterlos
  en `data()` pone un observer de Vue sobre arrays inmutables: coste sin
  beneficio, y en tablas grandes se nota.
- `:filter` es un **objeto**, no un string. `QTable` lo vigila con deep watch, así
  que cambiar `filter.status` re-filtra y **resetea la página**. El watcher
  anti-bug de F4 (`watch: { statusFilter() { this.page = 1 } }`) **se borra**:
  el componente ya lo hace.
- `debounce="300"` en el `q-input` de búsqueda. En F4 no lo tenías (filtrabas en
  memoria, daba igual). Aquí tampoco hace falta… **hasta que pases a server-side
  y cada tecla sea un `GET`.** Ponlo ahora, gratis.
- `loading` viene del store (F3 → F10). **No se crea uno nuevo.**
- El `summaryCards` computed **se queda**. Es derivación de datos, no
  presentación de tabla. `QTable` no compite con él. **Migrar no es borrar todo:
  es borrar lo que el framework hace mejor.**

### El registro de componentes (⚠️ el fallo de Q1 que vuelve)

```js
// quasar.conf.js
framework: {
  components: [
    "QLayout", "QPageContainer", "QPage", "QBtn", "QInput", "QForm", // de Q1/Q2
    "QTable",     // ← Q3
    "QTd",        // ← Q3. SIN ESTO LOS SLOTS NO PINTAN. Y no hay error.
    "QSelect",    // ← Q3 (el filtro de estado)
    "QIcon",
    "QCard", "QCardSection",
    "QLinearProgress" // ← lo usa QTable para la barra de :loading
  ],
  directives: ["Ripple", "ClosePopup"],
  plugins: ["Notify", "Dialog"]  // ← this.$q.notify / this.$q.dialog
}
```

> ⚠️ **El clásico de la fase:** declaras `QTable`, te olvidas de `QTd`. La tabla
> renderiza. Las columnas normales se ven. **Las celdas de tus slots salen
> vacías.** Sin error en consola. Sin warning. **Nada.** Y tú mirando el
> `body-cell-status` durante 40 minutos, convencido de que el `name` está mal.
>
> Es el mismo fallo de Q1, con otro componente. **Cuando algo de Quasar no
> renderiza y no hay error: es `framework.components`.** Siempre.

---

## 🐛 6. Errores clásicos

| # | Síntoma | Causa | Arreglo |
|---|---|---|---|
| 1 | Los slots `body-cell-*` no pintan nada. Sin error. | `QTd` no está en `framework.components`. | Declararlo. |
| 2 | El slot no se aplica, sale la celda por defecto. | El `name` de la columna no coincide con `body-cell-<name>`. Typo. | `name: "status"` ↔ `v-slot:body-cell-status`. |
| 3 | La tabla se descuadra en móvil, las celdas custom se solapan. | Usaste `<td>` en vez de `<q-td :props="props">`. | `<q-td :props="props">`. Siempre. |
| 4 | Ninguna columna ordena al clicar la cabecera. | `sortable` es `false` por defecto. | `sortable: true` en cada columna. |
| 5 | La columna ordena por texto, no por fecha ("31/01" antes que "05/03"). | Aplicaste `format` **y** ordenaste por el valor formateado. | `format` solo pinta. El orden usa `field`. Si lo hiciste al revés, quita el `format` de `field`. |
| 6 | `response.headers["X-Total-Count"]` → `undefined`. | axios normaliza los headers a **minúsculas**. | `response.headers["x-total-count"]`. |
| 7 | Igual que el 6, pero en minúsculas también falla, y el header **se ve** en la pestaña Network. | CORS: falta `Access-Control-Expose-Headers`. | Se arregla en el **backend**. 💸 |
| 8 | Server-side: tabla vacía, sin loading, sin error, al entrar. | `QTable` no dispara `@request` al montarse. | Llamar a `onRequest()` en `created()`. |
| 9 | Server-side: la tabla pagina **dos veces** (recibes 10 filas y te enseña 10 de 10, pero el footer dice "1-10 de 10"). | `rowsNumber` no está en el objeto de paginación → `QTable` cree que es modo cliente. | `rowsNumber: 0` en el `data()` desde el principio, y asignarlo tras el fetch. |
| 10 | Server-side: clicas "página 2" y ves la página 1 otra vez. | Copiaste la caché de `fetchTickets` (F10) a `fetchTicketsPaged`. | La action paginada **no cachea**. |
| 11 | `[vuex] do not mutate vuex store state outside mutation handlers` al ordenar. | `:pagination.sync` contra un computed **sin setter**. | Computed con `get`/`set` → commit. (§4.5, Opción B.) |
| 12 | Lo mismo que el 11 pero **en producción no da error** — y el time travel de las devtools no muestra nada. | `strict` está apagado en prod (F10). Vuex muta en silencio. | El mismo arreglo. Y **nunca** confíes en que "en prod va bien". |
| 13 | El layout se rompe al meter `QTable`: márgenes raros, columnas pegadas. | `.row` de Bootstrap vs `.row` de Quasar. | No mezcles grids en el mismo subárbol. §4.7. |
| 14 | El `<q-select>` dentro del modal Bootstrap se abre **detrás** del modal. | z-index. Bootstrap `1050` vs los portales de Quasar. | Ajustar z-index, o usar `<q-dialog>` en esa vista. |
| 15 | `:filter="search"` (string) funciona, pero al añadir el filtro de estado deja de resetear la página. | `QTable` vigila `:filter` con deep watch. Un objeto nuevo cada vez → OK. Mutar una propiedad de un objeto que Vue no observa → no dispara. | `filter: { search: "", status: null }` declarado en `data()` desde el inicio (así Vue lo observa entero). |
| 16 | Los tests de Q0 fallan: `wrapper.find(".table")` → no existe. | `QTable` renderiza `.q-table`, no `.table`. | **Este no es un bug: es la lección de Q0.** Si tu test buscaba una clase de Bootstrap, tu test estaba acoplado al DOM. Reescríbelo con `data-testid`. |

---

## 🏋️ 7. Ejercicios

### 🟢 Fácil (calentamiento)

**1.** Declara `QTable` y `QTd` en `framework.components`. Ahora **quita `QTd`**,
recarga, y mira los slots. ¿Qué error sale en consola? Escribe la respuesta.
*(Spoiler: ninguno. Ese es el ejercicio.)*

**2.** La columna `createdAt` usa `format` para pintar `10/03/2020`. Cámbialo para
que muestre "hace X días". Verifica que **sigue ordenando por fecha real**, no por
el texto que se ve.

**3.** Cambia el `align` de la columna `id` de `"left"` a `"right"`. Ahora
**bórralo entero**. ¿Qué alineación aplica Quasar por defecto?

**4.** Pon `:rows-per-page-options="[5]"`. ¿Qué le pasa al selector de filas por
página en el footer?

**5.** Cuenta las líneas. `git diff --stat` entre el `TicketsView.vue` de F4 y el
de Q3. Escribe el número de líneas borradas en un comentario al principio del
fichero.

**6.** Añade `flat` y `bordered` al `q-table`. Luego quítalos. Luego añade
`dense`. Describe en una frase qué hace cada uno.

**7.** Usa el slot `no-data` para pintar el mensaje "🔍 No hay tickets" de F4.
Filtra por un texto imposible y compruébalo.

**8.** Añade `loading-label="Cargando tickets…"`. ¿Dónde aparece? *(Pista:
necesitas que `loading` sea `true` el tiempo suficiente. Usa el throttle de red
de DevTools.)*

---

### 🟡 Medio

**9.** El filtro de F4 buscaba solo en `title`. Amplía `filterTickets` para que
busque también en la descripción y en el nombre del asignado. Sin romper el
filtro por estado.

**10.** `QTable` tiene una prop `filter` que acepta un **string** y filtra sola,
sin `filter-method`. Prueba `:filter="filter.search"` sin `filter-method`. ¿En
qué columnas busca? ¿Por qué el `field` como función rompe ese filtro por
defecto?

**11.** Migra las **tarjetas resumen** de F4 (`<div class="card">` de Bootstrap) a
`<q-card>`. Compara ambas versiones en el navegador. ¿Cuál necesita menos código?
¿Cuál es más fácil de personalizar?

**12.** Añade `:visible-columns` con un `<q-select multiple>` en el slot
`top-right`, para que el usuario elija qué columnas ve. ¿Dónde vive ese estado:
componente o store? **Aplica la regla de F10 y justifícalo en un comentario.**

**13.** El botón de eliminar usa `this.$q.dialog`. Reemplázalo por un
un modal Bootstrap de confirmación (jQuery, como el `ConfirmModal.vue` del
ej. 18 de F5). Ambos funcionan. Escribe 3 líneas sobre cuál
prefieres **y por qué** — no cuál es "mejor".

**14.** Mete el modo `grid` (`<q-table grid>`) tras un toggle. Comprueba que tus
slots `body-cell-*` **dejan de aplicarse**. Averigua qué slot los sustituye.

**15.** Pon `virtual-scroll` con `:rows-per-page-options="[0]"` (0 = todas).
Genera 5.000 tickets falsos en el `db.json` y compara el rendimiento con la
paginación normal. Mide con la pestaña Performance.

**16.** El `q-input` de búsqueda tiene `debounce="300"`. Quítalo y añade un
`console.log` en `filterTickets`. Teclea "urgente". ¿Cuántas veces se ejecuta?
Ahora ponlo. ¿Cuántas?

---

### 🟠 Difícil

**17.** **Implementa el modo server-side completo.** `@request`, `loading`,
`rowsNumber`. Con `fetchTicketsPaged` en el store y `getTicketsPaged` en el
service. El mapeo del `X-Total-Count` **vive en el service**. Verifica en la
pestaña Network que **solo se piden 10 tickets por página**, no los 43.

**18.** Con el server-side del 17: haz que el **filtro de búsqueda también viaje
al backend** (`props.filter` → `?q=urgente` de json-server). Compara: ¿cuántas
peticiones dispara escribir "urgente" letra a letra sin debounce?

**19.** **Persiste la paginación en la URL.** `/tickets?page=3&sort=title&desc=1`.
Al recargar, la tabla vuelve al mismo sitio. **Sin Vuex.** Usa `$route.query` +
`$router.replace`. Ojo con el bucle infinito: cambiar la query dispara el watcher
que cambia la paginación que cambia la query.

**20.** El proyecto ahora tiene **dos sistemas de notificación**: el módulo `ui`
con `FLASH` (F10) y `this.$q.notify` (Quasar). Ambos funcionan. **Elige uno y
elimina el otro de todo el proyecto.** Justifica la elección en 5 líneas.
*(Pista: uno de los dos lo usa el `socketPlugin` del store, que no tiene acceso a
`this.$q`.)*

**21.** Añade `selection="multiple"` + `:selected.sync` y un botón "Cerrar
seleccionados". ¿Dónde vive `selected`? ¿Es lo mismo que la paginación, o es un
caso distinto? **Argumenta desde F10.**

**22.** Implementa la **Opción B** de §4.5 completa: `:pagination.sync` contra el
módulo `ui` del store, con el computed `get`/`set`. Ahora abre las Vue Devtools →
Vuex → time travel. Clica cinco veces "página siguiente". **¿Puedes usar el time
travel para depurar algo real, o el historial es basura?** Escribe la respuesta.

**23.** Con el 22 implementado y **`strict: true`**: quita el `set` del computed.
¿Qué error sale? Ahora pon `strict: false` (simula producción). ¿Qué error sale
ahora? ¿Qué le pasa al store? **Este ejercicio es la razón por la que existe
`strict`.**

**24.** **La demostración del `.row`.** Crea una vista de laboratorio con el
snippet de §4.7. Inspecciona con DevTools. Haz una **captura de la regla tachada**
y pégala en un `MIGRACION.md`. Luego **cambia el orden de carga del CSS** en
`quasar.conf.js` y comprueba que gana el otro.

**25.** Añade un botón **fuera** del `q-table` que diga "Ir a la última página".
Con la **Opción A** (sin `:pagination.sync`), la única vía es
`this.$refs.tabla.setPagination({ page: N })`. Implémentalo. Luego hazlo con la
Opción B. **Compara las dos implementaciones y di cuál te parece más honesta.**

---

### 🔴 Muy difícil

**26.** **Escribe tu decisión.** Un documento `DECISION-PAGINACION.md`, formato
de la auditoría de F10:

| Estado | ¿Lo lee otra vista? | ¿Sobrevive a navegación? | ¿Lo necesita un guard/interceptor? | ¿Serializable? | **Dueño** | **Por qué** |
|---|---|---|---|---|---|---|

Una fila por cada pieza: `page`, `rowsPerPage`, `sortBy`, `descending`,
`rowsNumber`, `filter.search`, `filter.status`, `selected`.
**Y luego un párrafo defendiendo tu conclusión.** Puede contradecir la de §4.5.
Lo que no puede es decir "depende del caso".

**27.** El `filter` de la tabla y el `search` del store. En F10 decidiste que
`search` era local. Pero ahora las **métricas de F7** quieren pintar solo los
tickets filtrados. **Ahora sí lo lee otra vista.** La regla de F10 dice: al store.
Hazlo. Y luego responde: **¿cambia eso tu decisión sobre la paginación?** ¿Por
qué sí o por qué no?

**28.** **Rompe la convivencia a propósito.** Envuelve el `<q-table>` en un
`<div class="row">` de Bootstrap y mete el modal Bootstrap dentro de un `<div
class="col-md-6">` de Quasar. Documenta **exactamente** qué se rompe, con
capturas, y arréglalo. Luego escribe la regla que se saltó.

**29.** El `q-select` del filtro de estado usa `emit-value` + `map-options` (Q2).
Quítale `emit-value`. Ahora el `v-model` recibe el **objeto entero**
(`{label, value}`), no el string. **Sin tocar los badges de F4** (que esperan un
string) ni el modelo del store (`status` es un string, siempre). Documenta dónde
pusiste el adaptador y **por qué NO va en el componente**.

**30.** ⭐ **EL EJERCICIO DE LA FASE — Migración transversal sin guía**

> **Migra el panel de soporte (F9) a Quasar. Tú solo.**

Reglas:

1. **Escribe TÚ los tests de regresión primero.** Antes de tocar una línea de
   `SupportView.vue`. Con lo que aprendiste en Q0: comportamiento observable,
   `data-testid`, contrato con el store, contrato con el service. **No** clases de
   Bootstrap. **No** estructura del DOM.
2. **No hay guía.** Ni tabla de equivalencias, ni snippet, ni "pista". El panel de
   F9 tiene: cola de tickets (¿`QTable`? ¿`QList`? **decide tú**), asignación de
   agente (¿`q-select`?), comentarios (¿lista? ¿`QChat`?), cambio de estado.
3. **El modal de comentarios se queda en Bootstrap.** No lo migres. Y demuestra
   con un test que sigue funcionando.
4. **El socket de F8 no se toca.** El `socketPlugin` de F10 sigue commiteando.
   Si tu migración obliga a tocar el plugin, **la migración está mal**.
5. **Los tests deben pasar al final.** Si alguno no pasa, tienes dos opciones:
   arreglar el código, o **demostrar por escrito que el test estaba mal**.

**Entregable — `MIGRACION-F9.md`:**

- **Qué se rompió.** Lista literal. Cada cosa.
- **Cuántos tests fallaron** al primer intento, y **cuántos eran culpa del test**
  (acoplado al DOM) vs **culpa del código** (regresión real).
- **Qué componentes de F9 sobrevivieron intactos.** ¿Los badges? ¿El
  `CommentList`? ¿Por qué esos y no otros?
- **Cuántas líneas borraste.** Netas.
- **Dónde tuviste que tocar el store.** Y si la respuesta es "en ningún sitio",
  **di por qué eso es la nota más importante del documento.**
- **Qué dejaste en Bootstrap y por qué.** Sin decir "por falta de tiempo".

> 🎯 **Este ejercicio es el examen de la ruta.** Q0 te enseñó a escribir la red.
> Q1, a leer. Q2 y Q3, a migrar con guía. Aquí no hay red que no hayas tejido tú,
> ni guía que no seas tú.
>
> Si el store no se entera de que has migrado el panel entero: **has aprobado.**

---

## 📚 8. Referencias

> ⚠️ **quasar.dev sirve la documentación de v2 (Vue 3) por defecto.** Necesitas
> **v1**. Los enlaces de abajo apuntan al archivo de v1 (`v1.quasar.dev`). Si
> acabas en una página con `<script setup>` o Composition API, **estás en la doc
> equivocada**.

**QTable (v1)**
- Introducción y props — https://v1.quasar.dev/vue-components/table
- Definición de `columns` — https://v1.quasar.dev/vue-components/table#Defining-the-columns
- Paginación — https://v1.quasar.dev/vue-components/table#Pagination
- **Modo server-side (`@request`)** — https://v1.quasar.dev/vue-components/table#Synchronizing-with-server
- Slots (`body-cell-*`, `top-right`, `no-data`) — https://v1.quasar.dev/vue-components/table#Slots
- Filtrado y `filter-method` — https://v1.quasar.dev/vue-components/table#Filtering

**Componentes relacionados (v1)**
- QTd — https://v1.quasar.dev/vue-components/table#QTd-API
- QSelect (`emit-value`, `map-options`) — https://v1.quasar.dev/vue-components/select
- Notify plugin — https://v1.quasar.dev/quasar-plugins/notify
- Dialog plugin — https://v1.quasar.dev/quasar-plugins/dialog
- **Flex grid de Quasar** (el que choca con Bootstrap) — https://v1.quasar.dev/layout/grid/introduction-to-flexbox
- Spacing (`q-pa-*`, `q-gutter-*`) — https://v1.quasar.dev/style/spacing
- `framework.components` en `quasar.conf.js` — https://v1.quasar.dev/quasar-cli/quasar-conf-js#Property%3A-framework

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
- *(bootstrap-vue, solo para reconocerlo en otros legacy — el curso no lo usa)* — https://bootstrap-vue.org/

**json-server (la deuda 💸)**
- Paginación (`_page`, `_limit`) y `X-Total-Count` — https://github.com/typicode/json-server/tree/v0.16.3#paginate
- Búsqueda full-text (`?q=`) — https://github.com/typicode/json-server/tree/v0.16.3#full-text-search

**axios**
- Headers de respuesta (normalizados a minúsculas) — https://github.com/axios/axios#response-schema

**CORS (el fallo #7)**
- `Access-Control-Expose-Headers` — https://developer.mozilla.org/es/docs/Web/HTTP/Headers/Access-Control-Expose-Headers

---

## 🌉 9. Cierre y puente a Q4

### Lo que te llevas

**Borraste ~150 líneas.** Filtro, orden, paginación, los dos watchers que
parcheaban los bugs de la paginación, y el markup de la `<table>` con sus
flechitas. Todo eso lo hace `QTable`. **Y lo hace mejor que tú**, porque lo han
depurado miles de proyectos.

**Cediste el control.** Ese es el precio, y lo pagaste a conciencia:
`QTable` es ahora el dueño del estado de paginación, y ese estado **no se ve en
las devtools de Vuex**. Lo defendiste por escrito. Puedes cambiar de opinión
mañana — pero sabrás qué estás cambiando y qué cuesta.

**Y sobre todo: viste el flujo completo.** Un `<q-btn>` que abre un modal Bootstrap
que contiene un `<q-form>` que emite un evento Vue que commitea a Vuex que
repinta un `<q-table>`. Seis saltos entre dos frameworks de UI.

**Y el store no se enteró de ninguno.**

Esa es la lección. No es "Quasar es bueno". Es: **si tu arquitectura está bien —
Componente → Store → services/ → apiClient → API — la capa de UI es reemplazable
por trozos.** El día que haya que migrar esto a Vue 3, o a Vuetify, o a lo que
venga en 2029, **el store, los services y el interceptor van a sobrevivir.** Los
componentes no. Y está bien: los componentes son lo barato.

### El puente

Hasta aquí, todo lo que has hecho es **traducir**.

F5 → `QForm`. F4 → `QTable`. F9 → lo que hayas decidido en el ejercicio 30. En
todos los casos había un original. Sabías cómo tenía que quedar, porque lo tenías
delante. Si algo se rompía, comparabas.

**Eso es una muleta.** Y es una muleta muy buena — es exactamente lo que vas a
hacer los primeros seis meses en un proyecto legacy: leer lo que hay, entenderlo,
y cambiarlo por algo equivalente.

Pero llega el día en que te piden **algo que no existe**. Un requisito nuevo. Y
entonces no hay original que copiar, no hay test de regresión que te diga si te
has desviado, y no puedes decir "es que antes funcionaba así". Tienes que **abrir
la documentación de Quasar y construir**.

**Eso es Q4.**

> **Q4 — Timeline de actividad.** Una feature que **no está en el curso base**.
> Aterriza los WebSockets de F8 en algo visual: `QTimeline`, `QChip`, un modelo
> de datos nuevo (`activity`), y la decisión de F10 aplicada a un caso virgen —
> **¿el timeline vive en Vuex o es local?** Sin original que copiar. Sin trampa.
>
> Quasar puro. Sin traducir nada.

Y ahí, con el timeline pintándose en vivo, es donde vas a descubrir si de verdad
aprendiste Quasar… o si solo aprendiste a traducir de Bootstrap.

---

> 💸 **Deudas abiertas al cerrar Q3**
>
> | Deuda | Qué falta | Quién lo paga en producción |
> |---|---|---|
> | `X-Total-Count` → `rowsNumber` | Mapeo a mano en el service. Y CORS con `Access-Control-Expose-Headers`. | **Backend**: te da el total en el body o en un header expuesto. Y lo acordáis **antes**. |
> | Server-side implementado pero no usado | El Mini Jira usa modo cliente (40 tickets). | Nadie. **El día que sean 40.000, el interruptor ya está montado.** |
> | Dos sistemas de notificación (`ui/FLASH` + `$q.notify`) | Uno de los dos sobra. | **Tú.** Ejercicio 20. |
> | Bootstrap y Quasar conviviendo | 190KB de CSS que nadie se atreve a quitar. | **Nadie, nunca.** Y no pasa nada. Bienvenido al legacy. |
