import { mount, createLocalVue } from "@vue/test-utils";

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

  // --- ZONA VUETIFY (hoy vacía a propósito) ---------------------------
  // En VU2/VU3, aquí irá algo COMO:
  //   import Vuetify from "vuetify";
  //   localVue.use(Vuetify);
  //   const vuetify = new Vuetify();
  //   ...y el wrapping en <v-app> (ver la sección de abajo para el dilema).
  // HOY: nada. No hay Vuetify. Montamos el componente a pelo.
  // --------------------------------------------------------------------

  return mount(Component, Object.assign({}, options, { localVue: localVue }));
}
