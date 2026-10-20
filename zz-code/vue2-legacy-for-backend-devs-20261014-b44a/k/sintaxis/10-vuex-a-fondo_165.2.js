var __o = {
computed: {
  search: {
    get: function () { return this.$store.state.ui.search; },
    set: function (value) { this.$store.commit("ui/SET_SEARCH", value); }
  }
}
};