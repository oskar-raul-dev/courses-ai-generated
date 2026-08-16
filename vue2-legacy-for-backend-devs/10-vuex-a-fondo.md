# 🗂️ Fase 10 — Vuex a fondo

## 🎯 Propósito

Nueve fases diciendo "eso todavía no va al store" acumularon una deuda de
explicación. Hoy se paga: Vuex **completo y formal** — y más importante, el
**criterio** para decidir qué estado se vuelve global, respaldado por la
evidencia que el propio curso generó.

Porque esta fase no es "aprende Vuex" (ya lo usas desde la Fase 2). Es la
fase del **refactor consciente**: los tickets viven hoy duplicados en tres
vistas (dashboard, panel, métricas), cada una con su copia, su loading y su
handler de socket. Esa duplicación fue deliberada — necesitabas sentirla para
que la solución tuviera sentido. Ahora migramos los tickets al store, dejamos
por escrito qué NO se migra y por qué, y de paso aprendes las piezas de Vuex
que faltaban: **mapHelpers**, **strict mode**, **plugins** y el clásico dolor
de **v-model contra el store**.

> La regla de la fase: al store va lo que la evidencia pide,
> no lo que el tutorial de turno sugiere. Criterio antes que dogma.

---

## ✅ Qué queda listo al terminar

- anatomía completa de Vuex 3: state, getters, mutations, actions, módulos
  con namespace — con el flujo unidireccional entendido, no memorizado;
- **módulo `tickets` real**: items, loading, error, y toda mutación de
  tickets pasando por un solo lugar;
- dashboard, panel de soporte y métricas leyendo del store — **una** fuente
  de verdad, tres consumidores;
- los eventos de socket entrando por un **plugin de Vuex**: los handlers
  duplicados de las Fases 8 y 9 desaparecen;
- componentes refactorizados con `mapState`/`mapGetters`/`mapActions` (adiós
  a los strings kilométricos de `$store.getters["..."]`);
- **strict mode** activo en desarrollo, cazando mutaciones furtivas;
- el documento de decisiones: qué entró al store, qué no, y la evidencia de
  cada caso.

## 🚫 Qué NO entra todavía

- Pinia, Composition API stores, patrones de Vue 3 (otro curso);
- persistencia automática del store (vuex-persistedstate es ejercicio 🟡);
- normalización estilo entidades/ids al extremo (se discute, no se impone);
- migrar TODO al store — precisamente el anti-objetivo de la fase.

---

## 🧠 Concepto 1: la anatomía completa (y el porqué de cada pieza)

El flujo unidireccional de Vuex, con todos sus actores:

```
            dispatch                commit
COMPONENTE ─────────→ ACTION ──────────────→ MUTATION ──→ STATE
    ↑                 (async OK:              (SÍNCRONA:      │
    │                  HTTP, sockets,          solo asignar)  │
    │                  lógica, varios                         │
    │                  commits)                               ▼
    └──────────────────── getters (derivar) ◄─────────────────┘
```

| Pieza | Qué es | Regla de oro | Su gemelo en el componente |
|---|---|---|---|
| **state** | los datos crudos | solo las mutations lo tocan | `data` |
| **getters** | derivaciones con caché | puros, sin efectos | `computed` |
| **mutations** | LA forma de escribir el state | **síncronas** siempre | — (no hay: por eso existe Vuex) |
| **actions** | orquestación | async permitido; terminan en commits | `methods` |

**¿Por qué mutations síncronas y actions aparte?** No es capricho: es
**trazabilidad**. Las devtools de Vue graban cada mutation como un snapshot
del antes/después (time-travel debugging). Si una mutation hiciera un
`setTimeout` o un HTTP adentro, el snapshot mentiría: el estado seguiría
cambiando "después de la foto". La división es: **la action tarda lo que
tarde; la mutation es el instante exacto del cambio**. En legacy verás
mutations con async adentro — funciona de chiripa y rompe las devtools:
ahora sabes qué reparar.

**¿Y strict mode?** En desarrollo, hace que Vuex **lance error** si alguien
modifica el state fuera de una mutation (un componente haciendo
`this.$store.state.tickets.items.push(...)`, el pecado capital):

