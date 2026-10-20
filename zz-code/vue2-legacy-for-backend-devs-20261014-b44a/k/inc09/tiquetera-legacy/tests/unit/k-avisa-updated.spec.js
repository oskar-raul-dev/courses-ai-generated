// prueba de K3 (no publicada): el parche del incidente 09 anuncia y escucha ticket:updated
import { shallowMount } from "@vue/test-utils";
import TicketWorkspace from "@/components/support/TicketWorkspace.vue";
import SupportView from "@/views/SupportView.vue";
import ticketService from "@/services/ticketService";
import userService from "@/services/userService";
import commentService from "@/services/commentService";
import socketService from "@/services/socketService";
jest.mock("@/services/ticketService");
jest.mock("@/services/userService");
jest.mock("@/services/commentService");
jest.mock("@/services/socketService");
var store = { getters: { "auth/currentUser": { username: "lmcano", role: "agent" } } };
describe("incidente 09, parche", function () {
  it("tomar anuncia ticket:updated", function () {
    commentService.getByTicket.mockReturnValue(new Promise(function () {}));
    var updated = { id: 12, status: "in_progress", assignee: "lmcano" };
    ticketService.updateTicket.mockResolvedValue(updated);
    var w = shallowMount(TicketWorkspace, { propsData: { ticket: { id: 12, status: "open", assignee: null }, users: [] }, mocks: { $store: store } });
    w.vm.takeTicket();
    return new Promise(function (r) { setTimeout(r, 0); }).then(function () {
      expect(socketService.emit).toHaveBeenCalledWith("ticket:updated", updated);
    });
  });
  it("la vista escucha ticket:updated y lo suelta al destruirse", function () {
    ticketService.getTickets.mockReturnValue(new Promise(function () {}));
    userService.getUsers.mockReturnValue(new Promise(function () {}));
    var w = shallowMount(SupportView, { mocks: { $store: store } });
    var call = socketService.on.mock.calls.filter(function (c) { return c[0] === "ticket:updated"; })[0];
    w.setData({ tickets: [{ id: 12, status: "open", assignee: null }] });
    call[1]({ id: 12, status: "in_progress", assignee: "ana" });
    expect(w.vm.tickets[0].assignee).toBe("ana");
    w.destroy();
    expect(socketService.off).toHaveBeenCalledWith("ticket:updated", call[1]);
  });
});
