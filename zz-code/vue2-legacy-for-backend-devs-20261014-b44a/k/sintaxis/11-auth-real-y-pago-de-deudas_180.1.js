function __f(){
// src/middleware/authenticate.js — el guard REAL (vs el teatro heredado)
const { verify } = require("../lib/auth");

module.exports = function authenticate(req, res, next) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: "Token ausente" });
  try {
    req.user = verify(token);   // { sub, role, name } — la fuente de verdad del backend
    next();
  } catch (err) {
    return res.status(401).json({ error: "Token inválido o expirado" });
  }
};
}