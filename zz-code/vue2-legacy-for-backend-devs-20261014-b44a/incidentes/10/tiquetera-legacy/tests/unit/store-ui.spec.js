// tests/unit/store-ui.spec.js
import Vue from "vue";
import Vuex from "vuex";
import store from "@/store";
import ui from "@/store/modules/ui";
import tickets from "@/store/modules/tickets";

Vue.use(Vuex);

describe("store", function () {
  it("el módulo ui está namespaced", function () {
    var local = new Vuex.Store({ modules: { ui: ui, tickets: tickets } });
    local.commit("ui/SET_LOADING", true);
    expect(local.state.ui.loading).toBe(true);
    expect(local.state.tickets.loading).toBe(false);   // no se pisaron
  });

  it("el store del proyecto caza la escritura directa (strict)", function () {
    // strict avisa desde un watcher, y Vue atrapa los errores de los watchers: no le
    // llegan a quien escribió, así que un toThrow() no los ve. Se recogen con el
    // errorHandler global.
    var capturado = null;
    var anterior = Vue.config.errorHandler;
    Vue.config.errorHandler = function (err) { capturado = err; };
    store.state.tickets.items.push({ id: 1 });
    Vue.config.errorHandler = anterior;
    expect(capturado && capturado.message).toMatch("do not mutate vuex store state");
  });
});
