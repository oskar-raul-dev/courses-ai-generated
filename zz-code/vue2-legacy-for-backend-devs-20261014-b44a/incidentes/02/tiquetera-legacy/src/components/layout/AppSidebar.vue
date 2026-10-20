<template>
  <aside class="p-3">
    <ul class="nav flex-column">
      <li class="nav-item">
        <router-link class="nav-link" to="/">Inicio</router-link>
      </li>
      <li class="nav-item">
        <router-link class="nav-link" to="/tickets">Tickets</router-link>
      </li>
    </ul>
  </aside>
</template>

<script>
export default { name: "AppSidebar" };
</script>
