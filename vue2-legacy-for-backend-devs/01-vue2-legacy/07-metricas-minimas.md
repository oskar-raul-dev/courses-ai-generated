# 📊 Fase 7 — Métricas mínimas

## 🎯 Propósito

Una mesa de soporte sin números es una caja negra. Hoy el Mini Jira estrena
una vista de **métricas** con dos gráficos: tickets por estado (dona) y
tickets por agente (barras), construidos con **chart.js 2.x** — la librería
de gráficos omnipresente en el legacy 2018–2021.

Y como siempre, los gráficos son la excusa. Lo que realmente se aprende:

- integrar una **librería imperativa** (chart.js manipula un `<canvas>` a
  mano) dentro de un framework **declarativo** (Vue repinta solo) — el choque
  de paradigmas más común al mantener legacy: mapas, editores, calendarios y
  gráficos viven todos en esta frontera;
- el **ciclo de vida completo** de un recurso externo: crear en `mounted`,
  actualizar con `watch`, **destruir en `beforeDestroy`** (la parte que el
  legacy siempre olvida — y por eso hay memory leaks);
- por qué hay cosas que **NO deben ir en `data`** (la instancia del chart) y
  qué pasa si las pones;
- derivar agregaciones con computed + **lodash** (que por fin trabaja 💰).

> La regla de la fase: Vue es dueño de los DATOS del gráfico;
> chart.js es dueño del CANVAS. Cada uno en su lado de la frontera.

---

## ✅ Qué queda listo al terminar

- ruta `/metrics` con enlace en el sidebar;
- gráfico de dona: distribución de tickets por estado, con los mismos colores
  de los badges del dashboard (coherencia visual);
- gráfico de barras horizontales: tickets abiertos/en progreso por agente;
- tarjetas con indicadores numéricos (total, % resueltos, sin asignar);
- los gráficos se **actualizan** al recargar datos sin recrearse;
- cero memory leaks: instancias destruidas al salir de la vista;
- un componente de gráfico reutilizable con la frontera bien trazada.

## 🚫 Qué NO entra todavía

- BI real, drill-down, dashboards configurables;
- agregaciones server-side (json-server no agrega; contamos en el cliente);
- rangos de fecha con date-pickers (versión simple en ejercicio 🟡);
- actualización en tiempo real de los gráficos (Fase 8 lo hará posible);
- vue-chartjs u otros wrappers — primero a mano, el wrapper es ejercicio 🟠.

---

## 🧱 Instalación

```bash
npm install chart.js@2.9.4
```

> ⚠️ La versión importa MUCHO: chart.js **2.x** es la de la época y la que
> encontrarás en legacy. La 3.x (2021) rompió el API completo (registro de
> componentes, estructura de options, escalas). Si copias un ejemplo de
> internet y no funciona, lo primero a revisar es de qué versión es.

```js
// import de la época (v2 exporta la clase directamente)
import Chart from "chart.js";
```

---

## 🧠 Concepto: el choque imperativo vs declarativo

Todo lo que hicimos hasta ahora es declarativo: describes el estado, Vue
pinta. chart.js es lo contrario — imperativo: le das órdenes a un objeto.

```js
// chart.js: órdenes, paso a paso
var chart = new Chart(canvasElement, config); // créate
chart.data.datasets[0].data = [5, 3, 2];      // cámbiate
chart.update();                                // repíntate
chart.destroy();                               // muérete
```

Vue no sabe nada de ese objeto ni de lo que hace dentro del `<canvas>`. La
integración consiste en construir un **puente** con tres tablones, cada uno
sobre un hook o mecanismo de Vue:

| Momento | Lado Vue | Lado chart.js |
|---|---|---|
| Nacimiento | `mounted` (ya hay DOM → ya hay canvas) | `new Chart(...)` |
| Cambio de datos | `watch` sobre la prop de datos | `chart.data = ...; chart.update()` |
| Muerte | `beforeDestroy` | `chart.destroy()` |

Este patrón de tres tablones es **exactamente el mismo** para Leaflet (mapas),
FullCalendar, CKEditor, DataTables de jQuery… Apréndelo una vez aquí y
tendrás la llave de media internet legacy.

### 🚨 La instancia NO va en `data`

La tentación natural:

```js
data: function () {
  return { chart: null }; // ❌ NO
}
```

¿Por qué no? Porque Vue 2 **observa recursivamente** todo lo que pongas en
`data` (Fase 4: getters/setters en cada propiedad). La instancia de chart.js
es un objeto enorme con referencias circulares, al canvas, a datasets
internos… Observarlo cuesta rendimiento, puede romper la librería y dispara
reactividad fantasma.

