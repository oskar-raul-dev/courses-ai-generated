import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import store from "./store";
import "bootstrap/dist/css/bootstrap.min.css";
import Vuelidate from "vuelidate";
import vuetify from './plugins/vuetify'
import '@babel/polyfill'

Vue.use(Vuelidate);

Vue.config.productionTip = false;

// Filtro global de la época. En Vue 3 esto ya no existe.
Vue.filter("formatDate", function (value) {
  if (!value) return "";
  var d = new Date(value);
  return d.toLocaleDateString("es-CO", {
    year: "numeric", month: "short", day: "numeric"
  });
});

new Vue({
  router: router,
  store: store,
  vuetify,

  render: function (h) {
    return h(App);
  }
}).$mount("#app");
