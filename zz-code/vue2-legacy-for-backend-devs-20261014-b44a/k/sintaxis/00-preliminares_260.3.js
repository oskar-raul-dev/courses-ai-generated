var __a = [
mongosh mongodb://localhost:27017

use playground

// Insertar UNA persona — mira el anidamiento sin dramatismo: es solo JSON
db.people.insertOne({
  name: "Ana",
  lastName: "García",
  age: 34,
  email: "ana@example.com",
  tags: ["ops", "backend"],
  address: { city: "Bogotá", country: "CO" }
})

// Insertar VARIAS
db.people.insertMany([
  { name: "Luis", lastName: "Pérez", age: 41, email: "luis@example.com",
    tags: ["dba"], address: { city: "Medellín", country: "CO" } },
  { name: "Marta", lastName: "Ruiz", age: 29, email: "marta@example.com",
    tags: ["frontend", "backend"], address: { city: "Quito", country: "EC" } },
  { name: "Iker", lastName: "Etxeberria", age: 52, email: "iker@example.com",
    tags: [], address: { city: "Bilbao", country: "ES" } }
])

// Leer (la Fase 2 convierte esto en un arsenal; hoy, lo mínimo vital)
db.people.find()                          // todo
db.people.find({ age: { $gte: 40 } })    // un WHERE de probadita
db.people.findOne({ name: "Ana" })      // el primero que matchee
db.people.countDocuments()                // COUNT(*)

// Actualizar y borrar (idem: probadita; lo serio en Fases 2 y 6)
db.people.updateOne({ name: "Ana" }, { $set: { age: 35 } })
db.people.deleteOne({ name: "Iker" })

// Inventario
show dbs
show collections
db.people.drop()        // cuando quieras empezar de cero
];