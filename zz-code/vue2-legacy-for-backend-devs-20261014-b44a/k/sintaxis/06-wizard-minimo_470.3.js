var __a = [
module.exports = {
  name: "StepConfirmation",
  components: { TicketPriorityBadge },
  props: {
    draft: { type: Object, required: true }
  },
  computed: {
    reporterName: function () {
      var user = this.$store.getters["auth/currentUser"];
      return user ? user.name : "";
    }
  }
};

];