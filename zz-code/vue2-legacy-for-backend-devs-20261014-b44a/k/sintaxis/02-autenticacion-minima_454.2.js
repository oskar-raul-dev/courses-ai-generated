var __o = {
module.exports = {
  name: "AppHeader",
  computed: {
    currentUser: function () {
      return this.$store.getters["auth/currentUser"];
    }
  },
  methods: {
    logout: function () {
      this.$store.dispatch("auth/logout");
      this.$router.push("/login");
    }
  }
};

};