```js
export default new Vuex.Store({
  strict: process.env.NODE_ENV !== "production", // caro: solo en dev
  modules: { /* ... */ }
});
```

Solo en dev porque la vigilancia (deep watch de todo el state) cuesta. Es el
`novalidate` inverso: una alarma que quieres sonando mientras construyes.

## 🧠 Concepto 2: el criterio — ¿qué va al store?

Las cuatro preguntas, en orden. Con dos o más "sí", el store es candidato
serio; con uno, probablemente no; con cero, seguro que no:

1. **¿Lo consumen 2+ vistas/componentes que conviven o se alternan?**
2. **¿Debe sobrevivir a la navegación** (sin ser algo que la URL exprese
   mejor)?
3. **¿Lo mutan varias fuentes?** (HTTP + sockets + acciones del usuario…)
4. **¿La inconsistencia entre consumidores sería un bug visible?**

Y ahora, la auditoría de TODO lo que el curso decidió — el criterio aplicado
a evidencia real, no a ejemplos inventados:

| Estado | 2+ vistas | Sobrevive nav. | Multi-fuente | Inconsistencia = bug | Veredicto | Dónde quedó |
|---|---|---|---|---|---|---|
| Sesión (token, user) | ✅ header, guard, HTTP | ✅ | ✅ login/logout/401 | ✅ | **store** | F2, módulo `auth` ✅ |
| **Tickets** | ✅ dashboard + panel + métricas | ✅ | ✅ HTTP + socket + PATCH | ✅ ("tomé el ticket y métricas no se enteró") | **store** | **hoy se migra** 🎯 |
| Borrador del wizard | ❌ una vista | ❌ (aceptamos perderlo) | ❌ solo el usuario | ❌ | local | F6, `data` del wizard ✅ |
| Filtros del dashboard | ❌ | ✅ pero… | ❌ | ❌ | **URL** (query params) | F4 ej. 13 — la URL expresa filtros mejor que un store |
| Selección del panel | ❌ | ❌ | ❌ | ❌ | local (+URL ej.) | F9, `selectedId` ✅ |
| Comentarios del ticket | ❌ (por-ticket) | ❌ (el `:key` los renueva a propósito) | ~ | ❌ | local | F9, workspace ✅ |
| Flash messages | ✅ cualquier vista emite, App pinta | ✅ (cruzan navegación) | ✅ | ~ | **store** (chiquito) | F5 ej. 20 — se gradúa hoy |

Dos lecciones escondidas en la tabla: la **URL es un store subestimado**
(compartible, sobrevive a F5, con botón atrás gratis — para filtros y
selección le gana a Vuex), y "sobrevive a la navegación" tiene un contra-caso
en los comentarios: a veces **quieres** que el estado muera con la vista, y
el `:key` de la Fase 9 es justamente esa decisión hecha mecanismo.

---

## 🧩 Mini repaso: lo nuevo de Vuex/Vue en esta fase

### mapHelpers — el fin de los strings kilométricos

Llevamos ocho fases escribiendo `this.$store.getters["auth/currentUser"]`.
La forma idiomática son los helpers, que **generan** computed y methods:

```js
import { mapState, mapGetters, mapActions } from "vuex";

export default {
  computed: Object.assign(
    {},
    mapState("tickets", ["loading", "error"]),      // → this.loading, this.error
    mapGetters("tickets", ["allTickets", "counts"]), // → this.allTickets, ...
    mapGetters("auth", { me: "currentUser" }),       // renombrando: this.me
    {
      // y tus computed propios conviven en el mismo objeto
      filteredTickets: function () { /* ... */ }
    }
  ),
  methods: Object.assign(
    {},
    mapActions("tickets", ["fetchTickets", "updateTicket"]),
    { /* métodos propios */ }
  )
};
```

**⚰️ Nota de época importante:** en tutoriales de 2018+ verás
`...mapGetters(...)` con spread dentro del objeto — eso requiere una versión
de Babel/preset que lo soporte. `Object.assign` es el equivalente a prueba de
configuraciones viejas, y verás ambos en legacy. Los helpers son azúcar:
generan exactamente los computed/methods que escribías a mano — si un
`mapGetters` te confunde, expándelo mentalmente y desaparece la magia.

