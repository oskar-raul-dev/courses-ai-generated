var __o = {
watch: {
  chartData: {
    deep: true,          // observa mutaciones internas, no solo reemplazo
    handler: function () {
      this.refreshChart();
    }
  }
}
};