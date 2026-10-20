var STATUS_MAP = { 1: "open", 2: "in_progress", 3: "resolved", 4: "closed" }; // [K6: definido aparte en el script real]
// scripts/fix-08-status.js — idempotente: usa el origen como verdad
db.getSiblingDB("soporte_v1").tickets.find({}, { statusId: 1 })
  .forEach(function (src) {
    db.tickets.updateOne(
      { legacyId: src._id },
      { $set: { status: STATUS_MAP[src.statusId] } }    // mapa por CLAVE, no por índice
    );
  });
