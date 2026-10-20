// soporte_v1: la base de 2019, el MySQL de pedidos.php transcrito tabla por
// tabla a Mongo. Ids enteros, lookup-tables y "FKs" que nadie valida.
// Uso: node scripts/seed-antipattern.js   (100k tickets, 400k comentarios, 300k historial)
const { MongoClient } = require("mongodb");

const MONGO_URL = process.env.MONGO_URL || "mongodb://localhost:27017";
const DB_NAME = "soporte_v1";
const N_TICKETS = 100000;
const N_COMMENTS = 400000;
const N_HISTORY = 300000;
const BATCH = 1000;

let seed = 19061;
function rand() {
  seed = (seed * 1103515245 + 12345) % 2147483648;
  return seed / 2147483648;
}
function int(max) { return 1 + Math.floor(rand() * max); } // 1..max

async function insertInBatches(col, docs) {
  for (let i = 0; i < docs.length; i += BATCH) {
    await col.insertMany(docs.slice(i, i + BATCH), { ordered: false });
  }
}

async function main() {
  const t0 = Date.now();
  const client = await MongoClient.connect(MONGO_URL, { useUnifiedTopology: true });
  const db = client.db(DB_NAME);
  await db.dropDatabase();

  // Las lookup-tables, tal como venían de MySQL. "order" existe porque los ids no ordenan.
  await db.collection("roles").insertMany([{ _id: 1, name: "agent" }, { _id: 2, name: "reporter" }]);
  await db.collection("statuses").insertMany([
    { _id: 1, name: "open" }, { _id: 2, name: "in_progress" },
    { _id: 3, name: "resolved" }, { _id: 4, name: "closed" }
  ]);
  await db.collection("priorities").insertMany([
    { _id: 1, name: "low", order: 1 }, { _id: 2, name: "high", order: 3 }, { _id: 3, name: "medium", order: 2 }
  ]);

  const users = [];
  for (let i = 1; i <= 40; i++) {
    users.push({ _id: i, username: "user" + i, name: "Usuario " + i, roleId: i <= 10 ? 1 : 2 });
  }
  await db.collection("users").insertMany(users);

  const FROM = new Date("2019-01-01T00:00:00Z").getTime();
  const SPAN = 2 * 365 * 24 * 3600 * 1000;
  const created = [0];
  const tickets = [];
  for (let id = 1; id <= N_TICKETS; id++) {
    const createdAt = new Date(FROM + Math.floor(rand() * SPAN));
    created.push(createdAt.getTime());
    tickets.push({
      _id: id,
      title: "Caso " + id,
      description: "Transcrito de MySQL.",
      statusId: rand() < 0.6 ? 4 : int(3),
      priorityId: int(3),
      assigneeId: rand() < 0.15 ? null : int(10),
      reporterId: 10 + int(30),
      createdAt
    });
  }
  await insertInBatches(db.collection("tickets"), tickets);

  // Huérfanos, como en toda base sin FKs: comentarios e historial de tickets
  // que ya no existen (ids por encima del último) y autores borrados (user 99).
  const comments = [];
  for (let id = 1; id <= N_COMMENTS; id++) {
    const orphan = rand() < 0.005;
    const ticketId = orphan ? N_TICKETS + int(5000) : int(N_TICKETS);
    comments.push({
      _id: id,
      ticketId,
      authorId: rand() < 0.002 ? 99 : int(40),
      body: "Comentario " + id,
      createdAt: new Date((orphan ? FROM : created[ticketId]) + Math.floor(rand() * 7 * 24 * 3600 * 1000))
    });
  }
  await insertInBatches(db.collection("comments"), comments);

  const history = [];
  for (let id = 1; id <= N_HISTORY; id++) {
    const orphan = rand() < 0.005;
    const ticketId = orphan ? N_TICKETS + int(5000) : int(N_TICKETS);
    const from = int(4);
    history.push({
      _id: id,
      ticketId,
      fromStatusId: from,
      toStatusId: from === 4 ? 1 : from + 1,
      userId: int(10),
      at: new Date((orphan ? FROM : created[ticketId]) + Math.floor(rand() * 30 * 24 * 3600 * 1000))
    });
  }
  await insertInBatches(db.collection("ticketHistory"), history);

  console.log("soporte_v1:", tickets.length, "tickets,", comments.length, "comments,", history.length,
    "ticketHistory en", ((Date.now() - t0) / 1000).toFixed(1), "s");
  await client.close();
}

main().catch(function (err) {
  console.error("El seed de soporte_v1 falló:", err.message);
  process.exit(1);
});
