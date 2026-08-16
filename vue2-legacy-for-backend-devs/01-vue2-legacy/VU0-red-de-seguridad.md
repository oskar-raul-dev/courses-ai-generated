# 🛡️ VU0 — La red de seguridad

> **Prerequisito duro: F11 (Testing).** Si no tienes Jest corriendo, esta fase no
> existe. Vuelve.

> 🧩 **Núcleo común X0.** El ~85% de este capítulo es agnóstico al framework
> destino: sirve igual para Quasar, Vuetify o Nuxt. Lo específico de Vuetify vive
> encapsulado en las secciones marcadas **🅥**. Si vienes de la ruta Q y estás
> hojeando esto por curiosidad: el cuerpo lo reconocerás casi entero. **Salta a la
> 🅥. Ahí está lo que Quasar no te contó** — y esta vez no es una divergencia, son
> **dos**.

---

## 🎯 Propósito

Nadie migra lo que no puede verificar.

Estás a punto de borrar código que funciona. Vas a cambiar el `<div class="modal">`
con jQuery de F5 (el curso **no usa bootstrap-vue**, no hay `<b-modal>`) por un
`<v-dialog>`, la tabla de F4 por un `<v-data-table>`, y en el camino se van a caer
~150 líneas que alguien (tú) escribió con cariño. La pregunta que te va a perseguir
durante toda la ruta es una sola:

> **"¿esto sigue haciendo lo mismo que hacía ayer?"**

Y hay exactamente dos formas de responderla. Una es abrir el navegador y hacer clic
durante veinte minutos, cruzando los dedos por no haberte olvidado del caso raro.
La otra es `npm run test:unit` y mirar el color.

Esta fase construye la segunda. **Antes de tocar Vuetify.** Sin código del
framework, sin instalar nada, sin haber corrido todavía `vue add vuetify`. Primero
la red, después el salto.

Y hay una segunda lección, más incómoda, que llega gratis: **la migración va a
auditar tus tests de F11**. Ábrelos: son seis, están bien escritos, y **ninguno se
va a poner rojo cuando reescribas el dashboard entero.** No porque sean a prueba de
balas — porque `TicketsView`, `TicketsTable` y `TicketForm` no tienen un solo test.
En F11 eso eran los ejercicios 🟠, los opcionales. Los que la regla del curso te
dejaba saltarte.

Traducción: **la única parte del Mini Jira que no tiene red es exactamente la que
vas a borrar.** Esta fase existe para eso.

> La regla de la fase: un test de regresión describe lo que el sistema **hace**, no
> cómo está **hecho**. Si tu test conoce la clase CSS, no está protegiendo el
> comportamiento: está protegiendo el HTML — y el HTML es justo lo que vas a tirar.

Pero hay un detalle que hace a **esta** red distinta de la de Quasar, y conviene
saberlo desde el minuto uno para no escribir la red dos veces:

> ### En Vuetify, la red de seguridad no solo tiene que ignorar el framework viejo. Tiene que sobrevivir a una **exigencia** del framework nuevo que no existe en Quasar: **el `<v-app>` obligatorio.**

Eso es la segunda mitad de esta fase, y es 🅥 pura. Quédate con la idea; el
concepto entero llega en su sección.

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
- 🅥 **una decisión escrita, hoy, sobre el problema del `<v-app>`**: cómo vas a
  montar tus componentes en VU2/VU3 sin que el test se acople al framework destino
  ni reviente cuando Vuetify exija un `v-app` ancestro. No es código Vuetify — es
  **anticipación documentada**. Es lo que separa esta fase de Q0;
- y el criterio para responder, sin ideología, a la pregunta que abre la fase.

## 🚫 Qué NO entra todavía

- **Vuetify.** Cero. No se instala, no se importa, no se menciona en el código.
  Esta fase corre contra el Mini Jira a pelo tal como está hoy;
- **el `<v-app>` como código real.** Lo vamos a *anticipar* — vas a saber por qué
  te va a doler y vas a dejar por escrito cómo lo resolverás. Pero no montas ni un
  `v-app` funcional aquí: no hay Vuetify que lo provea todavía. Anticipar el
  problema ≠ resolverlo con el framework puesto;
- e2e / Cypress: sería la red ideal para esto (una migración de UI es el caso de
  uso canónico del e2e) pero está fuera del stack del curso. Se discute en el
  ejercicio 25 y se deja como deuda honesta;
- visual regression testing (Percy, snapshots de imagen): la maquetación **va a
  cambiar a propósito** — y con Vuetify cambia *más* que con Quasar, porque el
  theming reescribe colores enteros. Un test que grite "el pixel se movió" es ruido
  puro aquí;
- refactorizar el código de producción "para que sea más testeable": si algo no se
  puede testear sin tocarlo, **anótalo, no lo toques**. Es información, no tarea;
- tests nuevos de *funcionalidad*: no es momento de arreglar los agujeros de
  cobertura de F11. Regresión es congelar lo que hay.

---

## 🧠 Concepto 1: test normal vs test de REGRESIÓN

Se escriben con las mismas herramientas y se ven casi iguales. Pero responden
preguntas distintas, y confundirlas es lo que hace que una migración se vaya de las
manos.

| | 🧪 Test normal (F11) | 🛡️ Test de **regresión** (VU0) |
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

La fila que hay que tatuarse es la penúltima. Un test normal puede permitirse mirar
un poco por dentro; a nadie le explota nada si `TicketStatusBadge.spec.js` comprueba
la clase `badge-danger`, porque ese componente no se va a mover.

Un test de regresión de migración **no puede permitirse nada de eso**, porque la
implementación entera es lo que está en juego. Es la definición operativa:

> **Un test de regresión válido para migrar es aquel que puede pasar en verde con
> dos implementaciones completamente distintas por debajo.**

Si tu test no cumple esa frase, no es red de seguridad: es cemento.

### El corolario incómodo

De F11 heredas una suite. **Parte de ella no sirve para esto.** No porque esté mal
escrita — sirve perfectamente para su propósito, que era "¿funciona?". Pero para
"¿sigue haciendo lo mismo *con otro framework debajo*?" hay tests tuyos que van a
mentir.

Y "mentir" aquí tiene dos direcciones, ambas caras:

- **falso rojo** 🔴: el test falla, tú no rompiste nada. Solo cambió el DOM. Te hace
  perder una tarde y, peor, te entrena a ignorar el rojo. *"Ah, ese siempre falla."*
  Ahí murió tu suite.
- **falso verde** 🟢: el test pasa, tú rompiste algo. Pasa cuando el test verifica la
  capa equivocada — por ejemplo, comprueba que el servicio se llamó, pero no que el
  resultado llegó a la pantalla. Este es el que te manda a producción.

El objetivo de esta fase es una suite donde **rojo signifique rojo**.

> 🅥 **Y un aviso que Quasar no necesita dar:** en Vuetify hay una tercera clase de
> falso rojo, y es traicionera precisamente porque **no es culpa de tu código ni de
> tu selector**. Es culpa de que montaste un componente Vuetify **sin `<v-app>`**.
> El test se pone rojo, tú miras tu código, tu código está bien, tu selector está
> bien, y pierdes la tarde buscando un bug que no existe. Lo tratamos en la 🅥 — pero
> que sepas desde ya que **"rojo sin culpa" tiene, en esta ruta, una causa extra.**

---

## 🧠 Concepto 2: comportamiento observable, no estructura

"Comportamiento observable" suena a filosofía. Es operativo, y se decide con una
pregunta:

> **¿esta aserción le importa a alguien que no seas tú?**

El usuario del Mini Jira no sabe que existe una clase `.table-hover`. Le importa que
**al escribir "impresora" queden menos filas**. Al backend no le importa que uses
`axios.get`; le importa que **llegue un GET a `/tickets` con `_sort`**.

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

Un `data-testid` es un atributo que **existe solo para los tests** y que tú prometes
mantener aunque cambies todo lo demás. Es un contrato explícito contigo mismo:

```html
<!-- Bootstrap, hoy -->
<input class="form-control" data-testid="ticket-search" v-model="search" />

<!-- Vuetify, mañana -->
<v-text-field data-testid="ticket-search" v-model="search" />
```

**El test no cambia:**

```js
wrapper.find('[data-testid="ticket-search"]').setValue("impresora");
```

Comparado con las alternativas:

| Selector | Sobrevive a la migración | Comentario |
|---|---|---|
| `.form-control` | ❌ | clase de Bootstrap. Vuetify no la pone |
| `input[type=text]` | ⚠️ | `v-text-field` sí renderiza un `<input>`… hasta que le pones `type="textarea"` o lo cambias por `v-textarea` |
| `.col-md-6 > div:nth-child(2)` | ❌❌ | esto ya está roto, solo que aún no lo sabes. **Y en Vuetify duele doble:** `v-text-field` envuelve el `<input>` en dos o tres `<div>` de estructura interna. Tu `nth-child` no sobrevive ni al render |
| `wrapper.vm.search = "x"` | ❌ | estás testeando la implementación, no la UI |
| `[data-testid="ticket-search"]` | ✅ | **es un contrato. Lo pones tú, lo mantienes tú** |

