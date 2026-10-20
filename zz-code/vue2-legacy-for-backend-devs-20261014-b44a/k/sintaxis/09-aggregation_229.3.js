var __a = [
// lib/stats.js — la función que la Fase 10 expondrá como GET /stats
async function computeStats(db) {
  const [result] = await db.collection("tickets").aggregate([
    { $facet: {
        byStatus: [
          { $group: { _id: "$status", count: { $sum: 1 } } },
          { $project: { _id: 0, status: "$_id", count: 1 } }
        ],
        byPriority: [
          { $group: { _id: "$priority", count: { $sum: 1 } } },
          { $project: { _id: 0, priority: "$_id", count: 1 } }
        ],
        // OJO: el frontend (Curso 01 · F7, activeByAgent) grafica SOLO carga
        // activa — open + in_progress. Reproducimos ESA métrica al pie de la
        // letra para que el dashboard muestre los mismos números al migrar.
        activeByAgent: [
          { $match: { status: { $in: ["open", "in_progress"] } } },
          // el cliente hace `t.assignee || "(sin asignar)"`: los tickets sin
          // asignar NO se descartan, se agrupan en un bucket propio. Si aquí
          // filtráramos por assignee, la dona perdería una porción entera.
          { $set: { agentKey: { $let: {
              vars: { a: { $ifNull: ["$assignee", ""] } },
              in: { $cond: [{ $eq: ["$$a", ""] }, "(sin asignar)", "$$a"] }
          } } } },
          { $group: { _id: "$agentKey", count: { $sum: 1 } } },
          { $sort: { count: -1 } },
          { $project: { _id: 0, agent: "$_id", count: 1 } }
        ],
        // total histórico por agente (todos los estados). No lo pinta el
        // cliente hoy; queda disponible como extensión del contrato. Acá sí
        // filtramos los sin asignar: es una métrica nueva y la definimos así.
        byAgent: [
          { $match: { assignee: { $type: "string" } } },
          { $group: { _id: "$assignee", count: { $sum: 1 } } },
          { $sort: { count: -1 } },
          { $project: { _id: 0, agent: "$_id", count: 1 } }
        ],
        // insumos de resolvedPercent. Devolvemos total y done EN CRUDO y
        // redondeamos en el serializer con Math.round, para dar el mismo
        // entero que el cliente: el $round de Mongo redondea al par más
        // cercano y Math.round redondea hacia arriba — en un 62.5% eso es
        // un punto de diferencia, y "la métrica migrada tiene que dar el
        // mismo número" no admite un punto de diferencia.
        resolved: [
          { $group: { _id: null,
              total: { $sum: 1 },
              done: { $sum: { $cond: [
                { $in: ["$status", ["resolved", "closed"]] }, 1, 0 ] } } } },
          { $project: { _id: 0 } }
        ],
        resolution: [
          // tiempo hasta resolved, calculado DESDE history (el premio analítico
          // de haberlo embebido): primera entrada cuyo "to" sea resolved
          { $unwind: "$history" },
          { $match: { "history.to": "resolved" } },
          { $group: { _id: "$_id", resolvedAt: { $min: "$history.at" },
                      createdAt: { $first: "$createdAt" } } },
          { $project: { hours: { $divide: [
              { $subtract: ["$resolvedAt", "$createdAt"] }, 3600000 ] } } },
          { $group: { _id: null, avgHours: { $avg: "$hours" },
                      maxHours: { $max: "$hours" }, tickets: { $sum: 1 } } },
          { $project: { _id: 0 } }
        ]
    } }
  ]).toArray();
  // forma cruda, natural para Mongo. La traducción al contrato es del serializer:
  // { byStatus:[…], byPriority:[…], activeByAgent:[…], byAgent:[…],
  //   resolved:[{total,done}], resolution:[{…}] }
  return result;
}
];