import { mount, createLocalVue } from "@vue/test-utils";
import Vuelidate from "vuelidate";
import TicketForm from "@/components/tickets/TicketForm.vue";

const localVue = createLocalVue();
localVue.use(Vuelidate); // sin esto, $v es undefined y el render explota

function build(props) {
  return mount(TicketForm, {
    localVue: localVue,
    propsData: props || {}
  });
}

// El acto de "llenar el formulario", en un solo sitio.
// Cuando los campos sean QInput, se toca ESTO. Los tests no se enteran.
function fill(wrapper, values) {
  const p = [];
  if (values.title !== undefined)
    p.push(wrapper.find('[data-testid="ticket-title"]').setValue(values.title));
  if (values.description !== undefined)
    p.push(wrapper.find('[data-testid="ticket-description"]').setValue(values.description));
  if (values.priority !== undefined)
    p.push(wrapper.find('[data-testid="ticket-priority"]').setValue(values.priority));
  if (values.assignee !== undefined)
    p.push(wrapper.find('[data-testid="ticket-assignee"]').setValue(values.assignee));
  return Promise.all(p);
}

const VALIDO = {
  title: "Impresora no imprime",
  description: "La del piso 3 lleva dos días muerta",
  priority: "high",
  assignee: "lmcorrea"
};

