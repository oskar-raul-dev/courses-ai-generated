var __a = [
User.findOne({ username, password })
//   { username: "admin", password: { $ne: null } }
//   → "cualquier admin cuya password no sea null" → LOGIN SIN CONTRASEÑA 💀
];