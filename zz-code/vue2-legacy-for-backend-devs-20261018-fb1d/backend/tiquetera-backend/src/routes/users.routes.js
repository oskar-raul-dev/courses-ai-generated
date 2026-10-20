// [unión de V7]
const router = require("express").Router();
const { getDb } = require("../db");
const { serializeUser } = require("../lib/serializers");
router.get("/", async function (req, res, next) {
  try {
    const filter = {}; if (req.query.role) filter.role = req.query.role;
    const docs = await getDb().collection("users").find(filter).sort({ _id: 1 }).toArray();
    res.json(docs.map(serializeUser));
  } catch (err) { next(err); }
});
module.exports = router;
