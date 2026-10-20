// [unión de V7]
const router = require("express").Router();
const { getDb } = require("../db");
const { computeStats, serializeStats } = require("../lib/stats");
router.get("/", async function (req, res, next) {
  try { res.json(serializeStats(await computeStats(getDb()))); } catch (err) { next(err); }
});
module.exports = router;
