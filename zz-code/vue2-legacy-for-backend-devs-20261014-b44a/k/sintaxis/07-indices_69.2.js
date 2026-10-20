var __o = {
db.tickets.createIndex({ status: 1, createdAt: -1 })   // compuesto, con dirección
db.tickets.getIndexes()                                  // inventario
db.tickets.dropIndex("status_1_createdAt_-1")           // por nombre
db.tickets.find({ status: "open" }).explain("executionStats")
};