var __a = [
db.tickets.insertOne({ title: "Z", priority: 3 })        // ¿priority numérico? claro que sí
db.tickets.find({ priority: "3" })                        // ✗ no lo encuentra
db.tickets.find({ priority: 3 })                          // ✅
];