var __a = [



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
      expect(result).toEqual([{ id: 1 }]); // data pelada, NO la respuesta axios
    });
  });

  it("updateTicket usa PATCH a la ruta con el id", function () {
    apiClient.patch.mockResolvedValue({ data: { id: 5, status: "resolved" } });

    return ticketService.updateTicket(5, { status: "resolved" }).then(function (result) {
      expect(apiClient.patch).toHaveBeenCalledWith("/tickets/5", { status: "resolved" });
      expect(result.status).toBe("resolved");
    });
  });
});
];