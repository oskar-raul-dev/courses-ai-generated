var __o = {
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
};