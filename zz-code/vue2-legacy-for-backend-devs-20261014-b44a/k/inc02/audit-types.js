// scripts/audit-types.js — un conteo por campo sospechoso
["createdAt", "priority", "status", "assignee"].forEach(function (field) {
  var types = db.tickets.aggregate([
    { $group: { _id: { $type: "$" + field }, n: { $sum: 1 } } }
  ]).toArray();
  print(field + ": " + JSON.stringify(types));
});