> ⚠️ **La objeción de siempre:** *"pero es contaminar el HTML de producción con
> cosas de test"*. Sí. Ese es el precio, y es baratísimo: un atributo que no pesa,
> no renderiza y no rompe nada, a cambio de una suite que no se cae con cada
> refactor. (Y si te molesta de verdad: existen plugins de Babel que los eliminan en
> build de producción. En 2020, casi nadie se molestaba.)

> 🅥 **Un matiz Vuetify sobre dónde cae el `data-testid`.** Cuando pongas
> `data-testid` en un `<v-text-field>`, Vuetify lo cuelga del **elemento raíz del
> componente** (un `<div>` contenedor), **no del `<input>` interno**. Para la mayoría
> de aserciones (`.exists()`, `.text()`) da igual. Pero `setValue` necesita el
> `<input>` de verdad. Esto no es un problema de VU0 —hoy tus campos son `<input>`
> a pelo y el `data-testid` cae justo donde quieres— pero es **exactamente el tipo de
> detalle que en VU2 te va a hacer tocar el helper `fill()`, no los tests.** Guárdalo.

**Regla de dónde ponerlos:** en los **puntos de interacción** (inputs, botones,
filas clicables) y en los **puntos de aserción** (mensajes de error, contadores, el
contenedor de la lista). No en cada `<div>`: un `data-testid` por cada nodo es volver
a testear el DOM, solo que con mejor letra.

---

## 🧠 Concepto 3: los dos contratos que de verdad importan

Tu aplicación tiene fronteras. Una migración de UI **no debería cruzar ninguna**. Y
eso, que es una afirmación de arquitectura, se convierte aquí en algo mucho mejor:
**una aserción ejecutable**.

```
   ┌──────────────────────────────────────────┐
   │  CAPA DE PRESENTACIÓN                    │
   │  Bootstrap hoy · Vuetify mañana          │  ← TODO esto se puede caer
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

**Contrato 1 — con el store.** La vista, sea cual sea el framework, tiene que seguir
despachando lo mismo. Si `TicketsView` despacha hoy `tickets/fetchTickets` al
montarse, la versión Vuetify debe despachar `tickets/fetchTickets` al montarse. Si la
nueva tabla te obliga a despachar otra cosa (spoiler: **VU3 te va a obligar** —
`v-data-table` quiere gestionar la paginación con `:options.sync`, y esa pelea con tu
Vuex es la fase entera), el test rojo **es la alarma correcta funcionando
correctamente**. No lo silencies: negócialo.

**Contrato 2 — con la API.** El servicio manda `GET /tickets` con
`{_sort: "createdAt", _order: "desc"}`. Punto. Cambiar de framework de UI **no es
excusa** para que salga otra petición. Y este contrato es el más sagrado de los dos,
porque del otro lado hay alguien que no está en tu equipo.

**💸 Deuda:** *"El backend no cambia. Si tu test de regresión toca la API real y
falla, el problema es tuyo."*
En este curso el "backend" es json-server y puedes editarlo a mano — lo que crea la
tentación exacta que hay que matar: *"ajusto el mock y ya"*. En producción no hay
ajuste: hay un equipo de backend, un contrato firmado y un ticket de tres sprints. **El
test de contrato existe para que no aprendas eso en producción.** (Y ojo con VU3: ahí
`v-data-table` server-side espera `server-items-length`, pero json-server te manda el
total en el header `X-Total-Count`. La tentación de "ajusto json-server para que
mande el total en el body" es la misma sirena. **No.** El contrato con la API que
congelas aquí es el que te dice, en VU3, que el problema es de mapeo en tu front, no
del backend.)

---

## 🧠 Concepto 4: qué NO testear (y por qué duele no hacerlo)

Esta es la sección que la gente se salta y luego sufre. La lista de arriba dice *qué*
no testear. Aquí va el *por qué*, caso por caso, porque cada uno tiene su sirena:

- **Clases de Bootstrap** (`.badge-danger`, `.table`, `.alert-danger`) — la sirena es
  que son fáciles y están ahí. Y funcionan hoy. Y mañana `v-chip` renderiza
  `.v-chip` con el color metido por el **tema en JS** (no por una clase que puedas
  leer), y tienes 14 tests rojos que no significan nada. *Test lo que la clase
  significa:* si `badge-danger` significa "abierto", asegura el **texto** "Abierto",
  no la clase.
- **Etiquetas HTML** (`wrapper.findAll("tr")`) — la sirena es que "un ticket es una
  fila, eso no va a cambiar". Va a cambiar. `v-data-table` renderiza `<tr>`, sí…
  hasta que le pones scoped slots o un breakpoint que lo pinta como tarjetas. **Cuenta
  con `data-testid`, no con etiquetas.**
- **Orden y estructura del DOM** (`:nth-child`, `.at(2)`, `> div > span`) — la sirena
  es que es lo que autocompleta el editor. Es el selector más frágil que existe y no
  protege nada. Y en Vuetify es **peor que en Bootstrap**: cada `v-text-field`,
  `v-select` y `v-btn` trae su propia envoltura de `<div>` internos. Un `nth-child`
  que hoy funciona sobre un `<input>` pelado no sobrevive al primer render de Vuetify.
- **Estilos y colores** — no son comportamiento. Son gusto. Y en la migración van a
  cambiar **a propósito**. Con Vuetify, además, el color deja de vivir en una clase y
  pasa a vivir en el **tema en JS** (`theme.themes.light.primary`) — o sea que ni
  siquiera podrías leerlo con `.classes()` aunque quisieras. Doble motivo para no
  tocarlo.
- **Nombres internos** (`wrapper.vm.filteredTickets`, `wrapper.vm.loading`) — la
  sirena es que es cómodo: acceso directo, sin DOM, sin async. Y es un falso verde
  ambulante: `filteredTickets` puede ser perfecto mientras la tabla no lo pinta.
  **Testea lo que se ve, no lo que se calcula.** (Excepción única y honesta: testear
  el computed *como función pura* — pero entonces sácalo a `utils/` y testéalo ahí,
  sin montar nada. La testeabilidad detectando diseño, otra vez: F11, concepto 1.)
- **Snapshots del HTML** (`toMatchSnapshot()`) — la sirena es que es una línea y
  "captura todo". Captura **todo**, ese es el problema: y con Vuetify el HTML
  renderizado es **enorme** (cada componente mete decenas de `<div>` de estructura),
  así que el diff de la primera migración no son 400 líneas rojas, son 2.000. Aprietas
  `-u` sin mirar. Un snapshot en una migración a Vuetify es un test que se
  autodesactiva a lo grande.

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
      mount.js               ← 🅥 el helper que absorbe el problema del <v-app>
```

Fíjate en ese último archivo, `helpers/mount.js`. En Q0 no existe. Es la respuesta
física al problema del `<v-app>`, y por eso esta fase tiene un helper más que su
gemela. Llegamos a él en la 🅥.

La separación no es cosmética. Es una regla operativa que puedes leer en un `git
diff`:

> **Si un commit de la migración toca `tests/unit/regression/`, es sospechoso por
> defecto y necesita justificación en el mensaje del commit.**

`tests/unit/regression/README.md`:

```md
# Red de seguridad — NO TOCAR durante la migración

Estos tests describen el comportamiento del Mini Jira **antes** de Vuetify.

Regla: durante VU1–VU4 estos archivos NO se editan.
Si uno se pone rojo, hay exactamente dos respuestas válidas:

1. Rompiste el comportamiento → arregla el CÓDIGO.
2. El test estaba acoplado al DOM viejo → arréglalo, y ANOTA POR QUÉ
   en MIGRATION-CHECKLIST.md. Cada edición aquí es una confesión.

Excepción prevista (y SOLO esta): los helpers de helpers/ SÍ se tocan.
Concretamente helpers/mount.js, cuando <v-app> entre en juego (VU2/VU3).
Eso NO es tocar un test: es tocar la junta de dilatación, que existe
precisamente para absorber ese cambio en UN sitio. Ver la sección v-app.

Lo que NO es una respuesta válida: borrar un test, .skip()arlo, o
"ajustarlo hasta que pase".
```

### Sembrar los `data-testid` (el único cambio a código de producción)

Antes de escribir un test, siembra las anclas. Es el **único** momento de la ruta en
que tocas el código a pelo, y es un cambio de cero riesgo.

