<template>
  <div>
    <h5 class="mb-3">¿Qué pasó?</h5>

    <q-form ref="form" class="q-gutter-md">
      <q-input
        v-model.trim="form.title"
        label="Título *"
        outlined
        lazy-rules
        :rules="[rules.required, rules.minLen(5), rules.maxLen(80)]"
      />
      <q-input
        v-model.trim="form.description"
        label="Descripción *"
        type="textarea"
        rows="4"
        outlined
        lazy-rules
        :rules="[rules.required, rules.minLen(10)]"
      />
    </q-form>
  </div>
</template>

<script>
import * as rules from "../../../utils/rules";

export default {
  name: "StepData",
  props: {
    draft: { type: Object, required: true }
  },
  data: function () {
    return {
      rules: rules,
      form: {
        title: this.draft.title,
        description: this.draft.description
      }
    };
  },
  methods: {
    // API pública del paso: ahora devuelve la PROMESA de QForm (Concepto 3)
    validate: function () {
      return this.$refs.form.validate();
    },
    getData: function () {
      return Object.assign({}, this.form);
    }
  }
};
</script>
