<template><p>x</p></template>
<script>
export default {
  asyncData: function () {
    return this.$store.dispatch("tickets/fetchTickets");
  }
};
</script>
