// src/middleware/authorize.js
function requireRole(role) {
  return function (req, res, next) {
    if (req.user.role !== role) return res.status(403).json({ error: "Prohibido" });
    next();
  };
}

module.exports = { requireRole };
