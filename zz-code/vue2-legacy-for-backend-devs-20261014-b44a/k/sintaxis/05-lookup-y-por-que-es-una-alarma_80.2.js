var __o = {
db.tickets.aggregate([
  { $match: { status: "open" } },
  { $lookup: {
      from: "comments",            // colección derecha
      localField: "_id",           // campo aquí
      foreignField: "ticketId",    // campo allá
      as: "comments"               // ⬅️ y AQUÍ la primera diferencia grande
  } }
])
};