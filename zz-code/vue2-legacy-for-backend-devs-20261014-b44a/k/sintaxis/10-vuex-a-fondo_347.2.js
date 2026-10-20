var __o = {
// services/socketService.js — versión de la Fase 10


var SOCKET_URL = "http://localhost:4000";
var socket = null; // singleton a nivel de módulo
var handlers = []; // [evento, callback]: se recuerdan aunque todavía no haya socket

function connect() {
  if (socket) return; // idempotente: llamar dos veces no abre dos sockets
  socket = io(SOCKET_URL);
  // lo registrado antes de conectar (el plugin de Vuex, al crear el store) se aplica aquí
  handlers.forEach(function (h) {
    socket.on(h[0], h[1]);
  });
}

function disconnect() {
  if (!socket) return;
  socket.disconnect();
  socket = null;
}

function on(event, callback) {
  handlers.push([event, callback]);
  if (socket) socket.on(event, callback);
}

function off(event, callback) {
  handlers = handlers.filter(function (h) {
    return h[0] !== event || h[1] !== callback;
  });
  if (socket) socket.off(event, callback);
}

function emit(event, payload) {
  if (socket) socket.emit(event, payload);
}

function isConnected() {
  return !!(socket && socket.connected);
}
module.exports = {
  connect: connect,
  disconnect: disconnect,
  on: on,
  off: off,
  emit: emit,
  isConnected: isConnected
};
};