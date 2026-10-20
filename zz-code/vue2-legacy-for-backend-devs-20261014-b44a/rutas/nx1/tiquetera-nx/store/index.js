export const actions = {
  nuxtServerInit: function (context) {
    var token = this.$cookies.get("token");
    var user = this.$cookies.get("user");
    if (token) {
      context.commit("auth/SET_SESSION", { token: token, user: user });
    }
  }
};
