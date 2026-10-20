db.tickets.find({ createdAt: { $gte: ISODate("2020-01-01") } })
db.tickets.find({ createdAt: {
  $gte: ISODate("2020-01-01"),
  $lte: ISODate("2020-06-30")     // BETWEEN = dos operadores en el mismo campo
} })
db.tickets.find({ priority: { $ne: "low" } })   // ⚠️ trampa abajo: $ne y ausentes