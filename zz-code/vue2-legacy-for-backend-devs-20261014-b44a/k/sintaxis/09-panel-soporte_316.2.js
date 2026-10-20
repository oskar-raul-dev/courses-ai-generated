var __o = {
module.exports = {
  name: "SupportQueue",
  components: { TicketPriorityBadge, TicketStatusBadge },
  props: {
    tickets: { type: Array, required: true },
    selectedId: { type: Number, default: null },
    currentUsername: { type: String, required: true }
  },
  computed: {
    unassigned: function () {
      return this.tickets.filter(function (t) {
        return !t.assignee && t.status !== "closed";
      });
    },
    mine: function () {
      var self = this;
      return this.tickets.filter(function (t) {
        return t.assignee === self.currentUsername && t.status !== "closed";
      });
    }
  }
};

};