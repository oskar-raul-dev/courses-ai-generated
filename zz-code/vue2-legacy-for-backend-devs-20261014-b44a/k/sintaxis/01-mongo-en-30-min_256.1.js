function __f(){
// Seed: importa el db.json heredado a MongoDB.
// Node 14 + driver nativo mongodb@3.6 — sin ODM, a mano, a propósito.
const { MongoClient, ObjectId } = require("mongodb");
const fs = require("fs");
const path = require("path");

const MONGO_URL = "mongodb://localhost:27017";
const DB_NAME = "tiquetera";

async function main() {
  const raw = fs.readFileSync(path.join(__dirname, "../data/db.json"), "utf8");
  const data = JSON.parse(raw);

  const client = await MongoClient.connect(MONGO_URL, {
    useUnifiedTopology: true
  });
  const db = client.db(DB_NAME);

  // Empezar de cero: el seed debe ser re-ejecutable (idempotente por las malas)
  await db.dropDatabase();

  // ── 1. users: id numérico → ObjectId, guardando el mapa de traducción
  const userIdMap = new Map(); // idViejo -> ObjectId nuevo
  const users = data.users.map(function (u) {
    const _id = new ObjectId();
    userIdMap.set(u.id, _id);
    return { _id, username: u.username, name: u.name, role: u.role };
  });
  await db.collection("users").insertMany(users);

  // ── 2. tickets: igual, más fechas string → Date
  const ticketIdMap = new Map();
  const tickets = data.tickets.map(function (t) {
    const _id = new ObjectId();
    ticketIdMap.set(t.id, _id);
    return {
      _id,
      title: t.title,
      description: t.description || "",
      status: t.status,
      priority: t.priority,
      assignee: t.assignee,          // username o null (así lo usa el frontend)
      reporter: t.reporter,
      createdAt: new Date(t.createdAt)
    };
  });
  await db.collection("tickets").insertMany(tickets);

  // ── 3. comments: AQUÍ está la lección de la fase.
  // ticketId apuntaba a un número que ya no existe. La "FK" la retraduces TÚ.
  const comments = data.comments.map(function (c) {
    const ticketId = ticketIdMap.get(c.ticketId);
    if (!ticketId) {
      // En SQL esto era un error del motor. Aquí es un console.log tuyo
      // o un comentario huérfano silencioso. Elige ser el motor.
      throw new Error("Comentario " + c.id + " apunta a ticket inexistente: " + c.ticketId);
    }
    return {
      _id: new ObjectId(),
      ticketId,                       // ObjectId del ticket nuevo
      author: c.author,
      body: c.body,
      createdAt: new Date(c.createdAt)
    };
  });
  await db.collection("comments").insertMany(comments);

  // ── 4. la OTRA referencia, la que no es un id: los usernames.
  // assignee, reporter y author no apuntan a un _id: apuntan a un username.
  // Sigue siendo una referencia, y sigue siendo tuya. Aquí NO lanzamos: la
  // fixture heredada ya viene con algunas rotas y romper el seed te dejaría
  // sin base. Se reportan, y tú decides (ver abajo).
  const known = new Set(users.map(function (u) { return u.username; }));
  const dangling = new Map();   // username -> [dónde aparece]

  function check(username, where) {
    if (username && !known.has(username)) {          // null = sin asignar, es válido
      if (!dangling.has(username)) dangling.set(username, []);
      dangling.get(username).push(where);
    }
  }

  tickets.forEach(function (t) {
    check(t.assignee, "ticket." + t._id + ".assignee");
    check(t.reporter, "ticket." + t._id + ".reporter");
  });
  comments.forEach(function (c) { check(c.author, "comment." + c._id + ".author"); });

  if (dangling.size > 0) {
    console.warn("\n⚠️  Usernames referenciados que NO existen en users:");
    dangling.forEach(function (where, username) {
      console.warn("   " + username + " → " + where.length + " referencia(s)");
    });
    console.warn("   Decide qué haces con esto y anótalo en DATA-MODEL.md.\n");
  }

  console.log("Seed OK:", users.length, "users,", tickets.length, "tickets,",
    comments.length, "comments");
  await client.close();
}

main().catch(function (err) {
  console.error("El seed falló:", err.message);
  process.exit(1);
});
}