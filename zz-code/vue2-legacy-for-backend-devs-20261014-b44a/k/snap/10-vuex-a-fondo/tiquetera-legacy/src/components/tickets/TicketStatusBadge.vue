<template>
  <span class="badge" :class="badgeClass">{{ label }}</span>
</template>

<script>
var STATUS_MAP = {
  open:        { label: "Abierto",     css: "badge-danger" },
  in_progress: { label: "En progreso", css: "badge-warning" },
  resolved:    { label: "Resuelto",    css: "badge-success" },
  closed:      { label: "Cerrado",     css: "badge-secondary" }
};

export default {
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
</script>
