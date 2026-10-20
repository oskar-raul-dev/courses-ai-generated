show dbs                 // tus bases (tiquetera aún no existe)
use tiquetera             // "cámbiate" a ella (aún no existe: no importa)
db.tickets.insertOne({ title: "hola mundo", status: "open" })
show dbs                 // ahora sí existe
db.tickets.find()
db.tickets.drop()        // limpia el experimento