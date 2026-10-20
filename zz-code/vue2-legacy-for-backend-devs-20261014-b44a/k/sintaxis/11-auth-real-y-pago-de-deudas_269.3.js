var __a = [
// ANTES (F10, paridad con el mock): reporter salía del body. Cualquiera reportaba como cualquiera.
// AHORA: el reporter es QUIÉN ESTÁS AUTENTICADO SIENDO.
async function create(req, res, next) {
  const ticket = await service.create({
    ...whitelist(req.body, ["title", "description", "priority"]),
    reporter: req.user.sub,       // ⬅️ del token, no del body. Innegociable.
    status: "open", createdAt: new Date(), history: []
  });
  res.status(201).json(serializeTicket(ticket));
}
];