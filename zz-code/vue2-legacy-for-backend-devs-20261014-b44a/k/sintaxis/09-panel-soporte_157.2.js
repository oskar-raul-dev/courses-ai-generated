var __o = {
module.exports = {
  props: { value: { type: String, default: "" } },
  methods: {
    onInput: function (e) {
      this.$emit("input", e.target.value); // el padre actualiza; la prop vuelve
    }
  }
};
};