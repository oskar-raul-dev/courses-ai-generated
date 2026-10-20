var __a = [
module.exports = {
  name: "TicketsSummary",
  props: {
    tickets: { type: Array, required: true }
  },
  computed: {
    cards: function () {
      var self = this;
      var defs = [
        { status: "open", label: "Abiertos" },
        { status: "in_progress", label: "En progreso" },
        { status: "resolved", label: "Resueltos" },
        { status: "closed", label: "Cerrados" }
      ];

      return defs.map(function (def) {
        return {
          status: def.status,
          label: def.label,
          count: self.tickets.filter(function (t) {
            return t.status === def.status;
          }).length
        };
      });
    }
  }
};

];