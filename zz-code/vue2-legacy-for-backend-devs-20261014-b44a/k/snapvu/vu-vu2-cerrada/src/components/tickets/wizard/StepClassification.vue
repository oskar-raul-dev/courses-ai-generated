<template>
  <div>
    <h5 class="mb-3">Clasifica el ticket</h5>

    <div class="form-row">
      <div class="form-group col-md-6">
        <v-form ref="form">
          <v-select
            v-model="form.priority"
            :items="priorityOptions"
            label="Prioridad *"
            :rules="priorityRules"
          />
        </v-form>
      </div>

      <div class="form-group col-md-6">
        <label for="assignee">Asignar a</label>
        <input
          id="assignee"
          v-model.trim="form.assignee"
          class="form-control"
          placeholder="(opcional, soporte lo asignará)"
        />
      </div>
    </div>

    <div v-if="form.priority === 'high'" class="alert alert-warning">
      ⚠️ Los tickets de prioridad alta notifican al equipo de guardia.
      Úsala solo si bloquea tu trabajo.
    </div>
  </div>
</template>

<script>
import { required, oneOf } from "../../../utils/rules";


export default {
  name: "StepClassification",
  props: {
    draft: { type: Object, required: true }
  },
  data: function () {
    return {
      priorityOptions: [
        { text: "Baja", value: "low" },
        { text: "Media", value: "medium" },
        { text: "Alta", value: "high" }
      ],
      priorityRules: [required("Seleccione una prioridad."), oneOf(["low", "medium", "high"])],
      form: {
        priority: this.draft.priority,
        assignee: this.draft.assignee
      }
    };
  },
  methods: {
    validate: function () {
      return this.$refs.form.validate();
    },
    getData: function () {
      return Object.assign({}, this.form);
    }
  }
};
</script>
