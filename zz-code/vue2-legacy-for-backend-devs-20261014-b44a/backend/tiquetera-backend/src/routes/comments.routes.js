// [unión de V7]
const router = require("express").Router();
const { getDb } = require("../db");
const { serializeComment } = require("../lib/serializers");
const { toObjectId } = require("../lib/objectId");
const authenticate = require("../middleware/authenticate");
router.get("/", async function (req, res, next) {
  try {
    const filter = {};
    if (req.query.ticketId) { const oid = toObjectId(req.query.ticketId); if (!oid) return res.json([]); filter.ticketId = oid; }
    const sortField = req.query._sort || "id";
    const sort = { [sortField === "id" ? "_id" : sortField]: req.query._order === "desc" ? -1 : 1 };
    const docs = await getDb().collection("comments").find(filter).sort(sort).toArray();
    res.json(docs.map(serializeComment));
  } catch (err) { next(err); }
});
router.post("/", authenticate, async function (req, res, next) {
  try {
    const oid = toObjectId(req.body.ticketId);
    // el autor sale del token, como el reporter de los tickets (F11); el del body se ignora
    const doc = { ticketId: oid, author: req.user.sub, body: req.body.body, createdAt: new Date(req.body.createdAt || Date.now()) };
    const r = await getDb().collection("comments").insertOne(doc);
    res.status(201).json(serializeComment(Object.assign({ _id: r.insertedId }, doc)));
  } catch (err) { next(err); }
});
module.exports = router;
