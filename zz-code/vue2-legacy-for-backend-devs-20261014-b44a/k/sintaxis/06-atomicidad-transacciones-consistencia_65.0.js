// TODO esto ocurre o no ocurre — nadie ve el estado intermedio:
db.tickets.updateOne(
  { _id: id },
  {
    $set:  { status: "in_progress", updatedAt: new Date() },
    $push: { history: { from: "open", to: "in_progress",
                        by: "lmcano", at: new Date() } },
    $inc:  { touchCount: 1 }
  }
)