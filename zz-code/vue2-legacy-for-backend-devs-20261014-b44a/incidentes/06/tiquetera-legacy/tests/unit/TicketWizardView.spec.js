// tests/unit/TicketWizardView.spec.js
import { mount, createLocalVue } from "@vue/test-utils";
import Vuelidate from "vuelidate";
import TicketWizardView from "@/views/TicketWizardView.vue";

// mount y no shallowMount: con <keep-alive><component :is>, el shallowMount de
// esta versión de test-utils entra en un bucle y Jest se queda sin memoria
var localVue = createLocalVue();
localVue.use(Vuelidate);

function montar() {
  return mount(TicketWizardView, { localVue: localVue, stubs: ["router-link"] });
}

describe("TicketWizardView", function () {
  it("no avanza si el paso actual es inválido", function () {
    var wrapper = montar();
    wrapper.vm.$refs.stepComponent = {
      validate: function () { return false; },
      getData: function () { return {}; }
    };
    wrapper.vm.next();
    expect(wrapper.vm.currentStep).toBe(1);
  });

  it("al volver atrás encuentra el mismo paso, no uno nuevo (keep-alive)", function () {
    var wrapper = montar();
    var first = wrapper.vm.$refs.stepComponent;
    first.validate = function () { return true; };   // el paso 1 vacío no pasaría su validación
    wrapper.vm.next();
    return wrapper.vm.$nextTick()
      .then(function () {
        wrapper.vm.back();
        return wrapper.vm.$nextTick();
      })
      .then(function () {
        // booleano a propósito: si toBe falla entre dos instancias de Vue, Jest intenta
        // imprimir la diferencia de dos objetos enormes y circulares y se queda sin memoria
        expect(wrapper.vm.$refs.stepComponent === first).toBe(true);
      });
  });
});
