var __a = [






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
  render: function (h) {
    return h(App);
  }
}).$mount("#app");
];