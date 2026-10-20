db.tickets.aggregate([
  { $group: { _id: "$assignee", reporters: { $addToSet: "$reporter" } } },
  { $project: { reporters: { $size: "$reporters" } } }
])
// $addToSet junta el conjunto; $size lo cuenta. Dos pasos honestos:
// el motor te muestra el costo que tu COUNT(DISTINCT) escondía. 