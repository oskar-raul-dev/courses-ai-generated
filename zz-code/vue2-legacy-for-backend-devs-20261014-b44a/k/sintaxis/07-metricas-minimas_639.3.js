var __a = [
module.exports = {
  name: "MetricsView",
  components: { PageTitle, MetricCard, StatusDoughnut, AgentBarChart, ScoreBoard },
  data: function () {
    return {
      tickets: [],
      users: [],     // solo para las iniciales de la tabla de puntajes
      loading: true, // arranca en true: adiós al parpadeo de la Fase 4
      error: ""
    };
  },
  computed: {
    // envolturas de una línea sobre las funciones puras
    statusCounts: function () { return countByStatus(this.tickets); },
    agentRows: function () { return activeByAgent(this.tickets); },
    donePercent: function () { return resolvedPercent(this.tickets); },
    scoreRows: function () { return scoreBoard(this.tickets, this.users); },
    unassignedCount: function () {
      return this.tickets.filter(function (t) {
        return !t.assignee && t.status !== "closed";
      }).length;
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

      // 💸 DEUDA: /users va directo por apiClient; userService llega en la Fase 9
      apiClient
        .get("/users")
        .then(function (res) {
          self.users = res.data;
          return ticketService.getTickets();
        })
        .then(function (tickets) {
          self.tickets = tickets;
        })
        .catch(function () {
          self.error = "No se pudieron cargar las métricas. ¿Está corriendo la Mock API?";
        })
        .finally(function () {
          self.loading = false;
        });
    }
  }
};

];