// [unión de V7]
const router = require("express").Router();
const ctrl = require("../controllers/tickets.controller");
const authenticate = require("../middleware/authenticate");
const { requireRole } = require("../middleware/authorize");
router.get("/", ctrl.list);
router.get("/:id", ctrl.getById);
router.post("/", authenticate, ctrl.create);              // reporter = req.user.sub
router.patch("/:id", authenticate, requireRole("agent"), ctrl.patch);
router.delete("/:id", ctrl.remove);
module.exports = router;
