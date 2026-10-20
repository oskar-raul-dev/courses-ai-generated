function __f(){
// store/modules/ui.js
const state = { flash: null }; // { type, text } o null

const mutations = {
  FLASH: function (state, message) {
    state.flash = message;
  },
  CLEAR_FLASH: function (state) {
    state.flash = null;
  }
};
module.exports = {
  namespaced: true,
  state: state,
  mutations: mutations
};
}