<template>
  <q-layout view="hHh LpR fFf">
    <q-header elevated class="bg-primary text-white">
      <q-toolbar>
        <q-btn flat dense round icon="menu" @click="drawer = !drawer" />
        <q-toolbar-title>Tiquetera</q-toolbar-title>
        <q-btn flat label="Salir" @click="logout" />
      </q-toolbar>
    </q-header>

    <q-drawer v-model="drawer" show-if-above bordered>
      <q-list>
        <q-item clickable to="/tickets">
          <q-item-section avatar><q-icon name="list" /></q-item-section>
          <q-item-section>Tickets</q-item-section>
        </q-item>
        <q-item clickable to="/tickets/new">
          <q-item-section avatar><q-icon name="add" /></q-item-section>
          <q-item-section>Nuevo ticket</q-item-section>
        </q-item>
        <q-item clickable to="/metrics">
          <q-item-section avatar><q-icon name="insights" /></q-item-section>
          <q-item-section>Métricas</q-item-section>
        </q-item>
        <q-item clickable to="/support">
          <q-item-section avatar><q-icon name="support_agent" /></q-item-section>
          <q-item-section>Soporte</q-item-section>
        </q-item>
      </q-list>
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>

    <live-toast />
  </q-layout>
</template>

<script>
import LiveToast from '../components/common/LiveToast.vue'
import socketService from '../services/socketService'

export default {
  name: 'MainLayout',
  components: { LiveToast },
  data: function () {
    return { drawer: false }
  },
  computed: {
    isAuthenticated: function () {
      return this.$store.getters['auth/isAuthenticated']
    }
  },
  watch: {
    // lo que App.vue hacía en F8: el socket vive mientras haya sesión
    isAuthenticated: {
      immediate: true,
      handler: function (isAuth) {
        if (isAuth) {
          socketService.connect()
        } else {
          socketService.disconnect()
        }
      }
    }
  },
  methods: {
    logout: function () {
      this.$store.dispatch('auth/logout')
      this.$router.push('/login')
    }
  }
}
</script>
