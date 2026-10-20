show collections                                    // 1. ¿qué hay?
db.getCollectionInfos().map(c => c.name + ": " + (c.options.validator ? "✅" : "❌"))
db.X.countDocuments()                               // 2. ¿cuánto pesa cada una?
db.X.findOne()                                      // 3. ¿qué forma tiene?
db.X.getIndexes()                                   // 4. ¿qué se indexó?
formas("X")                                         // 5. ¿todos los docs son iguales?