<template>
  <section style="max-width: 640px;">
    <page-title :title="'Editar ticket #' + $route.params.id" />

    <div v-if="loading" class="spinner-border text-primary"></div>

    <div v-else-if="error" class="alert alert-danger">{{ error }}</div>

    <ticket-form
      v-else-if="ticket"
      :initial-ticket="ticket"
      :saving="saving"
      submit-label="Guardar cambios"
      @submit="updateTicket"
      @cancel="$router.push('/tickets/' + $route.params.id)"
    />
  </section>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";
import TicketForm from "../components/tickets/TicketForm.vue";
import ticketService from "../services/ticketService";

export default {
  name: "TicketEditView",
  components: { PageTitle, TicketForm },
  data: function () {
    return { ticket: null, loading: false, saving: false, error: "" };
  },
  mounted: function () {
    this.loadTicket();
  },
  methods: {
    loadTicket: function () {
      var self = this;
      this.loading = true;

      ticketService
        .getTicketById(this.$route.params.id)
        .then(function (ticket) {
          self.ticket = ticket;
        })
        .catch(function () {
          self.error = "No se pudo cargar el ticket.";
        })
        .finally(function () {
          self.loading = false;
        });
    },
    updateTicket: function (formData) {
      var self = this;
      this.saving = true;
      this.error = "";

      ticketService
        .updateTicket(this.$route.params.id, formData)
        .then(function () {
          self.$router.push("/tickets/" + self.$route.params.id);
        })
        .catch(function () {
          self.error = "No se pudieron guardar los cambios.";
        })
        .finally(function () {
          self.saving = false;
        });
    }
  }
};
</script>
