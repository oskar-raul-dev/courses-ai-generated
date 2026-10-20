var __o = {
// scripts/migrations/002-add-updatedAt.js  (driver 3.6, Node 14)
const { MongoClient } = require("mongodb");

async function main() {
  const dryRun = process.argv.includes("--dry");
  const client = await MongoClient.connect("mongodb://localhost:27017",
    { useUnifiedTopology: true });
  const col = client.db("tiquetera").collection("tickets");

  const filter = { updatedAt: { $exists: false } };
  const total = await col.countDocuments(filter);
  console.log((dryRun ? "[DRY] " : "") + "Documentos a migrar:", total);

  if (!dryRun && total > 0) {
    // updatedAt arranca igual a createdAt: honesto y consultable.
    // OJO: esta migración NO toca schemaVersion. Estampar aquí un "2" fijo
    // pisaría a los documentos que ya son v3 (priority + history). La versión
    // se infiere por forma en su propia migración (001-add-schemaVersion.js,
    // ejercicio 13): sin priority → 1; con priority sin history → 2; con
    // history → 3. Una migración, una responsabilidad.
    const result = await col.updateMany(filter, [
      { $set: { updatedAt: "$createdAt" } }
    ]);
    console.log("Modificados:", result.modifiedCount);
  }
  await client.close();
}
main().catch(function (e) { console.error(e); process.exit(1); });
};