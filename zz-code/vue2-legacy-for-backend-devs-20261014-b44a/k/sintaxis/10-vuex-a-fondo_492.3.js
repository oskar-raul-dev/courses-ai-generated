var __a = [
// views/TicketsView.vue — DESPUÉS (el <script> completo). En el template cambia una
// sola cosa: el botón Reintentar llama a fetchTickets(), porque loadTickets ya no existe
module.exports = {
  name: "TicketsView",
  components: { PageTitle, TicketsTable, TicketsSummary },
  // data: se van tickets, loading, error → QUEDAN search y statusFilter
  data: function () {
    return { search: "", statusFilter: "" };
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
      goToDetail: function (ticket) { this.$router.push("/tickets/" + ticket.id); }
    }
  )
  // beforeDestroy: ya no hay socket que dar de baja. Una preocupación menos.
};
];