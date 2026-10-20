var __o = {
module.exports = {
  name: "WizardProgress",
  props: {
    steps: { type: Array, required: true },   // [{ number, label }]
    current: { type: Number, required: true }
  },
  methods: {
    circleClass: function (number) {
      if (number < this.current) return "bg-success text-white";
      if (number === this.current) return "bg-primary text-white";
      return "bg-light border text-muted";
    }
  }
};

};