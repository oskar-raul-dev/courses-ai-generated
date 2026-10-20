<template>
  <div class="card text-center h-100">
    <div class="card-body py-3">
      <h2 class="mb-0" :class="valueClass">{{ value }}</h2>
      <small class="text-muted">{{ label }}</small>
    </div>
  </div>
</template>

<script>
export default {
  name: "MetricCard",
  props: {
    label: { type: String, required: true },
    value: { type: [Number, String], required: true }, // prop con DOS tipos válidos
    valueClass: { type: String, default: "" }
  }
};
</script>
