var __o = {
mounted: function () {
  // propiedad de instancia creada FUERA de data → Vue no la observa
  this.chart = new Chart(this.$refs.canvas, this.buildConfig());
}
};