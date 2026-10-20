// Middleware = (req, res, next). Se ejecutan EN ORDEN de registro.
// Salidas: responder · next() · next(err) · 💀 nada (request colgado)

// ⭐ EL BUG DE LA ÉPOCA: Express 4 NO atrapa promesas rechazadas
const asyncHandler = fn => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);
// alternativas: try/catch en cada handler · require("express-async-errors")
// Express 5 lo arregla — tu legacy es 4

// Error handler: 4 ARGUMENTOS (la aridad lo identifica) y SIEMPRE el último
(err, req, res, next) => ...   // 3 args = middleware normal = nunca ve errores

// Orden canónico:
//   logger → cors → json → helmet → routers → notFound → errorHandler

// req.query puede ser OBJETO (?a[$ne]=1) → inyección NoSQL (A4)
// req.user lo pone TU middleware, no Express
// sin express.json → req.body === undefined
// CORS: el preflight OPTIONS es el que falla, no tu PATCH