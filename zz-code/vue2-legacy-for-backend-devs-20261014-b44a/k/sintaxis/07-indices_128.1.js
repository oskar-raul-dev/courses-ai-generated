function __f(){
db.tickets.createIndex({ tags: 1 })              // multikey automático
db.tickets.find({ tags: "hardware" })            // IXSCAN 🎉

// Y sobre campos DE documentos DENTRO de arrays:
db.tickets.createIndex({ "history.by": 1 })
db.tickets.find({ "history.by": "lmcano" })    // "todo lo que tocó lmcano"
                                                  // — la consulta transversal de
                                                  // la Fase 3, ahora indexada
}