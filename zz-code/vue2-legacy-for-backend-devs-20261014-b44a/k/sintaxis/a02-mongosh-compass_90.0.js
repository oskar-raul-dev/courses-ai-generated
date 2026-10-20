// Solo lo que importa (proyección, siempre)
db.tickets.find({}, { title: 1, status: 1, _id: 0 })

// Tabla en vez de JSON gigante
db.tickets.find().limit(5).toArray()
  .forEach(t => print(t.status.padEnd(12), t.priority.padEnd(8), t.title));

// Contar rápido sin traerte nada
db.tickets.countDocuments({ status: "open" })

// Cursores grandes: it (siguiente lote), o .itcount() para contar iterando
db.tickets.find()      // muestra 20 y ofrece "Type 'it' for more"