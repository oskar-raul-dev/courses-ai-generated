<template>
  <header class="navbar navbar-dark bg-dark px-3 d-flex justify-content-between">
    <span class="navbar-brand mb-0 h1">Tiquetera</span>

    <div v-if="currentUser" class="text-white">
      <span class="mr-3 small" :title="live ? 'Conectado en tiempo real' : 'Sin conexión en vivo'">
        {{ live ? "🟢 en vivo" : "🔴" }}
      </span>
      <!-- VU4: el interruptor. Un flag. Nada más. -->
      <v-btn icon dark small class="mr-2" @click="toggleDark" :title="dark ? 'Modo claro' : 'Modo oscuro'">
        <v-icon>{{ dark ? "mdi-weather-sunny" : "mdi-weather-night" }}</v-icon>
      </v-btn>
      <span class="mr-3">{{ currentUser.name }}</span>
      <button class="btn btn-sm btn-outline-light" @click="logout">Salir</button>
    </div>
  </header>
</template>

<script>
import socketService from "../../services/socketService";

export default {
  name: "AppHeader",
  data: function () {
    return { live: false };
  },
  mounted: function () {
    var self = this;
    // sondeo barato del estado; los eventos connect/disconnect finos son el ej. 9
    this.liveTimer = setInterval(function () {
      self.live = socketService.isConnected();
    }, 2000);
  },
  beforeDestroy: function () {
    clearInterval(this.liveTimer);
  },
  computed: {
    currentUser: function () {
      return this.$store.getters["auth/currentUser"];
    },
    dark: function () {
      return this.$vuetify.theme.dark; // lectura reactiva del flag global
    }
  },
  methods: {
    toggleDark: function () {
      this.$vuetify.theme.dark = !this.$vuetify.theme.dark; // una línea. Toda la app responde.
      // (persistir en localStorage → ejercicio 🟢 5)
    },
    logout: function () {
      this.$store.dispatch("auth/logout");
      this.$router.push("/login");
    }
  }
};
</script>