La solución de la época — simple y correcta:

```js
mounted: function () {
  // propiedad de instancia creada FUERA de data → Vue no la observa
  this.chart = new Chart(this.$refs.canvas, this.buildConfig());
}
```

Asignar `this.loQueSea` fuera de `data` crea una propiedad **no reactiva**.
No aparecerá en templates ni computed (no la necesitas ahí), pero vive en la
instancia y se puede usar en methods y hooks. Es la herramienta oficiosa para
"cosas de librerías externas": sockets, mapas, editores, timers… tomen nota
para la Fase 8. 📝

---

## 🧩 Mini repaso: los `.vue` de esta fase (lo nuevo respecto a la Fase 6)

### `beforeDestroy` — el hook de limpieza

El ciclo de vida tiene salida, no solo entrada:

```
beforeDestroy   ← el componente AÚN funciona: this, $refs, todo disponible.
   ↓               Aquí se limpia: destroy() de librerías, clearInterval,
destroyed          removeEventListener, unsubscribe...
                ← ya está desmontado; $refs vacíos. Tarde para casi todo.
```

La regla de oro que el legacy viola sistemáticamente:

> **Todo lo que se crea en `mounted` y vive fuera de Vue,
> se destruye en `beforeDestroy`.**

¿Qué pasa si no? Dos síntomas clásicos: memory leaks acumulativos (cada
visita a la vista deja un chart zombie en memoria) y el error de chart.js
`"Canvas is already in use"` al volver a montar sobre un canvas reciclado.
El ejercicio 6 te hace provocar ambos a propósito.

Ojo al cruce con la Fase 6: si el componente está dentro de `keep-alive`,
`beforeDestroy` **no corre** al salir — corre `deactivated`. La limpieza
debe considerar dónde vivirá el componente.

### `$refs` sobre elementos DOM (la otra cara)

En la Fase 6 usamos `ref` sobre un **componente** (obtienes la instancia Vue,
con sus métodos). Sobre una **etiqueta HTML**, obtienes el nodo DOM crudo:

```vue
<canvas ref="canvas"></canvas>
```

```js
this.$refs.canvas // → HTMLCanvasElement, listo para dárselo a chart.js
```

Mismo mecanismo, dos resultados según dónde pongas el `ref`. Y la misma
regla temporal: existe desde `mounted`.

### `watch` con `deep` (y su costo)

El watch simple de la Fase 6 observaba un número. Para observar cambios
**dentro** de un objeto o arreglo:

```js
watch: {
  chartData: {
    deep: true,          // observa mutaciones internas, no solo reemplazo
    handler: function () {
      this.refreshChart();
    }
  }
}
```

`deep: true` recorre recursivamente — cómodo pero costoso en estructuras
grandes. El atajo barato de la época: si el padre **reemplaza** el objeto
(`this.stats = {...}` en vez de mutarlo), el watch normal basta y `deep`
sobra. Nuestro código hace justo eso: los computed devuelven objetos nuevos
en cada recálculo, así que el reemplazo está garantizado. Dejamos `deep` como
cinturón de seguridad documentado.

### `Object.freeze` — el otro escape de la reactividad

Truco de rendimiento muy de la época para listas grandes de solo lectura:

```js
this.tickets = Object.freeze(response); // Vue no observa objetos congelados
```

Con 10.000 tickets que solo se leen para agregar, congelar ahorra miles de
getters/setters. No lo necesitamos con nuestros datos de juguete, pero al
verlo en legacy sabrás que no es paranoia: es optimización deliberada.

---

## 💻 Código de la fase

### Estructura que se agrega

```
src/
  components/
    metrics/
      MetricCard.vue        ← indicador numérico
      StatusDoughnut.vue    ← dona por estado
      AgentBarChart.vue     ← barras por agente
  utils/
    ticketStats.js          ← agregaciones puras (¡testeables gratis en Fase 11!)
  views/
    MetricsView.vue
```

### `utils/ticketStats.js` — agregar es una función pura

