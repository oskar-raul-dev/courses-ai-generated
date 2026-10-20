<template>
  <v-form ref="form" v-model="valid" @submit.prevent="handleSubmit">
    <v-text-field
      v-model.trim="form.title"
      label="Título *"
      data-testid="ticket-title"
      :rules="titleRules"
    />

    <v-textarea
      v-model.trim="form.description"
      label="Descripción *"
      rows="4"
      data-testid="ticket-description"
      :rules="descriptionRules"
    />

    <v-row>
      <v-col cols="12" md="6">
        <v-select
          v-model="form.priority"
          :items="priorityOptions"
          item-text="text"
          item-value="value"
          label="Prioridad *"
          data-testid="ticket-priority"
          :rules="priorityRules"
        />
        <!-- SIN return-object: v-model emite el string "high", que es lo que
             el store espera. Ver Concepto 4. -->
      </v-col>
      <v-col cols="12" md="6">
        <v-text-field
          v-model.trim="form.assignee"
          label="Asignado a"
          data-testid="ticket-assignee"
          placeholder="(opcional)"
        />
      </v-col>
    </v-row>

    <div class="mt-3">
      <v-btn
        type="submit"
        color="primary"
        data-testid="ticket-submit"
        :disabled="!valid"
        :loading="saving"
      >
        {{ submitLabel }}
      </v-btn>
      <v-btn text data-testid="ticket-cancel" @click="$emit('cancel')">
        Cancelar
      </v-btn>
    </div>
  </v-form>
</template>

<script>
import { required, minLen, maxLen, oneOf } from "../../utils/rules";

export default {
  name: "TicketForm",
  props: {
    initialTicket: { type: Object, default: null },
    saving: { type: Boolean, default: false },
    submitLabel: { type: String, default: "Guardar" }
  },
  data: function () {
    return {
      valid: false,
      form: { title: "", description: "", priority: "", assignee: "" },
      priorityOptions: [
        { text: "Baja", value: "low" },
        { text: "Media", value: "medium" },
        { text: "Alta", value: "high" }
      ],
      // Reglas armadas una vez; el template solo las referencia.
      titleRules: [required("El título es obligatorio."), minLen(5), maxLen(80)],
      descriptionRules: [
        required("La descripción es obligatoria."),
        minLen(10, "Cuenta un poco más: mínimo 10 caracteres.")
      ],
      priorityRules: [
        required("Seleccione una prioridad."),
        oneOf(["low", "medium", "high"])
      ]
    };
  },
  created: function () {
    if (this.initialTicket) {
      // copia local: NUNCA editamos la prop directamente (patrón de F5)
      this.form = Object.assign({}, this.form, this.initialTicket);
    }
  },
  methods: {
    handleSubmit: function () {
      // v-model="valid" + :disabled="!valid" ya bloquean el submit inválido,
      // pero validamos por si acaso (Enter, autofill, etc.).
      if (!this.$refs.form.validate()) {
        return;
      }
      this.$emit("submit", Object.assign({}, this.form));
    }
  }
};
</script>
