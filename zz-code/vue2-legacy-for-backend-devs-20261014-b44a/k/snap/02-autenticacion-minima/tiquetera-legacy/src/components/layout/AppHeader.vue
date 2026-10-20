<template>
  <header class="navbar navbar-dark bg-dark px-3 d-flex justify-content-between">
    <span class="navbar-brand mb-0 h1">Tiquetera</span>

    <div v-if="currentUser" class="text-white">
      <span class="mr-3">{{ currentUser.name }}</span>
      <button class="btn btn-sm btn-outline-light" @click="logout">Salir</button>
    </div>
  </header>
</template>

<script>
export default {
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
</script>
