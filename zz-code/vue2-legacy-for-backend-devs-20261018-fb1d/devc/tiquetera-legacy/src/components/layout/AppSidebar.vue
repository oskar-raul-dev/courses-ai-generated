<template>
  <aside class="p-3">
    <ul class="nav flex-column">
      <li class="nav-item">
        <router-link class="nav-link" to="/">Inicio</router-link>
      </li>
      <li class="nav-item">
        <router-link class="nav-link" to="/tickets">Tickets</router-link>
      </li>
      <li class="nav-item">
        <router-link class="nav-link" to="/metrics">📊 Métricas</router-link>
      </li>
      <li v-if="isAgent" class="nav-item">
        <router-link class="nav-link" to="/support">🎧 Soporte</router-link>
      </li>
    </ul>
  </aside>
</template>

<script>
export default {
  name: "AppSidebar",
  computed: {
    isAgent: function () {
      var user = this.$store.getters["auth/currentUser"];
      return !!(user && user.role === "agent");
    }
  }
};
</script>
