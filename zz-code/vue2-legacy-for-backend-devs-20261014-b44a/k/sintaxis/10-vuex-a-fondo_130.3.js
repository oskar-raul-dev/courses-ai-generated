var __a = [
module.exports = {
  computed: Object.assign(
    {},
    mapState("tickets", ["loading", "error"]),      // → this.loading, this.error
    mapGetters("tickets", ["allTickets", "counts"]), // → this.allTickets, ...
    mapGetters("auth", { me: "currentUser" }),       // renombrando: this.me
    {
      // y tus computed propios conviven en el mismo objeto
      filteredTickets: function () { /* ... */ }
    }
  ),
  methods: Object.assign(
    {},
    mapActions("tickets", ["fetchTickets", "updateTicket"]),
    { /* métodos propios */ }
  )
};
];