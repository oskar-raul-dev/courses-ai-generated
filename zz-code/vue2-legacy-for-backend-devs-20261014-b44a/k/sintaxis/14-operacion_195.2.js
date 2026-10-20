var __o = {
db.setProfilingLevel(1, { slowms: 50 })   // nivel 1: solo lentas; 2: TODO (solo para cazar)
db.getProfilingStatus()

// system.profile es una colección capped: consúltala como cualquier otra
db.system.profile.find({ millis: { $gt: 50 } })
  .sort({ ts: -1 }).limit(5)

// El top de dolor por forma de query (¡tu vieja consulta al AWR, en MQL!):
db.system.profile.aggregate([
  { $group: { _id: { op: "$op", ns: "$ns",
                     plan: "$planSummary" },          // COLLSCAN = la pista
              total: { $sum: "$millis" }, n: { $sum: 1 },
              avg: { $avg: "$millis" } } },
  { $sort: { total: -1 } }, { $limit: 10 }
])
};