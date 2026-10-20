var __a = [
show dbs                                   // las bases
use tiquetera
show collections
db.getCollectionInfos()                    // ⬅️ incluye el VALIDATOR (F4)
db.tickets.getIndexes()                    // los índices
db.tickets.stats()                         // tamaño, storageSize, indexSizes
db.stats()                                 // la base entera
db.serverStatus()                          // el monstruo: conexiones, memoria, opcounters
db.serverStatus().connections              // ⬅️ pícalo por partes o te ahogas
db.tickets.distinct("status")              // el dominio REAL de un campo (F4)
db.version()
];