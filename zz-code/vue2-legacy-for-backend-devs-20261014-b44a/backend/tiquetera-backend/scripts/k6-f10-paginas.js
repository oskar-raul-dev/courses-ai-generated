// K6: el bloque opcional de F10 (Q3/VU3) — _page/_limit, X-Total-Count y su exposición CORS
const axios = require("axios");
const api = axios.create({ baseURL: "http://localhost:3000", headers: { Origin: "http://localhost:8080" } });
async function main() {
  const todo = await api.get("/tickets");
  console.log("sin _limit →", todo.status, "filas:", todo.data.length, "| X-Total-Count:", todo.headers["x-total-count"], "| array plano:", Array.isArray(todo.data));
  const p1 = await api.get("/tickets?_page=1&_limit=2&_sort=createdAt&_order=desc");
  const p2 = await api.get("/tickets?_page=2&_limit=2&_sort=createdAt&_order=desc");
  console.log("página 1 →", p1.data.length, "filas, total", p1.headers["x-total-count"], "| página 2 →", p2.data.length, "filas");
  console.log("ids distintos entre páginas:", p1.data.every(function (a) { return !p2.data.some(function (b) { return b.id === a.id; }); }));
  const f = await api.get("/tickets?status=open&_page=1&_limit=1");
  console.log("?status=open&_limit=1 →", f.data.length, "fila, total", f.headers["x-total-count"], "(el total respeta el filtro)");
  console.log("Access-Control-Expose-Headers:", p1.headers["access-control-expose-headers"]);
}
main().then(function () { process.exit(0); }, function (e) { console.error(e.message); process.exit(1); });
