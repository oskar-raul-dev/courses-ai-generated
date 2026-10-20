var __o = {
// Camino 1: regex — el que ya usas desde la Fase 2
db.tickets.find({ $or: [ { title: /impresora/i }, { description: /impresora/i } ] })
// anclado (/^impre/) acota el índice; flotante o insensible: lo recorre entero
// (o COLLSCAN si no hay índice en title). Tu LIKE '%..%'.

// Camino 2: índice de texto (uno solo por colección)
db.tickets.createIndex({ title: "text", description: "text" },
                       { default_language: "spanish" })
db.tickets.find({ $text: { $search: "impresora" } })
};