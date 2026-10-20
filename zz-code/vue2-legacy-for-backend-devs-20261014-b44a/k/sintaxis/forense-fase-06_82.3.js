var __a = [
// sesión A y sesión B, casi a la vez
db.tickets.updateOne({ _id: id }, { $set: { assignee: "lmcano" } })
db.tickets.updateOne({ _id: id }, { $set: { assignee: "jpmesa" } })
];