<template>
  <ul><li v-for="t in tickets" :key="t.id">{{ t.title }}</li></ul>
</template>
<script>
export default {
  asyncData: function (ctx) {
    return ctx.$axios
      .$get("/tickets", { params: { _sort: "createdAt", _order: "desc" } })
      .then(function (tickets) { return { tickets: tickets }; })
      .catch(function () {
        ctx.error({ statusCode: 503, message: "No se pudieron cargar los tickets." });
      });
  },
  data: function () { return { tickets: [] }; }
};
</script>
