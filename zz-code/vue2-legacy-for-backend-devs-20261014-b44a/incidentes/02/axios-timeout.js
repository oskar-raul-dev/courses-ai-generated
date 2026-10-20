// ¿El cliente se cuelga con CHAOS=timeout? Sin timeout espera para siempre; con 8000 rechaza.
var axios = require("/app/node_modules/axios");
function probar(nombre, opciones) {
  var inicio = Date.now(), estado = "pendiente";
  return new Promise(function (listo) {
    axios.create(opciones).get("/tickets")
      .then(function () { estado = "respondió"; })
      .catch(function (e) { estado = "error " + (e.code || e.message); })
      .finally(function () { console.log(nombre + ": " + estado + " a los " + ((Date.now() - inicio) / 1000).toFixed(1) + " s"); listo(); });
    setTimeout(function () { if (estado === "pendiente") { console.log(nombre + ": sigue pendiente a los 12 s"); listo(); } }, 12000);
  });
}
probar("sin timeout", { baseURL: "http://localhost:3000" })
  .then(function () { return probar("timeout 8000", { baseURL: "http://localhost:3000", timeout: 8000 }); })
  .then(function () { process.exit(0); });
