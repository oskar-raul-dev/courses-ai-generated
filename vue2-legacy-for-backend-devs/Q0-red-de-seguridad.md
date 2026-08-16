# 🛡️ Q0 — La red de seguridad

> **Prerequisito duro: F11 (Testing).** Si no tienes Jest corriendo, esta fase no
> existe. Vuelve.

> 🧩 **Núcleo común X0.** El ~85% de este capítulo es agnóstico al framework
> destino: sirve igual para Quasar, Vuetify o Nuxt. Lo específico de Quasar vive
> encapsulado en las secciones marcadas **🅠**. Si haces la ruta VU o NX, léelas
> igual: cambia el nombre del componente, no el problema.

---

## 🎯 Propósito

Nadie migra lo que no puede verificar.

Estás a punto de borrar código que funciona. Vas a cambiar el modal de Bootstrap
(el `<div class="modal">` con jQuery de F5 — el curso **no usa bootstrap-vue**,
no hay `<b-modal>`) por otra cosa, la tabla de F4 por otra tabla, y en el camino
se van a caer ~150 líneas que
alguien (tú) escribió con cariño. La pregunta que te va a perseguir durante toda
la ruta es una sola:

> **"¿esto sigue haciendo lo mismo que hacía ayer?"**

Y hay exactamente dos formas de responderla. Una es abrir el navegador y hacer
clic durante veinte minutos, cruzando los dedos por no haberte olvidado del caso
raro. La otra es `npm run test:unit` y mirar el color.

Esta fase construye la segunda. **Antes de tocar Quasar.** Sin código del
framework, sin instalar nada, sin ni siquiera haber leído qué es un boot file.
Primero la red, después el salto.

Y hay una segunda lección, más incómoda, que llega gratis: **la migración va a
auditar tus tests de F11**. Ábrelos: son seis, están bien escritos, y **ninguno se
va a poner rojo cuando reescribas el dashboard entero.** No porque sean a prueba de
balas — porque `TicketsView`, `TicketsTable` y `TicketForm` no tienen un solo test.
En F11 eso eran los ejercicios 🟠, los opcionales. Los que la regla del curso te
dejaba saltarte.

Traducción: **la única parte del Mini Jira que no tiene red es exactamente la que
vas a borrar.** Esta fase existe para eso.

> La regla de la fase: un test de regresión describe lo que el sistema **hace**,
> no cómo está **hecho**. Si tu test conoce la clase CSS, no está protegiendo el
> comportamiento: está protegiendo el HTML — y el HTML es justo lo que vas a
> tirar.

---

## ✅ Qué queda listo al terminar

- una suite `tests/unit/regression/` separada de la de F11, con nombre propio y
  contrato explícito: **estos tests no se tocan durante la migración**;
- tests de regresión sobre el **dashboard** (F4 + refactor F10): carga, filtro,
  búsqueda combinada, estado vacío, error, y el evento de selección;
- tests de regresión sobre el **CRUD** (F5): el contrato de `TicketForm` (qué
  emite, qué no emite, con qué payload) y el de las vistas (qué petición sale);
- el **contrato con el store** verificado: la vista despacha `tickets/fetchTickets`,
  punto — no importa quién pinte la tabla;
- el **contrato con la API** verificado: `ticketService` con `apiClient` mockeado
  — la petición que sale hoy es la que debe salir mañana;
- `data-testid` sembrado en los puntos de anclaje del dashboard y del formulario;
- un `MIGRATION-CHECKLIST.md` accionable en la raíz del repo;
- y el criterio para responder, sin ideología, a la pregunta que abre la fase.

## 🚫 Qué NO entra todavía

- **Quasar.** Cero. No se instala, no se importa, no se menciona en el código.
  Esta fase corre contra el Mini Jira a pelo tal como está hoy;
- e2e / Cypress: sería la red ideal para esto (una migración de UI es el caso de
  uso canónico del e2e) pero está fuera del stack del curso. Se discute en el
  ejercicio 25 y se deja como deuda honesta;
- visual regression testing (Percy, snapshots de imagen): la maquetación **va a
  cambiar a propósito**. Un test que grite "el pixel se movió" es ruido puro aquí;
- refactorizar el código de producción "para que sea más testeable": si algo no se
  puede testear sin tocarlo, **anótalo, no lo toques**. Es información, no tarea.
  (La tarea viene después, con la red puesta.)
- tests nuevos de *funcionalidad*: no es momento de arreglar los agujeros de
  cobertura de F11. Regresión es congelar lo que hay.

---

## 🧠 Concepto 1: test normal vs test de REGRESIÓN

Se escriben con las mismas herramientas y se ven casi iguales. Pero responden
preguntas distintas, y confundirlas es lo que hace que una migración se vaya de
las manos.

| | 🧪 Test normal (F11) | 🛡️ Test de **regresión** (Q0) |
|---|---|---|
| **La pregunta** | ¿esto **funciona**? | ¿esto **sigue haciendo lo mismo**? |
| **Contra qué compara** | contra la especificación / lo que quieres | contra **el comportamiento actual**, aunque sea feo |
| **Cuándo se escribe** | mientras (o antes de) desarrollar la feature | **antes de tocar** código que ya funciona |
| **Si falla** | el código está mal → arregla el código | **alguien decide**: ¿rompiste algo o el test estaba acoplado? |
| **Qué documenta** | la intención | **el statu quo** — incluidas las rarezas |
| **Vida útil** | permanente | permanente, pero su **momento de gloria** es la migración |
| **Qué hago si el comportamiento actual es raro** | lo arreglo | **lo congelo tal cual, y lo anoto.** Arreglar y migrar a la vez = no saber cuál de los dos te rompió |
| **Nivel de acoplamiento tolerable** | bajo | **cero.** Es la diferencia crítica |
| **Origen típico en legacy** | feature nueva | **un bug de producción** (F11) o **una migración** (aquí) |
| **Quién lo escribe** | quien hace la feature | quien va a **borrar** el código |
| **Qué lo invalida** | cambia el requisito | cambia el requisito. **Cambiar la implementación, NUNCA** |

La fila que hay que tatuarse es la penúltima. Un test normal puede permitirse
mirar un poco por dentro; a nadie le explota nada si `TicketStatusBadge.spec.js`
comprueba la clase `badge-danger`, porque ese componente no se va a mover.

Un test de regresión de migración **no puede permitirse nada de eso**, porque la
implementación entera es lo que está en juego. Es la definición operativa:

> **Un test de regresión válido para migrar es aquel que puede pasar en verde
> con dos implementaciones completamente distintas por debajo.**

Si tu test no cumple esa frase, no es red de seguridad: es cemento.

### El corolario incómodo

De F11 heredas una suite. **Parte de ella no sirve para esto.** No porque esté
mal escrita — sirve perfectamente para su propósito, que era "¿funciona?". Pero
para "¿sigue haciendo lo mismo *con otro framework debajo*?" hay tests tuyos que
van a mentir.

Y "mentir" aquí tiene dos direcciones, ambas caras:

- **falso rojo** 🔴: el test falla, tú no rompiste nada. Solo cambió el DOM. Te
  hace perder una tarde y, peor, te entrena a ignorar el rojo. *"Ah, ese siempre
  falla."* Ahí murió tu suite.
- **falso verde** 🟢: el test pasa, tú rompiste algo. Pasa cuando el test verifica
  la capa equivocada — por ejemplo, comprueba que el servicio se llamó, pero no
  que el resultado llegó a la pantalla. Este es el que te manda a producción.

El objetivo de esta fase es una suite donde **rojo signifique rojo**.

---

## 🧠 Concepto 2: comportamiento observable, no estructura

"Comportamiento observable" suena a filosofía. Es operativo, y se decide con una
pregunta:

> **¿esta aserción le importa a alguien que no seas tú?**

El usuario del Mini Jira no sabe que existe una clase `.table-hover`. Le importa
que **al escribir "impresora" queden menos filas**. Al backend no le importa que
uses `axios.get`; le importa que **llegue un GET a `/tickets` con `_sort`**.

Entonces, la escala — de lo que **siempre** se puede testear a lo que **nunca**:

```
🟢 SIEMPRE testeable (sobrevive a cualquier framework)
   ├─ ¿qué petición HTTP sale? (método, url, params, body)
   ├─ ¿qué action se despacha, con qué payload?
   ├─ ¿qué evento emite el componente, con qué payload?
   ├─ ¿cuántos elementos hay en la lista tras filtrar? (el CONTEO, no el <tr>)
   └─ ¿qué texto lee el usuario en la pantalla?

🟡 TESTEABLE CON ANCLA (necesita data-testid)
   ├─ "el botón de guardar está deshabilitado mientras guarda"
   ├─ "aparece el mensaje de error"
   └─ "el spinner está visible durante la carga"
      → sin data-testid, esto se escribe con selectores frágiles. CON él, aguanta.

🔴 NO TESTEAR (es exactamente lo que vas a cambiar)
   ├─ clases de Bootstrap (.table, .badge-danger, .form-control, .btn-primary)
   ├─ etiquetas HTML concretas (<tr>, <select>, .modal de Bootstrap)
   ├─ estructura del DOM (".row > div:nth-child(2)")
   ├─ orden de los nodos, número de <div>s
   ├─ estilos, colores, spacing
   └─ nombres internos: computed, methods, data properties
```

### `data-testid`: la ancla que sobrevive

Un `data-testid` es un atributo que **existe solo para los tests** y que tú
prometes mantener aunque cambies todo lo demás. Es un contrato explícito contigo
mismo:

```html
<!-- Bootstrap, hoy -->
<input class="form-control" data-testid="ticket-search" v-model="search" />

<!-- Quasar, mañana -->
<q-input outlined data-testid="ticket-search" v-model="search" />
```

**El test no cambia:**

```js
wrapper.find('[data-testid="ticket-search"]').setValue("impresora");
```

Comparado con las alternativas:

| Selector | Sobrevive a la migración | Comentario |
|---|---|---|
| `.form-control` | ❌ | clase de Bootstrap. Quasar no la pone |
| `input[type=text]` | ⚠️ | `QInput` sí renderiza un `<input>`… hasta que le pones `type="textarea"` |
| `.col-md-6 > div:nth-child(2)` | ❌❌ | esto ya está roto, solo que aún no lo sabes |
| `wrapper.vm.search = "x"` | ❌ | estás testeando la implementación, no la UI |
| `[data-testid="ticket-search"]` | ✅ | **es un contrato. Lo pones tú, lo mantienes tú** |

