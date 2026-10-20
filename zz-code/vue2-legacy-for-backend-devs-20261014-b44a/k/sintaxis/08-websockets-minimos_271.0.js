

var SOCKET_URL = "http://localhost:4000";
var socket = null; // singleton a nivel de módulo

function connect() {
  if (socket) return; // idempotente: llamar dos veces no abre dos sockets
  socket = io(SOCKET_URL);
}

function disconnect() {
  if (!socket) return;
  socket.disconnect();
  socket = null;
}

function on(event, callback) {
  if (socket) socket.on(event, callback);
}

function off(event, callback) {
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