var __a = [
module.exports = {
  name: "TicketCreateView",
  components: { PageTitle, TicketForm },
  data: function () {
    return { saving: false, error: "" };
  },
  methods: {
    createTicket: function (formData) {
      var self = this;
      this.saving = true;
      this.error = "";

      var payload = Object.assign({}, formData, {
        status: "open", // todo ticket nace abierto: regla de negocio, no del form
        reporter: this.$store.getters["auth/currentUser"].username,
        createdAt: new Date().toISOString()
      });

      ticketService
        .createTicket(payload)
        .then(function (created) {
          self.$router.push("/tickets/" + created.id);
        })
        .catch(function () {
          self.error = "No se pudo crear el ticket. Intenta de nuevo.";
        })
        .finally(function () {
          self.saving = false;
        });
    }
  }
};

];