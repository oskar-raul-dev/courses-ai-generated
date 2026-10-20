const app = require("../src/app");
const express = require("express");
const outer = express();
outer.get("/boom", async function (req, res) { throw new Error("sin captura"); });
outer.use(app);
outer.listen(3000);
