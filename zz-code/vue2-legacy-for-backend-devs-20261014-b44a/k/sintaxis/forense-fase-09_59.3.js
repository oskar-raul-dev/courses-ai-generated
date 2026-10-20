var __a = [
db.tickets.aggregate([
  { $group: { _id: "$status", total: { $sum: 1 } } }
])
// [ { "_id":"closed", "total":58977 }, { "_id":"open", "total":17875 }, … ]
];