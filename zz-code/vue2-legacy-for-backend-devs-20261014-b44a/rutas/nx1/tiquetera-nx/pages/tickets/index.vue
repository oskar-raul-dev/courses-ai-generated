<template>
  <div class="container mt-3">
    <!-- loading: solo se ve al navegar en cliente; en SSR nunca. Y está bien. -->
    <div v-if="loading" class="text-muted">Cargando tickets…</div>

    <div v-else-if="$fetchState.error" class="alert alert-danger">{{ storeError }}</div>

    <TicketTable v-else :tickets="allTickets" />
    <!-- 🔎 TicketTable es el componente TONTO de F4: recibe tickets por prop,
         no pide nada. En Nuxt esto deja de ser buena práctica opcional y pasa
         a ser obligatorio: los componentes no cargan datos en SSR. -->
  </div>
</template>

<script>
import { mapState, mapGetters } from "vuex";
import TicketTable from "~/components/tickets/TicketsTable.vue"; // ruta real del componente de F4

export default {
  components: { TicketTable: TicketTable },

  // ⬇️ fetch (con this): corre en servidor la 1ª vez, en cliente al navegar.
  //    Despacha la MISMA action de F10. La vista no sabe que está en Nuxt.
  fetch: function () {
    var nuxt = this.$nuxt;
    return this.$store.dispatch("tickets/fetchTickets").catch(function (err) {
      // en el servidor, que la respuesta diga la verdad: 503, no 200
      if (process.server) {
        nuxt.context.res.statusCode = 503;
      }
      throw err; // y $fetchState.error queda puesto
    });
  },

  // desde Nuxt 2.12, fetch expone su propio estado de carga:
  computed: Object.assign(
    {},
    mapState("tickets", { storeError: "error" }),
    mapGetters("tickets", ["allTickets"]),
    {
      loading: function () {
        // $fetchState.pending: true mientras fetch() está en curso (cliente)
        return this.$fetchState.pending;
      }
    }
  )
};
</script>
