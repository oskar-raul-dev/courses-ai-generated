<template>
  <section>
    <page-title title="Tickets" />

    <div v-if="loading" class="text-center my-5">
      <div class="spinner-border text-primary" role="status"></div>
      <p class="mt-2">Cargando tickets...</p>
    </div>

    <div v-else-if="error" class="alert alert-danger">
      {{ error }}
      <button class="btn btn-sm btn-outline-danger ml-2" @click="loadTickets">
        Reintentar
      </button>
    </div>

    <p v-else-if="loaded && tickets.length === 0" class="text-muted">
      No hay tickets registrados.
    </p>

    <ul v-else class="list-group">
      <li
        v-for="ticket in tickets"
        :key="ticket.id"
        class="list-group-item d-flex justify-content-between"
      >
        <router-link :to="'/tickets/' + ticket.id">
          #{{ ticket.id }} — {{ ticket.title }}
        </router-link>
        <span>{{ ticket.status }}</span>
      </li>
    </ul>
  </section>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";
import ticketService from "../services/ticketService";

export default {
  name: "TicketsView",
  components: { PageTitle },
  data: function () {
    return {
      tickets: [],
      loading: false,
      loaded: false,
      error: ""
    };
  },
  mounted: function () {
    this.loadTickets();
  },
  methods: {
    loadTickets: function () {
      var self = this;
      this.loading = true;
      this.error = "";

      ticketService
        .getTickets()
        .then(function (tickets) {
          self.tickets = tickets;
          self.loaded = true;      // "sí hubo respuesta", distinto de "hay datos"
        })
        .catch(function () {
          self.error = "No se pudieron cargar los tickets. ¿Está corriendo la Mock API?";
        })
        .finally(function () {
          self.loading = false;
        });
    }
  }
};
</script>
