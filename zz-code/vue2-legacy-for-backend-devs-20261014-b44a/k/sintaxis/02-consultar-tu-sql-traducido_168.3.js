var __a = [
db.tickets.countDocuments({ status: "open" })
db.tickets.distinct("assignee")
];