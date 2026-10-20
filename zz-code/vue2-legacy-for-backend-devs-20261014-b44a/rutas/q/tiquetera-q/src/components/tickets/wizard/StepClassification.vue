<template>
  <div>
    <h5 class="mb-3">Clasifica el ticket</h5>

    <div class="form-row">
      <div class="form-group col-md-6">
        <q-form ref="form">
          <q-select
            v-model="form.priority"
            :options="priorityOptions"
            emit-value
            map-options
            label="Prioridad *"
            outlined
            lazy-rules
            :rules="[rules.required]"
          />
        </q-form>
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
import * as rules from "../../../utils/rules";

export default {
  name: "StepClassification",
  props: {
    draft: { type: Object, required: true }
  },
  data: function () {
    return {
      rules: rules,
      priorityOptions: [
        { label: "Baja", value: "low" },
        { label: "Media", value: "medium" },
        { label: "Alta", value: "high" }
      ],
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
