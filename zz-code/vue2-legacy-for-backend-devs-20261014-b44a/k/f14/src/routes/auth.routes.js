// [unión de V7]
const router = require("express").Router();
const bcrypt = require("bcryptjs");
const User = require("../models/User");
const { sign } = require("../lib/auth");
const { serializeUser } = require("../lib/serializers");
// POST /auth/login — LA ruptura pactada (única, anunciada, firmada)
async function login(req, res, next) {
  try {
    const { username, password } = req.body;
    // ⚠️ primero los TIPOS: sin esta línea, el login de abajo es inyectable (ver abajo)
    if (typeof username !== "string" || typeof password !== "string") {
      return res.status(400).json({ error: "username y password son texto" });
    }
    const user = await User.findOne({ username });
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      return res.status(401).json({ error: "Credenciales inválidas" });
      // mismo mensaje para "no existe" y "clave mala": no filtres cuál falló
    }
    res.json({ token: sign(user), user: serializeUser(user) });
  } catch (err) { next(err); }
}

router.post("/login", login);
module.exports = router;
