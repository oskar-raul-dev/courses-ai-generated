var __a = [
db.tickets.aggregate([
  { $group: { _id: "status", total: { $sum: 1 } } }
])
// salida real:
// [ { "_id" : "status", "total" : 100000 } ]
];