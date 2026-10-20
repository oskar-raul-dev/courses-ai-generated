function __f(){
// ¿Qué agente hizo más transiciones? history está embebido (Fase 3):
db.tickets.aggregate([
  { $unwind: "$history" },                       // 1 doc por entrada de history
  { $group: { _id: "$history.by", moves: { $sum: 1 } } },
  { $sort: { moves: -1 } }
])
}