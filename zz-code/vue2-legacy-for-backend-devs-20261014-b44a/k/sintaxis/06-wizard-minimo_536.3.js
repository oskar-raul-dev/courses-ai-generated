var __a = [
module.exports = {
  name: "TicketWizardView",
  components: { PageTitle, WizardProgress, StepData, StepClassification, StepConfirmation },
  data: function () {
    return {
      currentStep: 1,
      stepDefs: [
        { number: 1, label: "Datos", component: StepData },
        { number: 2, label: "Clasificación", component: StepClassification },
        { number: 3, label: "Confirmación", component: StepConfirmation }
      ],
      // ÚNICA fuente de verdad del borrador
      draft: {
        title: "",
        description: "",
        priority: "",
        assignee: ""
      },
      saving: false,
      error: "",
      created: false // para no molestar con el confirm tras crear
    };
  },
  computed: {
    currentStepComponent: function () {
      return this.stepDefs[this.currentStep - 1].component;
    },
    hasChanges: function () {
      return !!(this.draft.title || this.draft.description ||
                this.draft.priority || this.draft.assignee);
    }
  },
  watch: {
    currentStep: function () {
      window.scrollTo(0, 0);
    }
  },
  beforeRouteLeave: function (to, from, next) {
    if (this.created || !this.hasChanges) {
      next();
      return;
    }
    var ok = window.confirm("Tienes un ticket a medias. ¿Salir y perder el borrador?");
    next(ok);
  },
  methods: {
    mergeCurrentStep: function () {
      var step = this.$refs.stepComponent;
      if (step && step.getData) {
        this.draft = Object.assign({}, this.draft, step.getData());
      }
    },
    next: function () {
      var step = this.$refs.stepComponent;
      if (step && step.validate && !step.validate()) {
        return; // el paso pinta sus propios errores
      }
      this.mergeCurrentStep();
      this.currentStep++;
    },
    back: function () {
      this.mergeCurrentStep(); // no perder lo escrito aunque esté inválido
      this.currentStep--;
    },
    finish: function () {
      var self = this;
      this.saving = true;
      this.error = "";

      var payload = Object.assign({}, this.draft, {
        status: "open",
        reporter: this.$store.getters["auth/currentUser"].username,
        createdAt: new Date().toISOString()
      });

      ticketService
        .createTicket(payload)
        .then(function (created) {
          self.created = true;
          self.$router.push("/tickets/" + created.id + "?created=1");
        })
        .catch(function () {
          self.error = "No se pudo crear el ticket. Tu borrador sigue aquí.";
        })
        .finally(function () {
          self.saving = false;
        });
    }
  }
};

];