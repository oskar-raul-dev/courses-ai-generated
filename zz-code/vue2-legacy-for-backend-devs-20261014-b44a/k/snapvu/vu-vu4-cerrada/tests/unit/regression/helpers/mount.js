import Vue from "vue";
import Vuetify from "vuetify";
import { mount, createLocalVue } from "@vue/test-utils";

// VU2: Vuetify entra aquí, y solo aquí. Se registra en Vue (no en el localVue:
// Vuetify 2 lo pide así) y cada montaje recibe su propia instancia.
Vue.use(Vuetify);

// 🅥 EL PUNTO DE LA FASE.
// Hoy esto es un mount() con envoltura vacía. Mañana (VU2/VU3) es el ÚNICO
// sitio donde <v-app> y el plugin de Vuetify entrarán en juego.
//
// La regla: los tests NO llaman a mount() directo. Llaman a mountView().
// Así, cuando Vuetify exija un v-app ancestro, se cambia AQUÍ:
//   - se registra Vuetify en el localVue
//   - se envuelve el componente en un <v-app> (con la técnica que se decida)
// ...y los veinte tests de dashboard.spec.js NO se enteran.
//
// Esto es la "junta de dilatación" del problema del v-app. Igual que rowCount()
// absorbe el cambio de <tr>, mountView() absorbe el cambio de "montaje aislado"
// a "montaje bajo v-app".

export function mountView(Component, options) {
  options = options || {};
  const localVue = options.localVue || createLocalVue();

  // --- ZONA VUETIFY ----------------------------------------------------
  // El <v-app> que Vuetify exige: diálogos y menús buscan un ancestro con
  // data-app para colgarse. En la app lo pone <v-app>; aquí, un div en el body.
  if (!document.querySelector("[data-app]")) {
    var app = document.createElement("div");
    app.setAttribute("data-app", "true");
    document.body.appendChild(app);
  }
  // --------------------------------------------------------------------

  return mount(Component, Object.assign({}, options, { localVue: localVue, vuetify: new Vuetify() }));
}
