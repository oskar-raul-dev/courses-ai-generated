module.exports = {
  name: "App",
  data: function () {
    return {
      greeting: "Hola mundo legacy",
      name: "",
      response: "",
      submitted: false,
      loading: false
    };
  },
  computed: {
    // derivado del estado: se recalcula solo cuando cambia name
    isNameValid: function () {
      return this.name.length > 0;
    }
  },
  methods: {
    submit: function () {
      // guardamos this: dentro del .then, this ya no es el componente
      var self = this;
      this.submitted = true;

      if (!this.isNameValid) {
        return; // la clase is-invalid ya pinta el error sola
      }

      this.loading = true;
      this.response = "";

      axios
        .post("http://localhost:8888/api/hello", { name: this.name })
        .then(function (res) {
          self.response = res.data.message + " " + self.name;
        })
        .catch(function () {
          self.response = "";
          window.alert("¿Está corriendo el mock? (npm run mock)");
        })
        .finally(function () {
          self.loading = false;
        });
    }
  }
};
