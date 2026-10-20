// Qué ve axios (0.21.4, el de la consola) ante el pánico sin recover, y qué ve ante un 500.
const axios = require("/app/node_modules/axios");
(async () => {
  for (const url of ["http://go:3012/_boom", "http://go:3011/_chaos-no-existe"]) {
    try { const r = await axios.get(url); console.log(url, "→", r.status); }
    catch (e) {
      console.log(url, "→ message:", e.message, "| code:", e.code, "| response:", e.response ? `${e.response.status} x-request-id=${e.response.headers["x-request-id"]}` : "undefined");
    }
  }
})();
