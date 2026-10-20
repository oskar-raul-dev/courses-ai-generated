const { getDb } = require("../db");

async function list(query) {
  // buildFilter y buildSort son el cuerpo de la list() anterior, extraído tal
  // cual a dos helpers: el filtro lo necesitan ahora DOS consultas (los datos
  // y el conteo), y duplicarlo es cómo se desincronizan.
  const filter = buildFilter(query);
  const sort = buildSort(query);

  const cursor = getDb().collection("tickets").find(filter).sort(sort);

  // Sin _page ni _limit el comportamiento es EXACTAMENTE el de antes: todo.
  // El tronco (F0–F11) nunca los manda, así que no le cambia nada.
  const limit = parseInt(query._limit, 10);
  const page = parseInt(query._page, 10) || 1;
  if (limit > 0) cursor.skip((page - 1) * limit).limit(limit);

  // countDocuments con el MISMO filtro y SIN paginar. Es el número de la
  // barra de paginación: cuántos hay que ver, no cuántos estoy devolviendo.
  const [items, total] = await Promise.all([
    cursor.toArray(),
    getDb().collection("tickets").countDocuments(filter)
  ]);

  return { items: items, total: total };
}

function buildFilter(query) {
  const filter = {};

  if (query.status) filter.status = query.status;      // ?status= (contratado)
  if (query.priority) filter.priority = query.priority; // ?priority= EXTENSIÓN:
  // no está en la tabla de dialecto del audit. json-server filtra por cualquier
  // campo, así que es fiel al dialecto; se declara como extensión inofensiva.
  // (El frontend heredado hoy filtra status/priority/búsqueda en cliente y solo
  //  manda ?_sort/?_order — ver Curso 01 · F4; esto es paridad con el mock, no algo
  //  que la UI ejerza aún.)

  if (query.q) {                                        // ?q= (alcance firmado)
    const rx = new RegExp(escapeRegex(query.q), "i");
    filter.$or = [{ title: rx }, { description: rx }];
  }

  return filter;
}

function buildSort(query) {
  const sortField = query._sort || "id";                // ?_sort= / ?_order=
  const sortDir = query._order === "desc" ? -1 : 1;     // (asc por defecto,
  return { [sortField === "id" ? "_id" : sortField]: sortDir };  // como json-server)

}

function escapeRegex(s) {                               // el ?q=".*" de un gracioso
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");      // no será tu COLLSCAN eterno
}

// [unión de V7: el resto del servicio no se publica en F10]
const { takeTicket } = require("../lib/tickets");
async function getById(oid) { return getDb().collection("tickets").findOne({ _id: oid }); }
const realtime = require("../realtime/io");
const { serializeTicket } = require("../lib/serializers");
async function create(body) {
  const doc = Object.assign({}, body, { createdAt: new Date(body.createdAt || Date.now()), history: [] });
  delete doc.id;
  const r = await getDb().collection("tickets").insertOne(doc);
  const saved = await getById(r.insertedId);
  realtime.emit("ticket:created", serializeTicket(saved));
  return saved;
}
const { changeStatus } = require("../lib/transitions");
async function patch(oid, body, byUser) {
  const changes = Object.assign({}, body); delete changes.id; delete changes._id;
  if (changes.createdAt) changes.createdAt = new Date(changes.createdAt);
  const current = await getById(oid);
  if (!current) return { doc: null };
  // tomar = asignar un ticket libre: la primitiva atómica de la Fase 6
  if (changes.assignee && current.assignee == null && changes.status === "in_progress") {
    const r = await takeTicket(getDb(), oid.toHexString(), changes.assignee);
    if (!r.ok) return r.reason === "conflict" ? { conflict: true } : { doc: null };
    return { doc: r.ticket };
  }
  // F11: un cambio de estado pasa por la máquina de estados, atribuido a quien está autenticado
  if (changes.status && changes.status !== current.status) {
    const t = await changeStatus(getDb(), oid, changes.status, byUser);
    if (t.notFound) return { doc: null };
    if (t.illegal || t.conflict) return t;
    delete changes.status;
    if (Object.keys(changes).length === 0) return { doc: t.ticket };
  }
  const r = await getDb().collection("tickets").findOneAndUpdate({ _id: oid }, { $set: changes }, { returnDocument: "after" });
  return { doc: r.value };
}
async function remove(oid) { await getDb().collection("tickets").deleteOne({ _id: oid }); }
// [V7: el refactor del ejercicio 8 de F13 — el service también se puede fabricar con su db]
function makeService(db) {
  return { takeTicket: function (id, user) { return takeTicket(db, id, user); } };
}
module.exports = Object.assign(makeService, { list, getById, create, patch, remove });
