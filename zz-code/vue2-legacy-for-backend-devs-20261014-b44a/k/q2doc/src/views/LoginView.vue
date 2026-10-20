<template>
  <div class="container mt-5" style="max-width: 420px;">
    <page-title title="Iniciar sesión" />

    <form @submit.prevent="submitLogin" class="mt-4">
      <div class="form-group">
        <label>Usuario</label>
        <input v-model="form.username" class="form-control" :disabled="loading" />
      </div>

      <div class="form-group">
        <label>Contraseña</label>
        <input v-model="form.password" type="password" class="form-control" :disabled="loading" />
      </div>

      <div v-if="error" class="alert alert-danger">{{ error }}</div>

      <button class="btn btn-primary btn-block" :disabled="loading">
        {{ loading ? "Ingresando..." : "Ingresar" }}
      </button>
    </form>
  </div>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";

export default {
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
</script>
