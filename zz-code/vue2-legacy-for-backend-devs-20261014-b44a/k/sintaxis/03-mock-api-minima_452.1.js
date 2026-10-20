function __f(){
module.exports = {
  name: "LoginView",
  components: { PageTitle },
  data: function () {
    return {
      form: { username: "", password: "" },
      error: "",
      loading: false
    };
  },
  methods: {
    submitLogin: function () {
      var self = this;
      this.error = "";

      if (!this.form.username || !this.form.password) {
        this.error = "Debe completar usuario y contraseña";
        return;
      }

      this.loading = true;

      this.$store
        .dispatch("auth/login", this.form)
        .then(function () {
          self.$router.push("/");
        })
        .catch(function (error) {
          self.error = error.message;
        })
        .finally(function () {
          self.loading = false;
        });
    }
  }
};

}