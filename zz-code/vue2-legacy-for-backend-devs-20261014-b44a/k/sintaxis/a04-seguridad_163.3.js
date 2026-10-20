var __a = [
const rateLimit = require("express-rate-limit");

// El login: el objetivo #1 de la fuerza bruta
app.use("/auth/login", rateLimit({
  windowMs: 15 * 60 * 1000, max: 10,          // 10 intentos / 15 min / IP
  message: { error: "Demasiados intentos" }
}));
// Uploads y API general: límites distintos, política escrita
app.use("/attachments", rateLimit({ windowMs: 60000, max: 20 }));
app.use(rateLimit({ windowMs: 60000, max: 300 }));
];