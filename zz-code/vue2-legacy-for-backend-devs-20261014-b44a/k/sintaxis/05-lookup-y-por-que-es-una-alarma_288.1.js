function __f(){
await db.collection("users").updateOne(
  { username: "lmcano" }, { $set: { name: "Agente Uno Pérez" } });
// ⚡ si el proceso muere AQUÍ: users nuevo, tickets viejos — drift nacido
await db.collection("tickets").updateMany(
  { assignee: "lmcano" }, { $set: { assigneeName: "Agente Uno Pérez" } });
}