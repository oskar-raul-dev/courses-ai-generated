# 🛡️ NX0 — La red de seguridad (ruta Nuxt)

> Primera fase de la ruta **NX**. Opcional, excluyente con Q y VU.
> **Prerequisito duro: F11 (Testing).** Sin saber montar componentes y mockear
> la frontera, aquí no hay nada que construir.

---

## 🎯 Propósito

Nadie migra lo que no puede verificar. Antes de tocar Nuxt vas a blindar el
Mini Jira **tal como está a pelo** con tests de regresión: fotos del
comportamiento actual que tienen que seguir en verde después de que la
migración cambie las tripas por debajo.

Eso es exactamente lo que hacen Q0 y VU0. Y ahí acaba el parecido.

Porque esta fase abre admitiendo algo incómodo: **la red que vas a tejer tiene
un agujero, y en la ruta Nuxt ese agujero importa.** Tus tests corren en jsdom
—un DOM de mentira que vive dentro de Node y que, para colmo de comodidad,
**trae `window`**. Tu código Nuxt va a correr de verdad en Node, en el
servidor, **donde `window` no existe**. Un test que toca `localStorage` pasa en
verde en tu máquina y la misma línea revienta en producción con
`window is not defined`. Y tu suite **no te avisa**, porque tu suite vive en el
único entorno donde el bug no ocurre.

Q0 y VU0 pueden decir "escribe la red y cruza tranquilo". NX0 no puede, y sería
deshonesto fingir que sí. Así que la fase hace lo contrario: te enseña a tejer
la red **bien**, y al final te enseña a ver el agujero con tus propios ojos —un
test que pasa en jsdom y fallaría en Node de verdad. Salir de aquí sabiendo
que la red no basta **es el objetivo**, no un fracaso. Es la mejor puerta de
entrada a Nuxt que existe.

> La regla de la fase: la red de regresión es necesaria y **no suficiente**.
> Testea el comportamiento que la migración debe preservar, y aprende a
> desconfiar del entorno donde corren tus tests.

---

## ✅ Qué queda listo al terminar

- una suite de **regresión** sobre las dos piezas que vas a migrar primero: el
  **dashboard** (F4) y el **CRUD** (F5), escrita contra el código que vas a
  reescribir —no contra el que vas a conservar;
- tests amarrados al **comportamiento observable** (texto, eventos emitidos,
  peticiones que salen) y **no** a clases de Bootstrap ni a la estructura del
  DOM —lo único que sobrevive a cambiar de molde;
- el **contrato con el store** blindado: la vista despacha la acción con el
  payload correcto, pase lo que pase con el HTML;
- el **contrato con la API** blindado: mockeas `apiClient` y verificas que la
  petición sale idéntica —mismo verbo, misma ruta, mismos params;
- `data-testid` sembrados en los puntos que vas a interrogar, para que los
  tests no dependan de dónde caiga cada `div`;
- un **checklist pre-migración** que puedes reusar en cada pieza;
- y —lo que hace especial a esta fase— un test que **demuestra el agujero**:
  verde en jsdom, rojo en Node. La prueba física de que la red no cubre el
  entorno de ejecución.

## 🚫 Qué NO entra todavía

- **cero Nuxt.** No se instala nada, no hay `nuxt.config.js`, no hay `pages/`.
  Todo esto corre sobre el proyecto a pelo de F0–F11. Nuxt empieza en NX1;
- cómo se **arregla** el agujero de `window` (cookies, `process.client`,
  `<client-only>`): eso es NX2. Aquí solo lo **ves**;
- e2e real (Cypress/Playwright): se nombra como el tapón definitivo del
  agujero, pero es otra disciplina y otra fase mental;
- tests nuevos de features que no vas a migrar en las primeras fases (wizard,
  métricas): la red se teje **donde vas a cortar**, no en todas partes.

---

## 🧠 Concepto 1: test normal vs test de regresión

Ya rozaste esto en F11 (el flujo del bug: reproducir → arreglar → el test se
queda de guardia). Aquí lo llevamos al caso concreto de **migrar**, que es un
tipo de cambio distinto a arreglar un bug: no cambias *qué* hace el código,
cambias *con qué* lo hace. El comportamiento tiene que quedar clavado; la
implementación entera se va a la basura.

Un test de regresión pre-migración es una clase aparte, y conviene tenerla
nítida:

| | Test normal | Test de regresión pre-migración |
|---|---|---|
| **Qué verifica** | que la feature funciona | que funciona **igual que antes de tocarla** |
| **Cuándo nace** | junto a la feature | **contra código que ya existe y vas a borrar** |
| **Qué asume** | la implementación es la buena | la implementación **va a cambiar entera** |
| **Si el código interno cambia** | puede morir con él | **debe sobrevivir** —ese es su trabajo |
| **De qué se agarra** | lo que sea, incluso detalles | **solo comportamiento observable** |
| **Contra qué mide** | la especificación | **el comportamiento actual como oráculo** |
| **Cuándo lo borras** | cuando la feature muere | cuando la migración terminó y quedó estable |

La fila que lo cambia todo es la penúltima. En un test normal puedes darte el
lujo de mirar un `computed` o una clase CSS. En un test de regresión de
migración **no puedes**, porque esas son justo las cosas que la migración va a
cambiar. Si tu test se agarra de `.b-table` o de `badge-danger`, muere en el
primer commit de Nuxt y no habrá servido de nada. La regresión se agarra de lo
que **no** va a cambiar: qué texto ve el usuario, qué evento se emite, qué
petición sale a la red.

> 🔎 **Qué hace un test de regresión de migración:** congela el contrato
> *externo* de una pieza —lo que el resto del sistema y el usuario esperan de
> ella— para que puedas destrozarle las tripas con red debajo.

Piénsalo como un contrato firmado con tu yo del futuro: *"pase lo que pase con
el HTML, esta pantalla seguirá mostrando 'Abierto' para un ticket abierto y
seguirá emitiendo `select` al hacer clic en una fila."* Si Nuxt rompe eso, el
test truena y te enteras hoy, no en el reporte de un agente el martes.

