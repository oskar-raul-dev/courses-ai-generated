// src/lib/serializers.js — el timeline que el frontend espera, desde history
// El frontend pide "activity"; nosotros tenemos "history". La frontera traduce,
// como traduce _id → id. No cambiamos el modelo para acomodar un nombre.
function serializeActivity(ticket) {
  return (ticket.history || []).map(function (entry, i) {
    return {
      // el frontend solo lo usa como :key de lista; un id derivado y estable
      // es más honesto que un Date.now() (que era su 💸)
      id: ticket._id.toHexString() + "-" + i,
      ticketId: ticket._id.toHexString(),
      type: entry.to === "open" && entry.from ? "reopened" : "status_change",
      actor: entry.by,
      from: entry.from,
      to: entry.to,
      at: entry.at.toISOString()
    };
  });
}