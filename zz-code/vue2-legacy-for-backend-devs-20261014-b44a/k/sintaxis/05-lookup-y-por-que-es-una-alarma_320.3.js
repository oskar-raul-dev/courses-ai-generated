var __a = [
// $lookup básico: LEFT JOIN que agrupa en array
{ $lookup: { from, localField, foreignField, as } }
// INNER simulado:  + { $match: { as: { $ne: [] } } }
// aplanar a filas: + { $unwind: { path: "$as", preserveNullAndEmptyArrays: true } }

// $lookup pipeline: el ON complejo / LATERAL
{ $lookup: { from, let: { v: "$campo" },
             pipeline: [ { $match: { $expr: { $eq: ["$x", "$$v"] } } }, ... ],
             as } }

// Las 3 uniones: N+1 (nunca) · batch $in (flexible, cachea) · $lookup (1 viaje)
// Regla: $match antes de $lookup · izquierda chica · derecha indexada (F7)

// La regla de oro:
//   nocturno/analítico → herramienta ✅
//   endpoint caliente  → síntoma 🚨 (el modelo no pagó la Fase 3)

// Denormalización adulta: 1 escritor · carrera nombrada (F6) ·
//   reconciliación nocturna · tolerancia con número
];