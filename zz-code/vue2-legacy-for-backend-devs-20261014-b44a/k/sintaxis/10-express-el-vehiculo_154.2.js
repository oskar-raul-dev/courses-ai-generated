var __o = {
// La base habla Mongo (_id: ObjectId, Date). La API habla el contrato
// (id: string, fechas ISO). ESTA es la aduana — y es el único lugar
// del proyecto donde se permite esa conversación.

function serializeTicket(doc) {
  if (!doc) return null;
  return {
    id: doc._id.toHexString(),          // _id → id string (decisión firmada)
    title: doc.title,
    description: doc.description,
    status: doc.status,
    priority: doc.priority,
    assignee: doc.assignee,             // username o null, tal cual
    reporter: doc.reporter,
    createdAt: doc.createdAt.toISOString()   // Date → ISO (ida y vuelta F1 💸: pagada)
    // history NO se serializa: campo interno (decisión de la Fase 3).
    // updatedAt tampoco POR AHORA: el contrato no lo conoce; exponerlo
    // sería extensión — se decide en la Fase 11, no de contrabando.
  };
}

function serializeComment(doc) {
  if (!doc) return null;
  return {
    id: doc._id.toHexString(),
    ticketId: doc.ticketId.toHexString(),  // ref → string hex, igual que el ticket
    author: doc.author,                    // USERNAME (string), como el frontend pinta `c.author`
    body: doc.body,
    createdAt: doc.createdAt.toISOString()
    // OJO: el modelo sano usa `author` (username). El `authorId` numérico
    // es de soporte_v1, el modelo traducido — no cruza jamás la frontera del contrato.
  };
}
function serializeUser(doc)    { /* id, username, name, role */ }

module.exports = { serializeTicket, serializeComment, serializeUser };
};