var __o = {
// El listado del dashboard en soporte_v1: 20 tickets "legibles"
db.tickets.aggregate([
  { $sort: { createdAt: -1 } }, { $limit: 20 },
  { $lookup: { from: "statuses",   localField: "statusId",   foreignField: "_id", as: "status" } },
  { $lookup: { from: "priorities", localField: "priorityId", foreignField: "_id", as: "priority" } },
  { $lookup: { from: "users",      localField: "assigneeId", foreignField: "_id", as: "assignee" } },
  { $lookup: { from: "users",      localField: "reporterId", foreignField: "_id", as: "reporter" } },
  { $unwind: { path: "$status", preserveNullAndEmptyArrays: true } },
  { $unwind: { path: "$priority", preserveNullAndEmptyArrays: true } },
  { $unwind: { path: "$assignee", preserveNullAndEmptyArrays: true } },
  { $unwind: { path: "$reporter", preserveNullAndEmptyArrays: true } }
])
};