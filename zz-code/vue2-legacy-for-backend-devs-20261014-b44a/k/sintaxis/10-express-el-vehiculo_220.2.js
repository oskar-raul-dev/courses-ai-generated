var __o = {
const { getDb } = require("../db");

async function list(query) {
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

  const sortField = query._sort || "id";                // ?_sort= / ?_order=
  const sortDir = query._order === "desc" ? -1 : 1;     // (asc por defecto,
  const sort = { [sortField === "id" ? "_id" : sortField]: sortDir };  // como json-server)

  return getDb().collection("tickets").find(filter).sort(sort).toArray();
}

function escapeRegex(s) {                               // el ?q=".*" de un gracioso
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");      // no será tu COLLSCAN eterno
}
};