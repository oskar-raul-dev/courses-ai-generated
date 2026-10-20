// Solo indexa tickets CON assignee: la "cola de trabajo por agente"
db.tickets.createIndex(
  { assignee: 1, status: 1 },
  { partialFilterExpression: { assignee: { $type: "string" } } }
)
// más chico, más barato de mantener, y resuelve el unique-con-nulls.
// ⚠️ `email` NO está en la fixture del contrato (users trae username/name/role):
// lo agregas tú para este ejercicio de unique parcial.
db.users.createIndex({ email: 1 },
  { unique: true, partialFilterExpression: { email: { $exists: true } } })