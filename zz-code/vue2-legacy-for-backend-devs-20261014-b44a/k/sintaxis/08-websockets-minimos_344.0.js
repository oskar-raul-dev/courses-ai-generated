// agregar a App.vue: los dos imports, el registro de LiveToast (sección 4) y el resto



components: { AppHeader, AppSidebar, LiveToast },

computed: {
  showLayout: function () {
    return this.$route.path !== "/login";
  },
  isAuthenticated: function () {
    return this.$store.getters["auth/isAuthenticated"];
  }
},
watch: {
  isAuthenticated: {
    immediate: true, // cubre la recarga con sesión ya activa
    handler: function (isAuth) {
      if (isAuth) {
        socketService.connect();
      } else {
        socketService.disconnect();
      }
    }
  }
}