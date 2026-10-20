var __o = {

var PRIORITY_CSS = {
  high: "badge-danger",
  medium: "badge-warning",
  low: "badge-info"
};
module.exports = {
  name: "TicketPriorityBadge",
  props: {
    priority: { type: String, required: true }
  },
  computed: {
    badgeClass: function () {
      return PRIORITY_CSS[this.priority] || "badge-light";
    }
  }
};

};