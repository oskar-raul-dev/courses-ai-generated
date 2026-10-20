function __f(){
var MOCK_TICKETS = [
  { id: 1, title: "La impresora no imprime", status: "open", priority: "high" },
  { id: 2, title: "No me llega el correo", status: "in_progress", priority: "medium" }
];

function getTickets() {
  return MOCK_TICKETS;
}

function getTicketById(id) {
  return MOCK_TICKETS.find(function (t) {
    return t.id === Number(id);
  });
}
module.exports = {
  getTickets: getTickets,
  getTicketById: getTicketById
};
}