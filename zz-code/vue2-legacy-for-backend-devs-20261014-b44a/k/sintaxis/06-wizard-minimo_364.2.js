var __o = {


function oneOf(values) {
  return function (value) {
    return values.indexOf(value) !== -1;
  };
}
module.exports = {
  name: "StepClassification",
  props: {
    draft: { type: Object, required: true }
  },
  data: function () {
    return {
      form: {
        priority: this.draft.priority,
        assignee: this.draft.assignee
      }
    };
  },
  validations: {
    form: {
      priority: { required: required, oneOf: oneOf(["low", "medium", "high"]) }
    }
  },
  methods: {
    validate: function () {
      this.$v.$touch();
      return !this.$v.$invalid;
    },
    getData: function () {
      return Object.assign({}, this.form);
    }
  }
};

};