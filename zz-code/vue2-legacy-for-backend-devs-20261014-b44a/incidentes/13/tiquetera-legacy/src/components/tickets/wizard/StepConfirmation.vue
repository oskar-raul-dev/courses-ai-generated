<template>
  <div>
    <h5 class="mb-3">Confirma antes de crear</h5>

    <dl class="row">
      <dt class="col-sm-3">Título</dt>
      <dd class="col-sm-9">{{ draft.title }}</dd>

      <dt class="col-sm-3">Descripción</dt>
      <dd class="col-sm-9" style="white-space: pre-line;">{{ draft.description }}</dd>

      <dt class="col-sm-3">Prioridad</dt>
      <dd class="col-sm-9">
        <ticket-priority-badge :priority="draft.priority" />
      </dd>

      <dt class="col-sm-3">Asignado a</dt>
      <dd class="col-sm-9">{{ draft.assignee || "Sin asignar" }}</dd>
    </dl>

    <div class="alert alert-info">
      El ticket se creará con estado <strong>Abierto</strong> a nombre de
      <strong>{{ reporterName }}</strong>.
    </div>
  </div>
</template>

<script>
import TicketPriorityBadge from "../TicketPriorityBadge.vue";

export default {
  name: "StepConfirmation",
  components: { TicketPriorityBadge },
  props: {
    draft: { type: Object, required: true }
  },
  computed: {
    reporterName: function () {
      var user = this.$store.getters["auth/currentUser"];
      return user ? user.name : "";
    }
  }
};
</script>
