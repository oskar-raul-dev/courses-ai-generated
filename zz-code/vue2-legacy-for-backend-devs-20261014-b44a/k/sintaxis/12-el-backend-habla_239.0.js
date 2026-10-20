const http = require("http");
const app = require("./app");            // el Express de la Fase 10
const realtime = require("./realtime/io");

// Puerta 1: la API donde siempre (:3000)
app.listen(3000, function () { console.log("API en :3000"); });

// Puerta 2: los sockets donde el cliente ya escucha (:4000)
const socketServer = http.createServer();   // http pelado: solo transporta al io
realtime.init(socketServer);
socketServer.listen(4000, function () { console.log("Sockets en :4000"); });