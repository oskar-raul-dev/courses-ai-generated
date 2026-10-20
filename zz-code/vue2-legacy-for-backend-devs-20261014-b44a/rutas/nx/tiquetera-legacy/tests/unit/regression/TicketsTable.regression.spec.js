import { shallowMount } from "@vue/test-utils";
import TicketsTable from "@/components/tickets/TicketsTable.vue";

// Stub del badge hijo: no es el objeto de este test, y shallowMount ya lo
// reemplazaría; lo dejamos explícito para documentar la frontera.
describe("REGRESIÓN · TicketsTable (F4)", function () {
  var tickets = [
    { id: 1, title: "No arranca el server", status: "open" },
    { id: 2, title: "Error 500 en login", status: "resolved" }
  ];

  function build() {
    return shallowMount(TicketsTable, { propsData: { tickets: tickets } });
  }

  it("pinta una fila por ticket recibido", function () {
    var wrapper = build();

    // NO contamos <tr> por su tag ni por clase de Bootstrap: contamos anclas.
    expect(wrapper.findAll('[data-testid^="ticket-row-"]')).toHaveLength(2);
  });

  it("muestra el título de cada ticket (comportamiento observable)", function () {
    var wrapper = build();

    // El usuario ve el título. Cómo esté maquetado no importa.
    expect(wrapper.text()).toContain("No arranca el server");
    expect(wrapper.text()).toContain("Error 500 en login");
  });

  it("al hacer clic en una fila emite 'select' con el ticket completo", function () {
    var wrapper = build();

    wrapper.find('[data-testid="ticket-row-2"]').trigger("click");

    // El CONTRATO con el padre: nombre del evento + payload. Esto no cambia
    // aunque la fila se convierta en <QTr> o en lo que sea.
    expect(wrapper.emitted("select")).toHaveLength(1);
    expect(wrapper.emitted("select")[0]).toEqual([tickets[1]]);
  });
});
