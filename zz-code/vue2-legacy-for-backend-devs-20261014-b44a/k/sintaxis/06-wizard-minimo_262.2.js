var __o = {
module.exports = {
  name: "StepData",
  props: {
    draft: { type: Object, required: true }
  },
  data: function () {
    return {
      form: {
        title: this.draft.title,
        description: this.draft.description
      }
    };
  },
  validations: {
    form: {
      title: { required: required, minLength: minLength(5), maxLength: maxLength(80) },
      description: { required: required, minLength: minLength(10) }
    }
  },
  methods: {
    // API pública del paso: el wizard la invoca por $refs
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