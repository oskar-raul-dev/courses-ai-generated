var __a = [


// Validador custom: valor dentro de una lista permitida.
function oneOf(values) {
  return function (value) {
    return values.indexOf(value) !== -1;
  };
}
module.exports = {
  name: "TicketForm",
  props: {
    // vacío para crear, con datos para editar
    initialTicket: { type: Object, default: null },
    saving: { type: Boolean, default: false },
    submitLabel: { type: String, default: "Guardar" }
  },
  data: function () {
    return {
      // copia local: NUNCA editamos la prop directamente
      form: {
        title: "",
        description: "",
        priority: "",
        assignee: ""
      }
    };
  },
  validations: {
    form: {
      title: { required: required, minLength: minLength(5), maxLength: maxLength(80) },
      description: { required: required, minLength: minLength(10) },
      priority: { required: required, oneOf: oneOf(["low", "medium", "high"]) }
    }
  },
  created: function () {
    if (this.initialTicket) {
      // clonado superficial suficiente para un objeto plano
      this.form = Object.assign({}, this.form, this.initialTicket);
    }
  },
  methods: {
    handleSubmit: function () {
      this.$v.$touch();
      if (this.$v.$invalid) {
        return; // los errores ya se pintan solos vía $error
      }
      this.$emit("submit", Object.assign({}, this.form));
    }
  }
};

];