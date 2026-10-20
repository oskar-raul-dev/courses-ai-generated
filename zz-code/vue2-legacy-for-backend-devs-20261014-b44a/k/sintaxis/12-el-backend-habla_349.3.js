var __a = [
// src/routes/attachments.routes.js
const router = require("express").Router();
const multer = require("multer");
const upload = multer({
  storage: multer.memoryStorage(),                 // el buffer va directo a GridFS
  limits: { fileSize: 10 * 1024 * 1024 }           // 10 MB: límite DECLARADO
});
const controller = require("../controllers/attachments.controller");
const requireAuth = require("../middleware/authenticate");   // el guard de la Fase 11

router.post("/", requireAuth, upload.single("file"), controller.upload);
router.get("/:id", controller.download);
module.exports = router;
];