### v-model contra el store: computed con get/set

El choque clásico: `v-model` quiere escribir, el store prohíbe escrituras
directas. Un `v-model="$store.state.ui.search"` funciona… hasta que strict
mode lo fusila. La solución idiomática es el computed bidireccional:

```js
computed: {
  search: {
    get: function () { return this.$store.state.ui.search; },
    set: function (value) { this.$store.commit("ui/SET_SEARCH", value); }
  }
}
```

```vue
<input v-model="search" />  <!-- lee del get, escribe por el set → commit -->
```

Los computed llevan todo el curso siendo solo-lectura; esta es su forma
completa: un getter y un setter. `v-model` no distingue — para él, `search`
es una propiedad más. (El ejercicio 12 lo usa en serio.)

### Plugins de Vuex — código que vive CON el store

Un plugin es una función que recibe el store al crearse, y puede suscribirse
o hacer commits desde afuera de cualquier componente:

```js
function myPlugin(store) {
  // corre UNA vez al crear el store
  store.subscribe(function (mutation, state) {
    // espía cada mutation (logging, persistencia...)
  });
  // o commitear por eventos externos (sockets 👀)
}
```

Es el lugar natural para "cosas que reaccionan a/alimentan el store sin ser
UI": persistencia, logging, y — nuestro caso estrella — **los eventos de
socket**. Hasta hoy, cada vista suscribía su propio handler (F8, F9); con un
plugin, el socket commitea una vez y **todas** las vistas conectadas al store
se enteran. La duplicación que arrastramos dos fases muere aquí.

### Las devtools con time travel (tu nueva mejor amiga)

Con el módulo bien hecho y strict mode activo, abre Vue Devtools → pestaña
Vuex: cada mutation queda grabada con su payload y el estado resultante.
Puedes **viajar en el tiempo** (revertir al estado tras cualquier mutation) y
ver quién cambió qué y cuándo. Es LA razón práctica de toda la ceremonia de
Vuex — un `data` compartido a mano jamás te dará esta radiografía. El
ejercicio 5 es literalmente "juega con esto 15 minutos".

---

## 💻 Código de la fase

### El módulo `tickets`, versión adulta

```js
// store/modules/tickets.js
import ticketService from "../../services/ticketService";

const state = {
  items: [],
  loading: false,
  error: ""
};

const getters = {
  allTickets: function (state) {
    return state.items;
  },
  ticketById: function (state) {
    // getter que devuelve función: la forma Vuex de getters con argumento
    return function (id) {
      return state.items.find(function (t) { return t.id === Number(id); }) || null;
    };
  },
  activeTickets: function (state) {
    return state.items.filter(function (t) { return t.status !== "closed"; });
  }
};

const mutations = {
  SET_LOADING: function (state, value) {
    state.loading = value;
  },
  SET_ERROR: function (state, message) {
    state.error = message;
  },
  SET_TICKETS: function (state, tickets) {
    state.items = tickets;
  },
  ADD_TICKET: function (state, ticket) {
    state.items.unshift(ticket);
  },
  UPSERT_TICKET: function (state, ticket) {
    var index = state.items.findIndex(function (t) { return t.id === ticket.id; });
    if (index === -1) {
      state.items.unshift(ticket);
    } else {
      state.items.splice(index, 1, ticket); // reactivo (F8), ahora en su casa
    }
  },
  REMOVE_TICKET: function (state, id) {
    state.items = state.items.filter(function (t) { return t.id !== id; });
  }
};

const actions = {
  fetchTickets: function (context, options) {
    options = options || {};

    // caché ingenuo: si ya hay datos y nadie fuerza, no vayas a la red
    if (context.state.items.length > 0 && !options.force) {
      return Promise.resolve(context.state.items);
    }

    context.commit("SET_LOADING", true);
    context.commit("SET_ERROR", "");

    return ticketService
      .getTickets({ _sort: "createdAt", _order: "desc" })
      .then(function (tickets) {
        context.commit("SET_TICKETS", tickets);
        return tickets;
      })
      .catch(function (error) {
        context.commit("SET_ERROR", "No se pudieron cargar los tickets.");
        throw error; // re-lanzar: la vista puede reaccionar si quiere
      })
      .finally(function () {
        context.commit("SET_LOADING", false);
      });
  },

  updateTicket: function (context, payload) {
    // payload: { id, changes }
    return ticketService
      .updateTicket(payload.id, payload.changes)
      .then(function (updated) {
        context.commit("UPSERT_TICKET", updated);
        return updated;
      });
  }
};

export default {
  namespaced: true,
  state: state,
  getters: getters,
  mutations: mutations,
  actions: actions
};
```

