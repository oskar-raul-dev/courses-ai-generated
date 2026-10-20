<template>
  <form @submit.prevent="handleSubmit" novalidate>
    <!-- Título -->
    <div class="form-group">
      <label for="title">Título *</label>
      <input
        id="title"
        v-model.trim="form.title"
        type="text"
        class="form-control"
        :class="{ 'is-invalid': $v.form.title.$error }"
        @blur="$v.form.title.$touch()"
      />
      <div v-if="$v.form.title.$error" class="invalid-feedback">
        <span v-if="!$v.form.title.required">El título es obligatorio.</span>
        <span v-else-if="!$v.form.title.minLength">
          Mínimo {{ $v.form.title.$params.minLength.min }} caracteres.
        </span>
        <span v-else-if="!$v.form.title.maxLength">
          Máximo {{ $v.form.title.$params.maxLength.max }} caracteres.
        </span>
      </div>
    </div>

    <!-- Descripción -->
    <div class="form-group">
      <label for="description">Descripción *</label>
      <textarea
        id="description"
        v-model.trim="form.description"
        rows="4"
        class="form-control"
        :class="{ 'is-invalid': $v.form.description.$error }"
        @blur="$v.form.description.$touch()"
      ></textarea>
      <div v-if="$v.form.description.$error" class="invalid-feedback">
        <span v-if="!$v.form.description.required">La descripción es obligatoria.</span>
        <span v-else>Cuenta un poco más: mínimo 10 caracteres.</span>
      </div>
    </div>

    <div class="form-row">
      <!-- Prioridad -->
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
          Seleccione una prioridad válida.
        </div>
      </div>

      <!-- Asignado -->
      <div class="form-group col-md-6">
        <label for="assignee">Asignado a</label>
        <input
          id="assignee"
          v-model.trim="form.assignee"
          type="text"
          class="form-control"
          placeholder="(opcional)"
        />
      </div>
    </div>

    <div class="mt-3">
      <button type="submit" class="btn btn-primary" :disabled="saving">
        {{ saving ? "Guardando..." : submitLabel }}
      </button>
      <button type="button" class="btn btn-link" @click="$emit('cancel')">
        Cancelar
      </button>
    </div>
  </form>
</template>

<script>
import { required, minLength, maxLength } from "vuelidate/lib/validators";

// Validador custom: valor dentro de una lista permitida.
function oneOf(values) {
  return function (value) {
    return values.indexOf(value) !== -1;
  };
}

export default {
  name: "TicketForm",
  props: {
    // vacío para crear, con datos para editar
    initialTicket: { type: Object, default: null },
    saving: { type: Boolean, default: false },
    submitLabel: { type: String, default: "Guardar" }
  },
  data: function () {
    return {
      // copia local: NUNCA editamos la prop directamente
      form: {
        title: "",
        description: "",
        priority: "",
        assignee: ""
      }
    };
  },
  validations: {
    form: {
      title: { required: required, minLength: minLength(5), maxLength: maxLength(80) },
      description: { required: required, minLength: minLength(10) },
      priority: { required: required, oneOf: oneOf(["low", "medium", "high"]) }
    }
  },
  created: function () {
    if (this.initialTicket) {
      // clonado superficial suficiente para un objeto plano
      this.form = Object.assign({}, this.form, this.initialTicket);
    }
  },
  methods: {
    handleSubmit: function () {
      this.$v.$touch();
      if (this.$v.$invalid) {
        return; // los errores ya se pintan solos vía $error
      }
      this.$emit("submit", Object.assign({}, this.form));
    }
  }
};
</script>
