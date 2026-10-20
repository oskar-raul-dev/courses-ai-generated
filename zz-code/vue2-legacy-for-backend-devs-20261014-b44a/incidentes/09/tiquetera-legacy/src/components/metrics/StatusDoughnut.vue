<template>
  <div class="card h-100">
    <div class="card-body">
      <h6 class="card-title text-muted">Tickets por estado</h6>
      <canvas ref="canvas"></canvas>
    </div>
  </div>
</template>

<script>
import Chart from "chart.js";
import { STATUS_COLORS } from "../../utils/statusColors";

export default {
  name: "StatusDoughnut",
  props: {
    // { open: 5, in_progress: 3, ... }
    counts: { type: Object, required: true }
  },
  // 👀 nota lo que NO hay: data(). Este componente no tiene estado reactivo.
  mounted: function () {
    // this.chart fuera de data: propiedad NO reactiva a propósito
    this.chart = new Chart(this.$refs.canvas, {
      type: "doughnut",
      data: this.buildData(),
      options: {
        responsive: true,
        legend: { position: "bottom" },
        // sintaxis v2: en v3 esto cambió por completo
        cutoutPercentage: 65
      }
    });
  },
  beforeDestroy: function () {
    // el tablón que el legacy olvida
    if (this.chart) {
      this.chart.destroy();
      this.chart = null;
    }
  },
  watch: {
    counts: {
      deep: true,
      handler: function () {
        if (!this.chart) return;
        this.chart.data = this.buildData();
        this.chart.update(); // actualizar, NO recrear
      }
    }
  },
  methods: {
    buildData: function () {
      var self = this;
      var keys = Object.keys(STATUS_COLORS);
      return {
        labels: keys.map(function (k) { return STATUS_COLORS[k].label; }),
        datasets: [{
          data: keys.map(function (k) { return self.counts[k] || 0; }),
          backgroundColor: keys.map(function (k) { return STATUS_COLORS[k].color; })
        }]
      };
    }
  }
};
</script>
