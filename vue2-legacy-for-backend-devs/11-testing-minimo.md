# ✅ Fase 11 — Testing mínimo

## 🎯 Propósito

Última fase del contenido base, y la que convierte todo lo anterior en algo
que se puede **tocar sin miedo**. Porque el drama del legacy no es que el
código sea viejo — es que nadie se atreve a cambiarlo. Un puñado de tests
bien puestos transforma "ojalá no haya roto nada" en "el test me lo habría
dicho".

Esta fase NO es evangelio de TDD ni persecución de coverage. Es **testing de
mantenimiento**: lo mínimo que un dev backend (que probablemente ya testea
en su lenguaje) necesita para hacer lo mismo en un frontend Vue 2 —
Jest + vue-test-utils 1.x, el dúo de la época.

Y es también el **día de cobro** de nueve fases de decisiones: las funciones
puras de `utils/` (F7, F9), las mutations aburridas (F10), los servicios que
esconden axios (F3) y los componentes tontos (F4) se van a testear casi
solos. La arquitectura buena no se nota al escribirla — se nota hoy.

> La regla de la fase: testea primero lo que da miedo tocar,
> y testea cada cosa en la capa donde vive.

---

## ✅ Qué queda listo al terminar

- Jest corriendo con `npm run test:unit` (y modo watch para desarrollar);
- tests de **utils**: `ticketStats` y `ticketTransitions` — las funciones
  puras, con sus casos borde;
- tests del **store**: mutations directas y la action `fetchTickets` con el
  servicio mockeado (éxito, error y caché);
- tests de **servicio**: `ticketService` con `apiClient` mockeado;
- tests de **componentes**: un presentacional (badge) y uno con eventos
  (`StatusActions`);
- el flujo de trabajo del bug en legacy: **reproducir con test → arreglar →
  el test queda de guardia**;
- criterio de qué testear primero (y qué no testear) en una base heredada.

## 🚫 Qué NO entra todavía

- e2e (Cypress/Selenium): otra disciplina, se menciona el mapa;
- coverage como meta ("80% o muerte") — medirlo sí, perseguirlo no;
- CI/CD (correr tests en pipeline: una línea, pero fuera de alcance);
- snapshot testing (aparece como ejercicio 🟡, con sus advertencias);
- testear el wizard o el panel completos: integración pesada, ejercicios 🔴.

> ⚠️ **Nota sobre las vistas.** Los tests de `TicketsView`, `TicketsTable` y
> `TicketForm` viven en los ejercicios 🟠 (18, 22) — es decir, en la zona
> **opcional**. La regla de la fase ("testea primero lo que da miedo tocar")
> te deja saltártelos, y mucha gente lo hace. Recuérdalo: **la única parte del
> Mini Jira que puede quedar sin red es exactamente la que más caro sale
> reescribir.** Volveremos a esto en el cierre.

---

## 🧠 Concepto 1: qué testear primero en legacy (la pirámide pragmática)

La pirámide clásica (muchos unit, menos integración, poquitos e2e) es cierta
pero abstracta. Para una base heredada, la versión operativa es **retorno
por esfuerzo**:

| Capa | Esfuerzo de testear | Qué atrapa | En Mini Jira |
|---|---|---|---|
| 🥇 Funciones puras (`utils/`) | trivial: entra dato, sale dato | lógica de negocio pura | `ticketStats`, `ticketTransitions` |
| 🥈 Mutations del store | trivial: son asignaciones | corrupción del estado compartido | `UPSERT_TICKET` y familia |
| 🥉 Actions y servicios | medio: hay que mockear la frontera | orquestación, contratos con la API | `fetchTickets`, `ticketService` |
| 🏅 Componentes | medio-alto: montar, DOM simulado | render, props, eventos | badges, `StatusActions` |
| 🎖️ Vistas completas / e2e | alto | integración real | (ejercicios) |

Dos corolarios que valen oro en legacy:

- **La testeabilidad es un detector de diseño.** Si algo cuesta muchísimo
  testear (un componente que hace HTTP, navega Y agrega datos), el problema
  no es el test: es que esa pieza tiene tres responsabilidades. Extraer la
  lógica a una función pura o un servicio la vuelve testeable *y* mejor.
  En una base ajena, "no puedo testear esto" es el mapa de dónde refactorizar.
- **Testea comportamiento, no implementación.** El test de `StatusActions`
  verifica "muestra estos botones y emite esto al clic" — no "tiene un
  computed llamado `available`". Si mañana refactorizas las tripas y el
  comportamiento se mantiene, el test debe seguir en verde. Tests pegados a
  la implementación se rompen con cada refactor y terminan borrados (destino
  real del 90% de los tests frágiles en legacy).

## 🧠 Concepto 2: la anatomía de un test (AAA)

Todo test decente tiene tres actos — y nombrarlos ordena la cabeza:

