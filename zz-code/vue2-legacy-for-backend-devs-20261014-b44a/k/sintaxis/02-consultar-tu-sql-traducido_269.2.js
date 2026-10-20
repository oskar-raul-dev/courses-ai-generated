var __o = {
db.tickets.updateOne({ title: "La impresora no imprime" }, { $set: { tags: ["hardware", "urgente"] } })

db.tickets.find({ tags: "hardware" })
// ✅ matchea si el array CONTIENE "hardware". Sin unnest, sin tabla puente.
};