<template>
  <div class="card h-100">
    <div class="card-body">
      <h6 class="card-title text-muted">Carga activa por agente</h6>
      <canvas ref="canvas"></canvas>
    </div>
  </div>
</template>

<script>
import Chart from "chart.js";

export default {
  name: "AgentBarChart",
  props: {
    // [{ agent, count }] ya ordenado
    rows: { type: Array, required: true }
  },
  mounted: function () {
    this.chart = new Chart(this.$refs.canvas, {
      type: "horizontalBar", // ⚰️ tipo propio de v2; en v3 es bar + indexAxis
      data: this.buildData(),
      options: {
        responsive: true,
        legend: { display: false },
        scales: {
          xAxes: [{ ticks: { beginAtZero: true, stepSize: 1 } }] // sintaxis v2
        }
      }
    });
  },
  beforeDestroy: function () {
    if (this.chart) {
      this.chart.destroy();
      this.chart = null;
    }
  },
  watch: {
    rows: function () {
      if (!this.chart) return;
      this.chart.data = this.buildData();
      this.chart.update();
    }
  },
  methods: {
    buildData: function () {
      return {
        labels: this.rows.map(function (r) { return r.agent; }),
        datasets: [{
          data: this.rows.map(function (r) { return r.count; }),
          backgroundColor: "#007bff"
        }]
      };
    }
  }
};
</script>
