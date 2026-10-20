import authService from "~/services/authService";

export const state = function () { return { token: "", user: null }; };
export const mutations = {
  SET_SESSION: function (state, session) { state.token = session.token; state.user = session.user; },
  CLEAR_SESSION: function (state) { state.token = ""; state.user = null; }
};
export const actions = {
  login: function (context, credentials) {
    var session = authService.login(credentials.username, credentials.password);
    this.$cookies.set("token", session.token, { path: "/" });
    this.$cookies.set("user", session.user, { path: "/" });
    context.commit("SET_SESSION", session);
  },
  logout: function (context) {
    this.$cookies.remove("token");
    this.$cookies.remove("user");
    context.commit("CLEAR_SESSION");
  }
};