> 🔒 **Contrato de IDs — el prefijo es `ticket-`, no `form-`.** Los `data-testid` que
> siembras aquí son un **contrato que VU2 y VU3 van a reutilizar tal cual**. El
> formulario usa exactamente estos: `ticket-title`, `ticket-description`,
> `ticket-priority`, `ticket-assignee`, `ticket-submit`, `ticket-cancel` (más los
> `-error` por campo). Cuando en VU2 el `<input class="form-control">` se convierta en
> `<v-text-field>`, el test sigue encontrando el campo **porque el `data-testid` no
> cambió**. Si aquí los llamas `form-*` y en VU2 los declaras `ticket-*` (o al revés),
> toda la suite del formulario se te pone roja en VU2 por un renombre — justo el ruido
> que esta fase existe para evitar. **Un solo prefijo, `ticket-`, en toda la ruta.**

> ⚠️ **Esto asume que hiciste el refactor de F10.** El botón de reintentar llama a
> `fetchTickets()` (la action mapeada), no a `loadTickets()` (el method local de F4).
> Si tu `TicketsView` todavía tiene `loadTickets` y `tickets` en `data()`, no hiciste
> F10 — y entonces el "contrato con el store" que esta fase te pide congelar **no
> existe todavía**. F10 no es opcional para la ruta: es donde nace el contrato que VU3
> va a poner a prueba (y en Vuetify esa prueba es más dura, porque `v-data-table`
> pelea por el control de la paginación). Vuelve, refactoriza, y regresa.

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

`components/tickets/TicketsSummary.vue` — VU3 también se lo lleva, y sin ancla no hay
forma de afirmar los conteos sin agarrarse de `.card` y de `<h2>`:

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

**🔎 Qué hace:** nada. Literalmente. Los `data-testid` no tienen efecto en runtime —
Vue los pasa al DOM como atributos y ahí se quedan. Corre la app: idéntica. Corre la
suite de F11: verde. Ese "nada" es la propiedad más valiosa del cambio.

**✅ Buenas prácticas aplicadas:**
- **Anclas dinámicas por id** (`'ticket-row-' + ticket.id`): permiten afirmar *"la
  fila del ticket 3 está / no está"* sin depender del orden. Los tests que dependen
  del orden mueren en cuanto `v-data-table` ordena por defecto por otra columna.
- Nombres con **prefijo de dominio** (`ticket-`), no de tecnología. Un
  `data-testid="bootstrap-table"` sería un chiste cruel en tres fases.
- Se anclan **puntos de interacción y de aserción**. Nada más. El `<thead>` no lleva
  ancla: nadie va a afirmar nada sobre él.

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
> `description`), tus números **no van a ser 2 y 1**. Y esa es exactamente la
> lección: **el fixture congela TU comportamiento, no el mío.** Ajusta los conteos a
> lo que tu `filteredTickets` hace **hoy**, y escribe en un comentario por qué hace
> eso. Si copias mis números sin correr la suite, acabas de escribir una red que
> protege un sistema que no es el tuyo.

**🔎 Qué hace:** el fixture **es** el diseño del test. Cuatro tickets elegidos para
que ningún filtro pueda pasar por casualidad: si el filtro de texto ignorara el de
estado, el caso combinado devolvería 2 en vez de 1 y el test lo caza.

**✅ Buenas prácticas aplicadas:** los datos son **inventados**, no copiados de
`db.json`. Un fixture pegado de datos reales trae 9 campos que a nadie le importan y
se rompe cuando el modelo cambia en un campo que el test ni miraba (F11, errores
comunes: *"fixtures gigantes copiados de datos reales: frágiles y ruidosos"*).

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
consume (`mapState`, `mapGetters`, `mapActions`) pero sin lógica real.

**✅ Buenas prácticas aplicadas:**
- **Cada capa se prueba contra un doble de su vecina de abajo** (F11). Aquí la vecina
  es el store.
- El store falso **hereda la deuda de forma**: si mañana renombras el getter, este
  helper truena y te enteras. Es un test de contrato disfrazado de helper.
- Un solo lugar donde tocar cuando el contrato cambie a propósito. Doce tests, un
  helper.

### 🅥 Helper 3 — el que Quasar no necesita: `tests/unit/regression/helpers/mount.js`

Este helper es el corazón físico de la divergencia Vuetify. **Todavía no hace nada
distinto** de un `mount` normal — no puede, no hay Vuetify instalado. Pero **existe
desde hoy**, y todos los tests montan a través de él, precisamente para que el día que
`<v-app>` entre en juego (VU2/VU3) se toque **este archivo y solo este archivo**.

```js
import { mount, createLocalVue } from "@vue/test-utils";

// 🅥 EL PUNTO DE LA FASE.
// Hoy esto es un mount() con envoltura vacía. Mañana (VU2/VU3) es el ÚNICO
// sitio donde <v-app> y el plugin de Vuetify entrarán en juego.
//
// La regla: los tests NO llaman a mount() directo. Llaman a mountView().
// Así, cuando Vuetify exija un v-app ancestro, se cambia AQUÍ:
//   - se registra Vuetify en el localVue
//   - se envuelve el componente en un <v-app> (con la técnica que se decida)
// ...y los veinte tests de dashboard.spec.js NO se enteran.
//
// Esto es la "junta de dilatación" del problema del v-app. Igual que rowCount()
// absorbe el cambio de <tr>, mountView() absorbe el cambio de "montaje aislado"
// a "montaje bajo v-app".

export function mountView(Component, options) {
  options = options || {};
  const localVue = options.localVue || createLocalVue();

  // --- ZONA VUETIFY (hoy vacía a propósito) ---------------------------
  // En VU2/VU3, aquí irá algo COMO:
  //   import Vuetify from "vuetify";
  //   localVue.use(Vuetify);
  //   const vuetify = new Vuetify();
  //   ...y el wrapping en <v-app> (ver la sección de abajo para el dilema).
  // HOY: nada. No hay Vuetify. Montamos el componente a pelo.
  // --------------------------------------------------------------------

  return mount(Component, Object.assign({}, options, { localVue: localVue }));
}
```

**🔎 Qué hace hoy:** literalmente un `mount()` con un `localVue` por defecto. Cero
magia. El valor no está en lo que hace hoy — está en que **existe el sitio** donde
mañana entrará Vuetify sin tocar un solo test.

**✅ Buenas prácticas aplicadas:**
- Es la misma doctrina que `rowCount()` y `fill()`: **concentrar en una función el
  punto que va a cambiar.** Aquí lo que va a cambiar no es un selector, es *el acto de
  montar*. Y en Vuetify ese acto **va a cambiar** por culpa del `v-app`. Adelantarse
  cuesta cinco líneas hoy; no adelantarse cuesta reescribir veinte tests en VU3.
- El helper deja el "hueco Vuetify" **documentado y vacío**. Un futuro tú (o quien
  herede el repo) lee el comentario y sabe exactamente dónde meter mano.

### Test 1 — el dashboard: `tests/unit/regression/dashboard.spec.js`

Fíjate: **no importa `mount` directo.** Importa `mountView` del helper. Esa es la
única diferencia estructural con el `dashboard.spec.js` de Q0 — y es toda la
divergencia hecha código.

```js
import { createLocalVue } from "@vue/test-utils";
import Vuex from "vuex";
import VueRouter from "vue-router";
import TicketsView from "@/views/TicketsView.vue";
import { makeTickets } from "./helpers/fixtures";
import { makeStore } from "./helpers/makeStore";
import { mountView } from "./helpers/mount"; // 🅥 el montaje pasa por aquí

function build(storeOverrides) {
  const localVue = createLocalVue();
  localVue.use(Vuex);
  localVue.use(VueRouter);

  // El filtro global de F4 vive en main.js, que aquí no corre.
  // Sin registrarlo, el template revienta con "Failed to resolve filter: formatDate".
  localVue.filter("formatDate", function (value) {
    return value ? String(value).slice(0, 10) : "";
  });

  const store = makeStore(storeOverrides);
  const router = new VueRouter({ routes: [] });

  // mount COMPLETO (no shallowMount): el comportamiento que protejo
  // ("al filtrar quedan N filas") vive en la COLABORACIÓN vista ↔ tabla.
  // Un shallowMount stubearía TicketsTable y no habría filas que contar.
  // 🅥 Y lo monto a través de mountView: hoy es transparente; en VU3 será
  //    donde el <v-app> se resuelva sin que este test lo sepa.
  const wrapper = mountView(TicketsView, {
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
      // ESTA es la aserción que debe sobrevivir a Vuetify.
      // No importa quién pinte la tabla: la vista pide los datos al store.
      expect(ctx.store.spies.fetchTickets).toHaveBeenCalledTimes(1);
    });

    it("el botón de reintentar vuelve a despachar la action", function () {
      const ctx = build({ error: "No se pudieron cargar los tickets." });

      ctx.wrapper.find('[data-testid="tickets-retry"]').trigger("click");

      // Se afirma QUÉ se despacha. NO con qué opciones de caché.
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
Bootstrap, a `<tr>`, a `.table` ni a `filteredTickets`. Reescribe la vista entera en
Vuetify y estos tests son válidos tal cual… *siempre que el `mountView` resuelva el
`v-app`.* Y ahí está la gracia: cuando lo resuelvas, lo harás en el helper, y este
archivo no cambia una coma.

**✅ Buenas prácticas aplicadas:**
- El helper `rowCount()` **encapsula el único punto de contacto con el DOM** para
  contar filas. Cuando la fila deje de ser un `<tr>`, se toca **una función**.
- **`mountView` en vez de `mount`**: la segunda junta de dilatación, la propia de
  esta ruta. `mount` directo aquí sería atarte a un montaje aislado que Vuetify no va
  a tolerar.
- `mount` en lugar de `shallowMount`, contra la regla de F11 — **y con motivo
  declarado**. El comportamiento a proteger vive en la colaboración vista↔tabla.
- `setValue` devuelve Promise en VTU 1.x: los `.then()` encadenados **son la única
  forma** de que el DOM esté actualizado antes del `expect`. Sin ellos: verde falso.
- `case-insensitive` está testeado explícitamente porque **es una decisión viva** (el
  `.toLowerCase()` del computed) que nadie documentó. Ahora sí.

### Test 2 — el formulario: `tests/unit/regression/ticketForm.spec.js`

```js
import { createLocalVue } from "@vue/test-utils";
import Vuelidate from "vuelidate";
import TicketForm from "@/components/tickets/TicketForm.vue";
import { mountView } from "./helpers/mount"; // 🅥 mismo montaje único

