<template>
  <div>
    <h5 class="mb-3">Clasifica el ticket</h5>

    <div class="form-row">
      <div class="form-group col-md-6">
        <label for="priority">Prioridad *</label>
        <select
          id="priority"
          v-model="form.priority"
          class="form-control"
          :class="{ 'is-invalid': $v.form.priority.$error }"
          @blur="$v.form.priority.$touch()"
        >
          <option value="">Seleccione...</option>
          <option value="low">Baja</option>
          <option value="medium">Media</option>
          <option value="high">Alta</option>
        </select>
        <div v-if="$v.form.priority.$error" class="invalid-feedback">
          Seleccione una prioridad.
        </div>
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
import { required } from "vuelidate/lib/validators";

function oneOf(values) {
  return function (value) {
    return values.indexOf(value) !== -1;
  };
}

export default {
  name: "StepClassification",
  props: {
    draft: { type: Object, required: true }
  },
  data: function () {
    return {
      form: {
        priority: this.draft.priority,
        assignee: this.draft.assignee
      }
    };
  },
  validations: {
    form: {
      priority: { required: required, oneOf: oneOf(["low", "medium", "high"]) }
    }
  },
  methods: {
    validate: function () {
      this.$v.$touch();
      return !this.$v.$invalid;
    },
    getData: function () {
      return Object.assign({}, this.form);
    }
  }
};
</script>
