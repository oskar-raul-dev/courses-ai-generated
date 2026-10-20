var __o = {
// lib/tickets.js — la primitiva que la Fase 10 montará en el PATCH
async function takeTicket(db, ticketId, agentUsername) {
  const result = await db.collection("tickets").findOneAndUpdate(
    {
      _id: new ObjectId(ticketId),
      assignee: null,                   // ⬅️ LA PRECONDICIÓN: solo si está libre…
      status: "open"                    // …y solo desde 'open' (tomar = empezar)
    },
    {
      $set:  { assignee: agentUsername, status: "in_progress",
               updatedAt: new Date() },
      $push: { history: { from: "open", to: "in_progress",
                          by: agentUsername, at: new Date() } }
    },
    { returnOriginal: false }
  );

  if (result.value === null) {
    // Nadie cumplía "libre Y open": o no existe, o ALGUIEN LO TOMÓ PRIMERO,
    // o ya no está en 'open' (resuelto/cerrado/reabierto por otro).
    // La Fase 10 traduce esto a HTTP: 404 o 409 (extensión pactada).
    const exists = await db.collection("tickets")
      .countDocuments({ _id: new ObjectId(ticketId) });
    return { ok: false, reason: exists ? "conflict" : "not_found" };
  }
  return { ok: true, ticket: result.value };
}
};