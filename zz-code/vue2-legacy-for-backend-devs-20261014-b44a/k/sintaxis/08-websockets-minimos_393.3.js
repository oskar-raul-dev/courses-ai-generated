var __a = [
module.exports = {
  name: "LiveToast",
  data: function () {
    return { ticket: null, visible: false };
  },
  mounted: function () {
    // guardamos la referencia enlazada para poder darla de baja idéntica
    this.handler = this.onTicketCreated.bind(this);
    socketService.on("ticket:created", this.handler);
  },
  beforeDestroy: function () {
    socketService.off("ticket:created", this.handler);
    clearTimeout(this.timer);
  },
  methods: {
    onTicketCreated: function (ticket) {
      this.ticket = ticket;
      this.visible = true;
      clearTimeout(this.timer);
      this.timer = setTimeout(this.hide.bind(this), 5000); // timer NO reactivo
    },
    hide: function () {
      this.visible = false;
    },
    go: function () {
      this.hide();
      this.$router.push("/tickets/" + this.ticket.id);
    }
  }
};

];