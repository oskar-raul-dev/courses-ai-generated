var __o = {
// src/controllers/tickets.controller.js (extracto)
const service = require("../services/tickets.service");
const { serializeTicket } = require("../lib/serializers");
const { toObjectId } = require("../lib/objectId");

async function list(req, res, next) {
  try {
    const docs = await service.list(req.query);
    res.json(docs.map(serializeTicket));        // array PLANO, sin envelope
  } catch (err) { next(err); }
}

async function getById(req, res, next) {
  try {
    const oid = toObjectId(req.params.id);
    const doc = oid && await service.getById(oid);
    if (!doc) return res.status(404).json({});  // el 404 REAL que el frontend espera
    res.json(serializeTicket(doc));
  } catch (err) { next(err); }
}

async function create(req, res, next) {
  try {
    const doc = await service.create(req.body); // valida, sella createdAt/history
    res.status(201).json(serializeTicket(doc)); // 201 + el ticket CON id
  } catch (err) { next(err); }
}

async function patch(req, res, next) {
  try {
    const oid = toObjectId(req.params.id);
    if (!oid) return res.status(404).json({});
    const result = await service.patch(oid, req.body);
    if (result.conflict) return res.status(409)          // la EXTENSIÓN pactada:
      .json({ error: "El ticket ya fue tomado" });       // el doble "tomar" (F6)
    if (!result.doc) return res.status(404).json({});
    res.json(serializeTicket(result.doc));               // el ticket COMPLETO actualizado
  } catch (err) { next(err); }
}

async function remove(req, res, next) {
  try {
    const oid = toObjectId(req.params.id);
    if (oid) await service.remove(oid);
    res.json({});                               // {} con 200: la manía, imitada
  } catch (err) { next(err); }
}
};