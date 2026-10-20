var __o = {
onTicketUpdated: function (updated) {
  var i = this.tickets.findIndex(function (t) { return t.id === updated.id; });
  this.tickets[i] = updated;    // ⚠️ ni un error, ni un repintado
}
};