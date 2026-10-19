// Verificación P7: compra en efectivo pendiente sobre json-server 0.16.3 + Express 4.17.1.
// La ruta de Express decide el estado; json-server guarda la compra.
const jsonServer = require("json-server");
const server = jsonServer.create();
const router = jsonServer.router(require("./db.json"));
const DEMORA_MS = Number(process.env.DEMORA_MS || 3000);
const confirmadas = {};
server.use(jsonServer.bodyParser);
server.get("/purchases/:token", (req, res, next) => {
  const t = req.params.token;
  const primera = confirmadas[t] === undefined;
  if (primera) confirmadas[t] = Date.now();
  // Efectivo (Efecty/OXXO): pendiente hasta que pasa la demora.
  const estado = Date.now() - confirmadas[t] >= DEMORA_MS ? "confirmed" : "pending";
  res.status(200).json({ purchaseToken: t, state: estado });
});
server.use(router);
server.listen(3002, () => console.log("mock google play en 3002, demora", DEMORA_MS, "ms"));
