var __o = {
db.tickets.aggregate([
  { $group: { _id: "$status", total: { $sum: 1 } } }
])

db.tickets.aggregate([
  { $group: {
      _id: { status: "$status", priority: "$priority" },
      total: { $sum: 1 },
      last: { $max: "$createdAt" }
  } },
  // cosmética para que salga plano como tu SELECT:
  { $project: { _id: 0, status: "$_id.status", priority: "$_id.priority",
                total: 1, last: 1 } }
])
};