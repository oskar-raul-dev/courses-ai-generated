// mixins/chartLifecycle.js
export default {
  mounted: function () { this.chart = this.createChart(); },
  beforeDestroy: function () { if (this.chart) { this.chart.destroy(); this.chart = null; } },
  watch: {
    chartData: {
      deep: true,
      handler: function () {
        if (!this.chart) { return; }
        this.chart.data = this.buildData();
        this.chart.update();          // update, no recrear
      }
    }
  }
};
