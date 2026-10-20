db.tickets.find({ title: { $regex: /impresora/i } })
db.tickets.find({ title: { $regex: /^La/ } })