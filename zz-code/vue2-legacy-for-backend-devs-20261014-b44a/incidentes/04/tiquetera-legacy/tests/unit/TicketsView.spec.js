// tests/unit/TicketsView.spec.js
import { shallowMount } from "@vue/test-utils";
import TicketsView from "@/views/TicketsView.vue";
import ticketService from "@/services/ticketService";

jest.mock("@/services/ticketService");

// ocho tickets, tres abiertos
var mixed = ["open", "open", "open", "in_progress", "in_progress", "resolved", "resolved", "closed"]
  .map(function (status, i) {
    return { id: i + 1, title: "Ticket " + (i + 1), status: status };
  });

describe("TicketsView", function () {
  it("refleja el filtro de estado sin necesidad de tocar la búsqueda", function () {
    ticketService.getTickets.mockReturnValue(new Promise(function () {})); // la carga real no importa aquí
    var wrapper = shallowMount(TicketsView, { stubs: ["router-link"] });

    wrapper.setData({ tickets: mixed, search: "", statusFilter: "" });
    expect(wrapper.vm.filteredTickets).toHaveLength(8);

    wrapper.setData({ statusFilter: "open" });
    expect(wrapper.vm.filteredTickets).toHaveLength(3);
  });
});
