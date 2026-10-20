<template>
  <section>
    <page-title title="Tickets" subtitle="Mesa de soporte" />

<v-btn color="primary" class="mb-3" data-testid="ticket-new" @click="openCreate">
  Nuevo ticket
</v-btn>
<router-link to="/tickets/wizard" class="btn btn-outline-primary mb-3 ml-2">
  🪜 Asistente
</router-link>

    <!-- estado: cargando -->
    <div v-if="loading" class="text-center my-5" data-testid="tickets-loading">
      <div class="spinner-border text-primary" role="status"></div>
    </div>

    <!-- estado: error -->
    <div v-else-if="error" class="alert alert-danger" data-testid="tickets-error">
      {{ error }}
      <button class="btn btn-sm btn-outline-danger ml-2"
              data-testid="tickets-retry"
              @click="fetchTickets()">
        Reintentar
      </button>
    </div>

    <!-- estado: datos -->
    <template v-else>
      <tickets-summary :tickets="tickets" />

      <div class="form-row mb-3">
        <div class="col-md-6 mb-2">
          <input
            v-model="search"
            data-testid="tickets-search"
            type="text"
            class="form-control"
            placeholder="🔍 Buscar por título..."
          />
        </div>
        <div class="col-md-3 mb-2">
          <select v-model="statusFilter" class="form-control" data-testid="tickets-status-filter">
            <option value="">Todos los estados</option>
            <option value="open">Abiertos</option>
            <option value="in_progress">En progreso</option>
            <option value="resolved">Resueltos</option>
            <option value="closed">Cerrados</option>
          </select>
        </div>
        <div class="col-md-3 mb-2 text-right">
          <button class="btn btn-outline-secondary btn-block"
                  data-testid="tickets-clear-filters"
                  @click="clearFilters">
            Limpiar filtros
          </button>
        </div>
      </div>

      <p class="text-muted small" data-testid="tickets-count">
        Mostrando {{ filteredTickets.length }} de {{ tickets.length }} tickets
      </p>

      <tickets-table :tickets="filteredTickets" @select="goToDetail" />
    </template>

    <!-- Diálogo CREAR / EDITAR -->
    <v-dialog v-model="formDialog" persistent max-width="640">
      <v-card>
        <v-card-title>{{ editing ? "Editar ticket" : "Nuevo ticket" }}</v-card-title>
        <v-card-text>
          <v-alert v-if="saveError" type="error" dense text>{{ saveError }}</v-alert>
          <!-- :key fuerza remontar el form al cambiar de ticket → clon limpio -->
          <ticket-form
            v-if="formDialog"
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
import PageTitle from "../components/common/PageTitle.vue";
import TicketForm from "../components/tickets/TicketForm.vue";
import ticketService from "../services/ticketService";
import TicketsTable from "../components/tickets/TicketsTable.vue";
import TicketsSummary from "../components/tickets/TicketsSummary.vue";
import { mapGetters, mapState, mapActions } from "vuex";

export default {
  name: "TicketsView",
  components: { PageTitle, TicketsTable, TicketsSummary, TicketForm },
  // data: se van tickets, loading, error → QUEDAN search y statusFilter
  data: function () {
    return {
      search: "",
      statusFilter: "",
      formDialog: false,
      confirmDelete: false,
      editing: false,
      editingId: null,
      editingTicket: null,
      toDelete: null,
      saving: false,
      deleting: false,
      saveError: ""
    };
  },
  computed: Object.assign(
    {},
    mapState("tickets", ["loading", "error"]),
    mapGetters("tickets", { tickets: "allTickets" }), // renombrado: el template no cambia
    {
      filteredTickets: function () {
        // idéntico a la Fase 4: filtra this.tickets... que ahora es un getter.
        // El computed NO SE ENTERÓ de la migración. 🎩
        var self = this;
        var term = this.search.trim().toLowerCase();
        return this.tickets.filter(function (t) {
          var matchesSearch = !term || t.title.toLowerCase().indexOf(term) !== -1;
          var matchesStatus = !self.statusFilter || t.status === self.statusFilter;
          return matchesSearch && matchesStatus;
        });
      }
    }
  ),
  mounted: function () {
    this.fetchTickets(); // el caché de la action decide si hay red o no
  },
  methods: Object.assign(
    {},
    mapActions("tickets", ["fetchTickets"]),
    {
      clearFilters: function () { this.search = ""; this.statusFilter = ""; },
      goToDetail: function (ticket) { this.$router.push("/tickets/" + ticket.id); },
      openCreate: function () {
        this.editing = false;
        this.editingId = null;
        this.editingTicket = null;
        this.saveError = "";
        this.formDialog = true;
      },
      openEdit: function (ticket) {
        this.editing = true;
        this.editingId = ticket.id;
        this.editingTicket = ticket;
        this.saveError = "";
        this.formDialog = true;
      },
      closeForm: function () {
        this.formDialog = false;
      },
      onSubmit: function (formData) {
        var self = this;
        this.saving = true;
        this.saveError = "";

        // reglas de negocio: las pone la VISTA, no el form (igual que en F5);
        // y el resultado entra al store, que es de donde lee la lista (F10)
        var request;
        if (this.editing) {
          request = this.$store.dispatch("tickets/updateTicket", { id: this.editingId, changes: formData });
        } else {
          var payload = Object.assign({}, formData, {
            status: "open",
            reporter: this.$store.getters["auth/currentUser"].username,
            createdAt: new Date().toISOString()
          });
          request = ticketService.createTicket(payload).then(function (created) {
            self.$store.commit("tickets/UPSERT_TICKET", created);
            return created;
          });
        }

        return request
          .then(function () {
            self.formDialog = false;
          })
          .catch(function () {
            self.saveError = "No se pudo guardar. Intenta de nuevo.";
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
        return ticketService
          .deleteTicket(this.toDelete.id)
          .then(function () {
            self.confirmDelete = false;
            return self.fetchTickets({ force: true });
          })
          .catch(function () {
            self.saveError = "No se pudo eliminar.";
            self.confirmDelete = false;
          })
          .finally(function () {
            self.deleting = false;
          });
      }
    }
  )
  // beforeDestroy: ya no hay socket que dar de baja. Una preocupación menos.
};
</script>
