// 1 ticket + 2 lookup-tables + 2 usuarios + comentarios + autores de comentarios
const t   = db.tickets.findOne({ _id: id });
const st  = db.statuses.findOne({ _id: t.statusId });
const pri = db.priorities.findOne({ _id: t.priorityId });
const asg = db.users.findOne({ _id: t.assigneeId });
const rep = db.users.findOne({ _id: t.reporterId });
const com = db.comments.find({ ticketId: id }).toArray();
// ...y un viaje más POR CADA autor de comentario distinto. Hola, N+1.