<template>
  <div class="row mb-4">
    <div class="col-6 col-md-3" v-for="card in cards" :key="card.status">
      <div class="card text-center">
        <div class="card-body py-3">
          <h2 class="mb-0">{{ card.count }}</h2>
          <small class="text-muted">{{ card.label }}</small>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "TicketsSummary",
  props: {
    tickets: { type: Array, required: true }
  },
  computed: {
    cards: function () {
      var self = this;
      var defs = [
        { status: "open", label: "Abiertos" },
        { status: "in_progress", label: "En progreso" },
        { status: "resolved", label: "Resueltos" },
        { status: "closed", label: "Cerrados" }
      ];

      return defs.map(function (def) {
        return {
          status: def.status,
          label: def.label,
          count: self.tickets.filter(function (t) {
            return t.status === def.status;
          }).length
        };
      });
    }
  }
};
</script>