**🔎 Qué hace, pieza por pieza:**

| Pieza | Su trabajo |
|---|---|
| `items/loading/error` | el trío de la Fase 3 (loading/error/data), ascendido a estado compartido: UNA carga, N vistas |
| `ticketById` (getter-función) | los getters no aceptan argumentos… salvo que devuelvan una función. El patrón oficial — con el costo de que **pierde la caché** (se re-evalúa en cada llamada) |
| `UPSERT_TICKET` | la mutation estrella: sirve para el PATCH propio, el socket ajeno y cualquier futuro — inserta o reemplaza, siempre reactivo |
| `fetchTickets` con caché | el patrón "no re-pidas lo que ya tienes" del ej. 25 de la Fase 3, ahora en el lugar correcto: la action decide, las vistas ni se enteran |
| el `throw error` re-lanzado | la action maneja el estado global del error Y deja que la vista encadene su propia reacción — dos niveles de manejo, sin robarle el error a nadie |

**✅ Buenas prácticas aplicadas:**
- **Mutations en MAYÚSCULAS_CON_GUION** — convención de la época (herencia de
  Redux) que grita "esto es un evento de cambio de estado" en las devtools.
  No es obligatoria; SÍ es consistencia: elige una y no la mezcles.
- Las mutations son **aburridas a propósito**: asignan, insertan, reemplazan.
  Toda la inteligencia (caché, HTTP, decisión de upsert) vive en actions o en
  la propia estructura. Mutation lista = devtools legibles.
- La action **devuelve la Promise** — la lección de la Fase 3, obligatoria
  aquí: sin el `return`, ninguna vista puede encadenar `.then` tras un
  dispatch y los errores caen al vacío.
- El servicio sigue existiendo por debajo: **Vuex no reemplaza la capa de
  servicios**, la consume. Store que hace axios directo = dos
  responsabilidades pegadas que costará separar (olor legacy frecuente).

### El plugin de socket — la duplicación muere aquí

```js
// store/plugins/socketPlugin.js
import socketService from "../../services/socketService";

export default function socketPlugin(store) {
  // Nota: connect/disconnect siguen siendo del watch de App.vue (vida = sesión).
  // El plugin solo REGISTRA qué hacer cuando lleguen eventos.
  socketService.on("ticket:created", function (ticket) {
    store.commit("tickets/UPSERT_TICKET", ticket);
    store.commit("ui/FLASH", { type: "info", text: "🎫 Nuevo ticket #" + ticket.id });
  });

  socketService.on("ticket:updated", function (ticket) {
    store.commit("tickets/UPSERT_TICKET", ticket);
  });
}
```

```js
// store/index.js — versión final
import Vue from "vue";
import Vuex from "vuex";
import auth from "./modules/auth";
import tickets from "./modules/tickets";
import ui from "./modules/ui";
import socketPlugin from "./plugins/socketPlugin";

Vue.use(Vuex);

export default new Vuex.Store({
  strict: process.env.NODE_ENV !== "production",
  modules: { auth: auth, tickets: tickets, ui: ui },
  plugins: [socketPlugin]
});
```

**🔎 Qué hace:** registra los listeners de socket **una sola vez**, al crear
el store, y los traduce a commits. A partir de aquí, TODA vista que lea
`tickets/allTickets` reacciona a los eventos en vivo — dashboard, panel,
métricas — sin que ninguna sepa que los sockets existen.

**✅ Buenas prácticas aplicadas (y una decisión explicada):**
- Los handlers de socket de `TicketsView` (F8) y `SupportView` (F9) **se
  eliminan** en el refactor: eran N suscripciones frágiles (on/off por vista,
  referencias bind, zombis acechando); ahora es UNA suscripción con vida de
  aplicación — ni siquiera necesita `off`, porque el store vive lo que la app.