```js
it("cuenta los tickets por estado", function () {
  // ARRANGE: prepara el mundo
  var tickets = [
    { status: "open" }, { status: "open" }, { status: "resolved" }
  ];

  // ACT: ejecuta LO ÚNICO que estás probando
  var result = countByStatus(tickets);

  // ASSERT: verifica
  expect(result).toEqual({ open: 2, resolved: 1 });
});
```

Y el vocabulario mínimo de Jest:

| Pieza | Qué hace |
|---|---|
| `describe("bloque", fn)` | agrupa tests relacionados (por función, por componente) |
| `it("hace X", fn)` / `test(...)` | un caso de prueba; el nombre completa la frase "it..." |
| `expect(valor).toBe(x)` | igualdad estricta (`===`) — para primitivos |
| `expect(valor).toEqual(x)` | igualdad **estructural** — para objetos y arrays |
| `expect(fn).toHaveBeenCalledWith(x)` | para espías/mocks: ¿lo llamaron y cómo? |
| `beforeEach(fn)` | arrange compartido, corre antes de cada `it` |

`toBe` vs `toEqual` es el primer tropiezo de todo el mundo: dos objetos con
el mismo contenido NO son `toBe` (referencias distintas) pero SÍ son
`toEqual`. Para datos: `toEqual`, casi siempre.

---

## 🧩 Mini repaso: las herramientas nuevas de esta fase

### vue-test-utils — montar componentes en probeta

La librería oficial (v1.x para Vue 2) monta componentes en un DOM simulado
(jsdom) y te da un `wrapper` para interrogarlos:

```js
import { shallowMount } from "@vue/test-utils";

var wrapper = shallowMount(TicketStatusBadge, {
  propsData: { status: "open" }
});

wrapper.text();                    // el texto renderizado
wrapper.classes();                 // las clases del elemento raíz
wrapper.find("button");            // buscar en el DOM interno
wrapper.findAll("button");         // todos
wrapper.trigger("click");          // disparar un evento nativo
wrapper.emitted("change");         // qué eventos personalizados emitió (¡y con qué payload!)
wrapper.setProps({ status: "x" }); // cambiar props (devuelve Promise en v1)
```

**`shallowMount` vs `mount`:** shallow reemplaza los componentes hijos por
stubs vacíos — pruebas al componente SOLO, sin que un bug del hijo te
contamine el test (y sin montar medio árbol). `mount` renderiza todo el árbol
real. Regla práctica: **shallow por defecto; mount cuando el test ES sobre
la colaboración con los hijos.** En legacy verás mounts gigantes que tardan y
fallan por hijos ajenos: ahora sabes por qué duelen.

### `jest.mock` — cortar el cable en la frontera

La instrucción más importante de la fase. Le dice a Jest: *cuando alguien
importe este módulo, dale esta versión falsa*:

```js
jest.mock("@/services/ticketService"); // auto-mock: todas sus funciones son jest.fn()
import ticketService from "@/services/ticketService";

// y ahora cada función es programable:
ticketService.getTickets.mockResolvedValue([{ id: 1 }]); // Promise que resuelve
ticketService.getTickets.mockRejectedValue(new Error()); // Promise que rechaza

// y espiable:
expect(ticketService.getTickets).toHaveBeenCalledWith({ _sort: "createdAt", _order: "desc" });
```

Detalle técnico que confunde a todos la primera vez: `jest.mock` se
**iza** (hoisting) arriba del archivo — por eso funciona aunque esté escrito
después del import. Y entre tests, `jest.clearAllMocks()` en un `beforeEach`
para que las llamadas de un test no contaminen al siguiente (olvidar esto =
tests que pasan solos y fallan en conjunto, un clásico desquiciante).

**Dónde mockear es LA decisión:** el test del store mockea el *servicio*
(prueba orquestación, no HTTP); el test del servicio mockea *apiClient*
(prueba el contrato con axios, no la red). Cada capa se prueba contra un
doble de su vecina de abajo — nunca contra la red real.

### Async en tests — la trampa del verde falso

Un test con Promises que no se esperan **pasa aunque todo falle**: Jest
termina el `it` antes de que el `.then` corra, y los expects de adentro
nunca se ejecutan. Verde mentiroso. 💀 La cura: **devolver la Promise**:

```js
it("carga tickets", function () {
  ticketService.getTickets.mockResolvedValue([{ id: 1 }]);

  return actions.fetchTickets(context).then(function () { // ← el return ES el test
    expect(context.commit).toHaveBeenCalledWith("SET_TICKETS", [{ id: 1 }]);
  });
});
```

Si Jest recibe una Promise devuelta, espera a que resuelva (y falla el test
si rechaza o si un expect interno truena). Es la versión testing del `return`
en actions de la Fase 3/10 — la misma lección, tercera aparición: **las
Promises que no se devuelven se pierden en silencio.**

### `createLocalVue` — un Vue de laboratorio

Para tests que necesitan plugins (Vuex, Router) sin contaminar el Vue global:

