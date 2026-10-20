import authService from "../../services/authService";

var storedSession = authService.getStoredSession();

const state = {
  token: storedSession.token,
  user: storedSession.user
};

const mutations = {
  SET_SESSION: function (state, session) {
    state.token = session.token;
    state.user = session.user;
  },
  CLEAR_SESSION: function (state) {
    state.token = "";
    state.user = null;
  }
};

const actions = {
  // ✅ Deuda pagada: la action ahora es asíncrona y DEVUELVE la Promise.
  // Devolverla es clave: permite que la vista encadene .then/.catch.
  login: function (context, credentials) {
    return authService
      .login(credentials.username, credentials.password)
      .then(function (session) {
        authService.saveSession(session);
        context.commit("SET_SESSION", session);
        return session;
      });
  },
  logout: function (context) {
    authService.clearSession();
    context.commit("CLEAR_SESSION");
  }
};

const getters = {
  isAuthenticated: function (state) {
    return !!state.token;
  },
  currentUser: function (state) {
    return state.user;
  }
};

export default {
  namespaced: true,
  state: state,
  mutations: mutations,
  actions: actions,
  getters: getters
};
