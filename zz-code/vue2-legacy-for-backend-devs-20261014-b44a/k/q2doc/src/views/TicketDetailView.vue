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
      <div class="mt-4">
        <router-link
          :to="'/tickets/' + ticket.id + '/edit'"
          class="btn btn-outline-primary mr-2"
        >
          ✏️ Editar
        </router-link>
        <button class="btn btn-outline-danger" :disabled="deleting" @click="removeTicket">
          {{ deleting ? "Eliminando..." : "🗑️ Eliminar" }}
        </button>
      </div>
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
    return { ticket: null, loading: false, error: "", deleting: false };
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
    },
    removeTicket: function () {
      var self = this;

      var ok = window.confirm(
        "¿Eliminar el ticket #" + this.ticket.id + "? Esta acción no se puede deshacer."
      );
      if (!ok) return;

      this.deleting = true;

      ticketService
        .deleteTicket(this.ticket.id)
        .then(function () {
          self.$router.push("/tickets");
        })
        .catch(function () {
          self.error = "No se pudo eliminar el ticket.";
          self.deleting = false;
        });
    }
  }
};
</script>
