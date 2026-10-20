var __a = [


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
  // 💸 Deuda declarada: hoy esta action es síncrona porque el login es mock.
  // En la Fase 3 el login será una llamada HTTP y esta action devolverá una
  // Promise. El try/catch de LoginView dejará de servir tal cual y lo
  // migraremos a .then/.catch. Lo dejamos así para ver el problema en vivo.
  login: function (context, credentials) {
    var session = authService.login(credentials.username, credentials.password);
    authService.saveSession(session);
    context.commit("SET_SESSION", session);
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
module.exports = {
  namespaced: true,
  state: state,
  mutations: mutations,
  actions: actions,
  getters: getters
};
];