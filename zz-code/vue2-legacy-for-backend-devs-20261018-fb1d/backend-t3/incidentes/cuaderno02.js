// Preparaciones y pruebas rojo/verde del cuaderno del Curso 02 (02, 04, 06, 08)
const { MongoClient, ObjectId } = require("mongodb");
const assert = require("assert");
function ver(nombre, fn) { return fn().then(function () { console.log("  ✅", nombre); }, function (e) { console.log("  ❌", nombre, "→", e.message.split("\n")[0].slice(0, 110)); }); }
async function main() {
  const client = await MongoClient.connect(process.env.MONGO_URL, { useUnifiedTopology: true });
  const db = client.db("cuaderno02");
  await db.dropDatabase();
  const col = db.collection("tickets");

  console.log("Incidente 02 — fechas como texto");
  const base = new Date("2020-03-01T00:00:00Z").getTime();
  const docs = [];
  for (let i = 0; i < 100; i++) { const d = new Date(base + i * 6 * 3600 * 1000); docs.push({ title: "T" + i, createdAt: i % 2 ? d : d.toISOString() }); }
  await col.insertMany(docs);
  const marzo = { createdAt: { $gte: new Date("2020-03-01"), $lt: new Date("2020-04-01") } };
  console.log("    en marzo (Date):", await col.countDocuments(marzo), "de 100 creados en marzo");
  const prueba02 = async function () { assert.strictEqual(await col.countDocuments({ createdAt: { $type: "string" } }), 0); };
  await ver("rojo esperado: no quedan fechas como texto", prueba02);
  for (const d of await col.find({ createdAt: { $type: "string" } }).toArray()) await col.updateOne({ _id: d._id }, { $set: { createdAt: new Date(d.createdAt) } });
  await ver("verde tras la migración", prueba02);
  console.log("    en marzo tras migrar:", await col.countDocuments(marzo));

  console.log("Incidente 04 — historiales gigantes");
  await col.deleteMany({});
  const t4 = [];
  for (let i = 0; i < 1000; i++) {
    const big = i < 20;
    const history = []; const n = big ? 15000 : 5;
    for (let k = 0; k < n; k++) history.push({ from: "open", to: "in_progress", by: "lmcano", at: new Date() });
    t4.push({ legacyId: i, title: "T" + i, status: "open", history: history });
  }
  for (let i = 0; i < t4.length; i += 50) await col.insertMany(t4.slice(i, i + 50));
  const tam = await col.aggregate([{ $match: { legacyId: { $in: [7, 41] } } }, { $project: { legacyId: 1, size: { $bsonSize: "$$ROOT" } } }]).toArray();
  console.log("    tamaños:", JSON.stringify(tam.map(function (d) { return [d.legacyId, d.size]; })));
  const prueba04 = async function () { const big = await col.aggregate([{ $project: { size: { $bsonSize: "$$ROOT" } } }, { $match: { size: { $gt: 100 * 1024 } } }]).toArray(); assert.strictEqual(big.length, 0, big.length + " tickets sobre el techo"); };
  await ver("rojo esperado: ningún ticket supera 100 KB", prueba04);
  for (const d of await col.find({ "history.100": { $exists: true } }).toArray()) {
    await db.collection("ticket_events").insertMany(d.history.map(function (h) { return Object.assign({ ticketId: d._id }, h); }));
    await col.updateOne({ _id: d._id }, { $set: { history: d.history.slice(-50) } });
  }
  await ver("verde tras sacar el historial a ticket_events (se quedan los últimos 50)", prueba04);

  console.log("Incidente 06 — el doble tomar");
  async function takeBug(id, user) {
    const t = await col.findOne({ _id: id });
    if (t.assignee) throw new Error("Ya está asignado");
    await col.updateOne({ _id: id }, { $set: { assignee: user, status: "in_progress" } });
  }
  async function takeFix(id, user) {
    const r = await col.updateOne({ _id: id, assignee: null }, { $set: { assignee: user, status: "in_progress" } });
    if (r.matchedCount === 0) throw new Error("Ana se te adelantó");
  }
  function prueba06(take) { return async function () {
    let dobles = 0;
    for (let i = 0; i < 50; i++) {
      const r = await col.insertOne({ title: "libre", status: "open", assignee: null });
      const res = await Promise.all([take(r.insertedId, "ana"), take(r.insertedId, "beto")].map(function (p) { return p.catch(function (e) { return e; }); }));
      if (res.filter(function (x) { return !(x instanceof Error); }).length !== 1) dobles++;
    }
    assert.strictEqual(dobles, 0, dobles + " de 50 rondas con dos ganadores");
  }; }
  await ver("rojo esperado: findOne + updateOne", prueba06(takeBug));
  await ver("verde: la condición en el filtro", prueba06(takeFix));

  console.log("Incidente 08 — el mapa de estados corrido");
  const v1 = client.db("soporte_v1").collection("tickets");
  const STATUS_MAP = { 1: "open", 2: "in_progress", 3: "resolved", 4: "closed" };
  const ARREGLO = ["open", "in_progress", "resolved", "closed"];   // el bug: indexar desde 0
  const dst = db.collection("v2tickets");
  async function migrar(mapa) {
    await dst.deleteMany({});
    const lote = [];
    for await (const t of v1.find({}, { projection: { statusId: 1 } }).limit(20000)) { lote.push({ legacyId: t._id, status: mapa(t.statusId) }); }
    await dst.insertMany(lote);
  }
  const prueba08 = async function () {
    assert.strictEqual(await dst.countDocuments({ status: { $nin: ["open", "in_progress", "resolved", "closed"] } }), 0, "estados fuera del enum");
    for (const id in STATUS_MAP) {
      const a = await dst.countDocuments({ status: STATUS_MAP[id] });
      const b = await v1.countDocuments({ statusId: Number(id), _id: { $lte: 20000 } });
      assert.strictEqual(a, b, STATUS_MAP[id] + ": " + a + " en v2, " + b + " en v1");
    }
  };
  await migrar(function (sid) { return ARREGLO[sid]; });
  console.log("    conteo total:", await dst.countDocuments(), "(igual al origen: el conteo no ve el bug)");
  await ver("rojo esperado: la distribución por estado coincide", prueba08);
  await migrar(function (sid) { return STATUS_MAP[sid]; });
  await ver("verde: mapa por clave", prueba08);

  await client.db("cuaderno02").dropDatabase();
  await client.close();
}
main().catch(function (e) { console.error(e); process.exit(1); });
