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
    router: router,
    // Confesión de Q3: QPage necesita un QLayout ancestro (lee su header).
    // La vista se prueba sola, así que la página es un div.
    stubs: { "q-page": { template: "<div><slot /></div>" } }
  });

  return { wrapper: wrapper, store: store, router: router };
}

// Confesión de Q3: el filtro de estado es un QSelect; se elige como el usuario
// (el mismo ayudante que el formulario en Q2).
function pick(wrapper, testid, value) {
  const select = wrapper.findAllComponents({ name: "QSelect" }).filter(function (w) {
    return w.find('[data-testid="' + testid + '"]').exists();
  }).at(0);
  const option = select.vm.options.filter(function (o) {
    return (o !== null && typeof o === "object" ? o.value : o) === value;
  })[0];
  select.vm.toggleOption(option);
  return wrapper.vm.$nextTick();
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

      return pick(ctx.wrapper, "tickets-status-filter", "open")
        .then(function () {
          expect(rowCount(ctx.wrapper)).toBe(1);
          expect(ctx.wrapper.find('[data-testid="ticket-row-1"]').exists()).toBe(true);
        });
    });

    it("los filtros se COMBINAN (el && del computed)", function () {
      const ctx = build({ items: makeTickets() });
      const search = ctx.wrapper.find('[data-testid="tickets-search"]');

      return search.setValue("impresora")
        .then(function () { return pick(ctx.wrapper, "tickets-status-filter", "open"); })
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
          const text = ctx.wrapper.find('[data-testid="tickets-count"]').text();
          // NO se afirma la frase exacta: se afirman los DOS NÚMEROS.
          // Si mañana el copy cambia a "2 de 4 resultados", esto sigue verde.
          expect(text).toMatch(/\b2\b/);
          expect(text).toMatch(/\b4\b/);
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
