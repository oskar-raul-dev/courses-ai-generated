function __f(){
db.tickets.aggregate([
  { $group: {
      _id: "$assignee",
      open:   { $sum: { $cond: [{ $eq: ["$status", "open"] }, 1, 0] } },
      closed: { $sum: { $cond: [{ $eq: ["$status", "closed"] }, 1, 0] } }
  } }
])
// $cond ES tu CASE WHEN. La traducción más literal de toda la fase.
}