```js
import _ from "lodash";

// { open: 5, in_progress: 3, resolved: 8, closed: 2 }
export function countByStatus(tickets) {
  return _.countBy(tickets, "status");
}

// [{ agent: "soporte1", count: 4 }, ...] solo tickets activos, ordenado desc
export function activeByAgent(tickets) {
  var active = tickets.filter(function (t) {
    return t.status === "open" || t.status === "in_progress";
  });

  var grouped = _.countBy(active, function (t) {
    return t.assignee || "(sin asignar)";
  });

  return _.orderBy(
    Object.keys(grouped).map(function (agent) {
      return { agent: agent, count: grouped[agent] };
    }),
    ["count"], ["desc"]
  );
}

export function resolvedPercent(tickets) {
  if (tickets.length === 0) return 0;
  var done = tickets.filter(function (t) {
    return t.status === "resolved" || t.status === "closed";
  }).length;
  return Math.round((done / tickets.length) * 100);
}
```

¿Por qué en `utils/` y no como computed de la vista? Porque son **funciones
puras**: datos entran, datos salen, cero `this`. Eso las hace reutilizables
(el panel de la Fase 9 las querrá) y testeables sin montar componentes
(Fase 11 te lo agradecerá). Los computed de la vista serán envolturas de una
línea. Y sí: `_.countBy` y `_.orderBy` — lodash pagando su instalación de la
Fase 0. 💰

### Colores compartidos con los badges

Para que la dona hable el mismo idioma visual que el dashboard:

```js
// utils/statusColors.js
export var STATUS_COLORS = {
  open:        { label: "Abiertos",     color: "#dc3545" }, // rojo   (badge-danger)
  in_progress: { label: "En progreso",  color: "#ffc107" }, // ámbar  (badge-warning)
  resolved:    { label: "Resueltos",    color: "#28a745" }, // verde  (badge-success)
  closed:      { label: "Cerrados",     color: "#6c757d" }  // gris   (badge-secondary)
};
```

(Refactor sugerido para inquietos: hacer que `TicketStatusBadge` de la Fase 4
consuma este mismo mapa — ejercicio 9.)

### `components/metrics/StatusDoughnut.vue` — el componente frontera

```vue
<template>
  <div class="card h-100">
    <div class="card-body">
      <h6 class="card-title text-muted">Tickets por estado</h6>
      <canvas ref="canvas"></canvas>
    </div>
  </div>
</template>

<script>
import Chart from "chart.js";
import { STATUS_COLORS } from "../../utils/statusColors";

export default {
  name: "StatusDoughnut",
  props: {
    // { open: 5, in_progress: 3, ... }
    counts: { type: Object, required: true }
  },
  // 👀 nota lo que NO hay: data(). Este componente no tiene estado reactivo.
  mounted: function () {
    // this.chart fuera de data: propiedad NO reactiva a propósito
    this.chart = new Chart(this.$refs.canvas, {
      type: "doughnut",
      data: this.buildData(),
      options: {
        responsive: true,
        legend: { position: "bottom" },
        // sintaxis v2: en v3 esto cambió por completo
        cutoutPercentage: 65
      }
    });
  },
  beforeDestroy: function () {
    // el tablón que el legacy olvida
    if (this.chart) {
      this.chart.destroy();
      this.chart = null;
    }
  },
  watch: {
    counts: {
      deep: true,
      handler: function () {
        if (!this.chart) return;
        this.chart.data = this.buildData();
        this.chart.update(); // actualizar, NO recrear
      }
    }
  },
  methods: {
    buildData: function () {
      var self = this;
      var keys = Object.keys(STATUS_COLORS);
      return {
        labels: keys.map(function (k) { return STATUS_COLORS[k].label; }),
        datasets: [{
          data: keys.map(function (k) { return self.counts[k] || 0; }),
          backgroundColor: keys.map(function (k) { return STATUS_COLORS[k].color; })
        }]
      };
    }
  }
};
</script>
```

**🔎 Qué hace, pieza por pieza:**

| Pieza | Su trabajo |
|---|---|
| prop `counts` | el contrato de entrada: un objeto ya agregado (`{open: 5, ...}`) — el gráfico NO agrega, solo pinta |
| `mounted` | tablón 1: toma el `<canvas>` vía `$refs` y crea la instancia, guardándola fuera de `data` |
| `watch counts` | tablón 2: cuando el padre entrega datos nuevos, reconstruye `chart.data` y pide `update()` |
| `beforeDestroy` | tablón 3: `destroy()` + `null` — chart.js suelta canvas y listeners |
| `buildData()` | el traductor: convierte el formato de la app (nuestro objeto) al formato de chart.js (labels + datasets) |

Los tres tablones del puente, señalizados: `mounted` crea, `watch` actualiza
con `update()`, `beforeDestroy` destruye. Y el `|| 0` en `buildData` cubre
estados sin tickets — chart.js con `undefined` dibuja cosas raras.

