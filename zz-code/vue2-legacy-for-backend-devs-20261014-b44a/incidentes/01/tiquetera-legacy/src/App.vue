<template>
  <div class="container mt-5">
    <div class="row justify-content-center">
      <div class="col-md-6">
        <div class="card shadow-sm">
          <div class="card-body">
            <h1 class="h3 mb-3">{{ greeting }}</h1>

            <form @submit.prevent="submit" novalidate>
              <div class="form-group">
                <label for="name">Nombre</label>
                <input
                  id="name"
                  v-model.trim="name"
                  type="text"
                  class="form-control"
                  :class="{ 'is-invalid': submitted && !isNameValid }"
                  placeholder="Escribe tu nombre"
                />
                <div class="invalid-feedback">El nombre es obligatorio.</div>
              </div>

              <button class="btn btn-primary" type="submit" :disabled="loading">
                {{ loading ? "Enviando..." : "Enviar" }}
              </button>
            </form>

            <p v-if="response" class="alert alert-success mt-3 mb-0">
              {{ response }}
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "App",
  data: function () {
    return {
      greeting: "Hola mundo legacy",
      name: "",
      response: "",
      submitted: false,
      loading: false
    };
  },
  computed: {
    // derivado del estado: se recalcula solo cuando cambia name
    isNameValid: function () {
      return this.name.length > 0;
    }
  },
  methods: {
    submit: function () {
      // guardamos this: dentro del .then, this ya no es el componente
      var self = this;
      this.submitted = true;

      if (!this.isNameValid) {
        return; // la clase is-invalid ya pinta el error sola
      }

      this.loading = true;
      this.response = "";

      axios
        .post("http://localhost:8888/api/hello", { name: this.name })
        .then(function (res) {
          self.response = res.data.message + " " + self.name;
        })
        .catch(function () {
          self.response = "";
          window.alert("¿Está corriendo el mock? (npm run mock)");
        })
        .finally(function () {
          self.loading = false;
        });
    }
  }
};
</script>
