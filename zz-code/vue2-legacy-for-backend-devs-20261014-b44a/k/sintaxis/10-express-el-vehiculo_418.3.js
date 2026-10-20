var __a = [
// src/app.js
const express = require("express");
const cors = require("cors");
const morgan = require("morgan");

const app = express();
app.use(cors());                    // el frontend vive en :8080 — sin esto, no hay magia
app.use(express.json());
app.use(morgan("dev"));

app.use("/tickets", require("./routes/tickets.routes"));
app.use("/users", require("./routes/users.routes"));
app.use("/comments", require("./routes/comments.routes"));
app.use("/stats", require("./routes/stats.routes"));   // extensión: nadie la pide aún

app.use(function (req, res) { res.status(404).json({}); });

app.use(function (err, req, res, next) {               // el safety net central
  console.error(err);
  res.status(500).json({ error: "Internal error" });   // el body de error es libre:
});                                                     // el frontend solo mira el status

module.exports = app;
];