- El plugin **no conecta ni desconecta** el socket: eso sigue en el watch de
  `App.vue` (Fase 8), porque la *conexión* tiene vida de sesión y el
  *registro de handlers* tiene vida de aplicación. Dos ciclos de vida
  distintos, dos dueños — como el socket registra handlers aunque esté
  desconectado y los conserva al reconectar, registrar temprano es seguro.
- ¿Y el `LiveToast`? Su suscripción directa también muere: ahora el plugin
  commitea a `ui/FLASH` y el toast se vuelve un componente tonto que pinta el
  state de `ui` — el flash-message del ejercicio 20 de la Fase 5,
  oficializado como módulo `ui` (queda como parte del refactor guiado, y su
  módulo es el ejercicio 4… de calentamiento).

### El refactor de las vistas — antes y después

El dashboard (F4), quirúrgicamente:

```js
// views/TicketsView.vue — DESPUÉS
import { mapGetters, mapState, mapActions } from "vuex";

export default {
  // data: se van tickets, loading, error → QUEDAN search y statusFilter
  data: function () {
    return { search: "", statusFilter: "" };
  },
  computed: Object.assign(
    {},
    mapState("tickets", ["loading", "error"]),
    mapGetters("tickets", { tickets: "allTickets" }), // renombrado: el template no cambia
    {
      filteredTickets: function () {
        // idéntico a la Fase 4: filtra this.tickets... que ahora es un getter.
        // El computed NO SE ENTERÓ de la migración. 🎩
        var self = this;
        var term = this.search.trim().toLowerCase();
        return this.tickets.filter(function (t) {
          var matchesSearch = !term || t.title.toLowerCase().indexOf(term) !== -1;
          var matchesStatus = !self.statusFilter || t.status === self.statusFilter;
          return matchesSearch && matchesStatus;
        });
      }
    }
  ),
  mounted: function () {
    this.fetchTickets(); // el caché de la action decide si hay red o no
  },
  methods: Object.assign(
    {},
    mapActions("tickets", ["fetchTickets"]),
    {
      clearFilters: function () { this.search = ""; this.statusFilter = ""; },
      goToDetail: function (ticket) { this.$router.push("/tickets/" + ticket.id); }
    }
  )
  // beforeDestroy: ya no hay socket que dar de baja. Una preocupación menos.
};
</script>
```

**🔎 La radiografía del refactor** (esto es lo que hay que saber hacer en
legacy — medir un refactor por lo que se VA):

| Se fue de la vista | A dónde | Por qué |
|---|---|---|
| `tickets` en data | getter del módulo | 3 vistas, 1 copia |
| `loading`/`error` en data | state del módulo | la carga es una sola |
| `loadTickets` completo | action `fetchTickets` | con caché de regalo |
| handler de socket + on/off | plugin | de N suscripciones a 1 |
| **Se quedó** | | |
| `search`, `statusFilter` | data local | la auditoría dijo URL/local — el store no los pidió |
| `filteredTickets` | computed local | deriva estado global + local: su lugar es donde está lo local |

El mismo tratamiento aplica a `SupportView` (sus computed `unassigned`/`mine`
se quedan en la cola — derivan del getter — y `onTicketUpdated` se reduce a
despachar `updateTicket`, porque el UPSERT ya lo hace el módulo) y a
`MetricsView` (sus computed de agregación ahora envuelven el getter — las
funciones puras de la Fase 7 ni se tocan).

---

## 🔄 Los flujos de la fase, paso a paso

### 🔍 Un dispatch bajo el microscopio (con devtools abiertas)

```
1. TicketsView monta → this.fetchTickets() (method generado por mapActions)
   └─ equivale a this.$store.dispatch("tickets/fetchTickets")

2. la action evalúa su caché:
   ├─ hay items y no hay force → Promise.resolve(items). CERO red, cero commits.
   │   (segunda visita al dashboard: instantánea — el usuario lo nota)
   └─ no hay items →
       a. commit SET_LOADING(true)     ← devtools: mutation #1 grabada 📸
       b. GET /tickets (el servicio de la F3, intacto)
       c. commit SET_TICKETS(datos)    ← mutation #2 📸
       d. finally: commit SET_LOADING(false) ← mutation #3 📸

3. reactividad en abanico: TODO consumidor del state/getters repinta:
   ├─ TicketsView: spinner fuera, tabla adentro
   ├─ (si SupportView estuviera viva —tabs, keep-alive—: también)
   └─ las devtools muestran las 3 mutations con payload y timestamp
```

