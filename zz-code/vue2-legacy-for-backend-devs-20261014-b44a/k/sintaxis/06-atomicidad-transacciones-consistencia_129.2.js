var __o = {
// $[elem] + arrayFilters: actualizar SOLO ciertos elementos del array
db.tickets.updateOne(
  { _id: id },
  { $set: { "checklist.$[item].done": true } },
  { arrayFilters: [ { "item.name": "reiniciar" } ] }
)
};