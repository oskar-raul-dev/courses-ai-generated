<template>
  <section>
    <div class="d-flex align-center mb-3">
      <h1 class="text-h5">Tickets</h1>
      <v-spacer />
      <v-btn color="primary" data-testid="ticket-new" @click="openCreate">
        Nuevo ticket
      </v-btn>
    </div>

    <!-- ... aquí sigue el listado de F4 (todavía Bootstrap; se migra en VU3) ... -->

    <!-- Diálogo CREAR / EDITAR -->
    <v-dialog v-model="formDialog" persistent max-width="640">
      <v-card>
        <v-card-title>{{ editing ? "Editar ticket" : "Nuevo ticket" }}</v-card-title>
        <v-card-text>
          <div v-if="error" class="mb-3">
            <v-alert type="error" dense text>{{ error }}</v-alert>
          </div>
          <!-- :key fuerza remontar el form al cambiar de ticket → clon limpio -->
          <ticket-form
            :key="editingId || 'new'"
            :initial-ticket="editingTicket"
            :saving="saving"
            :submit-label="editing ? 'Guardar cambios' : 'Crear ticket'"
            @submit="onSubmit"
            @cancel="closeForm"
          />
        </v-card-text>
      </v-card>
    </v-dialog>

    <!-- Diálogo BORRAR -->
    <v-dialog v-model="confirmDelete" max-width="420">
      <v-card>
        <v-card-title>Eliminar ticket</v-card-title>
        <v-card-text>
          ¿Seguro que quieres eliminar
          <strong>#{{ toDelete && toDelete.id }} — {{ toDelete && toDelete.title }}</strong>?
        </v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn text @click="confirmDelete = false">Cancelar</v-btn>
          <v-btn color="error" :loading="deleting" @click="doDelete">Eliminar</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </section>
</template>

<script>
import TicketForm from "../components/tickets/TicketForm.vue";
import ticketService from "../services/ticketService";

export default {
  name: "TicketsView",
  components: { TicketForm },
  data: function () {
    return {
      formDialog: false,
      confirmDelete: false,
      editing: false,
      editingId: null,
      editingTicket: null,
      toDelete: null,
      saving: false,
      deleting: false,
      error: ""
    };
  },
  methods: {
    openCreate: function () {
      this.editing = false;
      this.editingId = null;
      this.editingTicket = null;
      this.error = "";
      this.formDialog = true;
    },
    openEdit: function (ticket) {
      this.editing = true;
      this.editingId = ticket.id;
      this.editingTicket = ticket;
      this.error = "";
      this.formDialog = true;
    },
    closeForm: function () {
      this.formDialog = false;
    },
    onSubmit: function (formData) {
      var self = this;
      this.saving = true;
      this.error = "";

      // reglas de negocio: las pone la VISTA, no el form (igual que en F5)
      var request;
      if (this.editing) {
        request = ticketService.updateTicket(this.editingId, formData);
      } else {
        var payload = Object.assign({}, formData, {
          status: "open",
          reporter: this.$store.getters["auth/currentUser"].username,
          createdAt: new Date().toISOString()
        });
        request = ticketService.createTicket(payload);
      }

      request
        .then(function (saved) {
          // la lista lee del store (F10): lo guardado entra ahí, no por un evento
          self.$store.commit("tickets/UPSERT_TICKET", saved);
          self.formDialog = false;
        })
        .catch(function () {
          self.error = "No se pudo guardar. Intenta de nuevo.";
        })
        .finally(function () {
          self.saving = false;
        });
    },
    askDelete: function (ticket) {
      this.toDelete = ticket;
      this.confirmDelete = true;
    },
    doDelete: function () {
      var self = this;
      this.deleting = true;
      ticketService
        .deleteTicket(this.toDelete.id)
        .then(function () {
          self.confirmDelete = false;
          return self.$store.dispatch("tickets/fetchTickets", { force: true });
        })
        .catch(function () {
          self.error = "No se pudo eliminar.";
          self.confirmDelete = false;
        })
        .finally(function () {
          self.deleting = false;
        });
    }
  }
};
</script>
