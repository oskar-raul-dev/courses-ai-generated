module.exports = {
  name: "TicketsView",
  components: { PageTitle },
  data: function () {
    return {
      tickets: [],
      loading: false,
      error: ""
    };
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
        .getTickets()
        .then(function (tickets) {
          self.tickets = tickets;
        })
        .catch(function () {
          self.error = "No se pudieron cargar los tickets. ¿Está corriendo la Mock API?";
        })
        .finally(function () {
          self.loading = false;
        });
    }
  }
};