```js
import { createLocalVue, shallowMount } from "@vue/test-utils";
import Vuex from "vuex";

var localVue = createLocalVue();
localVue.use(Vuex); // el use vive SOLO en esta copia
```

Lo usaremos poco (los tests directos de mutations/actions no montan nada),
pero es la pieza que necesitas para testear componentes que leen del store
(ejercicio 17).

---

## 💻 Código de la fase

### Instalación — la vía Vue CLI (la de la época)

```bash
vue add unit-jest
```

El plugin `@vue/cli-plugin-unit-jest` instala y configura todo el combo
compatible entre sí — Jest, `vue-jest` (compila los `.vue` para Jest),
`babel-jest`, `@vue/test-utils` — y agrega:

```json
{
  "scripts": {
    "test:unit": "vue-cli-service test:unit"
  }
}
```

> ⚠️ **No subas versiones a mano.** El cuarteto Jest / vue-jest / babel-jest
> / test-utils es notoriamente quisquilloso entre versiones; el plugin trae
> una combinación probada. En legacy, "actualicé Jest y explotó todo" es un
> género literario propio.

Convenciones que deja: los tests viven en `tests/unit/` con sufijo
`.spec.js`, y el alias `@` → `src/` funciona también en tests. Modo watch
para desarrollar: `npm run test:unit -- --watch`.

### Test 1 — funciones puras: `tests/unit/ticketStats.spec.js`

```js
import { countByStatus, resolvedPercent } from "@/utils/ticketStats";

describe("ticketStats", function () {
  describe("countByStatus", function () {
    it("cuenta los tickets por estado", function () {
      var tickets = [
        { status: "open" },
        { status: "open" },
        { status: "resolved" }
      ];

      expect(countByStatus(tickets)).toEqual({ open: 2, resolved: 1 });
    });

    it("devuelve objeto vacío sin tickets", function () {
      expect(countByStatus([])).toEqual({});
    });
  });

  describe("resolvedPercent", function () {
    it("calcula el porcentaje de resueltos y cerrados", function () {
      var tickets = [
        { status: "resolved" },
        { status: "closed" },
        { status: "open" },
        { status: "open" }
      ];

      expect(resolvedPercent(tickets)).toBe(50);
    });

    it("devuelve 0 con lista vacía (sin dividir por cero)", function () {
      expect(resolvedPercent([])).toBe(0);
    });

    it("redondea al entero más cercano", function () {
      var tickets = [{ status: "resolved" }, { status: "open" }, { status: "open" }];
      expect(resolvedPercent(tickets)).toBe(33); // 33.33... → 33
    });
  });
});
```

**🔎 Qué hace:** prueba las funciones de la Fase 7 con datos mínimos
inventados — nota que los tickets de prueba solo tienen `status`: **el
mínimo dato que la función necesita**, nada de objetos completos copiados de
`db.json`.

**✅ Buenas prácticas aplicadas:**
- **Los casos borde son el test**: la lista vacía (¿división por cero?) y el
  redondeo valen más que el caso feliz — el caso feliz lo probaste a ojo al
  desarrollar; los bordes son donde el legacy sangra.
- Fixtures mínimos: un test que arma objetos de 9 campos para probar una
  función que lee 1 es ruido — y se rompe cuando el modelo cambia en campos
  que ni le importan.
- Cero mocks, cero montaje, cero async: **este es el premio de la Fase 7**.
  Si estas funciones vivieran como methods de `MetricsView`, este archivo
  necesitaría montar la vista, mockear el servicio y el store. Extraer lógica
  pura no era estética: era esto.

### Test 2 — la máquina de estados: `tests/unit/ticketTransitions.spec.js`

```js
import { nextStatuses, TRANSITIONS } from "@/utils/ticketTransitions";

describe("ticketTransitions", function () {
  it("un ticket abierto solo puede pasar a en progreso", function () {
    expect(nextStatuses("open")).toEqual(["in_progress"]);
  });

  it("un ticket resuelto puede cerrarse o reabrirse", function () {
    expect(nextStatuses("resolved")).toEqual(["closed", "open"]);
  });

  it("un estado desconocido no ofrece transiciones (y no revienta)", function () {
    expect(nextStatuses("estado-corrupto")).toEqual([]);
    expect(nextStatuses(undefined)).toEqual([]);
  });

  it("ningún estado permite quedarse donde está", function () {
    Object.keys(TRANSITIONS).forEach(function (status) {
      expect(TRANSITIONS[status]).not.toContain(status);
    });
  });
});
```

**✅ La joya está en el último test:** no prueba un caso — prueba una
**invariante** del negocio ("no hay auto-transiciones") recorriendo el mapa
completo. Si alguien agrega mañana `waiting: ["waiting", ...]` por error de
copy-paste, este test lo atrapa sin que nadie haya previsto ese estado. Los
tests de invariantes son los guardianes más baratos que existen.

