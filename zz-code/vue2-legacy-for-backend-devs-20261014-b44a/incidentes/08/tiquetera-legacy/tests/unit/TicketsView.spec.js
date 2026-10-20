// tests/unit/TicketsView.spec.js
import { shallowMount } from "@vue/test-utils";
import TicketsView from "@/views/TicketsView.vue";
import ticketService from "@/services/ticketService";
import socketService from "@/services/socketService";

jest.mock("@/services/ticketService");
jest.mock("@/services/socketService");

function montar() {
  ticketService.getTickets.mockReturnValue(new Promise(function () {})); // la carga no importa aquí
  return shallowMount(TicketsView, { stubs: ["router-link"] });
}

describe("TicketsView y el socket", function () {
  it("da de baja el handler al desmontarse", function () {
    var wrapper = montar();
    var handler = wrapper.vm.onCreatedHandler;
    wrapper.destroy();
    expect(socketService.off).toHaveBeenCalledWith("ticket:created", handler);
  });

  it("no duplica un ticket que ya está en la lista", function () {
    var wrapper = montar();
    wrapper.setData({ tickets: [{ id: 7, title: "X" }] });
    wrapper.vm.onTicketCreated({ id: 7, title: "X" });
    expect(wrapper.vm.tickets).toHaveLength(1);
  });
});
