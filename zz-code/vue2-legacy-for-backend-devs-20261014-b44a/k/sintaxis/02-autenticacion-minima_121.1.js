function __f(){
module.exports = {
  name: "App",
  components: { AppHeader, AppSidebar },
  computed: {
    showLayout: function () {
      return this.$route.path !== "/login";
    }
  }
};

}