### Test 3 — el store: `tests/unit/store-tickets.spec.js`

```js
import ticketsModule from "@/store/modules/tickets";
import ticketService from "@/services/ticketService";

jest.mock("@/services/ticketService"); // el cable a HTTP, cortado

var mutations = ticketsModule.mutations;
var actions = ticketsModule.actions;

describe("store/tickets", function () {
  describe("mutations", function () {
    it("UPSERT_TICKET inserta si el ticket no existe", function () {
      var state = { items: [{ id: 1, title: "viejo" }] };

      mutations.UPSERT_TICKET(state, { id: 2, title: "nuevo" });

      expect(state.items).toHaveLength(2);
      expect(state.items[0].id).toBe(2); // unshift: el nuevo va primero
    });

    it("UPSERT_TICKET reemplaza si el ticket ya existe", function () {
      var state = { items: [{ id: 1, status: "open" }] };

      mutations.UPSERT_TICKET(state, { id: 1, status: "resolved" });

      expect(state.items).toHaveLength(1);
      expect(state.items[0].status).toBe("resolved");
    });
  });

  describe("actions/fetchTickets", function () {
    var context;

    beforeEach(function () {
      jest.clearAllMocks(); // que un test no herede llamadas del anterior
      context = {
        commit: jest.fn(),           // espía: registra cada commit
        state: { items: [] }
      };
    });

    it("en éxito: enciende loading, guarda tickets, apaga loading", function () {
      var fakeTickets = [{ id: 1 }];
      ticketService.getTickets.mockResolvedValue(fakeTickets);

      return actions.fetchTickets(context).then(function () {
        expect(context.commit).toHaveBeenCalledWith("SET_LOADING", true);
        expect(context.commit).toHaveBeenCalledWith("SET_TICKETS", fakeTickets);
        expect(context.commit).toHaveBeenCalledWith("SET_LOADING", false);
      });
    });

    it("en error: guarda el mensaje, apaga loading y RE-LANZA", function () {
      ticketService.getTickets.mockRejectedValue(new Error("boom"));

      return actions.fetchTickets(context).then(
        function () { throw new Error("no debió resolver"); },
        function () { // rama de rechazo: aquí DEBE caer
          expect(context.commit).toHaveBeenCalledWith(
            "SET_ERROR", "No se pudieron cargar los tickets."
          );
          expect(context.commit).toHaveBeenCalledWith("SET_LOADING", false);
        }
      );
    });

    it("con caché: si hay items y no hay force, NO toca la red", function () {
      context.state.items = [{ id: 1 }];

      return actions.fetchTickets(context).then(function (result) {
        expect(ticketService.getTickets).not.toHaveBeenCalled();
        expect(context.commit).not.toHaveBeenCalled();
        expect(result).toEqual([{ id: 1 }]);
      });
    });
  });
});
```

**🔎 Qué hace:** las mutations se prueban **como las funciones que son** —
un state de juguete, la llamada, los asserts; ni store real ni Vue. La action
se invoca con un `context` falso donde `commit` es un espía (`jest.fn()`):
el test verifica la **coreografía de commits**, que es exactamente la
responsabilidad de una action.

**✅ Buenas prácticas aplicadas:**
- Este archivo es el **día de cobro de la Fase 10**: mutations aburridas =
  tests de tres líneas; action que devuelve la Promise = test que puede
  esperarla; servicio separado = un solo `jest.mock` y cero red. Cada regla
  de diseño de la F10 compró una línea menos aquí.
- El test del error verifica el **re-lanzamiento** usando las dos ramas del
  `.then(onOk, onError)` — si la action se tragara el error (quitando el
  `throw`), la primera rama fallaría el test. El contrato "dos niveles de
  manejo" de la F10, ahora vigilado.
- El test de caché afirma **negativos** (`not.toHaveBeenCalled`): tan
  importante probar lo que NO debe pasar como lo que sí. El caché que "a
  veces igual llama a la red" es un bug invisible sin este assert.
- `beforeEach` + `clearAllMocks`: cada test parte de cero. Los tests que
  dependen del orden son bombas de relojería.

### Test 4 — el servicio: `tests/unit/ticketService.spec.js`

```js
import ticketService from "@/services/ticketService";
import apiClient from "@/services/apiClient";

jest.mock("@/services/apiClient"); // el cable a axios, cortado

describe("ticketService", function () {
  beforeEach(function () {
    jest.clearAllMocks();
  });

  it("getTickets pide /tickets con los params y devuelve res.data", function () {
    apiClient.get.mockResolvedValue({ data: [{ id: 1 }], status: 200 });

    return ticketService.getTickets({ status: "open" }).then(function (result) {
      expect(apiClient.get).toHaveBeenCalledWith("/tickets", {
        params: { status: "open" }
      });
      expect(result).toEqual([{ id: 1 }]); // data pelada, NO la respuesta axios
    });
  });

  it("updateTicket usa PATCH a la ruta con el id", function () {
    apiClient.patch.mockResolvedValue({ data: { id: 5, status: "resolved" } });

    return ticketService.updateTicket(5, { status: "resolved" }).then(function (result) {
      expect(apiClient.patch).toHaveBeenCalledWith("/tickets/5", { status: "resolved" });
      expect(result.status).toBe("resolved");
    });
  });
});
```

