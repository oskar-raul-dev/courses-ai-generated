// La promesa del baseURL, en números: las llamadas del frontend contra json-server y contra Express
const axios = require("axios");
const JS = axios.create({ baseURL: "http://localhost:3001", validateStatus: function () { return true; } });
const EX = axios.create({ baseURL: "http://localhost:3000", validateStatus: function () { return true; } });
function forma(v) {
  if (Array.isArray(v)) return "array[" + v.length + "]" + (v.length ? " de " + forma(v[0]) : "");
  if (v && typeof v === "object") return "{" + Object.keys(v).sort().map(function (k) { return k + ":" + (k === "id" || k === "ticketId" ? "id" : typeof v[k]); }).join(",") + "}";
  return typeof v;
}
async function par(nombre, fn) {
  const a = await fn(JS, "js"), b = await fn(EX, "ex");
  const iguales = a.status === b.status && forma(a.data) === forma(b.data);
  console.log((iguales ? "✅" : "❌") + " " + nombre + " | json-server " + a.status + " " + forma(a.data) + (iguales ? "" : " | express " + b.status + " " + forma(b.data)));
  return { a: a, b: b };
}
async function main() {
  const ctx = {};
  const l = await par("GET /tickets?_sort=createdAt&_order=desc", function (c) { return c.get("/tickets", { params: { _sort: "createdAt", _order: "desc" } }); });
  console.log("   orden json-server:", l.a.data.map(function (t) { return t.title; }).join(" | "));
  console.log("   orden express:    ", l.b.data.map(function (t) { return t.title; }).join(" | "));
  ctx.js = l.a.data[0].id; ctx.ex = l.b.data[0].id;
  await par("GET /tickets/:id", function (c, k) { return c.get("/tickets/" + ctx[k]); });
  await par("GET /tickets/999 (no existe)", function (c) { return c.get("/tickets/999"); });
  await par("GET /tickets?status=open", function (c) { return c.get("/tickets", { params: { status: "open" } }); });
  await par("GET /tickets?q=impresora", function (c) { return c.get("/tickets", { params: { q: "impresora" } }); });
  const nuevo = { title: "Prueba diferencial", description: "Creado por la prueba de la promesa", priority: "medium", assignee: "", status: "open", reporter: "dprios", createdAt: "2026-10-15T10:00:00.000Z" };
  const p = await par("POST /tickets", function (c) { return c.post("/tickets", nuevo); });
  ctx.njs = p.a.data.id; ctx.nex = p.b.data.id;
  await par("PATCH /tickets/:id {status}", function (c, k) { return c.patch("/tickets/" + ctx["n" + k], { status: "in_progress" }); });
  await par("GET /comments?ticketId&_sort=createdAt&_order=asc", function (c, k) { return c.get("/comments", { params: { ticketId: ctx[k], _sort: "createdAt", _order: "asc" } }); });
  await par("POST /comments", function (c, k) { return c.post("/comments", { ticketId: ctx[k], author: "lmcano", body: "Hola", createdAt: "2026-10-15T10:05:00.000Z" }); });
  await par("DELETE /tickets/:id", function (c, k) { return c.delete("/tickets/" + ctx["n" + k]); });
  await par("GET /users", function (c) { return c.get("/users"); });
  await par("GET /no-existe", function (c) { return c.get("/no-existe"); });
}
main().catch(function (e) { console.error(e.message); process.exit(1); });
