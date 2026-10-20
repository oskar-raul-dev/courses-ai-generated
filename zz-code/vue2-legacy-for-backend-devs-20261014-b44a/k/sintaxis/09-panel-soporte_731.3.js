var __a = [
module.exports = {
  name: "SupportView",
  components: { PageTitle, SupportQueue, TicketWorkspace },
  data: function () {
    return {
      tickets: [],
      users: [],
      selectedId: null,
      loading: true,
      error: ""
    };
  },
  computed: {
    me: function () {
      return this.$store.getters["auth/currentUser"];
    },
    selectedTicket: function () {
      var self = this;
      return this.tickets.find(function (t) {
        return t.id === self.selectedId;
      }) || null;
    }
  },
  mounted: function () {
    this.loadData();
    this.onCreatedHandler = this.onTicketCreated.bind(this);
    socketService.on("ticket:created", this.onCreatedHandler);
  },
  beforeDestroy: function () {
    socketService.off("ticket:created", this.onCreatedHandler);
  },
  methods: {
    loadData: function () {
      var self = this;
      this.loading = true;
      this.error = "";

      Promise.all([
        ticketService.getTickets({ _sort: "createdAt", _order: "desc" }),
        userService.getUsers()
      ])
        .then(function (results) {
          self.tickets = results[0];
          self.users = results[1];
        })
        .catch(function () {
          self.error = "No se pudo cargar el panel. ¿Está corriendo la Mock API?";
        })
        .finally(function () {
          self.loading = false;
        });
    },
    selectTicket: function (ticket) {
      this.selectedId = ticket.id;
      ticket.isNew = false; // deja de brillar al abrirlo
    },
    onTicketUpdated: function (updated) {
      var index = this.tickets.findIndex(function (t) {
        return t.id === updated.id;
      });
      if (index !== -1) {
        this.tickets.splice(index, 1, updated); // splice: reactivo (F8) ✅
      }
    },
    onTicketCreated: function (ticket) {
      ticket.isNew = true; // ⚠️ ver nota abajo
      this.tickets.unshift(ticket);
    }
  }
};

];