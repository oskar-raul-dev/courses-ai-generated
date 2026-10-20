var __o = {
// Traduce la forma cruda del pipeline a la forma que el frontend YA consume.
// Vive junto a serializeTicket porque es exactamente el mismo trabajo:
// decidir qué sale y con qué forma.
function serializeStats(raw) {
  const done = raw.resolved[0] || { total: 0, done: 0 };

  return {
    // objeto indexado por estado: reemplaza countByStatus() del cliente
    byStatus: raw.byStatus.reduce(function (acc, row) {
      acc[row.status] = row.count;
      return acc;
    }, {}),

    // misma forma y mismo orden que activeByAgent() del cliente
    activeByAgent: raw.activeByAgent,

    // Math.round, igual que el cliente (ver el comentario del pipeline)
    resolvedPercent: done.total === 0
      ? 0
      : Math.round((done.done / done.total) * 100),

    // --- de aquí abajo, extensiones que el cliente no calculaba ---
    byPriority: raw.byPriority.reduce(function (acc, row) {
      acc[row.priority] = row.count;
      return acc;
    }, {}),
    byAgent: raw.byAgent,
    resolution: raw.resolution[0] || null
  };
}
};