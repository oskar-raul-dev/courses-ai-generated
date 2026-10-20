// store/modules/tickets.js
import ticketService from "../../services/ticketService";
import activityEmitter from "../../services/activityEmitter";

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
    // payload: { id, changes }  ← firma de F10, no la inventamos
    // || {}: si el ticket no está en el store (llegó por otra vía), no hay "antes" que comparar
    var before = context.getters.ticketById(payload.id) || {}; // getter-función de F10
  
    return ticketService
      .updateTicket(payload.id, payload.changes)
      .then(function (updated) {
        context.commit("UPSERT_TICKET", updated); // mutación real de F10
  
        // 💸 el front generando historial. Ver deuda.
        // Derivamos el tipo de evento del CHANGES: no inventamos actions nuevas.
        var actor = context.rootGetters["auth/currentUser"].username; // getter real de F2/F10
        if (payload.changes.status && payload.changes.status !== before.status) {
          activityEmitter.record({
            ticketId: updated.id, type: "status_change", actor: actor,
            from: before.status, to: updated.status
          });
        }
        if (payload.changes.assignee && payload.changes.assignee !== before.assignee) {
          activityEmitter.record({
            ticketId: updated.id, type: "assigned", actor: actor,
            from: before.assignee, to: updated.assignee
          });
        }
  
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
