<template>
  <section>
    <page-title title="Tickets" subtitle="Mesa de soporte" />

<router-link to="/tickets/new" class="btn btn-primary mb-3">
  ➕ Nuevo ticket
</router-link>
<router-link to="/tickets/wizard" class="btn btn-outline-primary mb-3 ml-2">
  🪜 Asistente
</router-link>

    <!-- estado: cargando -->
    <div v-if="loading" class="text-center my-5">
      <div class="spinner-border text-primary" role="status"></div>
    </div>

    <!-- estado: error -->
    <div v-else-if="error" class="alert alert-danger">
      {{ error }}
      <button class="btn btn-sm btn-outline-danger ml-2" @click="loadTickets">
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
            type="text"
            class="form-control"
            placeholder="🔍 Buscar por título..."
          />
        </div>
        <div class="col-md-3 mb-2">
          <select v-model="statusFilter" class="form-control">
            <option value="">Todos los estados</option>
            <option value="open">Abiertos</option>
            <option value="in_progress">En progreso</option>
            <option value="resolved">Resueltos</option>
            <option value="closed">Cerrados</option>
          </select>
        </div>
        <div class="col-md-3 mb-2 text-right">
          <button class="btn btn-outline-secondary btn-block" @click="clearFilters">
            Limpiar filtros
          </button>
        </div>
      </div>

      <p class="text-muted small">
        Mostrando {{ filteredTickets.length }} de {{ tickets.length }} tickets
      </p>

      <tickets-table :tickets="filteredTickets" @select="goToDetail" />
    </template>
  </section>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";
import TicketsTable from "../components/tickets/TicketsTable.vue";
import TicketsSummary from "../components/tickets/TicketsSummary.vue";
import ticketService from "../services/ticketService";

export default {
  name: "TicketsView",
  components: { PageTitle, TicketsTable, TicketsSummary },
  data: function () {
    return {
      tickets: [],        // crudo: lo que devolvió la API
      search: "",         // crudo: lo que escribió el usuario
      statusFilter: "",   // crudo: lo que seleccionó
      loading: false,
      error: ""
    };
  },
  computed: {
    // derivado: nunca vive en data
    filteredTickets: function () {
      var self = this;
      var term = this.search.trim().toLowerCase();

      return this.tickets.filter(function (t) {
        var matchesSearch =
          !term || t.title.toLowerCase().indexOf(term) !== -1;
        var matchesStatus =
          !self.statusFilter || t.status === self.statusFilter;
        return matchesSearch && matchesStatus;
      });
    }
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
        .getTickets({ _sort: "createdAt", _order: "desc" })
        .then(function (tickets) {
          self.tickets = tickets;
        })
        .catch(function () {
          self.error = "No se pudieron cargar los tickets. ¿Está corriendo la Mock API?";
        })
        .finally(function () {
          self.loading = false;
        });
    },
    clearFilters: function () {
      this.search = "";
      this.statusFilter = "";
    },
    goToDetail: function (ticket) {
      this.$router.push("/tickets/" + ticket.id);
    }
  }
};
</script>
