var __a = [
// AppSidebar.vue
computed: {
  isAgent: function () {
    var user = this.$store.getters["auth/currentUser"];
    return !!(user && user.role === "agent");
  }
}
];