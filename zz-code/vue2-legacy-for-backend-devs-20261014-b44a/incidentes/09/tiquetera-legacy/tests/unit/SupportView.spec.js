// tests/unit/SupportView.spec.js
import { shallowMount } from "@vue/test-utils";
import SupportView from "@/views/SupportView.vue";
import ticketService from "@/services/ticketService";
import userService from "@/services/userService";

jest.mock("@/services/ticketService");
jest.mock("@/services/userService");
jest.mock("@/services/socketService");

describe("SupportView", function () {
  it("el detalle refleja el ticket actualizado sin cambiar de selección", function () {
    // la carga no termina: el test pone la lista a mano
    ticketService.getTickets.mockReturnValue(new Promise(function () {}));
    userService.getUsers.mockReturnValue(new Promise(function () {}));
    var wrapper = shallowMount(SupportView, {
      mocks: { $store: { getters: { "auth/currentUser": { username: "lmcano", role: "agent" } } } }
    });

    var ticket = { id: 12, status: "open", assignee: null };
    wrapper.setData({ tickets: [ticket] });
    wrapper.vm.selectTicket(ticket); // por la acción, no por el estado: vale para las dos versiones

    wrapper.vm.onTicketUpdated({ id: 12, status: "in_progress", assignee: "lmcano" });

    expect(wrapper.vm.selectedTicket.status).toBe("in_progress");
    expect(wrapper.vm.selectedTicket.assignee).toBe("lmcano");
  });
});