**✅ Buenas prácticas aplicadas:**
- **El componente no tiene `data()`** — y eso es una declaración de
  intenciones: todo su estado visible viene de la prop, y su único "estado"
  interno (la instancia) es deliberadamente no reactivo. Un componente
  frontera mientras más tonto, mejor.
- `buildData()` es el **único traductor** entre los dos mundos: si mañana
  chart.js cambia su formato (cof, v3, cof), se toca una función. Tenerlo
  como method con nombre — en vez de armar el objeto inline en `mounted` Y en
  el watch — evita las dos copias que luego divergen.
- Los guards `if (!this.chart) return` en el watch y `if (this.chart)` en
  destroy cuestan una línea y blindan contra los instantes raros: un watch
  que dispara antes del mount (posible con `immediate` futuro) o un destroy
  doble. Programación defensiva barata en las fronteras.
- Iterar `Object.keys(STATUS_COLORS)` — y no las keys de `counts` — garantiza
  **orden estable y colores correctos** aunque el objeto de datos venga con
  las llaves en otro orden o le falten estados. El mapa de configuración
  manda; los datos se acomodan.

### `components/metrics/AgentBarChart.vue`

```vue
<template>
  <div class="card h-100">
    <div class="card-body">
      <h6 class="card-title text-muted">Carga activa por agente</h6>
      <canvas ref="canvas"></canvas>
    </div>
  </div>
</template>

<script>
import Chart from "chart.js";

export default {
  name: "AgentBarChart",
  props: {
    // [{ agent, count }] ya ordenado
    rows: { type: Array, required: true }
  },
  mounted: function () {
    this.chart = new Chart(this.$refs.canvas, {
      type: "horizontalBar", // ⚰️ tipo propio de v2; en v3 es bar + indexAxis
      data: this.buildData(),
      options: {
        responsive: true,
        legend: { display: false },
        scales: {
          xAxes: [{ ticks: { beginAtZero: true, stepSize: 1 } }] // sintaxis v2
        }
      }
    });
  },
  beforeDestroy: function () {
    if (this.chart) {
      this.chart.destroy();
      this.chart = null;
    }
  },
  watch: {
    rows: function () {
      if (!this.chart) return;
      this.chart.data = this.buildData();
      this.chart.update();
    }
  },
  methods: {
    buildData: function () {
      return {
        labels: this.rows.map(function (r) { return r.agent; }),
        datasets: [{
          data: this.rows.map(function (r) { return r.count; }),
          backgroundColor: "#007bff"
        }]
      };
    }
  }
};
</script>
```

**🔎 Qué hace:** el mismo puente de tres tablones, ahora con barras
horizontales — mejor que verticales cuando las etiquetas son nombres (se leen
sin rotar el cuello). Recibe `rows` **ya ordenado** por el util: el gráfico
no reordena, confía en su contrato de entrada.

**✅ Buenas prácticas aplicadas:**
- Aquí el watch va **sin** `deep`: `rows` llega de un computed que devuelve
  un arreglo nuevo cada vez — reemplazo garantizado, como explicamos arriba.
  Usar `deep` "por si acaso" en todos lados es pagar recorridos recursivos
  que no necesitas: decide por cómo fluyen tus datos, no por miedo.
- `stepSize: 1` en el eje: son tickets, no promedios — un eje que marca
  "2.5 tickets" delata un gráfico configurado sin mirar los datos. Ajustar
  las escalas al dominio es el 50% de que un gráfico se vea profesional.
- `legend: { display: false }`: con un solo dataset, la leyenda solo repite
  el título. Menos tinta, mismo mensaje (regla general de visualización que
  chart.js no aplica por defecto).

### `components/metrics/MetricCard.vue`

```vue
<template>
  <div class="card text-center h-100">
    <div class="card-body py-3">
      <h2 class="mb-0" :class="valueClass">{{ value }}</h2>
      <small class="text-muted">{{ label }}</small>
    </div>
  </div>
</template>

<script>
export default {
  name: "MetricCard",
  props: {
    label: { type: String, required: true },
    value: { type: [Number, String], required: true }, // prop con DOS tipos válidos
    valueClass: { type: String, default: "" }
  }
};
</script>
```

**🔎 Qué hace:** el componente más pequeño del curso — y aun así con dos
decisiones que enseñan: la prop `value` acepta **dos tipos**
(`type: [Number, String]`) porque a veces llega un conteo y a veces "85%",
y `valueClass` deja que el **padre** decida el color sin que la tarjeta
conozca la semántica ("abiertos = rojo" es regla del dashboard, no de la
tarjeta).

