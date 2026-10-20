var __o = {
// Los tickets con SOLO sus comentarios recientes (condición extra en la unión)
db.tickets.aggregate([
  { $match: { status: "open" } },
  { $lookup: {
      from: "comments",
      let: { tid: "$_id" },                       // variables del lado izquierdo
      pipeline: [
        { $match: { $expr: { $eq: ["$ticketId", "$$tid"] } } },
        { $match: { createdAt: { $gte: new Date("2020-06-01") } } },
        { $sort: { createdAt: -1 } },
        { $limit: 3 }
      ],
      as: "recentComments"
  } }
])
};