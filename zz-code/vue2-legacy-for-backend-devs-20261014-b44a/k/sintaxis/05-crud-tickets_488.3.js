var __a = [
module.exports = {
  name: "TicketEditView",
  components: { PageTitle, TicketForm },
  data: function () {
    return { ticket: null, loading: false, saving: false, error: "" };
  },
  mounted: function () {
    this.loadTicket();
  },
  methods: {
    loadTicket: function () {
      var self = this;
      this.loading = true;

      ticketService
        .getTicketById(this.$route.params.id)
        .then(function (ticket) {
          self.ticket = ticket;
        })
        .catch(function () {
          self.error = "No se pudo cargar el ticket.";
        })
        .finally(function () {
          self.loading = false;
        });
    },
    updateTicket: function (formData) {
      var self = this;
      this.saving = true;
      this.error = "";

      ticketService
        .updateTicket(this.$route.params.id, formData)
        .then(function () {
          self.$router.push("/tickets/" + self.$route.params.id);
        })
        .catch(function () {
          self.error = "No se pudieron guardar los cambios.";
        })
        .finally(function () {
          self.saving = false;
        });
    }
  }
};

];