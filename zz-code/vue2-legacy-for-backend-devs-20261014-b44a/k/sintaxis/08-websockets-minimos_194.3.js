var __a = [
// Mini servidor de eventos. NO toca la base de datos:
// solo repite lo que un cliente anuncia hacia los demás. Un megáfono. 📣
var http = require("http");
var socketIo = require("socket.io");

var server = http.createServer();
var io = socketIo(server, {
  origins: "*:*" // CORS estilo socket.io 2.x (en 3.x/4.x cambió a `cors: {}`)
});

io.on("connection", function (socket) {
  console.log("🟢 cliente conectado:", socket.id);

  socket.on("ticket:created", function (ticket) {
    console.log("📨 ticket:created →", ticket.id, ticket.title);
    // a todos MENOS quien lo creó (él ya lo sabe: acaba de hacer el POST)
    socket.broadcast.emit("ticket:created", ticket);
  });

  socket.on("disconnect", function () {
    console.log("🔴 cliente desconectado:", socket.id);
  });
});

server.listen(4000, function () {
  console.log("Socket server escuchando en http://localhost:4000");
});
];