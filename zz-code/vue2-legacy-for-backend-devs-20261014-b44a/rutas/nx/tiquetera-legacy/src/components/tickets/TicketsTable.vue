<template>
  <div>
    <table class="table table-hover table-sm">
      <thead class="thead-light">
        <tr>
          <th>#</th>
          <th>Título</th>
          <th>Estado</th>
          <th>Prioridad</th>
          <th>Asignado</th>
          <th>Creado</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="ticket in tickets"
          :key="ticket.id"
          :data-testid="'ticket-row-' + ticket.id"
          style="cursor: pointer;"
          @click="$emit('select', ticket)"
        >
          <td>{{ ticket.id }}</td>
          <td>{{ ticket.title }}</td>
          <td><ticket-status-badge :status="ticket.status" /></td>
          <td><ticket-priority-badge :priority="ticket.priority" /></td>
          <td>{{ ticket.assignee }}</td>
          <td>{{ ticket.createdAt | formatDate }}</td>
        </tr>
      </tbody>
    </table>

    <div v-if="tickets.length === 0" class="text-center text-muted py-4">
      <p class="mb-0">🔍 No hay tickets que coincidan con los filtros.</p>
    </div>
  </div>
</template>

<script>
import TicketStatusBadge from "./TicketStatusBadge.vue";
import TicketPriorityBadge from "./TicketPriorityBadge.vue";

export default {
  name: "TicketsTable",
  components: { TicketStatusBadge, TicketPriorityBadge },
  props: {
    tickets: { type: Array, required: true }
  }
};
</script>
