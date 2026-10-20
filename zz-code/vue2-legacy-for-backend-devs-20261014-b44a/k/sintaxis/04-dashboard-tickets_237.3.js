var __a = [

var STATUS_MAP = {
  open:        { label: "Abierto",     css: "badge-danger" },
  in_progress: { label: "En progreso", css: "badge-warning" },
  resolved:    { label: "Resuelto",    css: "badge-success" },
  closed:      { label: "Cerrado",     css: "badge-secondary" }
};
module.exports = {
  name: "TicketStatusBadge",
  props: {
    status: { type: String, required: true }
  },
  computed: {
    badgeClass: function () {
      var entry = STATUS_MAP[this.status];
      return entry ? entry.css : "badge-light";
    },
    label: function () {
      var entry = STATUS_MAP[this.status];
      return entry ? entry.label : this.status;
    }
  }
};

];