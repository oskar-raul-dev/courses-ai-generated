import ticketService from "@/services/ticketService";
import apiClient from "@/services/apiClient";

jest.mock("@/services/apiClient"); // el cable a axios, cortado

describe("ticketService", function () {
  beforeEach(function () {
    jest.clearAllMocks();
  });

  it("getTickets pide /tickets con los params y devuelve res.data", function () {
    apiClient.get.mockResolvedValue({ data: [{ id: 1 }], status: 200 });

    return ticketService.getTickets({ status: "open" }).then(function (result) {
      expect(apiClient.get).toHaveBeenCalledWith("/tickets", {
        params: { status: "open" }
      });
      expect(result).toEqual([expect.objectContaining({ id: 1 })]); // data normalizada, NO la respuesta axios
    });
  });

  it("updateTicket usa PATCH a la ruta con el id", function () {
    apiClient.patch.mockResolvedValue({ data: { id: 5, status: "resolved" } });

    return ticketService.updateTicket(5, { status: "resolved" }).then(function (result) {
      expect(apiClient.patch).toHaveBeenCalledWith("/tickets/5", { status: "resolved" });
      expect(result.status).toBe("resolved");
    });
  });

  it("normaliza los tickets que llegan sin tags", function () {
    apiClient.get.mockResolvedValue({ data: [{ id: 1, title: "X", status: "open" }] });
    return ticketService.getTickets().then(function (tickets) {
      expect(tickets[0].tags).toEqual([]);
      expect(Object.prototype.hasOwnProperty.call(tickets[0], "tags")).toBe(true);
    });
  });
});
