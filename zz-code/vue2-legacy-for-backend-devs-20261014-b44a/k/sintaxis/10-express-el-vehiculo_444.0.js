// src/server.js
const app = require("./app");
const { connect } = require("./db");
const config = require("./config");

connect().then(function () {
  app.listen(config.port, function () {
    console.log("Tiquetera backend en :" + config.port);
  });
});