---

## 🧠 Concepto 2: comportamiento observable, no estructura

Este es **el** concepto de la fase, y el que decide si tu red aguanta la
migración o se hace polvo. Ya lo viste enunciado en F11 ("testea
comportamiento, no implementación"). Aquí lo aterrizamos en una regla operativa
que vas a aplicar en cada test: **`data-testid` por encima de selectores de
clase.**

El problema con los selectores de clase en una migración es directo: las clases
**son** lo que migras. Tu dashboard a pelo usa `.table`, `.btn-primary`,
`.badge-danger` —clases de Bootstrap 4. Cuando llegue Nuxt (y más allá, cuando
alguien meta un framework de UI), esas clases cambian o desaparecen. Un test que
hace `wrapper.find(".badge-danger")` no está probando "el estado se muestra en
rojo": está probando "existe un elemento con la clase literal `badge-danger`",
que es una afirmación sobre el molde de Bootstrap, no sobre tu negocio.

La cura es marcar los puntos que te importan con un atributo que **tú** controlas
y que la migración no tiene por qué tocar:

```html
<!-- en el componente: un ancla estable para el test -->
<tr :data-testid="'ticket-row-' + ticket.id" @click="$emit('select', ticket)">
```

```js
// en el test: te agarras del ancla, no del molde
wrapper.find('[data-testid="ticket-row-1"]').trigger("click");
```

`data-testid` es un contrato explícito: este elemento existe **para ser
testeado**, y quien lo cambie sabe que rompe un test a propósito. Un selector de
clase es un contrato accidental —nadie prometió que `.badge-danger` iba a
seguir ahí, y cambiarlo rompe tests sin que el autor lo sospeche.

> ✅ **Buenas prácticas:**
> - Interroga por `data-testid`, por **texto visible** (`wrapper.text()`), o por
>   **evento emitido** (`wrapper.emitted()`). Los tres sobreviven al cambio de
>   molde.
> - Reserva `data-testid` para los anclas que de verdad interrogas —no lo
>   riegues por todo el template. Un `data-testid` por cada cosa que un test
>   busca; ni uno más.
> - Nómbralos por **rol semántico**, no por posición: `ticket-row`, no
>   `second-row`. El rol no cambia al reordenar.

> ⚠️ Sí, `data-testid` mete atributos de test en el HTML de producción. Es un
> trueque conocido y aceptado en la industria: unos bytes de atributo a cambio
> de tests que no se rompen con cada retoque de maqueta. En legacy, ese trato
> sale barato.

**Qué NO testear** (porque es justo lo que vas a cambiar):

| Tentación | Por qué NO | Qué probar en su lugar |
|---|---|---|
| clases de Bootstrap (`.btn`, `.badge-danger`) | migran o desaparecen | el **texto** o el **estado** que representan |
| estructura del DOM (`div > div:nth-child(2)`) | la maqueta se rehace entera | un `data-testid` en el elemento que importa |
| orden exacto de los elementos | el molde puede reordenar | que los elementos **existan** y hagan lo suyo |
| estilos, colores, spacing | no son comportamiento | nada —eso lo revisa el ojo, no el test |
| nombres de `computed`/`methods` internos | son implementación pura | el **efecto observable** de ese computed |

---

## 🧠 Concepto 3: el contrato con el store y con la API

Una pieza del Mini Jira habla con dos vecinos: hacia arriba con el **store**
(despacha acciones, lee getters) y hacia abajo, a través del servicio, con la
**API**. La migración a Nuxt va a mover mucho —el componente puede cambiar de
carpeta, el ciclo de vida se va a ejecutar dos veces, la carga de datos se va a
pelear con `asyncData` en NX3— pero esos **dos contratos no deberían cambiar**.
Y si cambian, quieres enterarte.

Así que además de testear lo que el usuario ve, la red de regresión clava esos
dos contratos, exactamente con las herramientas de F11:

- **Contrato con el store** — con un store de laboratorio (`createLocalVue` +
  Vuex, o un `store` de juguete con acciones espía), verificas que la vista
  **despacha la acción correcta con el payload correcto**. No te importa qué
  hace la acción por dentro; te importa que la vista la llame bien. Cuando Nuxt
  reacomode dónde vive el componente, este test sigue diciendo la verdad: *la
  vista sigue pidiéndole al store lo que siempre le pidió*.

- **Contrato con la API** — mockeas `apiClient` (el cable a axios) y verificas
  que el servicio **manda la petición idéntica**: mismo método, misma ruta,
  mismos params, y que devuelve `res.data` pelado. Este es el contrato más
  estable de todos, y el más valioso en Nuxt: cuando en NX3 el servidor Node
  empiece a hacer estas mismas llamadas, quieres saber que la forma de la
  petición no se movió.

> 🔎 **Qué hace:** cada test se enchufa a un doble de su vecina —store de
> juguete arriba, `apiClient` mockeado abajo— y afirma que la pieza **habla el
> mismo idioma con sus vecinos** antes y después de migrar. Es la misma lección
> de "dónde mockear es LA decisión" de F11, ahora al servicio de la migración.

---

## 💥 Concepto 4: la divergencia Nuxt — jsdom tiene `window`, Node no

Aquí es donde NX0 se separa de Q0 y VU0, y donde la fase se gana el nombre.

En Q0 y VU0, la red de seguridad **funciona y basta**. Migras a Quasar o
Vuetify, los componentes cambian de nombre, tus tests de regresión bien
escritos siguen en verde, y si algo se rompe, se rompe **en el mismo entorno
donde corren los tests**: el navegador. La red los cubre porque tests y
producción viven en el mismo sitio.

En Nuxt **no**. Y la razón es tan simple como brutal:

```
┌─────────────────────────────────────────────────────────────────┐
│  DÓNDE CORREN TUS TESTS          DÓNDE CORRERÁ TU CÓDIGO NUXT      │
│                                                                   │
│  Jest + jsdom                    Node (servidor SSR)              │
│  ┌───────────────┐               ┌───────────────┐               │
│  │  window   ✅   │               │  window   ❌   │  ← no existe  │
│  │  document ✅   │               │  document ❌   │               │
│  │  localStorage✅│               │  localStorage❌│               │
│  └───────────────┘               └───────────────┘               │
│         │                                │                        │
│         ▼                                ▼                        │
│   test PASA 🟢                     app REVIENTA 💥                 │
│                          window is not defined                    │
└─────────────────────────────────────────────────────────────────┘
```

jsdom es un DOM de mentira construido **para** los tests, y por comodidad
implementa `window`, `document` y `localStorage`. Tu código a pelo abusa de eso
sin saberlo: el guard del router lee `localStorage.getItem("token")` (F2), el
interceptor de axios adjunta el token desde `localStorage` (F2), chart.js
necesita `window` (F7), socket.io toca `window` (F8). Todo eso **pasa en tus
tests** porque jsdom finge tener esas cosas.

Nuxt en modo `universal` va a ejecutar el ciclo de vida de tus componentes
**dos veces**: una en el servidor Node (para mandar HTML ya pintado) y otra en
el navegador (para "revivirlo", la hidratación). Y en el servidor Node **no hay
`window`**. La primera línea que lo toque durante el render del servidor lanza
`window is not defined` y la página se cae antes de llegar al navegador.

**La pregunta que abre la ruta:** ¿cómo se testea código que va a correr en
dos entornos, cuando tu herramienta de test solo conoce uno? Es tu **primer
contacto con el entorno de ejecución como variable de test** —una dimensión que
en el curso a pelo no existía, porque a pelo todo corría en un solo sitio: el
navegador.

No la respondemos aquí. La **exponemos**. El código de esta fase incluye un test
que pasa en jsdom y que, si lo forzaras a correr sin `window` (como hará Node),
fallaría. Ver ese test verde, sabiendo que miente, es la lección.

> 💸 **Deuda:** *"Tu suite de tests da una falsa sensación de seguridad: pasa en
> jsdom, que tiene `window`, mientras el código va a correr en Node, que no.
> Lo arreglamos **parcialmente** en NX2 (moviendo lo que toca `window` a
> `mounted()`/cookies, y ganando visibilidad del entorno). **Del todo, nunca**
> —por eso en producción se paga un e2e real que ejerza el servidor de verdad.
> El unitario en jsdom es necesario y estructuralmente ciego a este bug."*

---

## 💻 Código de la fase

> ⚠️ **Cero Nuxt en todo lo que sigue.** Esto corre sobre el Mini Jira a pelo,
> con el mismo `vue add unit-jest` de F11 (Jest + `@vue/test-utils` 1.x +
> `vue-jest` + `babel-jest`). Si no tienes la suite de F11 corriendo, vuelve a
> F11 antes de seguir.

### Paso 0 — sembrar los `data-testid` en las piezas a migrar

Antes de escribir un solo test de regresión, marca los anclas. Son cambios de
una línea en los componentes de F4 y F5, y no alteran comportamiento.

En `components/tickets/TicketsTable.vue` (F4), la fila:

```html
<!-- antes -->
<tr @click="$emit('select', ticket)">

<!-- después: ancla estable por id de ticket -->
<tr :data-testid="'ticket-row-' + ticket.id" @click="$emit('select', ticket)">
```

En `views/TicketsView.vue` (F4), el buscador y el select de filtro:

```html
<input data-testid="search-input" v-model="search" class="form-control" ... />
<select data-testid="status-filter" v-model="statusFilter" class="form-control" ...>
<span data-testid="results-count">
  Mostrando {{ filteredTickets.length }} de {{ tickets.length }} tickets
</span>
```

En `components/tickets/TicketForm.vue` (F5), los campos y el submit:

```html
<input data-testid="form-title" v-model="form.title" ... />
<textarea data-testid="form-description" v-model="form.description" ... />
<button data-testid="form-submit" type="submit">Guardar</button>
<p data-testid="error-title" v-if="$v.form.title.$error">El título es obligatorio</p>
```

> 🔎 **Qué hace:** no cambia nada visible ni funcional; solo deja anclas que los
> tests pueden buscar sin depender de clases de Bootstrap ni de la posición en
> el DOM. Cuando la migración rehaga la maqueta, estos anclas viajan con el
> elemento.

### Test 1 — regresión del dashboard: contrato de render (F4)

`tests/unit/regression/TicketsTable.regression.spec.js`

```js
import { shallowMount } from "@vue/test-utils";
import TicketsTable from "@/components/tickets/TicketsTable.vue";

// Stub del badge hijo: no es el objeto de este test, y shallowMount ya lo
// reemplazaría; lo dejamos explícito para documentar la frontera.
describe("REGRESIÓN · TicketsTable (F4)", function () {
  var tickets = [
    { id: 1, title: "No arranca el server", status: "open" },
    { id: 2, title: "Error 500 en login", status: "resolved" }
  ];

  function build() {
    return shallowMount(TicketsTable, { propsData: { tickets: tickets } });
  }

  it("pinta una fila por ticket recibido", function () {
    var wrapper = build();

    // NO contamos <tr> por su tag ni por clase de Bootstrap: contamos anclas.
    expect(wrapper.findAll('[data-testid^="ticket-row-"]')).toHaveLength(2);
  });

  it("muestra el título de cada ticket (comportamiento observable)", function () {
    var wrapper = build();

    // El usuario ve el título. Cómo esté maquetado no importa.
    expect(wrapper.text()).toContain("No arranca el server");
    expect(wrapper.text()).toContain("Error 500 en login");
  });

  it("al hacer clic en una fila emite 'select' con el ticket completo", function () {
    var wrapper = build();

    wrapper.find('[data-testid="ticket-row-2"]').trigger("click");

    // El CONTRATO con el padre: nombre del evento + payload. Esto no cambia
    // aunque la fila se convierta en <QTr> o en lo que sea.
    expect(wrapper.emitted("select")).toHaveLength(1);
    expect(wrapper.emitted("select")[0]).toEqual([tickets[1]]);
  });
});
```

**🔎 Qué hace:** congela las tres cosas que el dashboard promete al resto del
sistema —una fila por ticket, el título visible, y `select` con el ticket al
hacer clic— **sin mirar una sola clase de Bootstrap**. Fíjate en el selector
`[data-testid^="ticket-row-"]` (prefijo): cuenta filas por su rol, no por su
tag `<tr>`, que la migración podría cambiar.

**✅ Buenas prácticas aplicadas:**
- **Cero selectores de clase.** Si mañana `<tr class="...">` pasa a
  `<q-tr class="...">`, estos tests siguen verdes porque nunca miraron el tag ni
  la clase.
- El test de `select` prueba el **contrato de evento**, la parte más frágil de
  cualquier migración: es lo que el padre escucha, y si se rompe, se rompe en
  silencio hasta que un clic no navega a ningún lado.
- Fixtures mínimos: cada ticket tiene solo lo que la tabla lee. Nada copiado de
  `db.json`.

### Test 2 — regresión del dashboard: contrato con el store (F4)

`tests/unit/regression/TicketsView.store-contract.spec.js`

```js
import { shallowMount, createLocalVue } from "@vue/test-utils";
import Vuex from "vuex";
import TicketsView from "@/views/TicketsView.vue";

var localVue = createLocalVue();
localVue.use(Vuex);

describe("REGRESIÓN · TicketsView ↔ store (F4/F10)", function () {
  var actions;
  var store;

  beforeEach(function () {
    // Store de LABORATORIO: acciones espía, getters mínimos. No importamos el
    // store real; construimos el mínimo que la vista consume.
    actions = {
      fetchTickets: jest.fn().mockResolvedValue([])
    };
    store = new Vuex.Store({
      modules: {
        tickets: {
          namespaced: true,
          actions: actions,
          getters: {
            all: function () { return []; },
            loading: function () { return false; },
            error: function () { return null; }
          }
        }
      }
    });
  });

  it("al montar, despacha fetchTickets (la vista pide sus datos al store)", function () {
    shallowMount(TicketsView, { localVue: localVue, store: store });

    // El CONTRATO con el store: se despacha la acción esperada. Da igual dónde
    // viva la vista tras migrar: si deja de pedir sus datos, este test truena.
    expect(actions.fetchTickets).toHaveBeenCalledTimes(1);
  });

  it("el botón de reintento vuelve a despachar la carga de tickets", function () {
    var wrapper = shallowMount(TicketsView, { localVue: localVue, store: store });

    // Suponiendo data-testid="retry" en el botón de error (siémbralo como los otros)
    wrapper.find('[data-testid="retry"]').trigger("click");

    // El CONTRATO mínimo: reintentar vuelve a pedir. Que se despache OTRA VEZ.
    expect(actions.fetchTickets).toHaveBeenCalledTimes(2);
  });
});
```

**🔎 Qué hace:** verifica que la vista **habla bien con el store** —despacha la
carga al montar, y **otra vez** al reintentar— usando un store de juguete con
acciones espía. Es el patrón de F11 (ejercicio 17: `createLocalVue` + store
mínimo) puesto al servicio de la migración.

> ⚠️ **Sobre el payload `{ force: true }`.** Si integraste el reintento con el
> caché de `fetchTickets` de F10 (el `!options.force` que salta el caché), añade
> `expect(actions.fetchTickets.mock.calls[1][1]).toEqual({ force: true })` y lo
> clavas también. Pero **el F4 a pelo tal cual salió de la fase reintenta
> llamando a `loadTickets` sin payload** —el botón "Reintentar" de F4 solo
> vuelve a llamar la carga—. Aquí congelamos el contrato mínimo (*reintentar
> vuelve a pedir*), que es el que sobrevive tengas o no la integración con el
> store de F10. Afirma el payload solo si tu vista de verdad lo manda.

**✅ Buenas prácticas aplicadas:**
- **Store de laboratorio, no el real.** Construyes el mínimo que la vista toca.
  Si importaras el store real, un cambio en cualquier módulo podría teñir de
  rojo este test por razones ajenas a la vista.
- Se afirma el **comportamiento** (se vuelve a despachar), no un detalle de
  implementación que tu F4 quizá no tenga. La coreografía con el store es el
  contrato; el payload exacto es letra chica que se clava **si existe**.
- ⚠️ **Ojo con el entorno.** Este test monta `TicketsView`, que en la vida real
  arrastra el guard del router y —transitivamente— código que lee
  `localStorage`. En jsdom eso pasa. Guárdate ese detalle: es la semilla del
  test 5.

### Test 3 — regresión del CRUD: el formulario emite bien (F5)

`tests/unit/regression/TicketForm.regression.spec.js`

```js
import { mount, createLocalVue } from "@vue/test-utils";
import Vuelidate from "vuelidate";
import TicketForm from "@/components/tickets/TicketForm.vue";

var localVue = createLocalVue();
localVue.use(Vuelidate); // vuelidate se registró global en F5

describe("REGRESIÓN · TicketForm (F5)", function () {
  function build(initial) {
    return mount(TicketForm, {
      localVue: localVue,
      propsData: { initialTicket: initial || null }
    });
  }

  it("con datos válidos, emite 'submit' con el ticket limpio", function () {
    var wrapper = build();

    wrapper.find('[data-testid="form-title"]').setValue("Bug en el filtro");
    wrapper.find('[data-testid="form-description"]').setValue("No filtra por estado");
    wrapper.find('[data-testid="form-submit"]').trigger("submit");

    // Contrato con la vista padre: nombre del evento + forma del payload.
    expect(wrapper.emitted("submit")).toHaveLength(1);
    expect(wrapper.emitted("submit")[0][0]).toMatchObject({
      title: "Bug en el filtro",
      description: "No filtra por estado"
    });
  });

  it("sin título, NO emite 'submit' y muestra el error", function () {
    var wrapper = build();

    wrapper.find('[data-testid="form-submit"]').trigger("submit");

    // El negativo es tan contrato como el positivo: submit inválido no propaga.
    expect(wrapper.emitted("submit")).toBeUndefined();
    // El usuario VE un error (texto observable, no clase de vuelidate).
    expect(wrapper.text()).toContain("El título es obligatorio");
  });

  it("en modo edición, precarga los datos del ticket inicial", function () {
    var wrapper = build({ id: 7, title: "Existente", description: "ya estaba" });

    // Comportamiento: el campo llega con el valor. Cómo lo clona por dentro
    // (created vs mounted) es implementación —no lo tocamos.
    expect(wrapper.find('[data-testid="form-title"]').element.value).toBe("Existente");
  });
});
```

**🔎 Qué hace:** clava el contrato del formulario por sus tres caras —emite
`submit` limpio con datos válidos, **no** emite y muestra error con datos
inválidos, y precarga en edición— mediante lo que el usuario hace (teclear,
enviar) y ve (el mensaje de error), nunca mediante el estado interno de `$v`.

**✅ Buenas prácticas aplicadas:**
- Aquí sí usamos `mount` (no `shallow`): el test **es** sobre la colaboración
  del form con vuelidate y sus inputs reales. F11 lo dijo: shallow por defecto,
  mount cuando el test es sobre la integración.
- El caso inválido afirma un **negativo** (`emitted` es `undefined`) y un
  **observable** (el texto del error), no `$v.form.title.$invalid`. Si mañana se
  cambia vuelidate por otra cosa, el test sobrevive.
- `toMatchObject` en vez de `toEqual`: el payload puede traer campos extra
  (status por defecto, etc.) sin romper el test. Congelamos lo que importa, no
  la forma exacta.

### Test 4 — regresión del CRUD: contrato con la API (F5)

`tests/unit/regression/ticketService.contract.spec.js`

```js
import ticketService from "@/services/ticketService";
import apiClient from "@/services/apiClient";

jest.mock("@/services/apiClient"); // el cable a axios, cortado

describe("REGRESIÓN · ticketService ↔ API (F3/F5)", function () {
  beforeEach(function () {
    jest.clearAllMocks();
  });

  it("createTicket hace POST /tickets con el payload íntegro y devuelve data", function () {
    apiClient.post.mockResolvedValue({ data: { id: 99, title: "nuevo" } });

    var payload = { title: "nuevo", description: "desc", status: "open" };

    return ticketService.createTicket(payload).then(function (result) {
      // El CONTRATO con la API: verbo + ruta + cuerpo idénticos.
      expect(apiClient.post).toHaveBeenCalledWith("/tickets", payload);
      // Y devuelve res.data pelado, no la respuesta axios cruda.
      expect(result).toEqual({ id: 99, title: "nuevo" });
    });
  });

  it("updateTicket hace PATCH /tickets/:id con los cambios", function () {
    apiClient.patch.mockResolvedValue({ data: { id: 7, status: "resolved" } });

    return ticketService.updateTicket(7, { status: "resolved" }).then(function () {
      expect(apiClient.patch).toHaveBeenCalledWith("/tickets/7", { status: "resolved" });
    });
  });

  it("deleteTicket hace DELETE /tickets/:id", function () {
    apiClient.delete.mockResolvedValue({ status: 200 });

    return ticketService.deleteTicket(7).then(function () {
      expect(apiClient.delete).toHaveBeenCalledWith("/tickets/7");
    });
  });
});
```

**🔎 Qué hace:** blinda el contrato más estable y más valioso para Nuxt —la
forma exacta de cada petición HTTP— mockeando `apiClient`. Cuando en NX3 el
servidor Node empiece a hacer estas mismas llamadas, este test es tu garantía
de que la petición no cambió de forma al mudarse de entorno.

**✅ Buenas prácticas aplicadas:**
- Mockea `apiClient`, **no** axios ni la red: cada capa se prueba contra un
  doble de su vecina de abajo (la lección de "dónde mockear" de F11).
- Verifica ambas direcciones del contrato: lo que **manda** (verbo, ruta,
  cuerpo) y lo que **devuelve** (`res.data` pelado). Un refactor que devolviera
  la respuesta cruda de axios rompería tres vistas —aquí suena la alarma primero.
- `return` en cada test async: sin él, verde falso (F11, tercera aparición de la
  misma trampa).

### Test 5 — ⭐ el test que demuestra el agujero

Y ahora el corazón de la fase. Este test **pasa en verde**, y esa es
exactamente la mala noticia.

`tests/unit/regression/auth-guard.regression.spec.js`

```js
// El guard del router (F2) lee localStorage directamente:
//
//   router.beforeEach(function (to, from, next) {
//     var token = localStorage.getItem("token");   // ⚠️ toca window
//     ...
//   });
//
// Extraemos la función a un módulo testeable (como en F11, ej. 19) y la
// probamos. En jsdom, localStorage EXISTE. El test pasa feliz.

import { authGuard } from "@/router/authGuard";

describe("REGRESIÓN · authGuard (F2) — y la mentira de jsdom", function () {
  beforeEach(function () {
    // jsdom nos deja hacer esto. Node NO tendría window.localStorage siquiera.
    window.localStorage.clear();
  });

  it("sin token, redirige a /login", function () {
    var next = jest.fn();
    var to = { path: "/tickets", matched: [{ meta: { requiresAuth: true } }] };

    authGuard(to, {}, next); // ← lee localStorage.getItem("token") por dentro

    expect(next).toHaveBeenCalledWith("/login");
  });

  it("con token, deja pasar", function () {
    window.localStorage.setItem("token", "mock-jwt-token-123");
    var next = jest.fn();
    var to = { path: "/tickets", matched: [{ meta: { requiresAuth: true } }] };

    authGuard(to, {}, next);

    expect(next).toHaveBeenCalledWith(); // next() sin args = pasa
  });
});
```

Corre esto: **verde**. Ahora simula el servidor —lo que Nuxt hará en NX2— y
mira qué pasa cuando `window` no está. Añade este bloque al mismo archivo:

```js
describe("⚠️ el mismo guard, en un entorno SIN window (lo que hará Node)", function () {
  var realWindow;

  beforeEach(function () {
    // Amputamos localStorage para IMITAR el servidor Node dentro de jsdom.
    // Esto NO es cómo se testea SSR de verdad (eso es NX2+); es una
    // DEMOSTRACIÓN de que tus tests actuales viven en el entorno equivocado.
    realWindow = global.window.localStorage;
    Object.defineProperty(global.window, "localStorage", {
      get: function () { throw new ReferenceError("localStorage is not defined"); },
      configurable: true
    });
  });

  afterEach(function () {
    Object.defineProperty(global.window, "localStorage", {
      value: realWindow, configurable: true, writable: true
    });
  });

  it("REVIENTA — el guard que pasaba en verde ahora tira ReferenceError", function () {
    var next = jest.fn();
    var to = { path: "/tickets", matched: [{ meta: { requiresAuth: true } }] };

    // Esta es la línea que en producción SSR lanzaría "window is not defined".
    // El test de arriba NUNCA la ejecutó en estas condiciones.
    expect(function () { authGuard(to, {}, next); }).toThrow(/localStorage is not defined/);
    expect(next).not.toHaveBeenCalled();
  });
});
```

**🔎 Qué hace:** el primer bloque es un test de regresión perfectamente normal y
verde. El segundo **amputa `localStorage`** para imitar al servidor Node, y
demuestra que la misma función, con el mismo input, **revienta** cuando el
entorno cambia. La conclusión no es "arréglalo" —eso es NX2—. La conclusión es:
*tu suite normal jamás ejercitó la línea peligrosa en el entorno donde va a
correr de verdad.*

**✅ Lo que te llevas de este test:**
- Un test verde **no** significa "el código funciona". Significa "el código
  funciona **en el entorno donde corrió el test**". En Q/VU esos dos entornos
  coinciden. En Nuxt, no.
- El bug no está en tu código todavía —el guard a pelo está bien para una SPA.
  El bug es **asumir un solo entorno**. Nuxt introduce el segundo, y tu red no
  lo cubre.
- Este es el `data-testid` de la fase entera: el ancla concreta de una idea
  abstracta. La red tiene un agujero, y lo acabas de tocar con las manos.

> 💸 **Deuda (recordatorio, ahora con el ojo puesto en el agujero):** este test
> "de servidor" es un truco didáctico, no la solución. Amputar `localStorage` a
> mano no escala: hay `window`, `document`, `navigator`, chart.js, socket.io…
> No vas a amputarlos uno por uno. La solución real es doble: **(a)** escribir
> el código para que sepa en qué entorno está (NX2: `process.client`,
> `mounted()`, cookies), y **(b)** un **e2e** que arranque el servidor Nuxt de
> verdad y lo ejercite. El unitario en jsdom se queda —es rápido y valioso—
> pero deja de ser tu única red.

---

## ✅ El checklist pre-migración

Antes de migrar **cualquier** pieza del Mini Jira a Nuxt, pasa esta lista. Es la
misma que en Q0/VU0 hasta el último punto, que es solo de Nuxt:

```
PRE-MIGRACIÓN — checklist de red de seguridad
──────────────────────────────────────────────
[ ] ¿La pieza tiene tests de REGRESIÓN antes de tocarla?
[ ] ¿Los tests se agarran de data-testid / texto / eventos,
    y NO de clases de Bootstrap ni estructura del DOM?
[ ] ¿Está clavado el contrato con el STORE (acción + payload)?
[ ] ¿Está clavado el contrato con la API (verbo + ruta + params)?
[ ] ¿Los casos NEGATIVOS están cubiertos (no emite, no llama)?
[ ] ¿Corren en verde ANTES de migrar? (si no, la foto está mal tomada)
[ ] ⭐ NUXT: ¿esta pieza toca window/document/localStorage/navigator?
    Si sí → tu test verde MIENTE sobre el servidor. Anótalo.
    Esa pieza es candidata segura a romperse en NX2.
```

El último punto es tu inventario de deuda: cada pieza que toca `window` es una
bomba que la red no desactiva. Tenerlas listadas **antes** de migrar es la mitad
del trabajo de NX2.

---

## ⚠️ Errores comunes

- **Escribir la red agarrándose de clases de Bootstrap.** `find(".badge-danger")`
  se siente robusto y muere en el primer commit de migración. Si un test mira una
  clase, pregúntate qué comportamiento representa esa clase y testea eso.
- **Creer que verde = seguro en Nuxt.** El error central de la ruta. Verde
  significa "seguro en jsdom". Es necesario y no suficiente. El test 5 existe
  para que nunca lo olvides.
- **Testear la estructura del DOM** (`div:nth-child(2)`): la maqueta se rehace
  entera al migrar. Ancla con `data-testid`.
- **Regar `data-testid` por todo el template.** Un ancla por cada cosa que un
  test interroga; ni una más. Los sobrantes son ruido que alguien borrará "por
  limpieza" y romperá tests.
- **Importar el store real en los tests de contrato.** Un cambio en un módulo
  ajeno tiñe de rojo la vista por razones que no son suyas. Store de
  laboratorio, mínimo.
- **Verde falso async** (F11, otra vez): sin `return` de la Promise, el test de
  servicio pasa aunque el contrato esté roto.
- **Intentar "arreglar" el agujero de `window` aquí.** No es esta fase. NX0 lo
  **muestra**; NX2 lo **tapa** (parcialmente). Adelantar la solución es saltarse
  la lección de por qué existe.
- **Escribir tests nuevos para features que no vas a migrar aún.** La red se teje
  donde vas a cortar —dashboard y CRUD primero—, no en todo el proyecto de
  entrada. Regresión donde hay migración inminente.

---

## 🧪 Ejercicios (26)

> Todos sobre el Mini Jira **a pelo**. Cero Nuxt hasta NX1. Options API,
> `function () {}`, VTU 1.x + Jest.

**🟢 Fácil (1–8)**

1. Siembra `data-testid` en las cuatro tarjetas de `TicketsSummary` del
   dashboard (F4) por estado (`metric-open`, `metric-resolved`, …) —son el
   `v-for="card in cards"`, no cuatro componentes sueltos— y escribe un test que
   verifique que la de "Abiertos" muestra el conteo correcto con un fixture de 3
   tickets. Prohibido usar selectores de clase.
2. Reescribe **un** test tuyo de F11 que use un selector de clase o de posición
   para que use `data-testid` o texto. Anota en un comentario qué migración
   habría roto la versión vieja.
3. Test de regresión de `TicketStatusBadge` (F4) por **texto y estado**, no por
   clase: "open" → muestra "Abierto"; estado desconocido → muestra el crudo. Sin
   tocar `badge-danger`.
4. Escribe el test negativo del formulario que falta: enviar con título de 2
   caracteres (viola `minLength`) **no** emite `submit` y muestra el mensaje de
   longitud. Solo texto observable.
5. En `ticketService.contract.spec`, añade el caso de `getTickets` con params de
   orden (`{ _sort: "createdAt", _order: "desc" }`) y verifica que salen tal cual
   en la petición.
6. Toma el checklist pre-migración y **táchalo** para el dashboard: ¿qué puntos
   ya cumples con los tests 1 y 2 de la fase, cuáles te faltan? Entrega la lista
   marcada.
7. Corre toda la suite de regresión en `--watch`, cambia a propósito el nombre
   del evento en `TicketsTable` (`select` → `pick`) y mira cuál test te atrapa.
   Restaura. ¿Por qué ese test es el guardián del contrato de migración?
8. Ejecuta el test 5 de la fase. Confirma con tus ojos: el bloque normal pasa,
   el bloque "sin window" también pasa (porque *espera* el throw). Escribe 3
   líneas explicando por qué "un test verde de un throw" no es una
   contradicción.

**🟡 Intermedio (9–17)**

9. Escribe el test de contrato con el store para el **CRUD** (F5): al enviar el
   formulario, `TicketFormView` (o la vista que orqueste) despacha
   `createTicket` con el payload limpio. Store de laboratorio, acción espía.
10. `data-testid` semánticos: renombra cualquier ancla que hayas puesto por
    posición (`row-2`, `btn-1`) a rol (`ticket-row-<id>`, `submit`). Justifica
    en una frase por qué el rol sobrevive al reordenamiento y la posición no.
11. Test de regresión del filtrado del dashboard (F4): con 4 tickets y
    `statusFilter = "open"`, `[data-testid="results-count"]` refleja el conteo
    filtrado. Prueba el **comportamiento** del computed, no su nombre.
12. Inventa un test que se rompería mal: escribe a propósito uno que se agarre de
    `.table-hover > tbody > tr:first-child`, hazlo pasar, y luego simula la
    migración renombrando el tag. Documenta el rojo. Reescríbelo bien. Entrega
    ambos y el diff.
13. Extrae el **interceptor de axios** de F2 (que también lee `localStorage`) a
    una función testeable y escríbele su test de regresión en jsdom (verde) —tal
    como el guard del test 5. Déjalo listo para el ejercicio 18.
14. Cubre el caso de error del contrato con la API: `createTicket` cuando
    `apiClient.post` rechaza —el servicio **re-lanza**, no se traga el error
    (dos ramas del `.then`, como en F11).
15. Test de regresión de `StatusActions` (F9) con `data-testid` por transición:
    `resolved` genera botones `action-closed` y `action-open`, el clic emite
    `change` con el destino. Hereda la confianza de `ticketTransitions.spec` —no
    re-verifiques qué transiciones existen.
16. Escribe el "test de inventario de deuda": un archivo `WINDOW-DEBT.md` que
    liste cada pieza del Mini Jira que toca `window`/`document`/`localStorage`
    (guard, interceptor, chart.js de F7, socket.io de F8) con la línea y fase
    exactas. Es el entregable del último punto del checklist.
17. Toma un test de F11 que use `mount` de un árbol grande y decide: para
    regresión de migración, ¿shallow o mount? Reescríbelo con la elección
    correcta y justifica en función de "¿el contrato que congelo depende de los
    hijos?".

**🟠 Difícil (18–23)**

18. Generaliza el test 5: escribe un helper `withoutWindow(fn)` que amputa
    `window.localStorage` (y restaura en `finally`), y úsalo para demostrar el
    agujero en **dos** piezas a la vez —el guard (test 5) y el interceptor
    (ejercicio 13). Un solo helper, dos víctimas. ¿Por qué esto **no** escala a
    chart.js y socket.io? (pista: no es solo `localStorage`).
19. El agujero al revés: escribe un test que pase en jsdom por una razón
    **falsa** —por ejemplo, un componente que usa `window.innerWidth` para
    decidir cuántas columnas pinta. En jsdom `innerWidth` tiene un valor por
    defecto (1024), así que el test "pasa"… pero en el servidor no hay ventana
    que medir. Documenta por qué este es más traicionero que el `throw` directo:
    no revienta, **pinta distinto** → hidratación rota (adelanto de NX2).
20. Simula un `describe.each` sobre dos "entornos" (`{ window: true }` y
    `{ window: false }`) para el guard, forzando el segundo con el helper del
    ejercicio 18. Un solo bloque de tests, dos entornos. Esto es —en miniatura y
    a mano— la idea del **entorno como variable de test** que Nuxt formaliza.
    ¿Qué te falta para que sea real y no un truco? (pista: un runner que corra de
    verdad en Node sin jsdom).
21. Contrato con el store bajo error: testea que cuando `fetchTickets` rechaza,
    la vista muestra el estado de error observable (`[data-testid="error"]` con
    texto) **y** el botón de reintento sigue despachando. Store de laboratorio
    con acción que rechaza.
22. Escribe la red de regresión **completa** de una tercera pieza a tu elección
    (panel de soporte F9, o el detalle de ticket): render observable + contrato
    store + contrato API + casos negativos + inventario de deuda de `window`.
    Pásala por el checklist entero y entrega el checklist marcado.
23. Falso positivo de `toEqual` vs `toMatchObject`: escribe un test de contrato
    de payload que rompe cuando el backend añade un campo inocuo (`createdAt`).
    Arréglalo con `toMatchObject` y argumenta cuándo `toEqual` (estricto) SÍ es
    lo correcto en un contrato (pista: cuando un campo de más **es** el bug).

**🔴 Muy difícil (24–26)**

24. **El experimento honesto de los dos entornos.** Configura un segundo proyecto
    de Jest (`jest.config.node.js`) con `testEnvironment: "node"` (¡sin jsdom!) y
    corre **la misma** `auth-guard.regression.spec.js` en ambos. Documenta en
    `TWO-ENVIRONMENTS.md`: qué tests pasan en jsdom y truenan en node, cuáles en
    ambos, y por qué esto es una demostración *real* (no amputación a mano) de
    que "el entorno es una variable de test". Este ejercicio es el puente físico
    a NX1. *(Nota: aún es cero Nuxt —solo dos entornos de Jest sobre el proyecto
    a pelo.)*
25. **El mapa de qué se rompe.** Sin instalar Nuxt, produce `SSR-RISK-MAP.md`:
    recorre el Mini Jira entero y clasifica cada módulo en 🟢 "sobrevive al
    servidor" / 🟡 "sobrevive si se mueve a `mounted()`" / 🔴 "necesita rediseño
    (auth, sockets)". Para cada 🔴/🟡, la línea exacta que toca `window` y la
    fase donde nació. Este documento es la agenda de trabajo de NX2 y NX3 —lo vas
    a tachar entero en las próximas fases.
26. **La red que sí cubriría el agujero (diseño, no implementación).** Escribe
    `E2E-PLAN.md`: ¿qué haría un e2e que el unitario en jsdom estructuralmente no
    puede? Especifica 3 escenarios concretos sobre el Mini Jira (p. ej. "cargar
    `/tickets` con el servidor apagado, verificar que el SSR no tira 500") que
    **solo** un test que arranque el servidor de verdad atraparía. Argumenta por
    qué, aun con e2e, **no borras** los unitarios. Estás escribiendo, hoy, la
    justificación de la deuda que la ruta arrastra hasta el final.

---

## 📚 Referencias

**Documentación oficial (la de la época)**

- Vue Test Utils **v1** (Vue 2): https://v1.test-utils.vuejs.org/
- VTU v1 — `emitted`, `find`, `trigger`: https://v1.test-utils.vuejs.org/api/wrapper/
- Jest — `testEnvironment` (jsdom vs node, ej. 24):
  https://jestjs.io/docs/configuration#testenvironment-string
- Jest — matchers (`toMatchObject`, `toEqual`): https://jestjs.io/docs/expect
- Jest — mock functions: https://jestjs.io/docs/mock-functions
- jsdom — qué implementa (y qué finge): https://github.com/jsdom/jsdom#readme
- MDN — `data-*` attributes (los `data-testid`):
  https://developer.mozilla.org/en-US/docs/Learn/HTML/Howto/Use_data_attributes

**Para el concepto de entorno dual (lectura de puente, aún NO Nuxt)**

- Nuxt 2 — Universal (SSR), visión general: https://v2.nuxt.com/docs/concepts/server-side-rendering
  (⚠️ dominio `v2.nuxt.com`: el raíz sirve Nuxt 3+). Solo léelo por encima —lo
  desmenuzamos en NX1.

**Orden de lectura sugerido:** repasa `emitted`/`trigger`/`find` de VTU → teje la
red de los tests 1–4 → llega al test 5 sin prisa → cierra con el ejercicio 24,
que es el que de verdad te enseña la lección con un runner real.

---

## 🚀 Cierre y puente a NX1

Sales de NX0 con dos cosas en la mano, y son opuestas a propósito.

La primera es una **red de seguridad de verdad**: el dashboard y el CRUD tienen
tests de regresión que se agarran de lo que no cambia —comportamiento, contrato
con el store, contrato con la API— y que sobrevivirán a que Nuxt les cambie las
tripas. Esa red es la misma que tejerían Q0 y VU0, y es tan buena como la de
ellos.

La segunda es la incómoda, y es la que define esta ruta: **sabes que la red
tiene un agujero.** Lo viste con tus manos en el test 5 y —si hiciste el
ejercicio 24— en un runner de verdad corriendo sin jsdom. Tus tests viven en un
entorno que tiene `window`; tu código va a vivir, la mitad del tiempo, en uno
que no. Verde no significa seguro. Significa seguro *aquí*.

En Q y VU esa frase no haría falta, porque allí "aquí" es el único sitio donde
el código corre. Que en Nuxt sí haga falta **es la información**: confirma, desde
la primera fase, que Nuxt no es del mismo molde. No estás cambiando de
componentes. Estás cambiando de **modelo de ejecución**.

> **NX1 — Leer Nuxt.** Ya sabes *que* la red tiene un agujero. Ahora vas a
> entender *por qué*: qué es un meta-framework, dónde quedó tu `main.js`, cómo
> el routing sale de una carpeta, y —el concepto que lo explica todo— por qué el
> ciclo de vida de tus componentes se ejecuta **dos veces**. El agujero del test
> 5 tiene un nombre, y en NX1 se lo ponemos. Todavía sin instalar nada: primero
> se lee, luego se rompe.
