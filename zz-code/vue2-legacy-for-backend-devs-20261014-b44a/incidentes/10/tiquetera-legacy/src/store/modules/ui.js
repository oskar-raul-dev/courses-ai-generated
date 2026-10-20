// store/modules/ui.js — con el indicador de carga global que agregó el legacy
const state = { flash: null, loading: false };

const mutations = {
  FLASH: function (state, message) {
    state.flash = message;
  },
  CLEAR_FLASH: function (state) {
    state.flash = null;
  },
  SET_LOADING: function (state, value) {
    state.loading = value;
  }
};

export default {
  namespaced: true,
  state: state,
  mutations: mutations
};
