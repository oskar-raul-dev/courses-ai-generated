import ticketsModule from "@/store/modules/tickets";
import ticketService from "@/services/ticketService";

jest.mock("@/services/ticketService"); // el cable a HTTP, cortado

var mutations = ticketsModule.mutations;
var actions = ticketsModule.actions;

describe("store/tickets", function () {
  describe("mutations", function () {
    it("UPSERT_TICKET inserta si el ticket no existe", function () {
      var state = { items: [{ id: 1, title: "viejo" }] };

      mutations.UPSERT_TICKET(state, { id: 2, title: "nuevo" });

      expect(state.items).toHaveLength(2);
      expect(state.items[0].id).toBe(2); // unshift: el nuevo va primero
    });

    it("UPSERT_TICKET reemplaza si el ticket ya existe", function () {
      var state = { items: [{ id: 1, status: "open" }] };

      mutations.UPSERT_TICKET(state, { id: 1, status: "resolved" });

      expect(state.items).toHaveLength(1);
      expect(state.items[0].status).toBe("resolved");
    });
  });

  describe("actions/fetchTickets", function () {
    var context = {
      commit: jest.fn(),           // espía: registra cada commit
      state: { items: [] }
    };

    it("en éxito: enciende loading, guarda tickets, apaga loading", function () {
      var fakeTickets = [{ id: 1 }];
      ticketService.getTickets.mockResolvedValue(fakeTickets);

      return actions.fetchTickets(context).then(function () {
        expect(context.commit).toHaveBeenCalledWith("SET_LOADING", true);
        expect(context.commit).toHaveBeenCalledWith("SET_TICKETS", fakeTickets);
        expect(context.commit).toHaveBeenCalledWith("SET_LOADING", false);
      });
    });

    it("en error: guarda el mensaje, apaga loading y RE-LANZA", function () {
      ticketService.getTickets.mockRejectedValue(new Error("boom"));

      return actions.fetchTickets(context).then(
        function () { throw new Error("no debió resolver"); },
        function () { // rama de rechazo: aquí DEBE caer
          expect(context.commit).toHaveBeenCalledWith(
            "SET_ERROR", "No se pudieron cargar los tickets."
          );
          expect(context.commit).toHaveBeenCalledWith("SET_LOADING", false);
        }
      );
    });

    it("con caché: si hay items y no hay force, NO toca la red", function () {
      console.log("commits heredados:", context.commit.mock.calls.length);
      context.state.items = [{ id: 1 }];

      return actions.fetchTickets(context).then(function (result) {
        expect(ticketService.getTickets).not.toHaveBeenCalled();
        expect(context.commit).not.toHaveBeenCalled();
        expect(result).toEqual([{ id: 1 }]);
      });
    });
  });
});
