function __f(){
// El rename de la Fase 5, ahora todo-o-nada
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
}