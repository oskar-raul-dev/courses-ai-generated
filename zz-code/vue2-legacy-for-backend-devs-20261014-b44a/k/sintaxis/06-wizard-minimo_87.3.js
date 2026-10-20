var __a = [
computed: {
  currentStepComponent: function () {
    // puede devolver el nombre registrado o el objeto componente importado
    return this.steps[this.currentStep - 1].component;
  }
}
];