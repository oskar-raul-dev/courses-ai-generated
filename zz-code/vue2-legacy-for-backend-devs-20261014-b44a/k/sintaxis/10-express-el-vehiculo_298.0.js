// src/controllers/tickets.controller.js — list()
async function list(req, res, next) {
  try {
    const { items, total } = await service.list(req.query);
    res.set("X-Total-Count", String(total));   // la manía de json-server
    res.json(items.map(serializeTicket));      // el body sigue siendo array PLANO
  } catch (err) { next(err); }
}