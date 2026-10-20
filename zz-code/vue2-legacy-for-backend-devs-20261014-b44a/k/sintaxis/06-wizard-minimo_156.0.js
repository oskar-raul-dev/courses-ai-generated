watch: {
  currentStep: function (newVal, oldVal) {
    // efecto secundario al cambiar de paso: scroll arriba
    window.scrollTo(0, 0);
  }
}