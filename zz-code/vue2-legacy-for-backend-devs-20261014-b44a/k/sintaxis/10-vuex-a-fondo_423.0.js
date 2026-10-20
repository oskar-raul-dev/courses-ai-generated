// store/index.js — versión final







Vue.use(Vuex);
module.exports = new Vuex.Store({
  strict: process.env.NODE_ENV !== "production",
  modules: { auth: auth, tickets: tickets, ui: ui },
  plugins: [socketPlugin]
});