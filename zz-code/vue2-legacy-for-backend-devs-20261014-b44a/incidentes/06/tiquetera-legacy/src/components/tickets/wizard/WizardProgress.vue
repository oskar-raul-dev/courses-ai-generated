<template>
  <div class="d-flex justify-content-between mb-4">
    <div
      v-for="step in steps"
      :key="step.number"
      class="text-center flex-fill"
    >
      <div
        class="rounded-circle d-inline-flex align-items-center justify-content-center"
        style="width: 36px; height: 36px;"
        :class="circleClass(step.number)"
      >
        <span v-if="step.number < current">✓</span>
        <span v-else>{{ step.number }}</span>
      </div>
      <div class="small mt-1" :class="{ 'font-weight-bold': step.number === current }">
        {{ step.label }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "WizardProgress",
  props: {
    steps: { type: Array, required: true },   // [{ number, label }]
    current: { type: Number, required: true }
  },
  methods: {
    circleClass: function (number) {
      if (number < this.current) return "bg-success text-white";
      if (number === this.current) return "bg-primary text-white";
      return "bg-light border text-muted";
    }
  }
};
</script>
