// Fábrica explícita y no auto-mock: con el babel-jest 23 del plugin de Vue CLI 3, el
// auto-mock de la instancia de axios depende del orden de los import. Así no depende de nada.
jest.mock("@/services/apiClient", function () {
  return { get: jest.fn(), post: jest.fn(), put: jest.fn(), patch: jest.fn(), delete: jest.fn() };
});

import apiClient from "@/services/apiClient";
import ticketService from "@/services/ticketService";

describe("REGRESIÓN · Contrato con la API", function () {
  beforeEach(function () {
    jest.clearAllMocks(); // sin esto: llamadas fantasma entre tests (F11)
  });

  it("listar: GET /tickets con el sort de F4, exacto", function () {
    apiClient.get.mockResolvedValue({ data: [] });

    return ticketService
      .getTickets({ _sort: "createdAt", _order: "desc" })
      .then(function () {
        expect(apiClient.get).toHaveBeenCalledWith("/tickets", {
          params: { _sort: "createdAt", _order: "desc" }
        });
      });
  });

  it("obtener: GET /tickets/:id", function () {
    apiClient.get.mockResolvedValue({ data: { id: 1 } });

    return ticketService.getTicketById(1).then(function () {
      expect(apiClient.get).toHaveBeenCalledWith("/tickets/1");
    });
  });

  it("crear: POST /tickets con el payload ÍNTEGRO", function () {
    const payload = {
      title: "Impresora no imprime",
      description: "La del piso 3 lleva dos días muerta",
      priority: "high", assignee: "lmcorrea",
      status: "open", reporter: "user1", createdAt: "2020-03-10T09:00:00Z"
    };
    apiClient.post.mockResolvedValue({ data: Object.assign({ id: 99 }, payload) });

    return ticketService.createTicket(payload).then(function (created) {
      expect(apiClient.post).toHaveBeenCalledWith("/tickets", payload);
      // el servicio desenvuelve response.data — la vista recibe el ticket,
      // no la respuesta de axios. Contrato de F3, todavía vigente.
      expect(created.id).toBe(99);
    });
  });

  it("actualizar: PATCH (no PUT) — congela la decisión de F3", function () {
    apiClient.patch.mockResolvedValue({ data: {} });

    return ticketService.updateTicket(1, { status: "resolved" }).then(function () {
      expect(apiClient.patch).toHaveBeenCalledWith("/tickets/1", { status: "resolved" });
      expect(apiClient.put).not.toHaveBeenCalled(); // PATCH parcial vs PUT total: no es lo mismo
    });
  });

  it("borrar: DELETE /tickets/:id", function () {
    apiClient.delete.mockResolvedValue({ data: {} });

    return ticketService.deleteTicket(1).then(function () {
      expect(apiClient.delete).toHaveBeenCalledWith("/tickets/1");
    });
  });

  it("el error se PROPAGA (la vista pinta la alerta; el servicio no la traga)", function () {
    apiClient.get.mockRejectedValue(new Error("Network Error"));

    return ticketService.getTickets({}).then(
      function () { throw new Error("no debió resolver"); },
      function (err) { expect(err.message).toBe("Network Error"); }
    );
  });
});
