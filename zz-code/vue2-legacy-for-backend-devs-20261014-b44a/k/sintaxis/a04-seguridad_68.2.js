var __o = {
// DEFENSA 1 — VALIDAR (la buena): lista blanca, tipos, enums del contrato
// Con ajv (los schemas de la F4) o express-validator:
const { query } = require("express-validator");
router.get("/",
  query("status").optional().isIn(["open","in_progress","resolved","closed"]),
  query("q").optional().isString().isLength({ max: 100 }),
  query("_sort").optional().isIn(["createdAt","priority","status","title"]),
  handleValidation,
  controller.list
);
// ⬆️ Un objeto {$ne:...} NO es "open". Rechazado antes de tocar Mongo.
// Esta defensa no "escapa" nada: define lo permitido. Es la correcta.

// DEFENSA 2 — SANITIZAR (la red): quitar lo peligroso por si algo se coló
app.use(require("express-mongo-sanitize")());   // elimina claves con $ y puntos
// Útil como defensa en profundidad. NO sustituye a validar: un $ eliminado
// sigue siendo input que nunca debió llegar.

// DEFENSA 3 — CASTEAR EXPLÍCITAMENTE en la frontera (F10: ya lo hacías)
const status = String(req.query.status || "");   // un objeto se vuelve "[object Object]"
// Feo, efectivo, y gratis. El casteo defensivo del que no confía en nadie.
};