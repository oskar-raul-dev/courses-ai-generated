// src/server.js
const http = require("http");
const mongoose = require("mongoose");
const app = require("./app");            // el Express de la Fase 10
const { connect } = require("./db");
const config = require("./config");
const realtime = require("./realtime/io");

// las dos conexiones de la Fase 11, antes de abrir ninguna puerta
Promise.all([
  connect(),
  mongoose.connect(config.mongoUri, { dbName: config.dbName, useNewUrlParser: true, useUnifiedTopology: true })
]).then(function () {
  // Puerta 1: la API donde siempre (:3000)
  app.listen(config.port, function () { console.log("API en :" + config.port); });

  // Puerta 2: los sockets donde el cliente ya escucha (:4000)
  const socketServer = http.createServer();   // http pelado: solo transporta al io
  realtime.init(socketServer);
  socketServer.listen(4000, function () { console.log("Sockets en :4000"); });
});
