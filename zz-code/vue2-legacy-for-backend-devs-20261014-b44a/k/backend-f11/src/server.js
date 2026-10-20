// src/server.js
const app = require("./app");
const { connect } = require("./db");
const config = require("./config");
const mongoose = require("mongoose");

Promise.all([connect(), mongoose.connect(config.mongoUri, { dbName: config.dbName, useNewUrlParser: true, useUnifiedTopology: true }) /* [K6: dbName como opción; MONGO_URL puede traer la base] */]).then(function () {
  app.listen(config.port, function () {
    console.log("Tiquetera backend en :" + config.port);
  });
});
