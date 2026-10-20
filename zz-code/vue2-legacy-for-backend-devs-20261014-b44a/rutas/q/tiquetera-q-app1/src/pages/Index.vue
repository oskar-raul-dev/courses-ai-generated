<template>
  <q-page class="flex flex-center">
    <img
      alt="Quasar logo"
      src="~assets/quasar-logo-vertical.svg"
      style="width: 200px; height: 200px"
    >
    <!-- 🧪 EXPERIMENTO: QChip NO está en framework.components -->
    <q-chip color="primary" text-color="white">
      Ticket #1 abierto
    </q-chip>
  </q-page>
</template>

<script>
export default {
  name: 'PageIndex'
}
</script>
