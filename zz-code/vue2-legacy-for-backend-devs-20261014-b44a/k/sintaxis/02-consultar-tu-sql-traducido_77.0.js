// MongoDB
db.tickets.find()
db.tickets.find({ status: "open" })
db.tickets.find({ status: "open" }, { title: 1, priority: 1 })
db.tickets.find({ status: "open", priority: "high" })   // AND implícito