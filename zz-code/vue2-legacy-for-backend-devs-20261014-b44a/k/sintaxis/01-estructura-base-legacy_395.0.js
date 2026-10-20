const state = { items: [] };

const mutations = {
  setTickets: function (state, tickets) {
    state.items = tickets;
  }
};
module.exports = {
  namespaced: true,
  state: state,
  mutations: mutations
};