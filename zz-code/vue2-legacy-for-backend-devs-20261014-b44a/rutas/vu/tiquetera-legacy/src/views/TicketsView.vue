<template>
  <v-container fluid>
    <div class="d-flex align-center mb-3">
      <h1 class="text-h5">Tickets</h1>
      <v-spacer />
      <v-btn color="primary" data-testid="ticket-new" @click="openCreate">Nuevo ticket</v-btn>
    </div>

    <!-- resumen: los cards de F4 pueden quedarse o migrarse (ejercicio 8) -->
    <tickets-summary :tickets="allTickets" />

    <!-- error del store (F3/F10), con su reintento -->
    <v-alert v-if="error" type="error" dense data-testid="tickets-error">
      {{ error }}
      <v-btn small text data-testid="tickets-retry" @click="fetchTickets()">Reintentar</v-btn>
    </v-alert>

    <v-row dense>
      <v-col cols="12" md="6">
        <!-- el buscador alimenta el :search built-in -->
        <v-text-field v-model="search" label="Buscar por título..." prepend-inner-icon="mdi-magnify" dense data-testid="tickets-search" />
      </v-col>
      <v-col cols="12" md="3">
        <v-select v-model="statusFilter" :items="statusOptions" label="Estado" dense data-testid="tickets-status-filter" />
      </v-col>
      <v-col cols="12" md="3">
        <v-btn text block data-testid="tickets-clear-filters" @click="clearFilters">Limpiar filtros</v-btn>
      </v-col>
    </v-row>

    <p class="grey--text text--darken-1 mb-2" data-testid="tickets-count">
      Mostrando {{ visibleCount }} de {{ allTickets.length }} tickets
    </p>

    <v-data-table
      :headers="headers"
      :items="ticketsByStatus"
      item-key="id"
      :search="search"
      :loading="loading"
      :items-per-page="10"
      :footer-props="{ 'items-per-page-options': [10, 25, 50] }"
      @click:row="goToDetail"
      @pagination="onPagination"
    >
      <!-- las anclas de VU0 viajan en las celdas: una por fila, y el título aparte -->
      <template v-slot:item.id="{ item }">
        <span :data-testid="'ticket-row-' + item.id">{{ item.id }}</span>
      </template>

      <template v-slot:item.title="{ item }">
        <span :data-testid="'ticket-title-' + item.id">{{ item.title }}</span>
      </template>

      <template v-slot:item.status="{ item }">
        <ticket-status-badge :status="item.status" />
      </template>

      <template v-slot:item.priority="{ item }">
        <ticket-priority-badge :priority="item.priority" />
      </template>

      <template v-slot:item.createdAt="{ item }">
        {{ item.createdAt | formatDate }}
      </template>

      <template v-slot:item.actions="{ item }">
        <v-btn icon small @click.stop="openEdit(item)">
          <v-icon small>mdi-pencil</v-icon>
        </v-btn>
      </template>

      <template v-slot:loading>
        <div class="py-4" data-testid="tickets-loading">Cargando tickets…</div>
      </template>
      <template v-slot:no-data>
        <div class="py-4 grey--text" data-testid="tickets-empty">🔍 No hay tickets.</div>
      </template>
      <template v-slot:no-results>
        <div class="py-4 grey--text" data-testid="tickets-empty">Sin coincidencias para "{{ search }}".</div>
      </template>
    </v-data-table>

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
  </v-container>
</template>

<script>
import { mapGetters, mapState, mapActions } from "vuex";
import TicketStatusBadge from "../components/tickets/TicketStatusBadge.vue";
import TicketPriorityBadge from "../components/tickets/TicketPriorityBadge.vue";
import TicketsSummary from "../components/tickets/TicketsSummary.vue";
import TicketForm from "../components/tickets/TicketForm.vue";
import ticketService from "../services/ticketService";
import socketService from "../services/socketService";

// headers como constante del módulo: no es reactivo, no muta nunca.
const HEADERS = [
  { text: "#",         value: "id",        align: "start",  sortable: true },
  { text: "Título",    value: "title",     align: "start",  sortable: true },
  { text: "Estado",    value: "status",    align: "center", sortable: true, filterable: false },
  { text: "Prioridad", value: "priority",  align: "center", sortable: true, filterable: false },
  { text: "Asignado",  value: "assignee",  align: "start",  sortable: true },
  { text: "Creado",    value: "createdAt", align: "end",    sortable: true, filterable: false },
  { text: "",          value: "actions",   align: "end",    sortable: false, filterable: false }
];

const STATUS_OPTIONS = [
  { text: "Todos los estados", value: "" },
  { text: "Abiertos",    value: "open" },
  { text: "En progreso", value: "in_progress" },
  { text: "Resueltos",   value: "resolved" },
  { text: "Cerrados",    value: "closed" }
];

export default {
  name: "TicketsView",
  components: { TicketStatusBadge, TicketPriorityBadge, TicketsSummary, TicketForm },
  data: function () {
    return {
      headers: HEADERS,
      statusOptions: STATUS_OPTIONS,
      search: "",       // local: la auditoría de F10 no lo mandó al store
      statusFilter: "",
      visibleCount: 0,  // lo informa la tabla, ya filtrado (@pagination)
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
    mapGetters("tickets", ["allTickets"]),
    mapState("tickets", ["loading", "error"]),
    {
      // el estado filtra antes de la tabla; el texto lo filtra ella (:search)
      ticketsByStatus: function () {
        var status = this.statusFilter;
        return this.allTickets.filter(function (t) { return !status || t.status === status; });
      }
    }
  ),
  mounted: function () {
    // modo CLIENTE: aquí SÍ disparas el fetch (no hay @update:options que lo haga)
    this.fetchTickets();
  },
  methods: Object.assign(
    {},
    mapActions("tickets", ["fetchTickets"]),
    {
      onPagination: function (p) {
        this.visibleCount = p.itemsLength;
      },
      clearFilters: function () {
        this.search = "";
        this.statusFilter = "";
      },
      goToDetail: function (ticket) {
        this.$router.push("/tickets/" + ticket.id);
      },
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
            socketService.emit("ticket:created", created); // 📣 anunciar a los demás, como en F8
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
};
</script>
