function __f(){


// en mounted, además de loadTickets():
mounted: function () {
  this.loadTickets();
  this.onCreatedHandler = this.onTicketCreated.bind(this);
  socketService.on("ticket:created", this.onCreatedHandler);
},
beforeDestroy: function () {
  socketService.off("ticket:created", this.onCreatedHandler);
},

// en methods:
onTicketCreated: function (ticket) {
  // unshift es uno de los 7 métodos parcheados: reactividad garantizada
  this.tickets.unshift(ticket);
  // y la cadena de la Fase 4 hace el resto: filteredTickets → summary → tabla
}
}