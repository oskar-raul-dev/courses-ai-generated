// Generador de volumen: reconstruye users, tickets y comments de la base
// `tiquetera` con datos sintéticos. Node 14 + mongodb@3.6, como el seed.
// Uso: node scripts/generate.js --tickets 100000 [--comments 400000]
const { MongoClient, ObjectId } = require("mongodb");

const MONGO_URL = process.env.MONGO_URL || "mongodb://localhost:27017";
const DB_NAME = "tiquetera";
const BATCH = 1000;

function arg(name, fallback) {
  const i = process.argv.indexOf("--" + name);
  return i === -1 ? fallback : Number(process.argv[i + 1]);
}
const N_TICKETS = arg("tickets", 100000);
const N_COMMENTS = arg("comments", N_TICKETS * 4);

// Aleatorio con semilla: dos corridas con los mismos argumentos dan la misma base
let seed = 20200310;
function rand() {
  seed = (seed * 1103515245 + 12345) % 2147483648;
  return seed / 2147483648;
}
function pick(list) { return list[Math.floor(rand() * list.length)]; }
function weighted(pairs) { // [[valor, peso], ...]
  let r = rand() * pairs.reduce(function (s, p) { return s + p[1]; }, 0);
  for (const p of pairs) { if ((r -= p[1]) < 0) return p[0]; }
  return pairs[pairs.length - 1][0];
}

const AGENTS = ["admin", "lmcano", "lmcorrea", "aegomez", "jfortiz", "kmarin", "dhenao", "vrestrepo"];
const REPORTERS = ["dprios", "cvelez", "mrestrepo", "sbotero", "pzapata", "lgiraldo", "acardona", "jarango"];
const SUBJECTS = ["La impresora", "El datáfono", "La caja", "El cuadre de caja", "La factura electrónica",
  "El correo", "El inventario", "El cierre de turno", "La tablet de pedidos", "El lector de código"];
const PROBLEMS = ["no imprime", "no conecta", "no cuadra", "se reinicia sola", "no sale con el NIT",
  "está lenta", "no abre", "muestra un error", "no sincroniza", "se congela"];

const FROM = new Date("2019-06-01T00:00:00Z").getTime();
const SPAN = 2 * 365 * 24 * 3600 * 1000; // dos años

async function insertInBatches(col, docs) {
  for (let i = 0; i < docs.length; i += BATCH) {
    await col.insertMany(docs.slice(i, i + BATCH), { ordered: false });
  }
}

async function main() {
  const t0 = Date.now();
  const client = await MongoClient.connect(MONGO_URL, { useUnifiedTopology: true });
  const db = client.db(DB_NAME);
  for (const name of ["users", "tickets", "comments"]) {
    await db.collection(name).deleteMany({});
  }

  // users: los agentes y una parte de los reporteros. cvelez y mrestrepo
  // quedan fuera a propósito: las referencias rotas del db.json heredado, a escala.
  const users = AGENTS.map(function (u) { return { _id: new ObjectId(), username: u, name: u, role: "agent" }; })
    .concat(REPORTERS.filter(function (u) { return u !== "cvelez" && u !== "mrestrepo"; })
      .map(function (u) { return { _id: new ObjectId(), username: u, name: u, role: "reporter" }; }));
  await db.collection("users").insertMany(users);

  const ids = [];
  const created = [];
  const tickets = [];
  for (let i = 0; i < N_TICKETS; i++) {
    const _id = new ObjectId();
    const status = weighted([["closed", 60], ["open", 20], ["in_progress", 10], ["resolved", 10]]);
    const createdAt = new Date(FROM + Math.floor(rand() * SPAN));
    const t = {
      _id,
      title: pick(SUBJECTS) + " " + pick(PROBLEMS),
      description: "Generado para pruebas de volumen.",
      status,
      priority: weighted([["low", 40], ["medium", 40], ["high", 20]]),
      reporter: pick(REPORTERS),
      createdAt
    };
    // assignee: username, null explícito o ausente (la trampa 1 de la Fase 2)
    const a = rand();
    if (status === "open" && a < 0.5) t.assignee = null;
    else if (a < 0.05) { /* sin campo */ } else t.assignee = pick(AGENTS);
    tickets.push(t);
    ids.push(_id);
    created.push(createdAt.getTime());
  }
  await insertInBatches(db.collection("tickets"), tickets);

  const comments = [];
  for (let i = 0; i < N_COMMENTS; i++) {
    const k = Math.floor(rand() * ids.length);
    comments.push({
      _id: new ObjectId(),
      ticketId: ids[k],
      author: rand() < 0.6 ? pick(AGENTS) : pick(REPORTERS),
      body: "Comentario de prueba " + (i + 1) + ".",
      createdAt: new Date(created[k] + Math.floor(rand() * 7 * 24 * 3600 * 1000))
    });
  }
  await insertInBatches(db.collection("comments"), comments);

  console.log("Generado:", users.length, "users,", tickets.length, "tickets,", comments.length,
    "comments en", ((Date.now() - t0) / 1000).toFixed(1), "s");
  await client.close();
}

main().catch(function (err) {
  console.error("El generador falló:", err.message);
  process.exit(1);
});
