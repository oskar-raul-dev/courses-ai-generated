var __o = {
// mock/chaos.js
// Middleware de caos para json-server. Se activa con la variable de entorno
// CHAOS; sin ella no toca ni una respuesta.
//
// Uso:  CHAOS=malformed npm run mock

var CHAOS = process.env.CHAOS || "off";
var SLOW_MS = 4000;

module.exports = function (req, res, next) {
  // Sin caos, el middleware es transparente.
  if (CHAOS === "off") {
    return next();
  }

  // El navegador bloquea la respuesta porque le faltan las cabeceras de CORS.
  // json-server las pone por defecto; acá las quitamos justo antes de enviar.
  if (CHAOS === "cors") {
    var originalWriteHead = res.writeHead;
    res.writeHead = function () {
      res.removeHeader("Access-Control-Allow-Origin");
      return originalWriteHead.apply(res, arguments);
    };
    return next();
  }

  // El servidor recibe el request y no contesta nunca. Sin error, sin cierre.
  if (CHAOS === "timeout") {
    return; // a propósito: no se llama a next() ni se responde
  }

  // 200 en verde, cuerpo roto: JSON cortado a la mitad.
  if (CHAOS === "malformed" && req.method === "GET") {
    res.status(200);
    res.set("Content-Type", "application/json");
    return res.send('[{"id":1,"title":"La impresora no imp');
  }

  // El error honesto: el servidor admite que algo se rompió.
  if (CHAOS === "500" && req.method === "GET") {
    return res.status(500).json({ error: "Internal Server Error" });
  }

  // Contesta bien, pero tarde. Cuatro segundos son eternos en una pantalla.
  if (CHAOS === "slow") {
    return setTimeout(next, SLOW_MS);
  }

  // 200, JSON válido, y ni un dato adentro.
  if (CHAOS === "empty" && req.method === "GET") {
    return res.status(200).json([]);
  }

  return next();
};
};