const localVue = createLocalVue();
localVue.use(Vuelidate); // sin esto, $v es undefined y el render explota

function build(props) {
  return mountView(TicketForm, {
    localVue: localVue,
    propsData: props || {}
  });
}

// El acto de "llenar el formulario", en un solo sitio.
// Cuando los campos sean v-text-field, se toca ESTO. Los tests no se enteran.
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
        .then(function () { return wrapper.find("form").trigger("submit"); })
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
        // NO se afirma su texto exacto (copy) ni su clase (Bootstrap).
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
fronteras**: lo que entra (props) y lo que sale (eventos). Vuelidate no aparece en una
sola aserción, y ese es el punto — **en VU2 vuelidate se va del proyecto entero**
(sale como dependencia, no solo cambia de componente), y este archivo tiene que seguir
en verde el día después.

**✅ Buenas prácticas aplicadas:**
- El helper `fill()` es el mismo truco que `rowCount()`: **un solo punto de contacto
  con el DOM**. Cuando los inputs sean `v-text-field` y `setValue` tenga que apuntar
  al `<input>` interno, se toca esa función. Veinte tests, un helper. *(En VU2 la vas
  a agradecer más que en Quasar: la envoltura de `v-text-field` es más profunda que la
  de `QInput`.)*
- Las reglas se testean por su **efecto** ("no emite"), no por su **mecanismo**
  (`$v.form.title.$invalid`). Un test que dice `expect(wrapper.vm.$v.$invalid)` se
  muere el día que `:rules` reemplace a vuelidate — y el comportamiento "título de 4
  letras no pasa" no habrá cambiado en absoluto. **Este es el archivo donde más se
  nota que testear el efecto y no el mecanismo era la decisión correcta**, porque VU2
  arranca el mecanismo de cuajo.
- **Los bordes exactos** (80 sí, 81 no) valen más que los casos felices.
- El test de "el payload arrastra `id` y `status`" **congela una rareza**. Se
  documenta, se congela, y se decide después — con la red puesta.

### Test 3 — el contrato con la API: `tests/unit/regression/ticketService.contract.spec.js`

Este archivo **es idéntico al de Q0.** No monta componentes, no conoce Vue, no sabe
qué es un `<v-app>`. Es el más portable de toda la ruta — y por eso es el mismo en las
tres.

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
      priority: "high", assignee: "agente1",
      status: "open", reporter: "user1", createdAt: "2020-03-10T09:00:00Z"
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
librería de tablas.

**✅ Buenas prácticas aplicadas:**
- **Este es el archivo con la vida útil más larga de toda la ruta.** No monta
  componentes, no conoce Vue, no sabe qué es un `<v-app>` — de hecho es el único test
  de la fase que **no pasa por `mountView`**, porque no monta nada. Va a seguir verde
  en VU4, y va a seguir verde si mañana alguien migra a Vue 3. Cuando alguien pregunte
  "¿qué test escribo primero en un legacy ajeno?": **este**.
- `expect(apiClient.put).not.toHaveBeenCalled()` es una aserción **negativa** que
  congela una decisión (PATCH parcial, no PUT total).
- El error se testea **propagándose**, no siendo tragado.

---

## 🅥 Divergencia Vuetify — aquí son DOS, no una

> Sección específica de la ruta VU. En Q0 hay **una** divergencia (los selectores de
> `.b-table`). Aquí hay **dos**: esa misma, **y una propia** que Quasar no tiene ni
> puede tener. La segunda es la mitad del valor de esta fase. Si vienes hojeando desde
> Q, **esto es lo nuevo**.

Antes de mirar a Vuetify, mira tu propia suite. Abre `tests/unit/` y haz el inventario
de lo que F11 te dejó:

```
tests/unit/
  ticketStats.spec.js        ← funciones puras (F7)
  ticketTransitions.spec.js  ← la máquina de estados (F9)
  store-tickets.spec.js      ← mutations y actions (F10)
  ticketService.spec.js      ← el servicio con apiClient mockeado (F3)
  TicketStatusBadge.spec.js  ← un badge
  StatusActions.spec.js      ← unos botones
```

Seis archivos. La pregunta incómoda:

> **¿Cuáles de esos seis se rompen cuando migres el dashboard a `v-data-table`?**

Cuéntalos. **Ninguno.** `ticketStats` no monta nada. `ticketTransitions` es una
función pura. `store-tickets` no sabe qué es un `<tr>`. El badge y los botones **no se
migran en esta ruta**.

Eso es una buena noticia. Y es, a la vez, **la peor noticia posible**:

> ### Tu suite de F11 no se va a poner roja durante la migración. Y no porque sea buena. Porque **no está mirando**.

`TicketsView`, `TicketsTable`, `TicketsSummary`, `TicketForm` — **las cuatro piezas
que VU2 y VU3 van a reescribir enteras** — no tienen un solo test en F11. Están, sí,
pero como **ejercicios 🟠** (F11 ej. 18 y 22), los opcionales. Si seguiste la regla del
curso al pie de la letra, llegas a VU0 **sin una sola línea de test sobre lo que estás
a punto de borrar.** No hiciste nada mal. El agujero es de diseño, y este es el momento
en que se paga.

Hasta aquí, **calcado a Q0.** Ahora empieza lo que Quasar no cuenta.

### 🅥 Divergencia 1 (la compartida con Q): tus selectores conocen Bootstrap

En VU3 vas a cambiar el dashboard por `v-data-table`, y —si hiciste el ejercicio 22 de
F11, o si el legacy ajeno al que llegues ya trae tests— te vas a encontrar con algo de
esta forma:

```js
// El test que un dev razonable escribe SIN pensar en migraciones.
it("pinta una fila por ticket", function () {
  const wrapper = mount(TicketsView, { /* store, router */ });

  expect(wrapper.findAll("tbody tr")).toHaveLength(4);
  expect(wrapper.find("table").classes()).toContain("table-hover");
});
```

El día de VU3 este test se pone **rojo**. `v-data-table` no renderiza `.table-hover`
(pone `.v-data-table`), y su `<tbody>` puede traer filas fantasma de "no data" o de
loading. Y ahí, delante del rojo, se abre **la primera pregunta de la fase**:

> ### ¿Rompiste el comportamiento, o tu test era una porquería acoplada al DOM?

Aserción por aserción:

| Aserción | Veredicto | Por qué |
|---|---|---|
| `findAll("tbody tr")).toHaveLength(4)` | 🟡 **medio culpable** | La intención ("hay 4 filas") es legítima y **hay que conservarla**. El selector no: asume `<table>` y cuenta filas de estructura de `v-data-table`. Con `[data-testid^="ticket-row-"]` habría sobrevivido |
| `classes()).toContain("table-hover")` | 🔴 **culpable** | No protege nada. Protege una clase de Bootstrap. **Bórralo sin remordimiento** |

Esta es **exactamente** la divergencia de Q0, con `v-data-table` en vez de `QTable`.
Misma lección, otro nombre. Si fuera lo único, esta fase sería un find&replace de la de
Quasar — y el curso te prometió que no lo sería.

No lo es. Sigue leyendo.

### 🅥 Divergencia 2 (la PROPIA de Vuetify): el `<v-app>` obligatorio

Esta no existe en Quasar. Y es un problema de una naturaleza distinta: no es que tu
*selector* esté acoplado. Es que **el framework destino exige una condición de montaje
que tu test actual no cumple** — y que, si la cumples mal, acoplas el test al framework
antes de tiempo.

