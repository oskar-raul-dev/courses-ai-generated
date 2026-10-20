var __o = {
db.tickets.aggregate([
  { $group: { _id: "$status", total: { $sum: 1 } } }   // $status = el VALOR
])
// [ { "_id":"closed", "total":58977 }, { "_id":"open", "total":17875 }, ... ]  (la base de scripts/generate.js)
};