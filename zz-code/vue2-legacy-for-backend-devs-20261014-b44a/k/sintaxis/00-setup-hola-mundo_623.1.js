function __f(){




Vue.config.productionTip = false;

new Vue({
  render: function (h) {
    return h(App);
  }
}).$mount("#app");
}