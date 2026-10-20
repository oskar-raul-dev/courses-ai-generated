<template>
  <div>
    <h5 class="mb-3">¿Qué pasó?</h5>

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
        <span v-else>Entre 5 y 80 caracteres.</span>
      </div>
    </div>

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
        Cuenta qué pasó: mínimo 10 caracteres.
      </div>
    </div>
  </div>
</template>

<script>
import { required, minLength, maxLength } from "vuelidate/lib/validators";

export default {
  name: "StepData",
  props: {
    draft: { type: Object, required: true }
  },
  data: function () {
    return {
      form: {
        title: this.draft.title,
        description: this.draft.description
      }
    };
  },
  validations: {
    form: {
      title: { required: required, minLength: minLength(5), maxLength: maxLength(80) },
      description: { required: required, minLength: minLength(10) }
    }
  },
  methods: {
    // API pública del paso: el wizard la invoca por $refs
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
