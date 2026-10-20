var __o = {
var ticket = await tickets.findOne({ _id: id });
if (ticket.assignee) {
  throw new ConflictError("El ticket ya está asignado");
}
await tickets.updateOne({ _id: id }, { $set: { assignee: user } });
};