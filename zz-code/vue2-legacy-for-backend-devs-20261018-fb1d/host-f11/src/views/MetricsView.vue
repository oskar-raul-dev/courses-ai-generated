<template>
  <section>
    <page-title title="Métricas" subtitle="Estado de la mesa de soporte" />

    <div v-if="loading" class="text-center my-5">
      <div class="spinner-border text-primary" role="status"></div>
    </div>

    <div v-else-if="error" class="alert alert-danger">
      {{ error }}
      <button class="btn btn-sm btn-outline-danger ml-2" @click="loadTickets">
        Reintentar
      </button>
    </div>

    <template v-else>
      <div class="row mb-4">
        <div class="col-6 col-md-3 mb-2">
          <metric-card label="Total tickets" :value="tickets.length" />
        </div>
        <div class="col-6 col-md-3 mb-2">
          <metric-card label="Abiertos" :value="statusCounts.open || 0" value-class="text-danger" />
        </div>
        <div class="col-6 col-md-3 mb-2">
          <metric-card label="% resueltos" :value="donePercent + '%'" value-class="text-success" />
        </div>
        <div class="col-6 col-md-3 mb-2">
          <metric-card label="Sin asignar" :value="unassignedCount" value-class="text-warning" />
        </div>
      </div>

      <div class="row">
        <div class="col-md-5 mb-3">
          <status-doughnut :counts="statusCounts" />
        </div>
        <div class="col-md-7 mb-3">
          <agent-bar-chart :rows="agentRows" />
        </div>
      </div>

      <div class="row">
        <div class="col-md-5 mb-3">
          <score-board :rows="scoreRows" />
        </div>
      </div>

      <p class="text-muted small text-right">
        Datos al {{ new Date() | formatDate }} ·
        <a href="#" @click.prevent="loadTickets">actualizar</a>
      </p>
    </template>
  </section>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";
import MetricCard from "../components/metrics/MetricCard.vue";
import StatusDoughnut from "../components/metrics/StatusDoughnut.vue";
import AgentBarChart from "../components/metrics/AgentBarChart.vue";
import ScoreBoard from "../components/metrics/ScoreBoard.vue";
import apiClient from "../services/apiClient";
import ticketService from "../services/ticketService";
import { countByStatus, activeByAgent, resolvedPercent, scoreBoard } from "../utils/ticketStats";

export default {
  name: "MetricsView",
  components: { PageTitle, MetricCard, StatusDoughnut, AgentBarChart, ScoreBoard },
  data: function () {
    return {
      tickets: [],
      users: [],     // solo para las iniciales de la tabla de puntajes
      loading: true, // arranca en true: adiós al parpadeo de la Fase 4
      error: ""
    };
  },
  computed: {
    // envolturas de una línea sobre las funciones puras
    statusCounts: function () { return countByStatus(this.tickets); },
    agentRows: function () { return activeByAgent(this.tickets); },
    donePercent: function () { return resolvedPercent(this.tickets); },
    scoreRows: function () { return scoreBoard(this.tickets, this.users); },
    unassignedCount: function () {
      return this.tickets.filter(function (t) {
        return !t.assignee && t.status !== "closed";
      }).length;
    }
  },
  mounted: function () {
    this.loadTickets();
  },
  methods: {
    loadTickets: function () {
      var self = this;
      this.loading = true;
      this.error = "";

      // 💸 DEUDA: /users va directo por apiClient; userService llega en la Fase 9
      apiClient
        .get("/users")
        .then(function (res) {
          self.users = res.data;
          return ticketService.getTickets();
        })
        .then(function (tickets) {
          self.tickets = tickets;
        })
        .catch(function () {
          self.error = "No se pudieron cargar las métricas. ¿Está corriendo la Mock API?";
        })
        .finally(function () {
          self.loading = false;
        });
    }
  }
};
</script>