Compáralo con la Fase 3: el flujo loading→datos→finally es EL MISMO — solo
que ahora cada paso es una mutation nombrada y fotografiada. Vuex no cambió
qué pasa; cambió **cuánto puedes ver** de lo que pasa.

### 📡 Un evento de socket, versión store

```
ANTES (F8/F9): socket → handler de CADA vista suscrita → unshift local × N
               (y ay de la vista que olvidó el off)

AHORA:
1. otro usuario crea → server → socket entrega el evento
2. el handler del PLUGIN (único, registrado al nacer el store):
   ├─ commit tickets/UPSERT_TICKET  📸
   └─ commit ui/FLASH               📸
3. abanico reactivo:
   ├─ dashboard (si está montado): fila nueva vía filteredTickets
   ├─ panel (si está montado): la cola re-deriva "Sin asignar"
   ├─ métricas (si está montada): dona y barras via watch de la F7
   └─ el toast pinta el flash — sin saber de sockets
```

Tres vistas actualizándose por un evento que **ninguna escucha**. Esa es la
foto que justifica la fase.

### ✍️ v-model → store (el get/set en acción)

```
1. usuario teclea en un input con v-model="search" (computed get/set)
2. v-model escribe → corre el SET → commit ui/SET_SEARCH 📸
3. el state cambia → el GET del computed se invalida → el input re-lee
4. strict mode, mudo: la escritura pasó por donde debía
   (la versión v-model="$store.state..." habría explotado con
    "do not mutate vuex store state outside mutation handlers")
```

---

## ⚠️ Errores comunes

- **el error fundacional**: mutar state fuera de mutations — desde
  componentes, desde actions (`context.state.items.push(...)`), desde
  plugins. Strict mode existe para cazarlo: enciéndelo YA;
- async dentro de mutations: funciona a veces, miente a las devtools siempre;
- actions-cascarón 1:1 (`setLoading` action → `SET_LOADING` mutation, sin
  nada más) multiplicadas por todo: boilerplate sin valor — las actions
  existen para orquestar; si no orquestan nada, commitea directo;
- meter en el store lo que la auditoría rechazó "ya que estamos" (filtros,
  selección, borradores): acabas de leer 9 fases de evidencia en contra;
- olvidar `namespaced: true` → getters y actions de todos los módulos en un
  espacio global, colisionando en silencio;
- olvidar el `return` de la Promise en actions (reincidencia de la Fase 3,
  ahora con más víctimas: toda vista que despacha);
- getters-función (`ticketById`) usados en templates dentro de `v-for`:
  sin caché, se re-evalúan por ítem por render — para eso deriva un mapa en
  un getter normal;
- el store importando componentes o tocando `router` alegremente: el flujo
  es UI → store, no store → UI (navegar tras una action es decisión de la
  vista que despachó).

---

## 🧪 Ejercicios (26)

**🟢 Fácil (1–8)**

1. Enciende strict mode y navega TODA la app. Documenta cualquier warning
   que aparezca (si hiciste todo bien: ninguno — verifícalo).
2. Agrega el getter `openCount` y muéstralo como badge en el link "Tickets"
   del sidebar. Nota: el sidebar reacciona a sockets sin saberlo. 🤯
3. Agrega la mutation `CLEAR_TICKETS` y commitéala en el logout (¿desde
   dónde? — pista: la action de logout de auth puede despachar a otros
   módulos con `{ root: true }`... o hazlo simple desde el componente y
   compara).
4. Crea el módulo `ui` formal: state `flash` (`{type, text}` o null),
   mutations `FLASH`/`CLEAR_FLASH`, y refactoriza `LiveToast` para pintarlo
   (con su auto-clear de 5s — ¿el setTimeout va en el componente o en una
   action? justifica).
