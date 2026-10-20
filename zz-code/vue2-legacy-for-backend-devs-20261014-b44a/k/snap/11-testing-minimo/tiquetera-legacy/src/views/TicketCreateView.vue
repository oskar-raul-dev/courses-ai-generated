<template>
  <section style="max-width: 640px;">
    <page-title title="Nuevo ticket" />

    <div v-if="error" class="alert alert-danger">{{ error }}</div>

    <ticket-form
      :saving="saving"
      submit-label="Crear ticket"
      @submit="createTicket"
      @cancel="$router.push('/tickets')"
    />
  </section>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";
import TicketForm from "../components/tickets/TicketForm.vue";
import ticketService from "../services/ticketService";
import socketService from "../services/socketService";

export default {
  name: "TicketCreateView",
  components: { PageTitle, TicketForm },
  data: function () {
    return { saving: false, error: "" };
  },
  methods: {
    createTicket: function (formData) {
      var self = this;
      this.saving = true;
      this.error = "";

      var payload = Object.assign({}, formData, {
        status: "open", // todo ticket nace abierto: regla de negocio, no del form
        reporter: this.$store.getters["auth/currentUser"].username,
        createdAt: new Date().toISOString()
      });

      ticketService
        .createTicket(payload)
        .then(function (created) {
          socketService.emit("ticket:created", created); // 📣 anunciar a los demás
          self.$router.push("/tickets/" + created.id);
        })
        .catch(function () {
          self.error = "No se pudo crear el ticket. Intenta de nuevo.";
        })
        .finally(function () {
          self.saving = false;
        });
    }
  }
};
</script>
