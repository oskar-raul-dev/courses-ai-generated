

describe("ticketStats", function () {
  describe("countByStatus", function () {
    it("cuenta los tickets por estado", function () {
      var tickets = [
        { status: "open" },
        { status: "open" },
        { status: "resolved" }
      ];

      expect(countByStatus(tickets)).toEqual({ open: 2, resolved: 1 });
    });

    it("devuelve objeto vacío sin tickets", function () {
      expect(countByStatus([])).toEqual({});
    });
  });

  describe("resolvedPercent", function () {
    it("calcula el porcentaje de resueltos y cerrados", function () {
      var tickets = [
        { status: "resolved" },
        { status: "closed" },
        { status: "open" },
        { status: "open" }
      ];

      expect(resolvedPercent(tickets)).toBe(50);
    });

    it("devuelve 0 con lista vacía (sin dividir por cero)", function () {
      expect(resolvedPercent([])).toBe(0);
    });

    it("redondea al entero más cercano", function () {
      var tickets = [{ status: "resolved" }, { status: "open" }, { status: "open" }];
      expect(resolvedPercent(tickets)).toBe(33); // 33.33... → 33
    });
  });

  describe("initialsOf", function () {
    it("toma la primera letra de cada palabra, máximo tres", function () {
      expect(initialsOf("Laura Marcela Cano")).toBe("LMC");
      expect(initialsOf("Andrés Felipe Ríos Gómez")).toBe("AFR");
    });

    it("tolera nombre vacío o nulo", function () {
      expect(initialsOf("")).toBe("");
      expect(initialsOf(null)).toBe("");
    });
  });

  describe("scoreBoard", function () {
    var users = [{ username: "lmcano", name: "Laura Marcela Cano" }];

    it("suma los resueltos y cerrados según la prioridad", function () {
      var tickets = [
        { assignee: "lmcano", status: "resolved", priority: "high" },
        { assignee: "lmcano", status: "closed", priority: "low" },
        { assignee: "lmcano", status: "open", priority: "high" }
      ];

      expect(scoreBoard(tickets, users)).toEqual([
        expect.objectContaining({ initials: "LMC", solved: 2, points: 400 })
      ]);
    });

    it("pinta ??? cuando el usuario ya no existe", function () {
      var tickets = [{ assignee: "jpmesa", status: "resolved", priority: "medium" }];
      expect(scoreBoard(tickets, users)).toEqual([
        expect.objectContaining({ initials: "???", solved: 1, points: 200 })
      ]);
    });

    it("ordena por puntos, de mayor a menor", function () {
      var tickets = [
        { assignee: "jpmesa", status: "resolved", priority: "low" },
        { assignee: "lmcano", status: "resolved", priority: "high" }
      ];
      var order = scoreBoard(tickets, users).map(function (row) { return row.initials; });
      expect(order).toEqual(["LMC", "???"]);
    });
  });
});