**El hecho técnico, seco:** casi todo componente de Vuetify 2 asume que existe un
`<v-app>` como **ancestro raíz** en el árbol. `<v-app>` es el que monta el contenedor
de aplicación, el sistema de theming, los breakpoints, los overlays (`v-dialog`,
`v-menu`, `v-tooltip` se teletransportan ahí dentro). Si falta, Vuetify **no te lo dice
con un error claro**: unas veces avisa por consola (`[Vuetify] Unable to locate target
[data-app]`), otras simplemente no renderiza el overlay, otras revienta al acceder a
`$vuetify.breakpoint`. Es el "el modal no sale y no hay error" que ya te anunció el
bosquejo de la ruta.

Ahora crúzalo con cómo montas hoy tus tests de regresión:

```js
// Lo que haces HOY, y lo que hace todo VTU 1.x por defecto:
mount(TicketForm, { /* ... */ });   // ← monta el componente AISLADO. Sin ancestros.
```

`mount()` monta tu componente **solo**, en la raíz del árbol de test. No hay `v-app`
por encima. Hoy da igual: tu `TicketForm` es `<input>` a pelo, no necesita a nadie. **El
día de VU2, cuando ese `TicketForm` sea `<v-text-field>` + `<v-select>` + viva dentro de
un `<v-dialog>`, tu `mount()` aislado deja de ser suficiente.** El componente exige un
`v-app` que tu test no le da.

Y aquí está **la pregunta de la fase**, la que Quasar no plantea:

> ### ¿Cómo escribes HOY un test que sobreviva a la exigencia del `<v-app>` SIN acoplarte ya al framework destino?

Porque las dos salidas obvias son ambas trampas:

**Trampa A — "envuelvo en `<v-app>` desde ya".**
No puedes: **no hay Vuetify instalado en VU0.** Y aunque lo instalaras solo para el
test, acabas de meter el framework destino dentro de tu red de seguridad. El test dejó
de probar *el código a pelo* — prueba el código a pelo *ya envuelto en la
infraestructura de Vuetify*. Contamina la foto del "antes". Rompe la regla de oro de la
fase: **la red se teje antes del salto, sin el framework dentro.**

**Trampa B — "no envuelvo nada y ya me apañaré en VU2".**
Entonces el día de VU2 tienes veinte tests que hacen `mount()` directo, y **cada uno**
hay que ir a envolverlo en `v-app` a mano. Veinte ediciones dentro de
`tests/unit/regression/` — la carpeta que juraste no tocar. Cada edición es una
confesión en el checklist, y el `git diff` de la migración se llena de ruido justo
donde no debería haber ninguno.

**La salida real es la tercera, y es la que ya sembraste sin saberlo: `mountView`.**

Vuelve al helper `helpers/mount.js`. Hoy es un `mount()` transparente. Pero **es el
único sitio de toda la suite que sabe *cómo* se monta un componente.** El día de VU2, el
cambio del `v-app` entra **ahí dentro**, y en ningún otro lado:

```js
// helpers/mount.js — cómo se verá en VU2/VU3 (NO lo escribas hoy; es el plan)
import { mount, createLocalVue } from "@vue/test-utils";
import Vuetify from "vuetify";       // ← llega en VU1
import Vue from "vue";

Vue.use(Vuetify); // Vuetify no soporta bien createLocalVue; se registra en el Vue global

export function mountView(Component, options) {
  options = options || {};
  const vuetify = new Vuetify();

  // La técnica canónica de VTU 1.x para el v-app: NO se envuelve el componente
  // en un template <v-app><Component/></v-app> (eso obliga a un wrapper y
  // rompe emitted()/props). Se usa la opción `attachTo` + el div [data-app],
  // o el patrón oficial: montar con { vuetify } y crear el data-app a mano.
  const app = document.createElement("div");
  app.setAttribute("data-app", "true"); // esto es lo que Vuetify busca como raíz
  document.body.appendChild(app);

  return mount(Component, Object.assign({}, options, {
    vuetify: vuetify,      // ← inyecta $vuetify (theming, breakpoint)
    attachTo: app          // ← y le da el ancestro [data-app] que exige
  }));
}
```

**Lo que importa de ese bloque no es la técnica** (la aprenderás de verdad en VU2, con
Vuetify delante). Lo que importa es **dónde vive**: en el helper. Los veinte tests de
`dashboard.spec.js` y `ticketForm.spec.js` llaman a `mountView` y **no cambian ni una
coma** cuando esto entre. El `v-app` se resuelve en un archivo. La carpeta de regresión
—los tests de verdad— queda intacta. El `README.md` ya declaró que `helpers/mount.js`
es la única excepción prevista, y por eso lo es.

> ### La resolución del dilema, en una frase:
> **No envuelves en `v-app` hoy (Trampa A), ni lo dejas para veinte sitios mañana
> (Trampa B). Sacas el *acto de montar* a un helper HOY —vacío de Vuetify—, y mañana
> el `v-app` entra por esa única puerta.** El test nunca conoce Vuetify. El helper sí,
> pero solo el helper.

Eso es lo que Q0 no necesita escribir, porque en Quasar montar un componente aislado no
exige un ancestro especial. **Es la segunda mitad de esta fase, y es tuya sola.**

> 💡 **Honestidad técnica, para que nadie te la cuele en la revisión:** algunos
> componentes Vuetify (un `v-btn`, un `v-chip` sueltos) montan sin `v-app` sin
> quejarse. Los que **siempre** lo exigen son los de overlay (`v-dialog`, `v-menu`,
> `v-tooltip`, `v-snackbar`) y cualquiera que lea `$vuetify.breakpoint`. Tu `TicketForm`
> de VU2 vive dentro de un `v-dialog` → cae de lleno en el grupo que lo exige. Por eso
> el `mountView` no es opcional en esta ruta: es la diferencia entre "mis tests
> corren en VU2" y "mis tests explotan con un error de consola que no menciona la
> palabra v-app".

### 🅥 El anticipo honesto: qué tests SÍ van a cambiar en VU2/VU3, y está bien

No todo se puede blindar. Sé honesto con lo que viene:

| Test | Sobrevive | Por qué |
|---|---|---|
| `ticketService.contract.spec.js` | ✅ **entero** | Ni sabe que Vue existe. **No pasa por `mountView`**, así que el `v-app` ni le roza |
| `dashboard.spec.js` · contrato con el store | ✅ | Salvo que VU3 te obligue a cambiar el dispatch por `:options.sync` — **y ese rojo es la fase VU3 entera** |
| `dashboard.spec.js` · filtros y conteo | ⚠️ **el helper `rowCount()`** | `v-data-table` no siempre pinta `<tr>` limpios; los `data-testid` van en el scoped slot `item`. **Se toca el helper, no los tests** |
| `dashboard.spec.js` · el montaje | ⚠️ **el helper `mountView()`** | Aquí entra el `v-app`. **Se toca el helper, no los tests.** Esta fila NO existe en Q0 |
| `ticketForm.spec.js` · qué emite | ✅ **entero** | `v-form @submit` sigue emitiendo. El payload es el mismo |
| `ticketForm.spec.js` · el helper `fill()` | ⚠️ | `setValue` sobre un `v-text-field` apunta a otro nodo. **Se toca el helper** |
| `ticketForm.spec.js` · el montaje | ⚠️ **`mountView()`** | El form vive en `v-dialog` → **necesita el `v-app`**. Otra vez: el helper, no los tests |
| `ticketForm.spec.js` · reglas de validación | ✅ | vuelidate se va del proyecto, `:rules` llega. **El comportamiento no cambia** — por eso lo testeaste por su efecto |

Cuenta las filas: **la mayoría sobrevive intacta, y lo que no, se arregla en TRES
helpers** (`rowCount`, `fill`, `mountView`). En Q0 eran dos. El tercero —`mountView`— es
el precio del `v-app`, y lo pagas hoy con cinco líneas vacías en vez de mañana con
veinte ediciones prohibidas.

Eso no es suerte. Es exactamente lo que compraste esta fase.

---

## 📋 El checklist pre-migración (accionable)

Crea `MIGRATION-CHECKLIST.md` en la raíz. **No es documentación: es una puerta.** Si
algo aquí no está en verde, no se pasa a VU1.

