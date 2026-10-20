var __a = [
db.tickets.aggregate([
  { $match: { status: "open" } },      // 1. filtra (tu WHERE — va PRIMERO)
  { $lookup: { ... } },                // 2. une (el invitado de honor)
  { $unwind: "$someArray" },            // 3. desanida un array (opcional)
  { $project: { title: 1, x: 1 } }     // 4. proyecta (tu SELECT)
])
];