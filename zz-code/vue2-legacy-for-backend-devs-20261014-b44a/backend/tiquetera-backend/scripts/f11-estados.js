const { MongoClient } = require("mongodb");
async function main() {
  const client = await MongoClient.connect(process.env.MONGO_URL, { useUnifiedTopology: true });
  const db = client.db("tiquetera");
  async function getById(id) { return db.collection("tickets").findOne({ _id: id }); }
// La máquina de estados, server-side, sobre la primitiva atómica de la Fase 6.
const LEGAL = {
  open: ["in_progress"], in_progress: ["resolved", "open"],
  resolved: ["closed", "open"], closed: ["open"]
};

async function changeStatus(db, ticketId, to, byUser) {
  const ticket = await getById(ticketId);
  if (!ticket) return { notFound: true };
  if (!LEGAL[ticket.status].includes(to))
    return { illegal: true, from: ticket.status, to };
  // precondición en el filtro (F6): el estado no cambió bajo nuestros pies
  const result = await db.collection("tickets").findOneAndUpdate(
    { _id: ticketId, status: ticket.status },     // ⬅️ optimistic: status esperado
    { $set: { status: to, updatedAt: new Date() },
      $push: { history: { from: ticket.status, to, by: byUser, at: new Date() } } },
    { returnOriginal: false }
  );
  if (!result.value) return { conflict: true };   // alguien transicionó primero → 409
  return { ok: true, ticket: result.value };
}

  const t = await db.collection("tickets").findOne({ status: "open" });
  console.log("open → resolved:", JSON.stringify(await changeStatus(db, t._id, "resolved", "lmcano")));
  const ok = await changeStatus(db, t._id, "in_progress", "lmcano");
  console.log("open → in_progress:", ok.ok, ok.ticket && ok.ticket.history.slice(-1)[0].by);
  const dos = await Promise.all([changeStatus(db, t._id, "resolved", "lmcano"), changeStatus(db, t._id, "resolved", "lmcorrea")]);
  console.log("dos a la vez in_progress → resolved:", JSON.stringify(dos.map(function (r) { return r.ok ? "ok" : Object.keys(r)[0]; })));
  await client.close();
}
main().catch(function (e) { console.error(e.message); process.exit(1); });