**✅ Buena práctica:** cuando un componente presentacional necesita variar
estilo según significado, recibir la clase por prop (o un `variant` tipo
`danger/success`) mantiene la semántica en el dueño de los datos. La
alternativa — pasar `label="Abiertos"` y que la tarjeta haga
`if (label === "Abiertos")` — acopla presentación a textos y muere en la
primera traducción.

### `views/MetricsView.vue` — la vista orquestadora

```vue
<template>
  <section>
    <page-title title="Métricas" subtitle="Estado de la mesa de soporte" />

    <div v-if="loading" class="text-center my-5">
      <div class="spinner-border text-primary" role="status"></div>
    </div>

    <div v-else-if="error" class="alert alert-danger">
      {{ error }}
      <button class="btn btn-sm btn-outline-danger ml-2" @click="loadTickets">
        Reintentar
      </button>
    </div>

    <template v-else>
      <div class="row mb-4">
        <div class="col-6 col-md-3 mb-2">
          <metric-card label="Total tickets" :value="tickets.length" />
        </div>
        <div class="col-6 col-md-3 mb-2">
          <metric-card label="Abiertos" :value="statusCounts.open || 0" value-class="text-danger" />
        </div>
        <div class="col-6 col-md-3 mb-2">
          <metric-card label="% resueltos" :value="donePercent + '%'" value-class="text-success" />
        </div>
        <div class="col-6 col-md-3 mb-2">
          <metric-card label="Sin asignar" :value="unassignedCount" value-class="text-warning" />
        </div>
      </div>

      <div class="row">
        <div class="col-md-5 mb-3">
          <status-doughnut :counts="statusCounts" />
        </div>
        <div class="col-md-7 mb-3">
          <agent-bar-chart :rows="agentRows" />
        </div>
      </div>

      <p class="text-muted small text-right">
        Datos al {{ new Date() | formatDate }} ·
        <a href="#" @click.prevent="loadTickets">actualizar</a>
      </p>
    </template>
  </section>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";
import MetricCard from "../components/metrics/MetricCard.vue";
import StatusDoughnut from "../components/metrics/StatusDoughnut.vue";
import AgentBarChart from "../components/metrics/AgentBarChart.vue";
import ticketService from "../services/ticketService";
import { countByStatus, activeByAgent, resolvedPercent } from "../utils/ticketStats";

export default {
  name: "MetricsView",
  components: { PageTitle, MetricCard, StatusDoughnut, AgentBarChart },
  data: function () {
    return {
      tickets: [],
      loading: true, // arranca en true: adiós al parpadeo de la Fase 4
      error: ""
    };
  },
  computed: {
    // envolturas de una línea sobre las funciones puras
    statusCounts: function () { return countByStatus(this.tickets); },
    agentRows: function () { return activeByAgent(this.tickets); },
    donePercent: function () { return resolvedPercent(this.tickets); },
    unassignedCount: function () {
      return this.tickets.filter(function (t) {
        return !t.assignee && t.status !== "closed";
      }).length;
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
        .getTickets()
        .then(function (tickets) {
          self.tickets = tickets;
        })
        .catch(function () {
          self.error = "No se pudieron cargar las métricas. ¿Está corriendo la Mock API?";
        })
        .finally(function () {
          self.loading = false;
        });
    }
  }
};
</script>
```

**🔎 Qué hace, pieza por pieza:**

| Pieza | Su trabajo |
|---|---|
| `tickets` (data) | el único estado crudo: la respuesta de la API tal cual |
| computed de una línea | envolturas sobre las funciones puras de `utils/` — la vista no sabe agregar, sabe a quién preguntarle |
| `loading: true` inicial | los gráficos no nacen hasta que hay datos (adiós parpadeo, herencia de la Fase 4) |
| el trío loading/error/datos | el patrón de la Fase 3, intacto: nada nuevo que aprender aquí, y eso es bueno |

**✅ Buenas prácticas aplicadas:**
- **Computed cascarón + función pura** es la división del trabajo ideal: el
  computed aporta la reactividad y el caché; la función pura aporta la lógica
  testeable y reutilizable. Si un computed tuyo supera ~5 líneas de lógica de
  negocio, probablemente esconde una función pura pidiendo salir a `utils/`.
- `unassignedCount` sí quedó como computed completo — porque (todavía) solo
  lo usa esta vista. Coherente con la regla de la duplicación de la Fase 6:
  extraer a la segunda necesidad, no a la primera.
