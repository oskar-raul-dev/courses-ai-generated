const io = require("socket.io-client");
const axios = require("axios");
const fs = require("fs");
const FormData = require("form-data");
const { sign } = require("../src/lib/auth");
async function main() {
  const anon = io("http://localhost:4000");
  const malo = io("http://localhost:4000", { query: { token: "basura" } });
  malo.on("error", function (e) { console.log("socket con token inválido → error:", e); });
  await new Promise(function (r) { anon.on("connect", r); });
  const llegó = new Promise(function (r) { anon.on("ticket:created", r); });
  await axios.post("http://localhost:3000/tickets", { title: "Desde la prueba", description: "x", priority: "low", status: "open", reporter: "dprios", assignee: null });
  const t = await llegó;
  console.log("ticket:created al cliente 2.4.0 →", JSON.stringify(Object.keys(t).sort()), "| id hex:", /^[0-9a-f]{24}$/.test(t.id));
  const token = sign({ username: "lmcano", role: "agent", name: "Laura" });
  const H = { Authorization: "Bearer " + token };
  const f1 = new FormData(); f1.append("ticketId", t.id); f1.append("file", Buffer.from("hola adjunto"), { filename: "nota.txt", contentType: "text/plain" });
  const up = await axios.post("http://localhost:3000/attachments", f1, { headers: Object.assign(f1.getHeaders(), H) });
  console.log("subida:", up.status, JSON.stringify(up.data));
  const down = await axios.get("http://localhost:3000/attachments/" + up.data.id);
  console.log("bajada:", down.status, down.headers["content-type"], JSON.stringify(down.data));
  const f2 = new FormData(); f2.append("ticketId", t.id); f2.append("file", Buffer.alloc(11 * 1024 * 1024), { filename: "grande.bin" });
  const big = await axios.post("http://localhost:3000/attachments", f2, { headers: Object.assign(f2.getHeaders(), H), maxBodyLength: Infinity, maxContentLength: Infinity, validateStatus: function () { return true; } });
  console.log("11 MB con límite de 10:", big.status, JSON.stringify(big.data));
  anon.close(); malo.close();
}
main().catch(function (e) { console.error(e.message); process.exit(1); });
