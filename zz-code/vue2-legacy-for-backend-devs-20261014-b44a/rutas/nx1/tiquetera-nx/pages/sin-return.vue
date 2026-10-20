<template><ul><li v-for="t in allTickets" :key="t.id">{{ t.title }}</li></ul></template>
<script>
import { mapGetters } from "vuex";
export default {
  fetch: function () {
    this.$store.dispatch("tickets/fetchTickets");
  },
  computed: mapGetters("tickets", ["allTickets"])
};
</script>
