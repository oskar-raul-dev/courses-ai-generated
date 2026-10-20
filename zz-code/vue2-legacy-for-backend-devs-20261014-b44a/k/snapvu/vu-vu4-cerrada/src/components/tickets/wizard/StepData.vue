<template>
  <div>
    <h5 class="mb-3">¿Qué pasó?</h5>

    <v-form ref="form">
      <v-text-field v-model.trim="form.title" label="Título *" :rules="titleRules" />
      <v-textarea v-model.trim="form.description" label="Descripción *" rows="4" :rules="descriptionRules" />
    </v-form>
  </div>
</template>

<script>
import { required, minLen, maxLen } from "../../../utils/rules";

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
      },
      titleRules: [required("El título es obligatorio."), minLen(5), maxLen(80)],
      descriptionRules: [required(), minLen(10, "Cuenta qué pasó: mínimo 10 caracteres.")]
    };
  },
  methods: {
    // API pública del paso: v-form valida en síncrono, así que el wizard no cambia
    validate: function () {
      return this.$refs.form.validate();
    },
    getData: function () {
      return Object.assign({}, this.form);
    }
  }
};
</script>
