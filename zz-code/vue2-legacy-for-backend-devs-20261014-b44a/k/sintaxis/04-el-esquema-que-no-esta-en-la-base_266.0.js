// Censo de formas (Fase 2 al servicio de esta)
db.tickets.find({ updatedAt: { $exists: false } }).count()
db.tickets.find({ createdAt: { $type: "string" } })      // contaminación
db.tickets.distinct("schemaVersion")

// Validación
db.getCollectionInfos({ name: "tickets" })   // ver el validator vigente
db.runCommand({ collMod: "tickets", validator: {...},
                validationLevel: "moderate", validationAction: "warn" })
// crear colección YA validada:
db.createCollection("users", { validator: {...} })

// Migración
updateMany(filtro-de-no-migrados, cambio)     // idempotente o no es migración
updateMany(filtro, [ { $set: { b: "$a" } } ]) // pipeline: copiar campo a campo

// Los 3 tiempos del despliegue: warn → reparar → error (moderate → strict)