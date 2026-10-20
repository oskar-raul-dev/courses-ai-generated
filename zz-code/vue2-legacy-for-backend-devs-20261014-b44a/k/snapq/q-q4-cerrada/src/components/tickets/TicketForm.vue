<template>
  <q-form ref="ticketForm" @submit="handleSubmit" class="q-gutter-md">

    <!-- Título -->
    <q-input
      v-model.trim="form.title"
      label="Título *"
      outlined
      lazy-rules
      data-testid="ticket-title"
      :rules="[rules.required, rules.minLen(5), rules.maxLen(80), rules.notAllCaps]"
    />

    <!-- Descripción -->
    <q-input
      v-model.trim="form.description"
      label="Descripción *"
      type="textarea"
      rows="4"
      outlined
      lazy-rules
      data-testid="ticket-description"
      :rules="[rules.required, rules.minLen(10)]"
    />

    <div class="row q-col-gutter-md">
      <!-- Prioridad: EL q-select. Lee el Concepto 4 dos veces. -->
      <div class="col-12 col-md-6">
        <q-select
          v-model="form.priority"
          :options="priorityOptions"
          option-value="value"
          option-label="label"
          emit-value
          map-options
          label="Prioridad *"
          outlined
          lazy-rules
          data-testid="ticket-priority"
          :rules="[rules.required]"
        />
      </div>

      <!-- Asignado (opcional: sin reglas) -->
      <div class="col-12 col-md-6">
        <q-input
          v-model.trim="form.assignee"
          label="Asignado a"
          placeholder="(opcional)"
          outlined
          data-testid="ticket-assignee"
        />
      </div>
    </div>

    <div>
      <!-- ⚠️ type="submit" y NADA MÁS. Sin @click. (Concepto 5) -->
      <q-btn
        type="submit"
        :label="submitLabel"
        :loading="saving"
        :disable="saving"
        color="primary"
        data-testid="ticket-submit"
      />
      <q-btn
        flat
        label="Cancelar"
        class="q-ml-sm"
        @click="$emit('cancel')"
        data-testid="ticket-cancel"
      />
    </div>

  </q-form>
</template>

<script>
import * as rules from "../../utils/rules";

export default {
  name: "TicketForm",
  props: {
    initialTicket: { type: Object, default: null },
    saving: { type: Boolean, default: false },
    submitLabel: { type: String, default: "Guardar" }
  },
  data: function () {
    return {
      // 🔎 Las reglas viven aquí para poder usarlas en el template.
      //    (Los imports no son accesibles desde el template en Options API.)
      rules: rules,
      priorityOptions: [
        { label: "Baja", value: "low" },
        { label: "Media", value: "medium" },
        { label: "Alta", value: "high" }
      ],
      // La copia local. Este patrón NO cambia con Quasar. (F5, sigue vigente.)
      form: {
        title: "",
        description: "",
        priority: null,   // ⚠️ null, no "": QSelect trabaja mejor con null
        assignee: ""
      }
      // ☠️ formError: NO EXISTE. QForm lo gestiona. (Concepto 2)
    };
  },
  // ☠️ validations: {...}  NO EXISTE. Se murió con vuelidate.
  created: function () {
    if (this.initialTicket) {
      this.form = Object.assign({}, this.form, this.initialTicket);
    }
  },
  methods: {
    handleSubmit: function () {
      // 🔎 Si estás aquí, QForm YA validó todo. No hay if, no hay $touch,
      //    no hay guardián. Esa ausencia es la migración.
      this.$emit("submit", Object.assign({}, this.form));
    }
  }
};
</script>
