var __a = [
db.tickets.aggregate([{ $group: { _id: "status",  total: { $sum: 1 } } }])
db.tickets.aggregate([{ $group: { _id: "$status", total: { $sum: 1 } } }])
];