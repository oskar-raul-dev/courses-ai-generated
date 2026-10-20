function __f(){
// antes: computed: { filteredTickets: function () { … } }
// ahora: data: function () { return { filteredTickets: [] }; }
//        created: function () { this.filteredTickets = this.filter(this.tickets); }
}