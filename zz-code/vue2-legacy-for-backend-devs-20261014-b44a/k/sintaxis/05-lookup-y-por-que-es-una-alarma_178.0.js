// FORMA 1 — N+1 (el pecado): una consulta por ticket
const tickets = await db.collection("tickets")
  .find({ status: "open" }).limit(20).toArray();
for (const t of tickets) {
  t.reporterInfo = await db.collection("users")
    .findOne({ username: t.reporter });          // 20 viajes 😬
}

// FORMA 2 — batch con $in (el clásico honesto de la época)
const usernames = [...new Set(tickets.map(t => t.reporter))];
const users = await db.collection("users")
  .find({ username: { $in: usernames } }).toArray();
const byName = new Map(users.map(u => [u.username, u]));
tickets.forEach(t => { t.reporterInfo = byName.get(t.reporter); });
// 2 viajes, join en memoria de la app

// FORMA 3 — $lookup (el join del motor)
const result = await db.collection("tickets").aggregate([
  { $match: { status: "open" } }, { $limit: 20 },
  { $lookup: { from: "users", localField: "reporter",
               foreignField: "username", as: "reporterInfo" } }
]).toArray();
// 1 viaje, join en el server