- Los gráficos reciben datos **ya agregados** (`:counts`, `:rows`), nunca
  `tickets` crudo: si cada gráfico agregara por su cuenta, el mismo filtro de
  rango (ejercicio 11) habría que implementarlo N veces. Agregación arriba,
  presentación abajo — la versión de datos del "props abajo, eventos arriba".
- El link "actualizar" reutiliza `loadTickets` tal cual: recargar es volver a
  ejecutar el flujo normal, no un flujo especial. Menos caminos = menos bugs.

### Ruta y sidebar

```js
// router/index.js
import MetricsView from "../views/MetricsView.vue";
// ...
{ path: "/metrics", name: "metrics", component: MetricsView, meta: { requiresAuth: true } }
```

```vue
<!-- AppSidebar.vue -->
<li class="nav-item">
  <router-link class="nav-link" to="/metrics">📊 Métricas</router-link>
</li>
```

---

## 🔄 Los flujos de la fase, paso a paso

### 🌱 Nacimiento de un gráfico

```
1. usuario navega a /metrics → guard ✓ → monta MetricsView
   └─ loading arranca en true → SOLO se ve el spinner
      → los componentes de gráfico NO EXISTEN todavía (rama v-else)

2. mounted de la vista → GET /tickets → .then → tickets = respuesta
   └─ cadena reactiva: statusCounts, agentRows, donePercent se calculan
   └─ .finally → loading = false → la rama de datos se monta AHORA

3. StatusDoughnut nace:
   a. Vue renderiza su template → el <canvas> entra al DOM
   b. mounted del componente → this.$refs.canvas YA existe
   c. new Chart(canvas, config) → chart.js toma posesión del canvas
      └─ this.chart guardado FUERA de data → Vue lo ignora (a propósito)
```

Nota la carambola del orden: como `loading` arranca en `true`, los gráficos
se montan **cuando ya hay datos**. Si arrancara en `false`, nacerían con
`counts` vacío y luego el watch los actualizaría — funciona igual, pero con
un frame de dona vacía. Detalle de pulido gratis heredado de la Fase 4.

### 🔁 Actualización (clic en "actualizar")

```
1. loadTickets() de nuevo → GET → .then → this.tickets = NUEVO arreglo
2. cadena reactiva: los computed devuelven objetos/arreglos NUEVOS
3. las props de los gráficos cambian (reemplazo, no mutación)
   └─ el watch de cada gráfico dispara
      └─ chart.data = buildData(); chart.update()
         └─ chart.js ANIMA la transición entre valores viejos y nuevos ✨
```

El paso 3 es la esencia del puente: la frontera se cruza **una sola vez por
actualización**, en el watch. Vue nunca toca el canvas; chart.js nunca lee
`this.tickets`. Si en un legacy ves `document.getElementById` dentro de un
computed o un `new Chart` dentro de un watch, la frontera está rota — y ya
sabes cómo se repara.

⚠️ Anti-patrón frecuente en este paso: destruir y recrear el chart en cada
cambio (`destroy()` + `new Chart(...)` en el watch). Funciona, pero pierde
las animaciones, parpadea y desperdicia trabajo. `update()` existe para esto.

### ⚰️ Muerte (navegar a otra vista)

```
1. clic en "Tickets" del sidebar → el router desmonta MetricsView
2. Vue destruye el árbol de ARRIBA hacia ABAJO en cascada:
   └─ beforeDestroy de cada gráfico:
      └─ this.chart.destroy() → chart.js suelta el canvas, listeners y RAF
      └─ this.chart = null → sin referencias colgantes
3. destroyed → el nodo sale del DOM → el GC puede recoger todo
```

Sin el paso 2, la instancia queda viva referenciando el canvas muerto:
memoria que no se libera, y si vuelves a `/metrics`, el famoso
`"Canvas is already in use"`. El ejercicio 6 te lo hace vivir.

---

## ⚠️ Errores comunes

- guardar la instancia del chart en `data` → reactividad recursiva sobre un
  objeto gigante: lentitud y bugs raros (el error de la fase);
- olvidar `chart.destroy()` en `beforeDestroy` → leaks y "Canvas is already
  in use" al volver;
- recrear el chart en cada cambio en vez de `update()`;
- crear el chart en `created` → `this.$refs.canvas` es `undefined` (no hay
  DOM aún);
- mezclar sintaxis de chart.js v2 y v3 copiando de Stack Overflow sin mirar
  la versión (escalas `xAxes` vs `x`, `horizontalBar` vs `indexAxis`...);
- agregar datos en el componente de gráfico en vez de recibirlos listos →
  el componente frontera debe ser tonto: recibe, pinta;
