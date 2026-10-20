<template>
  <div>
    <button
      v-for="status in available"
      :key="status"
      class="btn btn-sm mr-2"
      :class="labelFor(status).css"
      :disabled="busy"
      @click="$emit('change', status)"
    >
      {{ labelFor(status).label }}
    </button>
    <span v-if="available.length === 0" class="text-muted small">
      Sin movimientos disponibles.
    </span>
  </div>
</template>

<script>
import { nextStatuses, TRANSITION_LABELS } from "../../utils/ticketTransitions";

export default {
  name: "StatusActions",
  props: {
    status: { type: String, required: true },
    busy: { type: Boolean, default: false }
  },
  computed: {
    available: function () {
      return nextStatuses(this.status);
    }
  },
  methods: {
    labelFor: function (status) {
      return TRANSITION_LABELS[status] || { label: status, css: "btn-light" };
    }
  }
};
</script>
