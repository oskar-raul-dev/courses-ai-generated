var __a = [
computed: {
  filteredTickets: function () {
    // se recalcula SOLO si cambia this.tickets, this.search o this.statusFilter
    var self = this;
    return this.tickets.filter(function (t) {
      return t.title.toLowerCase().indexOf(self.search.toLowerCase()) !== -1;
    });
  }
}
];