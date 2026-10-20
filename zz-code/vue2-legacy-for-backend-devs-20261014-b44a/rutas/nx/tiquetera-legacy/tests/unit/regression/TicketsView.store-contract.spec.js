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
          // lo que lee la vista de F10: loading y error del state (mapState), tickets del getter
          // allTickets (mapGetters). Con error: así se pinta el botón de reintento.
          state: { loading: false, error: "No se pudieron cargar los tickets." },
          actions: actions,
          getters: {
            allTickets: function () { return []; }
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
