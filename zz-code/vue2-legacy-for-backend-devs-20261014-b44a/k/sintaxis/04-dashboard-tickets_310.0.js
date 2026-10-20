module.exports = {
  name: "TicketsTable",
  components: { TicketStatusBadge, TicketPriorityBadge },
  props: {
    tickets: { type: Array, required: true }
  }
};
