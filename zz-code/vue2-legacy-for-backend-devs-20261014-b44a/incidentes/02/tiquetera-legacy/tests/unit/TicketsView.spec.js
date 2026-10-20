// tests/unit/TicketsView.spec.js
import { shallowMount } from "@vue/test-utils";
import TicketsView from "@/views/TicketsView.vue";
import ticketService from "@/services/ticketService";

jest.mock("@/services/ticketService");

describe("TicketsView", function () {
  it("distingue lista vacía de fallo de carga", function () {
    // la carga no termina nunca: el test pone el estado a mano con setData
    ticketService.getTickets.mockReturnValue(new Promise(function () {}));
    var wrapper = shallowMount(TicketsView, { stubs: ["router-link"] });

    wrapper.setData({ loading: false, loaded: true, tickets: [] });
    return wrapper.vm.$nextTick()
      .then(function () {
        expect(wrapper.text()).toContain("No hay tickets");
        wrapper.setData({ loading: false, loaded: false, error: "No se pudieron cargar los tickets." });
        return wrapper.vm.$nextTick();
      })
      .then(function () {
        expect(wrapper.text()).not.toContain("No hay tickets");
      });
  });
});
