<template>
  <header class="navbar navbar-dark bg-dark px-3 d-flex justify-content-between">
    <span class="navbar-brand mb-0 h1">Tiquetera</span>

    <div v-if="currentUser" class="text-white">
      <span class="mr-3 small" :title="live ? 'Conectado en tiempo real' : 'Sin conexión en vivo'">
        {{ live ? "🟢 en vivo" : "🔴" }}
      </span>
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
    }
  },
  methods: {
    logout: function () {
      this.$store.dispatch("auth/logout");
      this.$router.push("/login");
    }
  }
};
</script>
