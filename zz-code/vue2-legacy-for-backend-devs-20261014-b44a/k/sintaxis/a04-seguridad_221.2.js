var __o = {
// Inyección NoSQL: nace en el query parser (objeto en req.query), no en Mongo
//   1. VALIDAR (lista blanca, enums del contrato) ← la buena
//   2. SANITIZAR (express-mongo-sanitize)         ← la red
//   3. CASTEAR (String(x)) en la frontera         ← el cinturón
//   + $where/mapReduce PROHIBIDOS (--noscripting) + escapar regex del ?q=

// JWT: verify SIEMPRE con { algorithms: ["HS256"] } · exp obligatorio
//   secreto largo, en .env, sin default en código · logout: decide y escríbelo
// bcrypt cost ≥10 · compare, nunca === · mismo coste si el usuario NO existe

// Autorización: autenticado ≠ autorizado sobre ESTE objeto (BOLA)
//   lista blanca de campos por rol (BOPLA) — nunca $set: req.body

// rate limit (login 10/15min) · trust proxy si hay proxy
// helmet: nosniff · frameguard · sin X-Powered-By
// uploads: MIME es sugerencia · Content-Disposition · limits · sanea nombres
// errores: 500 seco al cliente, stack al log · logs sin secretos
};