- canvas dentro de un contenedor sin dimensiones → gráfico invisible o de
  30.000px de alto con `responsive: true` (clásico absoluto);
- poner las agregaciones como métodos privados de la vista → duplicación
  asegurada cuando la Fase 9 las necesite.

---

## 🧪 Ejercicios (26)

**🟢 Fácil (1–8)**

1. Cambia la posición de la leyenda de la dona a la derecha y evalúa cuál se
   ve mejor con pocos datos.
2. Agrega una `MetricCard` de "Prioridad alta activa" (open/in_progress con
   priority high) en rojo.
3. Ajusta `cutoutPercentage` a 0 y conviértela en pie. Vuelve a dona y
   documenta la diferencia en un comentario.
4. Agrega `title` de chart.js dentro del gráfico y elimina el `<h6>` del
   card. ¿Cuál enfoque prefieres para un sistema con muchos gráficos?
5. Cambia el color de las barras según el valor: rojo si count ≥ 5, azul si
   no (backgroundColor acepta un arreglo).
6. Provoca el leak: comenta el `beforeDestroy` de la dona, entra y sal de
   `/metrics` 5 veces, y captura el error o el comportamiento raro.
   Descoméntalo y anota el síntoma observado.
7. Crea 10 tickets más en `db.json` variando agentes y estados para que los
   gráficos tengan algo que contar.
8. Agrega tooltips con formato: "5 tickets (33%)" usando
   `options.tooltips.callbacks.label` (sintaxis v2).

**🟡 Intermedio (9–17)**

9. Refactor de coherencia: haz que `TicketStatusBadge` (Fase 4) consuma
   `STATUS_COLORS` de `utils/` — un solo lugar para colores y labels de
   estado en toda la app.
10. Agrega un tercer gráfico: línea de "tickets creados por día" (últimos 14
    días). La agregación va en `ticketStats.js` (`createdPerDay(tickets, days)`)
    agrupando por fecha con lodash. Días sin tickets = 0, no hueco.
11. Filtro de rango simple: botones "7 días / 30 días / Todo" que filtren
    `tickets` por `createdAt` ANTES de agregar (computed intermedio
    `ticketsInRange`). Los tres gráficos deben reaccionar sin tocarlos.
12. Extrae el trío mounted/watch/beforeDestroy a un mixin `chartLifecycle`
    que espere del componente un método `buildConfig()`. Refactoriza ambos
    gráficos. Compara con el mixin de la Fase 3 (ej. 17): ¿ya ves el patrón
    de los mixins... y sus problemas de "¿de dónde salió este this.chart?"
13. `MetricCard` con tendencia: prop opcional `delta` que muestre "▲ 3" verde
    o "▼ 2" rojo vs los datos de hace 7 días (necesitas el ejercicio 10 o 11).
14. Estado vacío con datos: si `tickets.length === 0`, en vez de gráficos
    vacíos muestra un mensaje amable con link a crear el primer ticket.
15. Haz el gráfico de agentes clicable: `options.onClick` +
    `chart.getElementAtEvent(event)` para detectar la barra, y emite `select`
    con el agente. La vista navega a `/tickets` con ese filtro en la URL
    (¡reutiliza el ejercicio 13 de la Fase 4!).
16. Agrega un botón "Descargar PNG" por gráfico usando
    `canvas.toDataURL("image/png")` + un `<a download>`. Frontera cruzada
    legítimamente: ¿por qué este acceso al canvas sí está bien?
17. Auto-refresh de métricas cada 60s con `setInterval` — creado en `mounted`,
    limpiado en `beforeDestroy` (¡misma regla que el chart!), y guardado como
    propiedad no reactiva `this.timer`. Todo lo de la fase, aplicado dos veces.

**🟠 Difícil (18–23)**

18. Construye `BaseChart.vue` genérico: props `type`, `chartData`, `options`;
    dentro, el puente completo. Reescribe la dona y las barras como
    componentes de configuración que usan `BaseChart`. Acabas de escribir tu
    propio mini vue-chartjs.
19. Ahora instala `vue-chartjs@3` (el wrapper de la época) y reescribe UNO de
    los gráficos con él. Compara con tu `BaseChart` en 5 líneas: ¿qué
    resuelve, qué esconde, qué preferirías mantener en un legacy ajeno?
20. Doble eje en el gráfico de línea: tickets creados (barras) + acumulado
    del período (línea) en el mismo chart con dos `yAxes` (sintaxis v2 de
    `scales`). Prepárate para pelear con la documentación: es parte del
    ejercicio.
