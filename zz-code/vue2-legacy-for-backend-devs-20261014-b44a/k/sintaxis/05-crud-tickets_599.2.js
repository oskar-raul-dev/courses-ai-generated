var __o = {
// data: agregar deleting: false
// methods: agregar
removeTicket: function () {
  var self = this;

  var ok = window.confirm(
    "¿Eliminar el ticket #" + this.ticket.id + "? Esta acción no se puede deshacer."
  );
  if (!ok) return;

  this.deleting = true;

  ticketService
    .deleteTicket(this.ticket.id)
    .then(function () {
      self.$router.push("/tickets");
    })
    .catch(function () {
      self.error = "No se pudo eliminar el ticket.";
      self.deleting = false;
    });
}
};