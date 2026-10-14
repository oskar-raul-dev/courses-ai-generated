#!/bin/sh
# Fase 04: the extracted db.json loads in json-server 0.16.3 (run inside node:14.21.3 from sondas/angular8).
cp extraidos/fase04-db.json /tmp/db.json
(npx json-server --quiet --port 3000 /tmp/db.json >/dev/null 2>&1 &)
sleep 3
node -e '
const http = require("http");
const get = p => new Promise(r => http.get("http://localhost:3000" + p, res => { let b = ""; res.on("data", c => b += c); res.on("end", () => r(JSON.parse(b))); }));
(async () => {
  const ps = await get("/patients"), rr = await get("/referenceRanges?analyte=glucose"), o = await get("/orders?status=pending");
  console.log("json-server 0.16.3:", ps.length, "patients", ps.map(p => p.documentId).join(" "), "|", rr.length, "glucose ranges, v2 from", rr[1].effectiveFrom, "|", o.length, "pending order", o[0].createdAt);
})();'
