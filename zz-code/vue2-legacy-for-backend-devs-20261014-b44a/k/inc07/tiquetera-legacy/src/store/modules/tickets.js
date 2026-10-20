const state = { items: [] };

const mutations = {
  setTickets: function (state, tickets) {
    state.items = tickets;
  }
};

export default {
  namespaced: true,
  state: state,
  mutations: mutations
};
