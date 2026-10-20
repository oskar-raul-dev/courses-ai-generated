function __f(){
// test/services/tickets.take.test.js
const { connect, close } = require("../helpers/db");
const { users, makeTicket } = require("../fixtures");
const makeService = require("../../src/services/tickets.service");

let db, service;
beforeAll(async function () {
  db = await connect();
  service = makeService(db);                 // la costura: el service recibe su db
});
afterAll(close);

describe("takeTicket — el doble 'tomar' (Fase 6)", function () {
  test("dos agentes concurrentes: exactamente un ganador", async function () {
    for (let round = 0; round < 20; round++) {
      const t = makeTicket();
      await db.collection("tickets").insertOne(t);

      const [a, b] = await Promise.all([
        service.takeTicket(t._id.toHexString(), "lmcano"),
        service.takeTicket(t._id.toHexString(), "admin")
      ]);

      const winners = [a, b].filter(function (r) { return r.ok; });
      expect(winners).toHaveLength(1);                    // ni cero ni dos
      const doc = await db.collection("tickets").findOne({ _id: t._id });
      expect(doc.assignee).toBe(winners[0].ticket.assignee);
      expect(doc.history).toHaveLength(1);                  // la atomicidad, auditada
    }
  });

  test("tomar un tomado → conflict; inexistente → not_found", async function () {
    const t = makeTicket({ assignee: "admin", status: "in_progress" });
    await db.collection("tickets").insertOne(t);
    const r1 = await service.takeTicket(t._id.toHexString(), "lmcano");
    expect(r1).toEqual({ ok: false, reason: "conflict" });
    const r2 = await service.takeTicket(new (require("mongodb").ObjectId)().toHexString(), "lmcano");
    expect(r2).toEqual({ ok: false, reason: "not_found" });
  });
});
}