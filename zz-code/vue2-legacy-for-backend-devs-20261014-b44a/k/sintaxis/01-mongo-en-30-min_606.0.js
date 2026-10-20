// Levantar / entrar
docker compose up -d
mongosh mongodb://localhost:27017/tiquetera

// Supervivencia en mongosh
show dbs; use tiquetera; show collections
db.tickets.find()                        // SELECT *
db.tickets.findOne({ status: "open" })   // TOP 1 con WHERE
db.tickets.countDocuments()              // COUNT(*)
db.tickets.drop()                        // DROP TABLE

// Los 3 hechos que debes recordar
// 1. _id: ObjectId, generado en el cliente, sin secuencia, sin contención.
// 2. Base y colección nacen al primer insert. Los typos también.
// 3. Las referencias son convención tuya. El motor no valida nada.