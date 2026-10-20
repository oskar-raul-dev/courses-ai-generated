function __f(){
module.exports = {
  name: "StatusActions",
  props: {
    status: { type: String, required: true },
    busy: { type: Boolean, default: false }
  },
  computed: {
    available: function () {
      return nextStatuses(this.status);
    }
  },
  methods: {
    labelFor: function (status) {
      return TRANSITION_LABELS[status] || { label: status, css: "btn-light" };
    }
  }
};

}