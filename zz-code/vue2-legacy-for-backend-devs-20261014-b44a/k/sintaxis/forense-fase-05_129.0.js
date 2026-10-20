{ $lookup: {
    from: "comments",
    let: { tid: "$_id" },
    pipeline: [
      { $match: { $expr: { $eq: ["$ticketId", "$$tid"] } } },
      { $sort: { createdAt: -1 } },      // ⚠️ por CADA ticket
      { $limit: 3 }
    ],
    as: "lastComments" } }