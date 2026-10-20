function __f(){
// src/middleware/errorHandler.js — SIEMPRE el último app.use, SIEMPRE 4 argumentos
// (Express identifica el handler de errores por la ARIDAD: 4 args = error handler.
//  Si escribes 3, es un middleware normal y nunca verá un error. Bug clásico.)
function errorHandler(err, req, res, next) {
  // Errores esperados: los que TÚ lanzaste con intención
  if (err.status) {
    return res.status(err.status).json({ error: err.message });
  }
  // Errores del motor que sabes traducir (F4: el validator)
  if (err.code === 121) {
    return res.status(422).json({ error: "Documento inválido" });
  }
  // Lo inesperado: 500 seco, log completo, CERO detalles al cliente
  console.error(err);                                  // el stack, a TU log
  res.status(500).json({ error: "Internal server error" });   // nada al atacante
}
}