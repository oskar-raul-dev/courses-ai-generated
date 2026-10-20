<template>
  <h1 class="h3 mb-3">
    {{ title }}
    <small v-if="subtitle" class="text-muted">{{ subtitle }}</small>
  </h1>
</template>

<script>
export default {
  name: "PageTitle",
  props: {
    title: { type: String, required: true },
    subtitle: { type: String, default: "" }
  }
};
</script>
