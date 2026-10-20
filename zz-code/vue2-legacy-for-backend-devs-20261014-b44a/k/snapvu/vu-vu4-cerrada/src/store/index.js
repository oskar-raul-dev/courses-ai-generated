// store/index.js — versión final
import Vue from "vue";
import Vuex from "vuex";
import auth from "./modules/auth";
import tickets from "./modules/tickets";
import ui from "./modules/ui";
import socketPlugin from "./plugins/socketPlugin";

Vue.use(Vuex);

export default new Vuex.Store({
  strict: process.env.NODE_ENV !== "production",
  modules: { auth: auth, tickets: tickets, ui: ui },
  plugins: [socketPlugin]
});
