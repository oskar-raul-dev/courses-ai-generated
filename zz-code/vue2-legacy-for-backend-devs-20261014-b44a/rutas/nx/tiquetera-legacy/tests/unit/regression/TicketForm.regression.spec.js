import { mount, createLocalVue } from "@vue/test-utils";
import Vuelidate from "vuelidate";
import TicketForm from "@/components/tickets/TicketForm.vue";

var localVue = createLocalVue();
localVue.use(Vuelidate); // vuelidate se registró global en F5

describe("REGRESIÓN · TicketForm (F5)", function () {
  function build(initial) {
    return mount(TicketForm, {
      localVue: localVue,
      propsData: { initialTicket: initial || null }
    });
  }

  it("con datos válidos, emite 'submit' con el ticket limpio", function () {
    var wrapper = build();

    wrapper.find('[data-testid="form-title"]').setValue("Bug en el filtro");
    wrapper.find('[data-testid="form-description"]').setValue("No filtra por estado");
    wrapper.find('[data-testid="form-priority"]').setValue("high"); // obligatoria desde F5

    return wrapper.find('[data-testid="form-submit"]').trigger("submit").then(function () {
      // Contrato con la vista padre: nombre del evento + forma del payload.
      expect(wrapper.emitted("submit")).toHaveLength(1);
      expect(wrapper.emitted("submit")[0][0]).toMatchObject({
        title: "Bug en el filtro",
        description: "No filtra por estado"
      });
    });
  });

  it("sin título, NO emite 'submit' y muestra el error", function () {
    var wrapper = build();

    return wrapper.find('[data-testid="form-submit"]').trigger("submit").then(function () {
      // El negativo es tan contrato como el positivo: submit inválido no propaga.
      expect(wrapper.emitted("submit")).toBeUndefined();
      // El usuario VE un error (texto observable, no clase de vuelidate), tras el repintado.
      expect(wrapper.text()).toContain("El título es obligatorio");
    });
  });

  it("en modo edición, precarga los datos del ticket inicial", function () {
    var wrapper = build({ id: 7, title: "Existente", description: "ya estaba" });

    // Comportamiento: el campo llega con el valor. Cómo lo clona por dentro
    // (created vs mounted) es implementación —no lo tocamos.
    expect(wrapper.find('[data-testid="form-title"]').element.value).toBe("Existente");
  });
});
