var __a = [
module.exports = {
  name: "LoginView",
  components: { PageTitle },
  data: function () {
    return {
      form: { username: "", password: "" },
      error: ""
    };
  },
  methods: {
    submitLogin: function () {
      this.error = "";

      if (!this.form.username || !this.form.password) {
        this.error = "Debe completar usuario y contraseña";
        return;
      }

      // 💸 Este try/catch funciona SOLO porque la action es síncrona hoy.
      // Cuando el login sea async (Fase 3), habrá que usar .then/.catch.
      try {
        this.$store.dispatch("auth/login", this.form);
        this.$router.push("/");
      } catch (error) {
        this.error = error.message;
      }
    }
  }
};

];