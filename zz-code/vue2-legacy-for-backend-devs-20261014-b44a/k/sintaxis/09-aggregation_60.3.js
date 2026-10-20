var __a = [
db.tickets.aggregate([
  { $match: { status: { $ne: "closed" } } },   // WHERE   (filtra ANTES)
  { $group: {
      _id: "$priority",                         // GROUP BY priority
      total: { $sum: 1 },                       // COUNT(*)
      avgTouch: { $avg: "$touchCount" }         // AVG(touch_count)
  } },
  { $match: { total: { $gte: 5 } } },           // HAVING  (¡es otro $match!)
  { $sort: { total: -1 } }                      // ORDER BY
])
];