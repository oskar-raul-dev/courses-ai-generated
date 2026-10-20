<template>
  <div>
    <h6 class="text-muted px-2">
      Sin asignar <span class="badge badge-danger">{{ unassigned.length }}</span>
    </h6>
    <div class="list-group mb-3">
      <button
        v-for="t in unassigned"
        :key="t.id"
        class="list-group-item list-group-item-action py-2"
        :class="{ active: t.id === selectedId, 'list-group-item-warning': t.isNew }"
        @click="$emit('select', t)"
      >
        <div class="d-flex justify-content-between align-items-center">
          <span class="text-truncate mr-2">#{{ t.id }} {{ t.title }}</span>
          <ticket-priority-badge :priority="t.priority" />
        </div>
      </button>
    </div>

    <h6 class="text-muted px-2">
      Míos <span class="badge badge-primary">{{ mine.length }}</span>
    </h6>
    <div class="list-group">
      <button
        v-for="t in mine"
        :key="t.id"
        class="list-group-item list-group-item-action py-2"
        :class="{ active: t.id === selectedId }"
        @click="$emit('select', t)"
      >
        <div class="d-flex justify-content-between align-items-center">
          <span class="text-truncate mr-2">#{{ t.id }} {{ t.title }}</span>
          <ticket-status-badge :status="t.status" />
        </div>
      </button>
    </div>
  </div>
</template>

<script>
import TicketPriorityBadge from "../tickets/TicketPriorityBadge.vue";
import TicketStatusBadge from "../tickets/TicketStatusBadge.vue";

export default {
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
</script>