**🔎 Qué hace:** prueba el **contrato** del servicio por ambos lados — hacia
abajo (llama a apiClient con la ruta, el verbo y los params correctos) y
hacia arriba (devuelve `res.data`, no el objeto de axios). Ese contrato es
exactamente lo que las vistas y el store asumen: si alguien lo rompe (un
refactor que devuelve la respuesta cruda), aquí suena la alarma antes de que
tres vistas revienten.

### Test 5 — componente presentacional: `tests/unit/TicketStatusBadge.spec.js`

```js
import { shallowMount } from "@vue/test-utils";
import TicketStatusBadge from "@/components/tickets/TicketStatusBadge.vue";

describe("TicketStatusBadge", function () {
  function build(status) {
    return shallowMount(TicketStatusBadge, { propsData: { status: status } });
  }

  it("muestra el label y el color de un estado conocido", function () {
    var wrapper = build("open");

    expect(wrapper.text()).toBe("Abierto");
    expect(wrapper.classes()).toContain("badge-danger");
  });

  it("cae al fallback con un estado desconocido, sin romper", function () {
    var wrapper = build("estado-marciano");

    expect(wrapper.text()).toBe("estado-marciano"); // muestra el crudo
    expect(wrapper.classes()).toContain("badge-light");
  });
});
```

**✅ Buenas prácticas aplicadas:**
- El helper `build()` concentra el montaje: cuando el componente gane props,
  se toca una función y no doce tests. Factory de wrappers = el `beforeEach`
  con esteroides.
- Se prueba **lo que el usuario ve** (texto, clase de color), no el mapa
  interno `STATUS_MAP` — mañana el mapa puede volverse import de
  `statusColors` (ejercicio 9 de la F7) y estos tests siguen en verde.
  Comportamiento, no implementación: la promesa del Concepto 1, cumplida.
- El fallback tiene su test: el camino triste del componente (F4 lo diseñó
  a propósito) merece la misma vigilancia que el feliz.

### Test 6 — componente con eventos: `tests/unit/StatusActions.spec.js`

```js
import { shallowMount } from "@vue/test-utils";
import StatusActions from "@/components/support/StatusActions.vue";

describe("StatusActions", function () {
  it("genera un botón por transición válida del estado", function () {
    var wrapper = shallowMount(StatusActions, {
      propsData: { status: "resolved" } // resolved → [closed, open]
    });

    var buttons = wrapper.findAll("button");
    expect(buttons).toHaveLength(2);
    expect(buttons.at(0).text()).toContain("Cerrar");
    expect(buttons.at(1).text()).toContain("Reabrir");
  });

  it("al hacer clic emite change con el estado destino", function () {
    var wrapper = shallowMount(StatusActions, {
      propsData: { status: "open" }
    });

    wrapper.find("button").trigger("click");

    expect(wrapper.emitted("change")).toHaveLength(1);
    expect(wrapper.emitted("change")[0]).toEqual(["in_progress"]); // [payload]
  });

  it("con busy=true los botones quedan deshabilitados y no emiten", function () {
    var wrapper = shallowMount(StatusActions, {
      propsData: { status: "open", busy: true }
    });

    var button = wrapper.find("button");
    expect(button.attributes("disabled")).toBeDefined();

    button.trigger("click");
    expect(wrapper.emitted("change")).toBeUndefined(); // disabled no dispara click en jsdom
  });
});
```

**🔎 Qué hace:** verifica el ciclo completo del componente — render generado
desde la máquina de estados, la emisión con payload (`emitted("change")`
devuelve un array de llamadas, cada una un array de argumentos), y el
bloqueo por `busy`. Nota que **hereda** la confianza del test 2: no
re-verifica qué transiciones existen (eso ya lo vigila `ticketTransitions.spec`),
solo que el componente las traduce a botones — cada test en su capa, sin
solaparse.

---

## 🔄 El flujo de la fase: la vida de un bug en legacy (con tests)

El flujo paso a paso más valioso del capítulo no es cómo corre Jest — es
**cómo cambia tu día** cuando llega el bug de producción:

