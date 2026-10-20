var __a = [
// src/services/tickets.service.js — list(), versión paginada
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
];