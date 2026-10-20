<template>
  <span class="badge badge-pill" :class="badgeClass">{{ priority }}</span>
</template>

<script>
var PRIORITY_CSS = {
  high: "badge-danger",
  medium: "badge-warning",
  low: "badge-info"
};

export default {
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
</script>
