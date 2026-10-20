// scripts/migrate.incidente-08.js — la migración de anoche, con sus dos bugs puestos
const { MongoClient } = require("mongodb");

const MONGO_URL = process.env.MONGO_URL || "mongodb://localhost:27017";
const STATUS = ["open", "in_progress", "resolved", "closed"]; // 💣 posicional, y statusId empieza en 1

async function main() {
  const client = await MongoClient.connect(MONGO_URL, { useUnifiedTopology: true });
  const src = client.db("soporte_v1");
  const dst = client.db("soporte_v2");
  await dst.dropDatabase();
  // la clave estable de la migración: sin este índice, cada corrección por legacyId es un COLLSCAN
  await dst.collection("tickets").createIndex({ legacyId: 1 }, { unique: true });

  const userMap = {}; // 💣 se llena DESPUÉS: tickets se migra primero
  let lote = [];
  for await (const t of src.collection("tickets").find({})) {
    lote.push({
      legacyId: t._id,
      title: t.title,
      description: t.description,
      status: STATUS[t.statusId],
      assignee: userMap[t.assigneeId] || null,
      createdAt: t.createdAt
    });
    if (lote.length === 5000) { await dst.collection("tickets").insertMany(lote); lote = []; }
  }
  if (lote.length) await dst.collection("tickets").insertMany(lote);

  for await (const u of src.collection("users").find({})) {
    userMap[u._id] = u.username;
    await dst.collection("users").insertOne({ legacyId: u._id, username: u.username, name: u.name });
  }

  const n = await dst.collection("tickets").countDocuments();
  const total = await src.collection("tickets").countDocuments();
  console.log("Migración OK: " + n + " de " + total + " tickets");
  await client.close();
}

main().catch(function (e) { console.error(e); process.exit(1); });