describe("REGRESIÓN · TicketForm", function () {

  describe("el contrato de salida: qué emite y cuándo", function () {
    it("con datos válidos, el submit emite 'submit' con el payload limpio", function () {
      const wrapper = build();

      return fill(wrapper, VALIDO)
        .then(function () {
          return wrapper.find("form").trigger("submit");
        })
        .then(function () {
          expect(wrapper.emitted("submit")).toHaveLength(1);
          expect(wrapper.emitted("submit")[0][0]).toEqual(VALIDO);
        });
    });

    it("con datos INVÁLIDOS, el submit NO emite nada", function () {
      const wrapper = build();

      // esta es la aserción más importante del archivo:
      // el formulario es la última barrera antes del POST.
      return wrapper.find("form").trigger("submit").then(function () {
        expect(wrapper.emitted("submit")).toBeUndefined();
      });
    });

    it("el payload NO incluye status ni reporter ni createdAt (los pone la vista)", function () {
      const wrapper = build();

      return fill(wrapper, VALIDO)
        .then(function () { return wrapper.find("form").trigger("submit"); })
        .then(function () {
          const payload = wrapper.emitted("submit")[0][0];
          expect(payload.status).toBeUndefined();
          expect(payload.reporter).toBeUndefined();
          expect(payload.createdAt).toBeUndefined();
        });
    });

    it("el botón de cancelar emite 'cancel', sin payload", function () {
      const wrapper = build();

      wrapper.find('[data-testid="ticket-cancel"]').trigger("click");

      expect(wrapper.emitted("cancel")).toHaveLength(1);
    });
  });

  describe("las reglas de validación, una por una", function () {
    // Se afirma "no emite" — NO se afirma la clase .is-invalid ni el texto
    // del mensaje. La regla es comportamiento; el mensaje es copy.
    function rechaza(valores) {
      const wrapper = build();
      return fill(wrapper, Object.assign({}, VALIDO, valores))
        .then(function () { return wrapper.find("form").trigger("submit"); })
        .then(function () {
          expect(wrapper.emitted("submit")).toBeUndefined();
        });
    }

    it("título vacío: rechaza", function () { return rechaza({ title: "" }); });
    it("título de 4 caracteres: rechaza (mínimo 5)", function () { return rechaza({ title: "abcd" }); });
    it("título de 81 caracteres: rechaza (máximo 80)", function () {
      return rechaza({ title: "x".repeat(81) });
    });
    it("descripción de 9 caracteres: rechaza (mínimo 10)", function () {
      return rechaza({ description: "123456789" });
    });
    it("prioridad vacía: rechaza", function () { return rechaza({ priority: "" }); });

    it("asignado vacío: ACEPTA (es opcional — congela esta decisión)", function () {
      const wrapper = build();
      return fill(wrapper, Object.assign({}, VALIDO, { assignee: "" }))
        .then(function () { return wrapper.find("form").trigger("submit"); })
        .then(function () {
          expect(wrapper.emitted("submit")).toHaveLength(1);
        });
    });

    it("el título de exactamente 80 caracteres: ACEPTA (el borde exacto)", function () {
      const wrapper = build();
      return fill(wrapper, Object.assign({}, VALIDO, { title: "x".repeat(80) }))
        .then(function () { return wrapper.find("form").trigger("submit"); })
        .then(function () {
          expect(wrapper.emitted("submit")).toHaveLength(1);
        });
    });
  });

  describe("el feedback de error es visible para el usuario", function () {
    it("tras un submit inválido, aparece el error del título", function () {
      const wrapper = build();

      return wrapper.find("form").trigger("submit").then(function () {
        // se afirma que EXISTE un mensaje de error anclado al campo.
        // NO se afirma su texto exacto (eso es copy) ni su clase (eso es Bootstrap).
        expect(wrapper.find('[data-testid="ticket-title-error"]').exists()).toBe(true);
      });
    });

    it("antes de tocar nada, NO hay errores visibles (el patrón $error de F5)", function () {
      const wrapper = build();

      expect(wrapper.find('[data-testid="ticket-title-error"]').exists()).toBe(false);
    });
  });

  describe("modo edición: el patrón prop → copia local", function () {
    it("con initialTicket, precarga los campos", function () {
      const wrapper = build({
        initialTicket: {
          id: 7, title: "VPN caída", description: "No conecta desde casa",
          priority: "high", assignee: "agente2", status: "open"
        }
      });

      expect(wrapper.find('[data-testid="ticket-title"]').element.value).toBe("VPN caída");
      expect(wrapper.find('[data-testid="ticket-priority"]').element.value).toBe("high");
    });

    it("editar NO muta la prop (el pecado capital de F4)", function () {
      const original = {
        id: 7, title: "VPN caída", description: "No conecta desde casa",
        priority: "high", assignee: "agente2", status: "open"
      };
      const wrapper = build({ initialTicket: original });

      return wrapper.find('[data-testid="ticket-title"]').setValue("VPN caída otra vez")
        .then(function () {
          expect(original.title).toBe("VPN caída"); // el objeto del padre, intacto
        });
    });

    it("el payload de edición conserva los campos que el form no gestiona", function () {
      const wrapper = build({
        initialTicket: {
          id: 7, title: "VPN caída", description: "No conecta desde casa",
          priority: "high", assignee: "agente2", status: "open"
        }
      });

      return wrapper.find("form").trigger("submit").then(function () {
        const payload = wrapper.emitted("submit")[0][0];
        // ⚠️ COMPORTAMIENTO ACTUAL, no necesariamente el deseado:
        // el Object.assign de created() arrastra id y status al form,
        // y el submit los devuelve. El PATCH los reenvía tal cual.
        // ¿Está bien? Discutible. ¿Es lo que pasa hoy? Sí.
        // → SE CONGELA. Si al migrar cambia, quiero enterarme.
        expect(payload.id).toBe(7);
        expect(payload.status).toBe("open");
      });
    });
  });

  describe("estado de guardado", function () {
    it("con saving=true el botón se deshabilita (anti doble submit de F5)", function () {
      const wrapper = build({ saving: true });
      const boton = wrapper.find('[data-testid="ticket-submit"]');

      expect(boton.attributes("disabled")).toBeDefined();
    });

    it("submitLabel se respeta", function () {
      const wrapper = build({ submitLabel: "Crear ticket" });

      expect(wrapper.find('[data-testid="ticket-submit"]').text()).toContain("Crear ticket");
    });
  });
});
