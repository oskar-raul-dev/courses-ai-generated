// K6: las deudas de F11 integradas, contra el servidor real
const axios = require("axios");
const { sign } = require("../src/lib/auth");
const api = axios.create({ baseURL: "http://localhost:3000", validateStatus: function () { return true; } });
const agente = { Authorization: "Bearer " + sign({ username: "lmcano", role: "agent", name: "Laura" }) };
const reporter = { Authorization: "Bearer " + sign({ username: "dprios", role: "reporter", name: "Diana" }) };
async function main() {
  let r = await api.post("/tickets", { title: "Sin token", description: "x", priority: "low" });
  console.log("POST sin token →", r.status);
  r = await api.post("/tickets", { title: "x" }, { headers: { Authorization: "Bearer basura" } });
  console.log("POST token basura →", r.status);
  r = await api.post("/tickets", { title: "La impresora otra vez", description: "piso 2", priority: "high", reporter: "admin", status: "closed" }, { headers: reporter });
  const t = r.data;
  console.log("POST como dprios con reporter:'admin' y status:'closed' →", r.status, "reporter:", t.reporter, "status:", t.status);
  r = await api.patch("/tickets/" + t.id, { status: "in_progress" }, { headers: reporter });
  console.log("PATCH como reporter →", r.status, JSON.stringify(r.data));
  r = await api.patch("/tickets/" + t.id, { status: "resolved" }, { headers: agente });
  console.log("PATCH open → resolved →", r.status, JSON.stringify(r.data));
  const [a, b] = await Promise.all([
    api.patch("/tickets/" + t.id, { status: "in_progress" }, { headers: agente }),
    api.patch("/tickets/" + t.id, { status: "in_progress" }, { headers: agente })
  ]);
  console.log("dos PATCH open → in_progress a la vez →", [a.status, b.status].sort().join(" y "));
  const { MongoClient, ObjectId } = require("mongodb");
  const c = await MongoClient.connect(process.env.MONGO_URL, { useUnifiedTopology: true });
  const doc = await c.db("tiquetera").collection("tickets").findOne({ _id: new ObjectId(t.id) });
  const h = doc.history; await c.close();
  console.log("history:", JSON.stringify(h.map(function (x) { return { from: x.from, to: x.to, by: x.by }; })));
  r = await api.patch("/tickets/" + t.id, { priority: "low" }, { headers: agente });
  console.log("PATCH sin status (priority) →", r.status, r.data.priority, r.data.status);
}
main().then(function () { process.exit(0); }, function (e) { console.error(e); process.exit(1); });
