db.runCommand({
  collMod: 'patients',
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['documentId'],
      properties: {
        documentId: {
          bsonType: 'string',
          pattern: '^(HC|PP|LB)-[0-9]+$',
          description: 'documento de identidad con su prefijo'
        },
        // Un arreglo de tipos: el campo puede ser CUALQUIERA de ellos.
        // Feo y honesto: describe lo que hay, no lo que querríamos.
        birthDate: { bsonType: ['string', 'date'] },
        active: { bsonType: ['bool', 'null'] },
        email: { bsonType: ['string', 'null'] },
        contact: {
          bsonType: 'object',
          properties: { email: { bsonType: ['string', 'null'] } }
        }
      }
      // additionalProperties NO se pone. Por defecto es true, y eso es lo
      // que queremos: el régimen de crecimiento de CONTRACT.md depende de
      // que un campo nuevo no rompa nada.
    }
  },
  validationAction: 'warn',
  validationLevel: 'moderate'
});
