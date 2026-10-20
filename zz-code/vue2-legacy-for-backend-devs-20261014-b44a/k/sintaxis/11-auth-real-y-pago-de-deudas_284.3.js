var __a = [
// src/middleware/authorize.js
function requireRole(role) {
  return function (req, res, next) {
    if (req.user.role !== role) return res.status(403).json({ error: "Prohibido" });
    next();
  };
}
// En las rutas: solo agentes toman/transicionan/comentan-como-agente
router.patch("/:id", authenticate, requireRole("agent"), ctrl.patch);
];