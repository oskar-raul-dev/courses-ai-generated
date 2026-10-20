var __a = [
// La máquina de estados, server-side, sobre la primitiva atómica de la Fase 6.
const LEGAL = {
  open: ["in_progress"], in_progress: ["resolved", "open"],
  resolved: ["closed", "open"], closed: ["open"]
};

async function changeStatus(db, ticketId, to, byUser) {
  const ticket = await getById(ticketId);
  if (!ticket) return { notFound: true };
  if (!LEGAL[ticket.status].includes(to))
    return { illegal: true, from: ticket.status, to };
  // precondición en el filtro (F6): el estado no cambió bajo nuestros pies
  const result = await db.collection("tickets").findOneAndUpdate(
    { _id: ticketId, status: ticket.status },     // ⬅️ optimistic: status esperado
    { $set: { status: to, updatedAt: new Date() },
      $push: { history: { from: ticket.status, to, by: byUser, at: new Date() } } },
    { returnOriginal: false }
  );
  if (!result.value) return { conflict: true };   // alguien transicionó primero → 409
  return { ok: true, ticket: result.value };
}
];