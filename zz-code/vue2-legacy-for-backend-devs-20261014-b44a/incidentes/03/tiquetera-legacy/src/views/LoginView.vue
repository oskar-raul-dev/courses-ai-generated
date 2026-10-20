<template>
  <div class="container mt-5" style="max-width: 420px;">
    <page-title title="Iniciar sesión" />

    <form @submit.prevent="submitLogin" class="mt-4">
      <div class="form-group">
        <label>Usuario</label>
        <input v-model="form.username" class="form-control" />
      </div>

      <div class="form-group">
        <label>Contraseña</label>
        <input v-model="form.password" type="password" class="form-control" />
      </div>

      <div v-if="error" class="alert alert-danger">{{ error }}</div>

      <button class="btn btn-primary btn-block">Ingresar</button>
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
</script>
