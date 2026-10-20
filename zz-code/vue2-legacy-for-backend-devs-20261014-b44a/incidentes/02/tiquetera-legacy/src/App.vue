<template>
  <div id="app" class="d-flex flex-column min-vh-100">
    <template v-if="showLayout">
      <app-header />
      <div class="container-fluid flex-grow-1">
        <div class="row">
          <div class="col-md-3 col-lg-2 bg-light border-right p-0">
            <app-sidebar />
          </div>
          <main class="col-md-9 col-lg-10 p-4">
            <router-view />
          </main>
        </div>
      </div>
    </template>

    <template v-else>
      <router-view />
    </template>
  </div>
</template>

<script>
import AppHeader from "./components/layout/AppHeader.vue";
import AppSidebar from "./components/layout/AppSidebar.vue";

export default {
  name: "App",
  components: { AppHeader, AppSidebar },
  computed: {
    showLayout: function () {
      return this.$route.path !== "/login";
    }
  }
};
</script>