> ⚠️ **La objeción de siempre:** *"pero es contaminar el HTML de producción con
> cosas de test"*. Sí. Ese es el precio, y es baratísimo: un atributo que no pesa,
> no renderiza y no rompe nada, a cambio de una suite que no se cae con cada
> refactor. (Y si te molesta de verdad: existen plugins de Babel que los eliminan
> en build de producción. En 2020, casi nadie se molestaba.)

**Regla de dónde ponerlos:** en los **puntos de interacción** (inputs, botones,
filas clicables) y en los **puntos de aserción** (mensajes de error, contadores,
el contenedor de la lista). No en cada `<div>`: un `data-testid` por cada nodo es
volver a testear el DOM, solo que con mejor letra.

---

## 🧠 Concepto 3: los dos contratos que de verdad importan

Tu aplicación tiene fronteras. Una migración de UI **no debería cruzar ninguna**.
Y eso, que es una afirmación de arquitectura, se convierte aquí en algo mucho
mejor: **una aserción ejecutable**.

```
   ┌──────────────────────────────────────────┐
   │  CAPA DE PRESENTACIÓN                    │
   │  Bootstrap hoy · Quasar mañana           │  ← TODO esto se puede caer
   │  <tr> .modal(jQuery) .form-control        │
   └────────────┬─────────────────────────────┘
                │  ⬇️ CONTRATO 1: el store
                │  dispatch("tickets/fetchTickets")
   ┌────────────▼─────────────────────────────┐
   │  STORE (F10)  — NO SE TOCA               │
   └────────────┬─────────────────────────────┘
                │
   ┌────────────▼─────────────────────────────┐
   │  services/ — NO SE TOCA                  │
   └────────────┬─────────────────────────────┘
                │  ⬇️ CONTRATO 2: la API
                │  GET /tickets?_sort=createdAt&_order=desc
   ┌────────────▼─────────────────────────────┐
   │  apiClient → json-server                 │
   └──────────────────────────────────────────┘
```

**Contrato 1 — con el store.** La vista, sea cual sea el framework, tiene que
seguir despachando lo mismo. Si `TicketsView` despacha hoy `tickets/fetchTickets`
al montarse, la versión Quasar debe despachar `tickets/fetchTickets` al montarse.
Si la nueva tabla te obliga a despachar otra cosa (spoiler: **Q3 te va a obligar**,
y esa pelea es la fase entera), el test rojo **es la alarma correcta funcionando
correctamente**. No lo silencies: negócialo.

**Contrato 2 — con la API.** El servicio manda `GET /tickets` con
`{_sort: "createdAt", _order: "desc"}`. Punto. Cambiar de framework de UI **no es
excusa** para que salga otra petición. Y este contrato es el más sagrado de los
dos, porque del otro lado hay alguien que no está en tu equipo.

**💸 Deuda:** *"El backend no cambia. Si tu test de regresión toca la API real y
falla, el problema es tuyo."*
En este curso el "backend" es json-server y puedes editarlo a mano — lo que crea
la tentación exacta que hay que matar: *"ajusto el mock y ya"*. En producción no
hay ajuste: hay un equipo de backend, un contrato firmado y un ticket de tres
sprints. **El test de contrato existe para que no aprendas eso en producción.**

---

## 🧠 Concepto 4: qué NO testear (y por qué duele no hacerlo)

Esta es la sección que la gente se salta y luego sufre. La lista de arriba dice
*qué* no testear. Aquí va el *por qué*, caso por caso, porque cada uno tiene su
sirena:

- **Clases de Bootstrap** (`.badge-danger`, `.table`, `.alert-danger`) — la sirena
  es que son fáciles y están ahí. Y funcionan hoy. Y mañana `QBadge` renderiza
  `.bg-red` y tienes 14 tests rojos que no significan nada. *Test lo que la clase
  significa:* si `badge-danger` significa "abierto", asegura el **texto**
  "Abierto", no la clase.
- **Etiquetas HTML** (`wrapper.findAll("tr")`) — la sirena es que "un ticket es
  una fila, eso no va a cambiar". Va a cambiar. `QTable` renderiza `<tr>`, sí…
  hasta que le pones `grid` y renderiza `<div>`s. **Cuenta con `data-testid`, no
  con etiquetas.**
- **Orden y estructura del DOM** (`:nth-child`, `.at(2)`, `> div > span`) — la
  sirena es que es lo que autocompleta el editor. Es el selector más frágil que
  existe y no protege absolutamente nada. Si necesitas "el segundo botón", ese
  botón necesita un `data-testid`, no un índice.
- **Estilos y colores** — no son comportamiento. Son gusto. Y en la migración van
  a cambiar **a propósito** (ese es medio motivo por el que migras).
- **Nombres internos** (`wrapper.vm.filteredTickets`, `wrapper.vm.loading`) — la
  sirena es que es cómodo: acceso directo, sin DOM, sin async. Y es un falso
  verde ambulante: `filteredTickets` puede ser perfecto mientras la tabla no lo
  pinta. **Testea lo que se ve, no lo que se calcula.** (Excepción única y
  honesta: testear el computed *como función pura* — pero entonces sácalo a
  `utils/` y testéalo ahí, sin montar nada. La testeabilidad detectando diseño,
  otra vez: F11, concepto 1.)
- **Snapshots del HTML** (`toMatchSnapshot()`) — la sirena es que es una línea y
  "captura todo". Captura **todo**, ese es el problema: en la primera migración
  el diff son 400 líneas rojas, y aprietas `-u` sin mirar. Un snapshot en una
  migración de UI es un test que se autodesactiva.

**El resumen en una frase:**

> Si el test conoce el framework, el test **es** el framework.
> Y estás cambiando de framework.

---

## 💻 Código de la fase

Todo Jest + `@vue/test-utils` **1.x** (el de Vue 2, el mismo de F11). Cero
dependencias nuevas.

### Estructura: una carpeta con contrato

```
tests/
  unit/                      ← los de F11: siguen vivos, siguen siendo suyos
    ticketStats.spec.js
    TicketStatusBadge.spec.js
    ...
  unit/regression/           ← NUEVO. Contrato: NO se editan durante la migración
    README.md                ← el contrato, por escrito
    dashboard.spec.js
    ticketForm.spec.js
    ticketService.contract.spec.js
    helpers/
      fixtures.js
      makeStore.js
```

La separación no es cosmética. Es una regla operativa que puedes leer en un `git
diff`:

> **Si un commit de la migración toca `tests/unit/regression/`, es sospechoso por
> defecto y necesita justificación en el mensaje del commit.**

`tests/unit/regression/README.md`:

```md
# Red de seguridad — NO TOCAR durante la migración

Estos tests describen el comportamiento del Mini Jira **antes** de Quasar.

Regla: durante Q1–Q4 estos archivos NO se editan.
Si uno se pone rojo, hay exactamente dos respuestas válidas:

1. Rompiste el comportamiento → arregla el CÓDIGO.
2. El test estaba acoplado al DOM viejo → arréglalo, y ANOTA POR QUÉ
   en MIGRATION-CHECKLIST.md. Cada edición aquí es una confesión.

Lo que NO es una respuesta válida: borrarlo, .skip()arlo, o "ajustarlo
hasta que pase".
```

### Sembrar los `data-testid` (el único cambio a código de producción)

Antes de escribir un test, siembra las anclas. Es el **único** momento de la ruta
en que tocas el código a pelo, y es un cambio de cero riesgo.

> 🔒 **Contrato de IDs — el prefijo es `ticket-`, no `form-`.** Los `data-testid`
> que siembras aquí son un **contrato que Q2 y Q3 van a reutilizar tal cual**. El
> formulario usa exactamente estos seis: `ticket-title`, `ticket-description`,
> `ticket-priority`, `ticket-assignee`, `ticket-submit`, `ticket-cancel` (más los
> `-error` por campo). Cuando en Q2 el `<input class="form-control">` se convierta
> en `<q-input>`, el test sigue encontrando el campo **porque el `data-testid` no
> cambió**. Si aquí los llamas `form-*` y en Q2 los declaras `ticket-*` (o al
> revés), toda la suite del formulario se te pone roja en Q2 por un renombre —
> justo el ruido que esta fase existe para evitar. **Un solo prefijo, `ticket-`,
> en toda la ruta.**

> ⚠️ **Esto asume que hiciste el refactor de F10.** El botón de reintentar llama a
> `fetchTickets()` (la action mapeada), no a `loadTickets()` (el method local de
> F4). Si tu `TicketsView` todavía tiene `loadTickets` y `tickets` en `data()`, no
> hiciste F10 — y entonces el "contrato con el store" que esta fase te pide congelar
> **no existe todavía**. F10 no es opcional para la ruta: es donde nace el contrato
> que Q3 va a poner a prueba. Vuelve, refactoriza, y regresa.

`views/TicketsView.vue` — solo los atributos, todo lo demás intacto:

```vue
<!-- estado: cargando -->
<div v-if="loading" class="text-center my-5" data-testid="tickets-loading">
  <div class="spinner-border text-primary" role="status"></div>
</div>

<!-- estado: error -->
<div v-else-if="error" class="alert alert-danger" data-testid="tickets-error">
  {{ error }}
  <button class="btn btn-sm btn-outline-danger ml-2"
          data-testid="tickets-retry"
          @click="fetchTickets()">
    Reintentar
  </button>
</div>

<template v-else>
  <tickets-summary :tickets="tickets" />

  <input v-model="search" type="text" class="form-control"
         data-testid="tickets-search"
         placeholder="🔍 Buscar por título..." />

  <select v-model="statusFilter" class="form-control"
          data-testid="tickets-status-filter">
    ...
  </select>

  <button class="btn btn-outline-secondary btn-block"
          data-testid="tickets-clear-filters"
          @click="clearFilters">
    Limpiar filtros
  </button>

  <p class="text-muted small" data-testid="tickets-count">
    Mostrando {{ filteredTickets.length }} de {{ tickets.length }} tickets
  </p>

  <tickets-table :tickets="filteredTickets" @select="goToDetail" />
</template>
```

`components/tickets/TicketsTable.vue`:

