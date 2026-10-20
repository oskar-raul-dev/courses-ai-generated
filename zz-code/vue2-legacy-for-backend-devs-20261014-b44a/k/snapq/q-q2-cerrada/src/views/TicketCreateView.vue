<template>
  <q-page padding style="max-width: 640px;">
    <div class="text-h5 q-mb-md">Nuevo ticket</div>

    <!-- ✅ Este error SOBREVIVE: es un error de RED, no de validación. -->
    <q-banner v-if="error" class="bg-negative text-white q-mb-md">
      {{ error }}
    </q-banner>

    <ticket-form
      :saving="saving"
      submit-label="Crear ticket"
      @submit="createTicket"
      @cancel="$router.push('/tickets')"
    />
  </q-page>
</template>

<script>
import TicketForm from "../components/tickets/TicketForm.vue";
import ticketService from "../services/ticketService";

export default {
  name: "TicketCreateView",
  components: { TicketForm },
  data: function () {
    return { saving: false, error: "" };
  },
  methods: {
    createTicket: function (formData) {
      var self = this;
      this.saving = true;
      this.error = "";

      // 🔎 IDÉNTICO A F5. Las reglas de negocio siguen viviendo en la vista.
      //    Quasar no tiene opinión sobre esto, y mejor así.
      var payload = Object.assign({}, formData, {
        status: "open",
        reporter: this.$store.getters["auth/currentUser"].username,
        createdAt: new Date().toISOString()
      });

      ticketService
        .createTicket(payload)
        .then(function (created) {
          self.$q.notify({ type: "positive", message: "Ticket creado ✅" });
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
