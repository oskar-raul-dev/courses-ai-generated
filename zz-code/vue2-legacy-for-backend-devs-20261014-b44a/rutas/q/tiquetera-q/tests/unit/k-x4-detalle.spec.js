// K5 (no publicada): el detalle monta el timeline y la action registra actividad sin romper
import { shallowMount } from "@vue/test-utils";
import TicketDetailView from "@/views/TicketDetailView.vue";
import ticketService from "@/services/ticketService";
import activityEmitter from "@/services/activityEmitter";
import tickets from "@/store/modules/tickets";
jest.mock("@/services/ticketService");
describe("integración X4", function () {
  it("el detalle pinta <ticket-activity> con el id del ticket", function () {
    ticketService.getTicketById.mockResolvedValue({ id: 7, title: "Impresora", status: "open" });
    var w = shallowMount(TicketDetailView, { mocks: { $route: { params: { id: "7" } } }, stubs: ["router-link", "page-title"] });
    return new Promise(function (r) { setTimeout(r, 0); }).then(function () {
      var a = w.find("ticket-activity-stub");
      expect(a.exists()).toBe(true);
      expect(a.attributes("ticketid")).toBe("7");
    });
  });
  it("updateTicket registra dos eventos por PATCH y no revienta si el ticket no estaba en el store", function () {
    ticketService.updateTicket.mockResolvedValue({ id: 7, status: "in_progress", assignee: "lmcano" });
    var record = jest.spyOn(activityEmitter, "record").mockReturnValue(Promise.resolve());
    var commit = jest.fn();
    var context = { commit: commit, getters: { ticketById: function () { return undefined; } }, rootGetters: { "auth/currentUser": { username: "lmcano" } } };
    return tickets.actions.updateTicket(context, { id: 7, changes: { status: "in_progress", assignee: "lmcano" } }).then(function (u) {
      expect(u.id).toBe(7);
      expect(record).toHaveBeenCalledTimes(2);
      expect(record.mock.calls[0][0]).toEqual(expect.objectContaining({ type: "status_change", from: undefined, to: "in_progress" }));
    });
  });
});