```vue
<tr
  v-for="ticket in tickets"
  :key="ticket.id"
  :data-testid="'ticket-row-' + ticket.id"
  style="cursor: pointer;"
  @click="$emit('select', ticket)"
>
  <td>{{ ticket.id }}</td>
  <td :data-testid="'ticket-title-' + ticket.id">{{ ticket.title }}</td>
  ...
</tr>

<div v-if="tickets.length === 0"
     class="text-center text-muted py-4"
     data-testid="tickets-empty">
  <p class="mb-0">🔍 No hay tickets que coincidan con los filtros.</p>
</div>
```

`components/tickets/TicketsSummary.vue` — Q3 también se lo lleva, y sin ancla no
hay forma de afirmar los conteos sin agarrarse de `.card` y de `<h2>`:

```vue
<div class="col-6 col-md-3" v-for="card in cards" :key="card.status">
  <div class="card text-center">
    <div class="card-body py-3">
      <h2 class="mb-0" :data-testid="'summary-count-' + card.status">{{ card.count }}</h2>
      <small class="text-muted">{{ card.label }}</small>
    </div>
  </div>
</div>
```

Cuatro anclas dinámicas (`summary-count-open`, `-in_progress`, `-resolved`,
`-closed`) y ninguna sobre el `<small>`: la etiqueta es copy, el número es
comportamiento. El ejercicio 14 vive de esto.

`components/tickets/TicketForm.vue`:

```vue
<input id="title" v-model.trim="form.title" data-testid="ticket-title" ... />
<div v-if="$v.form.title.$error" class="invalid-feedback" data-testid="ticket-title-error">

<textarea id="description" v-model.trim="form.description" data-testid="ticket-description" ...>
<div v-if="$v.form.description.$error" class="invalid-feedback" data-testid="ticket-description-error">

<select id="priority" v-model="form.priority" data-testid="ticket-priority" ...>
<div v-if="$v.form.priority.$error" class="invalid-feedback" data-testid="ticket-priority-error">

<input id="assignee" v-model.trim="form.assignee" data-testid="ticket-assignee" ... />

<button type="submit" data-testid="ticket-submit" :disabled="saving">
  {{ saving ? "Guardando..." : submitLabel }}
</button>
<button type="button" data-testid="ticket-cancel" @click="$emit('cancel')">Cancelar</button>
```

**🔎 Qué hace:** nada. Literalmente. Los `data-testid` no tienen efecto en
runtime — Vue los pasa al DOM como atributos y ahí se quedan. Corre la app: idéntica.
Corre la suite de F11: verde. Ese "nada" es la propiedad más valiosa del cambio.

**✅ Buenas prácticas aplicadas:**
- **Anclas dinámicas por id** (`'ticket-row-' + ticket.id`): permiten afirmar
  *"la fila del ticket 3 está / no está"* sin depender del orden. Los tests que
  dependen del orden mueren en cuanto `QTable` ordena por defecto por otra columna.
- Nombres con **prefijo de dominio** (`tickets-`, `form-`), no de tecnología. Un
  `data-testid="bootstrap-table"` sería un chiste cruel en tres fases.
- Se anclan **puntos de interacción y de aserción**. Nada más. El `<thead>` no
  lleva ancla: nadie va a afirmar nada sobre él.

### Helper 1 — fixtures: `tests/unit/regression/helpers/fixtures.js`

```js
// El fixture mínimo que ejercita TODOS los caminos del dashboard:
// 4 estados distintos, 3 prioridades, un asignado vacío y títulos
// diseñados para que la búsqueda discrimine.
export function makeTickets() {
  return [
    {
      id: 1, title: "Impresora no imprime", description: "La del piso 3",
      status: "open", priority: "high", assignee: "agente1",
      reporter: "user1", createdAt: "2020-03-10T09:00:00Z"
    },
    {
      id: 2, title: "VPN caída", description: "No conecta desde casa",
      status: "in_progress", priority: "high", assignee: "agente2",
      reporter: "user2", createdAt: "2020-03-09T09:00:00Z"
    },
    {
      id: 3, title: "Solicitud de licencia", description: "Office para el nuevo",
      status: "resolved", priority: "low", assignee: "",
      reporter: "user1", createdAt: "2020-03-08T09:00:00Z"
    },
    {
      id: 4, title: "Impresora atascada", description: "Otra vez la del piso 3",
      status: "closed", priority: "medium", assignee: "agente1",
      reporter: "user3", createdAt: "2020-03-07T09:00:00Z"
    }
  ];
}

// "impresora" → tickets 1 y 4 (dos, no uno: obliga al filtro a filtrar de verdad)
// "impresora" + status=open → solo el 1 (la COMBINACIÓN de filtros, que es
//                                         donde vive el bug clásico del &&)
```

> ⚠️ **Si hiciste el ejercicio 3 de F4** (que el buscador mire también en
> `description`), tus números **no van a ser 2 y 1**: el ticket 3 dice "Office para
> el nuevo" y el 2 "No conecta desde casa" — no cambian nada aquí, pero *tu* fixture
> sí puede. Y esa es exactamente la lección: **el fixture congela TU comportamiento,
> no el mío.** Ajusta los conteos a lo que tu `filteredTickets` hace **hoy**, y
> escribe en un comentario por qué hace eso. Si copias mis números sin correr la
> suite, acabas de escribir una red que protege un sistema que no es el tuyo.

**🔎 Qué hace:** el fixture **es** el diseño del test. Cuatro tickets elegidos
para que ningún filtro pueda pasar por casualidad: si el filtro de texto ignorara
el de estado, el caso combinado devolvería 2 en vez de 1 y el test lo caza.

