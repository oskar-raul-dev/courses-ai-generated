var __o = {
// El problema clásico: services necesita emitir, server crea el io,
// server importa routes que importan services... círculo. Solución de época:
// un módulo-singleton con init() y emit() — nadie importa al server.
let io = null;

function init(httpServer) {
  io = require("socket.io")(httpServer, {
    // El frontend corre en :8080 y el socket en :4000 → CORS del handshake
    origins: "*:*"        // sintaxis 2.x; se endurece en el ejercicio 14
  });

  io.on("connection", function (socket) {
    console.log("[io] cliente conectado:", socket.id);
    socket.on("disconnect", function (reason) {
      console.log("[io] desconectado:", socket.id, reason);
    });
  });
  return io;
}

function emit(event, payload) {
  if (!io) return;            // en tests o scripts sin realtime: no-op silencioso
  io.emit(event, payload);    // a TODOS los clientes conectados
}

module.exports = { init, emit };
};