5. Sesión de devtools: provoca 10 mutations variadas, viaja en el tiempo a
   la #4, exporta el estado. 15 minutos que valen un capítulo.
6. Convierte `TicketDetailView` (F3) para intentar primero
   `ticketById(id)` del store y solo hacer fetch si no está (navegación
   dashboard→detalle: instantánea).
7. Refactoriza `MetricsView` al store (el patrón del dashboard, aplicado por
   ti). Las funciones de `ticketStats` no deben cambiar ni una coma.
8. Agrega `lastFetchedAt` al state y muéstralo en las métricas ("datos de
   hace N min") en vez del `new Date()` tramposo actual.

**🟡 Intermedio (9–17)**

9. Refactoriza `SupportView` completa al store: fuera su copia de tickets,
   su handler de socket y su `onTicketUpdated` (el workspace despacha
   `updateTicket` directamente). Mide en líneas eliminadas.
10. Caché con expiración: `fetchTickets` re-pide si `lastFetchedAt` tiene
    más de 60 segundos, aunque haya items. El TTL como constante del módulo.
11. `createTicket` como action (POST + `ADD_TICKET` + emit del socket dentro
    de la action — sí, la action puede usar `socketService`): refactoriza
    el create view y el wizard para despacharla. ¿Qué opinas de que la
    action emita sockets? Argumenta ambos lados en un comentario.
12. Mueve `search` y `statusFilter` del dashboard al módulo `ui` con
    computed get/set... y luego LEE tu auditoría, revierte, y déjalos en la
    URL (ej. 13 de la F4). El ejercicio es hacer el viaje completo y
    escribir por qué la vuelta.
13. `deleteTicket` como action (DELETE + `REMOVE_TICKET`), refactorizando el
    borrado de la Fase 5. El detalle post-borrado navega — ¿la action o la
    vista? (Relee el último error común antes de decidir.)
14. Instala `vuex-persistedstate` (o hazlo a mano con `store.subscribe` +
    localStorage) SOLO para el módulo `auth`: adiós al `getStoredSession`
    manual de la Fase 2. Compara ambos enfoques.
15. Plugin de logging: cada mutation a `console.log` con nombre, payload y
    duración desde la anterior. Actívalo solo en dev. (Acabas de escribir
    un tercio de las devtools.)
16. Getter `ticketsByAgent` que devuelva el mapa `{agente: [tickets]}` y
    refactoriza `activeByAgent` de métricas para derivar de él. ¿La función
    pura de la F7 sigue teniendo sentido o el getter la reemplaza? Decide.
17. Manejo de error con reintento en el store: si `fetchTickets` falla,
    guarda `error` Y `retryCount`; una action `retryFetch` con backoff
    (1s, 2s, 4s, tope 3). El botón "Reintentar" de las vistas despacha esta.

**🟠 Difícil (18–23)**

18. Optimistic update en `updateTicket`: commit del UPSERT ANTES del PATCH;
    si el PATCH falla, revierte al snapshot previo (guárdalo en la action).
    Pruébalo apagando json-server a mitad. Documenta el trade-off contra la
    versión pesimista actual.
19. Módulo `comments` con estado normalizado: `{ byTicketId: { 5: [...] } }`,
    action `fetchComments(ticketId)` con caché por ticket, y el workspace
    refactorizado. OJO: agregar una key nueva a `byTicketId` es LA trampa de
    la Fase 4 — te toca `Vue.set` en la mutation, ahora en su forma final.
20. Testea la migración con las devtools: graba la secuencia de mutations de
    "entrar al panel → tomar ticket → comentar → llegar un socket" y pégala
    (nombres + payloads resumidos) en un archivo `STORE-TRACE.md`. Ese trace
    es documentación viva del sistema.
21. Módulos dinámicos: registra un módulo `wizardDraft` con
    `store.registerModule` al ENTRAR al wizard y `unregisterModule` al salir
    (beforeRouteLeave). El borrador vive en el store... solo mientras el
    wizard vive. ¿Cambia esto tu respuesta al ejercicio 24 de la Fase 6?
22. Normalización total: refactoriza `items` (array) a
    `{ byId: {...}, allIds: [...] }` con getters que reconstruyen el array.
    Mide qué mejora (UPSERT O(1), ticketById O(1)) contra qué complica
    (mutations, Vue.set otra vez, legibilidad). Concluye si Mini Jira lo
    amerita — spoiler razonable: no, y saber decir "no amerita" es el punto.
23. `canTransition` de la Fase 9 (ej. 18) como getter parametrizado que
    combina `auth` y el ticket: `getters["tickets/canTransition"](ticket, to)`
    leyendo el user de `rootState`. Investiga los 4 argumentos de los getters
    de módulo (state, getters, rootState, rootGetters).

**🔴 Muy difícil (24–26)**

24. Sincronización entre PESTAÑAS sin sockets: con el evento `storage` de
    window, cuando otra pestaña persista una mutation de auth (ej. logout),
    esta pestaña replica el commit. Logout en una pestaña = logout en todas.
    Cuidado con el loop (la pestaña que origina no debe re-aplicarse).
25. Undo/redo de mutations de tickets: plugin que guarde snapshots
    (`store.subscribe` + deep clone del slice) en una pila con tope de 10, y
    actions `undo`/`redo` que restauren vía una mutation `RESTORE_TICKETS`.
    Botones en el panel. Discute por qué esto es fácil aquí y sería
    imposible con estado regado en 3 vistas (la fase entera, en un
    ejercicio).
26. El documento final: escribe `STATE-DECISIONS.md` — la auditoría de la
    sección de concepto, actualizada con TODO lo que decidiste en estos
    ejercicios (qué migraste, qué revertiste, qué rechazaste), una fila por
    estado, con la evidencia. En una base legacy real, este documento en la
    raíz del repo vale más que cualquier diagrama de arquitectura: es el
    mapa de dónde vive la verdad.

---

## 📚 Referencias

**Documentación oficial**

- Vuex 3 — guía completa: https://v3.vuex.vuejs.org/
- Vuex 3 — Mutations (y por qué síncronas):
  https://v3.vuex.vuejs.org/guide/mutations.html
- Vuex 3 — Actions (composición y Promises):
  https://v3.vuex.vuejs.org/guide/actions.html
- Vuex 3 — Modules y namespacing:
  https://v3.vuex.vuejs.org/guide/modules.html
- Vuex 3 — Plugins: https://v3.vuex.vuejs.org/guide/plugins.html
- Vuex 3 — Strict mode: https://v3.vuex.vuejs.org/guide/strict.html
- Vuex 3 — Forms (el problema del v-model, oficial):
  https://v3.vuex.vuejs.org/guide/forms.html
- Vue Devtools: https://github.com/vuejs/devtools

**Video / apoyo**

- Vue School — Vuex for Everyone: https://vueschool.io/courses/vuex-for-everyone
- Traversy Media — Vuex Crash Course (era correcta): buscar "Vuex crash
  course 2018/2019"

**Orden de lectura sugerido:** Mutations → Actions → Modules → volver al
código → Forms cuando llegues al get/set → Plugins antes del plugin de
socket.

---

## 🚀 Cierre

El estado del Mini Jira quedó donde la evidencia lo puso: sesión, tickets y
flashes en el store; filtros en la URL; borradores, selecciones y comentarios
en sus componentes. Y te llevas:

- la **anatomía completa** con el porqué de cada regla (mutations síncronas =
  fotos honestas para las devtools),
- las **cuatro preguntas** del criterio, calibradas contra nueve fases de
  casos reales,
- **mapHelpers**, el **get/set** para v-model, **plugins** para el mundo
  exterior y **strict mode** como alarma permanente,
- y la habilidad más subestimada del refactor: la tabla de "qué se fue, qué
  se quedó, y por qué".

La señal de que quedó bien:

> "puedo señalar cualquier dato de la app y decir dónde vive, quién lo
> escribe, quiénes lo leen — y defender por qué NO está en el store si no
> lo está."

**Siguiente parada:** ✅ Fase 11 — Testing mínimo: Jest + vue-test-utils
contra todo lo que construimos. Y la venganza de las decisiones buenas: las
funciones puras de `utils/`, las mutations aburridas y los componentes
tontos se testean solos. Casi.
