<template>
  <section>
    <div v-if="loading" class="spinner-border text-primary"></div>

    <div v-else-if="error" class="alert alert-warning">{{ error }}</div>

    <div v-else-if="ticket">
      <page-title :title="'#' + ticket.id + ' — ' + ticket.title" />
      <p>{{ ticket.description }}</p>
      <p>
        <strong>Estado:</strong> {{ ticket.status }} ·
        <strong>Prioridad:</strong> {{ ticket.priority }} ·
        <strong>Asignado a:</strong> {{ ticket.assignee }}
      </p>
    </div>
  </section>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";
import ticketService from "../services/ticketService";

export default {
  name: "TicketDetailView",
  components: { PageTitle },
  data: function () {
    return { ticket: null, loading: false, error: "" };
  },
  mounted: function () {
    this.loadTicket();
  },
  methods: {
    loadTicket: function () {
      var self = this;
      this.loading = true;
      this.error = "";

      ticketService
        .getTicketById(this.$route.params.id)
        .then(function (ticket) {
          self.ticket = ticket;
        })
        .catch(function (error) {
          if (error.response && error.response.status === 404) {
            self.error = "El ticket no existe.";
          } else {
            self.error = "No se pudo cargar el ticket.";
          }
        })
        .finally(function () {
          self.loading = false;
        });
    }
  }
};
</script>
