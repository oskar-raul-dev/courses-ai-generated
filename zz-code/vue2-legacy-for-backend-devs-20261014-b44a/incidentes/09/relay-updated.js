// A emite ticket:updated; ¿le llega a B?
var io = require("/app/node_modules/socket.io-client");
var a = io("http://localhost:4000"), b = io("http://localhost:4000"), recibido = null, n = 0;
b.on("ticket:updated", function (t) { recibido = t; });
function listo() { if (++n === 2) a.emit("ticket:updated", { id: 12, status: "in_progress", assignee: "lmcano" }); }
a.on("connect", listo); b.on("connect", listo);
setTimeout(function () { console.log("B recibió ticket:updated:", JSON.stringify(recibido)); a.close(); b.close(); process.exit(0); }, 2500);