**✅ Buenas prácticas aplicadas:** los datos son **inventados**, no copiados de
`db.json`. Un fixture pegado de datos reales trae 9 campos que a nadie le importan
y se rompe cuando el modelo cambia en un campo que el test ni miraba (F11, errores
comunes: *"fixtures gigantes copiados de datos reales: frágiles y ruidosos — el
fixture mínimo documenta qué campos importan"*).

### Helper 2 — el store de laboratorio: `tests/unit/regression/helpers/makeStore.js`

```js
import Vuex from "vuex";

// Un store MÍNIMO con la misma FORMA que el real (F10), pero de juguete:
// namespace tickets, el getter allTickets, el state loading/error,
// y las actions como jest.fn() para poder espiarlas.
//
// ¿Por qué no importar el store real? Porque entonces estaría testeando
// el store — y el store ya tiene sus tests (F11) y NO se migra.
// Aquí pruebo el CONTRATO de la vista CON el store. Nada más.
export function makeStore(overrides) {
  overrides = overrides || {};

  const fetchTickets = jest.fn().mockResolvedValue([]);

  const store = new Vuex.Store({
    modules: {
      tickets: {
        namespaced: true,
        state: {
          items: overrides.items || [],
          loading: overrides.loading || false,
          error: overrides.error || ""
        },
        getters: {
          allTickets: function (state) { return state.items; }
        },
        actions: {
          fetchTickets: fetchTickets
        }
      },
      auth: {
        namespaced: true,
        getters: {
          currentUser: function () { return { username: "agente1", role: "agent" }; }
        }
      }
    }
  });

  // se devuelven los espías junto al store: el test los interroga después
  store.spies = { fetchTickets: fetchTickets };
  return store;
}
```

**🔎 Qué hace:** construye un doble del store con la **forma** exacta que la vista
consume (`mapState("tickets", ...)`, `mapGetters("tickets", {tickets: "allTickets"})`,
`mapActions("tickets", ["fetchTickets"])`) pero sin lógica real.

**✅ Buenas prácticas aplicadas:**
- **Cada capa se prueba contra un doble de su vecina de abajo** (F11, concepto de
  `jest.mock`). Aquí la vecina es el store.
- El store falso **hereda la deuda de forma**: si mañana renombras el getter,
  este helper truena y te enteras. Es un test de contrato disfrazado de helper.
- Un solo lugar donde tocar cuando el contrato cambie a propósito. Doce tests, un
  helper.

### Test 1 — el dashboard: `tests/unit/regression/dashboard.spec.js`

```js
import { mount, createLocalVue } from "@vue/test-utils";
import Vuex from "vuex";
import VueRouter from "vue-router";
import TicketsView from "@/views/TicketsView.vue";
import { makeTickets } from "./helpers/fixtures";
import { makeStore } from "./helpers/makeStore";

const localVue = createLocalVue();
localVue.use(Vuex);
localVue.use(VueRouter);

// El filtro global de F4 vive en main.js, que aquí no corre.
// Se registra en el localVue: si no, el template revienta con
// "Failed to resolve filter: formatDate" — clásico al testear vistas.
localVue.filter("formatDate", function (value) {
  return value ? String(value).slice(0, 10) : "";
});

function build(storeOverrides) {
  const store = makeStore(storeOverrides);
  const router = new VueRouter({ routes: [] });

  // mount COMPLETO (no shallowMount): el comportamiento que protejo
  // ("al filtrar quedan N filas") vive en la COLABORACIÓN vista ↔ tabla.
  // Un shallowMount stubearía TicketsTable y no habría filas que contar.
  // Es la excepción de la regla de F11, y esta fase es su caso de uso.
  const wrapper = mount(TicketsView, {
    localVue: localVue,
    store: store,
    router: router
  });

  return { wrapper: wrapper, store: store, router: router };
}

// helper local: cuenta filas SIN saber que son <tr>
function rowCount(wrapper) {
  return wrapper.findAll('[data-testid^="ticket-row-"]').length;
}

describe("REGRESIÓN · Dashboard de tickets", function () {

  describe("contrato con el store", function () {
    it("al montarse despacha tickets/fetchTickets", function () {
      const ctx = build();
      // ESTA es la aserción que debe sobrevivir a Quasar.
      // No importa quién pinte la tabla: la vista pide los datos al store.
      expect(ctx.store.spies.fetchTickets).toHaveBeenCalledTimes(1);
    });

    it("el botón de reintentar vuelve a despachar la action", function () {
      const ctx = build({ error: "No se pudieron cargar los tickets." });

      ctx.wrapper.find('[data-testid="tickets-retry"]').trigger("click");

      // Se afirma QUÉ se despacha. NO con qué opciones de caché.
      // El `force` de la action (F10) es un detalle INTERNO del store:
      // afirmarlo aquí sería testear la implementación de la vecina de abajo.
      // (Y sería además innecesario: en estado de error `items` está vacío,
      //  el caché no dispara, y un fetchTickets() pelado ya va a la red.)
      expect(ctx.store.spies.fetchTickets).toHaveBeenCalledTimes(2);
    });
  });

  describe("los tres estados de la vista", function () {
    it("loading: muestra el indicador y ninguna fila", function () {
      const ctx = build({ loading: true });

      expect(ctx.wrapper.find('[data-testid="tickets-loading"]').exists()).toBe(true);
      expect(rowCount(ctx.wrapper)).toBe(0);
    });

    it("error: muestra el mensaje del store, literal", function () {
      const ctx = build({ error: "No se pudieron cargar los tickets." });
      const alert = ctx.wrapper.find('[data-testid="tickets-error"]');

      expect(alert.exists()).toBe(true);
      expect(alert.text()).toContain("No se pudieron cargar los tickets.");
      expect(rowCount(ctx.wrapper)).toBe(0);
    });

    it("datos: pinta una fila por ticket", function () {
      const ctx = build({ items: makeTickets() });

      expect(rowCount(ctx.wrapper)).toBe(4);
      expect(ctx.wrapper.find('[data-testid="ticket-title-1"]').text())
        .toBe("Impresora no imprime");
    });

    it("lista vacía: muestra el estado vacío, no una tabla muda", function () {
      const ctx = build({ items: [] });

      expect(ctx.wrapper.find('[data-testid="tickets-empty"]').exists()).toBe(true);
    });
  });

  describe("filtrado (el corazón de F4)", function () {
    it("la búsqueda por texto reduce las filas", function () {
      const ctx = build({ items: makeTickets() });

      return ctx.wrapper.find('[data-testid="tickets-search"]')
        .setValue("impresora")
        .then(function () {
          expect(rowCount(ctx.wrapper)).toBe(2); // tickets 1 y 4
          expect(ctx.wrapper.find('[data-testid="ticket-row-1"]').exists()).toBe(true);
          expect(ctx.wrapper.find('[data-testid="ticket-row-2"]').exists()).toBe(false);
        });
    });

    it("la búsqueda es case-insensitive (comportamiento actual: congélalo)", function () {
      const ctx = build({ items: makeTickets() });

      return ctx.wrapper.find('[data-testid="tickets-search"]')
        .setValue("IMPRESORA")
        .then(function () {
          expect(rowCount(ctx.wrapper)).toBe(2);
        });
    });

    it("el filtro de estado reduce las filas", function () {
      const ctx = build({ items: makeTickets() });

      return ctx.wrapper.find('[data-testid="tickets-status-filter"]')
        .setValue("open")
        .then(function () {
          expect(rowCount(ctx.wrapper)).toBe(1);
          expect(ctx.wrapper.find('[data-testid="ticket-row-1"]').exists()).toBe(true);
        });
    });

    it("los filtros se COMBINAN (el && del computed)", function () {
      const ctx = build({ items: makeTickets() });
      const search = ctx.wrapper.find('[data-testid="tickets-search"]');
      const status = ctx.wrapper.find('[data-testid="tickets-status-filter"]');

      return search.setValue("impresora")
        .then(function () { return status.setValue("open"); })
        .then(function () {
          // "impresora" da 2 (1 y 4). + open → solo el 1.
          // Si este test pasa a 2, alguien rompió el && y el otro test no lo vio.
          expect(rowCount(ctx.wrapper)).toBe(1);
          expect(ctx.wrapper.find('[data-testid="ticket-row-1"]').exists()).toBe(true);
          expect(ctx.wrapper.find('[data-testid="ticket-row-4"]').exists()).toBe(false);
        });
    });

    it("filtro sin resultados: estado vacío, cero filas", function () {
      const ctx = build({ items: makeTickets() });

      return ctx.wrapper.find('[data-testid="tickets-search"]')
        .setValue("zzzz-no-existe")
        .then(function () {
          expect(rowCount(ctx.wrapper)).toBe(0);
          expect(ctx.wrapper.find('[data-testid="tickets-empty"]').exists()).toBe(true);
        });
    });

    it("limpiar filtros devuelve todas las filas", function () {
      const ctx = build({ items: makeTickets() });

      return ctx.wrapper.find('[data-testid="tickets-search"]').setValue("impresora")
        .then(function () {
          return ctx.wrapper.find('[data-testid="tickets-clear-filters"]').trigger("click");
        })
        .then(function () {
          expect(rowCount(ctx.wrapper)).toBe(4);
        });
    });

    it("el contador refleja filtrados vs total", function () {
      const ctx = build({ items: makeTickets() });

      return ctx.wrapper.find('[data-testid="tickets-search"]')
        .setValue("impresora")
        .then(function () {
          const texto = ctx.wrapper.find('[data-testid="tickets-count"]').text();
          // NO se afirma la frase exacta: se afirman los DOS NÚMEROS.
          // Si mañana el copy cambia a "2 de 4 resultados", esto sigue verde.
          expect(texto).toMatch(/\b2\b/);
          expect(texto).toMatch(/\b4\b/);
        });
    });
  });

  describe("selección de fila", function () {
    it("clic en una fila navega al detalle de ESE ticket", function () {
      const ctx = build({ items: makeTickets() });
      const push = jest.spyOn(ctx.router, "push").mockImplementation(function () {});

      ctx.wrapper.find('[data-testid="ticket-row-2"]').trigger("click");

      expect(push).toHaveBeenCalledWith("/tickets/2");
    });
  });
});
```

**🔎 Qué hace:** congela el dashboard entero — el contrato con el store, los tres
estados, la combinación de filtros y la selección — **sin nombrar una sola vez** a
Bootstrap, a `<tr>`, a `.table` ni a `filteredTickets`. Reescribe la vista entera
en otro framework y estos tests son válidos tal cual.

**✅ Buenas prácticas aplicadas:**
- El helper `rowCount()` **encapsula el único punto de contacto con el DOM**.
  Cuando la fila deje de ser un `<tr>`, se toca **una función**, no once tests.
  Esa función es tu junta de dilatación.
- `mount` en lugar de `shallowMount`, contra la regla de F11 — **y con motivo
  declarado en el comentario**. El comportamiento a proteger vive en la
  colaboración vista↔tabla; stubear la tabla sería testear que la vista calcula
  bien un array que nadie pinta. Falso verde de manual.
- `setValue` devuelve Promise en VTU 1.x: los `.then()` encadenados **no son
  decoración**, son la única forma de que el DOM esté actualizado antes del
  `expect`. Sin ellos: verde falso, otra vez (F11, la trampa).
- El contador se afirma con **regex sobre los números**, no con la frase. El copy
  es presentación; los números son comportamiento. Sabes distinguirlos porque te
  preguntaste *"¿le importa al usuario, o solo a mí?"*.
- `case-insensitive` está testeado explícitamente porque **es una decisión que hoy
  está viva** (el `.toLowerCase()` del computed) y nadie la documentó. Ahora sí.

### Test 2 — el formulario: `tests/unit/regression/ticketForm.spec.js`

```js
import { mount, createLocalVue } from "@vue/test-utils";
import Vuelidate from "vuelidate";
import TicketForm from "@/components/tickets/TicketForm.vue";

const localVue = createLocalVue();
localVue.use(Vuelidate); // sin esto, $v es undefined y el render explota

function build(props) {
  return mount(TicketForm, {
    localVue: localVue,
    propsData: props || {}
  });
}

// El acto de "llenar el formulario", en un solo sitio.
// Cuando los campos sean QInput, se toca ESTO. Los tests no se enteran.
function fill(wrapper, values) {
  const p = [];
  if (values.title !== undefined)
    p.push(wrapper.find('[data-testid="ticket-title"]').setValue(values.title));
  if (values.description !== undefined)
    p.push(wrapper.find('[data-testid="ticket-description"]').setValue(values.description));
  if (values.priority !== undefined)
    p.push(wrapper.find('[data-testid="ticket-priority"]').setValue(values.priority));
  if (values.assignee !== undefined)
    p.push(wrapper.find('[data-testid="ticket-assignee"]').setValue(values.assignee));
  return Promise.all(p);
}

const VALIDO = {
  title: "Impresora no imprime",
  description: "La del piso 3 lleva dos días muerta",
  priority: "high",
  assignee: "agente1"
};

describe("REGRESIÓN · TicketForm", function () {

  describe("el contrato de salida: qué emite y cuándo", function () {
    it("con datos válidos, el submit emite 'submit' con el payload limpio", function () {
      const wrapper = build();

      return fill(wrapper, VALIDO)
        .then(function () {
          return wrapper.find("form").trigger("submit");
        })
        .then(function () {
          expect(wrapper.emitted("submit")).toHaveLength(1);
          expect(wrapper.emitted("submit")[0][0]).toEqual(VALIDO);
        });
    });

    it("con datos INVÁLIDOS, el submit NO emite nada", function () {
      const wrapper = build();

      // esta es la aserción más importante del archivo:
      // el formulario es la última barrera antes del POST.
      return wrapper.find("form").trigger("submit").then(function () {
        expect(wrapper.emitted("submit")).toBeUndefined();
      });
    });

    it("el payload NO incluye status ni reporter ni createdAt (los pone la vista)", function () {
      const wrapper = build();

      return fill(wrapper, VALIDO)
        .then(function () { return wrapper.find("form").trigger("submit"); })
        .then(function () {
          const payload = wrapper.emitted("submit")[0][0];
          expect(payload.status).toBeUndefined();
          expect(payload.reporter).toBeUndefined();
          expect(payload.createdAt).toBeUndefined();
        });
    });

    it("el botón de cancelar emite 'cancel', sin payload", function () {
      const wrapper = build();

      wrapper.find('[data-testid="ticket-cancel"]').trigger("click");

      expect(wrapper.emitted("cancel")).toHaveLength(1);
    });
  });

  describe("las reglas de validación, una por una", function () {
    // Se afirma "no emite" — NO se afirma la clase .is-invalid ni el texto
    // del mensaje. La regla es comportamiento; el mensaje es copy.
    function rechaza(valores) {
      const wrapper = build();
      return fill(wrapper, Object.assign({}, VALIDO, valores))
        .then(function () { return wrapper.find("form").trigger("submit"); })
        .then(function () {
          expect(wrapper.emitted("submit")).toBeUndefined();
        });
    }

    it("título vacío: rechaza", function () { return rechaza({ title: "" }); });
    it("título de 4 caracteres: rechaza (mínimo 5)", function () { return rechaza({ title: "abcd" }); });
    it("título de 81 caracteres: rechaza (máximo 80)", function () {
      return rechaza({ title: "x".repeat(81) });
    });
    it("descripción de 9 caracteres: rechaza (mínimo 10)", function () {
      return rechaza({ description: "123456789" });
    });
    it("prioridad vacía: rechaza", function () { return rechaza({ priority: "" }); });

    it("asignado vacío: ACEPTA (es opcional — congela esta decisión)", function () {
      const wrapper = build();
      return fill(wrapper, Object.assign({}, VALIDO, { assignee: "" }))
        .then(function () { return wrapper.find("form").trigger("submit"); })
        .then(function () {
          expect(wrapper.emitted("submit")).toHaveLength(1);
        });
    });

    it("el título de exactamente 80 caracteres: ACEPTA (el borde exacto)", function () {
      const wrapper = build();
      return fill(wrapper, Object.assign({}, VALIDO, { title: "x".repeat(80) }))
        .then(function () { return wrapper.find("form").trigger("submit"); })
        .then(function () {
          expect(wrapper.emitted("submit")).toHaveLength(1);
        });
    });
  });

  describe("el feedback de error es visible para el usuario", function () {
    it("tras un submit inválido, aparece el error del título", function () {
      const wrapper = build();

      return wrapper.find("form").trigger("submit").then(function () {
        // se afirma que EXISTE un mensaje de error anclado al campo.
        // NO se afirma su texto exacto (eso es copy) ni su clase (eso es Bootstrap).
        expect(wrapper.find('[data-testid="ticket-title-error"]').exists()).toBe(true);
      });
    });

    it("antes de tocar nada, NO hay errores visibles (el patrón $error de F5)", function () {
      const wrapper = build();

      expect(wrapper.find('[data-testid="ticket-title-error"]').exists()).toBe(false);
    });
  });

  describe("modo edición: el patrón prop → copia local", function () {
    it("con initialTicket, precarga los campos", function () {
      const wrapper = build({
        initialTicket: {
          id: 7, title: "VPN caída", description: "No conecta desde casa",
          priority: "high", assignee: "agente2", status: "open"
        }
      });

      expect(wrapper.find('[data-testid="ticket-title"]').element.value).toBe("VPN caída");
      expect(wrapper.find('[data-testid="ticket-priority"]').element.value).toBe("high");
    });

    it("editar NO muta la prop (el pecado capital de F4)", function () {
      const original = {
        id: 7, title: "VPN caída", description: "No conecta desde casa",
        priority: "high", assignee: "agente2", status: "open"
      };
      const wrapper = build({ initialTicket: original });

      return wrapper.find('[data-testid="ticket-title"]').setValue("VPN caída otra vez")
        .then(function () {
          expect(original.title).toBe("VPN caída"); // el objeto del padre, intacto
        });
    });

    it("el payload de edición conserva los campos que el form no gestiona", function () {
      const wrapper = build({
        initialTicket: {
          id: 7, title: "VPN caída", description: "No conecta desde casa",
          priority: "high", assignee: "agente2", status: "open"
        }
      });

      return wrapper.find("form").trigger("submit").then(function () {
        const payload = wrapper.emitted("submit")[0][0];
        // ⚠️ COMPORTAMIENTO ACTUAL, no necesariamente el deseado:
        // el Object.assign de created() arrastra id y status al form,
        // y el submit los devuelve. El PATCH los reenvía tal cual.
        // ¿Está bien? Discutible. ¿Es lo que pasa hoy? Sí.
        // → SE CONGELA. Si al migrar cambia, quiero enterarme.
        expect(payload.id).toBe(7);
        expect(payload.status).toBe("open");
      });
    });
  });

  describe("estado de guardado", function () {
    it("con saving=true el botón se deshabilita (anti doble submit de F5)", function () {
      const wrapper = build({ saving: true });
      const boton = wrapper.find('[data-testid="ticket-submit"]');

      expect(boton.attributes("disabled")).toBeDefined();
    });

    it("submitLabel se respeta", function () {
      const wrapper = build({ submitLabel: "Crear ticket" });

      expect(wrapper.find('[data-testid="ticket-submit"]').text()).toContain("Crear ticket");
    });
  });
});
```

**🔎 Qué hace:** encierra `TicketForm` en una caja y lo interroga **solo por sus
fronteras**: lo que entra (props) y lo que sale (eventos). Vuelidate no aparece en
una sola aserción, y ese es el punto — **en Q2 vuelidate se va del proyecto**, y
este archivo tiene que seguir en verde el día después.

**✅ Buenas prácticas aplicadas:**
- El helper `fill()` es el mismo truco que `rowCount()`: **un solo punto de
  contacto con el DOM**. Cuando los inputs sean `QInput` y `setValue` deje de
  funcionar igual, se toca esa función. Veinte tests, un helper. *(Guárdate esta
  frase: en Q2 la vas a agradecer.)*
- Las reglas se testean por su **efecto** ("no emite"), no por su **mecanismo**
  (`$v.form.title.$invalid`). Un test que dice `expect(wrapper.vm.$v.$invalid)`
  se muere el día que `:rules` reemplace a vuelidate — y el comportamiento
  "título de 4 letras no pasa" no habrá cambiado en absoluto.
- **Los bordes exactos** (80 sí, 81 no) valen más que los casos felices. Es donde
  el legacy sangra, y es donde una migración se lleva por delante una regla
  sin que nadie lo note.
- El test de "el payload arrastra `id` y `status`" **congela una rareza**. Nadie
  dijo que fuera bonito. Se documenta en el comentario, se congela, y se decide
  después — con la red puesta. **Arreglar y migrar a la vez es cómo se pierde una
  semana sin saber quién te rompió qué.**

### Test 3 — el contrato con la API: `tests/unit/regression/ticketService.contract.spec.js`

```js
jest.mock("@/services/apiClient"); // auto-mock: get/post/patch/delete → jest.fn()

import apiClient from "@/services/apiClient";
import ticketService from "@/services/ticketService";

describe("REGRESIÓN · Contrato con la API", function () {
  beforeEach(function () {
    jest.clearAllMocks(); // sin esto: llamadas fantasma entre tests (F11)
  });

  it("listar: GET /tickets con el sort de F4, exacto", function () {
    apiClient.get.mockResolvedValue({ data: [] });

    return ticketService
      .getTickets({ _sort: "createdAt", _order: "desc" })
      .then(function () {
        expect(apiClient.get).toHaveBeenCalledWith("/tickets", {
          params: { _sort: "createdAt", _order: "desc" }
        });
      });
  });

  it("obtener: GET /tickets/:id", function () {
    apiClient.get.mockResolvedValue({ data: { id: 1 } });

    return ticketService.getTicketById(1).then(function () {
      expect(apiClient.get).toHaveBeenCalledWith("/tickets/1");
    });
  });

  it("crear: POST /tickets con el payload ÍNTEGRO", function () {
    const payload = {
      title: "Impresora no imprime",
      description: "La del piso 3 lleva dos días muerta",
      priority: "high",
      assignee: "agente1",
      status: "open",
      reporter: "user1",
      createdAt: "2020-03-10T09:00:00Z"
    };
    apiClient.post.mockResolvedValue({ data: Object.assign({ id: 99 }, payload) });

    return ticketService.createTicket(payload).then(function (created) {
      expect(apiClient.post).toHaveBeenCalledWith("/tickets", payload);
      // el servicio desenvuelve response.data — la vista recibe el ticket,
      // no la respuesta de axios. Contrato de F3, todavía vigente.
      expect(created.id).toBe(99);
    });
  });

  it("actualizar: PATCH (no PUT) — congela la decisión de F3", function () {
    apiClient.patch.mockResolvedValue({ data: {} });

    return ticketService.updateTicket(1, { status: "resolved" }).then(function () {
      expect(apiClient.patch).toHaveBeenCalledWith("/tickets/1", { status: "resolved" });
      expect(apiClient.put).not.toHaveBeenCalled(); // PATCH parcial vs PUT total: no es lo mismo
    });
  });

  it("borrar: DELETE /tickets/:id", function () {
    apiClient.delete.mockResolvedValue({ data: {} });

    return ticketService.deleteTicket(1).then(function () {
      expect(apiClient.delete).toHaveBeenCalledWith("/tickets/1");
    });
  });

  it("el error se PROPAGA (la vista pinta la alerta; el servicio no la traga)", function () {
    apiClient.get.mockRejectedValue(new Error("Network Error"));

    return ticketService.getTickets({}).then(
      function () { throw new Error("no debió resolver"); },
      function (err) { expect(err.message).toBe("Network Error"); }
    );
  });
});
```

**🔎 Qué hace:** verifica el **contrato 2**. Mockea `apiClient` (la frontera con
axios) y afirma la petición exacta. Nada de esto puede cambiar porque cambies de
librería de tablas — y si cambia, aquí suena la alarma antes de que un backend
que no está en la sala se entere por un 400.

**✅ Buenas prácticas aplicadas:**
- **Este es el archivo con la vida útil más larga de toda la ruta.** No monta
  componentes, no conoce Vue, no sabe qué es un `<tr>`. Va a seguir verde en Q4,
  y va a seguir verde si mañana alguien migra a Vue 3. Cuando alguien pregunte
  "¿qué test escribo primero en un legacy ajeno?": **este**.
- `expect(apiClient.put).not.toHaveBeenCalled()` es una aserción **negativa** y
  parece redundante. No lo es: congela una decisión (PATCH parcial, no PUT total)
  que un refactor descuidado revierte sin que nadie lo note hasta que un campo
  desaparece en producción.
- El error se testea **propagándose**, no siendo tragado. Es la otra mitad del
  contrato, y la que se olvida.

---

## 🅠 Divergencia Quasar — el test que te va a dar la bofetada

> Sección específica de la ruta Q. En VU0 es `v-data-table`; en NX0 el problema es
> otro (`window` no existe en el servidor) y se trata allí.

Antes de mirar a Quasar, mira tu propia suite. Abre `tests/unit/` y haz el
inventario de lo que F11 te dejó:

```
tests/unit/
  ticketStats.spec.js        ← funciones puras (F7)
  ticketTransitions.spec.js  ← la máquina de estados (F9)
  store-tickets.spec.js      ← mutations y actions (F10)
  ticketService.spec.js      ← el servicio con apiClient mockeado (F3)
  TicketStatusBadge.spec.js  ← un badge
  StatusActions.spec.js      ← unos botones
```

Seis archivos. Y ahora la pregunta incómoda:

> **¿Cuáles de esos seis se rompen cuando migres el dashboard a `QTable`?**

Cuéntalos. **Ninguno.**

Ni uno solo. `ticketStats` no monta nada. `ticketTransitions` es una función pura.
`store-tickets` no sabe qué es un `<tr>`. `ticketService` no sabe que Vue existe.
El badge y los botones de estado **no se migran en esta ruta**.

Eso es una buena noticia. Y es, a la vez, **la peor noticia posible**, porque
significa exactamente esto:

> ### Tu suite de F11 no se va a poner roja durante la migración. Y no porque sea buena. Porque **no está mirando**.

`TicketsView`, `TicketsTable`, `TicketsSummary`, `TicketForm` — **las cuatro piezas
que Q2 y Q3 van a reescribir enteras** — no tienen un solo test en F11. Búscalos en
la lista de arriba. No están.

### ¿Y por qué no están? Porque el curso te lo dijo, y no lo leíste como una amenaza

Están, pero como **ejercicios 🟠**:

- **F11, ejercicio 18** — testear `TicketForm` (montar, `setValue`, `emitted`, el caso inválido).
- **F11, ejercicio 22** — test de integración de `TicketsView` con el store y el servicio mockeado.

Y la regla del curso, la que has venido siguiendo desde F0, es: *"completar los
ejercicios 🟢 y 🟡 de cada fase antes de avanzar"*. Los 🟠 son opcionales.

O sea: **si seguiste las reglas al pie de la letra, llegas a Q0 sin una sola línea
de test sobre lo que estás a punto de borrar.** No hiciste nada mal. El agujero es
de diseño, y este es el momento en que se paga.

Esa es la respuesta honesta a por qué existe esta fase. No viniste aquí a auditar
una suite podrida — viniste porque **la red no cubre la zona donde vas a saltar.**

### La bofetada de verdad llega en Q3

Ahora sí, mira hacia adelante. En Q3 vas a cambiar el dashboard por `QTable`, y
—si hiciste el ejercicio 22 de F11, o si el legacy ajeno al que llegues ya trae
tests— te vas a encontrar con algo de esta forma:

```js
// El test que un dev razonable escribe SIN pensar en migraciones.
// (Es el ejercicio 22 de F11, o cualquier test de tabla de cualquier legacy.)
it("pinta una fila por ticket", function () {
  const wrapper = mount(TicketsView, { /* store, router */ });

  expect(wrapper.findAll("tbody tr")).toHaveLength(4);
  expect(wrapper.find("table").classes()).toContain("table-hover");
});
```

El día de Q3 este test se pone **rojo**. `QTable` no renderiza `.table-hover`. Y
ahí, delante del rojo, con el café enfriándose, se abre **la pregunta de la fase**:

> ### ¿Rompiste el comportamiento, o tu test era una porquería acoplada al DOM?

Y hay que responderla **aserción por aserción**, porque las dos líneas de ese test
no valen lo mismo:

| Aserción | Veredicto | Por qué |
|---|---|---|
| `findAll("tbody tr")).toHaveLength(4)` | 🟡 **medio culpable** | La intención ("hay 4 filas") es legítima y **hay que conservarla**. El **selector** no: asume `<table>`. Con `[data-testid^="ticket-row-"]` habría sobrevivido intacto |
| `classes()).toContain("table-hover")` | 🔴 **culpable** | Esto no protege nada. Protege una clase de Bootstrap. **Bórralo sin remordimiento** |

Fíjate en lo que pasó: el rojo **no te dijo nada sobre tu aplicación**. Te dijo
algo sobre tu test. Y esa es la peor clase de rojo que existe, porque a la tercera
vez que ocurre, dejas de leerlos. *"Ah, ese siempre falla."* Ahí murió tu red.

**La regla que sale de aquí, y que es la razón de ser de Q0:**

> Cuando un test se pone rojo durante una migración, la primera pregunta **no** es
> "¿qué rompí?". Es: **"¿este test podría pasar en verde con otra implementación
> por debajo?"**
>
> - **Sí** → el rojo es real. Rompiste algo. Arregla el **código**.
> - **No** → el test era cemento. Reescríbelo con anclas, **anótalo en el
>   checklist**, y sigue.
>
> Y la tercera respuesta, la que nadie quiere oír: **si NINGÚN test se pone rojo,
> tampoco te relajes.** Puede que hayas roto medio dashboard y que tu suite,
> sencillamente, no estuviera mirando. Es lo que te acaba de pasar con F11.

Los tests de `tests/unit/regression/` que acabas de escribir están diseñados para
que la respuesta sea **siempre "sí"** — y, sobre todo, para que **estén mirando el
sitio correcto**. Por eso viven en su carpeta, por eso cubren precisamente F4 y F5
(lo que F11 dejó descubierto), y por eso el `rowCount()` es una función y no un
`findAll("tr")` copiado doce veces.

> 💡 **La moraleja, que vale para cualquier legacy ajeno:** cuando te digan *"esa
> parte del sistema tiene tests"*, la pregunta no es cuántos. Es **cuáles se
> pondrían rojos si reescribes la pantalla**. Muchas veces la respuesta es
> "ninguno", y la suite verde de la que todos presumen no cubre ni una línea de lo
> que vas a tocar. **Cobertura no es protección.**

### 🅠 El anticipo honesto: qué tests SÍ van a cambiar en Q2/Q3, y está bien

No todo se puede blindar. Sé honesto con lo que viene:

| Test | Sobrevive | Por qué |
|---|---|---|
| `ticketService.contract.spec.js` | ✅ **entero** | Ni sabe que Vue existe |
| `dashboard.spec.js` · contrato con el store | ✅ | Salvo que Q3 te obligue a cambiar el dispatch — **y ese rojo es la fase** |
| `dashboard.spec.js` · filtros y conteo | ⚠️ **el helper `rowCount()`** | `QTable` con `grid` no renderiza `<tr>`, pero los `data-testid` van en el slot `body-cell`. **Se toca el helper, no los tests** |
| `dashboard.spec.js` · los tres estados | ⚠️ | `QTable` trae su propio `loading`. Puede que el `data-testid="tickets-loading"` desaparezca. **Anótalo** |
| `ticketForm.spec.js` · qué emite | ✅ **entero** | `QForm @submit` sigue emitiendo. El payload es el mismo |
| `ticketForm.spec.js` · el helper `fill()` | ⚠️ | `setValue` sobre un `QInput` no es igual. **Se toca el helper** |
| `ticketForm.spec.js` · reglas de validación | ✅ | vuelidate se va, `:rules` llega. **El comportamiento no cambia** — y por eso lo testeaste por su efecto |

Cuenta las filas: **la mayoría sobrevive intacta, y las que no, se arreglan en
dos helpers.** Eso no es suerte. Es exactamente lo que compraste esta fase.

---

## 📋 El checklist pre-migración (accionable)

Crea `MIGRATION-CHECKLIST.md` en la raíz. **No es documentación: es una puerta.**
Si algo aquí no está en verde, no se pasa a Q1.

```md
# Checklist pre-migración — Ruta Q (Quasar 1.22)

## 🚦 Puerta 0 — El punto de partida está limpio
- [ ] `npm run test:unit` → **todo verde**. Cero tests en `.skip`, cero rojos
      "que ya estaban ahí".
- [ ] `git status` limpio. **La migración arranca desde un commit conocido.**
- [ ] Tag en git: `git tag pre-quasar` — el punto al que volver cuando te
      pierdas. Y te vas a perder.
- [ ] json-server levantado y la app funciona a mano. Si no funciona a pelo,
      no vas a saber si la rompió Quasar.
- [ ] **El inventario de la ceguera** (ejercicio 5): de los 6 specs que dejó F11,
      ¿cuántos se pondrían rojos si reescribo el dashboard? Si la respuesta es
      **cero** — y lo es — entonces **el verde de F11 no es una autorización para
      migrar. Es solo un punto de partida limpio.** No confundas una cosa con la
      otra: es el error que produce el *"pero si todos los tests pasaban"*.

## 🎯 Puerta 1 — Qué se migra, exactamente
- [ ] Lista explícita de lo que ENTRA en la ruta:
      - Q2 → `TicketForm` + `TicketCreateView` + `TicketEditView` (F5)
      - Q3 → `TicketsView` + `TicketsTable` + `TicketsSummary` (F4/F10)
- [ ] Lista explícita de lo que **NO** se toca:
      - `services/` · `store/` · `router/` · `utils/`
      - Panel de soporte (F9), wizard (F6), métricas (F7) → **ejercicios**
- [ ] ⚠️ Si en algún momento el diff toca `services/` o `store/`: **PARA.**
      Migraste hacia abajo. Eso no era el plan.

## 🛡️ Puerta 2 — La red está puesta
- [ ] `tests/unit/regression/` existe, con su `README.md` y su contrato.
- [ ] Contrato con la API: los 5 verbos de `ticketService` testeados con
      `apiClient` mockeado.
- [ ] Contrato con el store: la vista despacha `tickets/fetchTickets` al montar.
- [ ] Dashboard: carga · error · vacío · filtro texto · filtro estado ·
      **combinado** · limpiar · contador · selección de fila.
- [ ] TicketForm: emite con válidos · **no emite con inválidos** · cada regla ·
      los bordes exactos · precarga en edición · `saving` deshabilita.
- [ ] `data-testid` sembrados en TODOS los puntos de interacción y aserción.
- [ ] **Auditoría de acoplamiento**: recorre `tests/unit/regression/` con este
      grep y que no devuelva NADA:

      grep -rnE "\.(table|badge|btn|form-control|alert|b-modal|col-md)" tests/unit/regression/
      grep -rnE "find\(['\"](tr|td|table|select)['\"]\)" tests/unit/regression/
      grep -rn "wrapper.vm\." tests/unit/regression/

      Si devuelve algo: ese test es cemento. Arréglalo AHORA, no en Q3 a las 7pm.

## 📸 Puerta 3 — La foto del "antes"
- [ ] `npm run test:unit -- --coverage` y **guarda el número**. No para
      perseguirlo: para saber si al terminar la ruta bajó (mala señal:
      borraste código Y su red).
- [ ] Cuenta las líneas de lo que vas a migrar:
      `wc -l src/views/TicketsView.vue src/components/tickets/*.vue`
      En Q3 vas a borrar ~150. Quiero que lo veas medido, no que lo sientas.
- [ ] Anota en 5 líneas: **qué NO te gusta del código actual**. Lo escribes
      HOY, antes de tener framework nuevo con el que confundir tus motivos.

## 🧨 Puerta 4 — El kata del sabotaje (no opcional)
- [ ] Rompe el `&&` de `filteredTickets` a propósito (cámbialo por `||`).
      → ¿La suite lo caza? **Si no lo caza, tu red tiene un agujero y acabas
      de encontrarlo.** Repara la suite, no el código. Luego revierte.
- [ ] Cambia `_order: "desc"` por `"asc"` en el fetch.
      → ¿La suite lo caza? Debe cazarlo el test de contrato.
- [ ] Haz que `TicketForm` emita también con datos inválidos.
      → ¿La suite lo caza? Es la aserción más importante del archivo.

## ✍️ Durante la migración
- [ ] **Cada edición a `tests/unit/regression/` se anota aquí abajo**, con fecha
      y motivo. Al terminar la ruta, esta lista es el informe de calidad de tu
      suite original.

| Fecha | Test tocado | Motivo | ¿Era acoplamiento o rotura real? |
|---|---|---|---|
|  |  |  |  |
```

---

## ⚠️ Errores comunes

- **Escribir la red DESPUÉS de instalar el framework.** Es el error que mata la
  fase entera. Con Quasar ya en el proyecto, tus tests de regresión describen el
  comportamiento **post-migración** — y entonces no protegen nada, solo certifican
  lo que acabas de hacer, incluidos los bugs. La red se teje **antes del salto**,
  o no es red.
- **Testear lo que vas a borrar.** Escribir un test precioso para el `<select>` de
  estado que en Q3 se convierte en un `QSelect` dentro de un slot. Trabajo tirado.
  Testea el **efecto** del select (las filas se reducen), no el select.
- **"Ya que estoy, arreglo esto"**: el bug del `id` que arrastra el payload, el
  filtro que no busca en la descripción, el mensaje de error feo. **NO.** Arreglar
  y migrar en el mismo commit es garantizar que cuando algo falle no sepas cuál de
  los dos fue. Anótalo en el checklist. Se arregla **después**, con la red puesta —
  y entonces es un cambio de cinco minutos con test rojo→verde.
- **Confundir cobertura con protección.** Puedes tener 90% de coverage y cero red:
  si todos esos tests miran clases CSS, en Q3 tienes 90% de coverage en rojo y
  cero información. **La pregunta no es cuánto cubres, es qué pasa cuando cambias
  la implementación.**
- **El helper que no existe**: copiar `findAll("tbody tr")` en doce tests en vez
  de escribir `rowCount()` una vez. El día de la migración, esos doce sitios son
  doce oportunidades de equivocarse y una tarde perdida. **El helper es la junta
  de dilatación de tu suite.**
- **Mockear el store real en vez de construir uno de juguete.** Si importas el
  store de producción, tus tests de vista fallan cuando cambia el store — y el
  store **no se migra**. Ruido puro. Doble de la vecina de abajo, siempre.
- **Olvidar el `.then()` tras `setValue`/`trigger`** en VTU 1.x: el DOM no se ha
  actualizado todavía y el `expect` mira el render viejo. Verde falso, la tercera
  aparición de la trampa (F3 → F11 → aquí). Si un test de filtrado **nunca** falla
  aunque rompas el filtro, es esto. Siempre es esto.
- **Snapshot testing "para capturar el antes"**: suena perfecto y es una trampa
  perfecta. El diff de 400 líneas en la primera migración se resuelve con `-u` sin
  mirar, y acabas de certificar tu propia rotura.
- **No correr la suite antes de empezar.** Arrancar una migración con dos tests
  rojos "que ya estaban ahí" es empezar con la alarma desconectada. Verde total o
  no se sale de esta fase.

---

## 🧪 Ejercicios (28)

**🟢 Fácil (1–8)**

1. Crea `tests/unit/regression/` con su `README.md` (el contrato). Commitea eso
   solo, con el mensaje `chore: red de seguridad pre-migración`. Que quede en el
   historial **antes** que cualquier línea de Quasar.
2. Siembra los `data-testid` del dashboard y del `TicketForm`. Corre la app y la
   suite de F11: **todo igual, todo verde**. Escribe una línea sobre por qué ese
   "no pasó nada" era el resultado deseado.
3. Copia el `fixtures.js` de la fase y agrégale un quinto ticket cuyo `assignee`
   sea `null` en vez de `""`. Corre el dashboard. ¿Cambia algo? Documenta la
   diferencia entre `""` y `null` en este modelo. (Spoiler: hoy nadie la maneja.)
4. Escribe el test de "el dashboard despacha `tickets/fetchTickets` al montar" tú
   solo, sin mirar. Es el test más importante de la ruta y tiene que salirte de
   memoria.
5. El inventario de la vergüenza: lista los 6 specs que F11 te dejó y marca, al
   lado de cada uno, **si Q2/Q3 lo van a poner rojo**. (Pista: la columna te va a
   salir entera en "no".) Luego lista los 4 componentes que Q2/Q3 **van a
   reescribir** y marca cuáles tienen test. Dos columnas, diez líneas, y tienes
   la justificación entera de esta fase en un papel.
6. Rompe el `&&` de `filteredTickets` (cámbialo por `||`) y corre la suite de
   regresión. ¿Rojo? Bien. Revierte. Si salió verde: **tienes un agujero**, y el
   ejercicio real es taparlo.
7. Escribe el test de contrato de `deleteTicket` (DELETE `/tickets/:id`) sin
   mirar el ejemplo. Es de tres líneas y es la mitad de un incidente evitado.
8. Añade a `ticketForm.spec.js` el test del borde exacto de la descripción: 10
   caracteres acepta, 9 rechaza. Los bordes, siempre los bordes.

**🟡 Intermedio (9–17)**

9. **Haz el ejercicio 22 de F11 que te saltaste** (el `mount` de `TicketsView` con
   el store real y el servicio mockeado) — pero escríbelo **como lo habrías escrito
   antes de leer esta fase**: con `findAll("tbody tr")`, con `.table-hover`, con
   selectores por posición. Sin trampa, de verdad. Ahora aplícale el veredicto de
   la tabla de la sección 🅠, aserción por aserción, y reescríbelo. Compara ambas
   versiones lado a lado y anota cuántas aserciones sobrevivieron intactas. **Ese
   porcentaje es lo que Q0 te acaba de ahorrar**, medido con tus propias manos.
10. Escribe el test de regresión del **detalle del ticket** (`TicketDetailView`):
    contrato con el servicio/store, los tres estados, el 404 (ticket que no
    existe). No está en la fase; te toca a ti.
11. Escribe el test de regresión del **borrado con confirmación** (F5): mockea
    `window.confirm` (`jest.spyOn(window, "confirm")`), verifica que si devuelve
    `false` **no** sale el DELETE, y si devuelve `true` sí. La confirmación es
    comportamiento, no adorno.
12. El helper `rowCount()` está en `dashboard.spec.js`. **Sácalo a
    `helpers/dom.js`** junto con `fill()`. Justifica en tres líneas por qué todo
    el contacto con el DOM debe vivir en un solo archivo antes de una migración.
    (Esta es la respuesta que en Q3 vale una tarde.)
13. Congela el **orden** de los tickets: hoy llegan de la API ya ordenados
    (`_sort=createdAt&_order=desc`) y el dashboard no reordena. Escribe el test
    que afirme que la primera fila es el ticket más reciente. Luego responde: en
    Q3, `QTable` **ordena por su cuenta**. ¿Este test es una red o una trampa?
    Argumenta y decide si lo dejas.
14. `TicketsSummary`: escribe su test de regresión afirmando **los cuatro
    conteos** por su `data-testid`, sin tocar `.card` ni `<h2>`. Y luego el caso
    borde: lista vacía → cuatro ceros, no cuatro huecos.
15. Verde falso deliberado: en el test de "la búsqueda reduce las filas", **quita
    el `.then()`** tras el `setValue`. Rompe el filtro a propósito. Confirma que
    el test **pasa igual**. 😱 Restaura y deja el escalofrío en un comentario. (Es
    el ejercicio 8 de F11, ahora con la migración de por medio: aquí un verde
    falso te manda a producción con la tabla rota.)
16. `beforeRouteLeave` del wizard (F6): ese `window.confirm` de "tienes un ticket
    a medias" es comportamiento puro y nadie lo ha testeado nunca. Escríbelo. No
    se migra en la ruta, pero el ejercicio 🔴 de Q4 sí lo toca — y entonces
    querrás tener esto.
17. Escribe el test que verifica que `TicketCreateView` **arma el payload
    completo**: `formData` + `status:"open"` + `reporter` (del getter de auth) +
    `createdAt`. Mockea el servicio y afirma el objeto que le llega. Ese payload
    es una regla de negocio y hoy vive suelta en una vista.

**🟠 Difícil (18–23)**

18. **La auditoría de F11, en dos ejes.** Recorre los 6 specs de `tests/unit/` y
    clasifica **cada aserción** en dos dimensiones, que **no** son la misma:
    - *acoplamiento*: 🟢 sobrevive a cualquier framework · 🟡 sobrevive con
      `data-testid` · 🔴 cemento;
    - *pertinencia*: ✅ vigila algo que Q2/Q3 van a tocar · ⬜ **no está mirando**.

    Entrega `TEST-AUDIT.md` con la matriz. Y ahora la parte que importa: **la
    mayoría de tus aserciones va a caer en 🟢⬜** — impecables *y* ciegas. Escribe
    tres párrafos sobre por qué esa casilla es la más peligrosa de las cuatro, y
    por qué una suite entera de 🟢⬜ es exactamente lo que produce la frase *"pero
    si todos los tests pasaban"* en un post-mortem. Este documento es el entregable
    más valioso de la fase: es tu suite mirándose al espejo y descubriendo que
    estaba mirando a otro lado.
19. La **matriz de riesgo de la migración**: por cada archivo que Q2/Q3 van a
    tocar, una fila con (a) qué tests lo cubren, (b) qué comportamiento **no** está
    cubierto, (c) qué pasaría en producción si eso se rompiera en silencio.
    Ordénala por riesgo. Los tres primeros: **escribe hoy los tests que faltan.**
20. **Testea lo que el dashboard NO hace.** Aserciones negativas para congelar
    ausencias: no hay paginación (todos los tickets se pintan, sean 4 o 400), no
    hay ordenamiento por columna (clic en el header no hace nada), no hay
    selección múltiple. En Q3, `QTable` trae **las tres de fábrica**. Estos tests
    se van a poner rojos — y ese rojo **es correcto y deseado**: es Quasar
    entregándote features que no pediste. Escribe en un comentario cómo distingues
    "un rojo que es una feature nueva" de "un rojo que es una regresión".
21. `LiveToast` + el plugin de socket (F8/F10): red de seguridad para el tiempo
    real. Mockea `socketService`, captura los handlers, invoca uno a mano con un
    ticket nuevo y verifica que (a) el store lo incorporó y (b) **el dashboard
    montado pinta la fila nueva**. Es el pegamento — la pieza que ningún test de
    capa cubre y que una migración de tabla puede romper sin tocarla.
22. **La red del panel de soporte** (F9), completa: master-detail, tomar ticket,
    máquina de estados, comentarios. **La vas a necesitar en Q3** (es el ejercicio
    🔴 de esa fase, y allí te la piden sin guía). Escríbela ahora, con la fase
    fresca, en vez de a las 11pm con `QTable` a medio migrar.
23. `jest.config.js`: configura un script `test:regression` que corra **solo**
    `tests/unit/regression/`. Añade `test:regression -- --watch` a tu flujo. En
    Q2/Q3 vas a correr esa suite cincuenta veces al día y no quieres esperar a la
    de F11 cada vez. Mide cuánto ahorras.

**🔴 Muy difícil (24–28)**

24. **El sabotaje a ciegas (el kata definitivo).** Pide a alguien (o a tu yo de
    dentro de una semana, con un script) que introduzca **tres regresiones**
    sutiles en el dashboard o el CRUD, sin decirte cuáles: p.ej. el filtro deja de
    ser case-insensitive, el `_order` pasa a `asc`, `TicketForm` emite con
    prioridad vacía. Corre **solo** la suite de regresión. ¿Las caza las tres? Por
    cada una que se escape, escribe el test que faltaba **y** la línea de por qué
    no se te ocurrió. Ese "por qué" es la fase entera.
25. **La discusión e2e, con datos.** Este curso no trae Cypress, y una migración de
    UI es el caso de uso **canónico** del e2e (un test que hace clic en el
    navegador real es indiferente a si debajo hay `<b-table>` o `QTable` — es el
    único test verdaderamente inmune). Monta un Cypress mínimo aparte, escribe
    **un** test e2e del flujo "login → dashboard → filtrar → crear ticket", y
    escribe `E2E-NOTES.md` respondiendo: ¿cuánto costó? ¿Qué cazaría que tus
    unitarios no? ¿Qué NO cazaría? ¿Y por qué, aun así, los unitarios no se
    reemplazan? Sé honesto: puede que la conclusión sea que el e2e habría sido la
    mejor red y que este curso te dio la segunda mejor.
26. **El test de contrato contra json-server REAL** (retoma el ejercicio 26 de
    F11): levanta json-server en un puerto de test con un `db.json` fixture y
    valida que cada endpoint responde la **forma** documentada — códigos, campos,
    tipos. Córrelo como `test:contract`, separado. Y ahora la pregunta 💸: *"el
    backend no cambia"* — pero json-server **sí lo puedes cambiar tú**. Escribe qué
    disciplina te impone eso, y qué se rompe el día que el backend real no acepte
    el `id` que arrastras en el PATCH (el que congelaste en `ticketForm.spec.js`).
27. **La red mínima viable, cronometrada.** Te sueltan en un Vue 2 legacy ajeno de
    80.000 líneas y te piden migrar una pantalla a Quasar. Tienes **4 horas** para
    la red. ¿Qué escribes, en qué orden, y qué dejas sin cubrir a sabiendas?
    Entrega `RED-MINIMA.md`: el orden de escritura justificado, y —lo más
    difícil— **la lista de lo que aceptas no proteger**. Pista para el orden: el
    contrato con la API es el que más vida útil tiene por línea escrita. Este
    ejercicio es la promesa del curso hecha examen.
28. **El post-mortem invertido.** Escribe hoy, **antes** de tocar Quasar, el
    informe de incidente de la migración que aún no ha ocurrido: *"tras migrar el
    dashboard a QTable, en producción el filtro de estado dejó de combinarse con
    la búsqueda durante seis días"*. Reconstruye hacia atrás: ¿qué test faltó?
    ¿por qué la revisión de código no lo vio? ¿qué del `MIGRATION-CHECKLIST.md`
    se saltó alguien y por qué le pareció razonable en ese momento? Guárdalo. Al
    terminar Q3, ábrelo y compara con lo que realmente pasó. (Los que aciertan
    dan miedo.)

---

## 📚 Referencias

**Documentación oficial**

- Vue Test Utils **v1** (la de Vue 2): https://v1.test-utils.vuejs.org/
- VTU v1 — `mount` vs `shallowMount`: https://v1.test-utils.vuejs.org/api/#mount
- VTU v1 — API del wrapper (`find`, `setValue`, `trigger`, `emitted`):
  https://v1.test-utils.vuejs.org/api/wrapper/
- VTU v1 — testear con Vuex (`createLocalVue` + store):
  https://v1.test-utils.vuejs.org/guides/using-with-vuex.html
- VTU v1 — testear con Vue Router:
  https://v1.test-utils.vuejs.org/guides/using-with-vue-router.html
- VTU v1 — `nextTick` y el DOM asíncrono (**la trampa del verde falso**):
  https://v1.test-utils.vuejs.org/guides/#testing-asynchronous-behavior
- Jest — funciones mock y espías: https://jestjs.io/docs/mock-functions
- Jest — matchers (`toEqual`, `not.toHaveBeenCalled`): https://jestjs.io/docs/expect
- Jest — testing asíncrono: https://jestjs.io/docs/asynchronous
- Vuex 3 — testing (mutations, actions, componentes):
  https://v3.vuex.vuejs.org/guide/testing.html

**Lectura de fondo (el criterio, no la herramienta)**

- Testing Library — *Guiding Principles* (el origen de la doctrina
  "comportamiento observable"; la librería no es de este stack, la idea sí):
  https://testing-library.com/docs/guiding-principles/
- Kent C. Dodds — *Testing Implementation Details*:
  https://kentcdodds.com/blog/testing-implementation-details
- Martin Fowler — *Refactoring: the safety net of tests*:
  https://martinfowler.com/books/refactoring.html *(el capítulo 4, "Building
  Tests", es literalmente esta fase escrita en 1999)*

**Para el ejercicio 25 (e2e), si te animas**

- Cypress — Vue CLI plugin (el de la época): https://cli.vuejs.org/core-plugins/e2e-cypress.html

**Orden de lectura sugerido:** VTU con Vuex → el artículo de Kent C. Dodds
(quince minutos, y es el 80% del concepto 2 de esta fase) → volver al código.
Fowler solo si quieres saber que esto lo inventaron antes de que existiera
JavaScript moderno.

---

## 🚀 Cierre

No has escrito una línea de Quasar. No lo has instalado. No sabes todavía qué es un
boot file. Y sin embargo, esta es probablemente la fase más importante de la ruta.

Lo que te llevas:

- la distinción operativa entre **test normal** ("¿funciona?") y **test de
  regresión** ("¿sigue haciendo lo mismo?"), y la definición que las separa: *un
  test de regresión válido puede pasar en verde con dos implementaciones
  completamente distintas por debajo*;
- **`data-testid` como contrato**: el ancla que tú pones, tú mantienes, y que
  sobrevive a que cambie todo lo demás;
- los **dos contratos que no se cruzan** — con el store y con la API — convertidos
  de principio de arquitectura en aserción ejecutable;
- **los helpers como junta de dilatación**: `rowCount()` y `fill()` concentran todo
  el contacto con el DOM en dos funciones. Cuando el DOM cambie —y va a cambiar—
  tocas dos funciones, no treinta tests;
- la disciplina que separa una migración de un incendio: **congelar primero,
  arreglar después**. Todo lo que no te gusta del código actual está anotado en el
  checklist y **sigue sin arreglar**. Eso no es pereza: es la única forma de saber,
  cuando algo se rompa, quién te lo rompió;
- y la lección que no venía en el guion, la que te dio F11 sin querer:
  **cobertura no es protección.** Tenías seis specs impecables y cero red sobre lo
  que ibas a borrar. Una suite verde no dice que tu sistema esté a salvo — dice que
  tus tests están contentos. **La pregunta correcta nunca es cuántos tests tienes.
  Es cuáles se pondrían rojos si reescribes esta pantalla.**

La señal de que quedó bien:

> "puedo reescribir el dashboard entero con otro framework, y sé —sin abrir el
> navegador, en once segundos— si sigue haciendo lo que hacía ayer.
> Y cuando un test se ponga rojo, sabré si el problema es mi código
> o era mi test. Y si NINGUNO se pone rojo, sabré que es porque están mirando,
> no porque estén ciegos."

Y la pregunta que abrió la fase, ahora con respuesta — y con una hermana que no
esperabas:

> *¿Rompiste el comportamiento, o tu test era una porquería acoplada al DOM?*
>
> **Ahora tienes cómo saberlo.** Que es exactamente lo que no tenías ayer.
>
> Y la que aprendiste por el camino: *¿tu suite está en verde porque todo está
> bien… o porque no está mirando?*

**💸 La deuda de la fase, para que no se te olvide:** *"El backend no cambia. Si
tu test de regresión toca la API real y falla, el problema es tuyo."*

**Siguiente parada:** 📖 **Q1 — Leer Quasar**. Todavía sin migrar nada, todavía sin
tocar el Mini Jira. Reconocimiento puro: qué es Quasar de verdad (no es "un
framework de formularios"), dónde vive lo que antes estaba en `main.js`, qué
demonios es un boot file, y por qué `QLayout > QPageContainer > QPage` no es un
capricho sino una obligación. Ya tienes red. Ahora aprende a leer el framework al
que vas a saltar.
