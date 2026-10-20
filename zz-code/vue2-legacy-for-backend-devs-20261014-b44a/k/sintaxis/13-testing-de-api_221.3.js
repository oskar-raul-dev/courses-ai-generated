var __a = [
// test/lib/serializers.test.js
const { serializeTicket } = require("../../src/lib/serializers");
const { makeTicket } = require("../fixtures");

describe("serializeTicket (la frontera del contrato)", function () {
  test("_id se vuelve id string", function () {
    const out = serializeTicket(makeTicket());
    expect(typeof out.id).toBe("string");
    expect(out._id).toBeUndefined();
  });

  test("las fechas salen como ISO string", function () {
    const out = serializeTicket(makeTicket());
    expect(out.createdAt).toMatch(/^\d{4}-\d{2}-\d{2}T.*Z$/);
  });

  test("history NO se expone (decisión de la Fase 3)", function () {
    const out = serializeTicket(makeTicket({ history: [{}] }));
    expect(out.history).toBeUndefined();
  });
});
];