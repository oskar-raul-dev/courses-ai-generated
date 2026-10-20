const { MongoClient, ObjectId } = require("mongodb");
const { takeTicket } = require("../lib/tickets");
async function main() {
  const client = await MongoClient.connect(process.env.MONGO_URL, { useUnifiedTopology: true });
  const db = client.db("tiquetera");
  const t = await db.collection("tickets").findOne({ status: "open", assignee: null });
  const r = await Promise.all([takeTicket(db, String(t._id), "lmcano"), takeTicket(db, String(t._id), "lmcorrea")]);
  console.log("dos agentes a la vez:", JSON.stringify(r.map(function (x) { return x.ok ? "ok " + x.ticket.assignee : x.reason; })));
  console.log("inexistente:", (await takeTicket(db, "5f8a1b2c3d4e5f6a7b8c9d0e", "lmcano")).reason);
  try {
const session = client.startSession();
    try {
      await session.withTransaction(async function () {
        await db.collection("users").updateOne(
          { username: "lmcano" },
          { $set: { name: "Agente Uno Pérez" } },
          { session }                                    // ⬅️ cada op DEBE llevarla
        );
        await db.collection("tickets").updateMany(
          { assignee: "lmcano" },
          { $set: { assigneeName: "Agente Uno Pérez" } },
          { session }
        );
      }, {
        readConcern:  { level: "majority" },
        writeConcern: { w: "majority" }
      });
    } finally {
      await session.endSession();
    }
    
    console.log("transacción: ok,", await db.collection("tickets").countDocuments({ assigneeName: "Agente Uno Pérez" }), "tickets con el nombre nuevo");
  } catch (e) { console.log("transacción:", e.message); }
  await client.close();
}
main().catch(function (e) { console.error(e.message); process.exit(1); });
