var __o = {
// CURA 1 — try/catch en CADA handler: correcta, explícita, insoportable
router.get("/:id", async function (req, res, next) {
  try {
    const ticket = await service.getById(req.params.id);
    res.json(ticket);
  } catch (err) {
    next(err);                     // ⬅️ la línea que salva el request
  }
});

// CURA 2 — el wrapper asyncHandler: LO QUE USÓ LA FASE 10
function asyncHandler(fn) {
  return function (req, res, next) {
    Promise.resolve(fn(req, res, next)).catch(next);   // ⬅️ toda la magia
  };
}
router.get("/:id", asyncHandler(async function (req, res) {
  res.json(await service.getById(req.params.id));      // sin try/catch: el wrapper lo hace
}));

// CURA 3 — el paquete express-async-errors (un require y ya)
require("express-async-errors");   // parchea Express por dentro. Cómodo y mágico.
};