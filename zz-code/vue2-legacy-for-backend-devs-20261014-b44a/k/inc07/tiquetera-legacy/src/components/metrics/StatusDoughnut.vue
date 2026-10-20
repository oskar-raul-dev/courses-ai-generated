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
import chartLifecycle from "../../mixins/chartLifecycle";

export default {
  name: "StatusDoughnut",
  props: {
    // { open: 5, in_progress: 3, ... }
    counts: { type: Object, required: true }
  },
  mixins: [chartLifecycle],
  computed: {
    chartData: function () { return this.counts; } // lo que vigila el watch del mixin
  },
  methods: {
    createChart: function () {
      return new Chart(this.$refs.canvas, {
        type: "doughnut",
        data: this.buildData(),
        options: { responsive: true, legend: { position: "bottom" }, cutoutPercentage: 65 }
      });
    },
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
