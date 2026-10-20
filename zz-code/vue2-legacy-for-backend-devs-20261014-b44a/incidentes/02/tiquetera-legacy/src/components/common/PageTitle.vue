<!-- creado desde la especificación del ejercicio 6 de F1: NO es código publicado en F1 (hallazgo H-V1-4) -->
<template>
  <h1 class="h3 mb-3">{{ title }}</h1>
</template>

<script>
export default {
  name: "PageTitle",
  props: {
    title: { type: String, required: true }
  }
};
</script>
