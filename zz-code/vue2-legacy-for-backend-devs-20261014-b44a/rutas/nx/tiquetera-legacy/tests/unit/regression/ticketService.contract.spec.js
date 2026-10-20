import ticketService from "@/services/ticketService";
import apiClient from "@/services/apiClient";

jest.mock("@/services/apiClient"); // el cable a axios, cortado

describe("REGRESIÓN · ticketService ↔ API (F3/F5)", function () {
  beforeEach(function () {
    jest.clearAllMocks();
  });

  it("createTicket hace POST /tickets con el payload íntegro y devuelve data", function () {
    apiClient.post.mockResolvedValue({ data: { id: 99, title: "nuevo" } });

    var payload = { title: "nuevo", description: "desc", status: "open" };

    return ticketService.createTicket(payload).then(function (result) {
      // El CONTRATO con la API: verbo + ruta + cuerpo idénticos.
      expect(apiClient.post).toHaveBeenCalledWith("/tickets", payload);
      // Y devuelve res.data pelado, no la respuesta axios cruda.
      expect(result).toEqual({ id: 99, title: "nuevo" });
    });
  });

  it("updateTicket hace PATCH /tickets/:id con los cambios", function () {
    apiClient.patch.mockResolvedValue({ data: { id: 7, status: "resolved" } });

    return ticketService.updateTicket(7, { status: "resolved" }).then(function () {
      expect(apiClient.patch).toHaveBeenCalledWith("/tickets/7", { status: "resolved" });
    });
  });

  it("deleteTicket hace DELETE /tickets/:id", function () {
    apiClient.delete.mockResolvedValue({ status: 200 });

    return ticketService.deleteTicket(7).then(function () {
      expect(apiClient.delete).toHaveBeenCalledWith("/tickets/7");
    });
  });
});
