var __o = {
// en las dos, casi a la vez:
db.tickets.updateOne({ _id: id }, { $set: { assignee: "ana" } })
db.tickets.updateOne({ _id: id }, { $set: { assignee: "beto" } })
};