21. Rendimiento: genera 5.000 tickets falsos con un script Node que escriba
    `db.json` (lodash + faker casero). Mide con `console.time` cuánto tardan
    las agregaciones y el render. Aplica `Object.freeze` a `tickets` y mide
    de nuevo. Documenta los números.
22. Concurrencia de requests: si el usuario hace clic en "actualizar" 3 veces
    rápido, hay 3 GET en vuelo y puede ganar el viejo. Implementa la
    protección: ignora respuestas de requests obsoletos (contador de request
    id) o deshabilita el link mientras carga. Explica en un comentario cuál
    elegiste y por qué.
23. Gráfico de "aging": barras apiladas por agente donde cada segmento es un
    rango de antigüedad del ticket (0-2 días, 3-7, +7). Agregación en
    `ticketStats.js`, stacked bars en chart.js v2 (`stacked: true` en ambas
    escalas). El gráfico más útil de una mesa de soporte real.

**🔴 Muy difícil (24–26)**

24. Plugin de chart.js casero: escribe un plugin v2 que dibuje el número
    total en el centro de la dona (hook `afterDraw`, dibujando con el
    contexto 2D del canvas a mano). Regístralo solo en la dona. Bienvenido al
    lado imperativo profundo.
25. Server-side de mentira: agrega a json-server un middleware que responda
    `GET /stats` con las agregaciones ya calculadas (reutiliza
    `ticketStats.js` desde Node — ¡son funciones puras, corren en ambos
    lados!). Crea `statsService.js`, y haz que la vista use `/stats` con
    fallback al cálculo local si el endpoint falla. Discute: ¿cuándo agregar
    en el servidor deja de ser opcional?
26. Snapshot histórico: cada vez que se visita `/metrics`, guarda (POST) un
    documento `{date, counts}` en una colección `snapshots` (máximo uno por
    día). Nuevo gráfico de línea "evolución de abiertos" alimentado por los
    snapshots. Acabas de descubrir por qué las métricas serias necesitan
    series temporales y no solo el estado actual — escríbelo en 3 líneas.

---

## 📚 Referencias

**Documentación oficial**

- chart.js 2.9 (¡la versión correcta!): https://www.chartjs.org/docs/2.9.4/
- chart.js 2.9 — Doughnut & Pie: https://www.chartjs.org/docs/2.9.4/charts/doughnut.html
- chart.js 2.9 — actualizar gráficos: https://www.chartjs.org/docs/2.9.4/developers/updates.html
- chart.js 2.9 — plugins (ej. 24): https://www.chartjs.org/docs/2.9.4/developers/plugins.html
- Vue 2 — Reactivity in Depth (por qué la instancia no va en data):
  https://v2.vuejs.org/v2/guide/reactivity.html
- Vue 2 — hooks de destrucción: https://v2.vuejs.org/v2/api/#beforeDestroy
- Lodash — countBy: https://lodash.com/docs/4.17.15#countBy
- Lodash — orderBy: https://lodash.com/docs/4.17.15#orderBy
- vue-chartjs 3.x (la de la época, para el ej. 19): https://vue-chartjs.org/

**Video / apoyo**

- Traversy Media — Chart.js Crash Course (verifica que sea de la era v2):
  buscar en YouTube "Chart.js crash course 2019"
- Vue Mastery / Net Ninja — episodios de lifecycle hooks (playlists ya citadas)

**Orden de lectura sugerido:** chart.js Getting Started (v2.9) → Updates →
Reactivity in Depth de Vue → volver al código. Plugins solo para el
ejercicio 24.

---

## 🚀 Cierre

El Mini Jira ya cuenta su propia historia en números, y tú te llevas el
patrón que abre media internet legacy:

- **el puente de tres tablones** (mounted crea, watch actualiza, beforeDestroy
  destruye) para cualquier librería imperativa,
- **propiedades no reactivas** fuera de `data` para instancias externas,
- **funciones puras en `utils/`** para lógica que trasciende una vista,
- y la disciplina de limpieza que separa una SPA sana de una que se come la
  RAM del navegador a las 3 horas de uso.

La señal de que quedó bien:

> "si mañana me piden integrar un mapa de Leaflet o un calendario,
> ya sé exactamente qué tres hooks tocar y qué NO poner en data".

**Siguiente parada:** 💬 Fase 8 — WebSockets mínimos: un mini servidor
socket.io de 30 líneas y el dashboard se entera de los tickets nuevos
**sin que nadie recargue nada**. (Y sí: el socket también irá fuera de
`data`, y también se limpiará en `beforeDestroy` — ya sabes por qué. 😉)
