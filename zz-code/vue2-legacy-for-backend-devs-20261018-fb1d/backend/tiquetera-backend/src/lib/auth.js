// src/lib/auth.js
const jwt = require("jsonwebtoken");
const config = require("../config");

function sign(user) {
  return jwt.sign(
    { sub: user.username, role: user.role, name: user.name },  // claims
    config.jwtSecret,                                          // el secreto (env!)
    { expiresIn: "8h" }   // 8h para el curso; en el ej. 22 lo bajas a 30s para ver el 401
  );
}

function verify(token) {
  return jwt.verify(token, config.jwtSecret);  // lanza si firma inválida o expiró
}

module.exports = { sign, verify };
