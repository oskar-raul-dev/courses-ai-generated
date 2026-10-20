function __f(){






Vue.config.productionTip = false;

new Vue({
  router: router,
  store: store,
  render: function (h) {
    return h(App);
  }
}).$mount("#app");
}