```md
# Checklist pre-migración — Ruta VU (Vuetify 2.6)

## 🚦 Puerta 0 — El punto de partida está limpio
- [ ] `npm run test:unit` → **todo verde**. Cero .skip, cero rojos "que ya estaban".
- [ ] `git status` limpio. La migración arranca desde un commit conocido.
- [ ] Tag en git: `git tag pre-vuetify` — el punto al que volver cuando te
      pierdas. Y te vas a perder.
- [ ] json-server levantado y la app funciona a mano. Si no funciona a pelo,
      no vas a saber si la rompió Vuetify.
- [ ] **El inventario de la ceguera** (ejercicio 5): de los 6 specs de F11,
      ¿cuántos se pondrían rojos si reescribo el dashboard? Si es **cero** — y lo
      es — entonces el verde de F11 NO es una autorización para migrar. Es solo un
      punto de partida limpio. No confundas una cosa con la otra.

## 🎯 Puerta 1 — Qué se migra, exactamente
- [ ] Lista de lo que ENTRA:
      - VU2 → `TicketForm` + `TicketCreateView` + `TicketEditView` (F5) → v-form,
              v-dialog, y SALE vuelidate del proyecto
      - VU3 → `TicketsView` + `TicketsTable` + `TicketsSummary` (F4/F10) → v-data-table
- [ ] Lista de lo que NO se toca:
      - services/ · store/ · router/ · utils/
      - Panel de soporte (F9), wizard (F6), métricas (F7) → ejercicios
- [ ] ⚠️ Si el diff toca services/ o store/: **PARA.** Migraste hacia abajo.

## 🛡️ Puerta 2 — La red está puesta
- [ ] `tests/unit/regression/` existe, con su README.md y su contrato.
- [ ] Contrato con la API: los 5 verbos de ticketService con apiClient mockeado.
- [ ] Contrato con el store: la vista despacha tickets/fetchTickets al montar.
- [ ] Dashboard: carga · error · vacío · filtro texto · filtro estado ·
      combinado · limpiar · contador · selección de fila.
- [ ] TicketForm: emite con válidos · NO emite con inválidos · cada regla ·
      los bordes exactos · precarga en edición · saving deshabilita.
- [ ] data-testid sembrados en TODOS los puntos de interacción y aserción.
- [ ] **Auditoría de acoplamiento**: este grep NO debe devolver NADA:

      grep -rnE "\.(table|badge|btn|form-control|alert|b-modal|col-md)" tests/unit/regression/
      grep -rnE "find\(['\"](tr|td|table|select)['\"]\)" tests/unit/regression/
      grep -rn "wrapper.vm\." tests/unit/regression/

      Si devuelve algo: ese test es cemento. Arréglalo AHORA.

## 🅥 Puerta 2-bis — El seguro del v-app (SOLO ruta VU)
- [ ] `helpers/mount.js` existe y **exporta `mountView`**.
- [ ] **Ningún test importa `mount` de @vue/test-utils directamente.** Grep de
      control (debe devolver solo el propio helper):

      grep -rn "from \"@vue/test-utils\"" tests/unit/regression/
      grep -rn "mount(" tests/unit/regression/ | grep -v mountView | grep -v helpers/mount

      Si un .spec llama a mount() directo, el día del v-app se te queda fuera de
      la junta de dilatación. Redirígelo a mountView AHORA.
- [ ] `mount.js` tiene, escrito en un comentario, el PLAN del v-app para VU2:
      qué se registrará (Vuetify), cómo se creará el [data-app], por qué NO se
      envuelve el componente en un template <v-app>. El plan escrito hoy es la
      mitad del trabajo de VU2 hecho.
- [ ] La contract spec de la API **NO** pasa por mountView (no monta nada). Verifícalo.

## 📸 Puerta 3 — La foto del "antes"
- [ ] `npm run test:unit -- --coverage` y **guarda el número**.
- [ ] `wc -l src/views/TicketsView.vue src/components/tickets/*.vue`.
      En VU3 vas a borrar ~150 líneas. Quiero que lo veas medido.
- [ ] Anota en 5 líneas: qué NO te gusta del código actual. HOY, antes de tener
      framework nuevo con el que confundir tus motivos.

## 🧨 Puerta 4 — El kata del sabotaje (no opcional)
- [ ] Rompe el && de filteredTickets (cámbialo por ||). ¿La suite lo caza?
      Si no lo caza, tu red tiene un agujero. Repara la SUITE, no el código.
- [ ] Cambia _order: "desc" por "asc". ¿Lo caza el test de contrato?
- [ ] Haz que TicketForm emita con datos inválidos. ¿Lo caza? Es la aserción
      más importante del formulario.

## ✍️ Durante la migración
- [ ] Cada edición a tests/unit/regression/ se anota aquí, con fecha y motivo.
      EXCEPCIÓN prevista y esperada: las ediciones a helpers/mount.js, fill()
      y rowCount() son la junta de dilatación funcionando — se anotan igual,
      pero NO cuentan como "toqué un test". Distinguir ambas cosas es el punto.

| Fecha | Archivo tocado | ¿helper o test? | Motivo | ¿acoplamiento o rotura real? |
|---|---|---|---|---|
|  |  |  |  |  |
```

---

## ⚠️ Errores comunes

- **Escribir la red DESPUÉS de instalar Vuetify.** Es el error que mata la fase
  entera. Con Vuetify ya en el proyecto, tus tests de regresión describen el
  comportamiento **post-migración** — y no protegen nada. La red se teje **antes del
  salto**, o no es red.
- **🅥 Instalar Vuetify "solo para que el test del v-app funcione".** La versión sutil
  del error anterior, y muy tentadora en esta ruta precisamente por el `v-app`. En el
  momento en que metes `import Vuetify` en un test de VU0 para envolver un `v-app`,
  contaminaste la foto del "antes". El `v-app` se **anticipa** en un comentario dentro
  de `mountView`, **no se implementa** hasta VU2. Si tu `mount.js` de VU0 importa
  Vuetify, borra ese import: es humo.
- **🅥 Llamar a `mount()` directo en un .spec "porque hoy funciona igual".** Funciona
  hoy, sí. Y el día del `v-app` ese test se queda fuera de la única puerta por la que
  el `v-app` entra limpio. Todo montaje pasa por `mountView`, desde el primer test,
  aunque hoy `mountView` no haga nada especial. Ese "no hace nada especial" es temporal
  a propósito.
- **Testear lo que vas a borrar.** Un test precioso para el `<select>` de estado que en
  VU3 será un `v-select` dentro de un scoped slot. Trabajo tirado. Testea el **efecto**
  del select (las filas se reducen), no el select.
- **"Ya que estoy, arreglo esto"**: el bug del `id` que arrastra el payload, el filtro
  que no busca en la descripción. **NO.** Arreglar y migrar en el mismo commit es
  garantizar que cuando algo falle no sepas cuál de los dos fue. Anótalo en el
  checklist. Se arregla **después**, con la red puesta.
- **Confundir cobertura con protección.** 90% de coverage y cero red si todos esos
  tests miran clases CSS. **La pregunta no es cuánto cubres, es qué pasa cuando cambias
  la implementación.**
- **El helper que no existe**: copiar `findAll("tbody tr")` en doce tests en vez de
  `rowCount()`. Y su versión Vuetify: copiar `mount()` en doce tests en vez de
  `mountView()`. El día de la migración, cada copia es una oportunidad de equivocarse.
- **Mockear el store real en vez de construir uno de juguete.** El store **no se
  migra**; si lo importas, tus tests de vista fallan cuando cambia el store. Ruido puro.
- **Olvidar el `.then()` tras `setValue`/`trigger`** en VTU 1.x: el DOM no se ha
  actualizado y el `expect` mira el render viejo. Verde falso. Si un test de filtrado
  **nunca** falla aunque rompas el filtro, es esto. Siempre es esto.
- **Snapshot testing "para capturar el antes"**: trampa perfecta, y en Vuetify a lo
  grande — el HTML renderizado de Vuetify es enorme, el diff de la primera migración
  son miles de líneas y aprietas `-u` sin mirar.
- **No correr la suite antes de empezar.** Arrancar con dos rojos "que ya estaban ahí"
  es empezar con la alarma desconectada. Verde total o no se sale de esta fase.

---

## 🧪 Ejercicios (28)

**🟢 Fácil (1–8)**

1. Crea `tests/unit/regression/` con su `README.md` (el contrato, con la excepción
   prevista de `helpers/mount.js` ya escrita). Commitea eso solo, con el mensaje
   `chore: red de seguridad pre-migración`. Que quede en el historial **antes** que
   cualquier línea de Vuetify.
2. Siembra los `data-testid` del dashboard y del `TicketForm`. Corre la app y la suite
   de F11: **todo igual, todo verde**. Escribe una línea sobre por qué ese "no pasó
   nada" era el resultado deseado.
3. Copia el `fixtures.js` de la fase y agrégale un quinto ticket cuyo `assignee` sea
   `null` en vez de `""`. Corre el dashboard. ¿Cambia algo? Documenta la diferencia
   entre `""` y `null` en este modelo. (Spoiler: hoy nadie la maneja.)
4. Escribe el test de "el dashboard despacha `tickets/fetchTickets` al montar" tú solo,
   sin mirar. Es el test más importante de la ruta y tiene que salirte de memoria.
5. El inventario de la vergüenza: lista los 6 specs que F11 te dejó y marca, al lado de
   cada uno, **si VU2/VU3 lo van a poner rojo**. (Pista: la columna te va a salir entera
   en "no".) Luego lista los 4 componentes que VU2/VU3 **van a reescribir** y marca
   cuáles tienen test. Dos columnas, diez líneas, y tienes la justificación entera de
   esta fase en un papel.
6. Rompe el `&&` de `filteredTickets` (cámbialo por `||`) y corre la suite de regresión.
   ¿Rojo? Bien. Revierte. Si salió verde: **tienes un agujero**, y el ejercicio real es
   taparlo.
7. Escribe el test de contrato de `deleteTicket` (DELETE `/tickets/:id`) sin mirar el
   ejemplo. Es de tres líneas y es la mitad de un incidente evitado.
8. 🅥 Crea `helpers/mount.js` con `mountView` **vacío de Vuetify** (el `mount()`
   transparente de la fase). Redirige `dashboard.spec.js` y `ticketForm.spec.js` para
   que monten a través de él. Corre la suite: **debe seguir toda verde.** Escribe una
   línea sobre por qué un helper que "no hace nada" hoy es lo más valioso que vas a
   escribir en esta fase.

**🟡 Intermedio (9–17)**

9. **Haz el ejercicio 22 de F11 que te saltaste** (el `mount` de `TicketsView` con el
   store real y el servicio mockeado) — pero escríbelo **como lo habrías escrito antes
   de leer esta fase**: con `findAll("tbody tr")`, con `.table-hover`, con selectores
   por posición. Sin trampa. Ahora aplícale el veredicto de la tabla de la
   Divergencia 1, aserción por aserción, y reescríbelo con `data-testid` y `mountView`.
   Compara ambas versiones y anota cuántas aserciones sobrevivieron intactas. **Ese
   porcentaje es lo que VU0 te acaba de ahorrar.**
10. Escribe el test de regresión del **detalle del ticket** (`TicketDetailView`):
    contrato con el servicio/store, los tres estados, el 404. No está en la fase; te
    toca a ti. Móntalo con `mountView`.
11. Escribe el test de regresión del **borrado con confirmación** (F5): mockea
    `window.confirm` (`jest.spyOn(window, "confirm")`), verifica que si devuelve `false`
    **no** sale el DELETE, y si devuelve `true` sí. La confirmación es comportamiento,
    no adorno.
12. Los helpers `rowCount()` y `fill()` viven en sus specs. **Sácalos a
    `helpers/dom.js`.** Justifica en tres líneas por qué todo el contacto con el DOM
    debe vivir en un solo archivo antes de una migración. (Y nota que `mountView` ya
    nació separado: era la excepción, ahora es la regla.)
13. Congela el **orden** de los tickets: hoy llegan de la API ya ordenados
    (`_sort=createdAt&_order=desc`) y el dashboard no reordena. Escribe el test que
    afirme que la primera fila es el ticket más reciente. Luego responde: en VU3,
    `v-data-table` **ordena por su cuenta con `:options.sync`**. ¿Este test es una red o
    una trampa? Argumenta y decide si lo dejas.
14. `TicketsSummary`: escribe su test de regresión afirmando **los cuatro conteos** por
    su `data-testid`, sin tocar `.card` ni `<h2>`. Y el caso borde: lista vacía →
    cuatro ceros, no cuatro huecos.
15. Verde falso deliberado: en "la búsqueda reduce las filas", **quita el `.then()`**
    tras el `setValue`. Rompe el filtro a propósito. Confirma que el test **pasa
    igual**. 😱 Restaura y deja el escalofrío en un comentario.
16. `beforeRouteLeave` del wizard (F6): ese `window.confirm` de "tienes un ticket a
    medias" es comportamiento puro y nadie lo ha testeado. Escríbelo. No se migra en la
    ruta, pero el ejercicio 🔴 de VU4 (el `v-stepper`) sí lo toca — y entonces querrás
    tener esto.
17. Escribe el test que verifica que `TicketCreateView` **arma el payload completo**:
    `formData` + `status:"open"` + `reporter` (del getter de auth) + `createdAt`.
    Mockea el servicio y afirma el objeto que le llega.

**🟠 Difícil (18–23)**

18. **La auditoría de F11, en dos ejes.** Recorre los 6 specs y clasifica **cada
    aserción** en dos dimensiones: *acoplamiento* (🟢 sobrevive a cualquier framework ·
    🟡 con `data-testid` · 🔴 cemento) y *pertinencia* (✅ vigila algo que VU2/VU3 tocan ·
    ⬜ no está mirando). Entrega `TEST-AUDIT.md` con la matriz. La mayoría caerá en
    🟢⬜ — impecables *y* ciegas. Escribe tres párrafos sobre por qué esa casilla es la
    más peligrosa: es la que produce el *"pero si todos los tests pasaban"* del
    post-mortem.
19. La **matriz de riesgo**: por cada archivo que VU2/VU3 van a tocar, una fila con
    (a) qué tests lo cubren, (b) qué comportamiento **no** está cubierto, (c) qué
    pasaría en producción si eso se rompiera en silencio. Ordénala por riesgo. Los tres
    primeros: **escribe hoy los tests que faltan.**
20. **Testea lo que el dashboard NO hace.** Aserciones negativas para congelar
    ausencias: no hay paginación (todos los tickets se pintan, sean 4 o 400), no hay
    ordenamiento por columna, no hay selección múltiple. En VU3, `v-data-table` trae
    **las tres de fábrica**. Estos tests se pondrán rojos — y ese rojo **es correcto y
    deseado**: es Vuetify entregándote features que no pediste. Escribe cómo distingues
    "un rojo que es una feature nueva" de "un rojo que es una regresión".
21. `LiveToast` + el plugin de socket (F8/F10): red de seguridad para el tiempo real.
    Mockea `socketService`, captura los handlers, invoca uno a mano con un ticket nuevo
    y verifica que (a) el store lo incorporó y (b) **el dashboard montado pinta la fila
    nueva**. Es el pegamento — y lo vas a necesitar en VU4, donde el timeline se
    alimenta del mismo socket.
22. **La red del panel de soporte** (F9), completa: master-detail, tomar ticket,
    máquina de estados, comentarios. **La vas a necesitar en VU3** (es el ejercicio 🔴
    de esa fase, y allí te la piden sin guía). Escríbela ahora, con la fase fresca, en
    vez de a las 11pm con `v-data-table` a medio migrar.
23. 🅥 **El ensayo del `v-app`, en seco.** Escribe en `V-APP-PLAN.md` la respuesta
    completa a la pregunta de la fase: (a) por qué la Trampa A (envolver hoy) contamina
    la red; (b) por qué la Trampa B (dejarlo para VU2) rompe la carpeta intocable;
    (c) exactamente qué líneas entrarán en `mountView` en VU2 y por qué NO se envuelve
    el componente en un template `<v-app>` (pista: rompe `emitted()` y el paso de
    props). Este documento es medio VU2 hecho por adelantado. **Es el entregable que
    Q0 no puede pedir.**

**🔴 Muy difícil (24–28)**

24. **El sabotaje a ciegas (el kata definitivo).** Pide a alguien (o a tu yo de dentro
    de una semana, con un script) que introduzca **tres regresiones** sutiles sin
    decirte cuáles: p.ej. el filtro deja de ser case-insensitive, el `_order` pasa a
    `asc`, `TicketForm` emite con prioridad vacía. Corre **solo** la suite de regresión.
    ¿Las caza las tres? Por cada una que se escape, escribe el test que faltaba **y** la
    línea de por qué no se te ocurrió. Ese "por qué" es la fase entera.
25. **La discusión e2e, con datos.** Este curso no trae Cypress, y una migración de UI
    es el caso de uso **canónico** del e2e (un test que hace clic en el navegador real
    es indiferente a si debajo hay `<b-table>` o `v-data-table`, **y además ni se entera
    del problema del `v-app`** — el navegador real monta la app entera, `v-app`
    incluido). Monta un Cypress mínimo aparte, escribe **un** test del flujo "login →
    dashboard → filtrar → crear ticket", y escribe `E2E-NOTES.md`: ¿cuánto costó? ¿Qué
    cazaría que tus unitarios no? ¿Qué NO cazaría? Y la pregunta propia de esta ruta:
    **¿el e2e te habría ahorrado el helper `mountView`?** (Sí. Y aun así, sé honesto
    sobre por qué los unitarios no se reemplazan.)
26. **El test de contrato contra json-server REAL** (retoma el ej. 26 de F11): levanta
    json-server en un puerto de test con un `db.json` fixture y valida que cada endpoint
    responde la **forma** documentada. Córrelo como `test:contract`, separado. Y la
    pregunta 💸: *"el backend no cambia"* — pero json-server **sí lo puedes cambiar tú**.
    Escribe qué disciplina te impone eso, y qué se rompe el día que el backend real no
    acepte el `id` que arrastras en el PATCH. Adelanto de VU3: ese mismo backend te va a
    mandar el total en `X-Total-Count`, no en el body — ¿tu contract test lo congela?
27. **La red mínima viable, cronometrada.** Te sueltan en un Vue 2 legacy ajeno de
    80.000 líneas y te piden migrar una pantalla a Vuetify. Tienes **4 horas** para la
    red. ¿Qué escribes, en qué orden, y qué dejas sin cubrir a sabiendas? Entrega
    `RED-MINIMA.md`: el orden justificado y —lo más difícil— **la lista de lo que
    aceptas no proteger**. Pista de orden: el contrato con la API es el que más vida
    útil tiene por línea; y en Vuetify, el `mountView` va **antes** del primer test de
    componente, no después. Este ejercicio es la promesa del curso hecha examen.
28. **El post-mortem invertido, versión Vuetify.** Escribe hoy, **antes** de tocar
    Vuetify, el informe de incidente de la migración que aún no ha ocurrido. Dos
    escenarios, escoge uno o haz los dos:
    (a) *"tras migrar el dashboard a v-data-table, en producción el filtro de estado
    dejó de combinarse con la búsqueda durante seis días"*;
    (b) 🅥 *"tras migrar el CRUD, el diálogo de crear ticket no abría en producción —
    y en local sí. Tardamos dos días en descubrir que en los tests el `v-dialog` nunca
    se probó de verdad porque montaban sin `v-app`, y el falso verde nos mandó a
    producción convencidos de que funcionaba."*
    Reconstruye hacia atrás: ¿qué test faltó? ¿por qué la revisión no lo vio? ¿qué del
    checklist se saltó alguien? Guárdalo. Al terminar VU3, ábrelo y compara. (El
    escenario (b) es el que Q0 no puede escribir — y el que más miedo da cuando acierta.)

---

## 📚 Referencias

**Documentación oficial (testing — Vue 2)**

- Vue Test Utils **v1** (la de Vue 2): https://v1.test-utils.vuejs.org/
- VTU v1 — `mount` vs `shallowMount`: https://v1.test-utils.vuejs.org/api/#mount
- VTU v1 — `attachTo` (clave para el patrón del `v-app`):
  https://v1.test-utils.vuejs.org/api/options.html#attachto
- VTU v1 — API del wrapper (`find`, `setValue`, `trigger`, `emitted`):
  https://v1.test-utils.vuejs.org/api/wrapper/
- VTU v1 — testear con Vuex: https://v1.test-utils.vuejs.org/guides/using-with-vuex.html
- VTU v1 — testear con Vue Router:
  https://v1.test-utils.vuejs.org/guides/using-with-vue-router.html
- VTU v1 — `nextTick` y el DOM asíncrono (**la trampa del verde falso**):
  https://v1.test-utils.vuejs.org/guides/#testing-asynchronous-behavior
- Jest — funciones mock y espías: https://jestjs.io/docs/mock-functions
- Jest — matchers: https://jestjs.io/docs/expect
- Jest — testing asíncrono: https://jestjs.io/docs/asynchronous
- Vuex 3 — testing: https://v3.vuex.vuejs.org/guide/testing.html

**🅥 Sobre el `<v-app>` y los tests (léelo AHORA, no en VU2 — es la mitad de la fase)**

- Vuetify 2 — *Application* (`v-app`, el `[data-app]` y por qué es la raíz):
  https://v2.vuetifyjs.com/en/components/application/
- Vuetify 2 — *Unit testing* (el patrón oficial: `Vue.use(Vuetify)` + instancia
  `vuetify` por test; ojo, el aviso de `createLocalVue`):
  https://v2.vuetifyjs.com/en/getting-started/unit-testing/
- ⚠️ **El dominio importa:** la doc **v2** vive en `v2.vuetifyjs.com`. El dominio raíz
  `vuetifyjs.com` sirve **v3 (Vue 3)**, que está fuera de scope. Si un ejemplo usa
  `createVuetify()` en vez de `new Vuetify()`, estás leyendo v3. Cierra la pestaña.

**Lectura de fondo (el criterio, no la herramienta)**

- Testing Library — *Guiding Principles* (el origen de "comportamiento observable"):
  https://testing-library.com/docs/guiding-principles/
- Kent C. Dodds — *Testing Implementation Details*:
  https://kentcdodds.com/blog/testing-implementation-details
- Martin Fowler — *Refactoring*, cap. 4 "Building Tests" (esta fase escrita en 1999):
  https://martinfowler.com/books/refactoring.html

**Para el ejercicio 25 (e2e), si te animas**

- Cypress — Vue CLI plugin (el de la época): https://cli.vuejs.org/core-plugins/e2e-cypress.html

**Orden de lectura sugerido:** VTU con Vuex → el artículo de Kent C. Dodds (quince
minutos, el 80% del concepto 2) → **la página de *Unit testing* de Vuetify 2** (para
entender el `v-app` que vas a anticipar) → volver al código.

---

## 🚀 Cierre

No has escrito una línea de Vuetify. No lo has instalado. No sabes todavía qué toca
`vue add vuetify`. Y sin embargo, esta es probablemente la fase más importante de la
ruta.

Lo que te llevas — **lo común, lo que también vale en Quasar y en Nuxt:**

- la distinción operativa entre **test normal** ("¿funciona?") y **test de regresión**
  ("¿sigue haciendo lo mismo?"), y la definición que las separa: *un test de regresión
  válido puede pasar en verde con dos implementaciones completamente distintas por
  debajo*;
- **`data-testid` como contrato**: el ancla que tú pones, tú mantienes, y que sobrevive
  a que cambie todo lo demás;
- los **dos contratos que no se cruzan** — con el store y con la API — convertidos de
  principio de arquitectura en aserción ejecutable;
- **los helpers como junta de dilatación**: `rowCount()` y `fill()` concentran todo el
  contacto con el DOM en dos funciones;
- la disciplina que separa una migración de un incendio: **congelar primero, arreglar
  después**;
- y la lección que no venía en el guion: **cobertura no es protección.** Tenías seis
  specs impecables y cero red sobre lo que ibas a borrar.

Y lo que te llevas **que en Quasar no había — lo tuyo, lo de esta ruta:**

- 🅥 **una tercera junta de dilatación, `mountView`**, que en Q0 no existe. Porque
  Vuetify no solo te pide *ignorar* el framework viejo: te pide *sobrevivir a una
  exigencia* del framework nuevo, el `<v-app>` obligatorio, sin dejarlo entrar todavía
  en tu red;
- 🅥 **la respuesta a un dilema que Quasar nunca plantea**: cómo montar hoy un test que
  no se acople al framework destino (Trampa A) ni te condene a veinte ediciones
  prohibidas mañana (Trampa B). La salida —sacar *el acto de montar* a un helper vacío
  hoy— es de las cosas más elegantes que enseña el curso entero, y solo tiene sentido
  aquí;
- 🅥 y el instinto para el **falso rojo sin culpa**: el día que un test Vuetify se
  ponga rojo y tu código esté bien y tu selector esté bien, tu primera hipótesis ya no
  será "¿qué rompí?" sino "**¿le falta el `v-app`?**". Esa hipótesis, hoy, no la tenías.

La señal de que quedó bien:

> "puedo reescribir el dashboard y el CRUD entero en Vuetify, y sé —sin abrir el
> navegador, en once segundos— si siguen haciendo lo que hacían ayer. Cuando un test se
> ponga rojo, sabré si el problema es mi código, era mi test acoplado, **o es que le
> falta un `v-app`**. Y si NINGUNO se pone rojo, sabré que es porque están mirando, no
> porque estén ciegos."

Y la pregunta que abrió la fase, ahora con respuesta doble:

> *¿Rompiste el comportamiento, o tu test era una porquería acoplada al DOM?*
> **Ahora tienes cómo saberlo.**
>
> Y la que es solo tuya, la que Quasar no hace: *¿cómo escribo hoy un test que
> sobreviva al `v-app` de mañana sin dejar que el `v-app` entre hoy?*
> **Ahora también: `mountView`, vacío hoy, la única puerta mañana.**

**💸 La deuda de la fase, para que no se te olvide:** *"El backend no cambia. Si tu test
de regresión toca la API real y falla, el problema es tuyo."*

**Siguiente parada:** 📖 **VU1 — Leer Vuetify**. Todavía sin migrar nada, todavía sin
tocar el Mini Jira. Reconocimiento puro: qué es Vuetify de verdad (Material Design,
componentes, no solo formularios), qué toca —y qué **no** toca— `vue add vuetify`
(spoiler: tu `main.js` sobrevive, y eso ya lo hace distinto de Quasar), qué es
`plugins/vuetify.js`, el **theming en JS** que va a ser el peso de la ruta, el grid por
**componentes** (`v-container`/`v-row`/`v-col`) con su trampa de la sintaxis v1
(`v-layout`/`v-flex`) que te vas a encontrar en código de 2019 — y, por fin, el
`<v-app>` de verdad, ese que hoy solo has anticipado. Ya tienes red, y ya tienes la
puerta (`mountView`) por la que va a entrar. Ahora aprende a leer el framework al que
vas a saltar.
