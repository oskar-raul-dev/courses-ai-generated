var __a = [
const bcrypt = require("bcryptjs");

// En el seed de usuarios / registro:
const passwordHash = await bcrypt.hash(plainPassword, 10);  // 10 rounds, época-correcto

// En login:
const ok = await bcrypt.compare(plainPassword, user.passwordHash);
];