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
          currentUser: function () { return { username: "lmcorrea", role: "agent" }; }
        }
      }
    }
  });

  // se devuelven los espías junto al store: el test los interroga después
  store.spies = { fetchTickets: fetchTickets };
  return store;
}
