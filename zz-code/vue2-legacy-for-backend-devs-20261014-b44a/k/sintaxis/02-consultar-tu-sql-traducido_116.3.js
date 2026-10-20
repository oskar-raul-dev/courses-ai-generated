var __a = [
db.tickets.find({ status: { $in: ["open", "in_progress"] } })
db.tickets.find({ $or: [ { status: "open" }, { priority: "high" } ] })
db.tickets.find({ status: { $not: { $eq: "closed" } } })   // o $ne directo
];