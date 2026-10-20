var __a = [
module.exports = {
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

];