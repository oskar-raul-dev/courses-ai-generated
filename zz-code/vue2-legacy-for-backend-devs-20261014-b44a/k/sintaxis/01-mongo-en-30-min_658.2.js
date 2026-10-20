var __o = {
db.tickets.findOne()                                  // copia su _id
db.tickets.find({ _id: "<pega aquí el id como string>" }).count()   // 0
db.tikets.find().count()                              // 0, y la colección ni existe
};