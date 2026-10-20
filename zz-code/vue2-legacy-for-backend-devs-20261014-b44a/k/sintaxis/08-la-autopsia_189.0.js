db.tickets.countDocuments()                        // igual que el origen ✅
db.tickets.countDocuments({ priority: { $exists: false } })   // ¿cuántos perdieron el campo?
db.tickets.countDocuments({ createdAt: { $type: "string" } }) // ¿cuántos cambiaron de tipo?