```
1. REPORTE: "el % de resueltos muestra NaN cuando no hay tickets"
   (imaginemos que resolvedPercent no protegía la división)

2. REPRODUCIR CON UN TEST (antes de tocar el código):
   it("devuelve 0 con lista vacía", ...) → npm run test:unit → 🔴 ROJO
   └─ el rojo CONFIRMA que entendiste el bug: si el test pasa,
      el bug está en otra parte y acabas de ahorrarte una tarde

3. ARREGLAR lo mínimo:
   if (tickets.length === 0) return 0;

4. VERIFICAR: → 🟢 verde el nuevo... y TODOS los demás siguen verdes
   └─ el resto de la suite acaba de certificar que tu fix no rompió nada

5. EL TEST SE QUEDA: commiteado junto al fix.
   Ese bug, ESE, no vuelve nunca sin hacer sonar la alarma.
```

Esto es un **test de regresión**, y es el 80% del testing real en
mantenimiento legacy: no naciste con la suite completa — la vas construyendo
bug a bug, exactamente donde la realidad demostró que hacía falta. Cada
incidente deja un guardián. A los seis meses, las zonas minadas del sistema
están cercadas por tests, y son precisamente las zonas que más los
necesitaban. La suite crece donde duele.

Y el flujo mecánico, para completar:

```
npm run test:unit
 └─ Jest descubre tests/unit/**/*.spec.js
    └─ babel-jest transpila el JS · vue-jest compila los .vue
       └─ cada archivo corre en un entorno jsdom (DOM simulado, sin navegador)
          └─ reporte: suites, tests, tiempo — y en rojo, el diff exacto
             expected vs received con la línea del expect que falló
```

Leer un test rojo es una habilidad: el diff de `toEqual` te muestra
exactamente qué campo difiere. Resiste el impulso de "hacer pasar el test" —
primero decide si el equivocado es el código o el test.

---

## ⚠️ Errores comunes

- **el verde falso**: test async sin `return` de la Promise — pasa siempre,
  no prueba nada. Si un test async nunca falla, sospecha;
- testear implementación (nombres de computed, estructura interna) → suite
  que se rompe con cada refactor y termina en `.skip` eterno o borrada;
- mocks sin `clearAllMocks` entre tests → llamadas fantasma de tests previos
  contaminando asserts (falla "en conjunto pero no solo": esta es la causa);
- fixtures gigantes copiados de datos reales: frágiles y ruidosos — el
  fixture mínimo documenta qué campos importan;
- `mount` de árboles enormes cuando `shallowMount` bastaba: tests lentos que
  fallan por hijos ajenos al caso;
- probar el framework ("cuando cambia la prop, el computed se recalcula" —
  eso lo garantiza Vue, no tu código);
- perseguir el 100% de coverage testeando getters triviales y templates,
  mientras la máquina de estados duerme sin un solo test de invariantes;
- selectores frágiles (`wrapper.find(".col-md-6 > div:nth-child(2)")`): un
  cambio de maquetación mata el test — busca por rol, texto o
  `data-testid` (ejercicio 12).

---

## 🧪 Ejercicios (26)

**🟢 Fácil (1–8)**

1. Escribe los tests de `activeByAgent` (F7): agrupa, excluye
   resueltos/cerrados, ordena descendente y etiqueta "(sin asignar)".
2. Testea `TicketPriorityBadge`: las tres prioridades y el fallback.
3. Corre `npm run test:unit -- --watch`, rompe a propósito `resolvedPercent`
   (cambia el redondeo) y mira la suite atraparte en vivo. Repara.
4. Testea el validador `oneOf` (F5/F6 — o el extraído a `utils/validators`
   si hiciste esa tarea): acepta valores de la lista, rechaza el resto.
5. Agrega a `ticketTransitions.spec` la invariante inversa: todo estado
   destino en `TRANSITIONS` existe como llave del mapa (no hay transiciones
   a estados fantasma).
6. Testea las mutations `SET_SESSION` y `CLEAR_SESSION` del módulo auth (F2).
7. Testea que `MetricCard` renderiza value y label, y que acepta tanto
   número como string en `value` (las dos variantes en dos tests).
8. Provoca el verde falso: quita el `return` de un test async del store,
   rompe el código que prueba, y confirma que el test... pasa igual. 😱
   Restaura el return y documenta el escalofrío en un comentario.

**🟡 Intermedio (9–17)**

9. Testea la action `login` del store auth (F3): mockea `authService`,
   verifica éxito (saveSession llamado + SET_SESSION commiteado) y rechazo
   (nada commiteado, error propagado).
10. Testea `commentService` (F9): params correctos con `_sort`, y que
    `create` POSTea el payload íntegro.
11. Testea `CommentBox` (F9): el contrato v-model completo — pinta la prop
    `value` en el textarea, emite `input` al teclear
    (`textarea.setValue("hola")`), emite `submit` solo con texto no vacío,
    y `sending` deshabilita el botón.
12. Refactor de selectores: agrega `data-testid` a los botones de
    `StatusActions` y reescribe sus tests con
    `find('[data-testid="..."]')`. Compara robustez contra los selectores
    por posición.
13. Testea `WizardProgress` (F6): con `current=2` de 3 pasos, el círculo 1
    muestra ✓, el 2 el número resaltado, el 3 apagado.
