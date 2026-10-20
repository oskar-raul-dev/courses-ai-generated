var __a = [
// En mongosh: activar validación sobre una colección EXISTENTE
db.runCommand({
  collMod: "tickets",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["title", "status", "priority", "reporter", "createdAt"],
      properties: {
        title:    { bsonType: "string", minLength: 1, maxLength: 200 },
        // El vocabulario cerrado del CONTRATO, ahora custodiado por el motor:
        status:   { enum: ["open", "in_progress", "resolved", "closed"] },
        priority: { enum: ["low", "medium", "high"] },
        assignee: { bsonType: ["string", "null"] },   // username o null
        reporter: { bsonType: "string" },
        createdAt:{ bsonType: "date" },               // date BSON EN LA BASE; la API la serializa a ISO string (contrato, Fase 10)
        updatedAt:{ bsonType: "date" },
        schemaVersion: { bsonType: "int" },
        history: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["from", "to", "by", "at"],
            properties: {
              from: { enum: ["open", "in_progress", "resolved", "closed"] },
              to:   { enum: ["open", "in_progress", "resolved", "closed"] },
              by:   { bsonType: "string" },
              at:   { bsonType: "date" }
            }
          }
        }
      }
    }
  },
  validationLevel: "moderate",
  validationAction: "error"
})
];