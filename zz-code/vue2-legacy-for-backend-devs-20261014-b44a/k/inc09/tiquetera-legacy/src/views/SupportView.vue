<template>
  <section>
    <page-title title="Panel de soporte" subtitle="Cola de trabajo del agente" />

    <div v-if="loading" class="text-center my-5">
      <div class="spinner-border text-primary" role="status"></div>
    </div>

    <div v-else-if="error" class="alert alert-danger">
      {{ error }}
      <button class="btn btn-sm btn-outline-danger ml-2" @click="loadData">Reintentar</button>
    </div>

    <div v-else class="row">
      <div class="col-md-4 col-lg-3">
        <support-queue
          :tickets="tickets"
          :selected-id="selectedId"
          :current-username="me.username"
          @select="selectTicket"
        />
      </div>

      <div class="col-md-8 col-lg-9">
        <ticket-workspace
          v-if="selectedTicket"
          :key="selectedTicket.id"
          :ticket="selectedTicket"
          @updated="onTicketUpdated"
        />
        <div v-else class="text-center text-muted py-5">
          <p class="h4">👈 Selecciona un ticket de la cola</p>
          <p class="small">Los tickets nuevos aparecen resaltados en amarillo.</p>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";
import SupportQueue from "../components/support/SupportQueue.vue";
import TicketWorkspace from "../components/support/TicketWorkspace.vue";
import ticketService from "../services/ticketService";
import userService from "../services/userService";
import socketService from "../services/socketService";

export default {
  name: "SupportView",
  components: { PageTitle, SupportQueue, TicketWorkspace },
  data: function () {
    return {
      tickets: [],
      users: [],
      selectedId: null,
      loading: true,
      error: ""
    };
  },
  computed: {
    me: function () {
      return this.$store.getters["auth/currentUser"];
    },
    selectedTicket: function () {
      var self = this;
      return this.tickets.find(function (t) {
        return t.id === self.selectedId;
      }) || null;
    }
  },
  mounted: function () {
    this.loadData();
    this.onCreatedHandler = this.onTicketCreated.bind(this);
    socketService.on("ticket:created", this.onCreatedHandler);
    this.onUpdatedHandler = this.onTicketUpdated.bind(this);
    socketService.on("ticket:updated", this.onUpdatedHandler);
  },
  beforeDestroy: function () {
    socketService.off("ticket:created", this.onCreatedHandler);
    socketService.off("ticket:updated", this.onUpdatedHandler);
  },
  methods: {
    loadData: function () {
      var self = this;
      this.loading = true;
      this.error = "";

      Promise.all([
        ticketService.getTickets({ _sort: "createdAt", _order: "desc" }),
        userService.getUsers()
      ])
        .then(function (results) {
          self.tickets = results[0];
          self.users = results[1];
        })
        .catch(function () {
          self.error = "No se pudo cargar el panel. ¿Está corriendo la Mock API?";
        })
        .finally(function () {
          self.loading = false;
        });
    },
    selectTicket: function (ticket) {
      this.selectedId = ticket.id;
      ticket.isNew = false; // deja de brillar al abrirlo
    },
    onTicketUpdated: function (updated) {
      var index = this.tickets.findIndex(function (t) {
        return t.id === updated.id;
      });
      if (index !== -1) {
        this.tickets.splice(index, 1, updated); // splice: reactivo (F8) ✅
      }
    },
    onTicketCreated: function (ticket) {
      ticket.isNew = true; // ⚠️ ver nota abajo
      this.tickets.unshift(ticket);
    }
  }
};
</script>