14. Snapshot testing, con juicio: `expect(wrapper.html()).toMatchSnapshot()`
    sobre el badge; rompe el color a propósito, mira el diff, actualiza con
    `-u`. Escribe 3 líneas: ¿por qué los snapshots masivos degeneran en
    "aprietas u sin mirar"?
15. Testea `SupportQueue` (F9) con `shallowMount`: la partición
    unassigned/mine con un fixture de 5 tickets, y que el clic en una fila
    emite `select` con el ticket correcto.
16. Testea la función pura `canTransition` del ejercicio 18 de la Fase 9
    (si lo hiciste): matriz de casos usuario × transición en una tabla de
    `it`s — o con `it.each` si tu Jest lo trae.
17. Componente + store: testea que `AppHeader` muestra el nombre del usuario
    usando `createLocalVue` + un store de juguete con solo el getter
    `currentUser`. No importes el store real: constrúyelo mínimo en el test.

**🟠 Difícil (18–23)**

18. Testea el flujo interno de `TicketForm` (F5): montarlo, `setValue` en
    los campos, `trigger("submit")` y verificar `emitted("submit")` con los
    datos limpios — y el caso inválido: submit sin datos NO emite y los
    mensajes de error aparecen en el HTML. (Vuelidate se registró global:
    necesitarás `localVue.use(Vuelidate)`.)
19. Testea el guard del router (F2/F9): extrae la función del `beforeEach` a
    un módulo exportable, y pruébala con `to/from/next` falsos — sin token
    redirige a login, con token y ruta de login redirige a home, con rol
    insuficiente redirige. (Extraer para testear: la testeabilidad
    detectando diseño, en vivo.)
20. Testea `socketService` (F8): mockea `socket.io-client` para que `io()`
    devuelva un socket falso con jest.fn()s; verifica idempotencia de
    `connect` (dos llamadas, un solo `io()`), que `disconnect` anula, y que
    `emit` sin conexión no revienta.
21. Timers falsos: testea el auto-ocultado del `LiveToast` (F8) con
    `jest.useFakeTimers()` — dispara el evento, avanza
    `jest.advanceTimersByTime(5000)`, verifica que se ocultó. Y el caso del
    reinicio: dos eventos seguidos, el timer parte de cero.
22. Test de integración de vista: `mount` (completo) de `TicketsView`
    post-refactor F10, con store real del módulo tickets + servicio
    mockeado: verifica spinner mientras carga, filas al resolver, y que
    escribir en el buscador filtra. Compara el costo de escribirlo y
    mantenerlo contra los unitarios equivalentes.
23. Testea el plugin de socket (F10): store real mínimo + `socketService`
    mockeado capturando los handlers registrados; invoca el handler a mano
    con un ticket falso y verifica que el state del store lo incorporó
    (UPSERT observable). Estás testeando el pegamento — la pieza que ningún
    test de capa cubre.

**🔴 Muy difícil (24–26)**

24. Coverage con criterio: corre Jest con `--coverage`, mira el reporte HTML,
    y escribe `COVERAGE-NOTES.md`: las 3 zonas rojas que SÍ ameritan tests
    (y por qué), y 3 zonas rojas que NO (y por qué). El entregable es el
    criterio, no el porcentaje.
25. El kata completo de regresión: pide a un compañero (o a tu yo malvado)
    que introduzca un bug sutil en `utils/` o el store sin decirte cuál.
    Encuéntralo SOLO corriendo y escribiendo tests (sin leer el diff).
    Cronométrate. Luego lee el diff y evalúa: ¿qué test faltante lo habría
    atrapado gratis?
26. El contrato como test: convierte tu `API-CONTRACT.md` (F3, ej. 26) en
    una suite `contract.spec.js` que valide contra json-server REAL
    (levantado en un puerto de test con un db fixture): cada endpoint
    responde la forma documentada (campos, tipos, códigos de error). Corre
    aparte de los unitarios (`test:contract`). Discute: ¿qué atrapa esto que
    los mocks jamás verán — y por qué aun así los unitarios no se reemplazan?

---

## 📚 Referencias

**Documentación oficial**

- Vue Test Utils **v1** (¡la de Vue 2!): https://v1.test-utils.vuejs.org/
- VTU v1 — guía de empezar: https://v1.test-utils.vuejs.org/guides/
- VTU v1 — API del wrapper: https://v1.test-utils.vuejs.org/api/wrapper/
- Jest — matchers (expect): https://jestjs.io/docs/expect
- Jest — funciones mock: https://jestjs.io/docs/mock-functions
- Jest — testing async: https://jestjs.io/docs/asynchronous
- Jest — timer mocks (ej. 21): https://jestjs.io/docs/timer-mocks
- Vue CLI — plugin unit-jest: https://cli.vuejs.org/core-plugins/unit-jest.html
- Vue 2 — Unit Testing (guía oficial de la época):
  https://v2.vuejs.org/v2/guide/unit-testing.html

