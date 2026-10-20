var __o = {
module.exports = {
  data: function () {
    return {
      form: { title: "", description: "" }
    };
  },
  validations: {
    form: {
      title: { required: required, minLength: minLength(5), maxLength: maxLength(80) },
      description: { required: required, minLength: minLength(10) }
    }
  }
};
};