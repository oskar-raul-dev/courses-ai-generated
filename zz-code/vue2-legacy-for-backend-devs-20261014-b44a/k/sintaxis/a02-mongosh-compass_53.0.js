// 1. Es JavaScript. Guarda cosas en variables.
const t = db.tickets.findOne({ status: "open" });
t.title                                  // navega el objeto
Object.keys(t)                           // ¿qué campos tiene REALMENTE?

// 2. Los cursores son iterables: mapea, filtra, reduce
db.tickets.find({ status: "open" }).toArray()
  .map(x => x.priority)
  .reduce((acc, p) => (acc[p] = (acc[p] || 0) + 1, acc), {})
// ⬆️ un GROUP BY en el cliente, en una línea, sin aggregation

// 3. Bucles: la reparación quirúrgica
db.tickets.find({ createdAt: { $type: "string" } }).forEach(function (doc) {
  db.tickets.updateOne({ _id: doc._id },
    { $set: { createdAt: new Date(doc.createdAt) } });
});
// ⬆️ la migración de la Fase 4, en el shell, para 200 documentos
// (para 200.000: script con driver y lotes — F4 ej. 28)

// 4. Funciones propias: tu librería de auditoría
function formas(col, n) {
  const campos = {};
  db[col].find().limit(n || 1000).forEach(d =>
    Object.keys(d).forEach(k => campos[k] = (campos[k] || 0) + 1));
  return campos;                          // campo → cuántos docs lo tienen
}
formas("tickets")                         // ⬅️ detector de drift en 5 líneas