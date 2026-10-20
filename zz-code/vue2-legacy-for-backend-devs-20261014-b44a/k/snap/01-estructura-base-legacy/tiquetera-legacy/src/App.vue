<template>
  <div id="app" class="d-flex flex-column min-vh-100">
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
  </div>
</template>

<script>
import AppHeader from "./components/layout/AppHeader.vue";
import AppSidebar from "./components/layout/AppSidebar.vue";

export default {
  name: "App",
  components: { AppHeader, AppSidebar }
};
</script>