**Video / apoyo**

- Vue Mastery — Unit Testing (era Vue 2): https://www.vuemastery.com/courses/
- Net Ninja / Academind — episodios de Jest + Vue Test Utils (verifica que
  usen VTU v1 / Vue 2)

**Orden de lectura sugerido:** Jest expect + mock functions → VTU getting
started → volver al código → async y timers cuando los ejercicios los pidan.

---

## 🚀 Cierre (de la fase… y del contenido base)

El Mini Jira queda con guardianes: las funciones puras, la máquina de
estados, el store, los servicios y los componentes clave tienen tests que
convierten cada cambio futuro de apuesta en verificación. Te llevas:

- la **pirámide pragmática** (retorno por esfuerzo) y sus dos corolarios —
  la testeabilidad como detector de diseño, el comportamiento sobre la
  implementación,
- el kit completo: AAA, `jest.mock` en la frontera correcta, `shallowMount`
  por defecto, el `return` que evita verdes falsos, mocks limpios entre
  tests,
- y el flujo que cambia el mantenimiento para siempre: **cada bug deja un
  test, y la suite crece donde duele** — el germen del *test de regresión*,
  aunque todavía no lo hayamos llamado por su nombre.

Un matiz honesto antes de celebrar: mira **dónde** quedaron los guardianes.
Las funciones puras, el store, los servicios y los componentes tontos: cubiertos.
Las **vistas** — `TicketsView`, `TicketForm`, el dashboard entero — viven en los
ejercicios 🟠, los opcionales. Si los saltaste (y la regla te dejaba), tu suite
está verde y tu pantalla más grande está desnuda. **Cobertura verde no es lo
mismo que protección donde importa.** No es un defecto que arreglar hoy — es una
información que vas a necesitar mañana, el día que alguien proponga tocar esas
vistas. Guárdala.

Y con esto, el contenido base del curso está completo. 🎓 Mira lo que hay en
el repo: un sistema con autenticación, API, dashboard, CRUD, wizard,
métricas, tiempo real, panel de agente, estado global con criterio
documentado y tests — construido pieza a pieza con las herramientas exactas
de una base 2018–2021, y con cada decisión de arquitectura defendida por
escrito.

La señal de que el CURSO quedó bien:

> "me sueltan mañana en un Vue 2 ajeno de 80.000 líneas y no siento pánico:
> sé leer sus patrones, sé dónde vive cada tipo de cosa, sé qué oler,
> por dónde empezar a testear — y sé qué NO tocar todavía."

**Aquí el curso se bifurca.** Terminaste el tronco (F0–F11): sabes Vue 2 **a
pelo**. Lo que sigue depende de qué necesites.

**Material de consulta — siempre disponible.** Los apéndices (🎨 Bootstrap,
🟢 Node, 📦 npm, 🌐 axios, ⚙️ Webpack/Babel) no son una fase: se leen cuando el
tema aparece o algo suena flojo. No hay orden.

**Las rutas — opcionales y excluyentes.** El legacy real casi nunca es Vue "a
pelo": encima hay un framework. Por eso el curso ofrece **tres rutas**, y eliges
**una** (no se acumulan, enseñan la misma lección con distinto vocabulario):

- 🅠 **Ruta Q — Quasar 1.x**: framework de UI + CLI propio. La ruta de
  referencia, la que define el molde.
- 🅥 **Ruta VU — Vuetify 2**: mismo molde que Q, plugin de Vue CLI. Coste bajo si
  ya hiciste Q.
- 🅝 **Ruta NX — Nuxt 2**: meta-framework SSR. Molde propio; es casi otro curso.

Y todas arrancan en el mismo sitio, que es **exactamente donde acabas de llegar**:

> 🛡️ **X0 — La red de seguridad.** Antes de migrar una sola línea, escribes
> tests de **regresión** sobre el CRUD y el dashboard *tal como están hoy*. ¿Te
> suena? Es este cierre hecho fase: el "test de guardia tras un bug" que
> aprendiste aquí, aplicado a "¿esto sigue haciendo lo mismo con otro framework
> debajo?". Y esa suite tuya de seis specs va a pasar por una auditoría
> incómoda. Ahí entenderás por qué insistí tanto en **comportamiento, no
> implementación** — y por qué el hueco de las vistas que acabo de señalarte no
> era un detalle.

**Prerequisito de X0: esta fase.** Sin Jest corriendo, la red de seguridad no
existe. Ya lo tienes. La puerta a las rutas está abierta.

Y si un día el equipo pregunta "¿y si migramos a Vue 3?", ya tienes el criterio
para responder algo mejor que sí o no. Pero esa, sí, es otra historia. 🚪

**Siguiente parada (si haces una ruta):** 🛡️ **X0 — La red de seguridad**
(`Q0` / `VU0` / `NX0`, según elijas). Nadie migra lo que no puede verificar.
