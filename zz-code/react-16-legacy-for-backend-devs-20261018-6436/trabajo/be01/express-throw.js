// El contraste del track: un throw síncrono en un handler de Express 4.17.1.
const express = require("/app/node_modules/express");
const app = express();
app.get("/_boom", (req, res) => { const segments = ["esclusa-de-oro"]; res.json(segments[5].toUpperCase()); });
app.get("/health", (req, res) => res.json({ status: "ok" }));
const srv = app.listen(3013, async () => {
  const axios = require("/app/node_modules/axios");
  try { await axios.get("http://localhost:3013/_boom"); } catch (e) { console.log("express /_boom →", e.response.status, String(e.response.data).split("\n")[0].slice(0, 80)); }
  const h = await axios.get("http://localhost:3013/health"); console.log("express /health después →", h.status);
  srv.close();
});
